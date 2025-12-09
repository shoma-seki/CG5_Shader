Shader "Unlit/nonTexture"
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
			
			v2f vert(appdata i)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(i.vertex);

				o.uv = i.uv;

				return o;
			}

			fixed4 frag(v2f i): SV_TARGET
			{
				float2 a = (i.uv.x + i.uv.y) / 2;
				fixed b = step(0.5, a);
				fixed4 color = fixed4(1,1,1,1);
				return color * b ;
			}
			ENDCG
		}
	}
}