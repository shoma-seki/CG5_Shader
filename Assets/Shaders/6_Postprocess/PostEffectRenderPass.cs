using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class PostEffectRenderPass : ScriptableRenderPass
{
    private Material material = null;

    public PostEffectRenderPass(Material postEffectMaterial)
    {
        material = postEffectMaterial;
    }

    public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
    {
        if (material == null)
        {
            base.RecordRenderGraph(renderGraph, frameData);
            return;
        }

        UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
        if (resourceData.isActiveTargetBackBuffer) { return; }

        TextureHandle cameraTexture = resourceData.activeColorTexture;
        TextureDesc tempDesc = renderGraph.GetTextureDesc(cameraTexture);
        tempDesc.name = "_GreenTexture";
        tempDesc.depthBufferBits = 0;

        TextureHandle tempTexture = renderGraph.CreateTexture(tempDesc);

        RenderGraphUtils.BlitMaterialParameters blitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(cameraTexture, tempTexture, material, 0);
        renderGraph.AddBlitPass(blitMaterialParameters, "BlitGreenPostEffect");
        renderGraph.AddCopyPass(tempTexture, cameraTexture, "CopyGreenPostEffect");
    }
}
