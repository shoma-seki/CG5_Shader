Shader "Unlit/21_GrabPassWater"
{
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
		_ShiftX ("ShiftX", Range(-1.0, 1.0)) = 0
		_ShiftY ("ShiftY", Range(-1.0, 1.0)) = 0
		_Push ("Push", Range(0, 5.0)) = 0
		_HeightScale ("HeightScale", Range(0, 5)) = 0.1
		_HeightPlus ("HeightPlus", float) = 0.1

		_ModelScreenCenter ("Model Center (Screen)", Vector) = (0.5,0.5,0,0)
	}
	SubShader
	{		
		Tags{ "Queue" = "Transparent+100" }

		GrabPass {"_GrabPassTexture"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "Lighting.cginc"
			#include "Noise.cginc"

            fixed4 _Color;
            float _ShiftX;
            float _ShiftY;
			float _Push;

			struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
				float4 tangent : TANGENT;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
            };
			
            sampler2D _GrabPassTexture;
			
			float _HeightScale;
			float _HeightPlus;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = ComputeGrabScreenPos(o.vertex);

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float4 uv = i.uv;

				//float density = (sin(_Time.y) * 5 - 2) * FractalSumNoise(5, uv);
				
				uv.x += FractalSumNoise(-_Push, uv);
				uv.y += FractalSumNoise(-_Push, uv);
				uv.x -= FractalSumNoise(_Push, uv);
				uv.y -= FractalSumNoise(_Push, uv);

				return tex2Dproj(_GrabPassTexture, uv);
			}
			ENDCG
		}
	}
}