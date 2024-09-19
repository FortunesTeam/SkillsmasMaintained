Shader "TheMysticSword/Forcefield"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TintColor ("Color", Color) = (1,1,1,1)
        _ScaleX ("Scale X", Float) = 1.0
        _ScaleY ("Scale Y", Float) = 1.0
        _ScrollX ("Scroll X", Float) = 0.0
        _ScrollY ("Scroll Y", Float) = 0.0
        _WaveX ("Wave X", Range(-1,1)) = 0.0
        _WavePowerX ("Wave Power X", Range(0,16)) = 0.0
        _WaveSpeedX ("Wave Speed X", Range(0,10)) = 0.0
        _WaveY ("Wave Y", Range(-1,1)) = 0.0
        _WavePowerY ("Wave Power Y", Range(0,16)) = 0.0
        _WaveSpeedY ("Wave Speed Y", Range(0,10)) = 0.0
        _ObjectScale ("Object Scale", Vector) = (1,1,1,0)
        _RimPower ("Rim Power", Range(0,6)) = 0.0
        [Toggle] _RimHide ("Hide Rim?", Float) = 0.0
        _IntersectionPower ("Intersection Power", Range(0,6)) = 0.0
        [Toggle] _RoundFadeMult ("Round Edge Fading?", Float) = 0.0
    }
    SubShader
    {
        Tags { "IgnoreProjector"="True" "Queue"="Transparent" "RenderType"="Transparent" }
        // rim
        Pass
        {
            Cull Back
            ZWrite Off
            Blend One One
            
            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc

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
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
				float3 worldViewDir : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float eyeDepth : TEXCOORD4;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float4 _TintColor;
            float _ScrollX;
            float _ScrollY;
            float _RimPower;
            float _RimHide;
            float _IntersectionPower;
            float _RoundFadeMult;
            float _ScaleX;
            float _ScaleY;
            float _WaveX;
            float _WavePowerX;
            float _WaveSpeedX;
            float _WaveY;
            float _WavePowerY;
            float _WaveSpeedY;
            float _Offset;
            float4 _ObjectScale;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;
                v.vertex.xyz += (normalize(v.normal) * _Offset) / _ObjectScale;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeDepth);
                o.color = v.color;
                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                float4 saveX = i.uv.x;
                float4 saveY = i.uv.y; 
                // scroll the texture
                i.uv.x += _ScrollX * _Time.y;
                i.uv.y += _ScrollY * _Time.y;
                // scale the texture
                i.uv.x *= _ScaleX;
                i.uv.y *= _ScaleY;
                // apply wave effect
                i.uv.x += _WaveX * sin(_Time.y * _WaveSpeedX + saveY * _WavePowerX);
                i.uv.y += _WaveY * sin(_Time.y * _WaveSpeedY + saveX * _WavePowerY);
                
                fixed4 col = tex2D(_MainTex, i.uv) * _TintColor * fixed4(i.color.rgb * i.color.a, 0.0);

                float rim = 1 - saturate(dot(normalize(i.worldNormal), normalize(i.worldViewDir))) * _RimPower;
                if (_RimHide == 1.0) rim = 0.0;
                float fadeMult = rim;
                if (_RoundFadeMult == 1) fadeMult = round(fadeMult);
                col.rgb = clamp(col.rgb * fadeMult, 0, 1);

                return col;
            }

            ENDCG
        }
        // rim (backface)
        Pass
        {
            Cull Front
            Blend One One
            
            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc

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
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
				float3 worldViewDir : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float eyeDepth : TEXCOORD4;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float4 _TintColor;
            float _ScrollX;
            float _ScrollY;
            float _RimPower;
            float _RimHide;
            float _IntersectionPower;
            float _RoundFadeMult;
            float _ScaleX;
            float _ScaleY;
            float _WaveX;
            float _WavePowerX;
            float _WaveSpeedX;
            float _WaveY;
            float _WavePowerY;
            float _WaveSpeedY;
            float _Offset;
            float4 _ObjectScale;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;
                v.vertex.xyz += (normalize(v.normal) * _Offset) / _ObjectScale;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = -UnityObjectToWorldDir(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeDepth);
                o.color = v.color;
                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                float4 saveX = i.uv.x;
                float4 saveY = i.uv.y; 
                // scroll the texture
                i.uv.x += _ScrollX * _Time.y;
                i.uv.y += _ScrollY * _Time.y;
                // scale the texture
                i.uv.x *= _ScaleX;
                i.uv.y *= _ScaleY;
                // apply wave effect
                i.uv.x += _WaveX * sin(_Time.y * _WaveSpeedX + saveY * _WavePowerX);
                i.uv.y += _WaveY * sin(_Time.y * _WaveSpeedY + saveX * _WavePowerY);
                
                fixed4 col = tex2D(_MainTex, i.uv) * _TintColor * fixed4(i.color.rgb * i.color.a, 0.0);

                float rim = 1 - saturate(dot(normalize(i.worldNormal), normalize(i.worldViewDir))) * (_RimPower * 0.75);
                if (_RimHide == 1.0) rim = 0.0;
                float fadeMult = rim;
                if (_RoundFadeMult == 1) fadeMult = round(fadeMult);
                col.rgb = clamp(col.rgb * fadeMult, 0, 1);

                return col;
            }

            ENDCG
        }
        // intersection
        Pass
        {
            Cull Off
            ZWrite Off
            Blend One One
            
            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc

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
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
				float3 worldViewDir : TEXCOORD2;
				float4 screenPos : TEXCOORD3;
				float eyeDepth : TEXCOORD4;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float4 _TintColor;
            float _ScrollX;
            float _ScrollY;
            float _RimPower;
            float _RimHide;
            float _IntersectionPower;
            float _RoundFadeMult;
            float _ScaleX;
            float _ScaleY;
            float _WaveX;
            float _WavePowerX;
            float _WaveSpeedX;
            float _WaveY;
            float _WavePowerY;
            float _WaveSpeedY;
            float _Offset;
            float4 _ObjectScale;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;
                v.vertex.xyz += (normalize(v.normal) * _Offset) / _ObjectScale;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeDepth);
                o.color = v.color;
                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                float4 saveX = i.uv.x;
                float4 saveY = i.uv.y;
                // scroll the texture
                i.uv.x += _ScrollX * _Time.y;
                i.uv.y += _ScrollY * _Time.y;
                // scale the texture
                i.uv.x *= _ScaleX;
                i.uv.y *= _ScaleY;
                // apply wave effect
                i.uv.x += _WaveX * sin(_Time.y * _WaveSpeedX + saveY * _WavePowerX);
                i.uv.y += _WaveY * sin(_Time.y * _WaveSpeedY + saveX * _WavePowerY);
                
                fixed4 col = tex2D(_MainTex, i.uv) * _TintColor * fixed4(i.color.rgb * i.color.a, 0.0);

                float screenZ = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
                float intersect = (1.0 - (screenZ - i.eyeDepth)) * _IntersectionPower;
                float fadeMult = intersect;
                if (_RoundFadeMult == 1) fadeMult = round(fadeMult);
                col.rgb = clamp(col.rgb * fadeMult, 0, 1);

                return col;
            }

            ENDCG
        }
    }
}
