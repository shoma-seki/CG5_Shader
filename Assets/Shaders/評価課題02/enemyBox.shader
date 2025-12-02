Shader "Unlit/enemyBox"
{
	Properties
	{
        _Color("Color", Color) = (1,0,0,1)
		_NormalMap ("Texture", 2D) = "white" {}
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
				float4 tangent : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
                float3 normal : NORMAL;
				float3 tangent : TANGENT;
				float3 binormal : TEXCOORD2;
                float2 uv : TEXCOORD0;  
            };
			
            sampler2D _NormalMap;
			float4 _NormalMap_ST;
			
            sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
				o.tangent = normalize(v.tangent.xyz);
				o.binormal = normalize(cross(o.normal, o.tangent) * v.tangent.w * unity_WorldTransformParams.w);
                o.uv = v.uv;
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				float4 nMap = tex2D(_NormalMap, i.uv) * 2 - 1;
				nMap = normalize(nMap);
				i.tangent = normalize(i.tangent);
				i.binormal = normalize(i.binormal);
				i.normal = normalize(i.normal);

				fixed4 col = tex2D(_MainTex, i.uv);

				float3 lNormal = 
				normalize(i.tangent * nMap.x + i.binormal * nMap.y + i.normal * nMap.z);
				float3 wNormal = UnityObjectToWorldNormal(lNormal);

				float intensity = saturate(dot(wNormal, _WorldSpaceLightPos0));

                //ambientdd
                fixed4 ambient = _Color * 0.3 * _LightColor0;
                //diffuse                
                fixed4 color = _Color;
                fixed4 diffuse = color * intensity * _LightColor0;
                //specular
                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                float3 lightDir = normalize(_WorldSpaceLightPos0);
                float3 reflectDir = -lightDir + 2 * wNormal * dot(wNormal, lightDir);
                fixed4 specular = pow(saturate(dot(reflectDir, eyeDir)), 20) * _LightColor0;

                //Phong
                fixed4 phong = ambient + diffuse + specular + col;

				return phong;
			}
			ENDCG
		}
	}
}