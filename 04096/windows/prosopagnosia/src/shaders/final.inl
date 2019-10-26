#version 150 core
#extension GL_EXT_gpu_shader4 : enable
#extension GL_EXT_texture_array : enable
#define pi 3.141592653589793238462643383279
precision highp float;
precision highp int;

out vec4 out_data;
uniform sampler2D u_tex0;

void main()
{
	float t = 0.5 + texelFetch(u_tex0, ivec2(gl_FragCoord.xy), 0).r * 0.5;
	
	// Cubic interpolation
	vec3 q = vec3(0.786111, 0.05, 0.5);
	vec3 p = mix( mix( vec3( 0.575, 0.39, 0.29), q, t), mix( q, vec3(0.111111, 0.07, 0.94), t), t);
	
	// HSV to RGB conversion
	out_data = vec4( mix( vec3(1.0), clamp( (abs(fract(p.x + vec3(3.0,2.0,1.0) / 3.0) * 6.0 - 3.0) - 1.0), 0.0, 1.0), p.y) * p.z, 1.0 );
}
