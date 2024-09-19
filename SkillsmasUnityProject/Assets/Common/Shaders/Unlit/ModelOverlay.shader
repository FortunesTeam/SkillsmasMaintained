Shader "TheMysticSword/ModelOverlay"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        [Toggle] _MultiplyColorByVertexColor ("Multiply Color by Vertex Color", Float) = 1.0
        [Toggle] _UseRGBInsteadOfAlpha ("Use RGB Instead of Alpha", Float) = 1.0
        _Boost ("Brightness Boost", Float) = 0.0
        _ScaleX ("Scale X", Float) = 1.0
        _ScaleY ("Scale Y", Float) = 1.0
        _ScrollX ("Scroll X", Range(-3,3)) = 0.0
        _ScrollY ("Scroll Y", Range(-3,3)) = 0.0
        _WaveX ("Wave X", Range(-1,1)) = 0.0
        _WavePowerX ("Wave Power X", Range(0,16)) = 0.0
        _WaveSpeedX ("Wave Speed X", Range(0,10)) = 0.0
        _WaveY ("Wave Y", Range(-1,1)) = 0.0
        _WavePowerY ("Wave Power Y", Range(0,16)) = 0.0
        _WaveSpeedY ("Wave Speed Y", Range(0,10)) = 0.0
        _Offset ("Offset", Range(0,0.04)) = 0.0
        _OffsetMult ("Offset Multiplier", Float) = 1.0
        _OffsetPulse ("Offset Pulse", Range(0,16)) = 0.0
        _Shake ("Shake", Float) = 0.0
        _ShakeWave ("Shake Wave", Vector) = (0,0,0,0)
        _ObjectScale ("Object Scale", Vector) = (1,1,1,0)
        _NoiseTex ("Noise", 2D) = "white" {}
        [Header(Forcefield Fading)] [Toggle] _ForcefieldFadingOn ("Enable Forcefield Fading?", Float) = 0
        _RimPower ("Rim Power", Range(0,6)) = 0.0
        [Toggle] _RimHide ("Hide Rim?", Float) = 0.0
        _IntersectionPower ("Intersection Power", Range(0,6)) = 0.0
        [Toggle] _RoundFadeMult ("Round Edge Fading?", Float) = 0.0
        [Header(Remap)]
        [Toggle] _RemapOn ("Enable Texture Remapping?", Float) = 0
        _RemapTex ("Remap Texture", 2D) = "white" {}
        [Header(Cloud)]
        [Toggle] _CloudOn ("Enable Cloud?", Float) = 0
        _Cloud1Tex ("Cloud Texture 1", 2D) = "white" {}
        _Cloud2Tex ("Cloud Texture 2", 2D) = "white" {}
        _CloudSpeedX ("Cloud Speed X", Float) = 1.0
        _CloudSpeedY ("Cloud Speed Y", Float) = 1.0
        _CloudScaleX ("Cloud Scale X", Float) = 1.0
        _CloudScaleY ("Cloud Scale Y", Float) = 1.0
        [Header(Displacement)]
        _Displacement ("Displacement", Float) = 0.0
        _DisplacementDistance ("Displacement Distance", Float) = 0.0
        _DisplacementSpeed ("Displacement Speed", Float) = 0.0
        [Toggle] _DisplacementByNoise ("Displacement by Noise?", Float) = 1.0
        _DisplacementTex ("Displacement Texture", 2D) = "white" {}
        [Header(Shader Settings)]
        [KeywordEnum(Zero, One, DstColor, SrcColor, OneMinusDstColor, SrcAlpha, OneMinusSrcColor, DstAlpha, OneMinusDstAlpha, SrcAlphaSaturate, OneMinusSrcAlpha)] _SrcBlend ("Source Blend", Float) = 1.0
        [KeywordEnum(Zero, One, DstColor, SrcColor, OneMinusDstColor, SrcAlpha, OneMinusSrcColor, DstAlpha, OneMinusDstAlpha, SrcAlphaSaturate, OneMinusSrcAlpha)] _DstBlend ("Destination Blend", Float) = 10.0
        [KeywordEnum(Off, Front, Back)] _Cull ("Cull", Float) = 2.0
        [KeywordEnum(Off, On)] _ZWrite ("ZWrite", Float) = 0.0
        [Toggle] _UseWorldPosForUV ("Use World Pos for UV?", Float) = 0
        [PerRendererData] _ExternalAlpha ("External Alpha", Range(0, 1)) = 1
		[PerRendererData] _Fade ("Fade", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "IgnoreProjector"="True" "Queue"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ZWrite [_ZWrite]
            Cull [_Cull]
            
            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct vertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                fixed4 color : COLOR;
            };

            struct fragmentInput
            {
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(5)
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
				float3 worldViewDir : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float eyeDepth : TEXCOORD4;
                float3 worldPos : TEXCOORD5;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _DisplacementTex;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float4 _DisplacementTex_ST;
            float4 _Color;
            float _MultiplyColorByVertexColor;
            float _UseRGBInsteadOfAlpha;
            float _ScrollX;
            float _ScrollY;
            float _RimPower;
            float _RimHide;
            float _IntersectionPower;
            float _RoundFadeMult;
            float _Offset;
            float _OffsetMult;
            float _Shake;
            float4 _ShakeWave;
            float _OffsetPulse;
            float _ScaleX;
            float _ScaleY;
            float _WaveX;
            float _WavePowerX;
            float _WaveSpeedX;
            float _WaveY;
            float _WavePowerY;
            float _WaveSpeedY;
            float _Boost;
            float _ForcefieldFadingOn;
            float4 _ObjectScale;
            float _RemapOn;
            sampler2D _RemapTex;
            float _CloudOn;
            sampler2D _Cloud1Tex;
            sampler2D _Cloud2Tex;
            float _CloudSpeedX;
            float _CloudSpeedY;
            float _CloudScaleX;
            float _CloudScaleY;
            float _ExternalAlpha;
            float _UseWorldPosForUV;
            float _Fade;
            half _Displacement;
            half _DisplacementDistance;
            half _DisplacementSpeed;
            float _DisplacementByNoise;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;
                float scale = length(float3(unity_ObjectToWorld[0].x, unity_ObjectToWorld[1].x, unity_ObjectToWorld[2].x));
                if (_Offset != 0 && _OffsetMult != 0)
                {
                    v.vertex.xyz += (normalize(v.normal) * (_Offset * _OffsetMult * 3.0 * (_OffsetPulse > 0.0 ? sin(_Time.y * _OffsetPulse) * 0.5 + 0.5 : 1.0))) / scale;
                }
                if (_Shake != 0)
                {
                    v.vertex.xyz += float3(sin(_Time.y * _ShakeWave.x), sin(_Time.y * _ShakeWave.y), sin(_Time.y * _ShakeWave.z)) * _Shake / scale;
                }
                if (_Displacement != 0)
                {
                    if (_DisplacementByNoise == 1.0)
                    {
                        v.vertex.xyz += v.normal * (tex2Dlod(_NoiseTex, float4(v.uv.x * _DisplacementDistance + _Time.x * _DisplacementSpeed, v.uv.y * _DisplacementDistance + _Time.x * _DisplacementSpeed, 0, 0)).rgb - 0.5) * _Displacement;
                    }
                    else
                    {
                        v.vertex.xyz += v.normal * (tex2Dlod(_DisplacementTex, float4(v.uv.x + _Time.x * _DisplacementSpeed, v.uv.y + _Time.x * _DisplacementSpeed, 0, 0)).rgb - 0.5) * _Displacement;
                    }
                }
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeDepth);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                float2 texUV = i.uv;
                if (_UseWorldPosForUV == 1)
                {
                    texUV = i.worldPos;
                }

                float4 saveX = texUV.x;
                float4 saveY = texUV.y; 
                // scroll the texture
                texUV.x += _ScrollX * _Time.y;
                texUV.y += _ScrollY * _Time.y;
                // scale the texture
                texUV.x *= _ScaleX;
                texUV.y *= _ScaleY;
                // apply wave effect
                texUV.x += _WaveX * sin(_Time.y * _WaveSpeedX + saveY * _WavePowerX);
                texUV.y += _WaveY * sin(_Time.y * _WaveSpeedY + saveX * _WavePowerY);
                
                fixed4 col = tex2D(_MainTex, texUV);
                col *= _Color;
                if (_MultiplyColorByVertexColor) col *= i.color;
                if (_UseRGBInsteadOfAlpha == 1.0)
                {
                    col.a = 0;
                    col.rgb *= i.color.a;
                }

                if (_RemapOn == 1) {
                    float brightness = min(max(max(max(col.r, col.g), col.b), 0.01), 0.99);
                    col.rgb = tex2D(_RemapTex, float2(brightness, 0)).rgb;
                }

                if (_CloudOn == 1) {
                    float cloudMultiplier = tex2D(_Cloud1Tex, float2(texUV.x * _CloudScaleX + _CloudSpeedX * _Time.y, texUV.y * _CloudScaleY + _CloudSpeedY * _Time.y)).a;
                    cloudMultiplier *= tex2D(_Cloud2Tex, float2(texUV.x * _CloudScaleX - _CloudSpeedX * _Time.y, texUV.y * _CloudScaleY - _CloudSpeedY * _Time.y)).a;
                    if (_UseRGBInsteadOfAlpha) col.rgb *= cloudMultiplier;
                    else col.a *= cloudMultiplier;
                }

                if (_ForcefieldFadingOn == 1) {
                    if (_RimPower > 0 || _IntersectionPower > 0) {
                        float rim = 1 - saturate(dot(normalize(i.worldNormal), normalize(i.worldViewDir))) * _RimPower;
                        if (_RimHide == 1.0) rim = 0.0;
                        float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
                        float intersect = (1 - (screenZ - i.eyeDepth)) * _IntersectionPower;
                        float fadeMult = max(rim, intersect);
                        if (_RoundFadeMult == 1) fadeMult = round(fadeMult);
                        if (_UseRGBInsteadOfAlpha == 1.0) col.rgb = clamp(col.rgb * fadeMult, 0, 1);
                        else col.a = clamp(col.a * fadeMult, 0, 1);
                    }
                }

                col.rgb *= (1.0 + _Boost);
                if (_UseRGBInsteadOfAlpha == 1.0) col.rgb *= _ExternalAlpha * _Fade;
                else col.a *= _ExternalAlpha * _Fade;

                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }

            ENDCG
        }
    }
}
