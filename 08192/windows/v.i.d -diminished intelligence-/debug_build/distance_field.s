#ifndef DISTANCE_FIELD_S
#define DISTANCE_FIELD_S

#include "head.s"

#ifdef SHADOWMAP_PROJ_WIDTH
#	define DONT_CAST_SHADOW	if(is_shadowmap){return 99999.9;}
#else
#	define DONT_CAST_SHADOW
#endif

float lengthN(vec3 v, float n)
{
	vec3 tmp = pow(abs(v), vec3(n));
	return pow(tmp.x+tmp.y+tmp.z, 1/n);
}

float sphere(vec3 p, float radius)
{
	return length(p) - radius;
}

float cylinderx(vec3 p, float radius)
{
	return length(p.yz) - radius;
}

float cylindery(vec3 p, float radius)
{
	return length(p.xz) - radius;
}

vec3 get_p_head(vec3 p, float t)
{
	return p - get_head_pos(t);
}

vec3 get_p_head_xmirr(vec3 p, float t)
{
	vec3 p_head = get_p_head(p, t);
	return vec3(abs(p_head.x), p_head.yz);
}

float mayuge_DF(vec3 p, float t)
{
	DONT_CAST_SHADOW

	vec3 p_head_xmirr = get_p_head_xmirr (p, t);
	p_head_xmirr -= vec3(0.2, 0.2, 0.42);
	vec3 p_mayuge = SPHERICAL_MAT_INV(0.3, -0.4) * p_head_xmirr;
	return max(max(-p_mayuge.x, p_mayuge.x-0.15), cylinderx(p_mayuge, 0.014));
}

float eye_DF(vec3 p, float t)
{
	DONT_CAST_SHADOW

	vec3 p_head_xmirr = get_p_head_xmirr (p, t);

	return
		min
		(
			mayuge_DF(p, t),
			sphere(p_head_xmirr - vec3(0.23, 0.04, 0.4), 0.09)
		);
}

float head_DF(vec3 p, float t)
{
	vec3 p_head = get_p_head(p, t);
	vec3 p_head_xmirr = get_p_head_xmirr(p, t);
	float cap_theta = abs(sin(t*3.0)*PI*0.5*scene_smooth(t, 1));
	vec3 p_cap	= ROTATE_X_MAT_INV(cap_theta)*(p_head - vec3(0.0, CAP_Y, CAP_Z)) + vec3(0.0, CAP_Y, CAP_Z);

	float head_core = 
		min
		(
			min
			(
				max(sphere(p_head, HEAD_RADIUS), p_head.y - CAP_Y),
				max
				(
					cylindery(p_head, 0.15),
					max(p_head.y - CAP_Y - 0.03, -p_head.y + CAP_Y)
				)
			),
			max
			(
				max(sphere(p_cap, HEAD_RADIUS), -(p_cap.y - CAP_Y)),
				-max
				(
					cylindery(p_cap, 0.15),
					max(p_cap.y - CAP_Y - 0.03, -p_cap.y + CAP_Y-0.1)
				)
			)
		);

	return
		min
		(
			head_core,
			sphere(p_head_xmirr - vec3(0.045, -0.1, 0.49), 0.06)
		);
}

float env_DF(vec3 p, float t)
{
	vec3 p_lcl = p - vec3(0.0, -0.5, 0.0);

	vec3 repeated = fract(p_lcl)*2.0-1.0;
	return
			max(lengthN(repeated, 8.0) - 1.05, p_lcl.y);
}

float DF(vec3 p, float t)
{
	return
		min
		(
			min(head_DF(p, t), eye_DF(p, t)),
			env_DF(p, t)
		);
}

struct material
{
	vec3 diffuse;
	vec3 ambient;
};

material get_material(vec3 p, float t)
{
	float env_d		= env_DF(p, t);
	float head_d	= head_DF(p, t);
	float eye_d		= eye_DF(p, t);

	if(head_d < env_d && head_d < eye_d)
	{
		return material(vec3(0.9, 0.8, 0.3), vec3(0.3, 0.25, 0.1));
	}else if(eye_d < env_d)
	{
		return material(vec3(0.03), vec3(0.005));
	}else
	{
		return material(vec3(0.1, 0.8, 0.1), vec3(0.23, 0.23, 0.3));
	}
}

vec3 get_normal(vec3 p, float t)
{
	const float d = 0.0001;
	return
		normalize
		(
			vec3
			(
				DF(p+vec3(d,0.0,0.0), t)-DF(p+vec3(-d,0.0,0.0), t),
				DF(p+vec3(0.0,d,0.0), t)-DF(p+vec3(0.0,-d,0.0), t),
				DF(p+vec3(0.0,0.0,d), t)-DF(p+vec3(0.0,0.0,-d), t)
			)
		);
}
 
#endif
