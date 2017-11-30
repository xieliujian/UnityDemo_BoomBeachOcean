Shader "BoomBeachOcean/Ocean"
{
	Properties
	{
		_SeaNormal ("SeaNormal", 2D) = "white" {}
		_LightSea ("LightSea", 2D) = "white" {}
		_DarkSea ("DarkSea", 2D) = "white" {}
		u_time ("u_time", float) = 83.36153
		u_uvFactor ("u_uvFactor", float) = 0.7735959
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }
			
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION0;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex : POSITION0;
				float2 uv : TEXCOORD0;
				float2 normaluv : TEXCOORD1;
				float v_result : TEXCOORD2;
				float v_reflectionPower : TEXCOORD3;
			};

			uniform sampler2D _SeaNormal;
			uniform sampler2D _LightSea;
			uniform sampler2D _DarkSea;
			uniform float u_time;
			uniform float u_uvFactor;

			float4 custommix(float4 x, float4 y, float a)
			{
				return (x * (1 - a) + y * a);
			}
			
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;

				float ystretch = 0.2;
				o.v_reflectionPower = clamp((1.0 - length(float2(v.vertex.x * 0.7 + (v.uv.x - 0.5) * 1.5, v.vertex.z * ystretch) - float2(0.0, ystretch))) * 3.0, 1.5, 4.0);
				
				float x = v.uv.x;
				float y = v.uv.y * u_uvFactor;
				float mov1 = y / 0.04 * 5.0 + u_time;
				float mov2 = x / 0.02 * 5.0;
				float c1 = abs((sin(mov1 + u_time) + mov2) * 0.5 - mov1 - mov2 + u_time);
				float c4 = 0.5 * sin(sqrt(x * x + y * y) * 150.0 - u_time) + 0.5;
				c1 = 0.5 * sin(c1) + 0.5;
				o.v_result = c4;

				o.normaluv = v.uv * 25.0;
				o.normaluv.x -= 0.01 * u_time * 0.5;
				o.normaluv.y += 0.02 * u_time * 0.5;

				o.normaluv = float2(o.normaluv.x + c1 * 0.01, (o.normaluv.y + c1 * 0.01) * u_uvFactor) * 1.5;

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 normalMapValue = tex2D(_SeaNormal, i.normaluv);
				float4 lightseacol = tex2D(_LightSea, i.uv);
				float4 darkseacol = tex2D(_DarkSea, i.uv);

				float4 fragcol = custommix(lightseacol, darkseacol, (normalMapValue.x * i.v_result) + (normalMapValue.y * (1.0 - i.v_result)));
				float4 fragspeccol = min(0.4, exp2(log2(((normalMapValue.z * i.v_result) + (normalMapValue.w * (1.0 - i.v_result))) * i.v_reflectionPower) * 5.0));
				fragcol += fragspeccol;

				return fragcol;
			}

			ENDCG
		}
	}
}
