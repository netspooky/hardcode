// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#include <string.h>
#include "fmatrix.h"
#include "polygons.h"
#include "keyboard.h"
#include "fmath.h"
#include "lrbfiles.h"
#include "space.h"
#include "texgen.h"
#include "objgen.h"
#include "roto.h"
#include "pal.h"
#include "tunnel.h"

long gettimer();
extern long songposA00;
extern long songpos1400;
extern long songpos200;
extern long songpos800;
extern long songpos1100;
extern long songpos1D00;


void addtex(float angle, int zoom, int xmid, int ymid, unsigned char *map, int first);

extern unsigned char *globalalignedpool;
extern unsigned char *globalscrptr;
void globalcopyscr();


void stonepal(unsigned char *pal)
{
  int i;
  for (i=0; i<8; i++)
    palMakeBCW(pal+i*32*3, 16+4*i+((i+2)%3)*3, 16+3*i+(i&1)*4, 16+2*i+(i%3)*2, 18, 14);
}


void vectorfacepre()
{
//face
  int i,j;
  unsigned char *alignedpool=globalalignedpool;

  unsigned char *mempool=new unsigned char [4*65536];
  unsigned char (*alignedpool2)[65536]=(unsigned char (*)[65536])(((unsigned long)mempool+65535)&~65535);

  unsigned char (*maps)[65536]=(unsigned char (*)[65536])(alignedpool+0x00000);
  unsigned char (*tempbufs)[65536]=alignedpool2;

  signed char fns[768];
  signed char *xfn=(signed char*)(((unsigned long)fns+0xFF)&~0xFF);
  signed char *yfn=(signed char*)(((unsigned long)fns+0x1FF)&~0xFF);

  txPlasmaMap(tempbufs[0],6,2000,0x17091977);
  txDecodeBWMap(tempbufs[0], SVIK_RLE, 0, -1);
  for (i=0; i<0x10000; i++)
    tempbufs[0][i]+=0xC0;
  txSmoothMap(maps[5], tempbufs[0]);

  txDecodeBWMap(maps[4], SLBONG_RLE, 0x00, 0xC0);

//knot
  txPlasmaMap(tempbufs[0],3,500,0x17091977);
  txPlasmaMap(tempbufs[1],8,500,1235);
  txPlasmaMap(tempbufs[2],8,500,1143);

  for (i=0; i<256; i++)
  {
//    xfn[i]=-150*fsin(i*0.04);
//    yfn[i]=150*fcos(i*0.04);
//    xfn[i]=-60*fsin(i*0.1)+20*fsin(i*0.2);
//    yfn[i]=60*fcos(i*0.1);
    xfn[i]=tempbufs[2][i]/2-80*fsin(i*0.04);
    yfn[i]=tempbufs[1][i]/2+80*fcos(i*0.04);
  }
  txTwirlify(maps[7], tempbufs[0], tempbufs[1], tempbufs[2], xfn, yfn);
  for (i=0; i<65536; i++)
    maps[7][i]<<=5;

  txHexagonMap(tempbufs[0], 5, 8, 0x45, 0x4C, 0x54);
  txSmoothMap(maps[8], tempbufs[0]);

//braid
  txPlasmaMap(tempbufs[0],6,2000,0x17091977);


  txPlasmaMap(tempbufs[1],8,500,1234235);
  txPlasmaMap(tempbufs[2],8,100,1142343);

  for (i=0; i<256; i++)
  {
    xfn[i]=-50*fsin(i*0.2);
    yfn[i]=30*fsin(i*0.2);
  }
  txTwirlify(tempbufs[1], tempbufs[0], tempbufs[1], tempbufs[2], xfn, yfn);

  txDecodeBWMap(tempbufs[1], CUBSEEN_RLE, 0, -1);
  for (i=0; i<0x10000; i++)
    tempbufs[1][i]+=0xC0;
  txSmoothMap(maps[12], tempbufs[1]);

  unsigned char (*mapptr)[65536]=maps;


//duck
  unsigned short *remapX=(unsigned short *)(maps[16]);
  int p;
  for (p=0; p<64000; p++)
  {
    i=(p&7)+((p>>6)%40)*8-160;
    j=((p>>3)&7)+(p/2560)*8-100;
    if (i||j)
      remapX[p]=(unsigned char)(fpatan(j, i)*256/(2*M_PI)+128)+256*(unsigned char)(5000/fsqrt(i*i+j*j));
    else
      remapX[p]=0;
  }

// multimap
  txSeenMap(tempbufs[0]);
  txSmoothMap(maps[18], tempbufs[0]);

// morf

  txPlasmaMap(tempbufs[0], 8, 10000, 0x12345678);
  txPlasmaMap(tempbufs[1],8,100,1235);
  txPlasmaMap(tempbufs[2],8,400,1143);

  for (i=0; i<256; i++)
  {
    xfn[i]=-70*fsin(i*0.05);
    yfn[i]=70*fcos(i*0.05);
  }
  txTwirlify(tempbufs[1], tempbufs[0], tempbufs[1], tempbufs[2], xfn, yfn);

  txDecodeBWMap(tempbufs[2], CUBSEEN_RLE, 0, 255);
  txSmoothMap(tempbufs[0], tempbufs[2]);
  txSmoothMap(tempbufs[2], tempbufs[0]);
  txSmoothMap(tempbufs[0], tempbufs[2]);
  txSmoothMap(tempbufs[2], tempbufs[0]);

  for (i=0; i<256; i++)
  {
    xfn[i]=-10*fsin(i*0.05);
    yfn[i]=10*fcos(i*0.05);
  }
  txTwirlify(maps[19], tempbufs[1], tempbufs[2], tempbufs[2], xfn, yfn);

// phong
  for (j=0; j<256; j++)
    for (i=0; i<256; i++)
    {
      float rad=((i-128)*(i-128)+(j-128)*(j-128))/16384.0;
      if (rad>0.9)
        rad=0.9;
      char col1=(59+fpow(1-rad/6, 100)*128+((rad<0.003)?32:0)+(1-rad)*32)/4;
       mapptr[0][0]=col1;
       mapptr[9][0]=col1;
       mapptr[1][0]=col1+64;
      mapptr[10][0]=col1+64;
/*
       maps[0][j*256+i]=(59+fpow(1-rad/6, 100)*128+((rad<0.003)?32:0)+(1-rad)*32)/4+0;
       maps[1][j*256+i]=(59+fpow(1-rad/6, 100)*128+((rad<0.003)?32:0)+(1-rad)*32)/4+64;
      maps[15][j*256+i]=(59+fpow(1-rad/6, 100)*128+((rad<0.003)?32:0)+(1-rad)*32)/4+64;
      maps[14][j*256+i]=(59+fpow(1-rad/6, 100)*128+((rad<0.003)?32:0)+(1-rad)*32)/4+192;
      maps[10][j*256+i]=(50+fpow(1-rad/6, 100)*128+((rad<0.003)?32:0)+(1-rad)*40)/4+64;
       maps[9][j*256+i]=(50+fpow(1-rad/6, 100)*128+((rad<0.003)?32:0)+(1-rad)*40)/4+0;
*/
      maps[6][j*256+i]=(int)(fpow(1-rad/6, 100)*128+(1-rad)*96+30)>>3;
      char col2=(59+(1-rad)*32+fpow(1-rad/6, 50)*48)/4;
      char col3=(59+(1-rad)*32)/4;

      float rad2=((i-100)*(i-100)+(j-80)*(j-80))/16384.0;
      if (rad2>0.9)
        rad2=0.9;
      char col4=(59+fpow(1-rad2/6, 100)*128+((rad2<0.003)?32:0)+(1-rad2)*32)/4;

      mapptr[15][0]=col4+64;
      mapptr[14][0]=col4+192;

       mapptr[3][0]=col2+128;
      mapptr[13][0]=(59+(1-rad2)*32)/2+128;
       mapptr[2][0]=col2;
      mapptr[11][0]=col3;
/*
       maps[3][j*256+i]=(59+(1-rad)*32)/4+128;
      maps[13][j*256+i]=(59+(1-rad)*32)/4+128;
       maps[2][j*256+i]=(59+(1-rad)*32)/4;
      maps[11][j*256+i]=(30+(1-rad)*40)/4;
*/

      mapptr=(unsigned char (*)[65536])((unsigned char*)mapptr+1);
    }

  delete mempool;
}

void vectorface()
{
//  if (gettimer()>=songpos517)
//    return;

  palSetWhiteness();
  memset((void*)0xa0000, 0, 64000);

  int i,j;

  unsigned char (*maps)[65536]=(unsigned char (*)[65536])(globalalignedpool+0x00000);


  unsigned char replayr[256];
  txDecodeBWMap(globalscrptr, FONT_RLE, 0, 63);
  for (i=0; i<16; i++)
    memcpy(replayr+i*16, globalscrptr+5*256*16+2*16+i*256, 16);

  unsigned char pal[768];

  spcPar.phongbufs=maps;

  facelist face_f,glove_f;
  vertlist face_v,face_vhit,glove_v,face_vstr;

  spcReadFaces(face_f, BOX_F_FCS);

  spcReadFaces(glove_f, BOX_G_FCS);

  spcReadVerts(face_v, BOX_F0_VRT);
  spcCalcNorms(face_v, face_f);

  spcCopyVerts(face_vstr, face_v);
  for (i=0; i<face_vstr.nverts; i++)
  {
    face_vstr.verts[i].v[0]*=1.6;
    face_vstr.verts[i].v[1]*=5.9;
    face_vstr.verts[i].v[2]*=1;
  }
  spcCalcNorms(face_vstr, face_f);

  spcReadVerts(face_vhit, BOX_F1_VRT);
  spcCalcNorms(face_vhit, face_f);

  spcReadVerts(glove_v, BOX_G_VRT);
  spcCalcNorms(glove_v, glove_f);

  for (i=0; i<glove_v.nverts; i++)
  {
    glove_v.mapping[i].v[0]=144*65536-4.5*65536*glove_v.verts[i].v[0];
    glove_v.mapping[i].v[1]=120*65536-4.5*65536*glove_v.verts[i].v[2];
  }

  spcInit(2*(face_v.nverts+glove_f.nfaces), 2*(face_f.nfaces+glove_f.nfaces));

  spcSetScreen(320, 200, 240);

  palMakeBCW(pal, 26, 34, 63, 32, 32);
  palMakeBCW(pal+64*3, 63, 22, 28, 32, 32);
  palMakeBCW(pal+128*3, 60, 50, 25, 32, 32);
  palMakeBCW(pal+192*3, 32, 32, 32, 32, 32);

  polyPar.scrptr=globalscrptr;

  long starttime=songpos200;

  while (!kbCheckESC())
  {
    float frametime=(gettimer()-starttime)/65536.0;

    if (frametime>19)
      break;

    if (frametime>18.5)
      palFadeBlack(pal, 0, 256, (19-frametime)*2*64);
    if (frametime<0.5)
      palFadeWhite(pal, 0, 256, frametime*2*64);
    else
    if (frametime<1)
      palSetPal(pal, 0, 256);

    float glovetime=frametime;

    int part=0;
    if (frametime>2.8)
      part=1;
    if (frametime>5.5)
      part=2;
    if (frametime>11.5)
    {
      part=3;
      glovetime=9+(frametime-11.5)/4;
    }

    if (part==0)
    {
      spcPar.phongofsx=65536*50*fcos(frametime*2);
      spcPar.phongofsy=65536*30*fsin(frametime*2);
    }
    else
      spcPar.phongofsx=spcPar.phongofsy=0;

    float texangle=frametime/2;
    if (part&1)
      texangle*=-1;
    addtex(texangle, 65536*1.5*(1+fsin(frametime/3)*0.6), 0, 0, maps[5], 1);

    float glovepos=-1300-400+(glovetime-2.8)*250;

    if (glovepos>-14)
      glovepos=-41;
    else
    if (glovepos>-68)
      glovepos-=(glovepos+68)*(glovepos+68)/108;
    float facehitmorf=1+(glovepos+41)/27;
    if (facehitmorf<0)
      facehitmorf=0;
    if (facehitmorf>1)
      facehitmorf=1;
    if (glovetime>9.5)
      glovepos-=(1-fcos((glovetime-9.5)*M_PI/1.5))*100;
    if (glovetime>11)
      glovepos=-241;

    fmatrix cam;
    fvector campos;
    fvector camtar;
    float zoom=3;
    if ((part==0)||(part==2))
    {
      campos.set(87,-197,-8);
      camtar.set(97,-13,-3);
      if (frametime>6.7)
      {
        campos.v[1]+=(1-fcos((frametime-6.7)*M_PI/2))*75;
        campos.v[0]-=(1-fcos((frametime-6.7)*M_PI/2))*100;
        camtar.v[1]-=(1-fcos((frametime-6.7)*M_PI/2))*10;
      }
      if (frametime>8.7)
      {
        campos.v[1]=-47-(1-fcos((frametime-8.7)*M_PI/2))*30;
        campos.v[0]=-113+(1-fcos((frametime-8.7)*M_PI/2))*60;
        campos.v[2]=-8+(1-fcos((frametime-8.7)*M_PI/2))*25;
        camtar.v[1]=-33;
      }
      if (frametime>10.7)
      {
        campos.v[0]=-113+120;
        campos.v[1]=-47-60;
        campos.v[2]=-8+50;
      }
    }
    if (part==1)
    {
      campos.set(40,197-1300,-8);
      camtar.set(97,-13-1300,-3);
    }
    if (part==3)
    {
      campos.set(-113+120+200,-47,-8-50);
      camtar.set(99, glovepos+50,-3.9);
    }

    fvector camupvec={0,0,1};
    fvector camdir;
    fmatrix rot;
    spcCalcCamMatrix(cam, campos, camtar, camupvec, 0);

    spcInitScenery(zoom, 10);

    fmatrix facetrans;
    fvector facemid={99,3.7,-3.9};
    fmatmakemove(facetrans, facemid);
    fmatmul(facetrans, cam, facetrans);

    fmatrix rot1;
    fvector nz={0,1,0};
    fmatmakerot(rot1, nz, (frametime-4)/1.5);
    fmatrix glovetrans;
    fvector glovemid;

    glovemid.set(99,glovepos,-3.9);
    fmatmakemove(glovetrans, glovemid);
    if (part==1)
      fmatmul(glovetrans, glovetrans, rot1);
    fmatmul(glovetrans, cam, glovetrans);

    if (part!=0)
      spcPutObject(glove_f, glove_v, glovetrans, 30);

    if (part!=1)
    {
      float facemorf=0;
      if (frametime>5.5)
        facemorf=fsin((frametime-5.5)*M_PI/2);
      if (frametime>7.5)
        facemorf=0;
      if (facehitmorf)
        spcPutMorfVerts(face_v, face_vhit, facehitmorf, facetrans, 0);
      else
        spcPutMorfVerts(face_v, face_vstr, facemorf, facetrans, 0);
      spcPutFaces(face_f.faces, face_f.nfaces, face_v.nverts, 14);
    }

    spcDrawScenery();

    if ((part==3)&&((int)(frametime*3)&1))
    {
      for (i=0; i<12; i++)
        memcpy(globalscrptr+288+16*320+i*320, replayr+i*16, 14);
    }

    globalcopyscr();
  }

  palSetBlackness();
  memset((char*)0xA0000, 0, 64000);

  spcClose();
  spcFreeFaceList(face_f);
  spcFreeFaceList(glove_f);
  spcFreeVertList(face_v);
  spcFreeVertList(face_vhit);
  spcFreeVertList(glove_v);
}


static float trefoilpath(fvector &v0, fvector &v1, float t)
{
  float c2=1.8*fcos(2*t);
  float s2=1.8*fsin(2*t);
  float c1=1.0*fcos(t);
  float s1=1.0*fsin(t);

  v0[0]=c2-c1;
  v0[1]=s2+s1;
  v0[2]=0.8*fsin(3*t);
  v1[0]=-2*s2+s1;
  v1[1]=2*c2+c1;
  v1[2]=3*0.8*fcos(3*t);
  return 0.4;
}

void trefoilknot()
{
//  if (gettimer()>=songposA00)
//    return;
  long starttime=songpos800;

  int i,j;

  unsigned char (*maps)[65536]=(unsigned char (*)[65536])(globalalignedpool+0x00000);

  spcPar.phongbufs=maps;

  facelist torus_f;
  vertlist torus_v;

  spcGetToroidFaceList(torus_f, 48, 6, 20, 20);
  spcGetToroidVertList(torus_v, 48, 6, trefoilpath, 3.8, 0, 65536*256, 65536*1792);

  spcInit(torus_f.nfaces, 2*torus_f.nfaces);

  spcSetScreen(320, 200, 240);

  unsigned char pal[768];
  stonepal(pal);

  polyPar.scrptr=globalscrptr;

  while (!kbCheckESC())
  {
    if (gettimer()>=songposA00)
      break;

    float frametime=(gettimer()-starttime)/(65536.0*0.681818);
    if (frametime<0.5)
      palFadeWhite(pal, 0, 256, frametime*2*64);
    if (frametime>15)
      palFadeBlack(pal, 0, 256, (16-frametime)*64);

    addtex(1.5*(ffabs(fprem(frametime, 2)-1)-0.5), -65536/2, 160, 100, maps[8], 1);

    fmatrix cam;
    fvector campos={0,-3.8,0};
    fvector camtar={0,0,0};
    fvector camupvec={0,0,1};
    spcCalcCamMatrix(cam, campos, camtar, camupvec, frametime*0.1);

    spcInitScenery(2, 0.5);

    fmatrix rot;
    fvector xvec={1,0,0};
    fvector yvec={0,1,0};
    fmatmakerot(rot, yvec, frametime/4.23892476+12);
    fmatmul(cam, cam, rot);
    fvectransformv(&xvec, rot, &xvec, 1);
    fmatmakerot(rot, xvec, frametime/2.53892476+0.4);
    fmatmul(cam, cam, rot);

    if (frametime<2)
    {
      fvector pos;
      pos.set(0, 3*(1-fcos(frametime-2)), 5*(1-fcos(frametime-2)));
      fmatmove(cam, pos);
    }

    spcPutObject(torus_f, torus_v, cam, 16);

    spcDrawScenery();

    globalcopyscr();
  }

  spcClose();
  spcFreeFaceList(torus_f);
  spcFreeVertList(torus_v);

  palSetBlackness();
  memset((char*)0xA0000, 0, 64000);
}

static float braidphase;

float threebraitpath(fvector &v0, fvector &v1, float t)
{
#define ROUNDS 5
#define R1 0.7
#define R2 2.5
  float c1=R1*fcos(2*ROUNDS*t+2*braidphase);
  float s1=R1*fsin(2*ROUNDS*t+2*braidphase);
  float c2=R1*fcos(ROUNDS*t+braidphase);
  float s2=R1*fsin(ROUNDS*t+braidphase);
  float c3=fcos(3*t);
  float s3=fsin(3*t);

  v0[0]=(s1+R2)*c3;
  v0[1]=(s1+R2)*s3;
  v0[2]=s2;
  v1[0]=2*ROUNDS*c1*c3-3*(s1+R2)*s3;
  v1[1]=2*ROUNDS*c1*s3+3*(s1+R2)*c3;
  v1[2]=ROUNDS*c2;
  return 0.25;
}

void THEBRAID()
{
//  if (xmpGetPos()>=0x1400)
//    return;
  long starttime=songpos1100;

  int i,j;
  unsigned char *alignedpool=globalalignedpool;

  unsigned char (*maps)[65536]=(unsigned char (*)[65536])(alignedpool+0x00000);

  spcPar.phongbufs=maps;

  facelist torus_f;
  vertlist torus_v;

  braidphase=0;
  spcGetToroidFaceList(torus_f, 80, 6, 30, 31);
  spcGetToroidVertList(torus_v, 80, 6, threebraitpath, 0, 0, 65536*256, 65536*3072);

  spcInit(torus_f.nfaces, 2*torus_f.nfaces);

  spcSetScreen(320, 200, 240);

  unsigned char pal[768];
  palMakeBCW(pal, 15, 30, 63, 32, 32);
  palMakeBCW(pal+64*3, 8, 8, 8, 32, 32);
  palMakeBCW(pal+192*3, 32, 32, 32, 48, 16);
  palSetPal(pal, 0, 256);

  polyPar.scrptr=globalscrptr;

  while (!kbCheckESC())
  {
    if (gettimer()>=songpos1400)
      break;

    float frametime=(gettimer()-starttime)/(65536.0*0.681818);

    addtex(frametime/3, 65536*(1+fsin(frametime/4)*0.6), 0, 0, maps[12], 1);

    int part=0;
    if (frametime>16)
      part=1;
    if (frametime>32)
      part=2;
    if (frametime>40)
      part=3;

    fmatrix cam;
    fvector campos={0,-4,0};
    fvector camtar={0,0,0};
    fvector camupvec={0,0,1};
    fvector rgt={1,0,0};
    fvector camdir;
    fmatrix rot;
    fvecsub(camdir, campos, camtar);
    fmatmakerot(rot, camupvec, -frametime*0.3+0.3);
    fvectransformn(&camdir, rot, &camdir, 1);
    fmatmakerot(rot, rgt, -frametime*0.2);
    fvectransformn(&camdir, rot, &camdir, 1);
    fvecadd(campos, camtar, camdir);
    spcCalcCamMatrix(cam, campos, camtar, camupvec, frametime*0.1);
    float zoom=2;

    spcInitScenery(zoom, 0.5);

    int facenum;
    if (part==0)
      facenum=frametime*30;
    if (part==1)
      facenum=480;
    if (part==2)
      facenum=480+(frametime-32)*60;
    if (part==3)
      facenum=960;
    braidphase=frametime-16;
    if (part>=1)
      spcGetToroidVerts(spcPar.vertbuf+spcPar.nverts, spcPar.normbuf+spcPar.nverts, cam, 80, 6, threebraitpath, 0, (frametime-16)/5.5);
    else
      spcPutVerts(torus_v, cam, 0);
    spcPutFaces(torus_f.faces, facenum, torus_v.nverts, (facenum<720));

    spcDrawScenery();

    globalcopyscr();
  }

  palSetWhiteness();
  memset((char*)0xA0000, 0, 64000);

  spcClose();
  spcFreeFaceList(torus_f);
  spcFreeVertList(torus_v);
}


static float torusradius;

static float toruspath(fvector &v0, fvector &v1, float t)
{
  float c1=1000*fcos(t);
  float s1=1000*fsin(t);
  v0.v[0]=c1;
  v0.v[1]=s1*0.9397;
  v0.v[2]=-s1*0.3420;
  v1.v[0]=-s1;
  v1.v[1]=c1*0.9397;
  v1.v[2]=-c1*0.3420;
  return torusradius;
}

void ente()
{
  long starttime=songpos1D00;

  int i,j;

  unsigned char (*maps)[65536]=(unsigned char (*)[65536])(globalalignedpool+0x00000);

  spcPar.phongbufs=maps;

  facelist duck_f,torus_f;
  vertlist duck_v,duck_vthr,duck_vhd[4];

  spcReadFaces(duck_f, THROT_D_FCS);

  spcReadVerts(duck_v, THROT_D0_VRT);
  spcCalcNorms(duck_v, duck_f);

  fmatrix nickrot[4];
  fvector nickrotax[4]={{1,0,0},{1,0,0},{0,0,1},{0,0,1}};
  float nickrotang[4]={-0.8,1.2,-1.3,1.3};

  for (j=0; j<4; j++)
  {
    fmatmakerot(nickrot[j], nickrotax[j], nickrotang[j]);
    spcCopyVerts(duck_vhd[j], duck_v);
    for (i=0; i<duck_v.nverts; i++)
      if (duck_v.verts[i].v[2]>275)
      {
        duck_vhd[j].verts[i].v[1]-=675;
        duck_vhd[j].verts[i].v[2]-=485;
        fvectransformv(duck_vhd[j].verts+i, nickrot[j], duck_vhd[j].verts+i, 1);
        duck_vhd[j].verts[i].v[1]+=675;
        duck_vhd[j].verts[i].v[2]+=485;
      }
    spcCalcNorms(duck_vhd[j], duck_f);
  }

  spcReadVerts(duck_vthr, THROT_D1_VRT);
  spcCalcNorms(duck_vthr, duck_f);

  spcGetToroidFaceList(torus_f, 16, 8, 40, 40);

  spcInit(2*(duck_v.nverts)+torus_f.nfaces, 2*(duck_f.nfaces+torus_f.nfaces));

  spcSetScreen(320, 200, 240);

  unsigned char pal[768];
  palInterpolCols(pal, 0,0,0, 0,0,0, 16);
  palInterpolCols(pal+48, 0,0,0, 16,0,0, 16);
  palInterpolCols(pal+96, 16,0,0, 48,16,0, 16);
  palInterpolCols(pal+144, 48,16,0, 63,48,32, 16);
  palMakeBCW(pal+64*3, 32, 16, 48, 32, 32);
  palInterpolCols(pal+128*3, 0,0,0, 63,63,16, 64);
//  palMakeBCW(pal+128*3, 63, 63, 16, 63, 0);
  palMakeBCW(pal+192*3, 32, 32, 32, 32, 32);

  polyPar.scrptr=globalscrptr;

  unsigned char *mapptrX=new unsigned char [65536*2];
  unsigned char rotptrX[1024];

  unsigned char *mapX=(unsigned char*)(((unsigned long)mapptrX+0xFFFF)&~0xFFFF);
  unsigned short *rotmapX=(unsigned short*)(((unsigned long)rotptrX+0x1FF)&~0x1FF);



  txPlasmaMap(mapX, 6, 1000, 0x12312312);

  unsigned short *remapX=(unsigned short *)(maps[16]);

  unsigned short ofs;

  while (!kbCheckESC())
  {
    float frametime=(gettimer()-starttime)/(65536*0.68181818);

    for (i=0; i<256; i++)
      rotmapX[i]=(i+fsin(frametime+2*M_PI*i/256)*300)+((unsigned char)(ofs+fcos(frametime+2*M_PI*i/256)*50)<<8);
    wobbletunnel(globalscrptr, mapX, remapX, rotmapX);
    ofs=-frametime;

    if (frametime<1)
      palFadeBlack(pal, 0, 256, frametime*64);
    else
    if (frametime<1.5)
      palSetPal(pal, 0, 256);

    if (frametime>23.5)
    {
      palFadeWhite(pal, 0, 256, (24.5-frametime)*64);
//      xmpSetVolume((24.5-frametime)*63);
    }
    if (frametime>24.5)
      break;

    fmatrix cam;
    fvector campos={-4000,4000,600};
    fvector camtar={990,30,200};
    fvector camupvec={0,0,1};
    spcCalcCamMatrix(cam, campos, camtar, camupvec, 0);

    spcInitScenery(3.5, 20);

    fmatrix ducktrans,torustrans;

    fvector duckmid={990,30.7,-30.9};
    if (frametime<12.5)
      duckmid.v[1]+=800*(frametime-12.5);
    fmatmakemove(ducktrans, duckmid);
    fmatmul(ducktrans, cam, ducktrans);

    float duckmorf=ffabs(fsin(frametime*2*M_PI));
    vertlist *duck_vmb=&duck_vhd[0];
    if (frametime>=13)
      duckmorf=0;
    if (frametime>=14)
    {
      duckmorf=(1-fcos(frametime*M_PI*2))/2;
      duck_vmb=&duck_vhd[2];
    }
    if (frametime>=14.5)
      duckmorf=1;
    if (frametime>=15)
      duckmorf=ffabs(fcos((frametime-15)*M_PI));
    if (frametime>=15.5)
      duck_vmb=&duck_vhd[3];
    if (frametime>=16)
      duckmorf=1;
    if (frametime>=16.5)
      duckmorf=(1-fcos(frametime*M_PI*2))/2;
    if (frametime>=17)
      duckmorf=0;
    if (frametime>=18)
    {
      duckmorf=-fsin(frametime*M_PI/2);
      duck_vmb=&duck_vhd[1];
    }
    if (frametime>=19)
      duckmorf=1;
    if (frametime>=20)
      duckmorf=fcos(frametime*M_PI/2);
    if (frametime>=21)
      duckmorf=0;
    if (frametime>=22.5)
    {
      duckmorf=fsin((frametime-22.5)*M_PI);
      duck_vmb=&duck_vthr;
    }
    if (frametime>=23)
      duckmorf=1;

    fvector torusmid={990,700,300+3000};
    if (frametime>=19)
      torusmid.v[2]-=(1-fcos((frametime-19)/2*M_PI))*1500;
    if (frametime>=21)
      torusmid.v[2]=300;
    fmatmakemove(torustrans, torusmid);
    fmatmul(torustrans, cam, torustrans);
    torusradius=100;
    if (frametime>22)
      torusradius+=(1-fcos((frametime-22)*M_PI))*300;
    if (frametime>23)
      torusradius=700;

    spcPutMorfVerts(duck_v, *duck_vmb, duckmorf, ducktrans, 0);
    spcPutFaces(duck_f.faces, duck_f.nfaces, duck_v.nverts, 4);

    spcGetToroidVerts(spcPar.vertbuf+spcPar.nverts, spcPar.normbuf+spcPar.nverts, torustrans, 16, 8, toruspath, 0, 0);
    spcPutFaces(torus_f.faces, torus_f.nfaces, torus_f.nfaces/2, 8);

    spcDrawScenery();

    globalcopyscr();
  }

  spcClose();
  spcFreeFaceList(duck_f);
  spcFreeVertList(duck_v);
  spcFreeVertList(duck_vthr);

  palSetWhiteness();
  memset((void*)0xA0000, 0, 64000);
}
