using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class BloomRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material bloomMaterial_;
    [SerializeField] private Material luminanceExtractMaterial_;
    [SerializeField] private Material textureCompositeMaterial_;
    private BloomRenderPass renderPass;

    public override void Create()
    {
        renderPass = new BloomRenderPass(bloomMaterial_, luminanceExtractMaterial_, textureCompositeMaterial_);
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
