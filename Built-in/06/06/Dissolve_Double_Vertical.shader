// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dissolve_Double Vertical"
{
	Properties
	{
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_ChangeAmount("ChangeAmount", Range( 0 , 1)) = 0.5
		_EdgeColorEmiss("EdgeColorEmiss", Float) = 1
		_EegeWidth("EegeWidth", Range( 0 , 2)) = 0.1
		_EdgeColor("EdgeColor", Color) = (0,0,0,0)
		_MainColor("MainColor", Color) = (0,0,0,0)
		_MainColorAdjust("MainColorAdjust", Float) = 5
		_Noise("Noise", 2D) = "white" {}
		_NoiseSpeed("NoiseSpeed", Float) = 0
		_Spread("Spread", Range( 0 , 1)) = 0
		_ObjectScale("ObjectScale", Float) = 2
		[Toggle(_MNUECONTROL_ON)] _MnueControl("MnueControl", Float) = 1
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
			float3 worldPos;
			float2 uv_texcoord;
		};

		uniform float4 _MainColor;
		uniform float _MainColorAdjust;
		uniform float4 _EdgeColor;
		uniform float _EdgeColorEmiss;
		uniform float _ObjectScale;
		uniform float _ChangeAmount;
		uniform float _Spread;
		uniform sampler2D _Noise;
		uniform float _NoiseSpeed;
		uniform float4 _Noise_ST;
		uniform float _EegeWidth;
		uniform float _Cutoff = 0.5;

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float3 ase_worldPos = i.worldPos;
			float3 objToWorld48 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float clampResult52 = clamp( ( ( ase_worldPos.y - objToWorld48.y ) / _ObjectScale ) , 0.0 , 1.0 );
			float mulTime24 = _Time.y * 0.2;
			#ifdef _MNUECONTROL_ON
				float staticSwitch26 = _ChangeAmount;
			#else
				float staticSwitch26 = frac( mulTime24 );
			#endif
			float Gradient20 = ( ( ( ( 1.0 - clampResult52 ) - (-_Spread + (staticSwitch26 - 0.0) * (1.0 - -_Spread) / (1.0 - 0.0)) ) / _Spread ) * 2.0 );
			float4 temp_cast_0 = (Gradient20).xxxx;
			float2 temp_cast_1 = (_NoiseSpeed).xx;
			float2 uv_Noise = i.uv_texcoord * _Noise_ST.xy + _Noise_ST.zw;
			float2 panner34 = ( 1.0 * _Time.y * temp_cast_1 + uv_Noise);
			float4 Noise37 = tex2D( _Noise, panner34 );
			float4 temp_output_40_0 = ( temp_cast_0 - Noise37 );
			float4 temp_cast_2 = (0.5).xxxx;
			float clampResult15 = clamp( ( 1.0 - ( distance( temp_output_40_0 , temp_cast_2 ) / _EegeWidth ) ) , 0.0 , 1.0 );
			float4 lerpResult16 = lerp( ( _MainColor * _MainColorAdjust ) , ( _EdgeColor * _EdgeColorEmiss ) , clampResult15);
			o.Emission = lerpResult16.rgb;
			o.Alpha = 1;
			float4 temp_cast_4 = (Gradient20).xxxx;
			clip( step( float4( 0.5,0,0,0 ) , temp_output_40_0 ).r - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;21;-3032.986,-373.5091;Inherit;False;1712.631;875.9627;Graditent;19;41;32;42;24;31;20;5;30;25;4;8;26;46;48;49;52;54;58;59;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;43;-2605.157,531.5185;Inherit;False;1252.527;368;Noise;5;34;36;33;35;37;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;11;-445.6587,566.5526;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-307.5998,-2.67989;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;16;25.67978,-108.3252;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-575.6548,203.1507;Inherit;False;Property;_EdgeColorEmiss;EdgeColorEmiss;2;0;Create;True;0;0;0;False;0;False;1;15;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;7;-783.1877,262.0756;Inherit;True;2;0;COLOR;0.5,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;10;-1125.285,551.4345;Inherit;False;Constant;_Float0;Float 0;4;0;Create;True;0;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;12;-878.013,760.8701;Inherit;False;Property;_EegeWidth;EegeWidth;3;0;Create;True;0;0;0;False;0;False;0.1;0.861;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;9;-801.9957,505.6754;Inherit;True;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;13;-184.668,642.4112;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;15;69.72806,584.015;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;22;-1311.102,272.289;Inherit;False;20;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;40;-1075.967,307.69;Inherit;True;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.PannerNode;34;-2235.157,650.5185;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;36;-2525.157,783.5185;Inherit;False;Property;_NoiseSpeed;NoiseSpeed;8;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-2555.157,623.5185;Inherit;False;0;33;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;392.058,-14.42591;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Dissolve_Double Vertical;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;;0;False;;False;0;False;;0;False;;False;0;Custom;0.5;True;True;0;True;Opaque;;AlphaTest;All;12;all;True;True;True;True;0;False;;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;2;15;10;25;False;0.5;True;0;0;False;;0;False;;0;0;False;;0;False;;0;False;;0;False;;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;True;Relative;0;;0;-1;-1;-1;0;False;0;0;False;;-1;0;False;;0;0;0;False;0.1;False;;0;False;;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.ColorNode;17;-696.3425,10.1132;Inherit;False;Property;_EdgeColor;EdgeColor;4;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.2659306,0.489607,0.6792453,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;33;-1965.277,649.3538;Inherit;True;Property;_Noise;Noise;7;0;Create;True;0;0;0;False;0;False;-1;d14593d4466be7e44b9d537374a698ed;ac25e194d6b643743a7a33bbd0b359b8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StaticSwitch;26;-2606.199,86.34423;Inherit;False;Property;_MnueControl;MnueControl;11;0;Create;True;0;0;0;False;0;False;0;1;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;25;-2741.644,55.96036;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;30;-2833.757,296.8969;Inherit;False;Property;_Spread;Spread;9;0;Create;True;0;0;0;False;0;False;0;0.28;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2951.231,160.1882;Inherit;False;Property;_ChangeAmount;ChangeAmount;1;0;Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;20;-1527.689,67.72713;Inherit;True;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;42;-1822.706,291.8198;Inherit;False;Constant;_Float1;Float 1;11;0;Create;True;0;0;0;False;0;False;2;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;41;-1667.208,163.4251;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;38;-1312.967,403.8686;Inherit;False;37;Noise;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-1613.186,662.7403;Inherit;True;Noise;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TFHCRemapNode;8;-2344.22,39.88105;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;-1;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;31;-2533.365,211.9871;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;4;-2052.678,-86.48006;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-578.2313,-210.9897;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0.4571022;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;57;-784.0525,-85.01113;Inherit;False;Property;_MainColorAdjust;MainColorAdjust;6;0;Create;True;0;0;0;False;0;False;5;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-2742.269,-211.1034;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;52;-2382.173,-152.602;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;44;-966.7094,-294.9283;Inherit;False;Property;_MainColor;MainColor;5;0;Create;True;0;0;0;False;0;False;0,0,0,0;0.009567461,0.1431314,0.40566,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;54;-2720.069,-54.30851;Inherit;False;Property;_ObjectScale;ObjectScale;10;0;Create;True;0;0;0;False;0;False;2;3.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;46;-3029.176,-337.1907;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleTimeNode;24;-2925.15,45.31733;Inherit;False;1;0;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;32;-1817.392,122.1212;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;58;-2210.687,-121.1132;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;59;-2536.987,-149.6633;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;48;-3032.188,-183.3353;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
WireConnection;11;0;9;0
WireConnection;11;1;12;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;16;0;45;0
WireConnection;16;1;18;0
WireConnection;16;2;15;0
WireConnection;7;1;40;0
WireConnection;9;0;40;0
WireConnection;9;1;10;0
WireConnection;13;0;11;0
WireConnection;15;0;13;0
WireConnection;40;0;22;0
WireConnection;40;1;38;0
WireConnection;34;0;35;0
WireConnection;34;2;36;0
WireConnection;0;2;16;0
WireConnection;0;10;7;0
WireConnection;33;1;34;0
WireConnection;26;1;25;0
WireConnection;26;0;5;0
WireConnection;25;0;24;0
WireConnection;20;0;41;0
WireConnection;41;0;32;0
WireConnection;41;1;42;0
WireConnection;37;0;33;0
WireConnection;8;0;26;0
WireConnection;8;3;31;0
WireConnection;31;0;30;0
WireConnection;4;0;58;0
WireConnection;4;1;8;0
WireConnection;45;0;44;0
WireConnection;45;1;57;0
WireConnection;49;0;46;2
WireConnection;49;1;48;2
WireConnection;52;0;59;0
WireConnection;32;0;4;0
WireConnection;32;1;30;0
WireConnection;58;0;52;0
WireConnection;59;0;49;0
WireConnection;59;1;54;0
ASEEND*/
//CHKSM=35D61D84EB8DBE979C4A4ED0551410E57F0C3AB6