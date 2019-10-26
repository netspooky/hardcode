/*
    EL BOTTO SOURCE CODE DE PULSE
    
    Dunno what u want to do with this source, but i thought it might
    be nice to release some source.... 
    it's nothin fancy but you might get an idea how to create 4k win32
    intro's (hoping for some good competition :)
    project settings:
        optimize for size
        /opt:nowin98        (for smaller PE header allignment)
    source was hacked together in about 8 hours so don't complain :)
    
    Greetz Awak - T3F (The 3rd Foundation)
    
    - main.cpp  =  main code of the 4k
    - particle.cpp  =  particle texture
    - font.cpp  =  font texture
    - text.cpp  =  data for displayed text and greetz
    
    requires dx8 sdk to compile
    if you would like to contact me for some odd reasen, this is my mail
    address: awak@t3f.org (whow, that's original)
    
    btw, i made some code changes while writing this stuff.... should
    still compile and run... if not, mail me please :)
*/

extern "C"
{
	int _fltused = 1;

	inline float sin(float i)
	{
		__asm fld i;
		__asm fsin;
		__asm fstp i;
		return i;
	}

	inline float cos(float i)
	{
		__asm fld i;
		__asm fcos;
		__asm fstp i;
		return i;
	}
};

// i like this one :)
#define WIN32_LEAN_AND_MEAN

#define speed1 0.001623243f
#define speed2 0.001832123f
#define speed3 0.001441233f

#include <windows.h>
#include <d3d8.h>

extern char font[];
extern char particle[];

// --------------------------
//  defining some structures
// --------------------------
typedef struct
{
	float a;
	float b;
	float c;
}ANGLE;

typedef struct
{
	float x;
	float y;
	float z;
}VECTOR;

typedef struct
{
	float x,y,z,w;
	int   color;
	float u,v;
}TLVERTEX;

typedef struct
{
	float x,y,z;
	int   color;
	float u,v;
}VERTEX;

// --------------------
//  d3d vertex formats 
// --------------------
#define FVF_VERTEX	D3DFVF_DIFFUSE | D3DFVF_XYZ | D3DFVF_TEX1
#define FVF_TLVERTEX D3DFVF_XYZRHW | D3DFVF_DIFFUSE | D3DFVF_TEX1

#define VertSize	64

// -------------
//  win32 stuff
// -------------
HINSTANCE	MainInstance;
HWND		MainWindow;
bool		running;

// -----------------
//  direct3d8 stuff
// -----------------
LPDIRECT3D8			D3Dobject;
LPDIRECT3DDEVICE8	D3Ddevice;
LPDIRECT3DTEXTURE8	Particle;
LPDIRECT3DTEXTURE8	Font;
LPDIRECT3DTEXTURE8  Masker;

D3DMATRIX			ViewMatrix;
D3DMATRIX			WorldMatrix;
D3DMATRIX			ProjectionMatrix;

LPDIRECT3DVERTEXBUFFER8	Verts;
int					Counter;
float				radius;

WORD Faces[] = {0,1,2,0,2,3};

// ---------------------
//  function prototypes
// ---------------------
inline void ZeroMem(void* p, int size);
inline void SetRotationMatrix(ANGLE* a, D3DMATRIX* m);
inline void SetPositionMatrix(VECTOR* v, D3DMATRIX* m);
inline void SetUnitMatrix(D3DMATRIX* m);
inline void DoEffect(int time, float perc);
inline void DrawString(char* string, int xpos, int ypos, int size);
inline void DoEffect2(int time);

// ------------
//  text stuff 
// ------------
extern char* text[];
extern int times[];
extern int pos[];
extern int size[];
extern char* greetz;

// -------------------------
//  some other random stuff
// -------------------------
ANGLE	SceneAngle;
ANGLE	CamAngle;
VECTOR	ScenePos;
VECTOR	CamPos;

VERTEX	WVerts[4];

// ----------------
//  window handler
// ----------------
LRESULT CALLBACK WndProc(HWND wnd, UINT msg, WPARAM w, LPARAM l)
{
	switch(msg)
	{
	case WM_CLOSE:
	    Font->Release();
	    Particle->Release();
	    Verts->Release();
	    D3Ddevice->Release();
	    D3Dobject->Release();
		DestroyWindow(MainWindow);
		UnregisterClass("A", MainInstance);
		running = false;
		break;
	default:
		break;
	}
	return DefWindowProc(wnd,msg,w,l);
}

void WinMainCRTStartup()
{
	MainInstance = GetModuleHandle(NULL);
	running = true;
	ShowCursor(false);
	int x = WinMain(MainInstance, NULL, NULL, 0);
	ShowCursor(true);
	ExitProcess(x);
}

int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmd, int zooi)
{
	// create a window
	WNDCLASS wc;
	ZeroMem(&wc,sizeof(WNDCLASS));
	wc.lpfnWndProc = WndProc;
	wc.lpszClassName = "A";
	if (!RegisterClass(&wc)) return 0;

	MainWindow = CreateWindow("A","4k", WS_OVERLAPPED | WS_BORDER | WS_SYSMENU | WS_CAPTION, CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,MainInstance, NULL);
	if (!MainWindow) return 0;
	ShowWindow(MainWindow, SW_SHOWNORMAL);
	UpdateWindow(MainWindow);

	// create direct3d stuff
	D3Dobject = Direct3DCreate8(D3D_SDK_VERSION);
	if (D3Dobject == NULL) return 0;
	D3DPRESENT_PARAMETERS params;
	ZeroMem(&params, sizeof(D3DPRESENT_PARAMETERS));
	params.BackBufferWidth = 640;
	params.BackBufferHeight = 480;
	params.BackBufferFormat = (_D3DFORMAT)D3DFMT_A8R8G8B8;
	params.BackBufferCount = 1;
	params.MultiSampleType = D3DMULTISAMPLE_NONE;
	params.SwapEffect = D3DSWAPEFFECT_DISCARD;
	params.hDeviceWindow = MainWindow;
	params.Windowed = false;
	params.EnableAutoDepthStencil = false;
	params.FullScreen_RefreshRateInHz = D3DPRESENT_RATE_DEFAULT;
	params.FullScreen_PresentationInterval = D3DPRESENT_INTERVAL_DEFAULT;
	if(D3Dobject->CreateDevice(D3DADAPTER_DEFAULT,D3DDEVTYPE_HAL,MainWindow,D3DCREATE_SOFTWARE_VERTEXPROCESSING,&params,&D3Ddevice) != D3D_OK) return 0;

	// create a vertex buffer for the particles
	if (D3Ddevice->CreateVertexBuffer(2197*sizeof(VERTEX),0,FVF_VERTEX,D3DPOOL_DEFAULT,&Verts) != D3D_OK) return 0;

	// create some textures
	if (D3Ddevice->CreateTexture(8,8,1,0,D3DFMT_A8R8G8B8,D3DPOOL_MANAGED,&Particle) != D3D_OK) return 0;
	if (D3Ddevice->CreateTexture(512,16,1,0,D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, &Font) != D3D_OK) return 0;
	
    // fill particle texture
	D3DLOCKED_RECT	rect;
	Particle->LockRect(0, &rect, NULL, 0);
	int* surface = (int*)rect.pBits;
	for (int t = 0; t < 64; t++)
		surface[t] = ((particle[t] & 0xFF) << 16) | ((particle[t] & 0xFF) << 8) | (particle[t] & 0xFF);
	Particle->UnlockRect(0);

	// fill font texture
	// bitwise packed 2 color image
	Font->LockRect(0, &rect, NULL,0);
	surface = (int*)rect.pBits;
	int kleur;
	for (t = 0; t < 1024; t++)
	{
		kleur = font[t];
		for (int c = 0; c < 8; c++)
			if (((kleur >> c) & 1) == 1)
				surface[t*8+c] = 0xFFFFFF;
			else
				surface[t*8+c] = 0;
	}
	Font->UnlockRect(0);

	// create a nice cube
	VERTEX* vbuf;
	int index = 0;
	Verts->Lock(0, sizeof(VERTEX)*2197, (BYTE**)&vbuf, 0);
	for (int z = -6; z <= 6; z++)
	{
		for (int y = -6; y <= 6; y++)
		{
			for (int x = -6; x <= 6; x++)
			{
				vbuf[index].x = (float)x * 100.0f;
				vbuf[index].y = (float)y * 100.0f;
				vbuf[index].z = (float)z * 100.0f;
				vbuf[index].color = 0xFFFFFF;
				index++;
			}
		}
	}
	Verts->Unlock();

    // create the nice blue bar
	TLVERTEX	SquareVerts[4];
	ZeroMem(&SquareVerts,sizeof(TLVERTEX)*4);
	for (t = 0; t < 4; t++)
	{
		SquareVerts[t].z = 0.5f;
		SquareVerts[t].w = 0.5f;
		SquareVerts[t].color = 0x5F2F2FFF;
	}
	SquareVerts[0].x = 40.0f;
	SquareVerts[1].x = 200.0f;
	SquareVerts[2].x = 200.0f;
	SquareVerts[3].x = 40.0f;
	SquareVerts[2].y = 480.0f;
	SquareVerts[3].y = 480.0f;
	
    // nice square for the final effect :)
	ZeroMem(&WVerts, sizeof(VERTEX)*4);
	for (t = 0; t < 4; t++)
	{
		WVerts[t].color = 0x7F7F7F7F;
	}
	WVerts[0].x = -VertSize;
	WVerts[0].y = VertSize;
	WVerts[1].x = VertSize;
	WVerts[1].y = VertSize;
	WVerts[2].x = VertSize;
	WVerts[2].y = -VertSize;
	WVerts[3].x = -VertSize;
	WVerts[3].y = -VertSize;

	// setup projection matrix
	// quite large field of view
	// just copied & pasted it of some of my other code
	ZeroMem(&ProjectionMatrix, sizeof(D3DMATRIX));
	float w = cos(1.0f) / sin(1.0f);
	float h = cos(1.0f) / sin(1.0f);
	float q = 10000.0f / (10000.0f - 1.0f);
	ProjectionMatrix._11 = w;
	ProjectionMatrix._22 = h;
	ProjectionMatrix._33 = q;
	ProjectionMatrix._43 = -q;
	ProjectionMatrix._34 = 1.0f;
	D3Ddevice->SetTransform(D3DTS_PROJECTION, &ProjectionMatrix);

	MSG msg;
	ZeroMem(&SceneAngle, sizeof(ANGLE));
	ZeroMem(&CamAngle, sizeof(ANGLE));
	ZeroMem(&ScenePos, sizeof(VECTOR));
	ZeroMem(&CamPos, sizeof(VECTOR));
	CamPos.z = 800.f;

	SetUnitMatrix(&ViewMatrix);
	SetPositionMatrix(&CamPos, &ViewMatrix);
	D3Ddevice->SetTransform(D3DTS_VIEW, &ViewMatrix);

	D3Ddevice->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);
	D3Ddevice->SetRenderState(D3DRS_ZENABLE, D3DZB_FALSE);
	D3Ddevice->SetRenderState(D3DRS_LIGHTING, FALSE);
	D3Ddevice->SetRenderState(D3DRS_ALPHABLENDENABLE, true);

	// nice particle stuff in dx8
	// setup particle rendering
	// you can now just render points and
	// dx8 converts them to particles for you :)
	float pointsize = 48.0f;
	D3Ddevice->SetRenderState(D3DRS_POINTSIZE, *((DWORD*)&pointsize));
	D3Ddevice->SetRenderState(D3DRS_POINTSCALEENABLE, true);
	D3Ddevice->SetRenderState(D3DRS_POINTSPRITEENABLE, true);
	pointsize = 10.0f;
	D3Ddevice->SetRenderState(D3DRS_POINTSCALE_A, *((DWORD*)&pointsize));
	pointsize = 1.0f;
	D3Ddevice->SetRenderState(D3DRS_POINTSCALE_B, *((DWORD*)&pointsize));
	D3Ddevice->SetRenderState(D3DRS_POINTSCALE_C, *((DWORD*)&pointsize));

    // of course we want some bilinear filtering
	D3Ddevice->SetTextureStageState(0,D3DTSS_MAGFILTER, D3DTEXF_LINEAR);
	D3Ddevice->SetTextureStageState(0,D3DTSS_MINFILTER, D3DTEXF_LINEAR);

	// main loop
	int start = GetTickCount();
	int currenttime;
	int currenttext = 0;
	while(running)
	{
		if (PeekMessage(&msg,NULL,0,0,PM_NOREMOVE))
		{	// we got a message
			GetMessage(&msg, NULL, 0, 0);
			TranslateMessage(&msg);
			DispatchMessage(&msg);
		}
		else
		{
			currenttime = GetTickCount() - start;
			radius = (sin(0.0001424f * currenttime) * 100.0f) + 600.0f;
			if (currenttime > 69000) running = false;
			// clear target only cos we aint using the zbuffer
			D3Ddevice->Clear(0, NULL, D3DCLEAR_TARGET, 0x2F, 0.0f, 0);
			D3Ddevice->BeginScene();

            // some el lamo effect timing
			if (currenttime < 32000)
			{
				if ((currenttime > 0) && (currenttime < 8000))
				{
					DoEffect(currenttime, 0);
				}
				else
				{
					if ((currenttime > 8000) && (currenttime < 16000))
					{
						DoEffect(currenttime, (float)(currenttime-8000) / 8000.0f);
					}
					else
					{
						if ((currenttime > 16000) && (currenttime < 32000))
						{
							DoEffect(currenttime, 1.0f);
						}
					}
				}

			
				SetRotationMatrix(&SceneAngle, &WorldMatrix);
				SetPositionMatrix(&ScenePos, &WorldMatrix);
				D3Ddevice->SetTransform(D3DTS_WORLD, &WorldMatrix);

				// draw those nice particles :)
				D3Ddevice->SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ONE);
				D3Ddevice->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
				D3Ddevice->SetTextureStageState(0,D3DTSS_ALPHAOP, D3DTOP_DISABLE);
				D3Ddevice->SetTextureStageState(0,D3DTSS_COLOROP,D3DTOP_SELECTARG1);
				D3Ddevice->SetTextureStageState(0,D3DTSS_COLORARG1, D3DTA_TEXTURE);

				D3Ddevice->SetVertexShader(FVF_VERTEX);
				D3Ddevice->SetStreamSource(0, Verts, sizeof(VERTEX));
				D3Ddevice->SetTexture(0,Particle);

				D3Ddevice->DrawPrimitive(D3DPT_POINTLIST, 0, 2197);
			}
			else
				DoEffect2(currenttime);

			// draw the nice blue square
			D3Ddevice->SetVertexShader(FVF_TLVERTEX);
			D3Ddevice->SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
			D3Ddevice->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
			D3Ddevice->SetTextureStageState(0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG1);
			D3Ddevice->SetTextureStageState(0,D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
			D3Ddevice->SetTextureStageState(0,D3DTSS_COLOROP,D3DTOP_SELECTARG1);
			D3Ddevice->SetTextureStageState(0,D3DTSS_COLORARG1, D3DTA_DIFFUSE);
			D3Ddevice->DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST,
											  0,
											  4,
											  2,
											  &Faces,
											  D3DFMT_INDEX16,
											  &SquareVerts,
											  sizeof(TLVERTEX));
			
			// draw some text
			if (currenttime < 32000)
			{
				if (currenttime > times[currenttext*2])
				{
					if (currenttime < times[currenttext*2+1])
					{
						DrawString(text[currenttext],
								   pos[currenttext*2],
								   pos[currenttext*2+1],
								   size[currenttext]);
					}
					else
						currenttext++;
				}
			}
			else
			{
				int x = 500 - ((currenttime-32000) / 40);
				DrawString(greetz, 48, x,1);
			}
			
			// stop rendering and update buffers
			D3Ddevice->EndScene();
			D3Ddevice->Present(NULL, NULL, NULL, NULL);
			SceneAngle.a += 0.01f;
			SceneAngle.b += 0.02f;
			SceneAngle.c += 0.015f;
		}
	}
	return 0;
}

// some matrix stuff....
inline void SetRotationMatrix(ANGLE* a, D3DMATRIX* m)
{
	float sa = sin(a->a);
	float sb = sin(a->b);
	float sc = sin(a->c);
	float ca = cos(a->a);
	float cb = cos(a->b);
	float cc = cos(a->c);

    m->_11 =  cc * cb;
    m->_21 =  sc * cb;
    m->_31 = -sb;
    m->_12 = -sc * ca + cc * sb * sa;
    m->_22 =  cc * ca + sc * sb * sa;
    m->_32 =  cb * sa;
    m->_13 =  sc * sa + cc * sb * ca;
    m->_23 = -cc * sa + sc * sb * ca;
    m->_33 =  cb * ca;
	m->_44 = 1.0f;
}

inline void SetPositionMatrix(VECTOR* v, D3DMATRIX* m)
{
	m->_41 = v->x;
	m->_42 = v->y;
	m->_43 = v->z;
	m->_44 = 1.0f;
}

inline void ZeroMem(void* p, int size)
{
	char* d = (char*)p;
	for (int t = 0; t < size; t++)
	{
		*d = 0;
		d++;
	}
}

inline void SetUnitMatrix(D3DMATRIX* m)
{
	ZeroMem(m, sizeof(D3DMATRIX));
	m->_11 = 1.0f;
	m->_22 = 1.0f;
	m->_33 = 1.0f;
	m->_44 = 1.0f;
}

inline void DoEffect(int time, float perc)
{
	VERTEX* vbuf;
	int index = 0;
	Verts->Lock(0, sizeof(VERTEX)*2197, (BYTE**)&vbuf, 0);
	for (int z = -6; z <= 6; z++)
	{
		for (int y = -6; y <= 6; y++)
		{
			for (int x = -6; x <= 6; x++)
			{
				vbuf[index].x = (((float)x * 100.0f)*(1.0f-perc))+((sin(speed1 * (time+(index << 4)))*radius) * perc);
				vbuf[index].y = (((float)y * 100.0f)*(1.0f-perc))+((cos(speed2 * (time+(index << 4)))*radius) * perc);
				vbuf[index].z = (((float)z * 100.0f)*(1.0f-perc))+((sin(speed3 * (time+(index << 4)))*radius) * perc);
				index++;
			}
		}
	}
	Verts->Unlock();
	
}

inline void DoEffect2(int time)
{
	SetRotationMatrix(&SceneAngle,&WorldMatrix);
	D3Ddevice->SetVertexShader(FVF_VERTEX);
	D3Ddevice->SetRenderState(D3DRS_SRCBLEND, D3DBLEND_SRCALPHA);
	D3Ddevice->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_INVSRCALPHA);
	D3Ddevice->SetTextureStageState(0,D3DTSS_ALPHAOP,D3DTOP_SELECTARG1);
	D3Ddevice->SetTextureStageState(0,D3DTSS_ALPHAARG1, D3DTA_DIFFUSE);
	D3Ddevice->SetTextureStageState(0,D3DTSS_COLOROP,D3DTOP_SELECTARG1);
	D3Ddevice->SetTextureStageState(0,D3DTSS_COLORARG1, D3DTA_DIFFUSE);

	VECTOR	v;
	for (int y = -15; y <= 15; y++)
	{
		for (int x = -15; x <= 15; x++)
		{
			v.x = x * 128.0f;
			v.y = y * 128.0f;
			v.z = (sin(0.00324234f * time + x) + cos(0.004525f * time + y)) * 50.0f + 400.0f;
			SetPositionMatrix(&v, &WorldMatrix);
			D3Ddevice->SetTransform(D3DTS_WORLD, &WorldMatrix);
			D3Ddevice->DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST,
											  0,
											  4,
											  2,
											  &Faces,
											  D3DFMT_INDEX16,
											  &WVerts,
											  sizeof(VERTEX));
		}
	}
}

TLVERTEX FontVerts[4];

// my font drawing routine... don't say anything about this... this
// is NOT nice code
inline void DrawString(char* string, int xpos, int ypos, int size)
{
	int index = 0;
	float x = (float)xpos;
	float y = (float)ypos;
	int c;

	D3Ddevice->SetTexture(0,Font);
	D3Ddevice->SetRenderState(D3DRS_SRCBLEND, D3DBLEND_ONE);
	D3Ddevice->SetRenderState(D3DRS_DESTBLEND, D3DBLEND_ONE);
	D3Ddevice->SetTextureStageState(0,D3DTSS_COLOROP,D3DTOP_SELECTARG1);
	D3Ddevice->SetTextureStageState(0,D3DTSS_COLORARG1, D3DTA_TEXTURE);

	while (string[index] != '\0')
	{
		if (string[index] == ' ')
			x += 8.0f*size;
		else
		{
		if (string[index] == '\n')
		{
			y += 8.0f*size + 4.0f;
			x = (float)xpos;
		}
		else
		{
			for (int t = 0; t < 4; t++)
			{
				FontVerts[t].z = 0.5f;
				FontVerts[t].w = 0.5f;
			}
			c = (string[index]) & 0xFF;
			if (c == 46) 
				c = 26;
			else
				if (c == 51) 
					c = 27;
				else
					c -= 97;
			FontVerts[0].x = x;
			FontVerts[0].y = y;
			FontVerts[0].u = 0.03125f * c;
			FontVerts[0].v = 0.0f;

			FontVerts[1].x = x+8*size;
			FontVerts[1].y = y;
			FontVerts[1].u = 0.03125f * c + 0.03125f;
			FontVerts[1].v = 0.0f;

			FontVerts[2].x = x+8*size;
			FontVerts[2].y = y+8*size;
			FontVerts[2].u = 0.03125f * c + 0.03125f;
			FontVerts[2].v = 0.99f;

			FontVerts[3].x = x;
			FontVerts[3].y = y+8*size;
			FontVerts[3].u = 0.03125f * c;
			FontVerts[3].v = 0.99f;
			D3Ddevice->DrawIndexedPrimitiveUP(D3DPT_TRIANGLELIST,
										  0,
										  4,
										  2,
										  &Faces,
										  D3DFMT_INDEX16,
										  &FontVerts,
										  sizeof(TLVERTEX));
			x += 8.0f * size + 2.0f;
		}
		}
		index++;

	}
}
