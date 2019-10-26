#version 330

#include "common.s"

out vec2 out_sample;

float softnoise1D(float t, float freq)
{
	float d = rand3(freq/1000.);
	float n = floor(t*freq)+d*0.1;
	float a = t*freq - n;
	float c0 = rand3(n/freq/FLT(SOUND_LENGTH_IN_SECOND)).x;
	float c1 = rand3((n+1.0)/freq/FLT(SOUND_LENGTH_IN_SECOND)).x;
	return mix(c0, c1, smoothstep(0., 1., a));
}

float fbm1D(float t, float freq)
{
	float r = 0;
	r += softnoise1D(t, freq)*0.5;
	r += softnoise1D(t, freq*2.0)*0.25;
	r += softnoise1D(t, freq*4.0)*0.125;
	r += softnoise1D(t, freq*8.0)*0.0625;
	return r;
}

void main()
{
	float t = get_second(gl_VertexID);
	const float p2 = 2.0*3.1415926;
	float s = t*p2;

	float n = floor(t*8.);
	float cfreq = exp(rand3(n/8./FLT(SOUND_LENGTH_IN_SECOND))*8.)+160.;

	out_sample = vec2(0.);
//	out_sample = vec2(sin(s*400.0+sin(s*10)), sin(s*400.0+sin(s*10)))*0.5;
//	out_sample = vec2(fract(t*400))*0.25;

	//Low freq
	out_sample += vec2(fract(s*20))*0.2*pulse_fract(t)*(1.0-gbl_begin(t));

	//1
	float freq_base = lcl_1(t);
	float amp1 = 1.-pulse_fract(t);
	out_sample += fbm1D(t, 1000.+exp(freq_base*8.)*2222.)*0.5*amp1*amp1*gbl_1(t);

	//2
	out_sample += fract(t*(gbl_2(t)*2222.+222.))*0.2*pulse_double(t)*gbl_2(t);

	//3
	float phase3 = sin(s*(t+1.0))*2;
	out_sample += vec2(sign(fract(t*cfreq+phase3)-0.5))*0.25*narrow_wave2(t)*gbl_3(t);

	//4
	out_sample += vec2(fract(t*cfreq))*0.25*gbl_4(t);

	out_sample *= 1.0 - gbl_end(t);
}
