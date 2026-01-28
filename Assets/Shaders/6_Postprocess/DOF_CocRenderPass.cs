using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class DOF_CocRenderPass : ScriptableRenderPass
{
    private Material depthMaterial_ = null;
    private Material lowBlurMaterial_ = null;
    private Material middleBlurMaterial_ = null;
    private Material highBlurMaterial_ = null;
    private Material dofMaterial_ = null;

    static readonly int depthTextureId = Shader.PropertyToID("_DepthTexture");
    static readonly int lowBlurTextureId = Shader.PropertyToID("_LowBlurTexture");
    static readonly int middleBlurTextureId = Shader.PropertyToID("_MiddleBlurTexture");
    static readonly int highBlurTextureId = Shader.PropertyToID("_HighBlurTexture");

    class DepthOfFieldPassData
    {
        public TextureHandle sourceTexture;
        public TextureHandle depthTexture;
        public TextureHandle blurTextureLow;
        public TextureHandle blurTextureMiddle;
        public TextureHandle blurTextureHigh;
        public TextureHandle destination;
        public Material material;
    }

    /// <summary>
    /// 被写界深度を適用する
    /// </summary>
    /// <param name="renderGraph">使用しているRenderGraph</param>
    /// <param name="cameraTexture">未加工のカメラテクスチャ</param>
    /// <param name="destinationTexture">出力先テクスチャ</param>
    /// <param name="depthTexture">深度テクスチャ</param>
    /// <param name="blurTextureLow">ブラーテクスチャ</param>d
    /// <param name="blurTextureMiddle">ブラーテクスチャ</param>d
    /// <param name="blurTextureHigh">ブラーテクスチャ</param>d

    private void DepthOfFieldBlit(RenderGraph renderGraph, TextureHandle cameraTexture, TextureHandle destinationTexture
        , TextureHandle depthTexture, TextureHandle blurTextureLow, TextureHandle blurTextureMiddle, TextureHandle blurTextureHigh)
    {
        using (IRasterRenderGraphBuilder builder = renderGraph.AddRasterRenderPass("DepthOfFieldBlit", out DepthOfFieldPassData passData))
        {
            passData.sourceTexture = cameraTexture;
            passData.depthTexture = depthTexture;
            passData.blurTextureLow = blurTextureLow;
            passData.blurTextureMiddle = blurTextureMiddle;
            passData.blurTextureHigh = blurTextureHigh;
            passData.destination = destinationTexture;
            passData.material = dofMaterial_;

            builder.UseTexture(passData.sourceTexture);
            builder.UseTexture(passData.depthTexture);
            builder.UseTexture(passData.blurTextureLow);
            builder.UseTexture(passData.blurTextureMiddle);
            builder.UseTexture(passData.blurTextureHigh);

            builder.SetRenderAttachment(passData.destination, 0);

            builder.SetRenderFunc((DepthOfFieldPassData data, RasterGraphContext ctx) =>
            {
                data.material.SetTexture(depthTextureId, data.depthTexture);
                data.material.SetTexture(lowBlurTextureId, data.blurTextureLow);
                data.material.SetTexture(middleBlurTextureId, data.blurTextureMiddle);
                data.material.SetTexture(highBlurTextureId, data.blurTextureHigh);

                Blitter.BlitTexture(ctx.cmd, data.sourceTexture, new Vector4(1, 1, 0, 0), data.material, 0);
            });
        }
    }

    public DOF_CocRenderPass(Material depthMaterial, Material dofMaterial,
        Material lowBlurMaterial, Material middleBlurMaterial, Material highBlurMaterial)
    {
        depthMaterial_ = depthMaterial;
        dofMaterial_ = dofMaterial;
        lowBlurMaterial_ = lowBlurMaterial;
        middleBlurMaterial_ = middleBlurMaterial;
        highBlurMaterial_ = highBlurMaterial;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (depthMaterial_ == null)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        if (resourceData.isActiveTargetBackBuffer) { return; }

        TextureHandle cameraTexture = resourceData.activeColorTexture;

        //深度テクスチャ
        TextureDesc depthTextureDesc = renderGraph.GetTextureDesc(cameraTexture);
        depthTextureDesc.name = "_DepthTexture";
        depthTextureDesc.depthBufferBits = 0;
        depthTextureDesc.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R16_SFloat;
        TextureHandle depthTexture = renderGraph.CreateTexture(depthTextureDesc);

        //ブラーテクスチャ
        TextureDesc blurTextureDesc = renderGraph.GetTextureDesc(cameraTexture);

        //low
        blurTextureDesc.name = "_LowBlurTexture";

        int div = 2;
        blurTextureDesc.width /= div;
        blurTextureDesc.height /= div;

        blurTextureDesc.depthBufferBits = 0;
        TextureHandle lowBlurTexture = renderGraph.CreateTexture(blurTextureDesc);

        //middle
        blurTextureDesc.name = "_MiddleBlurTexture";
        TextureHandle middleBlurTexture = renderGraph.CreateTexture(blurTextureDesc);

        div = 2;
        blurTextureDesc.width /= div;
        blurTextureDesc.height /= div;

        blurTextureDesc.depthBufferBits = 0;

        //high
        blurTextureDesc.name = "_HighBlurTexture";
        TextureHandle highBlurTexture = renderGraph.CreateTexture(blurTextureDesc);

        //出力先テクスチャ
        TextureDesc destinationTextureDesc = renderGraph.GetTextureDesc(cameraTexture);
        destinationTextureDesc.name = "_DestinationTexture";
        destinationTextureDesc.depthBufferBits = 0;
        TextureHandle destinationTexture = renderGraph.CreateTexture(destinationTextureDesc);


        RenderGraphUtils.BlitMaterialParameters depthTextureBlitDesc
            = new RenderGraphUtils.BlitMaterialParameters(cameraTexture, depthTexture, depthMaterial_, 0);
        renderGraph.AddBlitPass(depthTextureBlitDesc, "DrawDepthBlit");

        RenderGraphUtils.BlitMaterialParameters lowBlurTextureBlitDesc
            = new RenderGraphUtils.BlitMaterialParameters(cameraTexture, lowBlurTexture, lowBlurMaterial_, 0);
        renderGraph.AddBlitPass(lowBlurTextureBlitDesc, "DrawLowBlurBlit");

        RenderGraphUtils.BlitMaterialParameters middleBlurTextureBlitDesc
            = new RenderGraphUtils.BlitMaterialParameters(cameraTexture, middleBlurTexture, middleBlurMaterial_, 0);
        renderGraph.AddBlitPass(middleBlurTextureBlitDesc, "DrawMiddleBlurBlit");

        RenderGraphUtils.BlitMaterialParameters highBlurTextureBlitDesc
            = new RenderGraphUtils.BlitMaterialParameters(cameraTexture, highBlurTexture, highBlurMaterial_, 0);
        renderGraph.AddBlitPass(highBlurTextureBlitDesc, "DrawHighBlurBlit");

        DepthOfFieldBlit(renderGraph, cameraTexture, destinationTexture, depthTexture, lowBlurTexture, middleBlurTexture, highBlurTexture);

        renderGraph.AddCopyPass(destinationTexture, cameraTexture, "CopyDof");
    }
}
