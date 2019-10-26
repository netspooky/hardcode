#version 330

#include "common.s"
#include "camera.s"
#include "raster_projection.s"

uniform float sample_count;

layout(location = 0) in vec2 in_position;

out vec3 vary_pos;

void main()
{
	float t = get_second(sample_count);

	float y = gl_InstanceID * 0.05 - 1.0;
	vec3 p = vec3(in_position*4.0, y).xzy;
	vary_pos = p;

	//view coordinate
	vec3 cam_pos	= get_cam_pos(t);
	mat3 viewmat	= transpose(get_view_mat(t, cam_pos));
	vec3 view_pos	= viewmat * (p - cam_pos);

	gl_Position	= projection*vec4(view_pos, 1.0);
}
