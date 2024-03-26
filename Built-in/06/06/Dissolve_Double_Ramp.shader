// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Double_Ramp"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_MainTex("MainTex", 2D) = "white" {}
		_Gradient("Gradient", 2D) = "white" {}
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.4647599
		_EdgeColorEmiss("EdgeColorEmiss", Float) = 10
		_ColorAdjust("ColorAdjust", Float) = 1
		_EegeWidth("EegeWidth", Range( 0 , 2)) = 2
		_Spread("Spread", Range( 0 , 1)) = 0.6494801
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Float) = 0
		[Toggle(_MNUECONTROL_ON)] _MnueControl("MnueControl", Float) = 1
		_RampTex("RampTex", 2D) = "white" {}
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
		uniform float _ColorAdjust;
		uniform sampler2D _RampTex;
		uniform sampler2D _Gradient;
		uniform float4 _Gradient_ST;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		uniform float _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _EegeWidth;
		uniform float _EdgeColorEmiss;
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
			float Gradient20 = ( ( ( tex2D( _Gradient, uv_Gradient ).r - (-_Spread + (staticSwitch26 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float4 temp_cast_0 = (Gradient20).xxxx;
			float2 temp_cast_1 = (_NoiseSpeed).xx;
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner34 = ( 1.0 * _Time.y * temp_cast_1 + uv_Noise);
			float4 Noise37 = tex2D( _Noise, panner34 );
			float4 temp_output_40_0 = ( temp_cast_0 - Noise37 );
			float4 temp_cast_2 = (0.5).xxxx;
			float clampResult15 = clamp( ( 1.0 - ( distance( temp_output_40_0 , temp_cast_2 ) / _EegeWidth ) ) , 0.0 , 1.0 );
			float2 appendResult44 = (float2(( 1.0 - clampResult15 ) , 0.5));
			float4 RampColor46 = tex2D( _RampTex, appendResult44 );
			float4 lerpResult16 = lerp( tex2DNode1 , ( ( tex2DNode1 * _ColorAdjust ) * RampColor46 * _EdgeColorEmiss ) , clampResult15);
			o.Emission = lerpResult16.rgb;
			o.Alpha = 1;
			float4 temp_cast_4 = (Gradient20).xxxx;
			clip( ( tex2DNode1.a * step( float4( 0.5,0,0,0 ) , temp_output_40_0 ) ).r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;43;-3282.442,640.5586;Inherit;False;1252.527;368;Noise;5;34;36;37;33;35;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;21;-3367.031,-38.9109;Inherit;False;1587.56;644.8994;Graditent;13;20;32;31;30;25;24;4;8;5;26;2;41;42;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;392.058,-14.42591;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve_Double_Ramp;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.SamplerNode;2;-3007.831,6.245005;Inherit;True;Property;_Gradient;Gradient;2;0;Create;True;0;0;0;False;0;False;-1;b28a1c18dc150f14799e3197260c4c2a;b28a1c18dc150f14799e3197260c4c2a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;26;-3002.07,245.7719;Inherit;False;Property;_MnueControl;MnueControl;10;0;Create;True;0;0;0;False;0;False;0;1;1;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-2693.296,197.7489;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-2441.263,75.007;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;25;-3137.515,215.3881;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-3347.102,319.6157;Inherit;False;Property;_ChangeAmount;ChangeAmount;3;0;Create;True;0;0;0;False;0;False;0.4647599;0.261;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1971.791,243.2311;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2900.62,371.4146;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-900.8252,277.4771;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StepOpNode;7;-1192.029,247.9776;Inherit;True;2;0;COLOR;0.5,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-1286.855,746.7721;Inherit;False;Property;_EegeWidth;EegeWidth;6;0;Create;True;0;0;0;False;0;False;2;1.12;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;9;-1210.837,491.5774;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode;24;-3321.021,204.7451;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1719.943,258.191;Inherit;False;20;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1721.808,388.592;Inherit;False;37;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-1484.808,293.592;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;34;-2912.442,759.5586;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-3202.442,892.5586;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-2262.912,691.2264;Inherit;False;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;33;-2640.441,690.5586;Inherit;True;Property;_Noise;Noise;8;0;Create;True;0;0;0;False;0;False;-1;d14593d4466be7e44b9d537374a698ed;d14593d4466be7e44b9d537374a698ed;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-3232.442,732.5586;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;42;-2266.809,467.3236;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-2258.895,245.6251;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-2090.642,371.0815;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;-451.3377,580.4016;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;44;-65.16792,583.1653;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0.5;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;49;-257.5593,586.5546;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-3236.158,469.3852;Inherit;False;Property;_Spread;Spread;7;0;Create;True;0;0;0;False;0;False;0.6494801;0.513;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1527.126,540.3365;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;45;97.2493,562.9229;Inherit;True;Property;_RampTex;RampTex;11;0;Create;True;0;0;0;False;0;False;-1;17dddefa3e2107740bb8a1e7e27d85a0;8f431112e33b0b0428ce9f1899536042;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;46;556.981,574.1471;Inherit;False;RampColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;47;-980.7662,49.64411;Inherit;False;46;RampColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;16;-59.15743,-104.0806;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;1;-1552.371,-288.1134;Inherit;True;Property;_MainTex;MainTex;1;0;Create;True;0;0;0;False;0;False;-1;0b7aca28296b0ed4e99f55846348e10e;0b7aca28296b0ed4e99f55846348e10e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;19;-979.2974,143.5527;Inherit;False;Property;_EdgeColorEmiss;EdgeColorEmiss;4;0;Create;True;0;0;0;False;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-932.5012,548.4546;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;-637.9379,563.5398;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-427.4907,-52.99854;Inherit;True;3;3;0;COLOR;1,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;58;-682.9761,-112.859;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-934.054,-26.05511;Inherit;False;Property;_ColorAdjust;ColorAdjust;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
WireConnection;0;2;16;0
WireConnection;0;10;3;0
WireConnection;26;1;25;0
WireConnection;26;0;5;0
WireConnection;8;0;26;0
WireConnection;8;3;31;0
WireConnection;4;0;2;1
WireConnection;4;1;8;0
WireConnection;25;0;24;0
WireConnection;20;0;41;0
WireConnection;31;0;30;0
WireConnection;3;0;1;4
WireConnection;3;1;7;0
WireConnection;7;1;40;0
WireConnection;9;0;40;0
WireConnection;9;1;10;0
WireConnection;40;0;22;0
WireConnection;40;1;38;0
WireConnection;34;0;35;0
WireConnection;34;2;36;0
WireConnection;37;0;33;0
WireConnection;33;1;34;0
WireConnection;32;0;4;0
WireConnection;32;1;30;0
WireConnection;41;0;32;0
WireConnection;41;1;42;0
WireConnection;15;0;13;0
WireConnection;44;0;49;0
WireConnection;49;0;15;0
WireConnection;45;1;44;0
WireConnection;46;0;45;0
WireConnection;16;0;1;0
WireConnection;16;1;18;0
WireConnection;16;2;15;0
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;13;0;11;0
WireConnection;18;0;58;0
WireConnection;18;1;47;0
WireConnection;18;2;19;0
WireConnection;58;0;1;0
WireConnection;58;1;57;0
ASEEND*/
//CHKSM=F738A6D5E4A1BE542AED909A66F9DA0129F85035