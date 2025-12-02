Shader "Unlit/box"
{
	Properties
	{
        _Color("Color", Color) = (1,0,0,1)
		_MainTex ("Texture1", 2D) = "white" {}
		_SubTex ("Texture2", 2D) = "white" {}
		_Dissolve("Dissolve", Range(0, 1)) = 0
	}
	SubShader
	{
		CGINCLUDE
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;
			float _Dissolve;

			struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;  
            };
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
				return o;
			}
		ENDCG

		Pass
		{
			Cull Front

			Tags
			{
				"Queue" = "Transparent"
			}

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			
            sampler2D _MainTex;
			float4 _MainTex_ST;

			fixed4 frag(v2f i) : SV_TARGET
			{
				//tiling
				float2 tiling = _MainTex_ST.xy;

				//offset
				float2 offset = _MainTex_ST.zw;

				fixed4 col = tex2D(_MainTex, i.uv * tiling + offset);
				
				float buffer = col.b;
				col.b = col.r;
				col.r = buffer;
				col.r += 0.1;

				clip(col.b - _Dissolve);
				                
				return col;
			}
			ENDCG
		}

		Pass
		{
			Tags
			{
				"Queue" = "Transparent"
			}

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			
            sampler2D _SubTex;
			float4 _SubTex_ST;
			
			fixed4 frag(v2f i) : SV_TARGET
			{
				//tiling
				float2 tiling = _SubTex_ST.xy;

				//offset
				float2 offset = _SubTex_ST.zw;

				fixed4 col = tex2D(_SubTex, i.uv * tiling + offset);

				clip(col.r - _Dissolve);
				                
				return col;
			}
			ENDCG
		}
	}
}