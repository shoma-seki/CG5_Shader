Shader "Unlit/20_GrabPass"
{
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
		_Shift ("Shift", Range(0.0, 1.0)) = 0
		_HeightScale ("HeightScale", Range(0, 5)) = 0.1
		_HeightPlus ("HeightPlus", float) = 0.1
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
			#include "Parallax.cginc"

            fixed4 _Color;
            float _Shift;

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
				float3 viewDirTS : TEXCOORD2;
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

			fixed4 frag(v2f i) : SV_TARGET
			{
				// float3 viewDirTS = i.viewDirTS;

				// float2 uvPOM = ParallaxOcclusionMapping(i.uv, viewDirTS, _Time.y, _HeightScale, _HeightPlus);

				float4 uv = i.uv;
				float density = (sin(_Time.y) * 5);
				uv.x -= _Shift;
				uv.y += _Shift;

				return tex2Dproj(_GrabPassTexture, uv);
			}
			ENDCG
		}
	}
}