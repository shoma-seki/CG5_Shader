Shader "Unlit/06_Transparent_texture"
{
	Properties
	{
        _Color("Color", Color) = (1,0,0,1)
		_MainTex ("Texture", 2D) = "white" {}
	}
	SubShader
	{
		Pass
		{
			Tags
			{
				"Queue" = "Transparent"
			}

			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "Lighting.cginc"

            fixed4 _Color;

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
			
            sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				//tiling
				float2 tiling = _MainTex_ST.xy;

				//offset
				float2 offset = _MainTex_ST.zw;

				fixed4 col = tex2D(_MainTex, i.uv * tiling + offset);
				                
				return col;
			}
			ENDCG
		}
	}
}