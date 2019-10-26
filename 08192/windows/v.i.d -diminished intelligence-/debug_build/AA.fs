#version 330

#include "common.s"

uniform float sample_count;

in vec2 vary_uv;

out vec4 out_color;

uniform sampler2D AATex;

void main()
{
	float v = texture(AATex, vary_uv).r;
	if(v < 0.05)
		discard;

	float t = get_second(sample_count);
	float offset = vary_uv.x + vary_uv.y;
	out_color = vec4(cos(-t*4.0 + offset*40.0)*0.5+0.5, 0.2, 0.1, 1.0);
}
