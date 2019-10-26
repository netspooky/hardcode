//This file contains ALL the routines, classes and so on
//connected to color management.
//2elmm: PLEASE! do not use your macros anymore!
//use COLOR class

#ifndef __COLOR_H_
#define __COLOR_H_

#include "base.h"
#pragma pack( push, enter_colorh)
//----------------------------------
#pragma pack(1)
struct COLOR{
  COLOR (){};
  COLOR (long color){this->color=color;};
  COLOR& ARGB(uchar a,uchar r,uchar g,uchar b){
    this->a=a;
    this->b=b;
    this->g=g;
    this->r=r;
    return *this;
  };
  COLOR& XRGB(uchar r,uchar g,uchar b){
    this->b=b;
    this->g=g;
    this->r=r;
    return *this;
  };
  COLOR (uchar a,uchar r,uchar g,uchar b){
    this->ARGB(a,r,g,b);
  }
  COLOR (uchar r,uchar g,uchar b){
    this->XRGB(r,g,b);
  }
  //data
  union{
    uint color;
    struct {
      uchar b,g,r,a;
    };
    uchar color_index[4];
  };
  COLOR& operator+=(COLOR &col){
    COLOR c=col;
    __asm{
      mov     eax,this
      movd    mm0,[eax]
      movd    mm1,c
      paddusb mm0,mm1
      movd    [eax],mm0  
      emms
    }
    return *this;
  };
  COLOR& operator%=(COLOR &col){
    COLOR c=col;
    __asm{
      mov     eax,this
      movd    mm0,[eax]
      movd    mm1,c
      paddsb  mm0,mm1
      movd    [eax],mm0  
      emms
    }
    return *this;
  };
  COLOR& operator-=(COLOR &col){
    COLOR c=col;
    __asm{
      mov     eax,this
      movd    mm0,[eax]
      movd    mm1,c
      psubusb  mm0,mm1
      movd    [eax],mm0  
      emms
    }
    return *this;
  };
/*  COLOR& operator*=(uchar m){
    __asm{
      mov         eax,this
      movd        mm0,[eax]
      pxor        mm1,mm1
      punpcklbw   mm0,mm1
      movzx       ebx,m
      movd        mm2,ebx
      punpcklbw   mm2,mm2
      punpcklwd   mm2,mm2
      punpcklbw   mm2,mm1
      pmullw      mm0,mm2
      packuswb    mm0,mm0
      movd        [eax],mm0
      emms
    }
    return *this;
  };*/
  COLOR& alpha(COLOR &c1,COLOR &c2,uint alpha){
    r=alpha*c1.r+(256-alpha)*c2.r;
    g=alpha*c1.g+(256-alpha)*c2.g;
    b=alpha*c1.b+(256-alpha)*c2.b;
    a=alpha*c1.a+(256-alpha)*c2.a;
    return *this;
  };
  COLOR& alpha(COLOR &c1,COLOR &c2,double alpha){
    return this->alpha(c1,c2,(uint)(alpha*256));
  };
};
#pragma pack( pop, enter_colorh)
#endif