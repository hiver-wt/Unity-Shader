// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Soft"
{
	Properties
	{
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5
		_EdgeColorEmiss("EdgeColorEmiss", Float) = 1
		_EegeWidth("EegeWidth", Range( 0 , 2)) = 0.1
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		[Toggle(_MNUECONTROL_ON)] _MnueControl("MnueControl", Float) = 1
		_Spread("Spread", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _MNUECONTROL_ON
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _MainTex;
		uniform float4 _MainTex_ST;
		uniform float4 _EdgeColor;
		uniform float _EdgeColorEmiss;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform float _EegeWidth;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime24 = _Time.y * 0.4;
			#ifdef _MNUECONTROL_ON
				float staticSwitch26 = _ChangeAmount;
			#else
				float staticSwitch26 = frac( mulTime24 );
			#endif
			float Gradient20 = ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (staticSwitch26 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread );
			float clampResult15 = clamp( ( 1.0 - ( distance( 0.1594267 , Gradient20 ) / _EegeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult16 = lerp( tex2DNode1 , ( _EdgeColor * _EdgeColorEmiss ) , clampResult15);
			o.Emission = lerpResult16.rgb;
			float smoothstepResult33 = smoothstep( 0.1594267 , 0.5 , Gradient20);
			o.Alpha = ( tex2DNode1.a * smoothstepResult33 );
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
Node;AmplifyShaderEditor.CommentaryNode;35;-1190.685,624.1777;Inherit;False;1445.614;447.4357;Edge Color;5;12;9;11;13;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2886.183,-3.63518;Inherit;False;1587.56;644.8994;Graditent;11;20;32;31;30;25;24;4;8;5;26;2;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;1;-1145.554,-165.0988;Inherit;True;Property;_MainTex;MainTex;0;0;Create;True;0;0;0;False;0;False;-1;0b7aca28296b0ed4e99f55846348e10e;0b7aca28296b0ed4e99f55846348e10e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;17;-635.0403,19.29964;Inherit;False;Property;_EdgeColor;EdgeColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.5649109,0.1650939,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-307.5998,-2.67989;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;16;25.67978,-108.3252;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-575.6548,203.1507;Inherit;False;Property;_EdgeColorEmiss;EdgeColorEmiss;3;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-2526.983,41.52072;Inherit;True;Property;_Gradient;Gradient;1;0;Create;True;0;0;0;False;0;False;-1;d14593d4466be7e44b9d537374a698ed;d14593d4466be7e44b9d537374a698ed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;26;-2521.222,281.0476;Inherit;False;Property;_MnueControl;MnueControl;6;0;Create;True;0;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-2212.448,233.0246;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1960.415,110.2827;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;25;-2656.667,250.6638;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2748.78,491.6;Inherit;False;Property;_Spread;Spread;7;0;Create;True;0;0;0;False;0;False;0;0.243;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2866.254,354.8914;Inherit;False;Property;_ChangeAmount;ChangeAmount;2;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1484.945,258.5068;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1698.553,269.3801;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2419.772,406.6903;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;279.2868,11.20388;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve_Soft;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;2;5;False;;10;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-391.9827,301.5751;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;33;-672.4783,367.0188;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1277.299,376.3488;Inherit;False;20;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-893.4122,929.3726;Inherit;False;Property;_EegeWidth;EegeWidth;4;0;Create;True;0;0;0;False;0;False;0.1;0.31;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;9;-817.3949,674.1777;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-433.4581,741.7548;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;-172.4674,817.6135;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;81.92864,759.2172;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;34;-984.5211,460.9218;Inherit;False;Constant;_Softness;Softness;8;0;Create;True;0;0;0;False;0;False;0.1594267;0;0;0.5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;24;-2840.173,240.0208;Inherit;False;1;0;FLOAT;0.4;False;1;FLOAT;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;16;0;1;0
WireConnection;16;1;18;0
WireConnection;16;2;15;0
WireConnection;26;1;25;0
WireConnection;26;0;5;0
WireConnection;8;0;26;0
WireConnection;8;3;31;0
WireConnection;4;0;2;1
WireConnection;4;1;8;0
WireConnection;25;0;24;0
WireConnection;20;0;32;0
WireConnection;32;0;4;0
WireConnection;32;1;30;0
WireConnection;31;0;30;0
WireConnection;0;2;16;0
WireConnection;0;9;3;0
WireConnection;3;0;1;4
WireConnection;3;1;33;0
WireConnection;33;0;22;0
WireConnection;33;1;34;0
WireConnection;9;0;34;0
WireConnection;9;1;22;0
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;13;0;11;0
WireConnection;15;0;13;0
ASEEND*/
//CHKSM=87FC034B589E23BEEE2FF0ADD31F8D40D1EF033C