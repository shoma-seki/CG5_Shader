Shader "Custom/DepthTexture"
{
    Properties
    {
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
            Name "DrawDepthTexture"
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv : TEXCOORD0;

                float4 screenPosPreDivW : TEXCOORD1;
            };

            Varyings  vert(Attributes IN)
            {
                Varyings OUT;
                VertexPositionInputs vp = GetVertexPositionInputs(IN.positionOS.xyz);
                OUT.positionCS = vp.positionCS;

                OUT.uv = IN.uv;
                OUT.screenPosPreDivW = ComputeScreenPos(OUT.positionCS);

                return OUT;
            }

            half4 Frag(Varyings IN) : SV_Target
            {
                float2 screenUV = IN.screenPosPreDivW.xy / IN.screenPosPreDivW.w;
                float rawSceneDepth = SampleSceneDepth(screenUV);

                half4 col = half4(1,0,0,0) * rawSceneDepth;

                col.a = 1;
                return col;
            }
            ENDHLSL
        }
    }
}
