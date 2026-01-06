using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class PostEffectRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material blurMaterial_;
    [SerializeField] private Material passThroughMaterial_;
    private PostEffectRenderPass renderPass;

    public override void Create()
    {
        renderPass = new PostEffectRenderPass(blurMaterial_, passThroughMaterial_);
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
