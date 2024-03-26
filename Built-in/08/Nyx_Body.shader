// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nyx_Body"
{
	Properties
	{
		_NormalMap("NormalMap", 2D) = "bump" {}
		_RimPower("RimPower", Float) = 5
		_RimScale("RimScale", Float) = 1
		_RimBias("RimBias", Float) = 0
		_RimColor("RimColor", Color) = (0.6084906,0.8577422,1,0)
		_EimssFlowMap("EimssFlowMap", 2D) = "white" {}
		_FlowTillingSpeed("FlowTillingSpeed", Vector) = (0.5,0.5,0,0)
		_FlowLightColor("FlowLightColor", Color) = (0.1787558,0.4194861,0.9716981,0)
		_FlowRimScale("FlowRimScale", Float) = 1
		_FlowRimBias("FlowRimBias", Float) = 0
		_NebulaTex("NebulaTex", 2D) = "white" {}
		_NebulaTilling("NebulaTilling", Vector) = (1,1,0,0)
		_NebulaDistort("NebulaDistort", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float3 worldNormal;
			INTERNAL_DATA
			float2 uv_texcoord;
			float3 worldPos;
		};

		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform float _RimPower;
		uniform float _RimScale;
		uniform float _RimBias;
		uniform float4 _RimColor;
		uniform float _FlowRimScale;
		uniform float _FlowRimBias;
		uniform sampler2D _EimssFlowMap;
		uniform float4 _FlowTillingSpeed;
		uniform float4 _FlowLightColor;
		uniform sampler2D _NebulaTex;
		uniform float _NebulaDistort;
		uniform float2 _NebulaTilling;


		inline float3 ASESafeNormalize(float3 inVec)
		{
			float dp3 = max( 0.001f , dot( inVec , inVec ) );
			return inVec* rsqrt( dp3);
		}


		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			o.Normal = float3(0,0,1);
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			float3 WorldNormal9 = normalize( (WorldNormalVector( i , UnpackNormal( tex2D( _NormalMap, uv_NormalMap ) ) )) );
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float dotResult5 = dot( WorldNormal9 , ase_worldViewDir );
			float NdotV6 = dotResult5;
			float clampResult14 = clamp( NdotV6 , 0.0 , 1.0 );
			float4 RimColor25 = ( ( ( pow( ( 1.0 - clampResult14 ) , _RimPower ) * _RimScale ) + _RimBias ) * _RimColor );
			float3 objToWorld31 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 panner43 = ( 1.0 * _Time.y * (_FlowTillingSpeed).zw + ( ( (NdotV6*0.5 + 0.5) + (( ase_worldPos - objToWorld31 )).xy ) * (_FlowTillingSpeed).xy ));
			float FlowLight44 = tex2D( _EimssFlowMap, panner43 ).r;
			float4 FlowLightColor55 = ( ( ( ( 1.0 - NdotV6 ) * _FlowRimScale ) + _FlowRimBias ) * FlowLight44 * _FlowLightColor );
			float3 ase_vertex3Pos = mul( unity_WorldToObject, float4( i.worldPos , 1 ) );
			float3 objToView66 = mul( UNITY_MATRIX_MV, float4( ase_vertex3Pos, 1 ) ).xyz;
			float3 objToView68 = mul( UNITY_MATRIX_MV, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float3 objToViewDir77 = ASESafeNormalize( mul( UNITY_MATRIX_IT_MV, float4( WorldNormal9, 0 ) ).xyz );
			float4 NebulaColor73 = tex2D( _NebulaTex, ( ( (( objToView66 - objToView68 )).xy + ( (objToViewDir77).xy * _NebulaDistort ) ) * _NebulaTilling ) );
			float4 saferPower86 = abs( NebulaColor73 );
			float saferPower89 = abs( FlowLight44 );
			o.Emission = ( ( RimColor25 + FlowLightColor55 + ( NebulaColor73 * FlowLight44 ) ) + ( pow( saferPower86 , 5.0 ) * pow( saferPower89 , 2.0 ) * 15.0 ) ).rgb;
			o.Alpha = 1;
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
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
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
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
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
Node;AmplifyShaderEditor.CommentaryNode;92;-696.0344,-30.60139;Inherit;False;635.0005;413.0001;BlinKing;6;85;86;87;90;88;89;BlinKing;0.8265786,0.4262638,0.9716981,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;74;-2470.053,1824.492;Inherit;False;1955.738;714.8608;NebulaColor;15;81;73;72;80;79;78;77;76;70;71;69;68;66;67;65;NebulaColor;1,0.5330188,0.5330188,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;56;-2467.371,1159.61;Inherit;False;1454.335;637.6857;FlowLightColor;10;63;51;55;52;53;58;62;61;60;59;FlowLightColor;0.25,0.5189276,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;45;-2466.75,406.288;Inherit;False;2053.505;689.986;FlowLight;14;47;50;48;33;44;43;36;34;38;35;32;31;29;30;FlowLight;0.4575472,0.7683797,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;26;-2443.745,-65.03184;Inherit;False;1632.409;434.175;RimColor;12;12;14;15;16;17;18;20;22;25;24;21;19;RimColor;0.7311321,0.9340044,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;11;-1502.834,-549.7464;Inherit;False;661.8757;409.8321;NdotV;4;6;5;3;28;NdotV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;10;-2457.904,-518.566;Inherit;False;846.9718;280;NormalMap;3;7;8;9;NormalMap;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;44;-697.9151,751.2247;Inherit;False;FlowLight;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;9;-1843.932,-467.5362;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DotProductOpNode;5;-1224.524,-438.9822;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;6;-1073.958,-437.6318;Inherit;False;NdotV;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;12;-2393.744,-15.0317;Inherit;False;6;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;14;-2215.454,-13.19229;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;15;-2019.221,-11.39279;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;17;-1966.735,106.8384;Inherit;False;Property;_RimPower;RimPower;1;0;Create;True;0;0;0;False;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-1601.64,7.402506;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;-1400.722,8.371378;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-1216.945,7.597208;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1044.334,1.988141;Inherit;False;RimColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-1565.722,162.3717;Inherit;False;Property;_RimBias;RimBias;3;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-1769.722,129.3717;Inherit;False;Property;_RimScale;RimScale;2;0;Create;True;0;0;0;False;0;False;1;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;24;-1402.088,157.1437;Inherit;False;Property;_RimColor;RimColor;4;0;Create;True;0;0;0;False;0;False;0.6084906,0.8577422,1,0;0.4198113,0.6087101,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;3;-1444.989,-375.9818;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.GetLocalVarNode;28;-1449.681,-459.8342;Inherit;False;9;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;7;-2407.904,-468.5657;Inherit;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;0;False;0;False;-1;9092de7db844f6044943760a9e24b8be;9092de7db844f6044943760a9e24b8be;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;16;-1803.311,11.70036;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;30;-2195.274,625.651;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.WorldPosInputsNode;29;-2429.276,575.6512;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;31;-2440.276,728.6501;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PannerNode;43;-1255.597,763.3486;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;33;-1014.342,722.658;Inherit;True;Property;_EimssFlowMap;EimssFlowMap;5;0;Create;True;0;0;0;False;0;False;-1;None;357c9d3f8659c95409a986a328da9f3e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;59;-2198.682,1255.256;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;60;-1938.682,1251.256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;61;-2229.682,1336.256;Inherit;False;Property;_FlowRimScale;FlowRimScale;8;0;Create;True;0;0;0;False;0;False;1;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;62;-1752.682,1284.256;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;58;-2441.411,1227.875;Inherit;False;6;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;53;-1810.621,1536.92;Inherit;False;Property;_FlowLightColor;FlowLightColor;7;0;Create;True;0;0;0;False;0;False;0.1787558,0.4194861,0.9716981,0;0.2311321,0.4493072,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;52;-1466.946,1369.043;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;55;-1310.443,1379.14;Inherit;False;FlowLightColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;51;-1758.82,1431.893;Inherit;False;44;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;63;-1949.528,1359.972;Inherit;False;Property;_FlowRimBias;FlowRimBias;9;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;8;-2088.931,-462.5362;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;48;-1613.973,667.0551;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;35;-1805.283,809.9087;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;38;-1805.283,891.9078;Inherit;False;FLOAT2;2;3;2;3;1;0;FLOAT4;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node;34;-2026.313,810.4569;Inherit;False;Property;_FlowTillingSpeed;FlowTillingSpeed;6;0;Create;True;0;0;0;False;0;False;0.5,0.5,0,0;0.1,0.1,0,0.3;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;47;-2101.388,482.3898;Inherit;False;6;NdotV;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;50;-1861.985,534.3934;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SwizzleNode;32;-1948.274,669.6307;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;36;-1437.013,725.4519;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PosVertexDataNode;65;-2420.053,1874.492;Inherit;False;0;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;67;-1907.111,1976.252;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformPositionNode;66;-2200.111,1907.252;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;68;-2214.111,2091.25;Inherit;False;Object;View;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SwizzleNode;69;-1740.111,1976.252;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SwizzleNode;78;-1901.481,2290.409;Inherit;False;FLOAT2;0;1;2;3;1;0;FLOAT3;0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;79;-1710.843,2324.103;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;80;-1893.843,2422.103;Inherit;False;Property;_NebulaDistort;NebulaDistort;12;0;Create;True;0;0;0;False;0;False;1;0.05;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;81;-1534.938,2063.904;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;72;-1149.691,2007.92;Inherit;True;Property;_NebulaTex;NebulaTex;10;0;Create;True;0;0;0;False;0;False;-1;138b0afdfd7cab64c89b7ec35ccc17a1;138b0afdfd7cab64c89b7ec35ccc17a1;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;73;-754.8292,2014.78;Inherit;False;NebulaColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-1331.262,2083.124;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;71;-1549.712,2176.496;Inherit;False;Property;_NebulaTilling;NebulaTilling;11;0;Create;True;0;0;0;False;0;False;1,1;0.2,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;76;-2372.595,2282.244;Inherit;False;9;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TransformDirectionNode;77;-2182.907,2281.277;Inherit;False;Object;View;True;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;130.7744,-367.0978;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Nyx_Body;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-229.9504,-302.4599;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;27;-652.5592,-396.9147;Inherit;False;25;RimColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;57;-663.0507,-315.2541;Inherit;False;55;FlowLightColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;75;-720.3474,-229.5394;Inherit;False;73;NebulaColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;83;-705.5797,-142.4248;Inherit;False;44;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;82;-446.8957,-217.4404;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;91;-47.44506,-276.7538;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-646.0344,19.39861;Inherit;False;73;NebulaColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;-227.0338,35.39858;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;90;-409.0338,266.3987;Inherit;False;Constant;_Float0;Float 0;13;0;Create;True;0;0;0;False;0;False;15;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;88;-632.0344,121.3986;Inherit;False;44;FlowLight;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;86;-429.0339,24.39861;Inherit;False;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;5;False;1;COLOR;0
Node;AmplifyShaderEditor.PowerNode;89;-428.0339,124.3986;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
WireConnection;44;0;33;1
WireConnection;9;0;8;0
WireConnection;5;0;28;0
WireConnection;5;1;3;0
WireConnection;6;0;5;0
WireConnection;14;0;12;0
WireConnection;15;0;14;0
WireConnection;18;0;16;0
WireConnection;18;1;19;0
WireConnection;20;0;18;0
WireConnection;20;1;21;0
WireConnection;22;0;20;0
WireConnection;22;1;24;0
WireConnection;25;0;22;0
WireConnection;16;0;15;0
WireConnection;16;1;17;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;43;0;36;0
WireConnection;43;2;38;0
WireConnection;33;1;43;0
WireConnection;59;0;58;0
WireConnection;60;0;59;0
WireConnection;60;1;61;0
WireConnection;62;0;60;0
WireConnection;62;1;63;0
WireConnection;52;0;62;0
WireConnection;52;1;51;0
WireConnection;52;2;53;0
WireConnection;55;0;52;0
WireConnection;8;0;7;0
WireConnection;48;0;50;0
WireConnection;48;1;32;0
WireConnection;35;0;34;0
WireConnection;38;0;34;0
WireConnection;50;0;47;0
WireConnection;32;0;30;0
WireConnection;36;0;48;0
WireConnection;36;1;35;0
WireConnection;67;0;66;0
WireConnection;67;1;68;0
WireConnection;66;0;65;0
WireConnection;69;0;67;0
WireConnection;78;0;77;0
WireConnection;79;0;78;0
WireConnection;79;1;80;0
WireConnection;81;0;69;0
WireConnection;81;1;79;0
WireConnection;72;1;70;0
WireConnection;73;0;72;0
WireConnection;70;0;81;0
WireConnection;70;1;71;0
WireConnection;77;0;76;0
WireConnection;0;2;91;0
WireConnection;64;0;27;0
WireConnection;64;1;57;0
WireConnection;64;2;82;0
WireConnection;82;0;75;0
WireConnection;82;1;83;0
WireConnection;91;0;64;0
WireConnection;91;1;87;0
WireConnection;87;0;86;0
WireConnection;87;1;89;0
WireConnection;87;2;90;0
WireConnection;86;0;85;0
WireConnection;89;0;88;0
ASEEND*/
//CHKSM=D5892A08D48360D2DF1FBBCAE18868344E9029D1