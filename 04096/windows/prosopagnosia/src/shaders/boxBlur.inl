#version 150 core
#extension GL_EXT_gpu_shader4 : enable
#extension GL_EXT_texture_array : enable
#define pi 3.141592653589793238462643383279
precision highp float;
precision highp int;
out vec4 out_data;

//------------------------------------------------------------------------------------------
// Box blur of arbitrary size (u_scale) using summed area table (u_tex0).
//------------------------------------------------------------------------------------------
uniform sampler2D u_tex0;
uniform int u_scale;
void main()
{
	ivec2 tSize = ivec2(textureSize2D(u_tex0, 0));
	ivec2 p = ivec2(gl_FragCoord.xy);
	ivec4 uv = ivec4( min(p + u_scale, tSize-ivec2(1)),
	                  max(p - u_scale, ivec2(0)) );
	ivec2 area = max(uv.xy - uv.zw, ivec2(1));
	out_data =
	( texelFetch( u_tex0, uv.xy, 0 )
	- texelFetch( u_tex0, uv.xw, 0 )
	- texelFetch( u_tex0, uv.zy, 0 )
	+ texelFetch( u_tex0, uv.zw, 0 ) ) / (area.x * area.y);
}