/*****************************************************************************
                                  ATTENTION!
                           this source is VOTEWARE,
              you may only use it to the conditions listed below:

  -You may modify it, or use parts of it in your own source as long as
    this header stays on top of all files containing this source.
  -You must give proper credit to the author, Niklas Beisert / pascal.
  -You may not use it in commercial productions without the written
    permission of the author.
  -AND MOST IMPORTANT: you have to buy an Assembly '94 CD-ROM
    by Sound Solutions (if you don't have it already) and vote for VEX-InTrO
    in the PC-64k-Intro-Compo! (if you have already sent your voting card,
    buy another one and fill it out CORRECTLY!!!)
*****************************************************************************/



// read the object tree

#include <stdlib.h>
#include <mem.h>
//#include <io.h>
#include "ovlio.h"
#include "ints.h"
#include "matrix.h"
#include "vect.h"

object *readobject(int file)
{
  char type;
  oread(file, &type, 1);
  switch (type)
  {
  case 0:
    return new objectnode(file);
  case 1:
    return new stdobject(file);
  case 2:
  default:
    return new lightobject(file);
  }
}

stdobject::stdobject(int file)
{
  o.mid.v[0]=o.mid.v[1]=o.mid.v[2]=0;
  o.id=-1;
  oread(file, &o.vertnum, 2);
  oread(file, &o.normnum, 2);
  oread(file, &o.planenum, 2);
  oread(file, &o.rad, 4);

  o.verts=new vector[o.vertnum];
  o.norms=new vector[o.normnum];
  if (o.planenum)
    o.planes=new plane[o.planenum];
  else
    o.planes=0;

  oread(file, o.verts, 12*o.vertnum);
  oread(file, o.norms, 12*o.normnum);

  short i;
  for (i=0; i<o.planenum; i++)
  {
    plane &p=o.planes[i];
    short x;
    oread(file, &x, 2);
    p.b=(x==-1)?0:&o.planes[x];
    oread(file, &x, 2);
    p.m=(x==-1)?0:&o.planes[x];
    oread(file, &x, 2);
    p.f=(x==-1)?0:&o.planes[x];
    oread(file, &p.opt, 1);
    oread(file, &p.disp, 1);
    oread(file, &p.nr.c0, 1);
    oread(file, &p.nr.cn, 1);
    oread(file, &p.mid, 2);
    oread(file, &p.nr.n, 2);
    oread(file, &p.num, 2);
    oread(file, &p.v, 2*o.planes[i].num);
    p.v[p.num]=p.v[0];
    switch (p.disp)
    {
    case DISP_TEXT:
    case DISP_TEXTX:
      oread(file, &p.textnum, 2);
    case DISP_SHADED:
      oread(file, &p.ct, 4*p.num);
      p.ct[p.num]=p.ct[0];
      break;
    }
  }

  short buflen;
  oread(file, &buflen, 2);
  events=new char[buflen];
  oread(file, events, buflen);
  evptr=events;
  active=1;

  t=new transform(file);
};

stdobject::~stdobject()
{
  delete events;
  delete t;
}

void stdobject::getobject(const matrix &m)
{
  while (*(long*)evptr<=curtime)
  {
//    long t=*(long*)evptr;
    char cmd=evptr[4];
    evptr+=5;
    switch (cmd)
    {
    case 0:
      active=0;
      break;
    case 1:
      active=1;
      break;
    case 2:
      o.id=*evptr++;
      break;
    }
  }

  if (!active)
    return;
  matrix x;
  t->makexform(x);
  matmul(o.xform, m, x);
  addobject(o);
}

objectnode::objectnode(int file)
{
  oread(file, &objnum, 1);
  short i;
  o=new object*[objnum];
  for (i=0; i<objnum; i++)
    o[i]=readobject(file);
  t=new transform(file);
};

objectnode::~objectnode()
{
  short i;
  for (i=0; i<objnum; i++)
    delete o[i];
  delete o;
  delete t;
}

void objectnode::getobject(const matrix &m)
{
  matrix x;
  t->makexform(x);
  matmul(x, m, x);
  short i;
  for (i=0; i<objnum; i++)
    o[i]->getobject(x);
}

lightobject::lightobject(int file)
{
  intens=dtol(5);
  t=new transform(file);
}

lightobject::~lightobject()
{
  delete t;
}

void lightobject::getobject(const matrix &m)
{
  if (!intens)
    return;
  matrix x;
  t->makexform(x);
  matmul(x, m, x);
  vector z={0,0,0};
  vecxform(&z, &z, x, 1);
  addlight(z, intens);
}
