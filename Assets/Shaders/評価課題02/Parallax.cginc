#include "Noise.cginc"

float2 ParallaxOcclusionMapping(float2 uv, float3 viewDirTS, float time, float HeightScale, float HeightPlus)
{
    float density = (sin(time) * 5);

    float3 v = normalize(viewDirTS);

    float ndotv = abs(v.z);
    float numLayers = lerp(64, 256, ndotv);
    float layerDepth = 1.0 / numLayers;

    float2 P = v.xy / max(v.z, 0.0001) * HeightScale;
    float2 deltaTexCoord = P / numLayers;

    float2 curTexCoord = uv;
    float curLayerDepth = 0.0;
    float curHeight = FractalSumNoise(density, curTexCoord);

				[loop]
    for (int i = 0; i < (int) 256; i++)
    {
        if (curLayerDepth > curHeight)
        {
            break;
        }
        curTexCoord -= deltaTexCoord;
        curLayerDepth += layerDepth;
        curHeight = FractalSumNoise(density, curTexCoord);
    }

    float2 preTexCoord = curTexCoord + deltaTexCoord;
    float preLayerDepth = curLayerDepth - layerDepth;
    float preHeight = FractalSumNoise(density, curTexCoord);
    
    float heightDiff = preHeight - preLayerDepth;
    float curDiff = curHeight - curLayerDepth;
    float weight = heightDiff / (heightDiff - curDiff + 1e-5);

    float2 finalTexCoord =
					lerp(curTexCoord, preTexCoord, saturate(weight));
    return finalTexCoord - deltaTexCoord * HeightPlus;
}