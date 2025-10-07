Shader "Unlit/05_RimLight"
{
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
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

            fixed4  _Color;

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPosition : TEXCOORD1;
				float3 normal : NORMAL;
            };

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);

				o.normal = UnityObjectToWorldNormal(v.normal);
                
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				//アンビエント
				//fixed4 ambient = _Color * 0.3 * _LightColor0;
				//ディフューズ
				float iDot = dot(normalize(i.normal),_WorldSpaceLightPos0);
				float intensity = saturate(iDot);
				fixed4 color = _Color;
                fixed4 diffuse = color * intensity * _LightColor0;
				//スペキュラ
                float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
                i.normal = normalize(i.normal);
				float pDot = dot(i.normal, eyeDir);
				float sIntensity = saturate(pDot);
				sIntensity = smoothstep(1.0, 0.0, sIntensity);
                fixed4 specular = pow(sIntensity, 5) * _LightColor0;
                
				//Phong
				fixed4 phong = diffuse + specular;

				return phong;
			}
			ENDCG
		}
	}
}