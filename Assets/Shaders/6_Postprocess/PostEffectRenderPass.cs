using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class PostEffectRenderPass : ScriptableRenderPass
{
    private Material blurMaterial_ = null;
    private Material passThroughMaterial_ = null;

    public PostEffectRenderPass(Material blurMaterial, Material passThroughMaterial)
    {
        blurMaterial_ = blurMaterial;
        passThroughMaterial_ = passThroughMaterial;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (blurMaterial_ == null || passThroughMaterial_ == null)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        if (resourceData.isActiveTargetBackBuffer) { return; }

        TextureHandle cameraTexture = resourceData.activeColorTexture;
        TextureDesc tempDesc = renderGraph.GetTextureDesc(cameraTexture);
        tempDesc.name = "_OrigTempTexture";
        tempDesc.depthBufferBits = 0;

        TextureHandle origTempTexture = renderGraph.CreateTexture(tempDesc);

        tempDesc.name = "_SmallTempTexture";
        int div = 2;
        tempDesc.width /= div;
        tempDesc.height /= div;
        TextureHandle smallTempTexture = renderGraph.CreateTexture(tempDesc);

        RenderGraphUtils.BlitMaterialParameters downSampleBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(cameraTexture, smallTempTexture, blurMaterial_, 0);
        renderGraph.AddBlitPass(downSampleBlitMaterialParameters, "DownSamplingBlitBlur");

        RenderGraphUtils.BlitMaterialParameters upSampleBlitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(cameraTexture, origTempTexture, passThroughMaterial_, 0);
        renderGraph.AddBlitPass(upSampleBlitMaterialParameters, "UpSamplingBlitBlur");

        renderGraph.AddCopyPass(origTempTexture, cameraTexture, "CopyGreenPostEffect");
    }
}
