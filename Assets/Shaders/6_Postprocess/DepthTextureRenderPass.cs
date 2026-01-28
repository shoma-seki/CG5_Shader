using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class DepthTextureRenderPass : ScriptableRenderPass
{
    private Material Material_ = null;

    public DepthTextureRenderPass(Material material)
    {
        Material_ = material;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (Material_ == null)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        if (resourceData.isActiveTargetBackBuffer) { return; }

        TextureHandle depthTexture = resourceData.activeColorTexture;
        TextureDesc depthTextureDesc = renderGraph.GetTextureDesc(depthTexture);
        depthTextureDesc.name = "_DepthTexture";
        depthTextureDesc.depthBufferBits = 0;
        depthTextureDesc.format = UnityEngine.Experimental.Rendering.GraphicsFormat.R16_SFloat;
        depthTexture = renderGraph.CreateTexture(depthTextureDesc);

        TextureHandle cameraTexture = resourceData.activeColorTexture;

        RenderGraphUtils.BlitMaterialParameters depthTextureBlitDesc
            = new RenderGraphUtils.BlitMaterialParameters(cameraTexture, depthTexture, Material_, 0);

        renderGraph.AddBlitPass(depthTextureBlitDesc, "DrawDepthBlit");
        renderGraph.AddCopyPass(depthTexture, cameraTexture, "CopyBlur");
    }
}
