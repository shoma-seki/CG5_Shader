Shader "PostEffect/PE_DOF"
{
    Properties
    {
        _FocusDistance("FocusDistance", Float) = 1.0
        _FocusRange("FocusRange", Float) = 2.0
        _DepthTexture("DepthTexture", 2D) = "black"{}
        _BlurTexture("BlurTexture", 2D) = "black"{}
    }

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

            TEXTURE2D(_BlurTexture);
            TEXTURE2D(_DepthTexture);
            CBUFFER_START(UnityPerMaterial)
                float _FocusDistance;
                float _FocusRange;
            CBUFFER_END

            half4 Frag(Varyings IN) : SV_Target
            {
                half depth =  SAMPLE_TEXTURE2D(_DepthTexture, sampler_LinearClamp, IN.texcoord);
                half focusDistance = abs(_FocusDistance - depth);
                half focusFactor = smoothstep(0.0, _FocusRange, focusDistance);

                half4 inFocusColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, IN.texcoord);
                half4 outOfFocusColor = SAMPLE_TEXTURE2D(_BlurTexture, sampler_LinearClamp, IN.texcoord);

                half4 output = lerp(inFocusColor, outOfFocusColor, focusFactor);
                return output;
            }

            ENDHLSL
        }
    }
}
