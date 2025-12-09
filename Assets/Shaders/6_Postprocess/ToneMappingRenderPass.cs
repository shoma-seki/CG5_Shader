using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RenderGraphModule.Util;
using UnityEngine.Rendering.Universal;

public class ToneMappingRenderPass : ScriptableRenderPass
{
    private Material material = null;

    public ToneMappingRenderPass(Material postEffectMaterial)
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
        tempDesc.name = "_ToneMapiing";
        tempDesc.depthBufferBits = 0;

        TextureHandle tempTexture = renderGraph.CreateTexture(tempDesc);

        RenderGraphUtils.BlitMaterialParameters blitMaterialParameters =
            new RenderGraphUtils.BlitMaterialParameters(cameraTexture, tempTexture, material, 0);
        renderGraph.AddBlitPass(blitMaterialParameters, "BlitToneMapping");
        renderGraph.AddCopyPass(tempTexture, cameraTexture, "CopyToneMapping");
    }
}
