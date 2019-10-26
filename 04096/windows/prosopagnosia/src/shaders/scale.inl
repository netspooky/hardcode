#version 150 core
#extension GL_EXT_gpu_shader4 : enable
#extension GL_EXT_texture_array : enable
#define pi 3.141592653589793238462643383279
precision highp float;
precision highp int;
out vec4 out_data;

//------------------------------------------------------------------------------------------
// Scale texture betwin [-1, 1] using the min/max values stores in u_tex0.
//------------------------------------------------------------------------------------------
out vec4 out_aux;
uniform sampler2D u_tex0;
uniform sampler2D u_tex1;
void main()
{
	vec2 bound = texelFetch (u_tex0, ivec2(0, 0), 0).rg;
	float val = texelFetch (u_tex1, ivec2(gl_FragCoord.xy), 0).r;
	out_aux = out_data = vec4((2.0 * (val - bound.x) / (bound.y - bound.x)) - 1.0);
}