Shader "PostEffect/PE_TextureComposite"
{
    Properties
    {
        _OtherTexture("OtherTexture", 2D) = "black" {}
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

            TEXTURE2D(_OtherTexture);

            SAMPLER(sampler_OtherTexture);

            float Gaussian(float x, float sigma)
            {
                sigma = max(sigma, 0.0001);
                return exp(-(x * x) / (2 * sigma * sigma));
            }

            half4 Frag(Varyings IN) : SV_Target
            {
                half4 blitColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, IN.texcoord);
                half4 otherColor = SAMPLE_TEXTURE2D(_OtherTexture, sampler_LinearClamp, IN.texcoord);

                half4 output = saturate(blitColor + otherColor);
                return output;
            }
            ENDHLSL
        }
    }
}
