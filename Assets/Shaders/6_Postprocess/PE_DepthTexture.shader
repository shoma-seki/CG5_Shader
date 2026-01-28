Shader "PostEffect/PE_DepthTexture"
{
    SubShader
    {
        Tags { "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
            ZWrite Off
            ZTest Always
            Blend Off
            Cull Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma editor_sync_compilation

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            half4 Frag(Varyings IN) : SV_Target
            {
                float rawSceneDepth = SampleSceneDepth(IN.texcoord);
                rawSceneDepth = LinearEyeDepth(rawSceneDepth, _ZBufferParams);
                return rawSceneDepth;
            }
            ENDHLSL
        }
    }
}
