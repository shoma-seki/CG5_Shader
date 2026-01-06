Shader "Custom/SoftParticle"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) = "white"{}
        _Softness("Softness", Range(0.001, 1.0)) = 0.15
    }

    SubShader
    {
        Tags { 
            "RenderPipeline" = "UniversalPipeline" 
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
            }

        Pass
        {
            Name "SoftParticle"
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseMap_ST;
                float _Softness;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;

                float4 color : COLOR;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;

                float4 color : COLOR;

                float4 screenPosPreDivW : TEXCOORD1;

                float eyeDepth : TEXCOORD2;
            };

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                VertexPositionInputs vp = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = vp.positionCS;

                OUT.uv = TRANSFORM_TEX(IN.uv, _BaseMap);
                OUT.color = IN.color;
                OUT.screenPosPreDivW = ComputeScreenPos(OUT.positionCS);

                OUT.eyeDepth = abs(vp.positionVS.z);

                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float2 screenUV = IN.screenPosPreDivW.xy / IN.screenPosPreDivW.w;
                float rawSceneDepth = SampleSceneDepth(screenUV);

                float sceneEyeDepth = LinearEyeDepth(rawSceneDepth, _ZBufferParams);

                float diff = sceneEyeDepth - IN.eyeDepth;
                float soft = saturate(diff / max(_Softness, 0.001));

                half4 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);

                half4 col = tex * IN.color;
                col.a *= soft;
                return col;
            }
            ENDHLSL
        }
    }
}
