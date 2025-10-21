Shader "Unlit/13_stenciBack"
{
	Properties
	{
		_Color("Color",Color) = (1,0,0,1)
	}
	SubShader
	{
		Pass
		{
			Stencil
			{
				Ref 1
				Comp NotEqual
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
				fixed4 o = _Color;
				return o;
			}
			ENDCG
		}

		Pass
		{
			Tags { "Queue" = "Geometry+1" }

			Stencil
			{
				Ref 1
				Comp Equal
			}
			ztest always

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
				fixed4 o = {0,1,0,1};
				return o;
			}
			ENDCG
		}
	}
}