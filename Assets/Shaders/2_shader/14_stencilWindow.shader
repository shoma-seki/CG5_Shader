Shader "Unlit/14_stencilWindow"
{
	Properties
	{
		_Color("Color",Color) = (0,0,0,0)
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" }
		blend zero one

		Pass
		{
			Stencil
			{
				Ref 2
				Comp always
				Pass replace
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			fixed4 _Color;
			
			float4 vert(float4 v:POSITION):SV_POSITION
			{
				float4 o;
				o = UnityObjectToClipPos(v);
				return o;
			}

			fixed4 frag(float4 i:SV_POSITION): SV_TARGET
			{
				fixed4 o = {0,0,0,0};
				return o;
			}
			ENDCG
		}
	}
}