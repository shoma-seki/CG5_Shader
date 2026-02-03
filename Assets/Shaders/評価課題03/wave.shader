Shader "Custom/wave"
{
    Properties
    {
        _BaseMap("BaseMap", 2D) = "white"{}
        _Softness("Softness", Range(0.001, 10.0)) = 0.15
        _Density("Density", Range(0, 10)) = 5
        _Step("Step", Range(0,1)) = 0.5
        _Speed("Speed", Float) = 0.1
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
            Name "IntersectionHighlight"
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "MultiNoise.cginc"
            #include "Noise.cginc"
            #include "CellulerNoise.cginc"

            TEXTURE2D(_BaseMap);
            SAMPLER(sampler_BaseMap);

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _BaseMap_ST;
                float _Softness;
                float _Density;
                float _Step;
                float _Speed;
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
                float soft = 1 - saturate(diff / max(_Softness, 0.001));

                half4 tex = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, IN.uv);

                half4 col = tex * IN.color;

                float2 waveDir = float2(1.0, 1.0);
                float speed = _Speed;

                float2 waveUV = IN.uv + waveDir * _Time.y * speed;
                //float noise = PerlinNoise(1.0, waveUV * _Density);
                //float noise = hybridMultifractal(IN.uv * 100, 10, 2.0, 100, _Time.y);
                float noise = cellularnoise(waveUV, 60, _Time.x);
                noise = step(noise, _Step);
                                         
                col = smoothstep(half4(0,0,0,0), col, noise);
                col = lerp(half4(0.2, 0.2, 0.9, 0.5), col, soft);

                if(soft > cellularnoise(waveUV, 60, _Time.x))
                {
                    col = half4(1,1,1,1);
                }

                return col;
            }
            ENDHLSL
        }
    }
}
