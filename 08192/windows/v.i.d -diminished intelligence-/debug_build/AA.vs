#version 330

#include "common.s"

uniform float sample_count;

#define AA_HEIGHT 4.0

layout(location = 0) in vec2 in_position;

out vec2 vary_uv;

void main()
{
	float t = get_second(sample_count);

	vary_uv = in_position;
	vec2 pos = in_position * vec2(1.0*(1080.0/1980.0), AA_HEIGHT)*2.0+vec2(0.0, 0.0);
	gl_Position = vec4(pos, 0.0, 1.0);
	gl_Position.y += max(t-12.0, 0.0)*0.25 - AA_HEIGHT*2.0 - 1.0;
}
