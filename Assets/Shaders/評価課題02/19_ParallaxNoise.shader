Shader "Unlit/19_ParallaxNoise"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_HeightScale ("HeightScale", Range(0, 5)) = 0.1
		_HeightPlus ("HeightPlus", float) = 0.1
		_MinLayers ("MinLayers", Range(4, 64)) = 8
		_MaxLayers ("MaxLayers", Range(16, 256)) = 32
		_Density ("Density", float) = 10
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" }
		Pass
		{
			Stencil
			{
				Ref 3
				Comp Always
				Pass Replace

			}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "Noise.cginc"
			#include "UnityCG.cginc"
            #include "Lighting.cginc"

			float _ParallaxShallow;
			float _ParallaxDeep;

			struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
				float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;  
				float3 viewDirTS : TEXCOORD1;
            };
			
            sampler2D _MainTex;
			float4 _MainTex_ST;
			
			float _HeightScale;
			float _HeightPlus;
			float _MinLayers;
			float _MaxLayers;

			float _Density;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				float3 viewDirWS = _WorldSpaceCameraPos.xyz - worldPos;

				float3 t = normalize(mul(
					(float3x3)unity_ObjectToWorld, v.tangent.xyz));
				float3 n = normalize(mul(
					(float3x3)unity_ObjectToWorld, v.normal));
				float3 b = cross(n, t) * 
					v.tangent.w * unity_WorldTransformParams.w;

				float3x3 TBN = float3x3(t, b, n);
				o.viewDirTS = mul(TBN, viewDirWS);

				return o;
			}
			
			float2 ParallaxOcclusionMapping(float2 uv, float3 viewDirTS)
			{
				float density = (sin(_Time.y) * 5);
				//float density = _Density;

				float3 v = normalize(viewDirTS);

				float ndotv = abs(v.z);
				float numLayers = lerp(_MaxLayers, _MinLayers, ndotv);
				float layerDepth = 1.0 / numLayers;

				float2 P = v.xy / max(v.z, 0.0001) * _HeightScale;
				float2 deltaTexCoord = P / numLayers;

				float2 curTexCoord = uv;
				float curLayerDepth = 0.0;
				float curHeight = FractalSumNoise(density, curTexCoord);

				[loop]
				for(int i = 0; i < (int)_MaxLayers; i++)
				{
					if(curLayerDepth > curHeight){ break; }
					curTexCoord -= deltaTexCoord;
					curLayerDepth += layerDepth;
					curHeight = FractalSumNoise(density, curTexCoord);
				}

				float2 preTexCoord = curTexCoord + deltaTexCoord;
				float preLayerDepth = curLayerDepth - layerDepth;
				float preHeight = FractalSumNoise(density, curTexCoord);

				// preHeight += _HeightPlus;
				// preLayerDepth += _HeightPlus;
				// curHeight += _HeightPlus;
				// curLayerDepth += _HeightPlus;

				float heightDiff = preHeight - preLayerDepth;
				float curDiff = curHeight - curLayerDepth;
				float weight = heightDiff / (heightDiff - curDiff + 1e-5);

				float2 finalTexCoord =
					lerp(curTexCoord, preTexCoord, saturate(weight));
				return finalTexCoord - deltaTexCoord * _HeightPlus;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float3 viewDirTS = i.viewDirTS;

				float2 uvPOM = ParallaxOcclusionMapping(i.uv, viewDirTS);
				//uvPOM = clamp(uvPOM, 0.0, 1.0);

				return tex2D(_MainTex, uvPOM);
			}

			ENDCG
		}
	}
}