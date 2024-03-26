// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Glass"
{
	Properties
	{
		_MatCap("MatCap", 2D) = "white" {}
		_RefractMatCap("RefractMatCap", 2D) = "white" {}
		_RefractIntensity("RefractIntensity", Float) = 1
		_RefractColor("RefractColor", Color) = (0,0,0,0)
		_ThicknessMap("ThicknessMap", 2D) = "white" {}
		_ObjectPivotOffset("ObjectPivotOffset", Float) = -0.005
		_ObjectHeight("ObjectHeight", Float) = 0.35
		_DirtyMask("DirtyMask", 2D) = "black" {}
		_Decal("Decal", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Pass
		{
			ColorMask 0
			ZWrite On
		}

		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		Blend SrcAlpha OneMinusSrcAlpha
		
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float3 worldPos;
			float3 worldNormal;
			float3 viewDir;
			float2 uv_texcoord;
		};

		uniform sampler2D _MatCap;
		uniform float4 _RefractColor;
		uniform sampler2D _RefractMatCap;
		uniform sampler2D _ThicknessMap;
		uniform float _ObjectPivotOffset;
		uniform float _ObjectHeight;
		uniform sampler2D _DirtyMask;
		uniform float4 _DirtyMask_ST;
		uniform float _RefractIntensity;
		uniform sampler2D _Decal;
		uniform float4 _Decal_ST;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView16 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 normalizeResult17 = normalize( objToView16 );
			float3 ase_worldNormal = i.worldNormal;
			float3 break20 = cross( normalizeResult17 , mul( UNITY_MATRIX_V, float4( ase_worldNormal , 0.0 ) ).xyz );
			float2 appendResult21 = (float2(break20.y , break20.x));
			float2 MatCapUV225 = (appendResult21*0.5 + 0.5);
			float4 MatCap67 = tex2D( _MatCap, MatCapUV225 );
			float dotResult32 = dot( ase_worldNormal , i.viewDir );
			float smoothstepResult34 = smoothstep( 0.0 , 1.0 , dotResult32);
			float3 ase_worldPos = i.worldPos;
			float3 objToWorldDir52 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 0 ) ).xyz;
			float2 appendResult58 = (float2(0.5 , ( ( ( ase_worldPos.y - objToWorldDir52.y ) - _ObjectPivotOffset ) / _ObjectHeight )));
			float2 uv_DirtyMask = i.uv_texcoord * _DirtyMask_ST.xy + _DirtyMask_ST.zw;
			float clampResult63 = clamp( ( ( 1.0 - smoothstepResult34 ) + tex2D( _ThicknessMap, appendResult58 ).r + tex2D( _DirtyMask, uv_DirtyMask ).a ) , 0.0 , 1.0 );
			float RefractThickness43 = clampResult63;
			float temp_output_35_0 = ( RefractThickness43 * _RefractIntensity );
			float4 lerpResult41 = lerp( ( _RefractColor * 0.5 ) , ( _RefractColor * tex2D( _RefractMatCap, ( MatCapUV225 + temp_output_35_0 ) ) ) , temp_output_35_0);
			float2 uv_Decal = i.uv_texcoord * _Decal_ST.xy + _Decal_ST.zw;
			float4 tex2DNode65 = tex2D( _Decal, uv_Decal );
			float4 lerpResult66 = lerp( ( MatCap67 + lerpResult41 ) , tex2DNode65 , tex2DNode65.a);
			o.Emission = lerpResult66.rgb;
			float4 temp_cast_3 = (RefractThickness43).xxxx;
			float4 clampResult64 = clamp( ( tex2DNode65.a + max( MatCap67 , temp_cast_3 ) ) , float4( 0,0,0,0 ) , float4( 1,0,0,0 ) );
			o.Alpha = clampResult64.r;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit keepalpha fullforwardshadows 

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
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
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
				surfIN.viewDir = worldViewDir;
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = IN.worldNormal;
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
Node;AmplifyShaderEditor.CommentaryNode;71;-955.0995,-428.185;Inherit;False;887.83;280;MatCap;3;9;1;67;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;46;-2875.891,555.4916;Inherit;False;1942.015;1049.243;RefractThickness;18;56;58;59;62;52;33;50;51;57;55;54;43;53;29;30;34;32;63;RefractThickness;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-2602.225,-61.42553;Inherit;False;1636.592;583.512;改进版MatCapUV;12;23;22;16;21;20;15;19;17;14;13;12;25;改进版MatCapUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;11;-2072.476,-440.3047;Inherit;False;1080.795;369;MatCap_UV，表面太平的时候不能用;6;2;4;3;8;6;7;MatCap_UV;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;8;-1183.998,-310.4199;Inherit;False;MatCapUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ViewMatrixNode;13;-2383.854,213.2173;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldNormalVector;14;-2416.854,343.217;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PosVertexDataNode;15;-2579.163,-11.42547;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformPositionNode;16;-2355.729,29.58662;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1177.361,193.0933;Inherit;False;MatCapUV2;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;6;-1603.415,-318.7015;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-1795.476,-315.3048;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewMatrixNode;4;-1997.476,-393.3048;Inherit;False;0;1;FLOAT4x4;0
Node;AmplifyShaderEditor.WorldNormalVector;2;-2030.476,-263.3048;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;7;-1408.165,-307.7094;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-2181.858,291.2171;Inherit;False;2;2;0;FLOAT4x4;0,0,0,0,0,1,0,0,0,0,1,0,0,0,0,1;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;17;-2104.875,91.23099;Inherit;False;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CrossProductOpNode;19;-1935.533,165.4824;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;20;-1724.808,178.5504;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.DynamicAppendNode;21;-1573.75,173.2773;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NegateNode;22;-1576.716,299.9459;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;23;-1422.051,171.5623;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DotProductOpNode;32;-2535.983,734.7695;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;30;-2797.984,781.7693;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;29;-2825.891,605.4916;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-379.0245,578.5513;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-629.7269,562.0883;Inherit;False;25;MatCapUV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;35;-544.254,684.6434;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;265.1278,523.5189;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;-237.8294,260.8467;Inherit;False;Property;_RefractColor;RefractColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;232.0676,285.8693;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;53;-2528.327,1097.622;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;54;-2325.474,1120.449;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;55;-2554.846,1233.622;Inherit;False;Property;_ObjectPivotOffset;ObjectPivotOffset;6;0;Create;True;0;0;0;False;0;False;-0.005;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-2347.647,1273.753;Inherit;False;Property;_ObjectHeight;ObjectHeight;7;0;Create;True;0;0;0;False;0;False;0.35;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;51;-2838.031,985.0942;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;50;-1804.456,1033.09;Inherit;True;Property;_ThicknessMap;ThicknessMap;5;0;Create;True;0;0;0;False;0;False;-1;2a30b31a579145b428c5dbfe7173212a;2a30b31a579145b428c5dbfe7173212a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TransformDirectionNode;52;-2862.196,1164.094;Inherit;False;Object;World;False;Fast;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DynamicAppendNode;58;-2025.208,1102.221;Inherit;False;FLOAT2;4;0;FLOAT;0.5;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;56;-2170.663,1158.014;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;43;-1152.933,947.9606;Inherit;False;RefractThickness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;59;-1407.126,953.9595;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;63;-1291.325,948.4224;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;45;-757.0166,667.5055;Inherit;False;43;RefractThickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;26;-228.8307,532.2969;Inherit;True;Property;_RefractMatCap;RefractMatCap;2;0;Create;True;0;0;0;False;0;False;-1;6c0a31db3ee45434585b04977c1adc20;6c0a31db3ee45434585b04977c1adc20;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;62;-1793.107,1343.882;Inherit;True;Property;_DirtyMask;DirtyMask;8;0;Create;True;0;0;0;False;0;False;-1;7364bd8601bcb25428296b553c8d8ad4;7364bd8601bcb25428296b553c8d8ad4;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;33;-2113.59,751.6241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;34;-2338.278,739.0775;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;66;978.6865,-66.55188;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;298.2264,-138.6305;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;9;-905.0995,-343.591;Inherit;False;25;MatCapUV2;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-660.1924,-378.185;Inherit;True;Property;_MatCap;MatCap;1;0;Create;True;0;0;0;False;0;False;-1;6c0a31db3ee45434585b04977c1adc20;6c0a31db3ee45434585b04977c1adc20;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;67;-300.2696,-373.7123;Inherit;False;MatCap;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;49;77.1018,343.6134;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;65;643.085,13.09098;Inherit;True;Property;_Decal;Decal;9;0;Create;True;0;0;0;False;0;False;-1;eb58bad1435090e468e736346e6723eb;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;41;457.2337,505.7568;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;64;1170.849,269.4963;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;38;813.3207,274.2449;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;44;609.5754,336.1624;Inherit;False;43;RefractThickness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;72;1008.688,167.7506;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;68;-72.52077,-138.8087;Inherit;False;67;MatCap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;69;584.2963,240.5197;Inherit;False;67;MatCap;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-758.8973,760.0311;Inherit;False;Property;_RefractIntensity;RefractIntensity;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1370.947,31.72106;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Glass;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;True;0;Custom;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;7;0
WireConnection;16;0;15;0
WireConnection;25;0;23;0
WireConnection;6;0;3;0
WireConnection;3;0;4;0
WireConnection;3;1;2;0
WireConnection;7;0;6;0
WireConnection;12;0;13;0
WireConnection;12;1;14;0
WireConnection;17;0;16;0
WireConnection;19;0;17;0
WireConnection;19;1;12;0
WireConnection;20;0;19;0
WireConnection;21;0;20;1
WireConnection;21;1;20;0
WireConnection;22;0;20;2
WireConnection;23;0;21;0
WireConnection;32;0;29;0
WireConnection;32;1;30;0
WireConnection;28;0;27;0
WireConnection;28;1;35;0
WireConnection;35;0;45;0
WireConnection;35;1;36;0
WireConnection;47;0;40;0
WireConnection;47;1;26;0
WireConnection;48;0;40;0
WireConnection;48;1;49;0
WireConnection;53;0;51;2
WireConnection;53;1;52;2
WireConnection;54;0;53;0
WireConnection;54;1;55;0
WireConnection;50;1;58;0
WireConnection;58;1;56;0
WireConnection;56;0;54;0
WireConnection;56;1;57;0
WireConnection;43;0;63;0
WireConnection;59;0;33;0
WireConnection;59;1;50;1
WireConnection;59;2;62;4
WireConnection;63;0;59;0
WireConnection;26;1;28;0
WireConnection;33;0;34;0
WireConnection;34;0;32;0
WireConnection;66;0;37;0
WireConnection;66;1;65;0
WireConnection;66;2;65;4
WireConnection;37;0;68;0
WireConnection;37;1;41;0
WireConnection;1;1;9;0
WireConnection;67;0;1;0
WireConnection;41;0;48;0
WireConnection;41;1;47;0
WireConnection;41;2;35;0
WireConnection;64;0;72;0
WireConnection;38;0;69;0
WireConnection;38;1;44;0
WireConnection;72;0;65;4
WireConnection;72;1;38;0
WireConnection;0;2;66;0
WireConnection;0;9;64;0
ASEEND*/
//CHKSM=BE327758FE414B750C402B49C85ED585C4156772