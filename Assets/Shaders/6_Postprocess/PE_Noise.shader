Shader "PostEffect/PE_Noise"
{
    Properties
    {
        saturation("彩度", range(0,1)) = 1
        contrast("コントラスト", range(0,2)) = 1
        push("ずらし具合", float) = 1
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
            #include "Noise.cginc"

            half saturation;
            half contrast;
            half push;

            half4 Frag(Varyings input) : SV_Target
            {
                float2 uv = input.texcoord;

                uv.x += FractalSumNoise(-push, uv);
				uv.y += FractalSumNoise(-push, uv);
				uv.x -= FractalSumNoise(push, uv);
				uv.y -= FractalSumNoise(push, uv);

                uv = clamp(uv, 0.001, 0.999);

                half4 output = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearRepeat, uv);

                half grayscale =
                0.2126 * output.r + 0.7152 * output.g + 0.0722 * output.b;

                half4 monochromeColor = half4(grayscale, grayscale, grayscale, 1);

                half4 outputColor = lerp(monochromeColor, output, saturation);

                outputColor = (outputColor - 0.5) * contrast + 0.5;

                return outputColor;
            }
            ENDHLSL
        }
    }
}
