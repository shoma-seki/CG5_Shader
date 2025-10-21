Shader "Unlit/11_specularMap"
{
	Properties
	{
        _Color("Color", Color) = (1,0,0,1)
		_MaskTex ("maskTex", 2D) = "white" {}
	}
	SubShader
	{
		//Cull Off

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
			
            sampler2D _MaskTex;
			float4 _MaskTex_ST;
			
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
				fixed4 col = _Color;

				fixed4 mask = tex2D(_MaskTex, i.uv * _MaskTex_ST.xy);

				//ƒXƒyƒLƒ…ƒ‰
                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                i.normal = normalize(i.normal);
                float3 reflectDir = -lightDir + 2 * i.normal * dot(i.normal, lightDir);
                fixed4 specular = pow(saturate(dot(reflectDir, eyeDir)), 2) * _LightColor0;

				col = lerp(col, col + specular, mask.r);

				return col + mask.r * specular;
			}
			ENDCG
		}
	}
}