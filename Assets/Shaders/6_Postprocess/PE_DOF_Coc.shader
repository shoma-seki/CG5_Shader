Shader "PostEffect/PE_DOF_Coc"
{
    Properties
    {
        _FNumber        ("fnumber" ,Range(1,32)) = 2.8
        _FocalLengthMilimeter("FocalLengthMilimeter", Float) = 50
        _FocusDistance  ("FocusDistance", Float) = 1.0
        _BlurLevelWidth ("BlurLevelWidth", Range(0,1)) = 0.05
        _LowBlurLevel   ("LowBlurLevel", Range(0,1)) = 0.05
        _MiddleBlurLevel("MiddleBlurLevel", Range(0,1)) = 0.1
        _HighBlurLevel  ("HighBlurLevel", Range(0,1)) = 0.3

        _DepthTexture       ("深度テクスチャ", 2D) ="black"{}
        _LowBlurTexture     ("弱ブラーテクスチャ", 2D) ="black"{}
        _MiddleBlurTexture  ("中ブラーテクスチャ", 2D) ="black"{}
        _HighBlurTexture    ("強ブラーテクスチャ", 2D) ="black"{}
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

            TEXTURE2D(_LowBlurTexture);
            TEXTURE2D(_MiddleBlurTexture);
            TEXTURE2D(_HighBlurTexture);
            TEXTURE2D(_DepthTexture);
            CBUFFER_START(UnityPerMaterial)

               float _FNumber;
               float _FocalLengthMilimeter;
               float _FocusDistance;
               float _BlurLevelWidth;
               float _LowBlurLevel;
               float _MiddleBlurLevel;
               float _HighBlurLevel;

            CBUFFER_END

            half4 Frag(Varyings IN) : SV_Target
            {
                half depth =  SAMPLE_TEXTURE2D(_DepthTexture, sampler_LinearClamp, IN.texcoord);
                float focalLengthMeter = _FocalLengthMilimeter / 1000;
                depth = max(depth, 1e-3);
                _FocusDistance = max(_FocusDistance, focalLengthMeter + 1e-3);
                float sensorTexelSize = min(_BlitTexture_TexelSize.x, _BlitTexture_TexelSize.y);
                float coc = abs(_FocusDistance - depth) / depth * focalLengthMeter * focalLengthMeter
                                / (_FNumber * (_FocusDistance - focalLengthMeter)) / sensorTexelSize;
                coc = saturate(coc);

                half4 inFocusColor = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, IN.texcoord);
                half4 lowBlurColor = SAMPLE_TEXTURE2D(_LowBlurTexture, sampler_LinearClamp, IN.texcoord);
                half4 middleBlurColor = SAMPLE_TEXTURE2D(_MiddleBlurTexture, sampler_LinearClamp, IN.texcoord);
                half4 highBlurColor = SAMPLE_TEXTURE2D(_HighBlurTexture, sampler_LinearClamp, IN.texcoord);

                float lowWeight = smoothstep(_LowBlurLevel - _BlurLevelWidth / 2, _LowBlurLevel + _BlurLevelWidth / 2, coc);
                float middleWeight = smoothstep(_MiddleBlurLevel - _BlurLevelWidth / 2, _MiddleBlurLevel + _BlurLevelWidth / 2, coc);
                float highWeight = smoothstep(_HighBlurLevel - _BlurLevelWidth / 2, _HighBlurLevel + _BlurLevelWidth / 2, coc);

                // lowBlurColor = half4(1,0,0,1);
                // middleBlurColor = half4(0,1,0,1);
                // highBlurColor = half4(0,0,1,1);

                half4 output = inFocusColor;
                output = lerp(output, lowBlurColor, lowWeight);
                output = lerp(output, middleBlurColor, middleWeight);
                output = lerp(output, highBlurColor, highWeight);

                return output;
            }

            ENDHLSL
        }
    }
}
