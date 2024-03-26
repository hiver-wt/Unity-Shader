// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Fire"
{
	Properties
	{
		_BaseColor("BaseColor", Color) = (0,0,0,0)
		_BaseColorEmiss("BaseColorEmiss", Float) = 3
		_NoiseTex("NoiseTex", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Vector) = (0,0,0,0)
		_GradientTex("GradientTex", 2D) = "white" {}
		_Softness("Softness", Range( 0 , 0.5)) = 0.1117647
		_GradientEndControl("GradientEndControl", Float) = 2
		_EndColorAdjust("EndColorAdjust", Range( 0 , 1)) = 0
		_FireShape("FireShape", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _BaseColor;
		uniform float _BaseColorEmiss;
		uniform float _EndColorAdjust;
		uniform sampler2D _GradientTex;
		uniform float4 _GradientTex_ST;
		uniform float _GradientEndControl;
		uniform sampler2D _NoiseTex;
		uniform float2 _NoiseSpeed;
		uniform float4 _NoiseTex_ST;
		uniform float _Softness;
		uniform sampler2D _FireShape;
		uniform float4 _FireShape_ST;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 break41 = ( _BaseColor * _BaseColorEmiss );
			float2 uv_GradientTex = i.uv_texcoord * _GradientTex_ST.xy + _GradientTex_ST.zw;
			float4 tex2DNode23 = tex2D( _GradientTex, uv_GradientTex );
			float GradientEnd38 = ( ( 1.0 - tex2DNode23.r ) * _GradientEndControl );
			float4 appendResult42 = (float4(break41.r , ( break41.g + ( _EndColorAdjust * GradientEnd38 ) ) , break41.b , 0.0));
			o.Emission = appendResult42.xyz;
			float2 uv_NoiseTex = i.uv_texcoord * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
			float2 panner21 = ( 1.0 * _Time.y * _NoiseSpeed + uv_NoiseTex);
			float Nosie31 = tex2D( _NoiseTex, panner21 ).r;
			float clampResult29 = clamp( ( Nosie31 - _Softness ) , 0.0 , 1.0 );
			float Gadient30 = tex2DNode23.r;
			float smoothstepResult25 = smoothstep( clampResult29 , Nosie31 , Gadient30);
			float2 uv_FireShape = i.uv_texcoord * _FireShape_ST.xy + _FireShape_ST.zw;
			float2 appendResult53 = (float2(( ( (Nosie31*2.0 + -1.0) * 0.1 * Gadient30 ) + uv_FireShape.x ) , uv_FireShape.y));
			float4 tex2DNode48 = tex2D( _FireShape, appendResult53 );
			float FireShapeg60 = ( tex2DNode48.r * tex2DNode48.r );
			o.Alpha = ( smoothstepResult25 * FireShapeg60 );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;63;-2589.808,188.2129;Inherit;False;1159.051;398.4384;Noise;5;3;21;4;22;31;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;62;-2752.937,-334.3103;Inherit;False;1308.38;447.7729;Gradient;7;23;30;16;36;38;37;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;59;-1434.358,614.0914;Inherit;False;1711.262;494.6603;Shape;11;53;54;49;52;51;56;55;57;48;58;60;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Fire;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ColorNode;10;-1221.902,-247.3184;Inherit;False;Property;_BaseColor;BaseColor;0;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.7924528,0.3474225,0.1906371,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-896.1998,-156.3256;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BreakToComponentsNode;41;-696.0328,-179.7814;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;43;-463.7722,-43.29098;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-1070.042,35.61916;Inherit;False;Property;_EndColorAdjust;EndColorAdjust;7;0;Create;True;0;0;0;False;0;False;0;0.442;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;46;-1015.626,156.631;Inherit;False;38;GradientEnd;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-690.7231,95.26478;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;42;-256.0134,-100.7105;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1065.867,-78.53333;Inherit;False;Property;_BaseColorEmiss;BaseColorEmiss;1;0;Create;True;0;0;0;False;0;False;3;3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;53;-614.6588,753.872;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;54;-985.3987,771.0081;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-1017.268,944.7524;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;52;-763.1769,750.0146;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-1384.359,664.0914;Inherit;False;31;Nosie;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;56;-1373.899,820.8251;Inherit;False;Constant;_NosieIntensity;NosieIntensity;9;0;Create;True;0;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;55;-1360.264,926.252;Inherit;False;30;Gadient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;57;-1195.394,698.7104;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-458.9341,685.5557;Inherit;True;Property;_FireShape;FireShape;8;0;Create;True;0;0;0;False;0;False;-1;2be768ada115d054692b3375d6bfc6e0;2be768ada115d054692b3375d6bfc6e0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-62.62776,709.8613;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;60;93.24327,716.2455;Inherit;False;FireShapeg;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;34;-919.6561,523.554;Inherit;False;31;Nosie;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;-1362.768,364.1765;Inherit;False;31;Nosie;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-1398.643,473.7669;Inherit;False;Property;_Softness;Softness;5;0;Create;True;0;0;0;False;0;False;0.1117647;0.291;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;33;-1087.614,310.752;Inherit;False;30;Gadient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;26;-1083.258,406.2248;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;29;-860.8393,380.4203;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;30;-1980.318,-251.942;Inherit;False;Gadient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;16;-2702.937,-249.5628;Inherit;False;0;23;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;3;-2539.808,238.2129;Inherit;False;0;4;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;21;-2228.376,309.2374;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;4;-2003.663,264.9274;Inherit;True;Property;_NoiseTex;NoiseTex;2;0;Create;True;0;0;0;False;0;False;-1;db8a17037f86d9e41bedc03b81739e6b;db8a17037f86d9e41bedc03b81739e6b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;22;-2502.673,422.6515;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;3;0;Create;True;0;0;0;False;0;False;0,0;0,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-1663.757,261.5666;Inherit;False;Nosie;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;23;-2388.608,-284.3103;Inherit;True;Property;_GradientTex;GradientTex;4;0;Create;True;0;0;0;False;0;False;-1;41bb3342aad56ae4e8ce4bc905b3c059;41bb3342aad56ae4e8ce4bc905b3c059;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;35;-2065.933,-129.6368;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;38;-1666.392,-56.95849;Inherit;False;GradientEnd;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;37;-1897.981,-111.4615;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2269.355,-3.933105;Inherit;False;Property;_GradientEndControl;GradientEndControl;6;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-241.1257,336.1917;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;25;-552.7762,300.2357;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;61;-478.9109,515.7592;Inherit;False;60;FireShapeg;1;0;OBJECT;;False;1;FLOAT;0
WireConnection;0;2;42;0
WireConnection;0;9;50;0
WireConnection;11;0;10;0
WireConnection;11;1;12;0
WireConnection;41;0;11;0
WireConnection;43;0;41;1
WireConnection;43;1;45;0
WireConnection;45;0;44;0
WireConnection;45;1;46;0
WireConnection;42;0;41;0
WireConnection;42;1;43;0
WireConnection;42;2;41;2
WireConnection;53;0;52;0
WireConnection;53;1;49;2
WireConnection;54;0;57;0
WireConnection;54;1;56;0
WireConnection;54;2;55;0
WireConnection;52;0;54;0
WireConnection;52;1;49;1
WireConnection;57;0;51;0
WireConnection;48;1;53;0
WireConnection;58;0;48;1
WireConnection;58;1;48;1
WireConnection;60;0;58;0
WireConnection;26;0;32;0
WireConnection;26;1;27;0
WireConnection;29;0;26;0
WireConnection;30;0;23;1
WireConnection;21;0;3;0
WireConnection;21;2;22;0
WireConnection;4;1;21;0
WireConnection;31;0;4;1
WireConnection;23;1;16;0
WireConnection;35;0;23;1
WireConnection;38;0;37;0
WireConnection;37;0;35;0
WireConnection;37;1;36;0
WireConnection;50;0;25;0
WireConnection;50;1;61;0
WireConnection;25;0;33;0
WireConnection;25;1;29;0
WireConnection;25;2;34;0
ASEEND*/
//CHKSM=503C295CFEFA34091382A6F759715B85D29361D1