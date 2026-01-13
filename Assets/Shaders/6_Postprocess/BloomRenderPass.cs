using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class BloomRenderPass : ScriptableRenderPass
{
    private Material blurMaterial_ = null;
    private Material luminanceExtractMaterial_ = null;
    private Material compositeTextureMaterial_ = null;

    static readonly int luminanceBlurTextureId = Shader.PropertyToID("_OtherTexture");

    class CompositePassData
    {
        public TextureHandle sourceTexture;
        public TextureHandle otherTexture;
        public TextureHandle destination;
        public Material material;
    }

    public BloomRenderPass(Material blurMaterial, Material luminanceExtractMaterial, Material compositeTextureMaterial)
    {
        blurMaterial_ = blurMaterial;
        luminanceExtractMaterial_ = luminanceExtractMaterial;
        compositeTextureMaterial_ = compositeTextureMaterial;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (blurMaterial_ == null || luminanceExtractMaterial_ == null || compositeTextureMaterial_ == null)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        if (resourceData.isActiveTargetBackBuffer)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        TextureHandle cameraTexture = resourceData.activeColorTexture;
        TextureDesc originalTextureDesc = renderGraph.GetTextureDesc(cameraTexture);
        originalTextureDesc.name = "_OriginalTexture";
        originalTextureDesc.depthBufferBits = 0;

        TextureHandle origTempTexture = renderGraph.CreateTexture(originalTextureDesc);

        ///テクスチャを作る↓↓↓↓↓
        TextureDesc luminanceTextureDesc = originalTextureDesc;
        luminanceTextureDesc.name = "_SmallTempTexture";

        int div = 4;
        luminanceTextureDesc.width /= div;
        luminanceTextureDesc.height /= div;

        luminanceTextureDesc.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R8G8B8A8_UNorm;
        ///テクスチャを作る↑↑↑↑↑

        TextureHandle luminanceTexture = renderGraph.CreateTexture(luminanceTextureDesc);
        TextureHandle luminanceBlurTexture = renderGraph.CreateTexture(luminanceTextureDesc);

        RenderGraphUtils.BlitMaterialParameters luminanceExtractBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(cameraTexture, luminanceTexture, luminanceExtractMaterial_, 0);
        renderGraph.AddBlitPass(luminanceExtractBlitMaterialParameters, "LuminanceExtractBlit");

        RenderGraphUtils.BlitMaterialParameters brightnessBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(luminanceTexture, luminanceBlurTexture, blurMaterial_, 0);
        renderGraph.AddBlitPass(brightnessBlitMaterialParameters, "BrightnessBlit");

        ///川瀬ブラー1↓↓↓↓↓
        TextureDesc kawaseTextureDesc1 = renderGraph.GetTextureDesc(luminanceBlurTexture);

        kawaseTextureDesc1.width /= div;
        kawaseTextureDesc1.height /= div;
        kawaseTextureDesc1.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R8G8B8A8_UNorm;
        TextureHandle kawaseTexture1 = renderGraph.CreateTexture(kawaseTextureDesc1);

        RenderGraphUtils.BlitMaterialParameters kawaseBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(luminanceBlurTexture, kawaseTexture1, blurMaterial_, 0);
        renderGraph.AddBlitPass(kawaseBlitMaterialParameters, "KawaseBlur1");
        ///川瀬ブラー1↑↑↑↑↑

        ///川瀬ブラー2↓↓↓↓↓
        TextureDesc kawaseTextureDesc2 = renderGraph.GetTextureDesc(kawaseTexture1);

        kawaseTextureDesc2.width /= div;
        kawaseTextureDesc2.height /= div;
        kawaseTextureDesc2.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R8G8B8A8_UNorm;
        TextureHandle kawaseTexture2 = renderGraph.CreateTexture(kawaseTextureDesc1);

        RenderGraphUtils.BlitMaterialParameters kawaseBlitMaterialParameters2 =
            new RenderGraphUtils.BlitMaterialParameters(luminanceBlurTexture, kawaseTexture2, blurMaterial_, 0);
        renderGraph.AddBlitPass(kawaseBlitMaterialParameters2, "KawaseBlur2");
        ///川瀬ブラー2↑↑↑↑↑

        using (IRasterRenderGraphBuilder builder = renderGraph.AddRasterRenderPass("BloomComposite", out CompositePassData passData))
        {
            passData.sourceTexture = cameraTexture;
            passData.otherTexture = kawaseTexture2;
            passData.destination = origTempTexture;
            passData.material = compositeTextureMaterial_;

            builder.UseTexture(passData.sourceTexture);
            builder.UseTexture(passData.otherTexture);
            builder.SetRenderAttachment(passData.destination, 0);

            builder.SetRenderFunc((CompositePassData data, RasterGraphContext ctx)
                =>
            {
                data.material.SetTexture(luminanceBlurTextureId, data.otherTexture);
                Blitter.BlitTexture(ctx.cmd, data.sourceTexture, new Vector4(1, 1, 0, 0), data.material, 0);
            });
        }

        renderGraph.AddCopyPass(origTempTexture, cameraTexture, "CopyBloom");
    }
}
