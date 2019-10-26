//////////////////////////////////////////////////////////////////////////
//                    
//                           CAVE 4k effect
//                                 by
//                BoyC / Conspiracy ^ Digital Dynamite
//
//  We decided this effect was too big for a "synced" 4k intro, so I just
//         released it as it is... Use this code at your own risk!
// This effect is the exact copy of the tunnel effect from the buenzli 13
//       invitation intro,  at least for the parameters and texture.
//
//////////////////////////////////////////////////////////////////////////


#pragma comment(linker,"/FILEALIGN:0x200")
#pragma comment(lib,"opengl32.lib")
#pragma comment(lib,"glu32.lib")

#include <windows.h>
#include <gl\gl.h>
#include <gl\glu.h>
#include <gl\glext.h>
//#include <math.h>

// screen X resolution
#define SXRES 800

// screen Y resolution
#define SYRES 600

// grid X resolution
#define GRIDX 40
// grid Y resolution
#define GRIDY 30
// grid Z resolution, this should be left at 4
#define GRIDZ 4
// tunnel depth
#define TDEPTH 100
// threshold value for the blobs
#define THRESHOLD 10.0f
// number of tunnels
#define TUNNELS 10

float RADTHETA=3.1415f/180.0f; //guess what, deg->rad help constant
float oldcampos[2]; // previous camera position

int TunnelPos=0; //starting position of the tunnel
int Precalc=TDEPTH;

float FogCol[4]={48/255.0f,158/255.0f,1,1}; //fog and background clear color
float LightCol[4]={1,1,1,1}; //light color
GLuint Tex, //the texture
       TexImage; //buffer used for the feedback effect

__forceinline float sin(float v)
{
	volatile float res;
	__asm
	{
		fld v
		fsin
		fstp res
	}
	return res;
}

__forceinline float cos(float v)
{
	volatile float res;
	__asm
	{
		fld v
		fcos
		fstp res
	}
	return res;
}

__forceinline float fabs(float v)
{
	volatile float res;
	__asm
	{
		fld v
		fabs
		fstp res
	}
	return res;
}

unsigned int next;

void memcpy_(void * to, const void * from, unsigned int sizez) 
{
  __asm {
    mov edi,to
    mov esi,from
    mov ecx,sizez
    rep movsb
  }
};

long _cdecl _ftol (float f)
{
  long a;
  _asm fistp dword ptr [a]
  return a;
}

// window create stuff

HWND            wm_hWnd=NULL;
HDC             wm_hDC=NULL;
HGLRC           wm_hRC=NULL;
PIXELFORMATDESCRIPTOR pfd={sizeof(PIXELFORMATDESCRIPTOR),1,PFD_DRAW_TO_WINDOW |PFD_SUPPORT_OPENGL |PFD_DOUBLEBUFFER,PFD_TYPE_RGBA,32,0, 0, 0, 0, 0, 0,0,0,0,0, 0, 0, 0,32,0,0,PFD_MAIN_PLANE,0,0, 0, 0};

__forceinline void wm_Create()
{
#ifndef _DEBUG
	DEVMODE dmScreenSettings;		
	dmScreenSettings.dmSize=sizeof(dmScreenSettings);		
	dmScreenSettings.dmPelsWidth	= SXRES;
	dmScreenSettings.dmPelsHeight	= SYRES;
 	dmScreenSettings.dmBitsPerPel	= 32;
	dmScreenSettings.dmFields=DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;
	ChangeDisplaySettings(&dmScreenSettings,CDS_FULLSCREEN);
#endif

	ShowCursor( FALSE ); // <-- 15 bytes...

	wm_hWnd=CreateWindowEx(	WS_EX_APPWINDOW,"EDIT", NULL,WS_CLIPSIBLINGS |WS_CLIPCHILDREN |WS_VISIBLE |WS_POPUP,0, 0,SXRES,SYRES,NULL,NULL,NULL,NULL);

	wm_hDC=GetDC(wm_hWnd);
	SetPixelFormat(wm_hDC,ChoosePixelFormat(wm_hDC,&pfd),&pfd);
	wm_hRC=wglCreateContext(wm_hDC);
	wglMakeCurrent(wm_hDC,wm_hRC);
}

// marching tetraeders algo
typedef struct
{
	float Value;
	float Pos[3];
	float Normal[3];
	int Inside;
} GRIDPOINT;

//yeah the tetraeder lookup tables are a bit smaller than the marching cubes ones ;)
unsigned char Tetraeders[6][4] = 
{
	//6 tetraeders that make up the cube (cube vertex indices)
	{3,7,2,1},
	{3,0,4,1},
	{3,4,7,1},
	{1,4,5,7},
	{1,5,2,7},
	{2,5,6,7}
};

unsigned char TetraMap[16][4] =
{
    //tetraeder vertex: 0 1 2 3     - 0 = inside, 1= outside
	{0,0,0,0}, //       0 0 0 0
	{3,5,6,0}, //       0 0 0 1
	{2,4,6,0}, //       0 0 1 0
	{2,3,5,4}, //       0 0 1 1
	{1,4,5,0}, //       0 1 0 0
	{1,4,6,3}, //       0 1 0 1
	{1,2,6,5}, //       0 1 1 0
	{1,2,3,0}  //       0 1 1 1     next 8 are the same but in reverse order
	           // mappos = vertex0.inside*8+vertex1.inside*4+vertex2.inside*2+vertex3.inside;
};

unsigned char TriMap[6] = {0,1,2,0,2,3};

float TetraederEdges[6][3]; //6 possible intersection points of the edges. mapped by TetraMap[value]-1, if TetraMap[value] is 0, end
float TetraederNormals[6][3];
GRIDPOINT Cube[8]; //8 grid points of the cube

GRIDPOINT Grid[GRIDX][GRIDY][GRIDZ];

float Linear(float a, float b, float t) //linear interpolation
{
	return a+(b-a)*t;
}

void CalculateCube() //calculate one cube of the marching tetraeder grid
{
	int e1,e2;
	int x;
	int z;
	for (x=0; x<6; x++) //for each tetraeder
	{
		unsigned char Map=(Cube[Tetraeders[x][0]].Inside<<3)
			             +(Cube[Tetraeders[x][1]].Inside<<2)
						 +(Cube[Tetraeders[x][2]].Inside<<1)
						 +Cube[Tetraeders[x][3]].Inside;
		int e=0;

		for (e1=0; e1<3; e1++)
			for (e2=e1+1; e2<4; e2++)
			{
				GRIDPOINT p1,p2;
				p1=Cube[Tetraeders[x][e1]];
				p2=Cube[Tetraeders[x][e2]];
				if (p1.Inside!=p2.Inside)
				{
					float t=(THRESHOLD-p1.Value)/(p2.Value-p1.Value);
					int k;
					for (k=0; k<3; k++)
					{
						TetraederEdges[e][k]=Linear(p1.Pos[k],p2.Pos[k],t);
						TetraederNormals[e][k]=Linear(p1.Normal[k],p2.Normal[k],t);
					}
				}
				e++;
			}

		for (z=0; z<6; z++) 
		if ((TetraMap[Map][0] && z<3) || (TetraMap[Map][3] && z>=3))
		{
			int t=TetraMap[Map][TriMap[z]]-1;
			glTexCoord2f(TetraederEdges[t][0]/(float)GRIDX*3,((-TetraederEdges[t][2]+TunnelPos)/(float)GRIDX*3));
			glNormal3fv(TetraederNormals[t]);
			glVertex3fv(TetraederEdges[t]);
		}

	}
}

// tunnel code, this is not optimal for a 4k but the same code as used in the buenzli invitation so the
// parameters of the tunnel are the same.

GLuint Lists[TDEPTH];

typedef struct //tunnel structure, holds the pre generated values for the path
{
	float xa,ya,xs,ys;
	float bxa,bya,bxs,bys;
	float cxa,cya,cxs,cys;
} TS;

TS ts[TUNNELS+1];

typedef struct //stores the current position of the tunnel
{
	float x,y;
	float r2,rs,ra,rd;
} TUNNEL;

TUNNEL Tunnels[TUNNELS];

__forceinline void InitTunnels() // generates amplitude and size parameters for the tunnels
{
	int x;
	float a=140/25.5f;
	float b=255/25.5f;
	float c=209/255.0f;
	float d=167/255.0f;
	float e=223/25.5f;
	float f=139/25.5f;
	float g=177/255.0f;
	float h=232/255.0f;
	float radius=153/255.0f;

	for (x=0; x<TDEPTH; x++) Lists[x]=glGenLists(1); // we create the display lists here

	srand(81);
	for (x=0; x<=TUNNELS; x++)
	{
		do
		ts[x].xs=rand()/(float)RAND_MAX*a-a/2.0f; //7
		while (fabs(ts[x].xs)<0.1);
		
		do
		ts[x].ys=rand()/(float)RAND_MAX*b-b/2.0f; //7
		while (fabs(ts[x].ys)<0.1);

		do
		ts[x].xa=rand()/(float)RAND_MAX*c-c/2.0f; //0.6
		while (fabs(ts[x].xa)<0.1);
		
		do
		ts[x].ya=rand()/(float)RAND_MAX*d-d/2.0f; //0.6
		while (fabs(ts[x].ya)<0.1);
		
		ts[x].bxs=(rand()/(float)RAND_MAX*e-e/2.0f);
		ts[x].bys=(rand()/(float)RAND_MAX*f-f/2.0f);
		ts[x].bxa=(rand()/(float)RAND_MAX*g-g/2.0f)/2.0f;
		ts[x].bya=(rand()/(float)RAND_MAX*h-h/2.0f)/2.0f;
		Tunnels[x].rd=rand()/(float)RAND_MAX*(GRIDX*4.0f/3.0f)*radius+5;
		Tunnels[x].rs=rand()/(float)RAND_MAX*7.0f-3.5f;
		Tunnels[x].ra=rand()/(float)RAND_MAX*(GRIDX*4.0f/3.0f)/2.0f*radius;

	}
	Tunnels[0].rd=70;
}

__forceinline float CheckPoint(int x, int y) // calculate potential for one point based on the tunnel positions
{
	float p=0;
	int z;
	if (x==1 || x==GRIDX-1 || y==1 || y==GRIDY-1) return -100000; // the edge of the grid should be solid
	for (z=0; z<TUNNELS; z++) p+=Tunnels[z].r2/((x-Tunnels[z].x)*(x-Tunnels[z].x)+(y-Tunnels[z].y)*(y-Tunnels[z].y));
	return p;
}

// texture generating stuff, copypaste from the buenzli invitation code

unsigned char SubPlasma[256*256];
unsigned char GrayScale[256*256];
unsigned char Texture[256*256][3];
unsigned char BlurResult[256*256];

unsigned char catmullrom_interpolate(int v0, int v1, int v2, int v3, float xx)
{
	int a =v0 - v1;
	int P =v3 - v2 - a;
	int Q =a - P;
	int R =v2 - v0;
	int t=(int)(v1+xx*(R+xx*(Q+xx*P)));
	_asm 
	{
		movd mm0,t
		packuswb mm0,mm0
		movd t,mm0
		emms;
	}
	return t;
}

void generate_subplasma() {

	int np=8;
	int rx=256;
	int ry=256;

	int ssize=rx/np;

	int x,y;
	srand(4);
	for (y=0; y<np; y++)
		for (x=0; x<np; x++)
			SubPlasma[x*32+y*32*256] = rand();

	for (y=0; y<np; y++)
		for (x=0; x<256; x++) {
			int p=x&(~31);
			int zy=y*32*256;
			SubPlasma[x+zy] = catmullrom_interpolate(
				SubPlasma[((p-32)&255)+zy],
				SubPlasma[((p   )&255)+zy],
				SubPlasma[((p+32)&255)+zy],
				SubPlasma[((p+64)&255)+zy],
				(x&31)/32.0f);
		}
		
	for (y=0; y<256; y++)
		for (x=0; x<256; x++) {
			int p=y&(~31);
			SubPlasma[x+y*256] = catmullrom_interpolate(
				SubPlasma[x+(((p-32)&255)<<8)],
				SubPlasma[x+(((p   )&255)<<8)],
				SubPlasma[x+(((p+32)&255)<<8)],
				SubPlasma[x+(((p+64)&255)<<8)],
				(y&31)/32.0f);
		}
}

#define WRAPX(x) ((x)&(255))
#define WRAPY(y) ((y)&(255))

void Glass()
{
	unsigned char buffer[65536];
	int a=-127;
	int x;
	int y;
	for (x=0; x<256; x++)
		for (y=0; y<256; y++) {
			int ofs=x+y*256;
			int p=SubPlasma[ofs];
			int dx=p - SubPlasma[WRAPX(x+1)+      (y   <<8)];
			int dy=p - SubPlasma[      x   +(WRAPY(y+1)<<8)];
			unsigned int ox=(x+(dx*a)/32)&(255);
			unsigned int oy=(y+(dy*a)/32)&(255);
			buffer[ofs]=GrayScale[ox+(oy<<8)];
		}
	memcpy_(GrayScale,buffer,65536);
}

void Blur(int s, int it)
{
	int z;
	int j;
	int i;
	for (z=0; z<it; z++) {
		int offset = 0;
		for (j=0; j<256; j++)
		{
			for (i=0; i<256; i++) 
			{				
				unsigned int r01 = SubPlasma[WRAPX(i-s)+(WRAPY(j  )<<8)];
				unsigned int r21 = SubPlasma[WRAPX(i+s)+(WRAPY(j  )<<8)];
				unsigned int r10 = SubPlasma[WRAPX(i  )+(WRAPY(j-s)<<8)];
				unsigned int r12 = SubPlasma[WRAPX(i  )+(WRAPY(j+s)<<8)];
				unsigned int z=0;
				__asm {
					pxor mm0,mm0
					pxor mm7,mm7

					movd mm1,r01
					punpcklbw mm1,mm7
					paddw mm0,mm1

					movd mm1,r21
					punpcklbw mm1,mm7
					paddw mm0,mm1

					movd mm1,r10
					punpcklbw mm1,mm7
					paddw mm0,mm1

					movd mm1,r12
					punpcklbw mm1,mm7
					paddw mm0,mm1

					psrlw mm0,2
					packuswb mm0,mm7
					movd z,mm0;
				}

				BlurResult[offset]=z;

				offset++;
			}
		}
		memcpy_(SubPlasma,BlurResult,65536);
	}
	__asm { emms }
}

void __inline DoTex()
{
	int x;
	static unsigned char t[1024*1024*3];
	generate_subplasma();

	memcpy_(GrayScale,SubPlasma,65536);

	Glass();
	Glass();

	memcpy_(SubPlasma,GrayScale,65536);
	Blur(1,5);
	memcpy_(GrayScale,SubPlasma,65536);

	Blur(163,2);
	for (x=0; x<256*256; x++)
		{
			Texture[x][0]=Texture[x][1]=GrayScale[x]*BlurResult[x]/256;
			Texture[x][2]=GrayScale[x];
		}

	glGenTextures(1,&Tex);
	glBindTexture(GL_TEXTURE_2D,Tex);
	gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGB8,256,256,GL_RGB,GL_UNSIGNED_BYTE,Texture);

	glGenTextures(1,&TexImage);
	glBindTexture(GL_TEXTURE_2D,TexImage);
	gluBuild2DMipmaps(GL_TEXTURE_2D,GL_RGB8,1024,1024,GL_RGB,GL_UNSIGNED_BYTE,t);

}

typedef void (APIENTRY * WGLSWAPINTERVALEXT) (int); //vsync stuff

void mainCRTStartup()
{
	// vsync extension
	WGLSWAPINTERVALEXT wglSwapIntervalEXT = (WGLSWAPINTERVALEXT) wglGetProcAddress("wglSwapIntervalEXT");

	// calculate the rest of the tetraeder map
	int x,y;
	for (x=0; x<8; x++) for (y=0; y<4; y++) TetraMap[15-x][y]=TetraMap[x][y]; 

	// init window
	wm_Create();

	if (wglSwapIntervalEXT) wglSwapIntervalEXT(1); // enable vsync

	// generate texture
	DoTex();

	// init tunnels
	InitTunnels();

	// init opengl
	glEnable(GL_LIGHTING);
	glEnable(GL_LIGHT0);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_NORMALIZE);
	glClearColor(FogCol[0],FogCol[1],FogCol[2],FogCol[3]);
	glFogfv(GL_FOG_COLOR,FogCol);
	glFogi(GL_FOG_MODE,GL_LINEAR);
	glFogf(GL_FOG_START,TDEPTH/10.0);
	glFogf(GL_FOG_END,TDEPTH-10);
	glEnable(GL_FOG);

	glEnable(GL_TEXTURE_2D);

	while(!(GetAsyncKeyState(VK_ESCAPE)&0x8000))
	{
		int m;
		float v1,v2;
		float campos[2];
		float Pos[4];
		float zoom = 1/255.0f;
		float asp=4/3.0f;
		float x1=0,y2=0,x2=SXRES/1024.0f,y1=SYRES/1024.0f;
		int i;

		glClear(0x4100);

		for (;Precalc;Precalc--)
		{
			int x,y,z;
			TunnelPos++;

			//calculate current tunnel positions
			for (x=0; x<TUNNELS; x++)
			{
				float TR=TunnelPos*RADTHETA;
				Tunnels[x].x=GRIDX*((float)sin(TR*ts[x].xs)*ts[x].xa+0.5f+(float)cos(TR*ts[x].bxs)*ts[x].bxa);
				Tunnels[x].y=GRIDY*((float)cos(TR*ts[x].ys)*ts[x].ya+0.5f+(float)sin(TR*ts[x].bys)*ts[x].bya);
				Tunnels[x].r2=max(5,Tunnels[x].rd+(float)sin(TR*Tunnels[x].rs)*Tunnels[x].ra);
			}

			//calculate grid values
			for (x=0; x<GRIDX; x++)
				for (y=0; y<GRIDY; y++)
					for (z=0; z<GRIDZ; z++)
					{
						Grid[x][y][z].Pos[0]=x-GRIDX/2.0f;
						Grid[x][y][z].Pos[1]=y-GRIDY/2.0f;
						Grid[x][y][z].Pos[2]=(float)-(z-1);

						if (z<GRIDZ-1) Grid[x][y][z].Value=Grid[x][y][z+1].Value;
						else Grid[x][y][z].Value=CheckPoint(x,y);

						Grid[x][y][z].Inside=Grid[x][y][z].Value<=THRESHOLD;
					}

			//calculate grid normals
			for (x=1; x<GRIDX-1; x++)
				for (y=1; y<GRIDY-1; y++)
					for (z=1; z<GRIDZ-1; z++)
					{
						Grid[x][y][z].Normal[0]= (Grid[x+1][y  ][z  ].Value-Grid[x-1][y  ][z  ].Value)/2.0f;
						Grid[x][y][z].Normal[1]= (Grid[x  ][y+1][z  ].Value-Grid[x  ][y-1][z  ].Value)/2.0f;
						Grid[x][y][z].Normal[2]=-(Grid[x  ][y  ][z+1].Value-Grid[x  ][y  ][z-1].Value)/2.0f;
					}


			//cycle display lists
			for (x=0; x<TDEPTH; x++) Lists[x]=Lists[(x+1)%(TDEPTH)];

			//create display list for new tunnel slice
			glNewList(Lists[TDEPTH-1],GL_COMPILE);
			glBegin(GL_TRIANGLES);
			for (x=1; x<GRIDX-1; x++)
				for (y=1; y<GRIDY-1; y++)
					{
						for (z=0; z<8; Cube[z++]=Grid[x+(((z+1)&2)>>1)][y+((z&2)>>1)][(z<4)+1]);
						CalculateCube();
					}
			glEnd();
			glTranslatef(0,0,-1);
			glEndList();
		}
		Precalc=1;

		/************ calculate camera ****************/
		m=3;

		v1=(TunnelPos-TDEPTH+m)*RADTHETA;
		v2=(TunnelPos-TDEPTH+m-1)*RADTHETA;

		campos[0]=GRIDX*(float)sin(v1*ts[0].xs)*ts[0].xa+GRIDX*(float)cos(v1*ts[0].bxs)*ts[0].bxa;
		campos[1]=GRIDY*(float)cos(v1*ts[0].ys)*ts[0].ya+GRIDY*(float)sin(v1*ts[0].bys)*ts[0].bya;

		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(90,4/3.0f,0.1,2000.0);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();

		gluLookAt(oldcampos[0],oldcampos[1],-m,campos[0],campos[1],-m-1,0,1,0);
		oldcampos[0]=campos[0];
		oldcampos[1]=campos[1];
		/************ cam calculation done ****************/

		// place light
		Pos[0]=Pos[2]=1;
		Pos[1]=-1;
		Pos[3]=0;
		glLightfv(GL_LIGHT0,GL_POSITION,Pos);

		// draw tunnel
		glBindTexture(GL_TEXTURE_2D,Tex);
		for (x=0; x<TDEPTH; x++) glCallList(Lists[x]);

		// FEEDBACK
		glPushAttrib(GL_ALL_ATTRIB_BITS);
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glViewport(0,0,SXRES,SYRES);
		gluOrtho2D (0, SXRES,SYRES,0);

		glColor4ub(220,183,103,167);

		glEnable(GL_BLEND);
		glDisable(GL_DEPTH_TEST);
		glBlendFunc(GL_SRC_ALPHA,GL_SRC_ALPHA);
		glDisable(GL_LIGHTING);
		glEnable(GL_TEXTURE_2D);

		glBindTexture(GL_TEXTURE_2D,TexImage);

		for (i=0; i<6; i++) {
			glCopyTexImage2D(GL_TEXTURE_2D,0,GL_RGB8,0,0,1024,1024,0);
			glBegin(GL_TRIANGLE_STRIP);
				glTexCoord2f(x1+i*zoom*asp,y1-i*zoom); glVertex2f(0,0); 
				glTexCoord2f(x1+i*zoom*asp,y2+i*zoom); glVertex2f(0,SYRES);
				glTexCoord2f(x2-i*zoom*asp,y1-i*zoom); glVertex2f(SXRES,0);
				glTexCoord2f(x2-i*zoom*asp,y2+i*zoom); glVertex2f(SXRES,SYRES);
			glEnd();
		}
		glPopAttrib();/**/

		SwapBuffers(wm_hDC);
	} 
}