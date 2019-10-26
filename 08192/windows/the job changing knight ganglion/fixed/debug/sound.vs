#version 330

#include "common.s"

out vec2 out_sample;

float kukei(float t)
{
	return sign(fract(t)-0.5);
}

float triangle(float t)
{
	float f = fract(t)*2.0;

	return f < 1.0 ? f : 2. - f;
}

float enve(float t)
{
//	return -4.*t*t+4.*t;
	return -4.*t+4.*sqrt(t);
}

float nrand(float t, float freq, float steps, float seed)
{
	return
		floor
		(
			rand3
			(
				floor(t*freq)/(freq*FLT(SOUND_LENGTH_IN_SECOND))+seed
			).x
			*
			(steps+1.0)
		)
		/
		steps;
}

float powsin(float x, float y)
{
	float s = sin(2.0*PI*x);
	return pow(abs(s), y) * sign(s);
}

vec2 gakki2(float t)
{
	float wv1_frq = 1.0;
	float wv2_steps = 3.0;
	float wv2_frq = wv1_frq / wv2_steps;
	float wv2i = floor(fract(wv2_frq*t)*wv2_steps);
	float wv1f = fract(t*wv1_frq);
	float amp = max(1.0 - wv1f*2.0, 0.0);
	return vec2(amp * powsin(t*100.+powsin(wv1f, exp2(wv2i-1.0))*20., 0.5));
}

void main()
{
	float t = get_second(gl_VertexID);
	const float p2 = 2.0*3.1415926;
	float s = t*p2;

	float n = floor(t*8.);
	float cfreq = exp(floor(rand3(n/8./FLT(SOUND_LENGTH_IN_SECOND)).x*8.)*0.25)+160.;

	float wv3_frq = 0.125;
	float wv3i0	= nrand(t, wv3_frq, 3.0, 0.01);
	float wv3i1	= nrand(t, wv3_frq, 3.0, 0.0011);
	float wv2_frq = 0.5;
	float wv2i = floor(fract(t*wv2_frq)*2.);
	float wv1_frq = wv2_frq*2.*(1.0+mix(wv3i0, wv3i1, wv2i)*3.0);
	float wv1f = fract(t*wv1_frq);
	float amp = sin(wv1f*PI)*0.5+max(sin(wv1f*2*PI), 0.0)*0.5;

	float wv1s = nrand(t, wv1_frq, 8.0, 0.);
	float freq = exp(wv1s+3.0)*33.;
	//float freq = 400.0;

	float mdlt_amp = (scene_smooth(t, 1.)*0.2 + scene_smooth(t, 3.))*40.0;
	float p = mdlt_amp*sin(wv1f*2.0)*4.0;
	float md = scene_smooth(t, 2.)*sin(s*freq*0.5);

	out_sample = vec2(0.);
	out_sample += vec2(sin(s*freq+p+md), sin(s*freq-p+md))*0.25*amp;
	out_sample += gakki2(t)*0.125+ gakki2(t*1.001)*0.125*scene_smooth(t, 2.);

	out_sample *= pow(1.0 - gbl_end(t), 2.0);
}
