#version 330

#include "common.s"
#include "camera.s"

uniform float sample_count;

out vec3 vary_ray_dir;

void main()
{
	if(gl_VertexID == 0)
		gl_Position = vec4(-1.0, -1.0, 0.999, 1.0);
	else if(gl_VertexID == 1)
		gl_Position = vec4(3.0, -1.0, 0.999, 1.0);
	else
		gl_Position = vec4(-1.0, 3.0, 0.999, 1.0);

	float t = get_second(sample_count);

	vec3 cam_pos	= get_cam_pos(t);
	mat3 viewmat	= get_view_mat(t, cam_pos);

	if(is_shadowmap)
	{
		//shadowmapのときはrayの位置.
		vary_ray_dir	=
			viewmat[0]*gl_Position.x*SHADOWMAP_PROJ_WIDTH
			+
			viewmat[1]*gl_Position.y*SHADOWMAP_PROJ_HEIGHT
			-
			viewmat[2]*SHADOWMAP_PROJ_NEAR
			+
			cam_pos;
	}else
	{
		vary_ray_dir	=
			viewmat[0]*gl_Position.x*PROJ_W
			+
			viewmat[1]*gl_Position.y*HEIGHT/WIDTH*PROJ_W
			-
			viewmat[2]*ZNEAR;
	}
}
