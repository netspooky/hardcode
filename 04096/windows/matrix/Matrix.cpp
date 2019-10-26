//matrix 4k intro
//(c)  Alex "killer_storm" Mizrahi from IndirectGroup, 2003
//written with help of Vladimir "Randy" Suhoy
//distributed under GPL license

//inspired by 17Points by BoyC from Conspiracy 8-]]]
//some technologies `stolen` from there 8-]]]

//get latest version and additional stuff(like screensaver,
// some helper utils and so on) at http://indirect3d.sf.net/misc/matrix4k.html

#pragma comment(linker,"/FILEALIGN:0x200")

#include <windows.h>
//#define _EXTRASLIM_

//extraslim gives about 300-700 bytes of packed space
// it makes all API functions exported by indices

#define _FINALRELEASE_
//this disables fps-measuring


#ifndef _FINALRELEASE_
#include <stdio.h>
#endif

#include <GL/gl.h>


#ifndef _EXTRASLIM_
#pragma comment(lib, "opengl32.lib")
#define _glBlendFunc glBlendFunc
#define _glCallList glCallList
#define _glClear glClear
#define _glDisable glDisable
#define _glEnable glEnable
#define _glGenLists glGenLists
#define _glLoadIdentity glLoadIdentity
#define _glMaterialfv glMaterialfv
#define _glMatrixMode glMatrixMode
#define _glPopMatrix glPopMatrix
#define _glPushMatrix glPushMatrix
#define _glScalef glScalef
#define _glTranslatef glTranslatef
#define _glRotatef glRotatef
#define _glFrustum glFrustum

#define _wglCreateContext wglCreateContext
#define _wglMakeCurrent wglMakeCurrent
#define _wglUseFontOutlinesA wglUseFontOutlines


#define _glColor4f glColor4f
#define _glRectf glRectf

//user32:

#define _DispatchMessageA DispatchMessageA
#define _PeekMessageA PeekMessageA
#define _RegisterClassA RegisterClassA
#define _CreateWindowExA CreateWindowExA
#define _ShowWindow ShowWindow
#define _GetDC GetDC
#define _ShowCursor ShowCursor
#define _FillRect FillRect
#define _ChangeDisplaySettingsA ChangeDisplaySettingsA
#define _DefWindowProcA DefWindowProcA


//gdi32:
#define _ChoosePixelFormat ChoosePixelFormat
#define _CreateCompatibleBitmap CreateCompatibleBitmap
#define _CreateCompatibleDC CreateCompatibleDC
#define _CreateFontIndirectA CreateFontIndirectA
#define _GetDIBits GetDIBits
#define _SelectObject SelectObject
#define _SetPixelFormat SetPixelFormat
#define _TextOutA TextOutA
#define _SwapBuffers SwapBuffers
#define _GetStockObject GetStockObject

//kernel32:
#define _QueryPerformanceCounter QueryPerformanceCounter
#define _QueryPerformanceFrequency QueryPerformanceFrequency
#define _GlobalAlloc GlobalAlloc

#else
#include "microgl.h"
#include "microuser.h"
#include "microgdi.h"
#include "microkernel32.h"
#endif


#include <math.h>
#include <float.h>

struct Color4 {
	float r,g,b,a;
};

struct Glyph {
	UCHAR* data;
};

struct MStripe {
	int len;
	int roffset;
	int highlight_index;
	int highlight_time;
	float x,y,z;
	float down_velocity;
};

enum eGSOps {
	Crossfade,
	Morph
};

struct GlyphMapping {
	float x_scale, y_scale,x_origin, y_origin;
};

struct GSymbol {
	UCHAR mapping;
	UCHAR glyph_id;
	eGSOps op;
	unsigned short display_time;
};
enum DState {
	dsStill0,
	dsAcceleratingForward,
	dsStartingRot,
	dsTurnRight,
	dsStill1,
	dsTurnDown,
	dsStill2,
	dsTurnUp,
	dsDepthGlyphAppear,
	dsFilterGlyphsAppear,
	dsShowGlyphsMoving,
	dsShowGlyphsStill,
	dsGlyphsDisappear,
	dsAway,
	dsFinish
};

int part_lengths[] = {
	8000,//dsStill0
		7000,//AcceleratingForward
		8000,//StartingRot
		3000,//TurnRight
		500,//Still1
		3000,//TurnDoffn
		3500,//Still2
		15000,//TurnUp
		5000,//DepthGlyphAppear  - TurnUpInv
		5000,//FilterGlyphsAppear - TurnUpInv
		12000,//Show glyphs - moving
		1000000,//Show glyphs - still
		8000,//glyphs-disappear
		8000,//away
		0,//the end
};

/*int part_lengths[] = {
	500,//dsStill0
		500,//AcceleratingForward
		500,//StartingRot
		500,//TurnRight
		500,//Still1
		500,//TurnDoffn
		500,//Still2
		500,//TurnUp
		5000,//DepthGlyphAppear  - TurnUpInv
		5000,//FilterGlyphsAppear - TurnUpInv
		12000,//Show glyphs - moving
		1000000,//Show glyphs - still
		8000,//glyphs-disappear
		8000,//away
		0,//the end
};*/




#ifdef _EXTRASLIM_

PFNglBlendFunc _glBlendFunc=0;
PFNglCallList _glCallList=0;
PFNglClear _glClear=0;
PFNglDisable _glDisable=0;
PFNglEnable _glEnable=0;
PFNglFrustum _glFrustum =0;
PFNglGenLists _glGenLists=0;
PFNglLoadIdentity _glLoadIdentity=0;
PFNglMaterialfv _glMaterialfv=0;
PFNglMatrixMode _glMatrixMode=0;
PFNglPopMatrix _glPopMatrix=0;
PFNglPushMatrix _glPushMatrix=0;
PFNglRotatef _glRotatef=0;
PFNglScalef _glScalef=0;
PFNglTranslatef _glTranslatef=0;

PFNwglCreateContext _wglCreateContext=0;
PFNwglMakeCurrent _wglMakeCurrent=0;
PFNwglUseFontOutlinesA _wglUseFontOutlinesA=0;
PFNglColor4f _glColor4f=0;
PFNglRectf _glRectf=0;


#define NUM_GL_FUNCTIONS 20

//indices for WinXP
/*USHORT gl_function_indices[NUM_GL_FUNCTIONS] = {
	14,15,17,71,80,104,105,165,179,
		182,213,218,256,258,317,346,357,367,
		44,//glColor4f
		248,//glRectf
};*/

//indices for Win98:
USHORT gl_function_indices[NUM_GL_FUNCTIONS] = {
	15,//glBlendFunc
	16,//glCallList
	18,//glClear
	72,//glDisable
	81,//glEnable
	105,//glFrustum
	106,//glGenLists
	166,//glLoadIdentity
	180,//glMaterialfv
	183,//glMatrixMode
	214,//glPopMatrix
	219,//glPushMatrix
	257,//glRotatef
	259,//glScalef
	318,//glTranslatef
	347,//wglCreateContext
	358,//wglMakeCurrent
	367,//wglUseFontOutlinesA
	45,//glColor4f
	249,//glRectf
};



#define NUM_GDI_FUNCTIONS 10
PFNChoosePixelFormat _ChoosePixelFormat=0;
PFNCreateCompatibleBitmap _CreateCompatibleBitmap=0;
PFNCreateCompatibleDC _CreateCompatibleDC=0;
PFNCreateFontIndirectA _CreateFontIndirectA=0;
PFNGetDIBits _GetDIBits=0;
PFNSelectObject _SelectObject=0;
PFNSetPixelFormat _SetPixelFormat=0;
PFNTextOutA _TextOutA=0;
PFNSwapBuffers _SwapBuffers=0;
PFNGetStockObject _GetStockObject=0;

USHORT gdi_function_indices[NUM_GDI_FUNCTIONS] = {
	//indices for WinXP
/*	25,//ChoosePixelFormat
	45,//CreateCompatibleBitmap
	46,//CreateCompatibleDC
	59,//CreateFontIndirectA
	363,//GetDIBits
	525,//SelectObject
	561,//SetPixelFormat
	589,//TextOutA
	588,//SwapBuffers
	422,//GetStockObject*/

	//win98:
	118,//ChoosePixelFormat
	136,//CreateCompatibleBitmap
	137,//CreateCompatibleDC
	150,//CreateFontIndirectA
	249,//GetDIBits
	371,//SelectObject
	403,//SetPixelFormat
	428,//TextOutA
	427,//SwapBuffers
	297,//GetStockObject

};

#define NUM_USER_FUNCTIONS 10
PFNDispatchMessageA _DispatchMessageA=0;
PFNPeekMessageA _PeekMessageA=0;
PFNRegisterClassA _RegisterClassA=0;
PFNCreateWindowExA _CreateWindowExA=0;
PFNShowWindow _ShowWindow=0;
PFNGetDC _GetDC=0;
PFNShowCursor _ShowCursor=0;
PFNFillRect _FillRect=0;
PFNChangeDisplaySettingsA _ChangeDisplaySettingsA=0;
PFNDefWindowProcA _DefWindowProcA=0;

USHORT user_function_indices[NUM_USER_FUNCTIONS] = {
	//winxp:
	/*162,//DispatchMessageA
	510,//PeekMessageA
	535,//RegisterClassA
	97,//CreateWindowExA
	659,//ShowWindow
	269,//GetDC
	655,//ShowCursor
	227,//FillRect
	33,//ChangeDisplaySettingsA
	143,//DefWindowProcA*/

	//win98:
	147,//DispatchMessageA
	460,//PeekMessageA
	472,//RegisterClassA
	91,//CreateWindowExA
	582,//ShowWindow
	247,//GetDC
	579,//ShowCursor
	210,//FillRect
	28,//ChangeDisplaySettingsA
	133,//DefWindowProcA

};


//in win98 bindings to kernel functions do not work 
#define _QueryPerformanceCounter QueryPerformanceCounter
#define _QueryPerformanceFrequency QueryPerformanceFrequency
#define _GlobalAlloc GlobalAlloc

#define _GetProcAddress GetProcAddress
#define _LoadLibraryA LoadLibrary


/*

#define NUM_KERNEL_FUNCTIONS 3

  
	
	 
	   

PFNQueryPerformanceCounter _QueryPerformanceCounter=0;
PFNQueryPerformanceFrequency _QueryPerformanceFrequency=0;
PFNGlobalAlloc _GlobalAlloc=0;


//it varies from between service pack, so it can be very incompatible
//#define KERNEL32_BASE 0x77E60000
//PFNGetProcAddress _GetProcAddress= (PFNGetProcAddress) (KERNEL32_BASE + 0x0001A5FD);
//PFNLoadLibraryA _LoadLibraryA=(PFNLoadLibraryA) (KERNEL32_BASE + 0x000205D8);




USHORT kernel_function_indices[NUM_KERNEL_FUNCTIONS] = {*/
	//winxp:
	/*639,//QueryPerformanceCounter
	640,//QueryPerformanceFrequency
	472,//GlobalAlloc*/
/*
	//win98:
	624,//QueryPerformanceCounter
	625,//QueryPerformanceFrequency
	486,//GlobalAlloc
};*/

void bind_functions (LPCSTR mdlname,FARPROC* pfirstproc, int count,
					const USHORT *indices)  
{
	int i;
	HMODULE mdl = _LoadLibraryA(mdlname);
	FARPROC* fn = pfirstproc;
	for(i=0;i<count;i++) {
		*fn = _GetProcAddress(mdl,MAKEINTRESOURCE(indices[i]));
		fn++;
	}
}

#endif
//globals
bool done;
MSG msg;
int start_time=0;
int last_time;
int timer=0;
int english_font = 0;//TMP
int glyph_timer=0;
int cur_rand = 1;
float rot1 = 0.0f;
float rot2 = 0.0f;
float rot3 = 0.0f;
float ztrans = 0.0f;
int max_rot_ang = 1;
int start_moving_glyphs;

#define MAX_MATRIX_SPEED 6.8f
float matrix_speed = 0;
#define INITIAL_STRIPE_MIN_Z -40.0f
float stripe_min_z = INITIAL_STRIPE_MIN_Z;
#define INITIAL_STRIPE_MAX_Z -6.5f
float stripe_max_z = INITIAL_STRIPE_MAX_Z;


int cur_symbol = -1;
int glyph_id;


#ifndef _FINALRELEASE_
int count =0;
int sum_delta = 0;
#endif

HWND		hwnd=NULL;
HDC			dc=NULL;
HGLRC		rc=NULL;

#define SFNT 12

#define G_ALIEN 0 //\x85 
#define G_HEART 1 //\x59 
#define G_WEB 2 //\x22 
#define G_SPIDER 3 //\x21 
#define G_GLASSES 4 //\x24 
#define G_SPY 5 //\xA0 
#define G_MAN 6 //\x80 
#define G_LIGHTING 7 //\x7E 
#define G_BUILDING 8 //\x43 
#define G_EYE 9 //\x4E
#define G_MONEY 10 //\x91 
#define G_LIPS 11 //\x96 


#define G_SKULL 0+SFNT //\X4e 
#define G_SMILE 1+SFNT //\x4A 
#define G_WINLOGO 2+SFNT //\xFF 
#define G_CHECK 3+SFNT //\xFE 
#define G_BOMB 4+SFNT //\x4D 
#define G_ARROW 5+SFNT //\xE8 
#define G_AIRPLANE 6+SFNT //\x51 
#define G_HAND 7+SFNT //\x49 
#define G_KEYBOARD 8+SFNT //\x37 
#define G_PHONE 9+SFNT //\x29 
#define G_SAND_CLOCK 10+SFNT //\x36
#define G_AIM 11+SFNT //\xB1 


GSymbol msymbols[] = {
	{0,G_ALIEN,Crossfade,2500},
	{0,G_WEB,Crossfade,1000},
	{0,G_WEB,Morph,1500},
	{0,G_SPIDER,Crossfade,1500},
	{1,G_SPIDER,Crossfade,1500},
	{0,G_AIM,Crossfade,1000},
	{1,G_AIM,Morph,1000},
	{0,G_HEART,Crossfade,1000},
	{1,G_HEART,Morph,1000},
	{0,G_HEART,Morph,1000},//10
	{1,G_SKULL,Crossfade,1800},
	{2,G_SKULL,Morph,1800},
	{1,G_SMILE,Crossfade,1500},
	{0,G_SMILE,Morph,1500},
	{3,G_EYE,Crossfade,1500},
	{0,G_EYE,Morph,1500},
	{4,G_EYE,Morph,1500},
	{0,G_GLASSES,Crossfade,1500},
	{1,G_GLASSES,Morph,1000},
	{0,G_SPY,Crossfade,2500},//20
	{1,G_SPY,Morph,1000},
	{0,G_BUILDING,Crossfade,1000},
	{1,G_BUILDING,Morph,1000},
	{0,G_BOMB,Crossfade,1500},
	{1,G_BOMB,Morph,1500},
	{0,G_WINLOGO,Crossfade,1500},
	{1,G_WINLOGO,Morph,1500},
	{1,G_CHECK,Crossfade,1500},
	{0,G_MONEY,Crossfade,1500},
	{1,G_MONEY,Morph,1900},//30
	{1,G_MAN,Crossfade,1000},
	{1,G_MAN,Morph,1000},
	{0,G_ARROW,Crossfade,1500},
	{0,G_AIRPLANE,Crossfade,1500},
	{0,G_PHONE,Crossfade,1500},
	{2,G_PHONE,Morph,1500},
	{1,G_LIGHTING,Crossfade,1500},
	{2,G_SAND_CLOCK,Crossfade,1000},
	{1,G_SAND_CLOCK,Morph,1000},
	{1,G_HAND,Crossfade,1500},//40
	{0,G_KEYBOARD,Crossfade,1000},
	{0,G_KEYBOARD,Morph,1000},
	{2,G_LIPS,Crossfade,1000},
	{2,G_LIPS,Morph,1000},//44
};



GlyphMapping mappings [] = {
	{1.0f,-1.0f,-21.0f,16.0f},
	{1.0f,-1.0f,-18.0f,18.0f},
	{1.0f,-1.0f,-16.0f,16.0f},
	{0.7f,-1.3f,-16.0f,18.0f},
	{1.3f,-1.3f,-21.0f,19.0f},
};


#define SYMBOL_COUNT 44
#define fov_angle (90.0f)
#define max_stripes 350

#ifdef _DEBUG
#define x_res 800
#define y_res 600
#else
#define x_res 1024
#define y_res 768
#endif

#define aspect (float(x_res)/y_res)

unsigned char * randchars;
float cutoff_coeff;
MStripe* stripes;
float ambient_density = 1.0f;
float depth_shift_scale = 0.0f;
float loc_x;
float loc_y;


PIXELFORMATDESCRIPTOR pfd = { sizeof(PIXELFORMATDESCRIPTOR),1,
PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER|PFD_SWAP_COPY
,PFD_TYPE_RGBA//iPixelType
,32,0,0,0,0,0,0,0,0,//cAlphaShift
0,0,0,0,0,//cAccumAlphaBits
32,0,0,PFD_MAIN_PLANE,0,0};

WNDCLASS	wc;
Glyph *glyphs;

//because Microsoft changed headers in PlatformSDK we can't do all initialization here
DEVMODE dmScreenSettings = { {0},
0,
0,
sizeof(DEVMODE),
0,
DM_BITSPERPEL|DM_PELSWIDTH|DM_PELSHEIGHT|DM_DISPLAYFREQUENCY };



LOGFONT lfnt;
DWORD font_list_start;

Color4 letter_color = {0.1f,0.7f,0.15f,0.7f};
Color4 letter_glow_color = {0.20f,0.78f,0.48f,0.18f};
Color4 letter_highlight = {0.35f,0.75f,0.1f,0.75f};

RECT r = {0,0,64,64};

bool glyph_filtering = false;
int demo_state = dsStill0;

int my_rand() {
	return(((cur_rand = cur_rand * 214013L + 2531011L) >> 16) & 0x7fff);
}

void* my_malloc(int size) {	
	return calloc(1,size);
}

float random(float a1, float a2) {
	return (my_rand()*(float((a2)-(a1)))/RAND_MAX+(a1));
}



LRESULT CALLBACK WndProc(HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
	switch (uMsg) {
		case WM_KEYDOWN:
			done = true;
			return 0;
	}
	return _DefWindowProcA(hWnd,uMsg,wParam,lParam);
}

void init_window(HINSTANCE hInstance) {
	GLuint PixelFormat;

	wc.lpfnWndProc = (WNDPROC) WndProc;
	wc.hInstance = hInstance;
	wc.lpszClassName = "L";

	_RegisterClassA(&wc);

	dmScreenSettings.dmBitsPerPel = 32;
	dmScreenSettings.dmPelsHeight = y_res;
	dmScreenSettings.dmPelsWidth = x_res;
	dmScreenSettings.dmDisplayFrequency = 85;

#ifndef _DEBUG
	_ChangeDisplaySettingsA(&dmScreenSettings,CDS_FULLSCREEN);
#endif
	_ShowCursor(FALSE);

	hwnd=_CreateWindowExA(WS_EX_APPWINDOW,"L","",WS_POPUP,0,0,x_res,y_res,NULL,NULL,hInstance,NULL);


	dc=_GetDC(hwnd);
	PixelFormat=_ChoosePixelFormat(dc,&pfd);
	_SetPixelFormat(dc,PixelFormat,&pfd);
	rc=_wglCreateContext(dc);
	_wglMakeCurrent(dc,rc);

	_ShowWindow(hwnd,SW_SHOW);

}

//typedef BOOL (WINAPI * PFNWGLSWAPINTERVALEXTPROC) (int interval);
void init_opengl()  {
	//glDisable(GL_DEPTH_TEST); - it's disabled by default
	//_glEnable(GL_CULL_FACE);
	_glEnable(GL_BLEND);
	_glEnable(GL_LIGHT0);
	_glMatrixMode(GL_PROJECTION);
	//gluPerspective(fov_angle,aspect,1,100.0);
	cutoff_coeff = (float)tan(fov_angle/2/180.0f*3.1415f);
	float height2 = cutoff_coeff;//*1.0f; znear = 1.0f
	float width2 = height2*aspect;
	_glFrustum(-width2,width2, -height2, height2, 1.0f,100.0f);
	_glMatrixMode(GL_MODELVIEW);

	/*	PFNWGLSWAPINTERVALEXTPROC wglSwapIntervalEXT = (PFNWGLSWAPINTERVALEXTPROC)wglGetProcAddress("wglSwapIntervalEXT");
	if(wglSwapIntervalEXT)
	wglSwapIntervalEXT(1);*/

}

HFONT create_font(LPCSTR font_name, int height,int charset) {
	strcpy(lfnt.lfFaceName,font_name);
	lfnt.lfHeight=height;
	lfnt.lfCharSet=charset;
	lfnt.lfOutPrecision = OUT_TT_ONLY_PRECIS;
	return _CreateFontIndirectA(&lfnt);
}

int init_wgl_font(LPCSTR font_name,int charset) {
	int font_list_start=0;
	_SelectObject(dc,create_font(font_name,-12,charset));
	font_list_start = _glGenLists(256);
	_wglUseFontOutlinesA(dc,0,256,font_list_start,0.05f,0.0f,true,0);
	return font_list_start;
}

float down_velocity_multiplier = 0.3f;
void new_stripe(MStripe& stripe) {
	stripe.z = random(stripe_min_z,stripe_max_z);
	float y_height = -stripe.z*cutoff_coeff;
	float x_width = y_height*aspect;
	stripe.x = random(-x_width,x_width);
	stripe.len = my_rand()%25+1;
	stripe.y = y_height + stripe.len;
	stripe.down_velocity = (random(1.7f,10.0f)+random(0.0,26.0f))*down_velocity_multiplier;
	stripe.roffset = my_rand()%950;
	stripe.highlight_index = 0;
	stripe.highlight_time = 0;
}



int myGetTime() {
	LARGE_INTEGER freq;
	_QueryPerformanceFrequency(&freq);

	LARGE_INTEGER cntr;
	_QueryPerformanceCounter(&cntr);
	return int(1000.0*double(cntr.QuadPart)/double(freq.QuadPart));
}

typedef float( * PFNglyph_data_at)(const int x,const int y);

PFNglyph_data_at glyph_data_at_func;

float glyph_data_at(const int x,const int y) {
	if (x<0 || y<0 || 64<= y || 64<=x)
		return 0;
	return glyphs[glyph_id].data[(y<<6)+x];
}


float blur_glyph_data_at(const int x,const int y) {
	return ( 2*glyph_data_at(x,y)+
		glyph_data_at(x+1,y)+glyph_data_at(x-1,y)+
		glyph_data_at(x,y+1)+glyph_data_at(x,y-1)
		)/6.0f;
}

inline float blend(float val1, float val2, float alpha) {
	return val1 + (val2-val1)*alpha;
}

float filtered_glyph_data_at(GlyphMapping* mapping) {
	float mapped_x = (loc_x-mapping->x_origin)/mapping->x_scale;
	float mapped_y = (loc_y-mapping->y_origin)/mapping->y_scale;

	int ix = int(mapped_x);
	int iy = int(mapped_y);

	float fx = mapped_x - ix;
	float fy = mapped_y - iy;

	float d1,d2,d3,d4;
	d1 = glyph_data_at_func(ix,iy);
	d2 = glyph_data_at_func(ix+1,iy);
	d3 = glyph_data_at_func(ix,iy+1);
	d4 = glyph_data_at_func(ix+1,iy+1);

	float a = blend(d1,d3,fy);
	float b = blend(d2,d4,fy);
	return blend(a,b,fx);
}


float symbol_data_for() {

	glyph_id = msymbols[cur_symbol].glyph_id;
	GlyphMapping *cm = &mappings[msymbols[cur_symbol].mapping];

	if (cur_symbol==0) {
		return filtered_glyph_data_at(cm);
	}

	GlyphMapping *pm = &mappings[msymbols[cur_symbol-1].mapping];

	float alpha = float(glyph_timer)/cur_symbol[msymbols].display_time;

	if (cur_symbol[msymbols].op == Crossfade) {

		float cur_val = filtered_glyph_data_at(cm);
		glyph_id = msymbols[cur_symbol-1].glyph_id;
		float prev_val = filtered_glyph_data_at(pm);
		return blend(prev_val,cur_val,alpha);

	} else {

		GlyphMapping mp;
		float * pmv = (float*)pm,
			*cmv = (float*)cm,
			*bmv = (float*)&mp;
		int i;
		for(i=0;i<4;i++,pmv++,cmv++,bmv++) {
			*bmv = blend(*pmv,*cmv, alpha);
		}
		return filtered_glyph_data_at(&mp);

	}
}

float depth_shift() {
	if (cur_symbol<0)
		return 0.0f;
	glyph_data_at_func = blur_glyph_data_at;
	return symbol_data_for()*depth_shift_scale;
}


bool location_filter(int i1, int j1) {
	if (cur_symbol<0)
		return true;
	glyph_data_at_func = glyph_data_at;
	float value = symbol_data_for();
	value = blend(ambient_density,1.0f,value);
	int hash = ((i1*13437)^(j1*32113))%100;
	if ((hash/99.0f)<value) return true;
	else return false;
}

void render_scene(int delta_time) {
	_glLoadIdentity();
	_glTranslatef(0,0,ztrans);
	_glRotatef(rot1,0,0,-1);
	_glRotatef(rot2,1,0,0);
	_glRotatef(rot3,0,1,0);
   

	int i,j;
	for(i=0;i<max_stripes;i++) {
		MStripe& stripe = stripes[i];
		bool has_visible_char = false;
		float y_height = -stripe.z*cutoff_coeff;
		float x_width = y_height*aspect;

		if (fabs(stripe.x) < x_width+1.0f )
			for(j=0;j<stripe.len;j++) {
				if( stripe.y-j > y_height + 1.0f )
					continue;
				if( stripe.y-j < -y_height - 1.0f )
					break;

				has_visible_char = true;

				loc_x = stripe.x;
				loc_y = stripe.y-j;

				int cur_chr = font_list_start + randchars[j+stripe.roffset];

				if (glyph_filtering && !location_filter(i,j))
					continue;

				_glPushMatrix();
				_glTranslatef(loc_x,loc_y,stripe.z+depth_shift());

				if(stripe.highlight_index == j) {
					_glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE,&letter_highlight.r);
					_glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,&letter_highlight.r);
				} else {
					Color4 this_letter_color = letter_color;
					this_letter_color.a = ((i%153)+3*(i%37))/(263.0f)*0.75f+0.25f;
					_glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE,&this_letter_color.r);
					_glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,&this_letter_color.r);
				}

				int ii = last_time*3+(j*2000)/stripe.len;
				ii %= 2000;
				ii -= 1000;
				float rphase = ii/1000.0f;
				if(max_rot_ang<180)
					rphase *= (((ii/2000)%2)*2-1);

				_glRotatef(rphase*max_rot_ang, 0, 1, 0);
				_glTranslatef(-0.5f,0,0);
				_glPushMatrix();
				_glCallList(cur_chr);
				_glPopMatrix();

				_glMaterialfv(GL_FRONT_AND_BACK,GL_AMBIENT_AND_DIFFUSE,&letter_glow_color.r);
				_glMaterialfv(GL_FRONT_AND_BACK,GL_SPECULAR,&letter_glow_color.r);

				int k;
				if((((i*32113)^(j*13437))&7)<2)
					for(k=0;k<2;k++) {

						float scf = random(0.95f,1.2f);
						float delta_x = random(-0.035f,0.02f);
						float delta_y = random(-0.035f,0.02f);

						_glPushMatrix();
						_glTranslatef(delta_x,delta_y,0.0f);
						_glScalef(scf,scf,1.0f);
						_glCallList(cur_chr);
						_glPopMatrix();
					}

				_glPopMatrix();
			}
			stripe.y -= stripe.down_velocity * (delta_time/1000.0f);
			stripe.z+= (delta_time/1000.0f)*matrix_speed;
			stripe.highlight_time+=delta_time;
			if (stripe.highlight_time > 170) {
				stripe.highlight_index++;
				stripe.highlight_time = 0;
			}
			if (!has_visible_char && stripe.y >0) {
				stripe.y--;
			}
			if (stripe.z > -1.6f || (!has_visible_char && stripe.y <0)) {
				new_stripe(stripe);
			}
	}
}


void mainloop() {
	while (!done) 	{
		if (_PeekMessageA(&msg,NULL,0,0,PM_REMOVE)) 		{
			//_TranslateMessage(&msg);
			_DispatchMessageA(&msg);
		} else {
			int delta_time;
			int curtime = myGetTime();
			if (!start_time) {
				start_time = curtime;
				delta_time = 10;
			} else {
				delta_time = curtime - last_time;
			}
			last_time = curtime;
#ifndef _FINALRELEASE_
			count++;
			sum_delta+=abs(delta_time);
			int ave = sum_delta/count;
			if (count>=100) {
				FILE *stream = fopen( "matrix.out", "a" );
				fprintf( stream, "%i/%i:%i\n", start_time, (curtime-start_time), ave );
				fclose( stream );
				count = 0;
				sum_delta=0;
			}
#endif


			timer += delta_time;

			if (timer > part_lengths[demo_state]) {
				switch(demo_state) { //finalize
					case dsStartingRot:
						max_rot_ang = 180;
						break;
					case dsTurnUp:
						matrix_speed = 0;
						rot2 = 90.0f;
						ztrans = -50.0f;
						break;
					/*case dsDepthGlyphAppear:
						//depth_shift_scale = 3.0f;
						stripe_min_z = -17.0f;
						stripe_max_z = -16.5f;
						break; */
					case dsFilterGlyphsAppear:
						ambient_density = 0.0f;
						rot1 = 0;
						rot2 = 0;
						rot3 = 0;
						break;
				}
				timer = 0;
				demo_state++;
				switch(demo_state) { //initialize
					case dsDepthGlyphAppear:
						cur_symbol = 0;
						break;
					case dsFilterGlyphsAppear:
						glyph_filtering = true;
						break;
					case dsShowGlyphsMoving:
						start_moving_glyphs = last_time-start_time;
						break;
					case dsShowGlyphsStill:
						ztrans = -4.0f;
						break;
					case dsFinish:
						done = true;
						return;
				}
			} else {
				float alpha = float(timer)/part_lengths[demo_state];
				switch(demo_state) {
					case dsStill0:
						if(timer<3000)
						{
							down_velocity_multiplier = 0.1f;
						}
						else 
						{
							down_velocity_multiplier = blend(0.1f,1,alpha);
						}
						break;
					case dsAcceleratingForward:
						matrix_speed = blend(0,MAX_MATRIX_SPEED,alpha);
						break;
					case dsStartingRot:
						max_rot_ang = (int)blend(0,180,alpha);
						break;
					case dsTurnRight:
						rot1 = blend(0.0f,90.0f,alpha);
						break;
					case dsTurnDown:
						rot1 = blend(90.0f,180.0f,alpha);
						break;
					case dsTurnUp:
						matrix_speed = blend(MAX_MATRIX_SPEED,0,alpha);
						ztrans = blend(0,-50.0f,alpha);
						rot2 = blend(0,90.0f,alpha);
						break;
					case dsDepthGlyphAppear:
						depth_shift_scale = blend(0,3.0f,alpha);
						stripe_min_z = blend(INITIAL_STRIPE_MIN_Z,-17.0f,alpha);
						stripe_max_z = blend(INITIAL_STRIPE_MAX_Z,-16.5f,alpha);

						//TurnUpInv - part1:
						rot1 = blend(180,90,alpha);
						rot2 = blend(90,45,alpha);
						rot3 = blend(0,180,alpha);
						break;
					case dsFilterGlyphsAppear:
						ambient_density = blend(1.0f,0.0f,alpha);

						//TurnUpInv - part2:
						rot1 = blend(90,0,alpha);
						rot2 = blend(45,0,alpha);
						rot3 = blend(180,360,alpha);
						break;
					case dsShowGlyphsMoving: 
					case dsShowGlyphsStill:
						glyph_timer+=delta_time;
						if(glyph_timer > msymbols[cur_symbol].display_time) {
							glyph_timer = 0;
							cur_symbol++;
							if (cur_symbol==SYMBOL_COUNT) {
								timer = 0;
								demo_state++;
								cur_symbol--;//prev
								break;
							}
						}
						break;
					case dsGlyphsDisappear:
						ztrans = blend(-4.0f,0.0f,alpha);
						ambient_density = blend(0.0f,1.0f,alpha);
						stripe_min_z = blend(-17.0f,INITIAL_STRIPE_MIN_Z,alpha);
						stripe_max_z = blend(-16.5f,INITIAL_STRIPE_MAX_Z,alpha);
						break;
					case dsAway:
						ztrans = blend(0.0f,-100.0f,alpha);
						break;

				}
			}

			//_glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
			_glLoadIdentity();
			_glTranslatef(0,0,-1);
			_glDisable(GL_LIGHTING);
			_glBlendFunc(GL_ZERO,GL_SRC_ALPHA);
			_glColor4f(0,0,0,exp(-0.16-6.0f*delta_time/1000.0f));
			_glRectf(-cutoff_coeff*aspect,cutoff_coeff,cutoff_coeff*aspect,-cutoff_coeff);
			_glEnable(GL_LIGHTING);
			_glBlendFunc(GL_SRC_ALPHA,GL_ONE);

#define MOVING_TIME 5000
			if (demo_state == dsShowGlyphsMoving) {
				int phase1 = (curtime-start_time-start_moving_glyphs)%MOVING_TIME;
				ztrans = blend(-50,50,float(phase1)/MOVING_TIME);

				render_scene(delta_time);

				int phase2 = (curtime-start_time-start_moving_glyphs-2500)%MOVING_TIME;
				ztrans = blend(-50,50,float(phase2)/MOVING_TIME);
				render_scene(delta_time);

			} else {
				render_scene(delta_time);
			}

			_SwapBuffers(dc);
		}
	}
}

char matrixdata[] = "shtuzzer&kaloerov";

void init_effect() {
	randchars = (unsigned char*)my_malloc(1000);
	int i;

	for(i=0;i<1000;i++) {
		randchars[i] = matrixdata[i%17];
	}

	stripes = (MStripe*) my_malloc (sizeof(MStripe)*max_stripes);
	for(i=0;i<max_stripes;i++) {
		new_stripe(stripes[i]);
	}
}

#define MAX_GLYPH_SIZE 64

void make_glyphs(HFONT font,const UCHAR* chars,int count, Glyph glyphs[]  ) {

	BITMAPINFOHEADER* bmh = (BITMAPINFOHEADER*) my_malloc(sizeof(BITMAPINFOHEADER)+128);

	RECT r = {0,0,MAX_GLYPH_SIZE,MAX_GLYPH_SIZE};

	HDC dc = _CreateCompatibleDC(0);
	HBITMAP bmp=_CreateCompatibleBitmap(dc,MAX_GLYPH_SIZE,MAX_GLYPH_SIZE);
	_SelectObject(dc,bmp);
	_SelectObject(dc,font);

	bmh->biSize = sizeof(BITMAPINFOHEADER);
	bmh->biWidth = MAX_GLYPH_SIZE;
	bmh->biHeight = -MAX_GLYPH_SIZE;
	bmh->biPlanes = 1;
	bmh->biBitCount = 1;
	bmh->biCompression= BI_RGB;

	UCHAR * buffer = (UCHAR*) my_malloc(MAX_GLYPH_SIZE*MAX_GLYPH_SIZE/8);

	for(int i = 0;i<count;++i) {
		_FillRect(dc,&r,(HBRUSH)_GetStockObject(WHITE_BRUSH));
		_TextOutA(dc,0,0,(LPCSTR)chars+i,1);
		_GetDIBits(dc,bmp,0,MAX_GLYPH_SIZE,buffer,(BITMAPINFO*)bmh,DIB_RGB_COLORS);

		int x,y;

		glyphs[i].data = (UCHAR*) my_malloc (64*64);
		for(y=0;y<64;y++)
			for(x=0;x<64;x++) {
				//glyphs[i].data[y*sz.cx+x] = 1-((buffer[y*MAX_GLYPH_SIZE/8+x/8] >> (7-x%8)) & 1);
				glyphs[i].data[(y<<6)+x] = 1^((buffer[(y<<3)+ (x>>3) ] >> (7-x&7)) & 1);
			}

	}

}


INT WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance,
				   LPSTR lpCmdLine, INT nCmdShow)
{
#ifdef _EXTRASLIM_
	bind_functions("opengl32.dll",(FARPROC*)&_glBlendFunc,NUM_GL_FUNCTIONS,gl_function_indices);
	bind_functions("gdi32.dll",(FARPROC*)&_ChoosePixelFormat,NUM_GDI_FUNCTIONS,gdi_function_indices);
	bind_functions("user32.dll",(FARPROC*)&_DispatchMessageA,NUM_USER_FUNCTIONS,user_function_indices);
//	bind_functions("kernel32.dll",(FARPROC*)&_QueryPerformanceCounter,NUM_KERNEL_FUNCTIONS,kernel_function_indices);
#endif
	init_window(hInstance);
	init_opengl();

	font_list_start = init_wgl_font("Verdana",DEFAULT_CHARSET);
//	english_font = init_wgl_font("Verdana",DEFAULT_CHARSET);

	glyphs = (Glyph*) my_malloc (sizeof(Glyph)*25);
	make_glyphs(create_font("Webdings",-36,SYMBOL_CHARSET),(UCHAR*)"\x85\x59\x22\x21\x24\xA0\x80\x7E\x43\x4E\x91\x96",SFNT,glyphs);
	make_glyphs(create_font("Wingdings",-36,SYMBOL_CHARSET),(UCHAR*)"\x4E\x4A\xFF\xFE\x4D\xE8\x51\x49\x37\x29\x36\xB1",12,glyphs+SFNT);

	init_effect();

	mainloop();

	_wglMakeCurrent(0,0);
	_ChangeDisplaySettingsA(NULL,0);
	return 0;
}
