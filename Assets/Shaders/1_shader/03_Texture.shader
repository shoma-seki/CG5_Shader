Shader "Unlit/01_Simple"
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

                //ambient
                fixed4 ambient = _Color * 0.3 * _LightColor0;
                //diffuse
                float intensity=
                    saturate(dot(normalize(i.normal),_WorldSpaceLightPos0));
                fixed4 color = _Color;
                fixed4 diffuse = color * intensity * _LightColor0;
                //specular
                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                i.normal = normalize(i.normal);
                float3 reflectDir = -lightDir + 2 * i.normal * dot(i.normal, lightDir);
                fixed4 specular = pow(saturate(dot(reflectDir, eyeDir)), 20) * _LightColor0;

                //Phong
                fixed4 phong = ambient + diffuse + specular + col;

				return phong;
			}
			ENDCG
		}
	}
}