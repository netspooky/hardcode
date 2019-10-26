#if 0

char DirBlurPS[] =
{
"struct VS_OUTPUT"
"{"
"	float4 vPosition            : POSITION;"
"	float2 vTexCoord0           : TEXCOORD0;"
"};"
""
"float4 deltapos;"
"sampler blursampler  : register( s0 ); "
""
"float4 main(in VS_OUTPUT input) : COLOR"
"{"
"   const float scale[7] = "
"	{"
"		0.070159327, 0.131074879, 0.190712824, 0.216105941, 0.190712824, 0.131074879, 0.070159327"
"   };"  
"	float4 output = tex2D(blursampler, input.vTexCoord0);"
"	float luminance = max( output.r, max( output.g, output.b ) );"
"	if( luminance < deltapos.z )"
"	{"
"		output = float4( 0.0f, 0.0f, 0.0f, 1.0f );"
"		return output;"
"	}"
"	else"
"	{"
"		float4 output = float4(0,0,0,0);"
"		int i;"
"		for (i=-3; i <= 3; i++)" 
"		{"
"			output += tex2D(blursampler, input.vTexCoord0 + i*deltapos.xy) * scale[i+3];"
"		}"
"		return output*deltapos.w;"
"	}"
"}"
};

#endif

const DWORD DirBlurPS[] =
{
    0xffff0201, 0x05000051, 0xa00f0001, 0xc0400000, 0xc0000000, 0x3e06387e, 
    0x3d8fafb1, 0x05000051, 0xa00f0002, 0x3e434a39, 0x3e5d4ae0, 0x40000000, 
    0x40400000, 0x05000051, 0xa00f0003, 0x00000000, 0x00000000, 0x00000000, 
    0x3f800000, 0x0200001f, 0x80000000, 0xb0030000, 0x0200001f, 0x90000000, 
    0xa00f0800, 0x02000001, 0x80030000, 0xa0e40001, 0x04000004, 0x80030001, 
    0xa0e40000, 0x80550000, 0xb0e40000, 0x04000004, 0x80030000, 0xa0e40000, 
    0x80000000, 0xb0e40000, 0x03000002, 0x80030002, 0xb0e40000, 0xa1e40000, 
    0x03000002, 0x80030003, 0xb0e40000, 0xa0e40000, 0x02000001, 0x80030004, 
    0xa0e40000, 0x04000004, 0x80030005, 0x80e40004, 0xa0aa0002, 0xb0e40000, 
    0x04000004, 0x80030004, 0x80e40004, 0xa0ff0002, 0xb0e40000, 0x03000042, 
    0x800f0001, 0x80e40001, 0xa0e40800, 0x03000042, 0x800f0000, 0x80e40000, 
    0xa0e40800, 0x03000042, 0x800f0002, 0x80e40002, 0xa0e40800, 0x03000042, 
    0x800f0006, 0xb0e40000, 0xa0e40800, 0x03000042, 0x800f0003, 0x80e40003, 
    0xa0e40800, 0x03000042, 0x800f0005, 0x80e40005, 0xa0e40800, 0x03000042, 
    0x800f0004, 0x80e40004, 0xa0e40800, 0x03000005, 0x800f0001, 0x80e40001, 
    0xa0aa0001, 0x04000004, 0x800f0000, 0x80e40000, 0xa0ff0001, 0x80e40001, 
    0x04000004, 0x800f0000, 0x80e40002, 0xa0000002, 0x80e40000, 0x04000004, 
    0x800f0000, 0x80e40006, 0xa0550002, 0x80e40000, 0x04000004, 0x800f0000, 
    0x80e40003, 0xa0000002, 0x80e40000, 0x04000004, 0x800f0000, 0x80e40005, 
    0xa0aa0001, 0x80e40000, 0x04000004, 0x800f0000, 0x80e40004, 0xa0ff0001, 
    0x80e40000, 0x03000005, 0x800f0000, 0x80e40000, 0xa0ff0000, 0x0300000b, 
    0x80080001, 0x80550006, 0x80aa0006, 0x0300000b, 0x80080002, 0x80000006, 
    0x80ff0001, 0x03000002, 0x80080001, 0x80ff0002, 0xa1aa0000, 0x04000058, 
    0x800f0000, 0x80ff0001, 0x80e40000, 0xa0e40003, 0x02000001, 0x800f0800, 
    0x80e40000, 0x0000ffff
};