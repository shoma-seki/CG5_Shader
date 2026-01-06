Shader "PostEffect/PE_AverageBlur"
{
    Properties
    {
        _StepWidth("ブラー密度",Range(0, 0.1)) = 0.01
        _StepNums("ブラー強度",Range(0, 5)) = 3
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
                float _StepNums;
            CBUFFER_END

            half4 Frag(Varyings IN) : SV_Target
            {
                half4 output = half4(0,0,0,0);
                float loopCount = 0;

                _StepNums = floor(_StepNums);

                for(float y = -_StepNums/2;  y <= _StepNums/2; y += 1.0)
                    {
                        for(float x = -_StepNums/2;  x <= _StepNums/2; x += 1.0)
                        {
                            float2 pickUV = IN.texcoord + float2(x,y) * _StepWidth;
                            pickUV = clamp(pickUV, 0.001, 0.999);
                            output += SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearRepeat, pickUV);
                            loopCount += 1.0;
                        }
                    }

                 output /= loopCount;
                 output.a = 1;
                 return output;
            }
            ENDHLSL
        }
    }
}
