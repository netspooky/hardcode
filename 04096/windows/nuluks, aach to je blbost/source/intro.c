#include <stdlib.h>
#include <math.h>
#ifdef _WIN32
#include <GL/gl.h>
#else
#include "mygl.h"
#endif
#include "main.h"

unsigned char texture_data[256*256];
int texture;

//float colorBlack[4] = { 0.0, 0.0, 0.0, 1.0 };

void
intro_init()
{
  int i, j;
  float x, y, v;
  unsigned char *t = texture_data;

//  srand(31234);
  srand(81234);

  for (i = 256; i >= 0; i--) {
    for (j = 256; j >= 0; j--) {
      x = j;// + 82*sin(5+i*(2*PI*1.0/128));
//      x = j + 82*sin(5+i*(2*PI*1.0/128));
      y = (i + 20*sin(2+j*(5*PI*1.0/128)));
//      y = i;
      v = 0.5 + 0.25*sin(x*(2*PI/128))+0.25*sin(y*(3*PI/128));
      *t++ = 256*pow(v, 6);
    }
  }
  //  memcpy(texture_data, synth_render, sizeof(texture_data)) ;

  glMatrixMode(GL_PROJECTION);
  glFrustum(-0.01, 0.01, -0.0075, 0.0075, 0.01, 1000.0);
  glMatrixMode(GL_MODELVIEW);
  
  glGenTextures(1, &texture);
  glBindTexture(GL_TEXTURE_2D, texture);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_ALPHA, 256, 256, 0, GL_ALPHA, GL_UNSIGNED_BYTE, texture_data);
  
  glFogf(GL_FOG_DENSITY, 0.2);
  glEnable(GL_FOG);
}

int time;

void
vertex(int j, int i, int oi, int oj, int k) 
{
  float x, y, z;
#if 0
  x = 3 * i / 63.0/4 + time*0.0004;
  y = j / 63.0;
#elif 0
  x = 3 * (j) / 63.0/4 + time*0.0004/* - 0.35*oi*/;
  y = i / 63.0 + 0.1*sin(j*0.2);
#else
  x = i / 63.0 + time * 0.0006 - 0.4*k - 0.35 * oi;
  y = j / 63.0 + 0.1*sin(i*0.3);
#endif
  // y = 1 * j / 63.0+ 0.1*sin(i*0.2);
  //x = i / 63.0;
  glTexCoord2f(x, y);
  x = 0.7*cos(j*(2*PI/63.0));
  y = 0.7*sin(j*(2*PI/63.0));
  z = (i - 32) / 4.0;
  glVertex3f(x, y, z);
}


void
intro_run(int tim)
{
  int i, j, u, v, k, t, t2;
  static float vertices[64][64][5];
  static float ox, oy, oz, or;
  static int t3 = 100000000;
  float x, y, z, a;
  time = tim;

  t = time*441/16/10;
  a = 0.0;
  if (t > 11*3692 && t < 44*3692) {
    a = 0.7 - 3.7 * ((4*t)%5088) / 5088.0;
  }
  //  a = 1.0 - 2*((time*441/4/10) % (5088)) / (5088.0);
  glClearColor(a, a, a, 1.0);
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  t2 = ((t/2)%5088);
  if (t3 > t2) {
    ox = ((rand() & 511) - 255) / 1955.0;
    oy = ((rand() & 511) - 255) / 1955.0;
    oz = ((rand() & 511) - 255) / 1955.0;
    or = 560 * ((rand() & 511) - 255) / 255.0;
//    printf("ad %f %f %f %f\n", ox, oy, oz, or);
  }
  t3 = t2;
  
  glLoadIdentity();
  // glTranslatef(0.0, 0.0, -3.1);
  x = pow(0.5+0.5*sin(time*0.0001), 10);
  //  x = 0;
  //glTranslatef(0.9*sin(PI+time*0.0007), -0.9*cos(PI/2+time*0.0013), x-3.1);
  glTranslatef(ox+0.2*sin(PI+time*0.0007), oy+-0.2*sin(time*0.0013), oz+x-2.3);
  glRotatef(or+time*0.01, 1.0, 0.9, 0.8);
  
  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE);
  glEnable(GL_TEXTURE_2D);

  k = 1;
  do {
    glColor3ub(100+95*0.5+95*0.5*cos(time*0.0004)+20*k, 100+95*0.5+95*0.5*sin(time*0.00007)+20*k, 0);
    glBegin(GL_QUADS);
    for (i = 0; i < 63; i++) {
      for (j = 0; j < 63; j++) {
	vertex(i  , j  , i, j, k);
	vertex(i+1, j  , i, j, k);
	vertex(i+1, j+1, i, j, k);
	vertex(i  , j+1, i, j, k);
      }
    }
    glEnd();
    glScalef(1.15, 1.15, 1.15);
  } while (k--);
  
} 

