#version 150 core
#extension GL_EXT_gpu_shader4 : enable
#extension GL_EXT_texture_array : enable
#define pi 3.141592653589793238462643383279
precision highp float;
precision highp int;
out vec4 out_data;

//------------------------------------------------------------------------------------------
// Summed area table generation:
// This shader will be repeatedly applied (ping/pong) with an increasing delta at each pass.
// The number of passes is equal to the minimum value of the log base X of the image size. 
// X being the delta increase at each pass.
// Note that this procedure will be applied horizontally and vertically.
//------------------------------------------------------------------------------------------
uniform sampler2D u_tex0;
uniform ivec2 u_delta;
void main()
{
	vec4 t[8];
	ivec2 coord = ivec2(gl_FragCoord.xy);
	for(int i=0; i<8; ++i)
	{
		t[i]  = texelFetch( u_tex0, coord, 0 );
		coord -= u_delta;
		t[i] += texelFetch( u_tex0, coord, 0 );
		coord -= u_delta;
	}
	t[0] += t[1]; t[2] += t[3];
	t[4] += t[5]; t[6] += t[7];
	t[0] += t[2]; t[4] += t[6];
	out_data = t[0] + t[4];
}