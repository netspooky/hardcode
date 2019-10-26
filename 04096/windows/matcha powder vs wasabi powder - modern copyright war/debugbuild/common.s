#include "sound_conf.h"
#include "particle_conf.h"

#define PI	3.1415926

#define FLT_(n) n##.0
#define FLT(n) FLT_(n)

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

float get_second(float smpl)
{
	return smpl/SOUND_SAMPLE_RATE;
}

//t[second]
float narrow_wave(float t)
{
	return max(sin(2.0*PI*t*t*1.0), 0.0);
}

float narrow_wave2(float t)
{
	return max(sin(2.0*PI*(sin(t*0.25)+2.)*t*1.0), 0.0);
}

float pulse_fract(float t)
{
	return max(fract(t)*2.0-1.0, 0.0);
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

float gbl_begin(float t)
{
	return max(1.-t*t*0.0625, 0.);
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

float gbl_end(float t)
{
	float t0 = t - FLT(SOUND_LENGTH_IN_SECOND);
	return max(1.-t0*t0*0.0625, 0.);
}


float lengthN(vec3 v, float n)
{
  vec3 tmp = pow(abs(v), vec3(n));
  return pow(tmp.x+tmp.y+tmp.z, 1/n);
}

float sphereNR(vec3 p, float n, float r)
{
  return lengthN(p, n) - r;
}

float DF(vec3 pos)
{
	vec3 p = pos - vec3(0.05);
	p = fract(p*12.)-vec3(0.5);
	return -sphereNR(p, 4., 0.55);
}

vec3 getNormal(vec3 p)
{
  float d = 0.0001;
  return
    normalize
    (
      vec3
      (
        DF(p+vec3(d,0,0))-DF(p+vec3(-d,0,0)),
        DF(p+vec3(0,d,0))-DF(p+vec3(0,-d,0)),
        DF(p+vec3(0,0,d))-DF(p+vec3(0,0,-d))
      )
    );
}

