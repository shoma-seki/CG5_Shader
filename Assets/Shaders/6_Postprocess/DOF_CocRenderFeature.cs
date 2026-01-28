using System;
using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class DOF_CocRenderFeature : ScriptableRendererFeature
{
    [SerializeField] private Material depthMaterial_;
    [SerializeField] private Material lowBlurMaterial_;
    [SerializeField] private Material middleBlurMaterial_;
    [SerializeField] private Material highBlurMaterial_;
    [SerializeField] private Material dofMaterial_;
    private DOF_CocRenderPass renderPass;

    public override void Create()
    {
        renderPass = new DOF_CocRenderPass(depthMaterial_, dofMaterial_, lowBlurMaterial_, middleBlurMaterial_, highBlurMaterial_);
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
