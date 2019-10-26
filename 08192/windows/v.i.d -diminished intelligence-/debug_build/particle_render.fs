#version 420

#include "common.s"
#include "camera.s"
#include "shadowmap.s"

uniform float sample_count;
layout(binding = 1) uniform sampler2DShadow shadowmap;

//in  vec3 vary_pos;
in vec3 vary_tangent;
in vec3 vary_view_dir;
in vec4 vary_shadow_pos;
in float	vary_t;
in float	vary_nrm_insid;

out vec4 color;

void main()
{
//	vec3 vary_pos = gl_TexCoord[0].xyz;
//	float nrm_insid = gl_TexCoord[0].w;
	float t = get_second(sample_count);

#if 0
	//	color = vec4(nrm_insid);
	//	float vis = floor(nrm_insid*8.)/8. < gbl_1(t) ? 1.0 : 0.0;
//	if(nrm_insid < gbl_begin(t))
//		discard;

	vec2 uv = gl_TexCoord[1].xy;
	uv = uv*2.0 - vec2(1., 1.);

	color = vec4(1.0);

	if(gl_TexCoord[1].z > 0.5)
	{
		//Background
		color = vec4(0.1, 0.1, 0.5, 1.0);
		color *= 0.9;
	}else if(gl_TexCoord[1].z > 0.)
	{
		//Nippon!
		vec2 uv0 = uv + vec2(1., 0.5);
		float theta = atan(uv0.y, uv0.x) + t;
		const float tfreq = 0.003;
		float noise = softnoise(vec3(uv, snd_sin(t*tfreq)), 111.)*0.5 + softnoise(vec3(uv, snd_sin(t*tfreq+.1)), 222.)*0.25 + softnoise(vec3(uv, snd_sin(t*tfreq+.03)), 444.)*0.125;
		if
		(
			length(uv0) + noise*.03
			> (pulse_fract_long(t)*.1 + .3)*min((t-1.)/8., 1.)
			&&
			sin(theta*16.0) < 1.-min((t-20.)/8., 1.)
		)
			discard;
		color = vec4(HSVtoRGB(.0+noise*.2/(1.+length(uv0)*12.), 0.8, 1.), 1.);
	}else
	{
		color = vec4((1.0-uv), 1.0, 1.0);
	}
#endif

//	color = vec4(1.0) + vec4(sample_count);
//	color = vec4(abs(normalize(vary_tangent).xzy), 1.0) + vec4(sample_count)*0.00000001;
	vec3 tangent	= normalize(vary_tangent);
	vec3 view_dir	= normalize(vary_view_dir);
	mat3 shadowmap_view_mat	= get_shadowmap_view_mat();
	vec3 light_dir	= shadowmap_view_mat[2];
	float dot_lt	= dot(light_dir,	tangent);
	float dot_vt	= dot(view_dir,		tangent);
	float diffuse	= sqrt(1.0 - dot_lt*dot_lt);
	float spec		= pow(max(diffuse*sqrt(1.0 - dot_vt*dot_vt) - dot_lt*dot_vt, 0.0), 60.0);
	color = diffuse*vec4(0.1, 0.05, 0.05, 1.0) + spec*vec4(0.4, 0.4, 0.4, 1.0) + vec4(0.05);

	float shadow	= textureProj(shadowmap, vary_shadow_pos);
	color *= shadow;
	color += vec4(0.05);
	color *= 1.0 - max(gbl_begin(t), gbl_end(t));

//	color = vec4(fract(vary_t*3.0));
	color += vec4(max(((sin(vary_t*4.0+t*6.0+vary_nrm_insid*4.0))-0.9), 0.0)*10.0);
//	color = vec4(fract(vary_nrm_insid*3.0));
#if 0
	color = vec4(0.);
//	color.r = gbl_begin(t);
//	color.r = gbl_1(t);
	color.r = gbl_end(t);
	color.g = gbl_2(t);
	color.b = gbl_3(t);
#endif
}
