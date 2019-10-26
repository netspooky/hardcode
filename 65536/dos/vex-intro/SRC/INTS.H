#ifndef __INTS_H
#define __INTS_H

extern "C"
{
  long IntMul(long, long);
  long IntSqr(long);
  long IntDiv(long, long);
  long IntSqrt(long);
  long IntMulDiv(long, long, long);
  long IntVecMul(long(*)[3], long(*)[3]);
  long IntVecSqr(long(*)[3]);
  void InstallZeroDivide();
  void DeinstallZeroDivide();
}

#define dtol(d) ((long)((d)*65536))
#define ltod(l) ((double)(l)/65536)
#define itol(i) ((long)(i)<<16)
#define ltoi(l) ((int)((l)>>16))

#endif
