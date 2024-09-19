Shader "TheMysticSword/Wireframe"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color ("Color", Color) = (1,1,1,1)
        [Toggle] _MultiplyColorByVertexColor ("Multiply Color by Vertex Color", Float) = 1.0
        [Toggle] _OnlyFadeAlpha ("Only Fade Alpha", Float) = 1.0
        [Toggle] _ConstantWidth ("Constant Width", Float) = 1.0
        _Boost ("Brightness Boost", Float) = 0.0
        _Width ("Width", Float) = 1.0
        [Header(Shader Settings)]
        [KeywordEnum(Zero, One, DstColor, SrcColor, OneMinusDstColor, SrcAlpha, OneMinusSrcColor, DstAlpha, OneMinusDstAlpha, SrcAlphaSaturate, OneMinusSrcAlpha)] _SrcBlend ("Source Blend", Float) = 1.0
        [KeywordEnum(Zero, One, DstColor, SrcColor, OneMinusDstColor, SrcAlpha, OneMinusSrcColor, DstAlpha, OneMinusDstAlpha, SrcAlphaSaturate, OneMinusSrcAlpha)] _DstBlend ("Destination Blend", Float) = 10.0
        [KeywordEnum(Off, Front, Back)] _Cull ("Cull", Float) = 2.0
    }
    SubShader
    {
        Tags { "IgnoreProjector"="True" "Queue"="Transparent" "RenderType"="Transparent" }
        Pass
        {
            Blend [_SrcBlend] [_DstBlend]
            ZWrite Off
            Cull [_Cull]
            
            CGPROGRAM

            #pragma vertex vertexFunc
            #pragma fragment fragmentFunc
            #pragma geometry geometryFunc
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct vertexInput
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                fixed4 color : COLOR;
            };

            struct geometryInput
            {
                float4 vertex : SV_POSITION;
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
                float3 barycentric : TEXCOORD6;
            };

            sampler2D _MainTex;
            sampler2D _NoiseTex;
            sampler2D _CameraDepthTexture;
            float4 _MainTex_ST;
            float4 _Color;
            float _MultiplyColorByVertexColor;
            float _OnlyFadeAlpha;
            float _ConstantWidth;
            float _Boost;
            float _Width;

            fragmentInput vertexFunc (vertexInput v)
            {
                fragmentInput o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.worldNormal = UnityObjectToWorldDir(v.normal);
				o.worldViewDir = UnityWorldSpaceViewDir(o.worldPos);
				o.screenPos = ComputeScreenPos(o.vertex);
				COMPUTE_EYEDEPTH(o.eyeDepth);
                o.color = v.color;
                UNITY_TRANSFER_FOG(o, o.vertex);
                o.barycentric = 0;
                return o;
            }

            fixed4 fragmentFunc (fragmentInput i) : SV_Target
            {
                float2 texUV = i.uv;
                fixed4 col = tex2D(_MainTex, texUV);
                col *= _Color;
                if (_MultiplyColorByVertexColor) col *= fixed4(i.color.rgb, 0.0);
                col.rgb *= i.color.a;

                col.rgb *= (1.0 + _Boost);

                float3 unitWidth = fwidth(i.barycentric);
                float finalWidth = unitWidth * _Width;
                if (_ConstantWidth == 0.0) finalWidth *= LinearEyeDepth(i.eyeDepth) * 100.0;
                float3 edge = smoothstep(float3(0.0, 0.0, 0.0), finalWidth, i.barycentric);
                float wireframeAlpha = 1.0 - min(edge.x, min(edge.y, edge.z));
                col.a *= wireframeAlpha;
                if (_OnlyFadeAlpha == 0) col.rgb *= wireframeAlpha;

                UNITY_APPLY_FOG(i.fogCoord, col);

                return col;
            }

            [maxvertexcount(3)]
            void geometryFunc (triangle fragmentInput i[3], inout TriangleStream<fragmentInput> triangleStream)
            {
                fragmentInput o;

                float edgeLengthX = length(i[1].vertex - i[2].vertex);
                float edgeLengthY = length(i[0].vertex - i[2].vertex);
                float edgeLengthZ = length(i[0].vertex - i[1].vertex);

                float3 modifier = 0;
                if (edgeLengthX > edgeLengthY && edgeLengthX > edgeLengthZ) modifier.x = 1.0;
                else if (edgeLengthY > edgeLengthX && edgeLengthY > edgeLengthZ) modifier.y = 1.0;
                else if (edgeLengthZ > edgeLengthX && edgeLengthZ > edgeLengthY) modifier.z = 1.0;

                for (int j = 0; j < 3; j++)
                {
                    o.uv = i[j].uv;
                    o.worldPos = i[j].worldPos;
                    o.worldNormal = i[j].worldNormal;
                    o.worldViewDir = i[j].worldViewDir;
                    o.screenPos = i[j].screenPos;
                    o.eyeDepth = i[j].eyeDepth;
                    o.color = i[j].color;
                    
                    o.vertex = UnityObjectToClipPos(i[j].vertex);
                    if (j == 0) o.barycentric = float3(1.0, 0.0, 0.0) + modifier;
                    if (j == 1) o.barycentric = float3(0.0, 1.0, 0.0) + modifier;
                    if (j == 2) o.barycentric = float3(0.0, 0.0, 1.0) + modifier;

                    triangleStream.Append(o);
                }
            }

            ENDCG
        }
    }
}
