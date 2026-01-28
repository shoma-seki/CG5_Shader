using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class DOFRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material depthMaterial_;
    [SerializeField] private Material blurMaterial_;
    [SerializeField] private Material dofMaterial_;
    private DOFRenderPass renderPass;

    public override void Create()
    {
        renderPass = new DOFRenderPass(depthMaterial_, dofMaterial_, blurMaterial_);
        renderPass.renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
    }

    public override void AddRenderPasses(ScriptableRenderer rendererPass, ref RenderingData renderingData)
    {
        if (renderingData.cameraData.isSceneViewCamera)
        {
           // return;
        }

        if (rendererPass != null)
        {
            rendererPass.EnqueuePass(renderPass);
        }
    }
}
