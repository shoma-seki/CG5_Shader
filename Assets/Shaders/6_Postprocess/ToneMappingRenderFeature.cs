using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class ToneMappingRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material postEffectMaterial;
    private ToneMappingRenderPass renderPass;

    public override void Create()
    {
        renderPass = new ToneMappingRenderPass(postEffectMaterial);
        renderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public override void AddRenderPasses(ScriptableRenderer rendererPass, ref RenderingData renderingData)
    {
        if (rendererPass != null)
        {
            rendererPass.EnqueuePass(renderPass);
        }
    }
}
