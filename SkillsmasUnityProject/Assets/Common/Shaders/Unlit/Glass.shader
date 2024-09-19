Shader "TheMysticSword/Glass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        _RimPower ("Rim Power", Range(0,6)) = 0.0
        _Distortion ("Distortion", Range(0,1)) = 1.0
        _DistortionNoiseTex ("Distortion Noise", 2D) = "white" {}
        _DistortionSpeed ("Distortion Over Time", Range(0,1)) = 0.0
        _Zoom ("Zoom", Range(0,1)) = 0.2
        _InnerSize ("Inner Size", Range(0,1)) = 1.0
        [Toggle] _OverrideBackgroundTexActive ("Override Background?", Float) = 0.0
        _OverrideBackgroundTex ("Override Background Texture", 2D) = "black" {}
        _ObjectScale ("Object Scale", Vector) = (1,1,1,0)
        [KeywordEnum(Off, Front, Back)] _Cull ("Cull", Float) = 2.0
    }
    SubShader
    {
        Tags { "Queue"="Transparent+1" "RenderType"="Transparent" }

        GrabPass { }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
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
            };

            struct fragmentInput
            {
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(1)
                float4 grabPos : TEXCOORD0;
            };

            sampler2D _DistortionNoiseTex;
            float4 _DistortionNoiseTex_ST;
            sampler2D _GrabTexture;
            float4 _GrabTexture_ST;
            float _OverrideBackgroundTexActive;
            sampler2D _OverrideBackgroundTex;
            float _InnerSize;
            float4 _ObjectScale;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;

                v.vertex.xyz += (normalize(v.normal) * (_InnerSize - 1.0)) / _ObjectScale;

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                o.grabPos = ComputeGrabScreenPos(o.vertex);

                UNITY_TRANSFER_FOG(o, o.vertex);

                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                fixed4 col = tex2Dproj(_GrabTexture, i.grabPos);
                if (_OverrideBackgroundTexActive == 1.0) {
                    col = tex2Dproj(_OverrideBackgroundTex, i.grabPos);
                }
                col.a = 1;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            ENDCG
        }

        GrabPass { }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
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
            };

            struct fragmentInput
            {
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(1)
                float4 grabPos : TEXCOORD0;
            };

            float4 _Color;
            float _Distortion;
            sampler2D _DistortionNoiseTex;
            float4 _DistortionNoiseTex_ST;
            sampler2D _GrabTexture;
            float4 _GrabTexture_ST;
            float _DistortionSpeed;
            float _Zoom;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                
                float4 uv_center = ComputeGrabScreenPos(UnityObjectToClipPos(float4(0, 0, 0, 1)));
                float4 uv_diff = ComputeGrabScreenPos(o.vertex) - uv_center;
                uv_diff *= (-_Zoom);

                o.grabPos = ComputeGrabScreenPos(o.vertex);
                o.grabPos.x += (tex2Dlod(_DistortionNoiseTex, float4(v.uv.x * (_DistortionSpeed != 0 ? sin(_Time.x * _DistortionSpeed) : 1), 0, 0, 0)).rgb - 0.5) * _Distortion;
                o.grabPos.y += (tex2Dlod(_DistortionNoiseTex, float4(0, v.uv.y * (_DistortionSpeed != 0 ? sin(_Time.x * _DistortionSpeed) : 1), 0, 0)).rgb - 0.5) * _Distortion;
                o.grabPos += uv_diff;

                UNITY_TRANSFER_FOG(o, o.vertex);

                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                fixed4 col = tex2Dproj(_GrabTexture, i.grabPos);
                col.a = 1;
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            ENDCG
        }

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
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
            };

            struct fragmentInput
            {
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(3)
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
				float3 worldViewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            float _RimPower;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(worldPos);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv) * _Color;
                float rim = 1 - saturate(dot(normalize(i.worldNormal), normalize(i.worldViewDir))) * _RimPower;
                col.a = clamp(col.a * rim, 0.0, 1.0);
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }

            ENDCG
        }
    }
}
