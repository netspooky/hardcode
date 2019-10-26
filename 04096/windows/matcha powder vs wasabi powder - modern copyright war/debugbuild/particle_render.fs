#version 330 compatibility

#include "common.s"

uniform float sample_count;

//in  vec3 vary_pos;
out vec4 color;

void main()
{
	vec3 vary_pos = gl_TexCoord[0].xyz;
	float nrm_insid = gl_TexCoord[0].w;
	float t = get_second(sample_count);
	float lit = step(0.85, softnoise(vec3(vary_pos.xz*0.2+vec2(t*0.02, 0.), 0.), 200.));
#if 0
	lit = step(0.75,sin(vary_pos.x*42.0)*sin(vary_pos.z*40.0));
	vec2 p = vary_pos.xz - vec2(0.5);
	vec2 lp = vec2(1.0)-p*p*64.0;
	lit = max(lp.x, 0.)*pow(0.12, 1.0-vary_pos.y);
#endif

	float vis = 1.0;
	//	color = vec4(nrm_insid);
	//	float vis = floor(nrm_insid*8.)/8. < gbl_1(t) ? 1.0 : 0.0;
		vis = nrm_insid > gbl_begin(t) ? 1.0 : 0.0;

//	color = vec4(0.3)+lit*0.8+narrow_wave(t)*0.01;
	color = vec4(1.0-vary_pos.z+0.3)*vis;
//	color = vec4(1.0);

#if 0
	color.xyz *=
		mix
		(
			1.,
			abs
			(
				dot(getNormal(vary_pos), vec3(0.58))//,
			//	0.
			),
		1.//	gbl_2(t)
		);
#endif

	color *= vec4(0.3, 1.0, 0.3, 1.0);

	float dist =vary_pos.x-pulse_fract(t);
	dist = (1.0-dist*dist);
	dist = pow(dist, 222.);
	color += vec4(0.5)*dist;

	color *= 1.0 - gbl_end(t);

#if 0
	color = vec4(0.);
//	color.r = gbl_begin(t);
//	color.r = gbl_1(t);
	color.r = gbl_end(t);
	color.g = gbl_2(t);
	color.b = gbl_3(t);
#endif
}
