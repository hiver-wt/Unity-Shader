// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Nyx_VFX"
{
	Properties
	{
		_EmissMap("EmissMap", 2D) = "white" {}
		_FlowSpeed("FlowSpeed", Vector) = (0,0,0,0)
		_EmissIntensity("EmissIntensity", Float) = 1
		_EmissColor("EmissColor", Color) = (0.5330188,0.8068478,1,0)
		_NoiseMap("NoiseMap", 2D) = "white" {}
		_NoiseIntensity("NoiseIntensity", Float) = 1
		_FadePower("FadePower", Float) = 2
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Custom"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		ZWrite Off
		Blend SrcAlpha One
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _EmissColor;
		uniform sampler2D _EmissMap;
		uniform float2 _FlowSpeed;
		uniform float4 _EmissMap_ST;
		uniform sampler2D _NoiseMap;
		uniform float4 _NoiseMap_ST;
		uniform float _NoiseIntensity;
		uniform float _EmissIntensity;
		uniform float _FadePower;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_EmissMap = i.uv_texcoord * _EmissMap_ST.xy + _EmissMap_ST.zw;
			float2 panner4 = ( 1.0 * _Time.y * _FlowSpeed + uv_EmissMap);
			float2 uv_NoiseMap = i.uv_texcoord * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
			float4 EmissMapUV35 = ( float4( panner4, 0.0 , 0.0 ) + ( (tex2D( _NoiseMap, uv_NoiseMap )).rgba * _NoiseIntensity * i.uv_texcoord.x ) );
			float temp_output_6_0 = ( tex2D( _EmissMap, EmissMapUV35.xy ).r * _EmissIntensity );
			o.Emission = ( _EmissColor * temp_output_6_0 ).rgb;
			float smoothstepResult23 = smoothstep( 0.0 , 0.3 , ( 1.0 - abs( (i.uv_texcoord.x*2.0 + -1.0) ) ));
			float clampResult40 = clamp( pow( ( 1.0 - i.uv_texcoord.y ) , _FadePower ) , 0.0 , 1.0 );
			float EdgeDetection25 = ( smoothstepResult23 * clampResult40 );
			float temp_output_26_0 = EdgeDetection25;
			o.Alpha = temp_output_26_0;
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
Node;AmplifyShaderEditor.CommentaryNode;37;-3199.285,-489.274;Inherit;False;1419.334;787.9845;EmissMapUV;11;35;27;28;30;32;31;1;5;34;4;33;EmissMapUV;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;24;-3209.893,394.9153;Inherit;False;1489.154;543.6751;边缘检测(Fade);11;38;25;21;23;20;19;18;15;14;39;40;边缘检测(Fade);1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;14;-3159.893,500.0945;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;15;-2876.918,671.6467;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ScaleAndOffsetNode;18;-2870.803,481.5519;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;2;False;2;FLOAT;-1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;19;-2655.059,485.3164;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;20;-2504.01,489.2339;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;23;-2306.358,444.9153;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.3;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;21;-2127.865,495.428;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;25;-1978.307,509.8821;Inherit;False;EdgeDetection;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Nyx_VFX;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;2;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;False;Custom;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;8;5;False;;1;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;35;-2012.951,-323.6476;Inherit;False;EmissMapUV;-1;True;1;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;27;-2876.61,-114.8868;Inherit;True;Property;_NoiseMap;NoiseMap;5;0;Create;True;0;0;0;False;0;False;-1;db115ed4bc2293d498379ab81a40f283;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;28;-3149.285,-93.42629;Inherit;False;0;27;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SwizzleNode;30;-2473.896,-117.1402;Inherit;False;FLOAT4;0;1;2;3;1;0;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RangedFloatNode;32;-2497.628,45.98782;Inherit;False;Property;_NoiseIntensity;NoiseIntensity;6;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;31;-2270.399,-48.21841;Inherit;False;3;3;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;1;-2667.904,-439.274;Inherit;False;0;3;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;5;-2634.454,-290.0158;Inherit;False;Property;_FlowSpeed;FlowSpeed;2;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;34;-2557.364,139.7105;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;4;-2399.826,-367.8914;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;33;-2150.5,-333.6463;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;11;-184.5052,-118.4091;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;12;-504.0803,-289.1154;Inherit;False;Property;_EmissColor;EmissColor;4;0;Create;True;0;0;0;False;0;False;0.5330188,0.8068478,1,0;0.5330188,0.8068478,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;26;-441.937,218.1578;Inherit;False;25;EdgeDetection;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;10;-394.4379,66.50606;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;6;-605.1956,-57.17352;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-931.6442,8.81498;Inherit;False;Property;_EmissIntensity;EmissIntensity;3;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-971.1353,-189.2174;Inherit;True;Property;_EmissMap;EmissMap;1;0;Create;True;0;0;0;False;0;False;-1;fa21a97d1f9ef3d4688be3123b8a70c3;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;36;-1219.911,-159.4661;Inherit;False;35;EmissMapUV;1;0;OBJECT;;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-214.7111,110.1367;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;39;-2800.608,792.373;Inherit;False;Property;_FadePower;FadePower;7;0;Create;True;0;0;0;False;0;False;2;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;38;-2618.309,652.4354;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;40;-2393.711,617.6448;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
WireConnection;15;0;14;2
WireConnection;18;0;14;1
WireConnection;19;0;18;0
WireConnection;20;0;19;0
WireConnection;23;0;20;0
WireConnection;21;0;23;0
WireConnection;21;1;40;0
WireConnection;25;0;21;0
WireConnection;0;2;11;0
WireConnection;0;9;26;0
WireConnection;35;0;33;0
WireConnection;27;1;28;0
WireConnection;30;0;27;0
WireConnection;31;0;30;0
WireConnection;31;1;32;0
WireConnection;31;2;34;1
WireConnection;4;0;1;0
WireConnection;4;2;5;0
WireConnection;33;0;4;0
WireConnection;33;1;31;0
WireConnection;11;0;12;0
WireConnection;11;1;6;0
WireConnection;10;0;6;0
WireConnection;6;0;3;1
WireConnection;6;1;7;0
WireConnection;3;1;36;0
WireConnection;16;0;10;0
WireConnection;16;1;26;0
WireConnection;38;0;15;0
WireConnection;38;1;39;0
WireConnection;40;0;38;0
ASEEND*/
//CHKSM=72E469999B660F06208A7562AB1C460BEE0AE162