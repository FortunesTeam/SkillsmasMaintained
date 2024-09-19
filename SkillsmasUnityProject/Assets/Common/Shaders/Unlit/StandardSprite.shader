Shader "TheMysticSword/StandardSprite"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _Boost ("Boost", Float) = 0.0
        [Toggle] _MultiplyColorByVertexColor ("Multiply Color by Vertex Color", Float) = 0.0
        _MainTex ("Texture", 2D) = "white" {}
        _RenderPortion ("Render Portion", Vector) = (0,1,0,1)
        _NoiseTex ("Noise", 2D) = "white" {}
        [Header(Blink)]
        [Toggle] _BlinkOn ("Blink On?", Float) = 0.0
        _BlinkIntensity ("Blink Intensity", Range(0,1)) = 0.5
        _BlinkSpeed ("Blink Speed", Range(0,20)) = 10.0
        [Header(Cloud)]
        [Toggle] _CloudOn ("Enable Cloud?", Float) = 0
        _Cloud1Tex ("Cloud Texture", 2D) = "white" {}
        _CloudSpeedX ("Cloud Speed X", Float) = 1.0
        _CloudSpeedY ("Cloud Speed Y", Float) = 1.0
        _CloudScaleX ("Cloud Scale X", Float) = 1.0
        _CloudScaleY ("Cloud Scale Y", Float) = 1.0
        [Header(Edge Fade)]
        _EdgeFadeLeft ("Left", Range(0,1)) = 0.0
        _EdgeFadeRight ("Right", Range(0,1)) = 0.0
        _EdgeFadeTop ("Top", Range(0,1)) = 0.0
        _EdgeFadeBottom ("Bottom", Range(0,1)) = 0.0
        [Header(Shader Settings)]
        [KeywordEnum(Zero, One, DstColor, SrcColor, OneMinusDstColor, SrcAlpha, OneMinusSrcColor, DstAlpha, OneMinusDstAlpha, SrcAlphaSaturate, OneMinusSrcAlpha)] _SrcBlend ("Source Blend", Float) = 1.0
        [KeywordEnum(Zero, One, DstColor, SrcColor, OneMinusDstColor, SrcAlpha, OneMinusSrcColor, DstAlpha, OneMinusDstAlpha, SrcAlphaSaturate, OneMinusSrcAlpha)] _DstBlend ("Destination Blend", Float) = 10.0
        [KeywordEnum(Off, Front, Back)] _Cull ("Cull", Float) = 2.0
        [KeywordEnum(Less, LEqual, Equal, GEqual, Greater, NotEqual, Always)] _ZTest ("ZTest", Float) = 6.0
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        Blend [_SrcBlend] [_DstBlend]
        Cull [_Cull]
        Lighting Off
        ZWrite Off
        ZTest [_ZTest]

        Pass
        {
            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc

            #pragma ADDITIVE

            #include "UnityCG.cginc"

            struct vertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct fragmentInput
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            float4 _Color;
            float _Boost;
            float _MultiplyColorByVertexColor;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            float4 _RenderPortion;
            float _BlinkOn;
            float _BlinkIntensity;
            float _BlinkSpeed;
            float _CloudOn;
            sampler2D _Cloud1Tex;
            float _CloudSpeedX;
            float _CloudSpeedY;
            float _CloudScaleX;
            float _CloudScaleY;
            float _EdgeFadeLeft;
            float _EdgeFadeRight;
            float _EdgeFadeTop;
            float _EdgeFadeBottom;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;

                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);

                if (!(i.uv.x >= _RenderPortion.x && i.uv.x <= _RenderPortion.y && i.uv.y >= _RenderPortion.z && i.uv.y <= _RenderPortion.w)) col = 0.0;

                if (_BlinkOn == 1.0) {
                    float blink = (1.0 - _BlinkIntensity) + _BlinkIntensity * tex2D(_NoiseTex, _Time.x * _BlinkSpeed);
                    _Color.r *= blink;
                    _Color.g *= blink;
                    _Color.b *= blink;
                }

                if (_CloudOn == 1) {
                    col *= tex2D(_Cloud1Tex, float2(i.uv.x * _CloudScaleX + _CloudSpeedX * _Time.y, i.uv.y * _CloudScaleY + _CloudSpeedY * _Time.y));
                }

                if (_EdgeFadeLeft != 0.0) _Color.a *= clamp(i.uv.x / _EdgeFadeLeft, 0.0, 1.0);
                if (_EdgeFadeRight != 0.0) _Color.a *= clamp((1.0 - i.uv.x) / _EdgeFadeRight, 0.0, 1.0);
                if (_EdgeFadeTop != 0.0) _Color.a *= clamp((1.0 - i.uv.y) / _EdgeFadeTop, 0.0, 1.0);
                if (_EdgeFadeBottom != 0.0) _Color.a *= clamp(i.uv.y / _EdgeFadeBottom, 0.0, 1.0);

                _Color.rgb *= 1.0 + _Boost;

                col *= _Color;

                if (_MultiplyColorByVertexColor) col *= i.color;
                
                return col;
            }

            ENDCG
        }
    }
}
