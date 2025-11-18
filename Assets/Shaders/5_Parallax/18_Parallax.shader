Shader "Unlit/18_Parallax"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_SubTex ("SubTexture", 2D) = "black" {}
		_Prallax("Parallax", float) = 0.5
		_SubPrallax("SubParallax", float) = 0
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "Lighting.cginc"

			float _Prallax;
			float _SubPrallax;

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
            sampler2D _SubTex;
			float4 _SubTex_ST;
			
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

				o.viewDirTS = 
					t * viewDirWS.x + b * viewDirWS.y + n * viewDirWS.z;

				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				//tiling
				float2 tiling = _MainTex_ST.xy;
				float2 subTiling = _SubTex_ST.xy;

				float3 viewDirTS = normalize(-i.viewDirTS);

				float2 mainOffset = viewDirTS.xy * _Prallax;
				float2 subOffset = viewDirTS.xy * _SubPrallax;

				float2 mainUV = i.uv * tiling + _MainTex_ST.zw + mainOffset;
				float2 subUV = i.uv * subTiling + _MainTex_ST.zw + subOffset;

				fixed4 mainColor = tex2D(_MainTex, mainUV);
				fixed4 subColor = tex2D(_SubTex, subUV);
				
				return lerp(mainColor, subColor, subColor.a);
			}
			ENDCG
		}
	}
}