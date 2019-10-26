#ifndef HEAD_S
#define HEAD_S

#define HEAD_RADIUS 0.5
#define CAP_THETA	acos(0.9)
#define CAP_Y		(cos(CAP_THETA)*HEAD_RADIUS)
#define CAP_Z		(sin(-CAP_THETA)*HEAD_RADIUS)

vec3 get_head_pos(float t)
{
#if 1
	float scene = max(scene_smooth(t, 1.),scene_smooth(t, 3.));
	return
	vec3
	(
		sin(2.0*PI*t*0.5)*0.2*scene,
		abs(sin(2.0*PI*t*0.5))*0.6*scene,
		0.0
	);
#else
	return vec3(0.0);
#endif
}

#endif
