float hash(float2 p)
{
    return frac(sin(dot(p, float2(127.1, 311.7))) * 43758.5453123);
}

float2 grad(float2 p)
{
    float h = hash(p) * 6.2831853;
    return float2(cos(h), sin(h));
}

float gradNoise(float2 p)
{
    float2 i = floor(p);
    float2 f = frac(p);

    float2 u = f * f * (3.0 - 2.0 * f);

    float2 g00 = grad(i + float2(0, 0));
    float2 g10 = grad(i + float2(1, 0));
    float2 g01 = grad(i + float2(0, 1));
    float2 g11 = grad(i + float2(1, 1));

    float n00 = dot(g00, f - float2(0, 0));
    float n10 = dot(g10, f - float2(1, 0));
    float n01 = dot(g01, f - float2(0, 1));
    float n11 = dot(g11, f - float2(1, 1));

    float nx0 = lerp(n00, n10, u.x);
    float nx1 = lerp(n01, n11, u.x);

    return lerp(nx0, nx1, u.y);
}

float hybridMultifractal(float2 p,int octaves,float lacunarity,float gain,float offset)
{
    float frequency = 1.0;
    float amplitude = 1.0;
    
    float result = gradNoise(p) + offset;
    float weight = result;

    for (int i = 1; i < octaves; i++)
    {
        frequency *= lacunarity;
        amplitude *= gain;

        float signal = gradNoise(p * frequency) + offset;
        signal *= amplitude;
        
        signal *= weight;

        result += signal;
        weight = saturate(signal);
    }

    return result;
}
