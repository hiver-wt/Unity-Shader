// Made with Amplify Shader Editor v1.9.1.5
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Gem"
{
	Properties
	{
		_Ramp("Ramp", 2D) = "white" {}
		_Color1("Color1", Color) = (0.7735849,0.05473477,0.05473477,0)
		_ReflectTex("ReflectTex", CUBE) = "white" {}
		_RefractTex("RefractTex", CUBE) = "white" {}
		_RefractIntensity("RefractIntensity", Float) = 0
		_ReflactIntensity("ReflactIntensity", Float) = 2
		_RimPower("RimPower", Float) = 2
		_RimScale("RimScale", Float) = 1
		_RimBias("RimBias", Float) = 0
		_RimColor("RimColor", Color) = (0,0,0,0)

	}
	
	SubShader
	{
		
		
		Tags { "RenderType"="Opaque" "Queue"="Geometry" }
	LOD 100

		/*ase_all_modules*/ //��ȫ����pass��״̬
		
		
		Pass
		{
			Name "FirstPass"
			Blend Off
			ZWrite On
			ZTest LEqual
			Cull Front
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _Ramp;
			uniform float4 _Ramp_ST;
			uniform float4 _Color1;
			uniform samplerCUBE _RefractTex;
			uniform samplerCUBE _ReflectTex;
			uniform float _RefractIntensity;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_Ramp = i.ase_texcoord1.xyz.xy * _Ramp_ST.xy + _Ramp_ST.zw;
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 worldRefl15 = reflect( -ase_worldViewDir, float3( dot( tanToWorld0, ase_worldNormal ), dot( tanToWorld1, ase_worldNormal ), dot( tanToWorld2, ase_worldNormal ) ) );
				float4 texCUBENode8 = texCUBE( _RefractTex, worldRefl15 );
				float4 texCUBENode7 = texCUBE( _ReflectTex, worldRefl15 );
				float4 temp_output_47_0 = ( ( tex2D( _Ramp, uv_Ramp ) * _Color1 ) * ( texCUBENode8 + ( texCUBENode8 * ( texCUBENode7 * _RefractIntensity ) ) ) );
				
				
				finalColor = temp_output_47_0;
				return finalColor;
			}
			ENDCG
		}
		
		Pass
		{
			Name "SecondPass"
			Blend One One
			ZWrite On
			ZTest LEqual
			Cull Back
			CGPROGRAM

			

			#ifndef UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX
			//only defining to not throw compilation error over Unity 5.5
			#define UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input)
			#endif
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_instancing
			#include "UnityCG.cginc"
			#define ASE_NEEDS_FRAG_WORLD_POSITION


			struct appdata
			{
				float4 vertex : POSITION;
				float4 color : COLOR;
				float4 ase_texcoord : TEXCOORD0;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			
			struct v2f
			{
				float4 vertex : SV_POSITION;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 worldPos : TEXCOORD0;
				#endif
				float4 ase_texcoord1 : TEXCOORD1;
				float4 ase_texcoord2 : TEXCOORD2;
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			uniform sampler2D _Ramp;
			uniform float4 _Ramp_ST;
			uniform float4 _Color1;
			uniform samplerCUBE _RefractTex;
			uniform samplerCUBE _ReflectTex;
			uniform float _RefractIntensity;
			uniform float _ReflactIntensity;
			uniform float _RimPower;
			uniform float _RimScale;
			uniform float _RimBias;
			uniform float4 _RimColor;

			
			v2f vert ( appdata v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				UNITY_TRANSFER_INSTANCE_ID(v, o);

				float3 ase_worldNormal = UnityObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord2.xyz = ase_worldNormal;
				float3 ase_worldTangent = UnityObjectToWorldDir(v.ase_tangent);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float ase_vertexTangentSign = v.ase_tangent.w * ( unity_WorldTransformParams.w >= 0.0 ? 1.0 : -1.0 );
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord4.xyz = ase_worldBitangent;
				
				o.ase_texcoord1.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord1.w = 0;
				o.ase_texcoord2.w = 0;
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				float3 vertexValue = float3(0, 0, 0);
				#if ASE_ABSOLUTE_VERTEX_POS
				vertexValue = v.vertex.xyz;
				#endif
				vertexValue = vertexValue;
				#if ASE_ABSOLUTE_VERTEX_POS
				v.vertex.xyz = vertexValue;
				#else
				v.vertex.xyz += vertexValue;
				#endif
				o.vertex = UnityObjectToClipPos(v.vertex);

				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(i);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
				fixed4 finalColor;
				#ifdef ASE_NEEDS_FRAG_WORLD_POSITION
				float3 WorldPosition = i.worldPos;
				#endif
				float2 uv_Ramp = i.ase_texcoord1.xyz.xy * _Ramp_ST.xy + _Ramp_ST.zw;
				float3 ase_worldNormal = i.ase_texcoord2.xyz;
				float3 ase_worldTangent = i.ase_texcoord3.xyz;
				float3 ase_worldBitangent = i.ase_texcoord4.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 ase_worldViewDir = UnityWorldSpaceViewDir(WorldPosition);
				ase_worldViewDir = normalize(ase_worldViewDir);
				float3 worldRefl15 = reflect( -ase_worldViewDir, float3( dot( tanToWorld0, ase_worldNormal ), dot( tanToWorld1, ase_worldNormal ), dot( tanToWorld2, ase_worldNormal ) ) );
				float4 texCUBENode8 = texCUBE( _RefractTex, worldRefl15 );
				float4 texCUBENode7 = texCUBE( _ReflectTex, worldRefl15 );
				float4 temp_output_47_0 = ( ( tex2D( _Ramp, uv_Ramp ) * _Color1 ) * ( texCUBENode8 + ( texCUBENode8 * ( texCUBENode7 * _RefractIntensity ) ) ) );
				float dotResult26 = dot( ase_worldNormal , ase_worldViewDir );
				float clampResult28 = clamp( dotResult26 , 0.0 , 1.0 );
				float saferPower30 = abs( ( 1.0 - clampResult28 ) );
				float temp_output_30_0 = pow( saferPower30 , _RimPower );
				float4 temp_output_20_0 = ( temp_output_47_0 + ( texCUBENode7 * _ReflactIntensity * temp_output_30_0 ) );
				
				
				finalColor = ( temp_output_20_0 + ( temp_output_20_0 * ( ( ( temp_output_30_0 * _RimScale ) + _RimBias ) * _RimColor ) ) );
				return finalColor;
			}
			ENDCG
		}
		
	}
	CustomEditor "ASEMaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19105
Node;AmplifyShaderEditor.CommentaryNode;43;-1778.103,-314.7723;Inherit;False;212;203;传入的应该是法线图的数据;1;15;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;42;-2007.878,-310.7456;Inherit;False;202;198;错误但好看;1;41;;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;16;-2877.511,-1018.143;Inherit;False;846.7998;392.4001;Reflection;5;17;12;10;11;9;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;20;49.44708,103.7294;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;22;-217.8147,204.1052;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;21;-516.5508,232.5753;Inherit;False;Property;_ReflactIntensity;ReflactIntensity;5;0;Create;True;0;0;0;False;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;23;-1854.672,207.3427;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;24;-1814.672,401.3425;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DotProductOpNode;26;-1471.672,316.3425;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;29;-1099.671,323.3425;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;28;-1310.148,332.4237;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;31;-1040.412,510.4624;Inherit;False;Property;_RimPower;RimPower;6;0;Create;True;0;0;0;False;0;False;2;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;30;-846.4327,367.3763;Inherit;False;True;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;32;-656.4114,419.463;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;33;-836.4115,518.4623;Inherit;False;Property;_RimScale;RimScale;7;0;Create;True;0;0;0;False;0;False;1;20;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-433.4106,465.4629;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FresnelNode;36;-796.052,666.8267;Inherit;False;Standard;WorldNormal;ViewDir;False;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;37;404.6559,121.4771;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;195.9037,208.5341;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-603.4111,555.4623;Inherit;False;Property;_RimBias;RimBias;8;0;Create;True;0;0;0;False;0;False;0;0.2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;39;-194.6348,457.0021;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;40;-402.4108,625.0755;Inherit;False;Property;_RimColor;RimColor;9;0;Create;True;0;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ReflectOpNode;9;-2473.711,-875.0431;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NegateNode;11;-2617.412,-909.743;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;10;-2816.711,-968.1431;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldNormalVector;12;-2827.511,-811.743;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldReflectionVector;17;-2252.393,-881.0261;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;8;-1385.635,-318.4055;Inherit;True;Property;_RefractTex;RefractTex;3;0;Create;True;0;0;0;False;0;False;-1;None;27ea2da27bb70d943b8e70557f6e4fb5;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;7;-1474.408,-9.641356;Inherit;True;Property;_ReflectTex;ReflectTex;2;0;Create;True;0;0;0;False;0;False;-1;None;336caf1d31311f1459cd7ed279013235;True;0;False;white;LockedToCube;False;Object;-1;Auto;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldNormalVector;41;-1996.878,-269.7456;Inherit;False;False;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldReflectionVector;15;-1764.103,-268.7723;Inherit;False;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;196.8824,-426.2076;Float;False;True;-1;2;ASEMaterialInspector;100;12;Gem;d926d2541dcd65b4ab4ef1c1b67a079c;True;FirstPass;0;0;FirstPass;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;False;0;True;True;0;1;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;True;True;1;False;;False;False;False;False;False;False;False;False;False;False;True;True;0;False;;True;0;False;;False;False;False;False;0;;0;0;Standard;1;Vertex Position,InvertActionOnDeselection;1;0;0;2;True;True;False;;False;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;47;-306.2542,-411.3615;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;46;-422.5632,-254.839;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;45;-631.244,-178.4004;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;44;-821.2025,-122.6495;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;19;-976.4988,-10.34239;Inherit;False;Property;_RefractIntensity;RefractIntensity;4;0;Create;True;0;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;48;-1309.447,-785.1491;Inherit;True;Property;_Ramp;Ramp;0;0;Create;True;0;0;0;False;0;False;-1;7fb9754db2e9dfc4491a0b44e202929a;7fb9754db2e9dfc4491a0b44e202929a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-1364.641,-536.9767;Inherit;False;Property;_Color1;Color1;1;0;Create;True;0;0;0;False;0;False;0.7735849,0.05473477,0.05473477,0;1,1,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-963.2258,-630.522;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;49;-1574.795,-766.079;Inherit;False;0;48;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;603.4235,126.9106;Float;False;False;-1;2;ASEMaterialInspector;100;12;New Amplify Shader;d926d2541dcd65b4ab4ef1c1b67a079c;True;SecondPass;0;1;SecondPass;2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;False;False;0;False;True;4;1;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;True;True;0;False;;True;0;False;;False;False;False;False;0;;0;0;Standard;0;False;0
WireConnection;20;0;47;0
WireConnection;20;1;22;0
WireConnection;22;0;7;0
WireConnection;22;1;21;0
WireConnection;22;2;30;0
WireConnection;26;0;23;0
WireConnection;26;1;24;0
WireConnection;29;0;28;0
WireConnection;28;0;26;0
WireConnection;30;0;29;0
WireConnection;30;1;31;0
WireConnection;32;0;30;0
WireConnection;32;1;33;0
WireConnection;34;0;32;0
WireConnection;34;1;35;0
WireConnection;37;0;20;0
WireConnection;37;1;38;0
WireConnection;38;0;20;0
WireConnection;38;1;39;0
WireConnection;39;0;34;0
WireConnection;39;1;40;0
WireConnection;9;0;11;0
WireConnection;9;1;12;0
WireConnection;11;0;10;0
WireConnection;8;1;15;0
WireConnection;7;1;15;0
WireConnection;15;0;41;0
WireConnection;3;0;47;0
WireConnection;47;0;50;0
WireConnection;47;1;46;0
WireConnection;46;0;8;0
WireConnection;46;1;45;0
WireConnection;45;0;8;0
WireConnection;45;1;44;0
WireConnection;44;0;7;0
WireConnection;44;1;19;0
WireConnection;48;1;49;0
WireConnection;50;0;48;0
WireConnection;50;1;5;0
WireConnection;4;0;37;0
ASEEND*/
//CHKSM=24AC1E3FB4401ECEA5FD9C5273592646C349C72A