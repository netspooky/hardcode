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

	float z = -gl_InstanceID * 0.125 - 0.5 + t*0.1;
	vec3 p = vec3(in_position * 2.0, z);
	vary_pos = p;

	gl_Position	= projection*vec4(p, 1.0);
}
