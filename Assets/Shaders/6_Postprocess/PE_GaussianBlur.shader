Shader "PostEffect/PE_GaussianBlur"
{
    Properties
    {
        _StepWidth("ブラー密度", Range(0.001, 0.02)) = 0.02
        _Sigma("ブラー強度", Range(0, 0.01)) = 0.01
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

            CBUFFER_START(UnityPerMaterial)
                float _StepWidth;
                float _Sigma;
            CBUFFER_END

            float Gaussian(float x, float sigma)
            {
                sigma = max(sigma, 0.0001);
                return exp(-(x * x) / (2 * sigma * sigma));
            }

            half4 Frag(Varyings IN) : SV_Target
            {
                half4 output = half4(0,0,0,0);

                float totalWeight = 0;
                float kernelWidth = 3 * _Sigma;

                for(float y = -kernelWidth/2;  y <= kernelWidth/2; y += _StepWidth)
                    {
                        for(float x = -kernelWidth/2;  x <= kernelWidth/2; x += _StepWidth)
                        {
                            float2 drawUV = IN.texcoord;
                            float2 pickUV = IN.texcoord + float2(x,y);
                            pickUV = clamp(pickUV, 0.001, 0.999);
                            float d = distance(drawUV, pickUV);
                            float weight = Gaussian(d, _Sigma);

                            half4 color = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearRepeat, pickUV);

                            output += color * weight;
                            totalWeight += weight;
                        }
                    }

                 output /= max(totalWeight, 0.0001);
                 output.a = 1;
                 return output;
            }
            ENDHLSL
        }
    }
}
