#include "txgen.h"
#include "color.h"
#include ".\z3d\z3d.h"

//this functions was grabbed from simple texture generator by somone...
float catmullrom_interpolate(float v0, float v1, float v2, float v3, float x, float distance)
// v0 and v1 are the 2 random pixels to the left
// v2 and v3 are the 2 random pixels to the right

// .  .  .  .  v0 .  .  .  v1 .  .  .  v2 .  .  .  v3 .  .  .
//                            x  x  x
{
   // make x range from 0 to 1
   float xx = x / distance;
   float P = (v3 - v2) - (v0 - v1);
   float Q = (v0 - v1) - P;
   float R =  v2 - v0;
   return (P*xx*xx*xx) + (Q*xx*xx) + (R*xx) + v1;
}

float spline(float x, int k[], int nk)
{
  float v0,v1,v2,v3;  int i;  

  x *= nk; 
  i = (int)x; 
  x-=(int)x; //tricky code, yeah? 

  if (i-1>=0) 
    v0 = (float)k[i-1]; 
  else 
    v0 = (float)k[i-1+nk];
  v1 = (float)k[i]; // left edge, correct anyway
  if (i+1<nk) 
    v2 = (float)k[i+1]; 
  else 
    v2 = (float)k[i+1-nk];
  if (i+2<nk) 
    v3 = (float)k[i+2]; 
  else 
    v3 = (float)k[i+2-nk];

  return catmullrom_interpolate(v0,v1,v2,v3,x,1);
}

/*void txgFractal(TEXTURE *tx,txProcP *params) {
  int w = tx->GetMetrics(TX_WIDTH);
  int h = tx->GetMetrics(TX_HEIGHT);
  long cc;
  COLOR cx;

  int w2 = w/2;
  int h2 = h/2;
  int limit = (int)params->param1;

  int i, j, k;
  double z_i, z_r, c_i, c_r, tmp;
  double module;

  for( i=-w2; i<w2; i++) {
    c_i = ((double) i) / (w2*1.0f);
    for( j=-h2; j<h2; j++) {
        c_r = ((double) j)/80.0;
        z_i = params->param3;
        z_r = params->param4;
        for( k=0; k<limit; k++) {
            tmp = z_r * z_r - z_i * z_i;

            z_i = 2 * z_r * z_i + c_i;      // z = z * z + c
            z_r = tmp                + c_r;

            module = z_r * z_r + z_i * z_i; // is |z| large enough?
            if( module > 1.0E16 ) break;
        }
        if( k<limit)
          cc = (long)((k/15)*2*params->param2+20);
        else 
          cc = (long)(16*params->param2);

          tx->SetPixel(i+w2, j+h2, cx.XRGB(cc,cc,cc),params->sp_mode,params->sp_param);
    }
  }
}*/

//F(x,y) = Icolor*(cos(a*cos(x+k1)+b*sin(y+k2)))
//pattern
/*void txgPattern1(TEXTURE *tx,txProcP *params) {
  COLOR cc;
  long cx;
  int w = tx->GetMetrics(TX_WIDTH);
  int h = tx->GetMetrics(TX_HEIGHT);
  float a,b,k1,k2;
  a   = params->param1;
  b   = params->param2;
  k1  = params->param3;
  k2  = params->param4;
  float amp = (float)params->l1;

  for(int y=0;y<h;y++) {
    for(int x=0;x<w;x++) {
      cx = (long)(amp*(cos(a*cos(x+k1)+b*sin(y+k2))));
      if(cx>255)
        cx = 255;
      if(cx<0)
        cx = 0;
      cc.ARGB(cx,cx,cx,cx);
      tx->SetPixel(x,y,cc,params->sp_mode,params->sp_param);
    }
  }
}*/

void txgSubplasma(TEXTURE_Z *tx,txProcP *params) {
	#define max_knots 32
  int knots;
  int layer;
  COLOR cx;

	int i,j,c,p;
	int k[max_knots][max_knots];
	int res[max_knots][256];
	int h[max_knots];

  int wt,ht;

  wt = tx->w;
  ht = tx->h;

  knots = (int)params->param1;
  layer = (int)params->param2;

  int step = (int)params->param3;
  if(step==0)
    step = 1;

	if (knots<1) 
    knots=1; 
  if (knots>max_knots) 
    knots=max_knots;		

	for (i=0;i<knots;i++) 
		for (j=0;j<knots;j++) 
			k[i][j]=rand()%255;

   for (i=0;i<256;i++)
     for (j=0;j<knots;j++) {
       for (p=0;p<knots;p++) 
         h[p]=k[p][j];
       res[j][i] = (int)spline(i/256.0f,h,knots);
     }

    for (i=0;i<256;i+=step)
      for (j=0;j<256;j+=step) { 
			  for (p=0;p<knots;p++) 
          h[p]=res[p][j]; 
        c = (int)spline(i/256.0f,h,knots);
        if (c<0) 
          c=0; 
        if (c>255) 
          c=255;

        tx->SetPixel(i,j,
        ((tx->GetPixel(i,j).color&0xfefefe)>>1)+
        ((cx.ARGB(layer==4?c:0,layer==3?c:0,layer==2?c:0,layer==1?c:0).color
        &0xfefefe)>>1)/*,params->sp_mode,params->sp_param*/);
      }  	
/*
  for(i=0;i<max_knots;i++) {
    delete []res[i];
  }*/
}

// <!-- :) -->

/*void txgCreateChecker(TEXTURE *tx,txProcP *params) {
  COLOR c;
  COLOR c1,c2;
  long cellsize;
  int wt,ht;

  wt = tx->GetMetrics(TX_WIDTH);
  ht = tx->GetMetrics(TX_HEIGHT);
  c1 = params->l1;
  c2 = params->l2;
  cellsize = (long)params->param1;
  for (int tj=0;tj<ht;tj++){
    for (int ti=0;ti<wt;ti++){
      c=((ti%cellsize)<cellsize/2)^((tj%cellsize)<cellsize/2)?c1:c2;
      tx->SetPixel(ti,tj,c,params->sp_mode,params->sp_param);
    }
  }
}

void txgCreateSinePlasm(TEXTURE *tx,txProcP *params) {
//void tgCreateSinePlasm(TEXTURE_Z *texture,uint c1,uint c2,double c){
  COLOR cx;
  int wt,ht;
  COLOR c1,c2;
  float c;

  wt = tx->GetMetrics(TX_WIDTH);
  ht = tx->GetMetrics(TX_HEIGHT);
  c1 = params->l1;
  c2 = params->l2;
  c  = params->param1;
  for (int tj=0;tj<ht;tj++){
    for (int ti=0;ti<wt;ti++){
      double k=(sin(3.14*ti/c)+1)/2*(sin(3.14*tj/c)+1)/2;
      cx.alpha(c1,c2,k);
      tx->SetPixel(ti,tj,cx,params->sp_mode,params->sp_param);
    }
  }
}

void txgCreateRadial(TEXTURE *tx,txProcP *params) {
//void tgCreateRadial(TEXTURE_Z *texture,uint c1,uint c2,double c){
  COLOR cx;
  int wt,ht;
  COLOR c1,c2;
  float c;

  wt = tx->GetMetrics(TX_WIDTH);
  ht = tx->GetMetrics(TX_HEIGHT);
  c1 = params->l1;
  c2 = params->l2;
  c  = params->param1;
  for (int tj=0;tj<ht;tj++){
    for (int ti=0;ti<wt;ti++){
      double k=sin(sqrt(pow(ti-wt/2,2)+pow(tj-ht/2,2))/c)/2+1;
      cx.alpha(c1,c2,k);
      tx->SetPixel(ti,tj,cx,params->sp_mode,params->sp_param);
    }
  }
}

void txgCreateEff(TEXTURE *tx,txProcP *params) {
//void tgCreateEff(TEXTURE_Z *texture,uint c1,uint c2,double c){
  COLOR cx;
  int wt,ht;
  COLOR c1,c2;
  float c;

  wt = tx->GetMetrics(TX_WIDTH);
  ht = tx->GetMetrics(TX_HEIGHT);
  c1 = params->l1;
  c2 = params->l2;
  c  = params->param1;
  for (int tj=0;tj<ht;tj++){
    for (int ti=0;ti<wt;ti++){
      double k=sin(ti*tj/c)/2+1;
      cx.alpha(c1,c2,k);
      tx->SetPixel(ti,tj,cx,params->sp_mode,params->sp_param);
    }
  }
}

void txgReSin(TEXTURE *tx,txProcP *params) {
  COLOR cx;
  int wt,ht;
  COLOR c1;
  float c;

  wt = tx->GetMetrics(TX_WIDTH);
  ht = tx->GetMetrics(TX_HEIGHT);
  c  = params->param1;
  for (int tj=0;tj<ht;tj++){
    for (int ti=0;ti<wt;ti++){
      c1 = tx->GetPixel(ti,tj);
      cx.a = (long)(params->l1*sin(c1.a*c));
      cx.r = (long)(params->l1*sin(c1.r*c));
      cx.g = (long)(params->l1*sin(c1.g*c));
      cx.b = (long)(params->l1*sin(c1.b*c));
      tx->SetPixel(ti,tj,cx,params->sp_mode,params->sp_param);
    }
  }
}*/