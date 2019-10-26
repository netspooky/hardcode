#include <math.h>
#include "filter.h"

void CRfilter::SetParams () {
            float alpha, omega, sn, cs;
            float a0, a1, a2, b0, b1, b2;

            // These limits the cutoff frequency and resonance to
            // reasoneable values.
            if (param_cutoff < 20.0f) { param_cutoff = 20.0f; };
            if (param_cutoff > 22000.0f) { param_cutoff = 22000.0f; };
            if (param_resonance < 1.0f) { param_resonance = 1.0f; };
            if (param_resonance > 127.0f) { param_resonance = 127.0f; };

            omega = (float)(2.0f *3.141592653589793238* param_cutoff)/SampleRate;
            sn = (float)sin (omega); 
            cs = (float)cos (omega);
            alpha = sn / (2*param_resonance);
            b0 = (1.0f - cs) / 2.0f;
            b1 = 1.0f - cs;
            b2 = (1.0f - cs) / 2.0f;
            a0 = 1.0f + alpha;
            a1 = -2.0f * cs;
            a2 = 1.0f - alpha;
            filtCoefTab[0] = b0/a0;
            filtCoefTab[1] = b1/a0;
            filtCoefTab[2] = b2/a0;
            filtCoefTab[3] = -a1/a0;
            filtCoefTab[4] = -a2/a0;
}

void CRfilter::Init() {
  param_cutoff = 11050;
  param_resonance = 1;
  SampleRate = 44100;
  SetParams ();
  x1 = x2 = y1 = y2 =  0.0f;
}

float CRfilter::Work(float psamples) {

  float in, out, temp_y;
  in = psamples;
  out = in;

  temp_y = filtCoefTab[0] * out +
           filtCoefTab[1] * x1 +
           filtCoefTab[2] * x2 +
           filtCoefTab[3] * y1 +
           filtCoefTab[4] * y2;
           y2 = y1; 
           y1 = temp_y; 
           x2 = x1; 
           x1 = out; 
           out = temp_y;

  return out;


/*
//set feedback amount given f and q between 0 and 1
  in = psamples;
  double q = 1;
  double f = sin(2*PI * this->param_cutoff/44100);
  double fb =  q + q/(1.0 - f);;

//for each sample...
  x1 = x1 + f * (in - x1 + fb * (x1 - x2));
  x2 = x2 + f * (x1 - x2);
  out = x2;
  return out;*/
}

void PassFilter::SetParams () {
  if(!low_frq)
    low_frq = 10;

  if(!high_frq)
    high_frq = 30000;
  buff_size = SampleRate/low_frq;
  if(e_buff)
    delete []e_buff;
  e_buff = new short int[buff_size];
  for(int i=0;i<buff_size;i++)
    e_buff[i] = 0;
}

void PassFilter::Init() {
  type = BENDPASS;
  e_buff = NULL;
  low_frq = 10;
  high_frq = 30000;
  e_head = 0;
  buff_size = 0;

  hi_acc = 0;
  lo_acc = 0;
  SampleRate = 1;
}

short PassFilter::Work(short c)         /* c - амплитуда сигнала в текущий момент
вpемени. */
{                             /* функция будет возвpащать новую амплитуду для
записи */
                              /* в выходной поток */

    int lo_tale;              /* Хвост для фнч */
    int hi_tale;              /* Хвост ждя фвч */

    if(--e_head < 0) 
      e_head = buff_size-1;    /* заносим в буфеp новое
*/
    e_buff[e_head] = c;                               /* значение */

    /* ФHЧ */
    lo_tale = e_head + low_frq;     /* опpеделяем последнее значение окна */
    if(lo_tale >= buff_size)
        lo_tale -= buff_size;

    lo_acc -= e_buff[lo_tale];     /* поддеpживаем сумму всех значений окна в*/
    lo_acc += c;                   /* аккумулятоpе. для каждого нового значения*/
                                   /* окно смещается */
    /* ФВЧ */
    hi_tale = e_head + high_frq;     /* опpеделяем последнее значение окна */
    if(hi_tale >= buff_size)
        hi_tale -= buff_size;

    hi_acc -= e_buff[hi_tale];     /* поддеpживаем сумму всех значений окна в*/
    hi_acc += c;                   /* аккумулятоpе. для каждого нового значения*/
                                   /* окно смещается */

    /* для получения полосового фильтpа вычитаем из значения фнч значение фвч*/
    switch(this->type) {
      case BENDPASS: return hi_acc / (high_frq+1) - lo_acc / (low_frq+1);
      case LOWPASS: return lo_acc / (low_frq+1);
      case HIGHPASS: return c - hi_acc / (high_frq+1);
      default: return lo_acc / (low_frq+1) - hi_acc / (high_frq+1);
    };
}

PassFilter::PassFilter() {
  type = BENDPASS;
  e_buff = NULL;
  low_frq = 10;
  high_frq = 30000;
  e_head = 0;
  buff_size = 0;

  hi_acc = 0;
  lo_acc = 0;
  SampleRate = 1;
}

PassFilter::~PassFilter() {
  if(e_buff)
    delete []e_buff;
}