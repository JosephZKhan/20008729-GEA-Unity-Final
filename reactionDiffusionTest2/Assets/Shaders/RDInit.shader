Shader "Custom/RDInit"
{
    Properties
    {
        _Seed("Seed", Range(0, 1)) = 0
        //value that is compared against randVal to determine if a cell is seeded

        _RandU("Random U", Range(0, 100)) = 79.9898
        _RandV("Random V", Range(0, 1000)) = 420.233
        //float values used in randUVs
    }

    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"

    half _Seed;

    half _RandU;
    half _RandV;

    //generate a random float value for the entered float2 value UV
    float randUVs(float2 uv)
    {
        return frac(tan(dot(uv, float2(_RandU, _RandV))) * 43758.5453);
        //return random value between 0 and 1
    }

    half4 frag(v2f_init_customrendertexture i) : SV_Target
    {
        float randVal = randUVs(i.texcoord) + randUVs(i.texcoord + 1);
        return half4(1, step(randVal, _Seed * 0.0001), 0, 0);
        //step returns 1 if randVal > _Seed * 0.0001, and 0 otherwise
    }

    ENDCG

    SubShader
    {
        Cull Off ZWrite Off ZTest Always    //optimization
        Pass
        {
            Name "Init"
            CGPROGRAM
            #pragma vertex InitCustomRenderTextureVertexShader
            #pragma fragment frag
            ENDCG
        }
    }
}
