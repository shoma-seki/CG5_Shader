Shader "PostEffect/PE_ToneMapping"
{
    Properties
    {
        saturation("彩度", range(0,1)) = 1
        contrast("コントラスト", range(0,2)) = 1
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

            half GetLuminance(half3 color)
            {
                return dot(color, half3(0.2126, 0.7152, 0.0722));
            }

            half Linear(half luminance)
            {
                return luminance;
            }

            half Division(half luminance, half divider)
            {
                return luminance/divider;
            }

            half Reinhard(half lIn)
            {
                return lIn / (1 + lIn);
            }

            half3 MulAcesInputMatrix(half3 col)
            {
                half3x3 acesInputMatrix = half3x3
                (
                    0.59719, 0.35438, 0.04823,
                    0.07600, 0.90834, 0.01566,
                    0.02840, 0.13383, 0.83777
                );

                return mul(acesInputMatrix, col);
            }

            half3 RRTAndODTFit(half3 v)
            {
                half3 a = v * (v + 0.0245786) - 0.000090537;
                half3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
                return a / b;
            }

            half3 MulAcesOutputMatrix(half3 col)
            {
                half3x3 acesOutputMatrix = half3x3
                (
                    1.60475, -0.53108, -0.07367,
                    -0.10208, 1.10813, -0.00605,
                    -0.00327, -0.07276, 1.07602
                );
                
                return mul(acesOutputMatrix, col);
            }

            half4 Frag(Varyings input) : SV_Target
            {
                half4 output = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearRepeat, input.texcoord);

                half3 acesInput = MulAcesInputMatrix(output.rgb);
                half3 transpose = RRTAndODTFit(acesInput);
                half3 acesOutput = MulAcesOutputMatrix(transpose);
                half4 outputColor = half4(acesOutput, 1);

                outputColor.a = 1;

                return outputColor;
            }
            ENDHLSL
        }
    }
}
