#version 150 core
#extension GL_EXT_gpu_shader4 : enable
#extension GL_EXT_texture_array : enable
#define pi 3.141592653589793238462643383279
precision highp float;
precision highp int;
out vec4 out_data;

//------------------------------------------------------------------------------------------
// Find minimal and maximal value in a texture.
// The red channel may contain the minimal value. And the green one the max.
// This is a standard pyramidal algorithm. It starts at the most detailed level (w,h). And
// find the min/max in a 2x2 neighbourhood around current pixel. They are then written to
// the hald sized destination texture. This step is repeated until the destination texture
// is only 1 pixel wide.
//------------------------------------------------------------------------------------------
uniform sampler2D u_tex0;
uniform ivec2 u_size;
void main()
{
	ivec4 uv = ivec4(gl_FragCoord.xyxy)*2 + ivec4(0,0,1,1);
	uv.zw = clamp(uv.zw, ivec2(0), u_size);
	vec2 c0 = texelFetch (u_tex0, uv.xy, 0).rg;
	vec2 c1 = texelFetch (u_tex0, uv.zy, 0).rg;
	vec2 c2 = texelFetch (u_tex0, uv.xw, 0).rg;
	vec2 c3 = texelFetch (u_tex0, uv.zw, 0).rg;
	out_data = vec4(min(min(min(c0.r, c1.r),c2.r),c3.r),
	                max(max(max(c0.g, c1.g),c2.g),c3.g), 0.0, 0.0);
}