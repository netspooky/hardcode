#include "sound_conf.h"
#include "particle_conf.h"

#define PI	3.1415926
#define SQRT_2	1.41421

#define FLT_(n) n##.0
#define FLT(n) FLT_(n)

#define SPHERICAL_MAT_INV(theta, phi) mat3(						\
	cos(theta)*cos(phi),	-sin(theta)*cos(phi),	-sin(phi),	\
	sin(theta),				cos(theta),				0.0,		\
	cos(theta)*sin(phi),	-sin(theta)*sin(phi),	cos(phi))

#define ROTATE_X_MAT_INV(theta)	mat3(		\
	1.0,	0.0,			0.0,			\
	0.0,	cos(theta), 	sin(theta),		\
	0.0, 	-sin(theta),	cos(theta))

#define ROTATE_Y_MAT_INV(theta)	mat3(		\
	cos(theta),	0.0,	-sin(theta),		\
	0.0,		1.0, 	0.0,				\
	sin(theta),	0.0,	cos(theta))

#define NUM_SCENES 4
float scene_smooth(float t, float n)
{
	float begin = 
			n/FLT(NUM_SCENES)*FLT(SOUND_LENGTH_IN_SECOND);
	float width = 
			1.0/FLT(NUM_SCENES)*FLT(SOUND_LENGTH_IN_SECOND);
	float trans =
			0.8;

	return smoothstep(-width/2.0, -width*(1.-trans)/2.0, -abs(t-begin - width*0.5));
}

vec3 rand3(float pos)
{
  float x = pos + 2.;
  vec3 p = vec3(x, x*x, x*x*x);
  vec3 fp = fract(p*222.)+vec3(2.);

  return
    fract
	(
	  p*fp.yzx*fp.zxy
    );
}

float get_second(float smpl)
{
	return smpl/SOUND_SAMPLE_RATE;
}

float gbl_begin(float t)
{
	return 1.0 - smoothstep(3., 7., t);
}

float gbl_end(float t)
{
	float t0 = FLT(SOUND_LENGTH_IN_SECOND) - t;
	return 1.0 - smoothstep(0., 4., t0);
}

#if 0
float rand(vec3 pos)
{
  vec3 p = pos + vec3(2.);
  vec3 fp = fract(p*p.yzx*222.)+vec3(2.);
  p.y *= p.z * fp.z;
  p.x *= p.y * fp.y;
  return
    fract
    (
		p.x*p.x
    );
}

float floorN(float v, float n)
{
	return floor(v*n)/n;
}

float floorFract(float v, float n, out float frac)
{
	float x = v*n;
	float flr = floor(x);
	frac = x - flr;
	return flr/n;
}

float snd_sin(float t)
{
	return sin(2.*PI*t)*0.5+0.5;
}

float softnoise(vec3 pos, float scale)
{
  vec3 smplpos = pos*scale;
  vec3 nsmplpos = floor(smplpos);
  float c000 = rand((nsmplpos+vec3(.0,.0,.0))/scale);
  float c100 = rand((nsmplpos+vec3(1.,.0,.0))/scale);
  float c010 = rand((nsmplpos+vec3(.0,1.,.0))/scale);
  float c110 = rand((nsmplpos+vec3(1.,1.,.0))/scale);
  float c001 = rand((nsmplpos+vec3(.0,.0,1.))/scale);
  float c101 = rand((nsmplpos+vec3(1.,.0,1.))/scale);
  float c011 = rand((nsmplpos+vec3(.0,1.,1.))/scale);
  float c111 = rand((nsmplpos+vec3(1.,1.,1.))/scale);

  vec3 a = smoothstep(0.0, 1.0, fract(smplpos));
  return
    mix(
      mix(
        mix(c000, c100, a.x),
        mix(c010, c110, a.x),
        a.y
      ),
      mix(
        mix(c001, c101, a.x),
        mix(c011, c111, a.x),
        a.y
      ),
      a.z
    );
}

//t[second]
float narrow_wave2(float t)
{
	return max(sin(2.0*PI*(sin(t*0.25)+2.)*t*1.0), 0.0);
}

float pulse_fract(float t)
{
	return max(fract(t*2.0)*8.0-7.0, 0.0);
}

float pulse_fract_long(float t)
{
	return max(fract(t*2.0), 0.0);
}

float pulse2(float t)
{
	return max(sin(2.0*PI*t*2.0)*2.0-1.0, 0.0);
}

float pulse2_1(float t)
{
	return max(sin(2.0*PI*t*2.0+3.)*2.0-1.0, 0.0);
}

float pulse_double(float t)
{
	return pulse2(t)+pulse2_1(t);
}

float lcl_1(float t)
{
	return
		floor
		(
			rand3(floor(t*12.0)/12.0/FLT(SOUND_LENGTH_IN_SECOND)).x
			*
			12.0
		)
		/
		12.0;
}

float gbl_1a(float t)
{
	return
		max
		(
			fract(t/FLT(SOUND_LENGTH_IN_SECOND)*2.+0.75)*4. - 3.,
			0.
		);
}

float gbl_3a(float t)
{
	return
		max
		(
			fract(t/FLT(SOUND_LENGTH_IN_SECOND)*2.+0.25)*4. - 3.,
			0.
		);
}

float gbl_4a(float t)
{
	return
		max
		(
			fract(t/FLT(SOUND_LENGTH_IN_SECOND)*2.+0.)*4. - 3.,
			0.
		);
}

float gbl_1(float t)
{
	return
		max
		(
			sin(4.*PI*t/FLT(SOUND_LENGTH_IN_SECOND))*2.0-1.,
			0.
		);
}

float gbl_2(float t)
{
	return
		max
		(
			sin(4.*PI*t/FLT(SOUND_LENGTH_IN_SECOND) - PI*0.5)*2.0-1.,
			0.
		);
}

float gbl_3(float t)
{
	return
		max
		(
			sin(4.*PI*t/FLT(SOUND_LENGTH_IN_SECOND) - PI*0.5 - PI*0.5)*2.0-1.,
			0.
		);
}

float gbl_4(float t)
{
	return
		max
		(
			sin(4.*PI*t/FLT(SOUND_LENGTH_IN_SECOND) - PI*0.5 - PI*0.5 - PI*0.5)*2.0-1.,
			0.
		);
}

#endif
