using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class DepthTextureRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material material_;
    private DepthTextureRenderPass renderPass;

    public override void Create()
    {
        renderPass = new DepthTextureRenderPass(material_);
        renderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public override void AddRenderPasses(ScriptableRenderer rendererPass, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.isSceneViewCamera)
        {
            return;
        }

        if (rendererPass != null)
        {
            rendererPass.EnqueuePass(renderPass);
        }
    }
}
