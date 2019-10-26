#version 150 core
#extension GL_EXT_gpu_shader4 : enable
#extension GL_EXT_texture_array : enable
#define pi 3.141592653589793238462643383279
precision highp float;
precision highp int;
out vec4 out_data;

//------------------------------------------------------------------------------------------
// Multiscale Turing patterns.
// References : 
//		* Cyclic Symmetric Multi-Scale Turing Patterns by Jonathan McCabe
//		* Multi-Scale Turing Patterns by Jason Rampe (Softology's Blog)
//------------------------------------------------------------------------------------------
out vec4 out_aux;
uniform sampler2DArray u_tex0;
uniform sampler2D u_tex1;
uniform int u_t;
void main()
{
	float delta[7] = float[7](0.0025, 0.0045, 0.0065, 0.0085, 0.015, 0.0125, 0.0145);
	int symmetry[7] = int[7](4,2,2,2,3,3,3);
	int scale[7] = int[7](0,2,3,4,5,6,8);
	vec2 size = textureSize(u_tex1, 0);
	vec2 p = gl_FragCoord.xy - size*0.5;
	float min = 65535.0;
	int bestIndex = 6;
	vec2 best;
	for(int k=0; k<7; k++)
	{
		vec2 tmp = vec2(0.0);
		int nrot = symmetry[k];
		int idx = scale[k];
		for(int i=0; i<nrot; i++)
		{
			float theta = pi * i * 2.0 / nrot;
			vec2 rot = vec2(cos(theta), sin(theta));
			vec2 r = vec2(p.x*rot.x-p.y*rot.y, dot(rot, p.yx))/ size + 0.5;
			tmp.x += texture2DArray(u_tex0, vec3(r, idx  ), 0).r;
			tmp.y += texture2DArray(u_tex0, vec3(r, idx+1), 0).r;
		}
		tmp /= nrot;
		float delta = abs(tmp.x - tmp.y);
		if(delta < min)
		{
			min  = delta;
			best = tmp;
			bestIndex = k;
		}
	}
	out_aux = out_data = vec4(texelFetch(u_tex1, ivec2(gl_FragCoord.xy), 0).r + ((2.0 * step(best.x, best.y)) - 1.0) * delta[bestIndex] * (u_t * 50.0 / 1000.0));
}
