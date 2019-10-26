#version 150 core
#extension GL_EXT_gpu_shader4 : enable
#extension GL_EXT_texture_array : enable
//[
precision highp float; precision highp int;
//]
#define pi 3.141592653589793238462643383279

out vec4 out_data;
out vec4 out_aux;

uniform sampler2D u_tex0;
uniform sampler2D u_tex1;

uniform sampler2DArray u_tex2;

uniform ivec2 u_s;
uniform int u_t;

//------------------------------------------------------------------------------------------
// IQ's noise fragment shader
//------------------------------------------------------------------------------------------
void out_0()
{
	int n = int(gl_FragCoord.x * 40.0 + gl_FragCoord.y * 6400.0);
	n = (n << 13) ^ n;
	out_aux = out_data = vec4(1.0 - float( (n * (n * n * 15731 + 789221) + 1376312589) & 0x7fffffff) / 1073741824.0);
}

//------------------------------------------------------------------------------------------
// Summed area table generation:
// This shader will be repeatedly applied (ping/pong) with an increasing delta at each pass.
// The number of passes is equal to the minimum value of the log base X of the image size. 
// X being the delta increase at each pass.
// Not that this procedure will be applied horizontally and vertically.
//------------------------------------------------------------------------------------------
void out_1()
{
	vec4 t[8];
	ivec2 coord = ivec2(gl_FragCoord.xy);
	for(int i=0; i<8; ++i)
	{
		t[i]  = texelFetch( u_tex0, coord, 0 );
		coord -= u_s;
		t[i] += texelFetch( u_tex0, coord, 0 );
		coord -= u_s;
	}
	t[0] += t[1]; t[2] += t[3];
	t[4] += t[5]; t[6] += t[7];
	t[0] += t[2]; t[4] += t[6];
	out_data = t[0] + t[4];
}

//------------------------------------------------------------------------------------------
// Box blur of arbitrary size (u_t) using summed area table (u_tex0).
//------------------------------------------------------------------------------------------
void out_2()
{
	ivec2 tSize = ivec2(textureSize2D(u_tex0, 0));
	ivec2 p = ivec2(gl_FragCoord.xy);
	ivec4 uv = ivec4( min(p + u_t, tSize-ivec2(1)),
	                  max(p - u_t, ivec2(0)) );
	ivec2 area = max(uv.xy - uv.zw, ivec2(1));
	out_data =
	( texelFetch( u_tex0, uv.xy, 0 )
	- texelFetch( u_tex0, uv.xw, 0 )
	- texelFetch( u_tex0, uv.zy, 0 )
	+ texelFetch( u_tex0, uv.zw, 0 ) ) / (area.x * area.y);
}

//------------------------------------------------------------------------------------------
// Multiscale Turing patterns.
// References : 
//		* Cyclic Symmetric Multi-Scale Turing Patterns by Jonathan McCabe
//		* Multi-Scale Turing Patterns by Jason Rampe (Softology's Blog)
//------------------------------------------------------------------------------------------
void out_3()
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
			tmp.x += texture2DArray(u_tex2, vec3(r, idx  ), 0).r;
			tmp.y += texture2DArray(u_tex2, vec3(r, idx+1), 0).r;
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

//------------------------------------------------------------------------------------------
// Find minimal and maximal value in a texture.
// The red channel may contain the minimal value. And the green one the max.
// This is a standard pyramidal algorithm. It starts at the most detailed level (w,h). And
// find the min/max in a 2x2 neighbourhood around current pixel. They are then written to
// the hald sized destination texture. This step is repeated until the destination texture
// is only 1 pixel wide.
//------------------------------------------------------------------------------------------
void out_3()
{
	ivec4 uv = ivec4(gl_FragCoord.xyxy)*2 + ivec4(0,0,1,1);
	uv.zw = clamp(uv.zw, ivec2(0), u_s);
	vec2 c0 = texelFetch (u_tex0, uv.xy, 0).rg;
	vec2 c1 = texelFetch (u_tex0, uv.zy, 0).rg;
	vec2 c2 = texelFetch (u_tex0, uv.xw, 0).rg;
	vec2 c3 = texelFetch (u_tex0, uv.zw, 0).rg;
	out_data = vec4(min(min(min(c0.r, c1.r),c2.r),c3.r),
	                max(max(max(c0.g, c1.g),c2.g),c3.g), 0.0, 0.0);
}

//------------------------------------------------------------------------------------------
// Scale texture betwin [-1, 1] using the min/max values stores in u_tex0.
//------------------------------------------------------------------------------------------
void out_4()
{
	vec2 bound = texelFetch (u_tex0, ivec2(0, 0), 0).rg;
	float val = texelFetch (u_tex1, ivec2(gl_FragCoord.xy), 0).r;
	out_aux = out_data = vec4((2.0 * (val - bound.x) / (bound.y - bound.x)) - 1.0);
}

//------------------------------------------------------------------------------------------
// Final shader
//------------------------------------------------------------------------------------------
void out_5()
{
	float t = 0.5 + texelFetch(u_tex0, ivec2(gl_FragCoord.xy), 0).r * 0.5;
	
	// Cubic interpolation
	vec3 q = vec3(0.786111, 0.05, 0.5);
	vec3 p = mix( mix( vec3( 0.575, 0.39, 0.29), q, t), mix( q, vec3(0.111111, 0.07, 0.94), t), t);
	
	// HSV to RGB conversion
	out_data = vec4( mix( vec3(1.0), clamp( (abs(fract(p.x + vec3(3.0,2.0,1.0) / 3.0) * 6.0 - 3.0) - 1.0), 0.0, 1.0), p.y) * p.z, 1.0 );
}
