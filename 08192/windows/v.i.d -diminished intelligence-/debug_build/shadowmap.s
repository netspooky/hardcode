#pragma once

uniform bool is_shadowmap;

#define SHADOWMAP_PROJ_WIDTH	1.5
#define SHADOWMAP_PROJ_HEIGHT	1.5
#define SHADOWMAP_PROJ_NEAR		1.0
#define SHADOWMAP_PROJ_FAR		6.0

const mat4 shadowmap_projection =
mat4
(
	1.0/SHADOWMAP_PROJ_WIDTH,	0.0,						0.0,						0.0,
	0.0,						1.0/SHADOWMAP_PROJ_HEIGHT,	0.0,						0.0,
	0.0,						0.0,						-2.0/(SHADOWMAP_PROJ_FAR - SHADOWMAP_PROJ_NEAR),	0.0,
	0.0,						0.0,						-(SHADOWMAP_PROJ_FAR + SHADOWMAP_PROJ_NEAR)/(SHADOWMAP_PROJ_FAR - SHADOWMAP_PROJ_NEAR), 1.0
);

vec3 get_shadowmap_light_pos()
{
	return vec3(1.5, 3.0, 2.0);
}

mat3 get_shadowmap_view_mat()
{
	return lookat_view_mat(get_shadowmap_light_pos(), vec3(0.0));
}
