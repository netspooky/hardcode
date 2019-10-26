#version 330

#include "common.s"
#include "utils.s"

uniform float sample_count;

in vec2 vary_uv;

out vec4 out_color;

uniform sampler2D AATex;

void main()
{
	float t = get_second(sample_count);

	vec2 uv = vary_uv;
	uv.x = min(uv.x, max(t - 8.0, -0.1)*0.04);
	uv.y += sin(t+uv.x*20.0)*0.1-0.1;
	float v = texture(AATex, uv).r;
	if(v < 0.05)
		discard;

	out_color = vec4(HSVtoRGB(sin(-t*2.0+vary_uv.x*40.0)*0.5+0.5, 1.0, 1.0), 1.0);
}
