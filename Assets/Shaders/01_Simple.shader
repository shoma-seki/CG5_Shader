Shader "Unlit/01_Simple"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			float4 vert(float4 v:POSITION):SV_POSITION
			{
				float4 o;
				o = UnityObjectToClipPos(v);
				return o;
			}

			fixed4 frag(float4 i:SV_POSITION): SV_TARGET
			{
				fixed4 o = fixed4 (1,0,0,1);
				return o;
			}
			ENDCG
		}
	}
}