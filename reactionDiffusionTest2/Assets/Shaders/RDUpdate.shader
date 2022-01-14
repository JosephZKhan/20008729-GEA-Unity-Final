Shader "Custom/RDUpdate"
{
    Properties
    {
        _Du("Diffusion (Chemical A)", Range(0, 1)) = 1
        _Dv("Diffusion (Chemical B)", Range(0, 1)) = 0.4
        _Feed("Feed", Range(0, 0.1)) = 0.05
        _Kill("Kill", Range(0, 0.1)) = 0.05

        //recommended values:
        //worms and rings: du = 1, dv = 0.33, feed = 0.0655, kill = 0.0671
        //pea pods: du = 0.413, dv = 0.092, feed = 0.037, kill = 0.06
        //crinkles: du = 1, dv = 0.33, feed = 0.037, kill = 0.06
        //angular: du = 1, dv = 0.092, feed = 0.0613, kill = 0.0538
        //cells: du = 0.875, dv = 0.138, feed = 0.0613, kill 0.0538
    }

    CGINCLUDE

    #include "UnityCustomRenderTexture.cginc"
    half _Du, _Dv;
    half _Feed, _Kill;
 
    half4 frag(v2f_customrendertexture i) : SV_Target
    {
        float texWidth = 1 / _CustomRenderTextureWidth;
        float texHeight = 1 / _CustomRenderTextureHeight;

        float2 uv = i.globalTexcoord;
        float4 duv = float4(texWidth, texHeight, -texWidth, 0);

        half2 q = tex2D(_SelfTexture2D, uv).xy;
        half2 dq = -q;
        
        dq += tex2D(_SelfTexture2D, uv - duv.xy).xy * 0.05;
        dq += tex2D(_SelfTexture2D, uv - duv.wy).xy * 0.20;
        dq += tex2D(_SelfTexture2D, uv - duv.zy).xy * 0.05;
        dq += tex2D(_SelfTexture2D, uv + duv.zw).xy * 0.20;
        dq += tex2D(_SelfTexture2D, uv + duv.xw).xy * 0.20;
        dq += tex2D(_SelfTexture2D, uv + duv.zy).xy * 0.05;
        dq += tex2D(_SelfTexture2D, uv + duv.wy).xy * 0.20;
        dq += tex2D(_SelfTexture2D, uv + duv.xy).xy * 0.05;

        half ABB = q.x * q.y * q.y;

        q += float2(dq.x * _Du - ABB + _Feed * (1 - q.x),
                    dq.y * _Dv + ABB - (_Kill + _Feed) * q.y);


        return half4(saturate(q), 0, 0);
    }

    ENDCG
        /*

    half4 frag(v2f_customrendertexture i) : SV_Target
    {
        return 0;
    }

    EDNCG
        */

    SubShader
    {
        Cull Off ZWrite Off ZTest Always
        Pass
        {
            Name "Update"
            CGPROGRAM
            #pragma vertex CustomRenderTextureVertexShader
            #pragma fragment frag
            ENDCG
        }
    }
}
