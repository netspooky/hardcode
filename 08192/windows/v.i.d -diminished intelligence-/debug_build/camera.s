#ifndef CAMERA_S
#define CAMERA_S

#define WIDTH	1920.0
#define HEIGHT	1080.0
#define ZNEAR	0.1
#define ZFAR	6.0
#define PROJ_W	0.05

mat3 lookat_view_mat(vec3 pos, vec3 target)
{
	//pos - targetがY軸と平行だと正しく計算できない.
	vec3 forward	= normalize(pos - target);
	vec3 side		= normalize(cross(vec3(0.0, 1.0, 0.0), forward));
	vec3 up			= normalize(cross(forward, side));

	mat3 viewmat	= mat3 (side, up, forward);

	return viewmat;
}

#include "shadowmap.s"

vec3 get_cam_pos(float t)
{
	return
		is_shadowmap ?
		get_shadowmap_light_pos() :
		vec3(/*cos(t)*1.3*/0.3, 2.0+cos(t)*1.0, 3.0+sin(t)*0.8);
}

mat3 get_view_mat(float t, vec3 cam_pos)
{
	return
		is_shadowmap
		?
		get_shadowmap_view_mat()
		:
		lookat_view_mat(cam_pos, vec3(0.0));
}

#endif
