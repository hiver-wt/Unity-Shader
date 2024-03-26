// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve 1"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0
		_EdgeColorEmiss("EdgeColorEmiss", Float) = 1
		_DistanceValue("DistanceValue", Float) = 0.5
		_EegeWidth("EegeWidth", Range( 0 , 2)) = 0.4849537
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		[Toggle(_MNUECONTROL_ON)] _MnueControl("MnueControl", Float) = 0
		_Spread("Spread", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "AlphaTest+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma shader_feature_local _MNUECONTROL_ON
		#pragma surface surf Unlit keepalpha addshadow fullforwardshadows 
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
		uniform float _DistanceValue;
		uniform float _EegeWidth;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float2 uv_MainTex = i.uv_texcoord * _MainTex_ST.xy + _MainTex_ST.zw;
			float4 tex2DNode1 = tex2D( _MainTex, uv_MainTex );
			float2 uv_Gradient = i.uv_texcoord * _Gradient_ST.xy + _Gradient_ST.zw;
			float mulTime24 = _Time.y * 0.2;
			#ifdef _MNUECONTROL_ON
				float staticSwitch26 = _ChangeAmount;
			#else
				float staticSwitch26 = frac( mulTime24 );
			#endif
			float Gradient20 = ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (staticSwitch26 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread );
			float clampResult15 = clamp( ( 1.0 - ( distance( Gradient20 , _DistanceValue ) / _EegeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult16 = lerp( tex2DNode1 , ( _EdgeColor * _EdgeColorEmiss ) , clampResult15);
			o.Emission = lerpResult16.rgb;
			o.Alpha = 1;
			clip( ( tex2DNode1.a * step( 0.5 , Gradient20 ) ) - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;37;-809.0489,500.7811;Inherit;False;284;270;算出与0.5的距离;1;9;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-2663.547,-105.2491;Inherit;False;1587.56;644.8994;Graditent;10;20;32;31;30;4;5;26;2;33;34;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;34;-2017.408,121.4952;Inherit;False;216;209;重新映射范围;1;8;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;33;-2653.864,123.4525;Inherit;False;323.5059;137.643;循环播放;2;24;25;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;392.058,-14.42591;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve 1;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-1737.781,8.668751;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-135.9172,-17.50946;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;17;-426.3607,-53.08174;Inherit;False;Property;_EdgeColor;EdgeColor;7;0;Create;True;0;0;0;False;0;False;0,0,0,0;1,0.5649109,0.165094,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-357.3835,137.6207;Inherit;False;Property;_EdgeColorEmiss;EdgeColorEmiss;4;0;Create;True;0;0;0;False;0;False;1;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-909.8655,-126.7308;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;0b7aca28296b0ed4e99f55846348e10e;0b7aca28296b0ed4e99f55846348e10e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-435.3504,617.0192;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1046.439,581.8405;Inherit;False;Property;_DistanceValue;DistanceValue;5;0;Create;True;0;0;0;False;0;False;0.5;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;-153.5504,633.6506;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;25;-2449.358,172.0955;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;24;-2624.864,169.4525;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2615.891,290.31;Inherit;False;Property;_ChangeAmount;ChangeAmount;3;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-1986.407,154.4952;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-2251.35,-70.72521;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;0;False;0;False;-1;d14593d4466be7e44b9d537374a698ed;d14593d4466be7e44b9d537374a698ed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-247.0294,310.3038;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1281.748,102.9672;Inherit;True;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;69.27462,537.7217;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;16;96.17559,-126.8977;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.DistanceOpNode;9;-768.0489,545.7811;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;7;-635.1246,277.0959;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1043.934,286.9316;Inherit;True;20;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-787.1099,794.6152;Inherit;False;Property;_EegeWidth;EegeWidth;6;0;Create;True;0;0;0;False;0;False;0.4849537;0.2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2194.236,331.6552;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2467.198,432.1181;Inherit;False;Property;_Spread;Spread;9;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1502.649,198.8538;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch;26;-2289.705,194.2249;Inherit;False;Property;_MnueControl;MnueControl;8;0;Create;True;0;0;0;False;0;False;0;0;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
WireConnection;0;2;16;0
WireConnection;0;10;3;0
WireConnection;4;0;2;1
WireConnection;4;1;8;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;13;0;11;0
WireConnection;25;0;24;0
WireConnection;8;0;26;0
WireConnection;8;3;31;0
WireConnection;3;0;1;4
WireConnection;3;1;7;0
WireConnection;20;0;32;0
WireConnection;15;0;13;0
WireConnection;16;0;1;0
WireConnection;16;1;18;0
WireConnection;16;2;15;0
WireConnection;9;0;22;0
WireConnection;9;1;10;0
WireConnection;7;1;22;0
WireConnection;31;0;30;0
WireConnection;32;0;4;0
WireConnection;32;1;30;0
WireConnection;26;1;25;0
WireConnection;26;0;5;0
ASEEND*/
//CHKSM=09A75C90A45880DAC602D2F6AA1A3E40D968022A