#include <math.h>

#define RMSSAMPLES 1024

class Osc {

    float f1l, f1h, f1b;
    float f2l, f2h, f2b;
    float ffrq;
    float frez;
    float rbuf[RMSSAMPLES];
    float rmsval;
    int   bufpos;
    int   mode;

    public:
    Osc(int f, int hm) {
        f2l=f2h=f2b=0;
        f1l=f1h=f1b=0;
        ffrq=f/11025.0;
        frez=pow(0,ffrq);
        for (int i=0; i<RMSSAMPLES; i++)
          rbuf[i]=0;
        bufpos=0;
        rmsval=0;
        mode=hm;
    };

    float tick(float is) {
        
        // filter 1
        f1h=is-(1-frez)*f1b-f1l;
        f1b+=ffrq*f1h;
        f1l+=ffrq*f1b;

        // filter 2
        f2h=f1h-(1-frez)*f2b-f2l;
        f2b+=ffrq*f2h;
        f2l+=ffrq*f2b;

        // RMS
        rmsval-=rbuf[bufpos];
        rbuf[bufpos]=mode?(f2h*f2h):(f2l*f2l);
        rmsval+=rbuf[bufpos];
        bufpos=(bufpos+1)%RMSSAMPLES;

        // output
        if (rmsval<0) rmsval=0;
        return sqrt(rmsval/RMSSAMPLES);
    };

};
    
