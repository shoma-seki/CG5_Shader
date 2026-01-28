using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class DOFRenderPass : ScriptableRenderPass
{
    private Material depthMaterial_ = null;
    private Material blurMaterial_ = null;
    private Material dofMaterial_ = null;

    static readonly int depthTextureId = Shader.PropertyToID("_DepthTexture");
    static readonly int blurTextureId = Shader.PropertyToID("_BlurTexture");

    class DepthOfFieldPassData
    {
        public TextureHandle sourceTexture;
        public TextureHandle depthTexture;
        public TextureHandle blurTexture;
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
    /// <param name="blurTexture">ブラーテクスチャ</param>

    private void DepthOfFieldBlit(RenderGraph renderGraph, TextureHandle cameraTexture, TextureHandle destinationTexture
        , TextureHandle depthTexture, TextureHandle blurTexture)
    {
        using (IRasterRenderGraphBuilder builder = renderGraph.AddRasterRenderPass("DepthOfFieldBlit", out DepthOfFieldPassData passData))
        {
            passData.sourceTexture = cameraTexture;
            passData.depthTexture = depthTexture;
            passData.blurTexture = blurTexture;
            passData.destination = destinationTexture;
            passData.material = dofMaterial_;

            builder.UseTexture(passData.sourceTexture);
            builder.UseTexture(passData.depthTexture);
            builder.UseTexture(passData.blurTexture);

            builder.SetRenderAttachment(passData.destination, 0);

            builder.SetRenderFunc((DepthOfFieldPassData data, RasterGraphContext ctx) =>
            {
                data.material.SetTexture(depthTextureId, data.depthTexture);
                data.material.SetTexture(blurTextureId, data.blurTexture);

                Blitter.BlitTexture(ctx.cmd, data.sourceTexture, new Vector4(1, 1, 0, 0), data.material, 0);
            });
        }
    }

    public DOFRenderPass(Material depthMaterial, Material dofMaterial, Material blurMaterial)
    {
        depthMaterial_ = depthMaterial;
        dofMaterial_ = dofMaterial;
        blurMaterial_ = blurMaterial;
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
        blurTextureDesc.name = "_BlurTexture";

        int div = 2;
        blurTextureDesc.width /= div;
        blurTextureDesc.height /= div;

        blurTextureDesc.depthBufferBits = 0;
        TextureHandle blurTexture = renderGraph.CreateTexture(blurTextureDesc);

        //出力先テクスチャ
        TextureDesc destinationTextureDesc = renderGraph.GetTextureDesc(cameraTexture);
        destinationTextureDesc.name = "_DestinationTexture";
        destinationTextureDesc.depthBufferBits = 0;
        TextureHandle destinationTexture = renderGraph.CreateTexture(destinationTextureDesc);


        RenderGraphUtils.BlitMaterialParameters depthTextureBlitDesc
            = new RenderGraphUtils.BlitMaterialParameters(cameraTexture, depthTexture, depthMaterial_, 0);
        renderGraph.AddBlitPass(depthTextureBlitDesc, "DrawDepthBlit");

        RenderGraphUtils.BlitMaterialParameters blurTextureBlitDesc
            = new RenderGraphUtils.BlitMaterialParameters(cameraTexture, blurTexture, blurMaterial_, 0);
        renderGraph.AddBlitPass(blurTextureBlitDesc, "DrawBlurBlit");

        DepthOfFieldBlit(renderGraph, cameraTexture, destinationTexture, depthTexture, blurTexture);

        renderGraph.AddCopyPass(destinationTexture, cameraTexture, "CopyDof");
    }
}
