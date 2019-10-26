// example

struct INPUT_PS
{
	float4 tpos : POSITION;
	float3 camdir : TEXCOORD0;
	float3 campos : TEXCOORD1;
//	float3 normal : TEXCOORD4;
	float2 coords : TEXCOORD2;
	float3 wpos : TEXCOORD3;
};

float4 pa(INPUT_PS):COLOR4 
{
return 1;
};