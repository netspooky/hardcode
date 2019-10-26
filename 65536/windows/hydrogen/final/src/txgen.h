#ifndef __TXGEN_H_
#define __TXGEN_H_

#include <math.h>
#include <stdlib.h>
#include ".\z3d\z3d.h"

/*
#define TX_EXIST	1 
#define TX_WIDTH	2
#define TX_HEIGHT	3
#define TX_BITSPP	4
*/
struct txProcP {
  long  generator;
  long  sp_mode;
  long  sp_param;
  float param1;
  float param2;
  float param3;
  float param4;
  long  l1;
  long  l2;
  long  l3;
};
/*
struct txGenP {
  long  w;
  long  h;
  long  gen_num;
  txProcP *gnParams;
};
*/


//void txgFractal(TEXTURE_Z *tx, txProcP *params);
//void txgPattern1(TEXTURE_Z *tx,txProcP *params);
void txgSubplasma(TEXTURE_Z *tx,txProcP *params);
//
//void txgCreateChecker(TEXTURE_Z *tx,txProcP *params);
//void txgCreateSinePlasm(TEXTURE_Z *tx,txProcP *params);
//void txgCreateRadial(TEXTURE_Z *tx,txProcP *params);
//void txgCreateEff(TEXTURE_Z *tx,txProcP *params);

//void txgReSin(TEXTURE_Z *tx,txProcP *params);

#endif