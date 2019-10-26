#define FULLSCREEN // its displayed fullscreen
//	{64.75f,  0.f,0.f, 0.f,0.f, 0.f,1000.f, MAKESCENEFLAG(0,1,1,0,1)},

//{38.f,  104.f,0.75f, ZERO,ZERO, 190.f,10.f, MAKESCENEFLAG(1,0,0,0,0)},

#define xres 1920
#define yres 1080

#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include <windows.h>
#include <Mmsystem.h>
#include <math.h>

#include <gl\gl.h>		
#include <gl\glu.h>		
#include "deepfloweroptimized2.h"

#define ZERO 0.000005f
#define MAXVERTEX (1024*1024*2)
#define MAXPOLYVERTEX 18
#define MAXPOLYS (1024*1024*2)
#define MAKESCENEFLAG(cubesWhite,cubesBlack,backgroundBlack,divPolys,morph1) (((((cubesBlack) & 1)|(((cubesWhite) & 1)<<1)|(((backgroundBlack) & 1)<<2)|(((divPolys) & 7)<<3)|(morph1<<6) )<<1)+1)

struct VERTEX
{
	float x,y,z;
};

struct POLY
{
	VERTEX *vertices[MAXPOLYVERTEX];
	int color;
	int vertexCount;
};

struct PLANE
{
	float a,b,c,d;
};

struct SCENE
{
	float startTime,animStartTime,animSpeed,cameraStartTime,cameraSpeed,cameraDistance,cameraZoom;
	int sceneFlags;
};

static unsigned int sceneFlag = 0;
static int polyCount = 0;
static int seed = 0;
static float lightPosition[4] = {0.f,0.f,0.f,1.f};
#ifndef _DEBUG
	extern "C" int _fltused = 1;
#endif
static float n255 = 255.f;
static float n7fff = (float)0x7fff;
static float nDouble = (float)0x7fff/(float)0x4000;
static float n1 = 1.f;
static float nFadeOutSpeed = 66.f;
static float fadeOutTime = 64.f;
static float materialSpecReflection[] = { 10.f, 10.f, 10.f, 1.f };
static unsigned int lineColor = 48+(48<<8)+(48<<16)+(255<<24);
static unsigned int whiteColor = 0xffffffff;
#include "scenescompiled.h"
POLY polys[MAXPOLYS];
VERTEX vertices[MAXVERTEX];
VERTEX *curVertex;
static float m[16];

float __fastcall frand()
{
	float temp;
	__asm
	{
			mov		eax, dword ptr [seed]
			imul	eax, 0x000343FD
			add		eax, 0x00269EC3
			mov		dword ptr [seed], eax
			sar		eax, 10
			and		eax, 0x00007FFF
			mov		dword ptr[temp],eax	
			fild    dword ptr[temp]
			fdiv    n7fff
	}
}

float __inline fsrand()
{
	__asm
	{
		call frand
		fmul dword ptr[nDouble]
		fsub dword ptr[n1]
	}
}

#define sin(x) sinf(x)
#define cos(x) cosf(x)

VERTEX *addVertex(VERTEX *p)
{
	curVertex++;
	curVertex->x = p->x;
	curVertex->y = p->y;
	curVertex->z = p->z;
	return curVertex;
}

POLY * __stdcall addPoly4(int color, VERTEX *p1,VERTEX *p2,VERTEX *p3,VERTEX *p4)
{
	POLY *p	= &polys[polyCount++];
	color = (sceneFlag & 0x02) ? 0xff000000 : color;
	color = (sceneFlag & 0x04) ? whiteColor : color;
	p->color = color;
	p->vertexCount	= 4;
	p->vertices[0] = addVertex(p4);
	p->vertices[1] = addVertex(p3);
	p->vertices[2] = addVertex(p2);
	p->vertices[3] = addVertex(p1);
	return p;
}

__inline float planeDist(VERTEX *v, PLANE *p)
{
	return v->x * p->b + v->y * p->c + v->z * p->d + p->a;
}

void addCubeByModelViewMatrixAndColor(int color)
{
	glGetFloatv(GL_MODELVIEW_MATRIX,m);
	VERTEX cV[8];
//	float *write = &cV[0].x;
//	for (int vertex = 0; vertex < 8; ++vertex)
	//{
		int x,y,z;
		__asm
		{
			//push edi
			//push esi
			//push ecx
			//push ebx
			//push eax

			lea esi,dword ptr[cV]
			xor ecx,ecx
nextVertex:
			lea edi,dword ptr[m]

			//const float x = (float)((vertex & 1) * 2 - 1);
			//const float y = (float)(((vertex>>1) & 1) * 2 - 1);
			//const float z = (float)(((vertex>>2) & 1) * 2 - 1);
			mov ebx,ecx
			mov eax,ebx
			and al,1
			sal al,1
			sub eax,1
			mov dword ptr[x],eax
			sar bl,1
			mov eax,ebx
			and al,1
			sal al,1
			sub eax,1
			mov dword ptr[y],eax
			sar bl,1
			mov eax,ebx
			and al,1
			sal al,1
			sub eax,1
			mov dword ptr[z],eax

			//write[0] = x * m[0] + y * m[4] + z * m[8]  + m[12]; 
			//write[1] = x * m[1] + y * m[5] + z * m[9]  + m[13]; 
			//write[2] = x * m[2] + y * m[6] + z * m[10] + m[14]; 
			//write += 3;

			fild dword ptr[x]
			fmul dword ptr[edi+0*4*4]
			fstp dword ptr[esi]
			fild dword ptr[y]
			fmul dword ptr[edi+1*4*4]
			fadd dword ptr[esi]
			fstp dword ptr[esi]
			fild dword ptr[z]
			fmul dword ptr[edi+2*4*4]
			fadd dword ptr[esi]
			fadd dword ptr[edi+3*4*4]
			fstp dword ptr[esi]

			add esi,4
			add edi,1*4

			fild dword ptr[x]
			fmul dword ptr[edi+0*4*4]
			fstp dword ptr[esi]
			fild dword ptr[y]
			fmul dword ptr[edi+1*4*4]
			fadd dword ptr[esi]
			fstp dword ptr[esi]
			fild dword ptr[z]
			fmul dword ptr[edi+2*4*4]
			fadd dword ptr[esi]
			fadd dword ptr[edi+3*4*4]
			fstp dword ptr[esi]

			add esi,4
			add edi,1*4

			fild dword ptr[x]
			fmul dword ptr[edi+0*4*4]
			fstp dword ptr[esi]
			fild dword ptr[y]
			fmul dword ptr[edi+1*4*4]
			fadd dword ptr[esi]
			fstp dword ptr[esi]
			fild dword ptr[z]
			fmul dword ptr[edi+2*4*4]
			fadd dword ptr[esi]
			fadd dword ptr[edi+3*4*4]
			fstp dword ptr[esi]

			add esi,4
			add edi,1*4

			inc ecx
			cmp cl,8
			jne nextVertex
	
			//pop eax
			//pop ebx
			//pop ecx
			//pop esi
			//pop edi
		}
	//}
	/*
	    4    5
	  0   1
        6    7
      2   3
	*/
	addPoly4(color,&cV[0],&cV[1],&cV[3],&cV[2]);
	addPoly4(color,&cV[5],&cV[4],&cV[6],&cV[7]);
	addPoly4(color,&cV[1],&cV[5],&cV[7],&cV[3]);
	addPoly4(color,&cV[4],&cV[5],&cV[1],&cV[0]);
	addPoly4(color,&cV[2],&cV[3],&cV[7],&cV[6]);
	addPoly4(color,&cV[4],&cV[0],&cV[2],&cV[6]);
}

void processPlaneWithModelViewMatrix()
{
	VERTEX k;
	PLANE plane;
	bool normalBool[MAXPOLYVERTEX];

	glGetFloatv(GL_MODELVIEW_MATRIX,m);
	
	plane.b = m[2+0*4];
	plane.c = m[2+1*4];
	plane.d = m[2+2*4];
	plane.a = m[12] * plane.b + m[13] * plane.c + m[14] * plane.d;	// camera pos already negativ so no need to negate the plane.a

	for (int i = 0; i < polyCount; ++i)
	{
		POLY *p = &polys[i];
		bool allout = true;
		bool someout = false;

		for (int vi = 0; vi < p->vertexCount; ++vi)
		{
			bool behind = planeDist(p->vertices[vi],&plane)<0.f;
			allout &= behind; // wenn einer drinnen ist dann muss das false werden
			someout |= behind;
			normalBool[vi] = !behind;
		}

		if (allout)
			p->vertexCount = 0; // we must do this in order to preserve the order
			//polys[i--] = polys[--polyCount];
		else
		if (someout)
		{
			POLY pNew;
			pNew.vertexCount = 0;
			pNew.color = p->color;
			// here comes the clipping
			for (int vi = 0; vi < p->vertexCount; ++vi)
			{
				if (normalBool[vi])
					pNew.vertices[pNew.vertexCount++] = p->vertices[vi];
				const int vip = (vi+1)%p->vertexCount;
				const float p0x = p->vertices[vi]->x;
				const float p0y = p->vertices[vi]->y;
				const float p0z = p->vertices[vi]->z;
				const float nx	= p->vertices[vip]->x - p0x;
				const float ny	= p->vertices[vip]->y - p0y;
				const float nz	= p->vertices[vip]->z - p0z;
				const float t=(-plane.a-plane.b*p0x-plane.c*p0y-plane.d*p0z)/(plane.b*nx+plane.c*ny+plane.d*nz); // intersection with plane
				if (t >= 0.f && t < 1.f)
				{
					k.x = p0x + nx * t;
					k.y = p0y + ny * t;
					k.z = p0z + nz * t;
					pNew.vertices[pNew.vertexCount++] = addVertex(&k);
				}
			}
			polys[i] = pNew;
		}
	}

	//// now reflect them
	const int polyCountStatic = polyCount;
	for (int i = 0; i < polyCountStatic; ++i)
	{
		POLY *inputPoly = &polys[i]; 
		// add the reflected ones by a plane
		if (inputPoly->vertexCount > 0)
		{
			POLY *p	= &polys[polyCount++];
			p->color		= inputPoly->color;
			p->vertexCount  = inputPoly->vertexCount;
			for (int j = 0; j < inputPoly->vertexCount; ++j)
			{
				VERTEX *oldVertex = inputPoly->vertices[inputPoly->vertexCount-j-1];
				const float planeD = planeDist(oldVertex,&plane) * ((sceneFlag & 0x80) ? 4.f : 2.f);
				k.x = oldVertex->x - planeD * plane.b;
				k.y = oldVertex->y - planeD * plane.c;
				k.z = oldVertex->z - planeD * plane.d;
				p->vertices[j] = addVertex(&k);
			}
		}
	}
}

void drawPolys()
{
	if (!(sceneFlag & 0x02))
		glEnable(GL_LIGHTING);
	glBegin(GL_TRIANGLES);
	for (int i = 0; i < polyCount; ++i)
	{
		POLY *p = &polys[i];
		const int drawPolyCount = p->vertexCount-2;
		if (drawPolyCount > 0)
		{
			VERTEX *p0 = p->vertices[0];
			VERTEX *p1 = p->vertices[1];
			VERTEX *p2 = p->vertices[2];
			const float dx0 = p1->x-p0->x;
			const float dy0 = p1->y-p0->y;
			const float dz0 = p1->z-p0->z;
			const float dx1 = p2->x-p0->x;
			const float dy1 = p2->y-p0->y;
			const float dz1 = p2->z-p0->z;
			glColor4ubv((GLubyte*)&p->color);
			glNormal3f(dy0*dz1-dy1*dz0,dz0*dx1-dz1*dx0,dx0*dy1-dx1*dy0);
			for (int rasterizer = 0; rasterizer < drawPolyCount; ++rasterizer)
			{
				glVertex3fv((float*)p0);
				glVertex3fv((float*)p->vertices[1+rasterizer]);
				glVertex3fv((float*)p->vertices[2+rasterizer]);
			}
		}
	}
	glEnd();
	glDisable(GL_LIGHTING);
	glBegin(GL_LINES);
	POLY *p = polys;
	for (int i = 0; i < polyCount; ++i)
	{
		glColor4ubv((GLubyte*)&lineColor); // the program flickers on some machines if we don't do this / dunno why
		for (int vertex = 0; vertex < p->vertexCount; ++vertex)
		{
			glVertex3fv((float*)p->vertices[vertex]);
			glVertex3fv((float*)p->vertices[(vertex+1) % p->vertexCount]);
		}
		p++;
	}
	glEnd();
}

void buildScene(float time)
{
	seed = 0;
	polyCount = 0;
	curVertex = vertices;
	for (int x = 0; x < 400; ++x)
	{
		glLoadIdentity();
		if (x & 8)
			glScalef(5.f,5.f,5.f);
		glTranslatef(fsrand()*100.f,fsrand()*100.f,fsrand()*100.f);
		glScalef(frand()*20.f,frand()*10.f,frand()*10.f);
		addCubeByModelViewMatrixAndColor(0xffffffff);
	}

	glLoadIdentity();
	for (int x = 0; x < 400; ++x)
	{
		float t = (float)x / 20.f+time*0.025f;
		glRotatef(16.f*sin(t),-0.1f+fsrand()*0.1f,cos(t)+fsrand()*0.5f,-0.1f+fsrand()*0.1f);
		glTranslatef(0,0,3.f);
		glScalef(1.0125f,1.0125f,1.0125f);
		int	color = 0xdff0f9f0;//ffffff;
		if (x & 0x03)
			color = 0xdf190b05;//000000;
		if (!(x & 0x0f))
			//color = 0xdf301050;
			color = 0xdf03e387;
			//color = 0xdf09d1de;
			//color = 0xdf05a7f3;
		addCubeByModelViewMatrixAndColor(color);
		glPushMatrix();
		glTranslatef(50.f,50.f,50.f);
		glScalef(4.f,4.f,4.f);
		addCubeByModelViewMatrixAndColor(color);
		glPopMatrix();
	}

	glLoadIdentity();
	glScalef(2.f,2.f,2.f);
	for (int k = 0; k < 256; ++k)
	{
		float t = (float)k / 20.f+time*0.5f;
		glRotatef(8.f,sin(t),cos(t),0);
		glTranslatef(0,0,10.f);
		addCubeByModelViewMatrixAndColor(0xdf396406);
//		addCubeByModelViewMatrixAndColor(0xdf055479);
	}

	for (int i = 0; i < 8; ++i)
	{
		float t = time*0.5f;
		glLoadIdentity();
		glRotatef((float)i*360/8+sin(t*0.2f)*40.f,sin(t*0.4f),sin(t*0.8f),cos(t*0.4f));
		processPlaneWithModelViewMatrix();
	}
}

/////////////////////////////////////////////////////////////////////////////////
// initialized data
/////////////////////////////////////////////////////////////////////////////////
// MAX_SAMPLES gives you the number of samples for the whole song. we always produce stereo samples, so times 2 for the buffer
static HDC		     hDC;
static SAMPLE_TYPE	lpSoundBuffer[MAX_SAMPLES*2];  
static HWAVEOUT	hWaveOut;
#define WAVE_FORMAT_IEEE_FLOAT 0x0003

static WAVEFORMATEX WaveFMT =
{
#ifdef FLOAT_32BIT	
	WAVE_FORMAT_IEEE_FLOAT,
#else
	WAVE_FORMAT_PCM,
#endif		
    2, // channels
    SAMPLE_RATE, // samples per sec
    SAMPLE_RATE*sizeof(SAMPLE_TYPE)*2, // bytes per sec
    sizeof(SAMPLE_TYPE)*2, // block alignment;
    sizeof(SAMPLE_TYPE)*8, // bits per sample
    0 // extension not needed
};

static WAVEHDR WaveHDR = 
{
	(LPSTR)lpSoundBuffer, 
	MAX_SAMPLES*sizeof(SAMPLE_TYPE)*2,			// MAX_SAMPLES*sizeof(float)*2(stereo)
	0, 
	0, 
	0, 
	0, 
	0, 
	0
};

static MMTIME MMTime = 
{ 
	TIME_SAMPLES,
	0
};

#ifndef REAL4K

	void initDemoGL()
	{
		glEnable(GL_COLOR_MATERIAL);
		glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
		glMaterialfv(GL_FRONT, GL_SPECULAR, materialSpecReflection);
		glMateriali(GL_FRONT, GL_SHININESS, 64);
	
		glEnable(GL_CULL_FACE);
		glEnable(GL_DEPTH_TEST);
		glEnable(GL_NORMALIZE);
		glEnable(GL_LIGHT0);
		glLightfv(GL_LIGHT0, GL_POSITION,lightPosition); 
	}

	void playDemoGL(float cameraTime, float sceneTime, float cameraDistance, int flags)
	{
		sceneFlag = flags;
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(120.0f, (float)xres/(float)yres, 2.f, 50000.0f);
		glMatrixMode(GL_MODELVIEW);

		// drawBackground start
		const float clearColor = sceneFlag & 0x08 ? 0.f : 1.f;
		glClearColor(clearColor,clearColor,clearColor,1.f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		buildScene(sceneTime);
		polyCount >>= (sceneFlag>>4) & 0x07;

		//glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
		gluLookAt(sin(cameraTime)*cameraDistance,cos(cameraTime*0.4f)*cameraDistance,cos(cameraTime)*cameraDistance,0.f,0.f,0.f,0,1,0.f);
		glRotatef(cameraTime,0,0,1);
		drawPolys();
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glMatrixMode(GL_MODELVIEW);
		glLoadIdentity();
	}

#endif

//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************
//******************************************************************************************************

static DEVMODE dmScreenSettings;
PIXELFORMATDESCRIPTOR pfd = {
			sizeof(PIXELFORMATDESCRIPTOR),
			1,
			PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
			PFD_TYPE_RGBA,
			32,				// Colour buffer bit depth
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			32,				// Depth buffer bit depth
			0, 0,			// stencilbuffer bit detph, auxbuffer bit depth
			PFD_MAIN_PLANE, 
			0, 0, 0, 0 };
#ifdef REAL4K
#ifdef _DEBUG
int WINAPI WinMain(HINSTANCE, HINSTANCE, LPSTR, int)
#else
extern "C" __declspec(noreturn) void WinMainCRTStartup()
#endif
{
	CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
#else
void notUsed()
{
	//CreateThread(0, 0, (LPTHREAD_START_ROUTINE)_4klang_render, lpSoundBuffer, 0, 0);
#endif

	HWND	hWnd;
#ifdef FULLSCREEN
	dmScreenSettings.dmSize			=	sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth	=	xres;
	dmScreenSettings.dmPelsHeight	=	yres;
	dmScreenSettings.dmBitsPerPel	=	32;
	// enable this if you have a too fast computer
	//dmScreenSettings.dmDisplayFrequency = 60;
	dmScreenSettings.dmFields		=	DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT;//|DM_DISPLAYFREQUENCY;

	// We set fullscreen mode
	ChangeDisplaySettings	(&dmScreenSettings,CDS_FULLSCREEN);

	// We hide the cursor
	ShowCursor(FALSE);
#endif
	// We create a window with the "EDIT" trick
	hWnd = CreateWindow("STATIC","STATIC",WS_POPUP|WS_VISIBLE, 0,0, xres, yres,0,0,0,0);
	hDC = GetDC(hWnd);
	SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);

	// Opengl context bind
	wglMakeCurrent(hDC,wglCreateContext(hDC));

	glEnable(GL_COLOR_MATERIAL);
	glColorMaterial(GL_FRONT, GL_AMBIENT_AND_DIFFUSE);
	glMaterialfv(GL_FRONT, GL_SPECULAR, materialSpecReflection);
	glMateriali(GL_FRONT, GL_SHININESS, 64);
	
	glEnable(GL_CULL_FACE);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_NORMALIZE);
	glEnable(GL_LIGHT0);
	glEnable(GL_BLEND);
	glEnable(GL_LINE_SMOOTH);

	glLightfv(GL_LIGHT0, GL_POSITION,lightPosition); 
	glLineWidth(1.5f);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

	waveOutOpen	( &hWaveOut, WAVE_MAPPER, &WaveFMT, NULL, 0, CALLBACK_NULL );
	waveOutPrepareHeader( hWaveOut, &WaveHDR, sizeof(WaveHDR) );
	waveOutWrite( hWaveOut, &WaveHDR, sizeof(WaveHDR) );	

	int currentScene = 0;
	float compareAgainstTime = 0.f;
	float lastBeat=0.f;
	float sceneTime;
	float curAnimSpeed;
	float cameraTime;
	float curCameraSpeed;
	float cameraDistance;
	float cameraZoom;
	float tempToPopFPU;
	do
	{		
		waveOutGetPosition(hWaveOut, &MMTime, sizeof(MMTIME));
		const float curBeat = (float)MMTime.u.sample * (float)(BPM / 4.f / 60.f / 44100.f);

		__asm
		{
			pushfd // that's very important when we change the statusword by ourselves (fpu)
			push ecx
			push eax
			push esi
			mov esi,dword ptr[currentScene]

			// stepsForward = curBeat - lastBeat
			fld  dword ptr [curBeat]
			fsub dword ptr [lastBeat]
			// lastBeat = curBeat
			fld  dword ptr [curBeat]
			fstp dword ptr [lastBeat]

			//sceneTime  += stepsForward * curAnimSpeed;
			//cameraTime += stepsForward * curCameraSpeed;
			//cameraDistance += stepsForward * cameraZoom;
			fld dword ptr[curAnimSpeed]
			fmul st(0),st(1)
			fadd dword ptr[sceneTime]
			fstp dword ptr[sceneTime]

			fld dword ptr[curCameraSpeed]
			fmul st(0),st(1)
			fadd dword ptr[cameraTime]
			fstp dword ptr[cameraTime]

			fld dword ptr[cameraZoom]
			fmul st(0),st(1)
			fadd dword ptr[cameraDistance]
			fstp dword ptr[cameraDistance]
		
			//stepsForward = checkScene->startTime - curBeat;  
			//if (stepsForward <= 0.f) // we have changed the sign before
			fldz
			fld dword ptr[compareAgainstTime]
			fsub dword ptr[curBeat]
			fcom st(1)
			fstsw ax
			sahf
			ja nonewsegment

				//sceneTime		-= distanceToThisScene * curAnimSpeed;
				//cameraTime		-= distanceToThisScene * curCameraSpeed;
				//cameraZoom      -= distanceToThisScene * cameraZoom; 
				//lastBeat		= checkScene->startTime;
				mov eax,dword ptr[compareAgainstTime]
				mov dword ptr[lastBeat],eax

				fld dword ptr[curAnimSpeed]
				fmul st(0),st(1)
				fadd dword ptr[sceneTime]
				fstp dword ptr[sceneTime]

				fld dword ptr[curCameraSpeed]
				fmul st(0),st(1)
				fadd dword ptr[cameraTime]
				fstp dword ptr[cameraTime]

				fld dword ptr[cameraZoom]
				fmul st(0),st(1)
				fadd dword ptr[cameraDistance]
				fstp dword ptr[cameraDistance]

				fldz

				//valueWithCheck(&curAnimSpeed	,checkScene->animSpeed);
				//valueWithCheck(&curCameraSpeed	,checkScene->cameraSpeed);
				//valueWithCheck(&sceneTime		,checkScene->animStartTime);
				//valueWithCheck(&cameraTime		,checkScene->cameraStartTime);
				//valueWithCheck(&cameraDistance	,checkScene->cameraDistance);
				//valueWithCheck(&cameraZoom		,checkScene->cameraZoom);

				// optimized this to first put onto stack and then call
				fld dword ptr[sceneElement1+esi*4]
				fcom st(1) // compare 0 with value
				fstsw ax
				sahf
				jne scenetimek0
				//fchs
				fadd dword ptr[sceneTime] 
scenetimek0:
				fstp dword ptr[sceneTime]

				fld dword ptr[sceneElement2+esi*4]
				fcom st(1) // compare 0 with value
				fstsw ax
				sahf
				jne curAnimSpeedk0
//				fchs
				fadd dword ptr[curAnimSpeed] 
curAnimSpeedk0:
				fstp dword ptr[curAnimSpeed]

				fld dword ptr[sceneElement3+esi*4]
				fcom st(1) // compare 0 with value
				fstsw ax
				sahf
				jne cameraTimek0
//				fchs
				fadd dword ptr[cameraTime] 
cameraTimek0:
				fstp dword ptr[cameraTime]

				fld dword ptr[sceneElement4+esi*4]
				fcom st(1) // compare 0 with value
				fstsw ax
				sahf
				jne curCameraSpeedk0
//				fchs
				fadd dword ptr[curCameraSpeed] 
curCameraSpeedk0:
				fstp dword ptr[curCameraSpeed]

				fld dword ptr[sceneElement5+esi*4]
				fcom st(1) // compare 0 with value
				fstsw ax
				sahf
				jne cameraDistancek0
//				fchs
				fadd dword ptr[cameraDistance] 
cameraDistancek0:
				fstp dword ptr[cameraDistance]

				fld dword ptr[sceneElement6+esi*4]
				fcom st(1) // compare 0 with value
				fstsw ax
				sahf
				jne cameraZoomk0
//				fchs
				fadd dword ptr[cameraZoom] 
cameraZoomk0:
				fstp dword ptr[cameraZoom]

				//if (checkScene->sceneFlags)
				//	sceneFlag = checkScene->sceneFlags;
				mov eax,dword ptr[sceneElement7+esi*4]
				or eax,eax
				je nonewflag
				mov dword ptr[sceneFlag],eax
nonewflag:
				//checkScene++;
				fld dword ptr[sceneElement0+esi*4+4]
				fadd dword ptr[compareAgainstTime]
				fstp dword ptr[compareAgainstTime]
				inc currentScene

				fstp dword ptr[tempToPopFPU] // the zero
nonewsegment:
				fstp dword ptr[tempToPopFPU] // the zero
				fstp dword ptr[tempToPopFPU] // the zero
				fstp dword ptr[tempToPopFPU]


				//curBeat -= 60.75f;
				//if (curBeat > 0.f)
				//{
				//	int k = (int)(255.f-curBeat*255.f);
				//	if (k < 0) k = 0;
				//	lineColor = (48+(48<<8)+(48<<16))+(k<<24);
				//}
				fld dword ptr[fadeOutTime]
				fsub dword ptr[curBeat]
				fmul dword ptr[nFadeOutSpeed]
				fadd dword ptr[n255]
				fistp dword ptr[tempToPopFPU]
				mov eax,dword ptr[tempToPopFPU]
				cmp eax,255
				jg nofadeout
				cmp eax,0
				jl nofadeout // hack
				mov byte ptr[whiteColor+3],al
				cmp al,16
				jae nofadeout
				sal al,4
				mov byte ptr[lineColor+3],al
nofadeout:

				pop esi
				pop eax
				pop ecx
				popfd // that's very important when we change the statusword by ourselves (fpu)
		}

		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		gluPerspective(120.0, (double)xres/(double)yres, 2.0, 50000.0);
		glMatrixMode(GL_MODELVIEW);

		// drawBackground start
		const float clearColor = sceneFlag & 0x08 ? 0.f : 1.f;
		glClearColor(clearColor,clearColor,clearColor,1.f);
		glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		buildScene(sceneTime);
		polyCount >>= (sceneFlag>>4) & 0x07;

		glLoadIdentity();
		gluLookAt(sin(cameraTime)*cameraDistance,cos(cameraTime*0.4f)*cameraDistance,cos(cameraTime)*cameraDistance,0.f,0.f,0.f,0.f,1.f,0.f);
		glRotatef(cameraTime,0,0,1);
		drawPolys();

		PeekMessage(NULL,0,0,0,PM_REMOVE); // prevent the hourglass

		SwapBuffers(hDC);

	} while(!GetAsyncKeyState(VK_ESCAPE) && (MMTime.u.sample < MAX_SAMPLES));
	ExitProcess(0);
}