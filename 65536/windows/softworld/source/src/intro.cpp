// intro.cpp : Defines the entry point for the application.
//

#include <windows.h>

#include <gl\gl.h>			// Header File For The OpenGL32 Library
#include <gl\glu.h>			// Header File For The GLu32 Library

// le decoder de gif
#include "gifdecoder/GifDecoder.h"

#include "lib/minifmod.h"

// les metaballs
#include "metaballs/metalib.h"

// la zik
#include "essai/softwrld.h"

// le Chat
#include "essai/chat.h"

// les objs 3d
#include "essai/glace2.h"
#include "essai/etoile.h"
#include "essai/o_oeuf2.h"
#include "essai/carotte.h"

// la fonte
#include "essai/fnt3.h"

// les textures

#include "essai/fd1b.h"
#include "essai/fd2b.h"
#include "essai/rub.h"
#include "essai/tetoile.h"
#include "essai/tglace9.h"
#include "essai/oeuf9.h"
#include "essai/t_carot9.h"


// le code
#include "3d_intro.h"
#include "normal.h"

#define USEMEMLOAD
#define USEMEMLOADRESOURCE

#define USEFMOD TRUE



// les metaballs
float R1=0.1f;
float R2=0.15f;
float R3=0.11f;
float R4=0.09f;

float xb1 =-0.3f;
float yb1 = 0;
float zb1 = 0;
float xb2 = 0.3f;
float yb2 = 0;
float zb2 = 0;
float xb3,yb3,zb3;
float xb4,yb4,zb4;

float spin=0;
#define DSPIN (float)(3.14/360)
float dspin=DSPIN;
float zoom=1.0;


void force(float x1,float y1,float z1,float x2,float y2,float z2,float *dx,float *dy,float *dz)
{
#define FORCE 40
  float r;
  
  r=(x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1);
  if(r==0.0) r=99999; else r=1/r;

  *dx=(x1-x2)*r/FORCE;
  *dy=(y1-y2)*r/FORCE;
  *dz=(z1-z2)*r/FORCE;
  
}
/*3=Nb boule*/
float TEMP[3*4][128];

float pos_plan=40.0f,pos_barre=0.0f,pos_rubber=+30.0f,pos_meta=11.0f;
// les objets
GLuint		GL_Glace,GL_Potdefleur,GL_Oeuf,GL_Carotte,GL_Etoile;
// les textures
GLuint		T_Glace,T_Potdefleur,T_Env,T_Env2,T_Env3,T_Env4,T_Oeuf,T_Carotte,T_Fond1,T_Fond2,T_Perlin,T_Fonte,T_Rub,T_Etoile,T_Chat;
// les textures tempo
unsigned char	*tglace,*tbrique,*toeuf,*tfd1,*tfd2,*tcarot,*tperlin,*tfonte,*trub,*tfonte2,*tenv,*tenv2,*tenv3,*tenv4,*tetoile,*tchat1,*tchat2;
// Pour la zik
int		ord = 0, row = 0;

Cylindre	*cyl,*tunnel;
Plan		*pl;
float		deform_cyl=0.0f,deform_cyl_val=0.005f,deform_cyl_maxval=1.5f;
float		deform_cyl2=0.0f,deform_cyl_val2=0.008f,deform_cyl_maxval2=4.0f;
float		deform_cyl3=0.0f,deform_cyl_val3=0.005f,deform_cyl_maxval3=4.0f;

// couleur
float		c_fond[3]={0.390625f, 0.390625f, 0.5f};
float		c_noir[3]={0.0f, 0.0f, 0.0f};
float		c_calcul[3]={0.0f, 0.0f, 0.0f};

float		depx = -310,depz = -320,etoilex=-90.8f,poschat=-1.0f;
float		posx_plan = -4.0f,poscarot1 = 200.0f,poscarot2 = 350.0f,poscarot3 = 500.0f;

int			nb_coul=120,nb_coulcal=0;;
int			nbt=1;
int			nbfaces=0;
HDC			hDC=NULL;		// Private GDI Device Context
HGLRC		hRC=NULL;		// Permanent Rendering Context
HWND		hWnd=NULL;		// Holds Our Window Handle
HINSTANCE	hInstance;		// Holds The Instance Of The Application
bool		keys[256];			// Array Used For The Keyboard Routine
bool		active=TRUE;		// Window Active Flag Set To TRUE By Default
float		X=0.0f;

bool		fullscreen = true;
char		bpp = 32;
int			res_x = 640,res_y = 480;
char		quality = 1;
int			max_tab=0;


void fNEG2(float **T,int N2)
{
 static int    off;
 static int    i,j,k,N;
 static float  x,y,z,dt,t;
 static float  dz1,dy1,dx1,r1;
 static float  dz2,dy2,dx2,r2;
 static float  dz3,dy3,dx3,r3;
 static float  dz4,dy4,dx4,r4;
  
 N=1<<N2;
 /*
 size=1<<N;
 
 dec=32/size;

 
 i1=(int)(16*(xb1+1));
 j1=(int)(16*(yb1+1));
 k1=(int)(16*(zb1+1));

 printf("%d %d %d %d\n",i1,j1,k1,dec);

 off1=64*j1+i1;
 
 for(k=0;k<size;k++)
 {
   for(j=0;j<size;j++)
   {
	   l=0;
	   for(i=0;i<size;i++)
	   {
	     T[k][i+(j*1<<N)]=BALL[k1][off1 + l];
	     l+=dec;
	   }
	   off1+=64*dec;
   }
   off1=64*j1+i1;
   k1+=dec;
 }
 */

     dt=2.0f/(float)(N-1);
     t=-1;
     for(k=0;k<N;k++)
       {
         TEMP[0][k]=(t-xb1)*(t-xb1);
	 TEMP[1][k]=(t-yb1)*(t-yb1);
	 TEMP[2][k]=(t-zb1)*(t-zb1);

	 TEMP[3][k]=(t-xb2)*(t-xb2);
	 TEMP[4][k]=(t-yb2)*(t-yb2);
	 TEMP[5][k]=(t-zb2)*(t-zb2);

	 TEMP[6][k]=(t-xb3)*(t-xb3);
	 TEMP[7][k]=(t-yb3)*(t-yb3);
	 TEMP[8][k]=(t-zb3)*(t-zb3);

	 TEMP[9 ][k]=(t-xb4)*(t-xb4);
	 TEMP[10][k]=(t-yb4)*(t-yb4);
	 TEMP[11][k]=(t-zb4)*(t-zb4);
	 
         t+=dt;
       }
 /*
	
     dt=2.0/(float)(N-1);
     x=-1;y=-1;z=-1;
     for(k=0;k<N;k++)
       {
         y=-1;
	 dz1=(z-zb1)*(z-zb1);
	 dz2=(z-zb2)*(z-zb2);
	 dz3=(z-zb3)*(z-zb3);
	 for(j=0;(j<N);j++)
	   {
             off=j<<N2;
             x=-1;
	     dy1=(y-yb1)*(y-yb1);
	     dy2=(y-yb2)*(y-yb2);
	     dy3=(y-yb3)*(y-yb3);
             for(i=0;i<N;i++)
	       {
		 dx1=(x-xb1)*(x-xb1);
		 dx2=(x-xb2)*(x-xb2);
		 dx3=(x-xb3)*(x-xb3);
		 r1=dx1+dy1+dz1;
		 if(r1==0.0) r1=999999;
		 else r1=1/(r1*r1*r1*r1);
		 r2=dx2+dy2+dz2;
		 if(r2==0.0) r2=999999;
		 else r2=1/(r2*r2*r2*r2);
		 r3=dx3+dy3+dz3;
		 if(r3==0.0) r3=999999;
		 else r3=1/(r3*r3*r3*r3);
		 T[k][off+i]=r1+r2-r3;                 
                 x+=dt;
	       }
             y+=dt;
	   }
         z+=dt;
       }
 */


     for(j=0;j<N;j++)
     {
	     for(i=0;i<N;i++)
	     {
		     T[0  ][j*(1<<N2)+i    ]=0;
		     T[N-1][j*(1<<N2)+i    ]=0;
		     T[  j][i*(1<<N2)      ]=0;
		     T[  j][i*(1<<N2)+N-1  ]=0;
		     T[  j][i              ]=0;
		     T[  j][(N-1)*(1<<N2)+i]=0;
	     }
     }

     for(k=1;k<N-1;k++)
       {
         
	 dz1=TEMP[2][k];
	 dz2=TEMP[5][k];
	 dz3=TEMP[8][k];
	 dz4=TEMP[11][k];
	 for(j=1;(j<N-1);j++)
	   {
             off=j<<N2;
             dy1=TEMP[1][j];
	     dy2=TEMP[4][j];
	     dy3=TEMP[7][j];	     
             dy4=TEMP[10][j];
             
             for(i=1;i<N-1;i++)
	       {
		  dx1=TEMP[0][i];
	          dx2=TEMP[3][i];
	          dx3=TEMP[6][i];
                  dx4=TEMP[9][i];

		  r1=dx1+dy1+dz1;
		  if(r1==0.0) r1=999999;
		  else {t=r1*r1;r1=1/(t*t);}

		  r2=dx2+dy2+dz2;
		  if(r2==0.0) r2=999999;
		  else {t=r2*r2;r2=1/(t*t);}

		  r3=dx3+dy3+dz3;
		  if(r3==0.0) r3=999999;
		  else {t=r3*r3;r3=1/(t*t);}

		  r4=dx4+dy4+dz4;
		  if(r4==0.0) r4=999999;
		  else {t=r4*r4;r4=1/(t*t);}

		  T[k][off+i]=0.7f*r1 + 0.8f*r2 - 0.6f*r3 - 0.6f*r4;                 
		  /*
                  if(i==0) T[k][off+i]=0;
		  if(j==0) T[k][off+i]=0;
		  if(k==0) T[k][off+i]=0;
		  if(i==N-1) T[k][off+i]=0;
		  if(j==N-1) T[k][off+i]=0;
		  if(k==N-1) T[k][off+i]=0;
		  */
	       }
             
	   }
         
       }
}


#ifndef USEMEMLOAD
#else

typedef struct 
{
	int length;
	int pos;
	void *data;
} MEMFILE;


unsigned int memopen(char *name)
{
	MEMFILE *memfile;

	memfile = (MEMFILE *)calloc(sizeof(MEMFILE),1);

#ifndef USEMEMLOADRESOURCE
	{	// load an external file and read it
		FILE *fp;
		fp = fopen(name, "rb");
		if (fp)
		{
			fseek(fp, 0, SEEK_END);
			memfile->length = ftell(fp);
			memfile->data = calloc(memfile->length,1);
			memfile->pos = 0;

			fseek(fp, 0, SEEK_SET);
			fread(memfile->data, 1, memfile->length, fp);
			fclose(fp);
		}
	}
#else
	{	// hey look some load from resource code!
		/*HRSRC		rec;
		HGLOBAL		handle;

		rec = FindResource(NULL, name, RT_RCDATA);
		handle = LoadResource(NULL, rec);
		
		memfile->data = LockResource(handle);
		memfile->length = SizeofResource(NULL, rec);
		memfile->pos = 0;*/

		memfile->data = (void *)music;
		memfile->length = MUSIC_LEN;
		memfile->pos = 0;

	}
#endif
	return (unsigned int)memfile;
}

void memclose(unsigned int handle)
{
	MEMFILE *memfile = (MEMFILE *)handle;

#ifndef USEMEMLOADRESOURCE
	free(memfile->data);			// dont free it if it was initialized with LockResource
#endif

	free(memfile);
}

int memread(void *buffer, int size, unsigned int handle)
{
	MEMFILE *memfile = (MEMFILE *)handle;

	if (memfile->pos + size >= memfile->length)
		size = memfile->length - memfile->pos;

	memcpy(buffer, (char *)memfile->data+memfile->pos, size);
	memfile->pos += size;
	
	return size;
}

void memseek(unsigned int handle, int pos, signed char mode)
{
	MEMFILE *memfile = (MEMFILE *)handle;

	if (mode == SEEK_SET) 
		memfile->pos = pos;
	else if (mode == SEEK_CUR) 
		memfile->pos += pos;
	else if (mode == SEEK_END)
		memfile->pos = memfile->length + pos;

	if (memfile->pos > memfile->length)
		memfile->pos = memfile->length;
}

int memtell(unsigned int handle)
{
	MEMFILE *memfile = (MEMFILE *)handle;

	return memfile->pos;
}
#endif


void Affiche_texte(char *texte,long taille,long x,long y, GLuint Texture)
{
	float val = 0.125f,pos;
	float depx,espace,depy,posx,posy;

	depx = 1.1f / ((float)640 / (float)taille);
	espace = depx - 0.015f;
	depy = 0.73f / ((float)480 / (float)taille);
	posx = ((float)x / (float)640) - 0.5f;
	posy = ((float)y / (float)480) - 0.355f;

	glBindTexture(GL_TEXTURE_2D,Texture);
	glDisable(GL_DEPTH_TEST);
	glLoadIdentity();	
	for(long i = 0;texte[i] != '\n';i++)
	{
		if (texte[i] >= 'a' && texte[i] <= 'h')
		{
			glBegin(GL_QUADS);
			pos = float(texte[i] - 'a') * val;
			glTexCoord2f(pos,1.0f - val);		glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - val);	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f);		glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f);				glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
		else if (texte[i] >= 'i' && texte[i] <= 'p')
		{
			glBegin(GL_QUADS);
			pos = float(texte[i] - 'i') * val;
			glTexCoord2f(pos,1.0f - (2 * val));			glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f -  (2 * val));	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - val);			glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f - val);				glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
		else if (texte[i] >= 'q' && texte[i] <= 'x')
		{
			glBegin(GL_QUADS);
			pos = float(texte[i] - 'q') * val;
			glTexCoord2f(pos,1.0f - (3 * val));			glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f -  (3 * val));	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - (2 * val));	glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f - (2 * val));			glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
		else if (texte[i] >= 'y' && texte[i] <= 'z')
		{
			glBegin(GL_QUADS);
			pos = float(texte[i] - 'y') * val;
			glTexCoord2f(pos,1.0f - (4 * val));			glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f -  (4 * val));	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - (3 * val));	glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f - (3 * val));			glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
		else if (texte[i] == '2')
		{
			glBegin(GL_QUADS);
			pos = 2 * val;
			glTexCoord2f(pos,1.0f - (4 * val));			glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f -  (4 * val));	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - (3 * val));	glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f - (3 * val));			glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
		else if (texte[i] == '/')
		{
			glBegin(GL_QUADS);
			pos = 3 * val;
			glTexCoord2f(pos,1.0f - (4 * val));			glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f -  (4 * val));	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - (3 * val));	glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f - (3 * val));			glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
		else if (texte[i] == '.')
		{
			glBegin(GL_QUADS);
			pos = 4 * val;
			glTexCoord2f(pos,1.0f - (4 * val));			glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f -  (4 * val));	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - (3 * val));	glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f - (3 * val));			glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
		else if (texte[i] == ':')
		{
			glBegin(GL_QUADS);
			pos = 5 * val;
			glTexCoord2f(pos,1.0f - (4 * val));			glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f -  (4 * val));	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - (3 * val));	glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f - (3 * val));			glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
		else if (texte[i] == '-')
		{
			glBegin(GL_QUADS);
			pos = 6 * val;
			glTexCoord2f(pos,1.0f - (4 * val));			glVertex3f((i * espace) + posx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f -  (4 * val));	glVertex3f((i * espace) + posx + depx,posy - depy,-1.0f);
			glTexCoord2f(pos + val,1.0f - (3 * val));	glVertex3f((i * espace) + posx + depx,posy,-1.0f);
			glTexCoord2f(pos,1.0f - (3 * val));			glVertex3f((i * espace) + posx,posy,-1.0f);
			glEnd();		
		}
	}
	glEnable(GL_DEPTH_TEST);
}



/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////              O P E N G L   H E R E                  ///////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

LRESULT	CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM);	// Declaration For WndProc

GLvoid ReSizeGLScene(GLsizei width, GLsizei height)		// Resize And Initialize The GL Window
{
	if (height==0)										// Prevent A Divide By Zero By
	{
		height=1;										// Making Height Equal One
	}

	glViewport(0,0,width,height);						// Reset The Current Viewport

	glMatrixMode(GL_PROJECTION);						// Select The Projection Matrix
	glLoadIdentity();									// Reset The Projection Matrix

	// Calculate The Aspect Ratio Of The Window
	//gluPerspective(45.0f,(GLfloat)width/(GLfloat)height,0.1f,100.0f);
	gluPerspective(45.0f,(GLfloat)width/(GLfloat)height,1.0f,500.0f);

	glMatrixMode(GL_MODELVIEW);							// Select The Modelview Matrix
	glLoadIdentity();									// Reset The Modelview Matrix
}

int InitGL(GLvoid)										// All Setup For OpenGL Goes Here
{
	GLfloat		L0dif[]= { 1.0f,1.0f,1.0f};
	GLfloat		L0spe[]= { 1.0f,1.0f,1.0f};

	glEnable(GL_TEXTURE_2D);							// Enable Texture Mapping
	//glShadeModel(GL_SMOOTH);							// Enable Smooth Shading
	glClearColor(c_noir[0],c_noir[1],c_noir[2], 0.0f);	// Background
	glClearDepth(1.0f);									// Depth Buffer Setup
	glEnable(GL_DEPTH_TEST);							// Enables Depth Testing
	glDepthFunc(GL_LEQUAL);								// The Type Of Depth Testing To Do


//	glBlendFunc(GL_ONE, GL_ONE);
//	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
//
//	glEnable(GL_BLEND);

	//glEnable(GL_NORMAL);
	//glEnable(GL_AUTO_NORMAL);
	//glEnable(GL_NORMALIZE);

	glCullFace(GL_BACK);
	glEnable(GL_CULL_FACE);

	 
	glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_FASTEST);	// Really Nice Perspective Calculations

GLfloat fogColor[4]= {0.390625f, 0.390625f, 0.5f, 1.0f};		// Fog Color

glFogi(GL_FOG_MODE, GL_LINEAR);		// Fog Mode
glFogfv(GL_FOG_COLOR, fogColor);			// Set Fog Color
glFogf(GL_FOG_DENSITY, 0.05f);				// How Dense Will The Fog Be
glHint(GL_FOG_HINT, GL_DONT_CARE);			// Fog Hint Value
glFogf(GL_FOG_START, 55.0f);				// Fog Start Depth
glFogf(GL_FOG_END, 85.0f);				// Fog End Depth
//glEnable(GL_FOG);					// Enables GL_FOG

	//glHint(GL_PERSPECTIVE_CORRECTION_HINT, GL_NICEST);	// Really Nice Perspective Calculations
/*
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glLightfv(GL_LIGHT0,GL_DIFFUSE,L0dif);
	glLightfv(GL_LIGHT0,GL_SPECULAR,L0spe);
*/
/*
//	GLfloat mat_specular0[] = { 1.0, 1.0, 1.0, 1.0 };
//	GLfloat mat_shininess0[] = { 100.0 };
	GLfloat light_position0[] = { 0.0, +10.0, 0.0, 0.0 };
	GLfloat light_ambient0[] = { 1.0, 1.0, 1.0, 1.0};
	GLfloat light_specular0[] = { 1.0, 1.0, 1.0, 1.0 };
	GLfloat light_diffuse0[] = { 1.0, 1.0, 1.0, 1.0 };

	GLfloat light_position1[] = { -10.0, 10.0, +50.0, 0.0 };
	GLfloat light_ambient1[] = { 1.0, 0.0, 0.0, 1.0};
	GLfloat light_specular1[] = { 1.0, 0.0, 0.0, 1.0 };
	GLfloat light_diffuse1[] = { 0.5, 0.5, 0.5, 1.0 };


//	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);

   	glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient0);
	glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient0);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse0);
	glLightfv(GL_LIGHT0, GL_POSITION, light_position0);

	glEnable(GL_LIGHT1);

   	glLightfv(GL_LIGHT1, GL_AMBIENT, light_ambient1);
	glLightfv(GL_LIGHT1, GL_AMBIENT, light_ambient1);
	glLightfv(GL_LIGHT1, GL_DIFFUSE, light_diffuse1);
	glLightfv(GL_LIGHT1, GL_POSITION, light_position1);
*/

glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	return TRUE;										// Initialization Went OK
}



GLvoid KillGLWindow(GLvoid)								// Properly Kill The Window
{
	if (fullscreen)										// Are We In Fullscreen Mode?
	{
		ChangeDisplaySettings(NULL,0);					// If So Switch Back To The Desktop
		ShowCursor(TRUE);								// Show Mouse Pointer
	}

	if (hRC)											// Do We Have A Rendering Context?
	{
		if (!wglMakeCurrent(NULL,NULL))					// Are We Able To Release The DC And RC Contexts?
		{
//			MessageBox(NULL,"Release Of DC And RC Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		}

		if (!wglDeleteContext(hRC))						// Are We Able To Delete The RC?
		{
//			MessageBox(NULL,"Release Rendering Context Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		}
		hRC=NULL;										// Set RC To NULL
	}

	if (hDC && !ReleaseDC(hWnd,hDC))					// Are We Able To Release The DC
	{
//		MessageBox(NULL,"Release Device Context Failed.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		hDC=NULL;										// Set DC To NULL
	}

	if (hWnd && !DestroyWindow(hWnd))					// Are We Able To Destroy The Window?
	{
//		MessageBox(NULL,"Could Not Release hWnd.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		hWnd=NULL;										// Set hWnd To NULL
	}

	if (!UnregisterClass("OpenGL",hInstance))			// Are We Able To Unregister Class
	{
//		MessageBox(NULL,"Could Not Unregister Class.","SHUTDOWN ERROR",MB_OK | MB_ICONINFORMATION);
		hInstance=NULL;									// Set hInstance To NULL
	}
}

/*	This Code Creates Our OpenGL Window.  Parameters Are:					*
 *	title			- Title To Appear At The Top Of The Window				*
 *	width			- Width Of The GL Window Or Fullscreen Mode				*
 *	height			- Height Of The GL Window Or Fullscreen Mode			*
 *	bits			- Number Of Bits To Use For Color (8/16/24/32)			*
 *	fullscreenflag	- Use Fullscreen Mode (TRUE) Or Windowed Mode (FALSE)	*/
 
BOOL CreateGLWindow(char* title, int width, int height, int bits, bool fullscreenflag)
{
	GLuint		PixelFormat;			// Holds The Results After Searching For A Match
	WNDCLASS	wc;						// Windows Class Structure
	DWORD		dwExStyle;				// Window Extended Style
	DWORD		dwStyle;				// Window Style
	RECT		WindowRect;				// Grabs Rectangle Upper Left / Lower Right Values
	WindowRect.left=(long)0;			// Set Left Value To 0
	WindowRect.right=(long)width;		// Set Right Value To Requested Width
	WindowRect.top=(long)0;				// Set Top Value To 0
	WindowRect.bottom=(long)height;		// Set Bottom Value To Requested Height

	fullscreen=fullscreenflag;			// Set The Global Fullscreen Flag

	hInstance			= GetModuleHandle(NULL);				// Grab An Instance For Our Window
	wc.style			= CS_HREDRAW | CS_VREDRAW | CS_OWNDC;	// Redraw On Size, And Own DC For Window.
	wc.lpfnWndProc		= (WNDPROC) WndProc;					// WndProc Handles Messages
	wc.cbClsExtra		= 0;									// No Extra Window Data
	wc.cbWndExtra		= 0;									// No Extra Window Data
	wc.hInstance		= hInstance;							// Set The Instance
	wc.hIcon			= LoadIcon(NULL, IDI_WINLOGO);			// Load The Default Icon
	wc.hCursor			= LoadCursor(NULL, IDC_ARROW);			// Load The Arrow Pointer
	wc.hbrBackground	= NULL;									// No Background Required For GL
	wc.lpszMenuName		= NULL;									// We Don't Want A Menu
	wc.lpszClassName	= "OpenGL";								// Set The Class Name

	if (!RegisterClass(&wc))									// Attempt To Register The Window Class
	{
		//MessageBox(NULL,"Failed To Register The Window Class.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;											// Return FALSE
	}
	
	if (fullscreen)												// Attempt Fullscreen Mode?
	{
		DEVMODE dmScreenSettings;								// Device Mode
		memset(&dmScreenSettings,0,sizeof(dmScreenSettings));	// Makes Sure Memory's Cleared
		dmScreenSettings.dmSize=sizeof(dmScreenSettings);		// Size Of The Devmode Structure
		dmScreenSettings.dmPelsWidth	= width;				// Selected Screen Width
		dmScreenSettings.dmPelsHeight	= height;				// Selected Screen Height
		dmScreenSettings.dmBitsPerPel	= bits;					// Selected Bits Per Pixel
		dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;

		// Try To Set Selected Mode And Get Results.  NOTE: CDS_FULLSCREEN Gets Rid Of Start Bar.
		if (ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN)!=DISP_CHANGE_SUCCESSFUL)
		{
/*			// If The Mode Fails, Offer Two Options.  Quit Or Use Windowed Mode.
			if (MessageBox(NULL,"The Requested Fullscreen Mode Is Not Supported By\nYour Video Card. Use Windowed Mode Instead?","Just for fun",MB_YESNO|MB_ICONEXCLAMATION)==IDYES)
			{
				fullscreen=FALSE;		// Windowed Mode Selected.  Fullscreen = FALSE
			}
			else
			{
				// Pop Up A Message Box Letting User Know The Program Is Closing.
				MessageBox(NULL,"Program Will Now Close.","ERROR",MB_OK|MB_ICONSTOP);
				return FALSE;									// Return FALSE
			}
*/		}
	}

	if (fullscreen)												// Are We Still In Fullscreen Mode?
	{
		dwExStyle=WS_EX_APPWINDOW;								// Window Extended Style
		dwStyle=WS_POPUP;										// Windows Style
		ShowCursor(FALSE);										// Hide Mouse Pointer
	}
	else
	{
		dwExStyle=WS_EX_APPWINDOW | WS_EX_WINDOWEDGE;			// Window Extended Style
		dwStyle=WS_OVERLAPPEDWINDOW;							// Windows Style
	}

	AdjustWindowRectEx(&WindowRect, dwStyle, FALSE, dwExStyle);		// Adjust Window To True Requested Size

	// Create The Window
	if (!(hWnd=CreateWindowEx(	dwExStyle,							// Extended Style For The Window
								"OpenGL",							// Class Name
								title,								// Window Title
								dwStyle |							// Defined Window Style
								WS_CLIPSIBLINGS |					// Required Window Style
								WS_CLIPCHILDREN,					// Required Window Style
								0, 0,								// Window Position
								WindowRect.right-WindowRect.left,	// Calculate Window Width
								WindowRect.bottom-WindowRect.top,	// Calculate Window Height
								NULL,								// No Parent Window
								NULL,								// No Menu
								hInstance,							// Instance
								NULL)))								// Dont Pass Anything To WM_CREATE
	{
		KillGLWindow();								// Reset The Display
		//MessageBox(NULL,"Window Creation Error.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	static	PIXELFORMATDESCRIPTOR pfd=				// pfd Tells Windows How We Want Things To Be
	{
		sizeof(PIXELFORMATDESCRIPTOR),				// Size Of This Pixel Format Descriptor
		1,											// Version Number
		PFD_DRAW_TO_WINDOW |						// Format Must Support Window
		PFD_SUPPORT_OPENGL |						// Format Must Support OpenGL
		PFD_DOUBLEBUFFER,							// Must Support Double Buffering
		PFD_TYPE_RGBA,								// Request An RGBA Format
		bits,										// Select Our Color Depth
		0, 0, 0, 0, 0, 0,							// Color Bits Ignored
		0,											// No Alpha Buffer
		0,											// Shift Bit Ignored
		0,											// No Accumulation Buffer
		0, 0, 0, 0,									// Accumulation Bits Ignored
		16,											// 16Bit Z-Buffer (Depth Buffer)  
		0,											// No Stencil Buffer
		0,											// No Auxiliary Buffer
		PFD_MAIN_PLANE,								// Main Drawing Layer
		0,											// Reserved
		0, 0, 0										// Layer Masks Ignored
	};
	
	if (!(hDC=GetDC(hWnd)))							// Did We Get A Device Context?
	{
		KillGLWindow();								// Reset The Display
		//MessageBox(NULL,"Can't Create A GL Device Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	if (!(PixelFormat=ChoosePixelFormat(hDC,&pfd)))	// Did Windows Find A Matching Pixel Format?
	{
		KillGLWindow();								// Reset The Display
		//MessageBox(NULL,"Can't Find A Suitable PixelFormat.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	if(!SetPixelFormat(hDC,PixelFormat,&pfd))		// Are We Able To Set The Pixel Format?
	{
		KillGLWindow();								// Reset The Display
		//MessageBox(NULL,"Can't Set The PixelFormat.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	if (!(hRC=wglCreateContext(hDC)))				// Are We Able To Get A Rendering Context?
	{
		KillGLWindow();								// Reset The Display
		//MessageBox(NULL,"Can't Create A GL Rendering Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	if(!wglMakeCurrent(hDC,hRC))					// Try To Activate The Rendering Context
	{
		KillGLWindow();								// Reset The Display
		//MessageBox(NULL,"Can't Activate The GL Rendering Context.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	ShowWindow(hWnd,SW_SHOW);						// Show The Window
	SetForegroundWindow(hWnd);						// Slightly Higher Priority
	SetFocus(hWnd);									// Sets Keyboard Focus To The Window
	ReSizeGLScene(width, height);					// Set Up Our Perspective GL Screen

	if (!InitGL())									// Initialize Our Newly Created GL Window
	{
		KillGLWindow();								// Reset The Display
		//MessageBox(NULL,"Initialization Failed.","ERROR",MB_OK|MB_ICONEXCLAMATION);
		return FALSE;								// Return FALSE
	}

	return TRUE;									// Success
}

// CREE un obj
// nbp: nb de points
// nbf: nb de faces
// p  : liste des points
// f  : liste des faces
// UV : liste des UV
// retourn Obj: Object opengl a creer!
GLuint create_object(int nbp,int nbf,double *p,unsigned long *f,float *UV)
{
	GLuint				Obj;
	int					i=0,j=0;
	int					point1,point2,point3;
	float				x,y,z;
	float				u,v;
	
	float				min_x=50000.0f,max_x=-50000.0f,min_y=50000.0f,max_y=-50000.0f,min_z=50000.0f,max_z=-50000.0f;
	float				val_x,val_y,val_z;

	// on cherche a centrer l'objet
	for (i=0;i<nbp;i++)
	{
		x=(float) (p[i*3+0]);
		if (x<min_x)		{			min_x=x;		}
		if (x>max_x)		{			max_x=x;		}

		y=(float) (p[i*3+1]);
		if (y<min_y)		{			min_y=y;		}
		if (y>max_y)		{			max_y=y;		}
				
		z=(float) (p[i*3+2]);
		if (z<min_z)		{			min_z=z;		}
		if (z>max_z)		{			max_z=z;		}
	}
	
	val_x=-(((max_x-min_x)/2)+min_x);
	val_y=-(((max_y-min_y)/2)+min_y);
	val_z=-(((max_z-min_z)/2)+min_z);

		
	Obj=glGenLists(1);
	glNewList(Obj,GL_COMPILE);

	for (i=0;i<nbf;i++)
	{
		glBegin(GL_TRIANGLES);

		point1=f[3*i+0];
		point2=f[3*i+1];
		point3=f[3*i+2];

		// POINT 1
		x=(float) (p[point1*3+0]+val_x);
		y=(float) (p[point1*3+1]+val_y);
		z=(float) (p[point1*3+2]+val_z);

		u=UV[point1*2+0];
		v=UV[point1*2+1];

		//glNormal3f(n_points[3*point1+0],n_points[3*point1+1],n_points[3*point1+2]);	
		glTexCoord2f(u, v); glVertex3f(x,y,z);

		// POINT 2
		x=(float) (p[point2*3+0]+val_x);
		y=(float) (p[point2*3+1]+val_y);
		z=(float) (p[point2*3+2]+val_z);

		u=UV[point2*2+0];
		v=UV[point2*2+1];

		//glNormal3f(n_points[3*point2+0],n_points[3*point2+1],n_points[3*point2+2]);	
		glTexCoord2f(u, v); glVertex3f(x,y,z);

		// POINT 3
		x=(float) (p[point3*3+0]+val_x);
		y=(float) (p[point3*3+1]+val_y);
		z=(float) (p[point3*3+2]+val_z);

		u=UV[point3*2+0];
		v=UV[point3*2+1];

		//glNormal3f(n_points[3*point3+0],n_points[3*point3+1],n_points[3*point3+2]);	
		glTexCoord2f(u, v); glVertex3f(x,y,z);

		glEnd();
	}
	glEndList();

	return Obj;
}

// cré une texture de taille*taille et pointer sur t(R8G8B8)
GLuint create_texture(unsigned char *t,int taille,char type)
{
	GLuint		Texture;
		
	glGenTextures(1, &Texture);
	glBindTexture(GL_TEXTURE_2D, Texture);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
//	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);

	
	if (type==0) // pixel
	{
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);	
		glTexImage2D(GL_TEXTURE_2D, 0, 3, taille, taille, 0, GL_RGB, GL_UNSIGNED_BYTE, t);
	} 
	if (type==1) // Adouci
	{
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR_MIPMAP_NEAREST);	
		gluBuild2DMipmaps(GL_TEXTURE_2D, 3, taille, taille, GL_RGB, GL_UNSIGNED_BYTE,t);
	}
	if (type==2) // pixel + Alpha
	{
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);	
		glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, taille, taille, 0, GL_RGBA, GL_UNSIGNED_BYTE, t);
	} 
	if (type==3) // Adouci + Alpha
	{
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR_MIPMAP_NEAREST);
		glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR_MIPMAP_NEAREST);	
		gluBuild2DMipmaps(GL_TEXTURE_2D, GL_RGBA, taille, taille, GL_RGBA, GL_UNSIGNED_BYTE,t);
	}


	return Texture;
}


  
LRESULT CALLBACK WndProc(	HWND	hWnd,			// Handle For This Window
							UINT	uMsg,			// Message For This Window
							WPARAM	wParam,			// Additional Message Information
							LPARAM	lParam)			// Additional Message Information
{
	switch (uMsg)									// Check For Windows Messages
	{
		case WM_ACTIVATE:							// Watch For Window Activate Message
		{
			if (!HIWORD(wParam))					// Check Minimization State
			{
				active=TRUE;						// Program Is Active
			}
			else
			{
				active=FALSE;						// Program Is No Longer Active
			}

			return 0;								// Return To The Message Loop
		}

		case WM_SYSCOMMAND:							// Intercept System Commands
		{
			switch (wParam)							// Check System Calls
			{
				case SC_SCREENSAVE:					// Screensaver Trying To Start?
				case SC_MONITORPOWER:				// Monitor Trying To Enter Powersave?
				return 0;							// Prevent From Happening
			}
			break;									// Exit
		}

		case WM_CLOSE:								// Did We Receive A Close Message?
		{
			PostQuitMessage(0);						// Send A Quit Message
			return 0;								// Jump Back
		}

		case WM_KEYDOWN:							// Is A Key Being Held Down?
		{
			keys[wParam] = TRUE;					// If So, Mark It As TRUE
			return 0;								// Jump Back
		}

		case WM_KEYUP:								// Has A Key Been Released?
		{
			keys[wParam] = FALSE;					// If So, Mark It As FALSE
			return 0;								// Jump Back
		}

		case WM_SIZE:								// Resize The OpenGL Window
		{
			ReSizeGLScene(LOWORD(lParam),HIWORD(lParam));  // LoWord=Width, HiWord=Height
			return 0;								// Jump Back
		}
	}

	// Pass All Unhandled Messages To DefWindowProc
	return DefWindowProc(hWnd,uMsg,wParam,lParam);
}

float f(float x,float y,float z)
{

  float r;
  float r1,r2;
  /*static float R1=0.5;
    static float R2=0.7;*/
  float  alpha;

  alpha=R2*R2/(R1*R1);

  r=0;
  /*a=0.035;
  if(x>-1 && x<=0 && y>-1 && y<=0 && z>-1 && z<=0) {r=1;}*/
  r=(float)((x-2.3)*(x-2.3)+y*y+z*z);
  r+=(float)((x+2.3)*(x+2.3)+y*y+z*z);

  r1=(x-xb1)*(x-xb1) + (y-yb1)*(y-yb1) + (z-zb1)*(z-zb1);
  /*r1=r1*r1;*/

  /*r2=(x-(0.5))*(x-(0.5)) + y*y + z*z;*/
  r2=(x-xb2)*(x-xb2) + (y-yb2)*(y-yb2) + (z-zb2)*(z-zb2);
  /*r2=r2*r2;*/

  if(r1==0.0) r1=99999;
  else r1=1/r1;

  if(r2==0.0) r2=99999;
  else r2=1/r2;
  
  r= r1 + alpha*r2;
  
  return(r);
}


void affiche_fond(GLuint texture,float posx)
{
	glLoadIdentity();			// Reset The View
	glTranslatef(posx,0.0f,-4.0f);
	glRotatef(6*X,0.0f,0.0f,1.0f);
	glBindTexture(GL_TEXTURE_2D, texture);
	glColor3f(1.0f,1.0f,1.0f);
	glDisable(GL_DEPTH_TEST);
	glBegin(GL_QUADS);						// Draw A Quad
		glTexCoord2f(0, 0); 
		glVertex3f(-1.0f,-1.0f, 0.0f);				// Bottom Left
		glTexCoord2f(1, 0); 		
		glVertex3f( 1.0f,-1.0f, 0.0f);				// Bottom Right
		glTexCoord2f(1, 1); 		
		glVertex3f( 1.0f, 1.0f, 0.0f);				// Top Right
		glTexCoord2f(0, 1); 		
		glVertex3f(-1.0f, 1.0f, 0.0f);				// Top Left
	glEnd();
	glEnable(GL_DEPTH_TEST);
}





void affiche_metaballs(void)
{



static GLuint i;
  static int start, end;
   float *P/**p1,*p2,*p3,*Norm;*/;
//   float *RGB;
   int   *F;
   int   NP,NF;
   char *NEG;

   static float U[3],V[3],W[3];

//   float r,t1,t2,t3;
   
   float fo12x,fo13x,fo14x,fo23x,fo24x,fo34x;
   float fo12y,fo13y,fo14y,fo23y,fo24y,fo34y;
   float fo12z,fo13z,fo14z,fo23z,fo24z,fo34z;





  /* do the trackball rotation. */

  spin+=dspin;

  xb1=(0.4f*(float)cos(spin/3))*(float)cos(spin);
  yb1=(0.4f*(float)cos(spin/3))*(float)sin(spin);  
  zb1=(0.4f*(float)sin(spin/5));
  

  /*xb1=0.4+0.3*cos(spin);
  yb1=0;  
  zb1=0;*/

 
 
/*xb2=-0.4+0.3*cos(spin+3.14);
  yb2=0;  
  zb2=0;*/
  
  xb2=0.3f*(float)sin(spin);
  yb2=0.2f*(float)cos(spin);
  zb2=0.3f*(float)sin(spin);

  xb3=0.3f*(float)sin(spin);
  yb3=0.2f*(float)cos(spin/3);
  zb3=0.2f*(float)cos(spin);


  xb4=0.2f*(float)cos(spin);
  yb4=0.1f*(float)sin(spin);
  zb4=0.2f*(float)cos(spin);


  force(xb1,yb1,zb1,xb2,yb2,zb2,&fo12x,&fo12y,&fo12z);
  force(xb1,yb1,zb1,xb3,yb3,zb3,&fo13x,&fo13y,&fo13z);
  force(xb1,yb1,zb1,xb4,yb4,zb4,&fo14x,&fo14y,&fo14z);
  force(xb2,yb2,zb2,xb3,yb3,zb3,&fo23x,&fo23y,&fo23z);
  force(xb2,yb2,zb2,xb4,yb4,zb4,&fo24x,&fo24y,&fo24z);
  force(xb3,yb3,zb3,xb4,yb4,zb4,&fo34x,&fo34y,&fo34z);



  xb1+= fo12x + fo13x + fo14x;
  yb1+= fo12y + fo13y + fo14y;
  zb1+= fo12z + fo13z + fo14z;

  xb2+=-fo12x + fo23x + fo24x;
  yb2+=-fo12y + fo23y + fo24y;
  zb2+=-fo12z + fo23z + fo24z;

  xb3+=-fo13x - fo23x + fo34x;
  yb3+=-fo13y - fo23y + fo34y;
  zb3+=-fo13z - fo23z + fo34z; 

  xb4+=-fo14x - fo24x - fo34x;
  yb4+=-fo14y - fo24y - fo34y;
  zb4+=-fo14z - fo24z - fo34z; 


  
/*
  r=(xb2-xb1)*(xb2-xb1) + (yb2-yb1)*(yb2-yb1) + (zb2-zb1)*(zb2-zb1);
  if(r==0.0) r=99999; else r=1/r;
   
  xb1+=(xb1-xb2)*r/FO;
  yb1+=(yb1-yb2)*r/FO;
  zb1+=(zb1-zb2)*r/FO;

  xb2+=(xb2-t1)*r/FO;
  yb2+=(yb2-t2)*r/FO;
  zb2+=(zb2-t3)*r/FO;  
*/
  
  /*glBegin(GL_TRIANGLES);*/
  
  glCullFace(GL_FRONT | GL_BACK);
  glEnable(GL_CULL_FACE);
  glEnable(GL_BLEND);
  glDisable(GL_DEPTH_TEST);
glDisable(GL_TEXTURE_2D);
#define ARET 0.95f  

  glBegin(GL_QUADS);


  glColor3f(0.25f,0.25f,0.25f);

	glVertex3f(-ARET,-ARET, ARET);
	glVertex3f( ARET,-ARET, ARET);
	glVertex3f( ARET, ARET, ARET);
	glVertex3f(-ARET, ARET, ARET);
	
  glColor3f(0.35f,0.35f,0.35f);
	glVertex3f( ARET,-ARET, ARET);
	glVertex3f( ARET,-ARET,-ARET);
	glVertex3f( ARET, ARET,-ARET);
	glVertex3f( ARET, ARET, ARET);
	
  glColor3f(0.25f,0.25f,0.25f);
	glVertex3f( ARET,-ARET,-ARET);
	glVertex3f(-ARET,-ARET,-ARET);
	glVertex3f(-ARET, ARET,-ARET);
	glVertex3f( ARET, ARET,-ARET);
	
  glColor3f(0.35f,0.35f,0.35f);
	glVertex3f(-ARET,-ARET,-ARET);
	glVertex3f(-ARET,-ARET, ARET);
	glVertex3f(-ARET, ARET, ARET);
	glVertex3f(-ARET, ARET,-ARET);
	
  glColor3f(0.3f,0.3f,0.3f);
	glVertex3f(-ARET, ARET, ARET);
	glVertex3f( ARET, ARET, ARET);
	glVertex3f( ARET, ARET,-ARET);
	glVertex3f(-ARET, ARET,-ARET);
	
  glColor3f(0.3f,0.3f,0.3f);
 	glVertex3f(-ARET,-ARET,-ARET);
	glVertex3f( ARET,-ARET,-ARET);
	glVertex3f( ARET,-ARET, ARET);
	glVertex3f(-ARET,-ARET, ARET);
  glEnd();
  glCullFace(GL_FRONT);
  glEnable(GL_CULL_FACE);
  glPolygonMode(GL_FRONT_AND_BACK,GL_FILL);
  glEnable(GL_TEXTURE_2D);
  
  //glColor3f(255.0f,255.0f,255.0f);
  
  meta_objectNEG(&P,&F,&NF,&NEG,&NP,&fNEG2,0.02f/(R1*R1));

  glCullFace(GL_BACK);
  glEnable(GL_CULL_FACE);
  glEnable(GL_DEPTH_TEST);
  /*glEnd();*/

  /*
  glBegin(GL_TRIANGLES);
  
  for(i=0;i<NF;i++)
    {
    
       if(NEG[i]) glColor3f(1.0,0.0,0.0);
       else       glColor3f(1.0,1.0,0.0);
       p1  =P + 3*F[3*i  ];
       p2  =P + 3*F[3*i+1];
       p3  =P + 3*F[3*i+2];


       glVertex3fv(p1);
       glVertex3fv(p2);
       glVertex3fv(p3);
    }
  glEnd();
  
*/


  
  
}

void Affiche_Part1(float position)
{
	glEnable(GL_FOG);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//	affiche_fond(T_Env2);
	glLoadIdentity();			// Reset The View
	glTranslatef(0.0f,position,-30); //-30
	glRotatef(90,1.0f,0.0f,0.0f);
	//glRotatef(X,0.0f,0.0f,1.0f);
	glBindTexture(GL_TEXTURE_2D, T_Fond1);
	pl->Plan_Affiche();
	glBindTexture(GL_TEXTURE_2D, T_Fond1);
	glLoadIdentity();			// Reset The View
	glTranslatef(0.0f,-position,-30); //-30
	glRotatef(90,1.0f,0.0f,0.0f);
	pl->Plan_Affiche2();
	glDisable(GL_FOG);
	
	
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	glLoadIdentity();
	glTranslatef(pos_barre,-0.35f,0.0f);
	glEnable(GL_BLEND);									
	//glBlendFunc(GL_SRC_COLOR, GL_ONE);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	//glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);
	glColor4f(0.0f,0.0f,0.0f,0.3f);
	glBegin(GL_QUADS);
		glVertex3f(1.0f,0.0f,-1.0f);
		glVertex3f(3.0f,0.0f,-1.0f);
		glVertex3f(3.0f,0.08f,-1.0f);
		glVertex3f(1.0f,0.08f,-1.0f);
	glEnd();
	glDisable(GL_BLEND);	
	glColor3f(1.0f,1.0f,1.0f);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);

}

void Affiche_Part2(float posx)
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	affiche_fond(T_Fond2,posx);
	glLoadIdentity();			// Reset The View
//	glTranslatef(0.0f,0.0f,-20); //-30
	glTranslatef(pos_rubber,0.0f,-45); //-30
	glRotatef(90,1.0f,0.0f,0.0f);
	glRotatef(X,0.0f,0.0f,1.0f);
	glBindTexture(GL_TEXTURE_2D, T_Rub);
	cyl->Cylindre_affiche();
	glFlush();

	glEnable(GL_BLEND);									// Enable Blending
	glBlendFunc(GL_SRC_COLOR, GL_ONE);					// Set Blending Mode To Mix Based On SRC Alpha
	glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);			// Set Blending Mode To Mix Based On SRC Alpha

	glBindTexture(GL_TEXTURE_2D, T_Env2);
	glEnable(GL_TEXTURE_GEN_T);
	glEnable(GL_TEXTURE_GEN_S);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	cyl->Cylindre_affiche();
	glFlush();
	glDisable(GL_TEXTURE_GEN_S);						// Disable Sphere Mapping
	glDisable(GL_TEXTURE_GEN_T);						// Disable Sphere Mapping
	glDisable(GL_BLEND);

}

void Affiche_Part3()
{
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glDisable(GL_CULL_FACE);
	glLoadIdentity();			// Reset The View
	glTranslatef(0.0f,0.0f,-25); //-30
	glRotatef(X,0.0f,0.0f,1.0f);
	glBindTexture(GL_TEXTURE_2D, T_Rub);
	tunnel->Cylindre_affiche();
	glEnable(GL_CULL_FACE);
	glFlush();
}

void Affiche_Part5()
{
//	glEnable(GL_FOG);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
//	affiche_fond(T_Env,0.0f);
	glLoadIdentity();			// Reset The View
	glTranslatef(0.0f,10.0f,-50); //-30
	glRotatef(90,0.0f,0.0f,1.0f);
	glRotatef(X,0.0f,0.0f,1.0f);
	glBindTexture(GL_TEXTURE_2D, T_Fond1);
	pl->Plan_Affiche();
	glEnable(GL_BLEND);									// Enable Blending
	glBlendFunc(GL_SRC_COLOR, GL_ONE);					// Set Blending Mode To Mix Based On SRC Alpha
	glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);			// Set Blending Mode To Mix Based On SRC Alpha

	glBindTexture(GL_TEXTURE_2D, T_Env);
	glEnable(GL_TEXTURE_GEN_T);
	glEnable(GL_TEXTURE_GEN_S);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	pl->Plan_Affiche();
	glFlush();
	glDisable(GL_TEXTURE_GEN_S);						// Disable Sphere Mapping
	glDisable(GL_TEXTURE_GEN_T);						// Disable Sphere Mapping
	glDisable(GL_BLEND);
/*
	glBindTexture(GL_TEXTURE_2D, T_Fond1);
	glLoadIdentity();			// Reset The View
	glTranslatef(0.0f,-10.0f,-30); //-30
	glRotatef(90,1.0f,0.0f,0.0f);
	pl->Plan_Affiche2();*/
//	glDisable(GL_FOG);
}


int DrawGLScene(GLvoid)									// Here's Where We Do All The Drawing
{
//	float	Zdep=-400.0f,espacement=150.0f;
//	int		i,j,k;
	
	//float	depart=(-(espacement*max_tab)/2)+espacement/2;
	

	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);	// Clear Screen And Depth Buffer

	//affiche_fond(T_Fond2);
	affiche_fond(T_Fond2,0);

	glLoadIdentity();			// Reset The View

	glTranslatef(-70.0f,60.0f,-250);
	glDisable(GL_DEPTH_TEST);
	glColor3f(0.0f,0.0f,0.0f);
	glDisable(GL_TEXTURE_2D);	
	glPushMatrix();
		glTranslatef(7.0f,-6.0f,25.0f);
		glRotatef(2*X,1.0f,1.0f,1.0f);
		glCallList(GL_Oeuf);
	glPopMatrix();
	glColor3f(1.0f,1.0f,1.0f);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
	glBindTexture(GL_TEXTURE_2D, T_Oeuf);
	glRotatef(2*X,1.0f,1.0f,1.0f);
	glCallList(GL_Oeuf);

	glLoadIdentity();			// Reset The View

	glTranslatef(-70.0f,-40.0f,-250);
	glDisable(GL_DEPTH_TEST);
	glColor3f(0.0f,0.0f,0.0f);
	glDisable(GL_TEXTURE_2D);	
	glPushMatrix();
		glTranslatef(7.0f,+4.0f,25.0f);
		glRotatef(2*X,1.0f,1.0f,1.0f);
		glCallList(GL_Glace);
	glPopMatrix();
	glColor3f(1.0f,1.0f,1.0f);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
	glBindTexture(GL_TEXTURE_2D, T_Glace);
	glRotatef(2*X,1.0f,1.0f,1.0f);
	glCallList(GL_Glace);

	glLoadIdentity();			// Reset The View

	glTranslatef(+70.0f,-60.0f,-250);
	glDisable(GL_DEPTH_TEST);
	glColor3f(0.0f,0.0f,0.0f);
	glDisable(GL_TEXTURE_2D);	
	glPushMatrix();
		glTranslatef(-7.0f,6.0f,25.0f);
		glRotatef(2*X,1.0f,1.0f,1.0f);
		glCallList(GL_Potdefleur);
	glPopMatrix();
	glColor3f(1.0f,1.0f,1.0f);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
	glBindTexture(GL_TEXTURE_2D, T_Potdefleur);
	glRotatef(2*X,1.0f,1.0f,1.0f);
	glCallList(GL_Potdefleur);

	glLoadIdentity();			// Reset The View

	glTranslatef(+70.0f,60.0f,-250);
	glDisable(GL_DEPTH_TEST);
	glColor3f(0.0f,0.0f,0.0f);
	glDisable(GL_TEXTURE_2D);	
	glPushMatrix();
		glTranslatef(-7.0f,-6.0f,25.0f);
		glRotatef(2*X,1.0f,1.0f,1.0f);
		glCallList(GL_Carotte);
	glPopMatrix();
	glColor3f(1.0f,1.0f,1.0f);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
	glBindTexture(GL_TEXTURE_2D, T_Carotte);
	glRotatef(2*X,1.0f,1.0f,1.0f);
	glCallList(GL_Carotte);

//	glPushMatrix();

//	glBindTexture(GL_TEXTURE_2D, Texture);	
	//glColor3f(1.0f,1.0f,1.0f);

/*	
	for (i=0;i<max_tab;i++)
	{
		for (j=0;j<max_tab;j++)
		{
			for (k=0;k<max_tab;k++)
			{
				glLoadIdentity();			// Reset The View
				glTranslatef(depart+i*espacement,depart+j*espacement,Zdep-k*espacement);
				glRotatef(X+(10.0f*i*j*k),1.0f,1.0f,1.0f);
//				glCallList(Obj);				
			}
		}
	}
*/
//	glPopMatrix();




/*
	glLoadIdentity();			// Reset The View
	glTranslatef(0.0, 0.0, -1.5);
	glBindTexture(GL_TEXTURE_2D, T_Potdefleur);
	glEnable(GL_TEXTURE_GEN_T);
	glEnable(GL_TEXTURE_GEN_S);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	affiche_metaballs();
	glDisable(GL_TEXTURE_GEN_S);
	glDisable(GL_TEXTURE_GEN_T);
*/
/*
	glLoadIdentity();			// Reset The View
	glTranslatef(0.0f,10.0f,-30); //-30
	glRotatef(90,1.0f,0.0f,0.0f);
	glBindTexture(GL_TEXTURE_2D, T_Perlin);
	pl->Plan_Affiche();
	glLoadIdentity();			// Reset The View
	glTranslatef(0.0f,-10.0f,-30); //-30
	glRotatef(90,1.0f,0.0f,0.0f);
	pl->Plan_Affiche2();
*/


	glLoadIdentity();			// Reset The View
//	glTranslatef(0.0f,0.0f,-20); //-30
	glTranslatef(0.0f,0.0f,-45); //-30
	glRotatef(90,1.0f,0.0f,0.0f);
	glRotatef(X,0.0f,0.0f,1.0f);
	glBindTexture(GL_TEXTURE_2D, T_Rub);
	cyl->Cylindre_affiche();
	glFlush();

	glEnable(GL_BLEND);									// Enable Blending
	glBlendFunc(GL_SRC_COLOR, GL_ONE);					// Set Blending Mode To Mix Based On SRC Alpha
	glBlendFunc(GL_DST_COLOR, GL_SRC_COLOR);			// Set Blending Mode To Mix Based On SRC Alpha

	glBindTexture(GL_TEXTURE_2D, T_Env);
	glEnable(GL_TEXTURE_GEN_T);
	glEnable(GL_TEXTURE_GEN_S);
	glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
	cyl->Cylindre_affiche();
	glFlush();
	glDisable(GL_TEXTURE_GEN_S);						// Disable Sphere Mapping
	glDisable(GL_TEXTURE_GEN_T);						// Disable Sphere Mapping
	glDisable(GL_BLEND);

	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	Affiche_texte("just for fun :\n",32,0,300,T_Fonte);
	glDisable(GL_BLEND);

	return 0;
}


void decode_gif(unsigned char *src,unsigned char *dest,long len)
{
	CGifDecoder		decoder;
	long			i,r,taille;
	unsigned char	cr,cb;
	taille=decoder.Open(src,len);
	taille=(long)sqrt(taille/3);

	r=decoder.Decode(dest);
	for (i=0;i<taille*taille;i++)
	{
		cr=dest[i*3];
		cb=dest[i*3+2];
		dest[i*3+2]=cr;
		dest[i*3]=cb;
	}
}

void convert_rgba(unsigned char *src,unsigned char *dest,int taille,unsigned char r,unsigned char v,unsigned char b)
{
	for (int i=0;i<256*256;i++)
	{
		if ((src[i*3]==r) && (src[i*3+1]==v) && (src[i*3+2]==b))
		{
			dest[i*4]=r;
			dest[i*4+1]=v;
			dest[i*4+2]=b;
			dest[i*4+3]=0;
		}
		else
		{
			dest[i*4]=src[i*3];
			dest[i*4+1]=src[i*3+1];
			dest[i*4+2]=src[i*3+2];
			dest[i*4+3]=255;
		}
	}
}

/*
void create_perlin(unsigned char *src)
{
	unsigned char c,d,e;

	int	xdim=256,ydim=256,z=0,zdim=256;
	int	i=0;
	for(int y=0; y < ydim ;++y)
	{
		for(int x=0; x < xdim ;++x)
		{
//			    c = (sin(tnoise(Cx/(xdim/1.0),(float)y/(ydim/1),(float)z/(zdim/1))))*255;
//				d = (sin(tnoise((float)x/(xdim/2.0),(float)y/(ydim/2.0),(float)z/(zdim/2))))*255;
//				e = (sin(tnoise((float)x/(2*xdim),(float)y/(2*ydim),(float)z/(2*zdim))))*255;

//			    c = tnoise((float)x/(float)xdim,(float)y/(float)ydim,(float)z/(float)zdim)*255;
//				d = ((tnoise((float)x/(xdim/1.0),(float)y/(ydim/1.0),(float)z/(zdim/1))))*255;
//				e = ((tnoise((float)x/(2*xdim),(float)y/(2*ydim),(float)z/(2*zdim))))*255;

				c=PerlinNoise2D((float)x,(float)y,20,0.5,7)*255;

				//c = tnoise( (float)x/4.0,(float)y/4.0,.5)*255.0;
				//src[z*ydim*xdim*3+y*xdim*3+x*3] = e*255;//(c*.5+.5)*255;//c;//x%4*255/4;
				//src[z*ydim*xdim*3+y*xdim*3+x*3 + 1] = c*255;//(cd)/2,0,1)*255;
				//src[z*ydim*xdim*3+y*xdim*3+x*3 + 2] = d*255;// +d/2;(d + c)/2;//c/2.0;

				src[i*3] = c*255;//(c*.5+.5)*255;//c;//x%4*255/4;
				src[i*3 + 1] = c*255;//(cd)/2,0,1)*255;
				src[i*3 + 2] = c*255;// +d/2;(d + c)/2;//c/2.0;
				i++;

		}
	}
}
*/

void Repmlir(unsigned char *tenv,long taille,float r,float g,float b)
{
	for(long i = 0;i < taille * taille;i++)
	{
		tenv[i * 3]     = (unsigned char)r;
		tenv[i * 3 + 1] = (unsigned char)g;
		tenv[i * 3 + 2] = (unsigned char)b;
	}
}

void Create_Env(unsigned char *tenv,long taille,long x1,long y1,float r,float g,float b,float rayon)
{
	float valx,valy,dist;

	for(long y = 0;y < taille;y++)
		for(long x = 0;x < taille;x++)
		{
			valx = (float)(x - x1) / (float)(taille / 2);
			valy = (float)(y - y1) / (float)(taille / 2);
			dist = valx * valx + valy * valy;
			dist = (float)exp(rayon * dist);

			tenv[(y * taille * 3) + (x * 3)]     =  (unsigned char)(dist * r);
			tenv[(y * taille * 3) + (x * 3) + 1] =  (unsigned char)(dist * g);
			tenv[(y * taille * 3) + (x * 3) + 2] =  (unsigned char)(dist * b);
		}
}

void Create_Env2(unsigned char *tenv,long taille,long x1,long y1,float r,float g,float b,float rayon)
{
	float valx,valy,dist;

	for(long y = 0;y < taille;y++)
		for(long x = 0;x < taille;x++)
		{
			valx = (float)(x - x1) / (float)(taille / 2);
			valy = (float)(y - y1) / (float)(taille / 2);
			dist = valx * valx + valy * valy;
			dist = (float)exp(rayon * dist);
/*
			tenv[(y * taille * 3) + (x * 3)]     = (unsigned char)(tenv[(y * taille * 3) + (x * 3)] *0.5)+ (unsigned char)(dist * r*0.5);
			tenv[(y * taille * 3) + (x * 3) + 1] = (unsigned char)(tenv[(y * taille * 3) + (x * 3) + 1]*0.5)+ (unsigned char)(dist * g*0.5);
			tenv[(y * taille * 3) + (x * 3) + 2] = (unsigned char)(tenv[(y * taille * 3) + (x * 3) + 2]*0.5)+(unsigned char)(dist * b*0.5);
*/
			tenv[(y * taille * 3) + (x * 3)]     +=  (unsigned char)(dist * r);
			tenv[(y * taille * 3) + (x * 3) + 1] +=  (unsigned char)(dist * g);
			tenv[(y * taille * 3) + (x * 3) + 2] +=  (unsigned char)(dist * b);
		}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
int APIENTRY WinMain(HINSTANCE hInstance,
                     HINSTANCE hPrevInstance,
                     LPSTR     lpCmdLine,
                     int       nCmdShow)
{
	MSG				msg;									// Windows Message Structure
	BOOL			done=FALSE;								// Bool Variable To Exit Loop

	// Change fullscreen HERE
	fullscreen=false;

#ifdef USEFMOD
	FMUSIC_MODULE *mod;

#ifndef USEMEMLOAD
	FSOUND_File_SetCallbacks(fileopen, fileclose, fileread, fileseek, filetell);
#else
	FSOUND_File_SetCallbacks(memopen, memclose, memread, memseek, memtell);
#endif
#endif

	if (!CreateGLWindow("Just for fun",res_x,res_y,bpp,fullscreen))
	{
		return 0;									// Quit If Window Was Not Created
	}


#ifdef USEFMOD
	// INITIALIZE
	if (!FSOUND_Init(44100, 0))	{		return 1;	}
	// LOAD SONG
	mod = FMUSIC_LoadSong("xm", NULL); //sampleloadcallback);
	if (!mod)	{		return 1;	}
	// PLAY SONG
#endif


	// INIT
	cyl=new Cylindre(22,50,40.0f,4.0f);
	tunnel=new Cylindre(22,50,100.0f,6.0f);
	pl=new Plan(64,64,100,100);

	// Création des Objets OpenGL
	GL_Glace=create_object(Glace_nbpoints,Glace_nbfaces,(double *) Glace_points,(unsigned long*) Glace_faces ,(float *) Glace_UV);
	GL_Oeuf=create_object(Oeuf_nbpoints,Oeuf_nbfaces,(double *) Oeuf_points,(unsigned long*) Oeuf_faces ,(float *) Oeuf_UV);
	GL_Carotte=create_object(Carotte_nbpoints,Carotte_nbfaces,(double *) Carotte_points,(unsigned long*) Carotte_faces ,(float *) Carotte_UV);
	GL_Etoile=create_object(Star01_nbpoints,Star01_nbfaces,(double *) Star01_points,(unsigned long*) Star01_faces ,(float *) Star01_UV);
	
	//
	// alloc mem pour les textures gif
	tglace=(unsigned char*) malloc(128*128*3);
	tbrique=(unsigned char*) malloc(64*64*3);
	toeuf=(unsigned char*) malloc(64*64*3);
	tcarot=(unsigned char*) malloc(32*32*3);
	tfd1=(unsigned char*) malloc(256*256*3);
	tfd2=(unsigned char*) malloc(256*256*3);
	tperlin=(unsigned char*) malloc(256*256*3);
	tfonte=(unsigned char*) malloc(256*256*3);
	tenv=(unsigned char*) malloc(256*256*3);
	tenv2=(unsigned char*) malloc(256*256*3);
	tenv3=(unsigned char*) malloc(256*256*3);
	tenv4=(unsigned char*) malloc(256*256*3);
	tfonte2=(unsigned char*) malloc(256*256*4);
	trub=(unsigned char*) malloc(64*64*3);
	tetoile=(unsigned char*) malloc(64*64*3);
	tchat1=(unsigned char*) malloc(256*256*3);
	tchat2=(unsigned char*) malloc(256*256*4);

	// Création des Textures
	decode_gif(tglacea,tglace,TGLACEA_LEN);
	T_Glace=create_texture(tglace,64,0);
	
	decode_gif(oeufa,toeuf,OEUFA_LEN);
	T_Oeuf=create_texture(toeuf,64,0);

	decode_gif(tetoile2,tetoile,TETOILE2_LEN);
	T_Etoile=create_texture(tetoile,64,0);

	decode_gif(t_carota,tcarot,T_CAROTA_LEN);
	T_Carotte=create_texture(tcarot,32,0);

	decode_gif(fd1b,tfd1,FD1B_LEN);
	T_Fond1=create_texture(tfd1,256,1);

	decode_gif(fd2b,tfd2,FD2B_LEN);
	T_Fond2=create_texture(tfd2,256,0);

	decode_gif(fnt3,tfonte,FNT3_LEN);
	convert_rgba(tfonte,tfonte2,256,214,99,123);
	T_Fonte=create_texture(tfonte2,256,3);

	decode_gif(chat,tchat1,CHAT_LEN);
	convert_rgba(tchat1,tchat2,256,100,100,128);
	T_Chat=create_texture(tchat2,256,3);

	decode_gif(rub,trub,RUB_LEN);
	T_Rub=create_texture(trub,64,1);

	Create_Env(tenv,256,140,140,200,0,0,-2);
	Create_Env2(tenv,256,120,120,0,150,0,-3);
	Create_Env2(tenv,256,150,110,0,0,220,-3);

	Create_Env(tenv2,256,128,128,255,255,220,-1);
	Create_Env(tenv3,256,128,128,50,150,220,-1);
	Create_Env(tenv4,256,128,128,160,250,210,-1);

	T_Env=create_texture(tenv,256,1);
	T_Env2=create_texture(tenv2,256,1);
	T_Env3=create_texture(tenv3,256,1);
	T_Env4=create_texture(tenv4,256,1);

	// Init des Metaballs
	init_metalibNEG(4,4000,10000,T_Env3,T_Env4);

	FMUSIC_PlaySong(mod);
	while (!done)								// Loop That Runs While done=FALSE 
	{	
		if (PeekMessage(&msg,NULL,0,0,PM_REMOVE))	// Is There A Message Waiting?
		{
			if (msg.message==WM_QUIT)				// Have We Received A Quit Message?
			{
				done=TRUE;							// If So done=TRUE
			}
			else									// If Not, Deal With Window Messages
			{
				TranslateMessage(&msg);				// Translate The Message
				DispatchMessage(&msg);				// Dispatch The Message
			}
		}
		else										// If There Are No Messages
		{
			// Draw The Scene.  Watch For ESC Key And Quit Messages From DrawGLScene()
			if (active)								// Program Active?
			{
				if (keys[VK_ESCAPE])				// Was ESC Pressed?
				{
					done=TRUE;						// ESC Signalled A Quit
				}
				else								// Not Time To Quit, Update Screen
				{
					//DrawGLScene();					// Draw The Scene

					// Fondu du départ du noir vers le bleu
					if (nb_coulcal<=nb_coul)
					{
						c_calcul[0]=(float)(nb_coulcal*((c_fond[0]-c_noir[0])/(float)(nb_coul)));
						c_calcul[1]=(float)(nb_coulcal*((c_fond[1]-c_noir[1])/(float)(nb_coul)));
						c_calcul[2]=(float)(nb_coulcal*((c_fond[2]-c_noir[2])/(float)(nb_coul)));
						glClearColor(c_calcul[0],c_calcul[1],c_calcul[2], 0.0f);
						nb_coulcal++;
						glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
					}
					else
					{
					
						ord = FMUSIC_GetOrder(mod);
						row = FMUSIC_GetRow(mod);

						// 1ere partie
						if ((ord>=0) && (ord<4))
						{
	
							pl->Plan_Deforme(deform_cyl,deform_cyl2,deform_cyl3);
							X=X+0.3f;
							deform_cyl2+=3*deform_cyl_val2;
							deform_cyl3+=3*deform_cyl_val3;
							Affiche_Part1(pos_plan);
							if (pos_plan>15.0f)
							{
								pos_plan-=0.15f;
							}
							else
							{
								if (pos_barre>-2.0f)
								{
									pos_barre-=0.01f;
								}	
							}
							
							if ((ord==1) && (row>=0) && (row<=5))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("just\n",32,170,30,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==1) && (row>=6) && (row<=11))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("just for\n",32,170,30,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==1) && (row>=12) && (row<=19))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("just for fun\n",32,170,30,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==1) && (row>=20) && (row<=28))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("present\n",32,240,30,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==1) && (row>=29) && (row<=99))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("softworld intro\n",32,130,30,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord>=2) )//&& (row>=36) && (row<=99))
							{
								glLoadIdentity();			// Reset The View

								glTranslatef(0.0f,20.0f,-150);

								glDisable(GL_DEPTH_TEST);
								glColor4f(0.0f,0.0f,0.0f,0.3f);
								glDisable(GL_TEXTURE_2D);
								glEnable(GL_BLEND);									
								glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
								glClear(GL_DEPTH_BUFFER_BIT);
								glPushMatrix();
									glTranslatef(depx + 1.0f,-9.0f,depz + 5.0f);
									glRotatef(2*X,0.0f,1.0f,0.2f);
									glRotatef(270,1.0f,0.0f,0.0f);
									glCallList(GL_Oeuf);
								glPopMatrix();
								glDisable(GL_BLEND);
								glColor3f(1.0f,1.0f,1.0f);
								glEnable(GL_TEXTURE_2D);
								glEnable(GL_DEPTH_TEST);
								glBindTexture(GL_TEXTURE_2D, T_Oeuf);
								glTranslatef(depx,-6.0f,depz);
								glRotatef(2*X,0.0f,1.0f,0.2f);
								glRotatef(270,1.0f,0.0f,0.0f);
								glCallList(GL_Oeuf);
								depx += 0.45f;depz += 0.31f;
								if ((ord==2) && (row>=12))
								{
									glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
									glEnable(GL_BLEND);
									Affiche_texte("at synthesis party\n",32,90,30,T_Fonte);
									glDisable(GL_BLEND);
								}
								if ((ord==3) && (row>=40))
								{
									pos_barre-=0.015f;
									pos_plan+=0.5f;
								}
								if ((ord==3) && (row>=50))
								{
									posx_plan += 0.04f;
									Affiche_Part2(posx_plan);
								}
								if ((ord>=3) && (row<=40))
								{
									glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
									glEnable(GL_BLEND);
									Affiche_texte("oldschool rulezzzz\n",32,90,30,T_Fonte);
									glDisable(GL_BLEND);
								}
							}
						}
						// 2e partie
						if ((ord>=4) && (ord<8))
						{
							glClearColor(c_fond[0],c_fond[1],c_fond[2], 0.0f);
							cyl->Cylindre_Deforme(deform_cyl,deform_cyl2,deform_cyl3);
							X=X+0.3f;
							deform_cyl2+=2*deform_cyl_val2;
							deform_cyl3+=2*deform_cyl_val3;
							if (pos_rubber>-15.0f)		pos_rubber-=0.5f;
							Affiche_Part2(posx_plan);
							if (ord==5)
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("code:\n",32,400,360,T_Fonte);
								if (row>=12) Affiche_texte("judge miguel\n",32,300,330,T_Fonte);
								if (row>=24) Affiche_texte("king valjean\n",32,300,300,T_Fonte);
								if (row>=36) Affiche_texte("white stallion\n",32,270,270,T_Fonte);
								glDisable(GL_BLEND);
							}
							if (ord==6)
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("code:\n",32,400,360,T_Fonte);
								Affiche_texte("judge miguel\n",32,300,330,T_Fonte);
								Affiche_texte("king valjean\n",32,300,300,T_Fonte);
								Affiche_texte("white stallion\n",32,270,270,T_Fonte);
								Affiche_texte("gfx:\n",32,420,190,T_Fonte);
								if (row>=12) Affiche_texte("bat\n",32,430,160,T_Fonte);
								if (row>=24) Affiche_texte("exocet\n",32,390,130,T_Fonte);
								glDisable(GL_BLEND);
							}
							if (ord==7)
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("code:\n",32,400,360,T_Fonte);
								Affiche_texte("judge miguel\n",32,300,330,T_Fonte);
								Affiche_texte("king valjean\n",32,300,300,T_Fonte);
								Affiche_texte("white stallion\n",32,270,270,T_Fonte);
								Affiche_texte("gfx:\n",32,420,190,T_Fonte);
								Affiche_texte("bat\n",32,430,160,T_Fonte);
								Affiche_texte("exocet\n",32,390,130,T_Fonte);
								Affiche_texte("music:\n",32,390,50,T_Fonte);
								if (row>=12) Affiche_texte("benji\n",32,400,20,T_Fonte);
								glDisable(GL_BLEND);
							}

						}
						// 3e partie flash blanc
						if ((ord==8) && (row==0))
						{
							glClearColor(1.0f,1.0f,1.0f, 0.0f);
							glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
						
							glFogi(GL_FOG_MODE, GL_EXP);		// Fog Mode
							glFogf(GL_FOG_DENSITY, 0.040f);
							glHint(GL_FOG_HINT, GL_DONT_CARE);
							glFogf(GL_FOG_START, 30.0f);
							glFogf(GL_FOG_END, 85.0f);

						}
						else
						{	
							// 3e partie flash blanc
							if ((ord>=8) && (ord<10))
							{
								tunnel->Cylindre_Deforme(deform_cyl,deform_cyl2,deform_cyl3);
								X=X+0.3f;
								deform_cyl2+=(float)(0.5*deform_cyl_val2);
								deform_cyl3+=(float)(0.5*deform_cyl_val3);
								glClearColor(c_fond[0],c_fond[1],c_fond[2], 0.0f);
								glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
								glEnable(GL_FOG);
								Affiche_Part3();
								glLoadIdentity();
								if (etoilex<5) etoilex+=0.15f;
								else etoilex=-90.0f;
								glTranslatef(0.0f,0.0f,etoilex);
								glRotatef(2*X,1.0f,0.8f,0.6f);
								glBindTexture(GL_TEXTURE_2D, T_Etoile);
								glRotatef(2*X+90,1.0f,1.0f,1.0f);
								glCallList(GL_Etoile);
								glDisable(GL_FOG);

							}
						}
						// 4e partie flash blanc
						if ((ord==10) && (row==0))
						{
							glClearColor(1.0f,1.0f,1.0f, 0.0f);
							glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
						
							glFogi(GL_FOG_MODE, GL_EXP);		// Fog Mode
							glFogf(GL_FOG_DENSITY, 0.040f);
							glHint(GL_FOG_HINT, GL_DONT_CARE);
							glFogf(GL_FOG_START, 30.0f);
							glFogf(GL_FOG_END, 85.0f);
						}
						else
						{
							if ((ord>=10) && (ord<14))
							{
								X+=0.3f;
								glClearColor(c_fond[0],c_fond[1],c_fond[2], 0.0f);
								glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

								glLoadIdentity();			// Reset The View
								glTranslatef(pos_meta, 0.0, -5.0);
								glRotatef(2*X,1.0f,1.0f,1.0f);
								glEnable(GL_TEXTURE_GEN_T);
								glEnable(GL_TEXTURE_GEN_S);
								glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_DECAL);
								glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
								glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP); 
								//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP);
								//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP);	
	
								glEnable(GL_NORMALIZE);
								glBlendFunc(GL_SRC_COLOR,GL_ONE);
								glEnable(GL_BLEND);
    
								affiche_metaballs();

								glDisable(GL_BLEND);

								glDisable(GL_TEXTURE_GEN_S);
								glDisable(GL_TEXTURE_GEN_T);
								
								glTexEnvf(GL_TEXTURE_ENV,GL_TEXTURE_ENV_MODE,GL_MODULATE );
								//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
								//glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

								glLoadIdentity();			// Reset The View
								glTranslatef(-70.0f,poscarot1,-250);
								glDisable(GL_DEPTH_TEST);
								glColor3f(0.2f,0.2f,0.2f);
								glDisable(GL_TEXTURE_2D);	
								glPushMatrix();
									glTranslatef(-3.0f,-3.0f,8.0f);
									glRotatef(2*X,1.0f,1.0f,1.0f);
									glCallList(GL_Carotte);
								glPopMatrix();
								glColor3f(1.0f,1.0f,1.0f);
								glEnable(GL_TEXTURE_2D);
								glEnable(GL_DEPTH_TEST);
								glBindTexture(GL_TEXTURE_2D, T_Carotte);
								glRotatef(2*X,1.0f,1.0f,1.0f);
								glCallList(GL_Carotte);

								glLoadIdentity();			// Reset The View
								glTranslatef(-70.0f,poscarot2,-250);
								glDisable(GL_DEPTH_TEST);
								glColor3f(0.2f,0.2f,0.2f);
								glDisable(GL_TEXTURE_2D);	
								glPushMatrix();
									glTranslatef(-3.0f,-3.0f,8.0f);
									glRotatef(2*X+180,1.0f,1.0f,1.0f);
									glCallList(GL_Carotte);
								glPopMatrix();
								glColor3f(1.0f,1.0f,1.0f);
								glEnable(GL_TEXTURE_2D);
								glEnable(GL_DEPTH_TEST);
								glBindTexture(GL_TEXTURE_2D, T_Carotte);
								glRotatef(2*X+180,1.0f,1.0f,1.0f);
								glCallList(GL_Carotte);

								glLoadIdentity();			// Reset The View
								glTranslatef(-70.0f,poscarot3,-250);
								glDisable(GL_DEPTH_TEST);
								glColor3f(0.2f,0.2f,0.2f);
								glDisable(GL_TEXTURE_2D);	
								glPushMatrix();
									glTranslatef(-3.0f,-3.0f,8.0f);
									glRotatef(2*X+250,1.0f,1.0f,1.0f);
									glCallList(GL_Carotte);
								glPopMatrix();
								glColor3f(1.0f,1.0f,1.0f);
								glEnable(GL_TEXTURE_2D);
								glEnable(GL_DEPTH_TEST);
								glBindTexture(GL_TEXTURE_2D, T_Carotte);
								glRotatef(2*X+250,1.0f,1.0f,1.0f);
								glCallList(GL_Carotte);

								poscarot1 -= 0.5f;
								poscarot2 -= 0.5f;
								poscarot3 -= 0.5f;

								if (poscarot1 == -225) poscarot1 = 200;
								if (poscarot2 == -225) poscarot2 = 200;
								if (poscarot3 == -225) poscarot3 = 200;


								if (pos_meta>1.0f) pos_meta-=0.05f;
							}
						}

						// 5e part
						if (ord>=14)
						{
							glColor3f(1.0f,1.0f,1.0f);
							glBlendFunc(GL_SRC_COLOR,GL_NONE);
							Affiche_Part5();
							pl->Plan_Deforme(deform_cyl,deform_cyl2,deform_cyl3);
							X=X+0.3f;
							deform_cyl2+=5*deform_cyl_val2;
							deform_cyl3+=10*deform_cyl_val3;
							if ((ord==14) && (row>=12))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("we love:\n",32,20,360,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==14) && (row>=18))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("digital murder\n",32,20,300,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==14) && (row>=24))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("eclipse\n",32,20,270,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==14) && (row>=30))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("ethereal\n",32,20,240,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==14) && (row>=36))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("knigths\n",32,20,210,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==14) && (row>=42))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("kiki prod\n",32,20,180,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==14) && (row>=48))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("naa\n",32,20,150,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==14) && (row>=54))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("newgen\n",32,20,120,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==14) && (row>=60))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("nehe\n",32,20,90,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("we love:\n",32,20,360,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15) && (row>=18))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("marshals\n",32,20,300,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15) && (row>=24))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("cymagine\n",32,20,270,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15) && (row>=30))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("experience\n",32,20,240,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15) && (row>=36))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("epidemic\n",32,20,210,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15) && (row>=42))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("mankind\n",32,20,180,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15) && (row>=48))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("ukonx\n",32,20,150,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15) && (row>=54))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("dahan\n",32,20,120,T_Fonte);
								glDisable(GL_BLEND);
							}
							if ((ord==15) && (row>=60))
							{
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								Affiche_texte("all at synthesis\n",32,20,90,T_Fonte);
								glDisable(GL_BLEND);
							}
							if (ord>=14)
							{
								glLoadIdentity();			// Reset The View
								glClear(GL_DEPTH_BUFFER_BIT);
								glTranslatef(80.0f,-40.0f,-250);
								glDisable(GL_DEPTH_TEST);
								glColor3f(0.2f,0.2f,0.2f);
								glDisable(GL_TEXTURE_2D);	
								glPushMatrix();
									glTranslatef(-8.0f,+4.0f,25.0f);
									glRotatef(2*X,1.0f,1.0f,1.0f);
									glCallList(GL_Glace);
								glPopMatrix();
								glColor3f(1.0f,1.0f,1.0f);		
								glEnable(GL_TEXTURE_2D);
								glEnable(GL_DEPTH_TEST);
								glBindTexture(GL_TEXTURE_2D, T_Glace);
								glRotatef(2*X,1.0f,1.0f,1.0f);
								glCallList(GL_Glace);
							}
							if (ord>=16)
							{
								glLoadIdentity();
								glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
								glEnable(GL_BLEND);
								glTranslatef(poschat,-0.42f,-1);
								glBindTexture(GL_TEXTURE_2D, T_Chat);
								glBegin(GL_QUADS);
									glTexCoord2f(0.0,0.0); glVertex3f(0.0f,0.0f,0.0f);
									glTexCoord2f(0.8f,0.0); glVertex3f(0.25f,0.0f,0.0f);
									glTexCoord2f(0.8f,0.8f); glVertex3f(0.25f,0.25f,0.0f);
									glTexCoord2f(0.0,0.8f); glVertex3f(0.0f,0.25f,0.0f);
									
								glEnd();
								glDisable(GL_BLEND);
								if (poschat<-0.5) poschat+=0.01f;
								else
								{
									glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
									glEnable(GL_BLEND);
									Affiche_texte("the end\n",32,250,200,T_Fonte);
									glDisable(GL_BLEND);
								}
							}

						}
					}

//					cyl->Cylindre_Deforme(deform_cyl,deform_cyl2,deform_cyl3);
//					pl->Plan_Deforme(deform_cyl,deform_cyl2,deform_cyl3);
					SwapBuffers(hDC);				// Swap Buffers (Double Buffering)

				}
			}
		}
	}

	// Shutdown
	KillGLWindow();									// Kill The Window


	// STOP SONG
//#ifdef USEFMOD
	FMUSIC_FreeSong(mod);
	FSOUND_Close();
//#endif
	return 0;
}


