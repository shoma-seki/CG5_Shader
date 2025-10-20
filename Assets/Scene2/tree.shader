Shader "Unlit/tree"
{
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
		_MainTex ("Texture", 2D) = "white" {}
	}

	SubShader
	{		
		Tags { "RenderType" = "Opaque" }

		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"
            #include "Lighting.cginc"
			#include "AutoLight.cginc"

            fixed4  _Color;

            struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 uv: TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
				float distance : TEXCOORD1;
                float3 worldPosition : TEXCOORD2;
				float3 normal : NORMAL;
                float2 uv : TEXCOORD3;  
				SHADOW_COORDS(2)
            };
			
            sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPosition = mul(unity_ObjectToWorld, v.vertex);
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

				o.normal = UnityObjectToWorldNormal(v.normal);

                o.uv = v.uv;

				//カメラとの距離
				o.distance = distance(worldPos.xyz, _WorldSpaceCameraPos.xyz);

				TRANSFER_SHADOW(o);
                
				return o;
			}

			fixed4 frag(v2f i) : SV_TARGET
			{
				//テクスチャ
				//tiling
				float2 tiling = _MainTex_ST.xy;

				//offset
				float2 offset = _MainTex_ST.zw;

				fixed4 col = tex2D(_MainTex, i.uv * tiling + offset);

				//アンビエント
				fixed4 ambient = _Color * -400 * _LightColor0;

				//ディフューズ
				float iDot = dot(normalize(i.normal),_WorldSpaceLightPos0);
				float intensity = saturate(iDot);
				fixed4 color = _Color;
                float toonColor = smoothstep(0.7, 0.8, intensity);
                if(toonColor >= 0.1)
                {
                    toonColor = 0;
                }
                // if(toonColor <= 0.2)
                // {
                //     toonColor = 0.2;
                // }
				fixed4 toon = color * toonColor * _LightColor0;

				//スペキュラ
				float3 eyeDir = normalize(_WorldSpaceCameraPos.xyz - i.worldPosition);
				float3 lightDir = normalize(_WorldSpaceLightPos0);
				i.normal = normalize(i.normal);
				float lDot = dot(i.normal, lightDir);
				lDot = step(0.9, lDot);
				float3 reflectDir = -lightDir + 2 * i.normal * lDot;
				float sDot = dot(reflectDir, eyeDir);
				sDot = step(0.9, sDot);
				fixed4 specular = pow(saturate(sDot), 20) * _LightColor0;

				if(sDot >= 0.9)
				{
					//return specular;
				}
				
				//リムライト
				float pDot = dot(i.normal, eyeDir);
				float sIntensity = saturate(pDot);
				sIntensity = 1.0 - sIntensity;
				if(sIntensity > 0.6)
				{
					sIntensity = 1;
				}
				if(sIntensity < 0.2)
				{
					sIntensity = 0;
				}
                fixed4 rim = pow(sIntensity, 100) * fixed4(0,0,0,1);
                
				if(sIntensity >= 0.99999)
				{
					//return rim;
				}


				//Phong
				fixed4 phong = ambient + col + toon;
				
				//shadow
				float shadow = SHADOW_ATTENUATION(i);
				phong.rgb *= shadow;

				float fog = smoothstep(1,0,i.distance);

				phong.r += fog;
				phong.g += fog;

				return phong;
			}
			ENDCG
		}

		Pass
		{
			Tags{ "LightMode" = "ShadowCaster" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
            {
                float4 vertex : POSITION;
				float3 normal : NORMAL;
                float2 texcoord: TEXCOORD0;
            };

			struct v2f
			{
				V2F_SHADOW_CASTER;
			};

			v2f vert (appdata v)
			{
				v2f o;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				return o;
			}

			fixed4 frag (v2f i) : SV_TARGET
			{
				SHADOW_CASTER_FRAGMENT(i)
			}
			ENDCG
		}
	}
}