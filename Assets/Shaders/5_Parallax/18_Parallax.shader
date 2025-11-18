Shader "Unlit/18_Parallax"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_HeightTex ("HeightTexture", 2D) = "black" {}
		_ParallaxShallow("ParallaxShallow", float) = 0
		_ParallaxDeep("DeepParallax", float) = 0.05
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
			sampler2D _HeightTex;
			float4 _HeightTex_ST;
			
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
				
				float3 viewDirTS = normalize(-i.viewDirTS);
				float2 mainUV = i.uv * _MainTex_ST.xy + _MainTex_ST.zw;
				float2 heightUV = i.uv * _HeightTex_ST.xy + _HeightTex_ST.zw;

				float height = tex2D(_HeightTex, heightUV).r;

				float2 shallowOffset = viewDirTS.xy * _ParallaxShallow;
				float2 deepOffset = viewDirTS.xy * _ParallaxDeep;

				float2 uv = mainUV + lerp(shallowOffset, deepOffset, height);
				return tex2D(_MainTex, uv);
			}
			ENDCG
		}
	}
}