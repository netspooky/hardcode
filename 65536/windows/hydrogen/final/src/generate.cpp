#include "generate.h"

double pi = 3.1415926535;

double saw(double x) {
  double pos = fmod( x, pi*2);
  double res = (pos/pi)-1.0;
  return res;
}
/*
double tri(double x) {
  double pos = fmod( x, pi*2);
  double res=0;
  double mlt=1;
  if(pos<=pi) 
    mlt = 1.0;
  else
    mlt = -1.0;
    
  if(pos<=pi/2) {
      res = pos/(pi/2);
  }
  else {
    pos -= pi/2;
    res = (pi/2-pos)/(pi/2);
  }

  res *= mlt;
  return res;
}*/

double squ(double x) {
  double res = sin(x);
  if(((res>0)&&(res<0.05))||((res<0)&&(res>-0.05)))
    return 0;
  if(res>0) {
    return 0.90;
  }
  else {
    return -0.90;
  }
//  return res;
}

double noise(double x) {
  srand((unsigned int) ceil(x*2));
  srand(rand()*2);
  int rndval=rand();
  while ((rndval>1000)) {
    rndval=rand();
  }
  return (rndval-500)*0.0007;
}

double g_func(double x, int f_number) {
  switch(f_number) {
    //case G_TRI:  return tri(x);
    case G_SQU:  return squ(x);
    case G_SAW:  return saw(x);
    case G_NOISE:return noise(x);
    case G_SIN:  return sin(x);
/*    case G_SINH: return sinh(x);
    case G_COS:  return cos(x);
    case G_COSH: return cosh(x);
    case G_TAN:  return tan(x);
    case G_TANH: return tanh(x);
    case G_ACOS: return acos(x);
    case G_ASIN: return asin(x);
    case G_ATAN: return atan(x);
    case G_LOG:  return log(x);
    case G_LOG10:return log10(x);*/
    default:     return sin(x);
  }

  return  0;
}

void GenerateSample16(void *buffer,SampleInfo *si) {
  double  r;
  double  underf;
  double  omg;
  short int *buf;
  unsigned int len = si->attack+si->sustain+si->release;
  unsigned int susend = si->attack+si->sustain;
  double val;
  double  ps;
  CRfilter  crf;
  PassFilter psf;


  buf = (short int *)buffer;
  //printf("omega = %f\n",omg);
  for(unsigned int pos=0;pos<len;pos++) {
    ps = pos;
    omg = (si->frequency+si->pitch_env*(ps/si->rate))*2*pi;
    underf = omg*(ps/si->rate)+si->phy;
    r = g_func(underf,si->gen_type);
    if(r>1.0) {
      r = 1.0;
    }
    else {
      if(r<-1.0)
        r = -1.0;
    }
    r *= si->amplitude;
    if((pos>=si->attack)&&(pos<=susend)) {
      val = r;
    }
	  else {
      if(pos<si->attack) {
        val = r*(ps/si->attack);
      }
      else {
        val = r*((len - ps)/si->release);
      }
    }
	  buf[pos] = (short int)val;
  }

  crf.Init();
  crf.SampleRate = si->rate;
  if(si->filter&1) {
    for(pos=0;pos<len;pos++) {
      crf.param_cutoff = si->cutoff + si->cut_env*(((float)pos)/si->rate);
      crf.param_resonance = si->resonance + si->res_env*(((float)pos)/si->rate);
      crf.SetParams();
      buf[pos] = (short int)(crf.Work(buf[pos]));
    }
  }
  
  if(si->filter&14) {
    psf.Init();
    psf.SampleRate = si->rate;
    psf.type = si->filter&14;
    psf.SetParams();
    for(pos=0;pos<len;pos++) {
      psf.high_frq = (int)floor(psf.SampleRate/(si->high_freq + si->high_env*(((float)pos)/si->rate)));
      psf.low_frq  = (int)floor(psf.SampleRate/(si->low_freq + si->low_env*(((float)pos)/si->rate)));
      buf[pos] = psf.Work(buf[pos]);
    }
    //psf.~PassFilter();
  }
}

