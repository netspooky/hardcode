#ifndef __INTRSECT_H
#define __INTRSECT_H

struct cutdata
{
  short pal;
  short pac;
  long vpa;
  short pbl;
  short pbc;
  long vpb;
};

extern "C" void calcplane(const vector &n, const vector &v, const long (&p)[4]);
extern "C" short chkplanecut(const long (&plane)[4], const vector *pts, const short *pl, short n, cutdata &rt);
extern "C" void planecutv(long a, const vector &dta, const vector &dtb, vector &dtr);
extern "C" void planecuts2(long a, const void *dta, const void *dtb, void *dtr);
extern "C" void planecutc2(long a, const void *dta, const void *dtb, void *dtr);

#endif
