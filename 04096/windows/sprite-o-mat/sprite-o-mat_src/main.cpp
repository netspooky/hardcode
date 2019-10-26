#define WIN32_LEAN_AND_MEAN
#define WIN32_EXTRA_LEAN
#include "windows.h"
#include "d3d9.h"
#include "d3dx9.h"
#include "mmsystem.h"
#include "dsound.h"


/////////////////////////////////////////////////////////////////////////////////
// defines
/////////////////////////////////////////////////////////////////////////////////

#ifdef _DEBUG
#include "stdio.h"	
#define MYDEBUG
//#define EXPORT_SOUND
#endif

//#define SAFE_CALL(func, msg) if (D3D_OK != func) MessageBox(NULL, msg, "Error", MB_OK);
#define SAFE_CALL(func, msg) func;

#define MY_RGBA(redval, greenval, blueval, alphaval) ((alphaval << 24) | (redval << 16) | (greenval << 8) | blueval)

#define FULLSCREEN
#define SCREEN_WIDTH 640	
#define SCREEN_HEIGHT 480
#define BLUR_WIDTH SCREEN_WIDTH/4
#define BLUR_HEIGHT SCREEN_HEIGHT/4
#define TEXT_WIDTH 64	
#define TEXT_HEIGHT 64

/////////////////////////////////////////////////////////////////////////////////
// uninitialized data
/////////////////////////////////////////////////////////////////////////////////

LPDIRECT3D9 lpD3D;
LPDIRECT3DDEVICE9 lpD3DDevice;

LPD3DXFONT   lpFont;

LPD3DXMATRIXSTACK lpMatrixStack;

struct RenderTarget
{
	LPDIRECT3DTEXTURE9 lpTexture;
	LPDIRECT3DSURFACE9 lpColorSurface;
	LPDIRECT3DSURFACE9 lpDepthSurface;
};

// screen sized maps and surfaces
#define SCREEN_TARGET		0
// blur maps and surfaces
#define BLUR1_TARGET		1
#define BLUR2_TARGET		2
// text maps and surfaces
#define TEXT_TARGET			3
// backup target for the original color and depth buffer
#define ORIGINAL_TARGET		4
#define MAX_TARGETS			5

RenderTarget lpRenderTarget[MAX_TARGETS];
LPDIRECT3DSURFACE9 lpTextSurface;

// shader
LPDIRECT3DPIXELSHADER9 lpDirBlurPS;

// screen FVF
struct QuadVertex
{
	D3DXVECTOR4 p;
	D3DXVECTOR2 t;
};
#define FVF_QUADVERTEX (D3DFVF_XYZRHW | D3DFVF_TEX1)

// point sprite FVF
struct SpriteVertex
{
	D3DXVECTOR3 p;
	float s;
	D3DCOLOR c;
};
#define FVF_SPRITEVERTEX (D3DFVF_XYZ | D3DFVF_PSIZE | D3DFVF_DIFFUSE)

LPDIRECT3DVERTEXBUFFER9 lpSpriteVB;
LPDIRECT3DTEXTURE9 lpSpriteTex;

// metaballs
struct MetaObject
{
	D3DXVECTOR3 pos;
	float	a, b;
};

#define METABALL_COUNT 128
MetaObject MetaBalls[METABALL_COUNT];

#define GP_TYPE_META	0x1
#define GP_TYPE_BORDER	0x2
#define GP_TYPE_TEXT	0x4
struct GridPoint
{
	float	value;
	DWORD	flags;
};

#define METAGRID_DIM 64
#define METAGRID_SHIFT1 6
#define METAGRID_SHIFT2 12
GridPoint MetaGrid[METAGRID_DIM*METAGRID_DIM*METAGRID_DIM];

// sound
#define SAMPLES_PER_SEC 22050
#define SONG_LENGTH 5*60*2*SAMPLES_PER_SEC
#define SOUND_BUFFERS 2

#define DBUFFER_SIZE 65536
#define DBUFFER_MASK 0xffff
int dbuffer[DBUFFER_SIZE];

LPDIRECTSOUNDBUFFER8 lpDSBuffer[SOUND_BUFFERS];

// the buffer where the gm.dls file name is copied to and then the data itself
char lpFileBuffer[0x800000];

// beat state for base, snare. 3rd entry is pattern index
int BeatState[3][SONG_LENGTH];
DWORD LastTick;

#ifdef EXPORT_SOUND
// the export sound buffer 
signed short lpSoundBuffer[SONG_LENGTH*2];
#endif

char	ClearFlags;
DWORD	RandSeed;

struct SceneVars
{
	float fov;
	float fend;
	float minI;
	float maxI;
	float yaw;
	float pitch;
	float roll;
	float up;
	float zoom;
	DWORD blendfactor;
};

SceneVars Scene_Vars;

float PatternTick;
float RadPatternTick;

/////////////////////////////////////////////////////////////////////////////////
// initialized data
/////////////////////////////////////////////////////////////////////////////////

#include "music.h"

#include "shaders.h"

#pragma data_seg(".screen")
D3DPRESENT_PARAMETERS screen_params =
{
	SCREEN_WIDTH,
	SCREEN_HEIGHT,
	D3DFMT_A8R8G8B8,
	1,
	D3DMULTISAMPLE_NONE,
	0,
	D3DSWAPEFFECT_DISCARD,
	0, // HWND
#ifdef FULLSCREEN
    0,
#else
	1,
#endif
	1,
	D3DFMT_D24S8,
	0,
	D3DPRESENT_RATE_DEFAULT,
	D3DPRESENT_INTERVAL_DEFAULT
};

#pragma data_seg(".quadvtx")
float quad_vertices[2][24] =
{
	//  blur sized
	{
		0.0f, 0.0f, 0.0f, 1.0f,
		0.5f/(BLUR_WIDTH), 0.5f/(BLUR_HEIGHT),
		BLUR_WIDTH, 0.0f, 0.0f, 1.0f,
		1.0f+0.5f/(BLUR_WIDTH), 0.5f/(BLUR_HEIGHT),
		0.0f, BLUR_HEIGHT, 0.0f, 1.0f,
		0.5f/(BLUR_WIDTH), 1.0f+0.5f/(BLUR_HEIGHT),
		BLUR_WIDTH, BLUR_HEIGHT, 0.0f, 1.0f,
		1.0f+0.5f/(BLUR_WIDTH), 1.0f+0.5f/(BLUR_HEIGHT)
	},
	//  screen sized
	{
		0.0f, 0.0f, 0.0f, 1.0f,
		0.5f/(SCREEN_WIDTH), 0.5f/(SCREEN_HEIGHT),
		SCREEN_WIDTH, 0.0f, 0.0f, 1.0f,
		1.0f+0.5f/(SCREEN_WIDTH), 0.5f/(SCREEN_HEIGHT),
		0.0f, SCREEN_HEIGHT, 0.0f, 1.0f,
		0.5f/(SCREEN_WIDTH), 1.0f+0.5f/(SCREEN_HEIGHT),
		SCREEN_WIDTH, SCREEN_HEIGHT, 0.0f, 1.0f,
		1.0f+0.5f/(SCREEN_WIDTH), 1.0f+0.5f/(SCREEN_HEIGHT)
	}
};

#pragma data_seg(".blurpar")
float blur_params[3][4] = 
{
	{ 1.0f/(SCREEN_WIDTH), 1.0f/(SCREEN_WIDTH), 0.00f, 1.0f }, // downsample4 + brightpass
	{ 1.2f/(BLUR_WIDTH), 0.0f, 0.0f, 2.0f },	// blurx, no threshold
	{ 0.0f, 1.2f/(BLUR_HEIGHT), 0.0f, 2.0f},	// blury, no threshold
};


#ifdef EXPORT_SOUND
char WaveHeader[44] =
{
	'R', 'I', 'F', 'F',
	0, 0, 0, 0,
	'W', 'A', 'V', 'E',
	'f', 'm', 't', ' ',
	16, 0, 0, 0,
	1, 0,
	1, 0,
	0x22, 0x56, 0, 0,
	0x44, 0xac, 0, 0,
	2, 0,
	16, 0,
	'd', 'a', 't', 'a',
	0, 0, 0, 0
};
#endif

#pragma data_seg(".sndfmt")
WAVEFORMATEX WaveFMT =
{
    WAVE_FORMAT_PCM,
    1, // channels
    SAMPLE_RATE, // samples per sec
    SAMPLE_RATE*2, // bytes per sec
    2, // block alignment;
    16, // bits per sample
    0 // extension not needed
};

#pragma data_seg(".snddesc")
DSBUFFERDESC SoundDesc =
{
	36,
	DSBCAPS_GLOBALFOCUS | DSBCAPS_GETCURRENTPOSITION2, 
	MAX_SAMPLES,
	0,
	&WaveFMT,
	GUID_NULL	
};

#pragma data_seg(".sndfx")
float vcf[5] = { 0.0f, 0.0f, 0.0f, 1.0f, 0.3f };
#pragma data_seg(".sndfx")
int dpos = 0;
#pragma data_seg(".sndfx")
int ddelay = SAMPLES_PER_PATTERN/8;

#pragma data_seg(".greet")
#define NUM_GREETS 8
char*	Greetings[NUM_GREETS] =
{		
	"fairlight",
	"farb rausch",
	"bypass",
	"tbl",	
	"mfx",		
	"sts",
	"s!p",
	"0ok"
};

#pragma data_seg(".greet")
LONG GreetRect[4] = 
{
	0, 
	0, 
	TEXT_WIDTH, 
	TEXT_HEIGHT
};

#pragma data_seg(".sysstr")
char    FontName[] = "System";
#pragma data_seg(".sysstr")
char	WindowName[] = "EDIT";
#pragma data_seg(".sysstr")
char	DLSPath[] = "\\drivers\\gm.dls";

#pragma data_seg(".metavar")
float GridOffset[3] = {METAGRID_DIM/2, METAGRID_DIM/2, METAGRID_DIM/2};
#pragma data_seg(".metavar")
float axis[3][3] = 
{
	{1.0f, 0.0f, 0.0f},
	{0.0f, 1.0f, 0.0f},
	{0.0f, 0.0f, 1.0f}
};
float fPointScaleC = 1.0f;

#pragma data_seg(".viewvar")
DWORD HDRBlendFactor = 0xffffffff;

#pragma data_seg(".scnvar")
SceneVars scv[6] =
{
	{
		0.0f,
		40.0f,
		0.0f,
		0.1f,
		0.0f,
		D3DX_PI,
		0.0f,
		0.0f,
		6.0f,
		D3DBLEND_INVBLENDFACTOR
	},
	{
		1.5f,
		40.0f,
		0.5f,
		64.0f,
		0.0f,
		D3DX_PI,
		0.0f,
		0.0f,
		20.0f,
		D3DBLEND_ONE
	},
	{
		1.4f,
		80.0f,
		0.5f,
		64.0f,
		0.0f,
		D3DX_PI,
		0.0f,
		0.0f,
		30.0f,
		D3DBLEND_ONE
	},
	{
		1.0f,
		80.0f,
		0.5f,
		64.0f,
		0.0f,
		0.0f,
		0.0f,
		0.0f,
		30.0f,
		D3DBLEND_ONE
	},
	{
		2.0f,
		7.0f,
		0.0f,
		0.5f,
		0.0f,
		0.0f,
		0.0f,
		0.0f,
		2.0f,
		D3DBLEND_ONE
	},
	{
		1.0f,
		80.0f,
		0.5f,
		64.0f,
		0.0f,
		0.0f,
		0.0f,
		0.0f,
		0.0f,
		D3DBLEND_ONE
	}
};

/////////////////////////////////////////////////////////////////////////////////
// crt emulation
/////////////////////////////////////////////////////////////////////////////////

#ifndef MYDEBUG
extern "C" 
{
	int _fltused = 1;
}
#endif


#pragma code_seg(".crtemuf")
int  lrintf (float flt)
{	
	int reti;
	__asm
	{
		fld		flt
		fistp	reti
	}
	return reti;
}

#pragma code_seg(".crtemuf")
float  HzDsqrtf(float i)
{
	__asm fld	i
	__asm fsqrt
}

#pragma code_seg(".crtemuf")
float  HzDsinf(float i)
{
	__asm fld	i
	__asm fsin
}

#pragma code_seg(".crtemuf")
float  HzDcosf(float i)
{
	__asm fld	i
	__asm fcos
}

#pragma code_seg(".crtemuf")
float  HzDfmodf(float i, float j)
{
	__asm fld	j
	__asm fld	i
	__asm fprem
	__asm fxch
	__asm fstp	i
}

#pragma code_seg(".crtemuf")
float HzDfabsf(float i)
{
	__asm fld	i
	__asm fabs
}

#pragma code_seg(".crtemui")
void  HzDZeroMemory(void* dest, SIZE_T s) 
{
	__asm mov edi, dest
	__asm xor eax, eax
	__asm mov ecx, s
	__asm rep stosb
}

#pragma code_seg(".crtemui")
void  HzDCopyMemory(void* dest, void* source, SIZE_T s) 
{
	__asm mov esi, source
	__asm mov edi, dest
	__asm mov ecx, s
	__asm rep movsb
}

#pragma code_seg(".crtemui")
unsigned long  RandomNumber()
{ 
   RandSeed = (RandSeed * 196314165) + 907633515;
   return RandSeed;   
}

/////////////////////////////////////////////////////////////////////////////////
// code
/////////////////////////////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////////////////////////////
// Render Stuff
/////////////////////////////////////////////////////////////////////////////////

#pragma code_seg(".crtgt")
void  CreateRenderTarget(RenderTarget* tgt, DWORD sizex, DWORD sizey)
{
	// create the color surface
	SAFE_CALL(lpD3DDevice->CreateTexture( sizex, sizey, 1, D3DUSAGE_RENDERTARGET, 
		D3DFMT_A8R8G8B8, D3DPOOL_DEFAULT, &(tgt->lpTexture), NULL ), "RT CreateTexture failed");
	// grab and store color surfaces
	SAFE_CALL(tgt->lpTexture->GetSurfaceLevel( 0, &(tgt->lpColorSurface)), "RT GetSurfaceLevel failed");
	// create the depth surface
	SAFE_CALL(lpD3DDevice->CreateDepthStencilSurface( sizex, sizey, D3DFMT_D24S8,
													D3DMULTISAMPLE_NONE, 0, TRUE, 
													&(tgt->lpDepthSurface), NULL ), "RT CreateDepthStencilSurface failed");
}

#pragma code_seg(".setrs")
void  SetRenderState(D3DRENDERSTATETYPE type, DWORD value)
{
	SAFE_CALL(lpD3DDevice->SetRenderState(type, value), "SetRenderState failed");
}

#pragma code_seg(".sadtrt")
void  SetAndDrawToRenderTarget(int tgt, int src, int which)
{
	SAFE_CALL(lpD3DDevice->SetRenderTarget( 0, lpRenderTarget[tgt].lpColorSurface ), "SetRenderTarget failed");
	SAFE_CALL(lpD3DDevice->SetDepthStencilSurface( lpRenderTarget[tgt].lpDepthSurface ), "SetDepthStencilSurface failed");	
	lpD3DDevice->SetTexture( 0, 0 );
	lpD3DDevice->Clear(0, NULL, ClearFlags, 0, 1.0f, 0);
	if (which >= 0)
	{
		lpD3DDevice->SetTexture( 0, lpRenderTarget[src].lpTexture );
		lpD3DDevice->DrawPrimitiveUP( D3DPT_TRIANGLESTRIP, 2, quad_vertices[which], sizeof(QuadVertex) );
	}
}

#pragma code_seg(".updmb")
void  Update_Metaballs(int from, int num)
{
	while (from < num)
	{		
		int influenceRange = 1+lrintf(MetaBalls[from].b);
		int posx = lrintf(MetaBalls[from].pos.x);
		int posy = lrintf(MetaBalls[from].pos.y);
		int posz = lrintf(MetaBalls[from].pos.z);		
		for (int z = posz-influenceRange; z < posz+influenceRange; ++z)
		{
			if (z < 0 || z >= METAGRID_DIM)
				continue;

			for (int y = posy-influenceRange; y < posy+influenceRange; ++y)
			{
				if (y < 0 || y >= METAGRID_DIM)
					continue;

				for (int x = posx-influenceRange; x < posx+influenceRange; ++x)
				{
					if (x < 0 || x >= METAGRID_DIM)
						continue;

					D3DXVECTOR3 grid(x, y, z);
					D3DXVECTOR3 dist = MetaBalls[from].pos-grid;					
					float dist2 = dist.x*dist.x+dist.y*dist.y+dist.z*dist.z;
					float range2 = MetaBalls[from].b*MetaBalls[from].b;

					if (range2 > dist2)
					{
						GridPoint *gp = &MetaGrid[(z<<METAGRID_SHIFT2)+(y<<METAGRID_SHIFT1)+x];
						gp->value += MetaBalls[from].a * 
							(1.0f - 
							0.4444444f*dist2*dist2*dist2/(range2*range2*range2) + 
							1.8888888f*dist2*dist2/(range2*range2) - 
							2.4444444f*dist2/range2);
						gp->flags |= GP_TYPE_META;
					}
				}
			}
		}
		++from;
	}
}

#pragma code_seg(".movemb")
void  Move_Metaballs(float fac)
{
	int movecount = METAGRID_DIM*METAGRID_DIM*METAGRID_DIM;
	while (movecount--)
	{
		if (((movecount >> 12) & 0x3f) > 0)
		{
			MetaGrid[movecount].value = fac*MetaGrid[movecount-METAGRID_DIM*METAGRID_DIM].value;
			MetaGrid[movecount].flags = MetaGrid[movecount-METAGRID_DIM*METAGRID_DIM].flags;
		}
		else
			MetaGrid[movecount].value = 0;
	}	
}

#pragma code_seg(".drawbra")
void  DrawBranch(int tick, int axis1, int axis2, int from, float rot)
{
	float translation = BeatState[2][tick];
	if (translation > 8.0f)
		translation = 8.0f;
	float metarange = 8.0f;

	lpMatrixStack->LoadIdentity();	
	lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[1], tick/44100.0f);            		    
	lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[0], tick/44100.0f);	
	lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[axis1], tick/44100.0f);            		    
	lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[axis2], rot);  

	int i = 10;
	while (i--)
	{
		MetaBalls[i+from].pos = *((D3DXVECTOR3*)(&(lpMatrixStack->GetTop()->_41)))+*((D3DXVECTOR3*)&GridOffset);
		MetaBalls[i+from].a = 1;
		MetaBalls[i+from].b = metarange;	
		metarange *= 0.9f;

		lpMatrixStack->ScaleLocal(0.9f, 0.9f, 0.9f);		
		lpMatrixStack->TranslateLocal(0.0f, translation, 0.0f);		
		lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[0], 0.3f*HzDsinf(tick/88200.0f));
		lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[1], 0.9f*HzDsinf(tick/44100.0f));
	}
}

#pragma code_seg(".mbcol")
DWORD  Metaball_Color(GridPoint* gp, float* maxval)
{
	*maxval = 2.0f*gp->value-1.0f;
	if (*maxval > 1.0f)
		*maxval = 1.0f;

	DWORD metacolor		= MY_RGBA(196, 64+lrintf(192.0f*(1.0f-*maxval)), 0, 0);

	if (gp->flags & GP_TYPE_META)
	{
		if (gp->flags & GP_TYPE_BORDER)
			return ((metacolor & 0xfefefefe) >> 1) + MY_RGBA(0, 64, 92, 0);
		else
			return metacolor;
	}
	else
	{
		if (gp->flags & GP_TYPE_BORDER)
			return MY_RGBA(0, 128, 196, 0);
		else
			return MY_RGBA(128, 228, 128, 0);
	}
}

#pragma code_seg(".crespr")
DWORD  Create_Sprites()
{
	int counter = 0;
	SpriteVertex* sprites;
	SAFE_CALL(lpSpriteVB->Lock(0, 0, (void**)(&sprites),D3DLOCK_DISCARD), "Vertexbuffer Lock failed");
	int spritecount = METAGRID_DIM*METAGRID_DIM*METAGRID_DIM;
	while (spritecount--)
	{
		int posx, posy, posz;
		posx = spritecount & 0x3f;
		posy = (spritecount >> 6) & 0x3f;
		posz = (spritecount >> 12) & 0x3f;
		GridPoint *gp = &MetaGrid[spritecount];
		if (gp->value > Scene_Vars.minI && gp->value < Scene_Vars.maxI)
		{
			float maxval;
			D3DXVECTOR3 mpos(posx, posy, posz);
			sprites->p = mpos-*((D3DXVECTOR3*)&GridOffset);
			sprites->c = Metaball_Color(gp, &maxval);			
			sprites->s = HzDfabsf(1.5f*maxval);
			++counter;
			++sprites;
		}
	}
	SAFE_CALL(lpSpriteVB->Unlock(), "Vertexbuffer Unlock failed");
	return counter;
}

#pragma code_seg(".drawspr")
void  Draw_Sprites(DWORD num)
{		
	// set projection matrix
	float proj[16];
	D3DXMatrixPerspectiveFovLH((D3DXMATRIX*)proj, Scene_Vars.fov, (float)SCREEN_WIDTH/(float)SCREEN_HEIGHT, 1.0f, 1000.0f);
	lpD3DDevice->SetTransform(D3DTS_PROJECTION, (D3DXMATRIX*)proj);

	// set view matrix
	lpMatrixStack->LoadIdentity();
	lpMatrixStack->TranslateLocal(0.0f, Scene_Vars.up, Scene_Vars.zoom);
	lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[1], Scene_Vars.yaw);	
	lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[0], Scene_Vars.pitch);
	lpMatrixStack->RotateAxisLocal((D3DXVECTOR3*)axis[2], Scene_Vars.roll);	
	
	lpD3DDevice->SetTransform(D3DTS_VIEW, lpMatrixStack->GetTop());

	SetRenderState(D3DRS_ALPHATESTENABLE, true);
	SetRenderState(D3DRS_FOGENABLE, true);
	SetRenderState(D3DRS_POINTSPRITEENABLE, true);
	SetRenderState(D3DRS_POINTSCALEENABLE, true);	
	SetRenderState(D3DRS_ALPHAFUNC, D3DCMP_EQUAL);;
	SetRenderState(D3DRS_FOGTABLEMODE, D3DFOG_LINEAR);	
	SetRenderState(D3DRS_ALPHAREF, 0xff);
	SetRenderState(D3DRS_FOGEND, *((DWORD*)&(Scene_Vars.fend)));
	SetRenderState(D3DRS_POINTSCALE_C, *((DWORD*)axis));

	lpD3DDevice->SetTexture(0, lpSpriteTex);
	lpD3DDevice->SetFVF(FVF_SPRITEVERTEX);	
	lpD3DDevice->SetStreamSource(0, lpSpriteVB, 0, sizeof(SpriteVertex));
	lpD3DDevice->DrawPrimitive(D3DPT_POINTLIST, 0, num);
	
	SetRenderState(D3DRS_ALPHATESTENABLE, false);
	SetRenderState(D3DRS_FOGENABLE, false);
	SetRenderState(D3DRS_POINTSPRITEENABLE, false);
	SetRenderState(D3DRS_POINTSCALEENABLE, false);	
}

#pragma code_seg(".render1")
void  Render_Field(DWORD tick)
{
	static DWORD lasttick = 0;
	if (!lasttick)
		HzDZeroMemory(MetaGrid, sizeof(GridPoint)*METAGRID_DIM*METAGRID_DIM*METAGRID_DIM);
	DWORD delta = (tick-lasttick) / 1760; //fix animation to about 25Hz
	if (delta)
		lasttick = tick;
	while (delta--)
	{		
		Move_Metaballs(0.98f);
		for (int i = 0; i < 4; i++)
		{
			MetaBalls[i].pos = D3DXVECTOR3(RandomNumber()>>26, RandomNumber()>>26, 8);
			MetaBalls[i].a = 1;
			MetaBalls[i].b = 4+(RandomNumber()>>29);
		}
		Update_Metaballs(0, 4);
	}
}

void Draw_Cube()
{
	int bordercount = METAGRID_DIM*METAGRID_DIM*METAGRID_DIM;
	while (bordercount--)
	{
		int xyzmod;
		bool border = false;
		int runner = bordercount;
		xyzmod = runner & 0x3f;
		if (!xyzmod || xyzmod == METAGRID_DIM-1)
			border = true;
		runner = runner >> 6;
		xyzmod = runner & 0x3f;
		if (!xyzmod || xyzmod == METAGRID_DIM-1)
			border = true;
		runner = runner >> 6;
		xyzmod = runner & 0x3f;
		if (!xyzmod || xyzmod == METAGRID_DIM-1)
			border = true;
		runner = runner >> 6;
		
		if (border)
		{
			MetaGrid[bordercount].value = 0.75;
			MetaGrid[bordercount].flags = GP_TYPE_BORDER;
		}
	}
}

#pragma code_seg(".render4")
void  Render_Tentacle(DWORD tick)
{
	HzDZeroMemory(MetaGrid, sizeof(GridPoint)*METAGRID_DIM*METAGRID_DIM*METAGRID_DIM);
	Draw_Cube();

	// metaball tentacle
	DrawBranch(tick, 1, 0, 0, 0.0f);
	DrawBranch(tick, 1, 0, 10, D3DX_PI);	
	DrawBranch(tick, 2, 0, 20, D3DX_PI/2);	
	DrawBranch(tick, 2, 0, 30, -D3DX_PI/2);
	DrawBranch(tick, 0, 2, 40, D3DX_PI/2);
	DrawBranch(tick, 0, 2, 50, -D3DX_PI/2);

	Update_Metaballs(0, 60);
}

#pragma code_seg(".render5")
void  Render_Greetings(DWORD tick)
{
	HzDZeroMemory(MetaGrid, sizeof(GridPoint)*METAGRID_DIM*METAGRID_DIM*METAGRID_DIM);
	Draw_Cube();
	static int oldgreet = -1;
	int greet = BeatState[2][tick] & (NUM_GREETS-1);
	if (greet != oldgreet)
	{
		ClearFlags = D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER;
		SetAndDrawToRenderTarget(TEXT_TARGET, NULL, -1);
		lpFont->DrawText(NULL, Greetings[greet], -1, (LPRECT)GreetRect, DT_WORDBREAK | DT_NOCLIP | DT_CENTER | DT_VCENTER, 0xffffffff);
		ClearFlags = 0;
		SetAndDrawToRenderTarget(SCREEN_TARGET, NULL, -1);
		SAFE_CALL(lpD3DDevice->GetRenderTargetData(lpRenderTarget[TEXT_TARGET].lpColorSurface, lpTextSurface), "Text GetRenderTargetData failed");
		oldgreet = greet;
	}
	
	D3DLOCKED_RECT lrect;
	SAFE_CALL(lpTextSurface->LockRect(&lrect, NULL, D3DLOCK_READONLY), "Text LockRect failed");;
	int z = 30;
	while (z++ < 34)
	{
		int yx = METAGRID_DIM*METAGRID_DIM;
		while (yx--)
		{
			if (*(((DWORD*)lrect.pBits)+yx))
			{
				MetaGrid[(z<<METAGRID_SHIFT2)+yx].value = 0.75;
				MetaGrid[(z<<METAGRID_SHIFT2)+yx].flags = GP_TYPE_TEXT;	
			}
		}
	}
	SAFE_CALL(lpTextSurface->UnlockRect(), "Text LockRect failed");; 
}

#pragma code_seg(".preren")
void Prepare_Scene(int i)
{
	HzDCopyMemory(&Scene_Vars, &scv[i], sizeof(Scene_Vars));
}

#pragma code_seg(".render")
void Render(DWORD tick)
{	
	if (BeatState[2][tick] < 16)
	{
		// birth
		Prepare_Scene(0);
		Render_Tentacle(tick);
		Scene_Vars.fov = 3.0414f-HzDsinf(RadPatternTick)*0.1f;
	}
	else if (BeatState[2][tick] < 32)
	{
		// metaball field
		Prepare_Scene(1);
		Render_Field(tick - 16*SAMPLES_PER_PATTERN);
		Scene_Vars.yaw = HzDsinf(RadPatternTick)*0.2f;
		Scene_Vars.pitch += BeatState[0][tick+100]*0.1f;
		Scene_Vars.roll = tick/88200.0f;
	}
	else if (BeatState[2][tick] < 40)
	{
		// greetings
		Prepare_Scene(2);
		Render_Greetings(tick);
		Scene_Vars.yaw = 0.5f-HzDfmodf(PatternTick, 1);
		Scene_Vars.up = -5.0f+HzDfmodf(PatternTick*20.0f, 20.0f);
	}
	else if (BeatState[2][tick] < 56)
	{
		// tentacle
		Prepare_Scene(3);
		Render_Tentacle(tick - 40*SAMPLES_PER_PATTERN);
		Scene_Vars.yaw = RadPatternTick/10.0f;
		Scene_Vars.roll = RadPatternTick/10.0f;
	}
	else if (BeatState[2][tick] < 64)
	{
		// pseudo plasma
		Prepare_Scene(4);
		Render_Tentacle(tick);
		Scene_Vars.yaw = RadPatternTick*0.2f;
	}
	else if (BeatState[2][tick] < 72)
	{
		// tentacle
		Prepare_Scene(5);
		Render_Tentacle(tick);
		Scene_Vars.yaw = RadPatternTick/10.0f;
		Scene_Vars.roll = RadPatternTick/10.0f;
		Scene_Vars.zoom = -800.0f+RadPatternTick*2.0f;
	}

	LastTick = tick;
	
	// draw the scene
	Draw_Sprites(Create_Sprites());
}

void SetPixelShaderConstantF(float* p1)
{
	SAFE_CALL(lpD3DDevice->SetPixelShaderConstantF(0, p1, 1), "SetPixelShaderConstantF failed");
}

#pragma code_seg(".rintro")
void  RenderIntro(DWORD tick)
{
	lpD3DDevice->BeginScene();
	// render scenes to screen buffer	
	ClearFlags = D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER;
	SetAndDrawToRenderTarget(SCREEN_TARGET, NULL, -1);	
	lpD3DDevice->SetPixelShader(0);
	Render(tick);
	
	// do post processing ...
	ClearFlags = 0;
	lpD3DDevice->SetFVF( FVF_QUADVERTEX );
	lpD3DDevice->SetPixelShader(lpDirBlurPS);
	// downsample4 + brightpass
	SetPixelShaderConstantF(blur_params[0]);
	SetAndDrawToRenderTarget(BLUR1_TARGET, SCREEN_TARGET, 0);	
	// blur horizontal
	SetPixelShaderConstantF(blur_params[1]);
	SetAndDrawToRenderTarget(BLUR2_TARGET, BLUR1_TARGET, 0);	
	// blur vertical
	SetPixelShaderConstantF(blur_params[2]);
	SetAndDrawToRenderTarget(BLUR1_TARGET, BLUR2_TARGET, 0);	

	lpD3DDevice->SetPixelShader(0);
	SetRenderState(D3DRS_SRCBLEND, D3DBLEND_BLENDFACTOR);
	SetRenderState(D3DRS_DESTBLEND, Scene_Vars.blendfactor);
	SetRenderState(D3DRS_ALPHABLENDENABLE, TRUE);		
	SetRenderState(D3DRS_BLENDFACTOR, HDRBlendFactor);
	SetAndDrawToRenderTarget(SCREEN_TARGET, BLUR1_TARGET, 1);	
	SetRenderState(D3DRS_ALPHABLENDENABLE, FALSE);
	SetAndDrawToRenderTarget(ORIGINAL_TARGET, SCREEN_TARGET, 1);	

	lpD3DDevice->EndScene();
	lpD3DDevice->Present(NULL,NULL,NULL,NULL);
}

/////////////////////////////////////////////////////////////////////////////////
// Initialization
/////////////////////////////////////////////////////////////////////////////////

#pragma code_seg(".clamps")
int  ClampSound(int val)
{
	if (val > 32767)
		val = 32767;
	if (val < -32767)
		val = -32767;
	return val;
}

#pragma code_seg(".fxsnd")
void Process_Effects(short* data[], DWORD s)
{
	short* dest;
	int input;
	// lowpass for 1st buffer
	dest = (data[0]+s);
	input = *dest;
	vcf[0]   = vcf[0] + vcf[3]*vcf[2];
	vcf[1]  = input - vcf[0] - vcf[4]*vcf[2];
	vcf[2]  = vcf[3]*vcf[1] + vcf[2];
	*dest = ClampSound(lrintf(vcf[0]));
	// delay for 2nd buffer
	dest = (data[1]+s);
	input = *dest;
	int val = dbuffer[(dpos + DBUFFER_SIZE - ddelay) & DBUFFER_MASK];
	dbuffer[dpos++] = input + (val>>1);
	dpos &= DBUFFER_MASK;
	*dest = ClampSound((input+val)>>1);	
}

#pragma code_seg(".reninst")
void  Render_Instrument(Instrument* inst, short* data[], DWORD s, float speed)
{
	short* dest = (data[inst->flags & TARGET_BUFFER_MASK]+s);
	short* src = (short*)(lpFileBuffer+inst->waveDataOffset);
	int bla = *dest;
	bla += (*(src+lrintf(inst->playPos))*inst->volume)>>8;
	*dest++ = ClampSound(bla);
	inst->playPos += speed;
}

#pragma code_seg(".rensnd")
void  Render_Sound()
{
	DWORD size;
	short *data[2];
	SAFE_CALL(lpDSBuffer[0]->Lock(0, 0, (LPVOID*)(&(data[0])), &size, 0, 0, DSBLOCK_ENTIREBUFFER), "Sound Lock failed");
	SAFE_CALL(lpDSBuffer[1]->Lock(0, 0, (LPVOID*)(&(data[1])), &size, 0, 0, DSBLOCK_ENTIREBUFFER), "Sound Lock failed");

#ifdef EXPORT_SOUND
	FILE *ef = fopen("sound.wav", "wb");
	HzDCopyMemory(lpSoundBuffer, WaveHeader, sizeof(WaveHeader));
	int exportoffset = 22;
#endif

	// fill all buffers with samples
	for (int s = 0; s < MAX_SAMPLES; s++)
	{
		int pindex = s / SAMPLES_PER_PATTERN;
		int tindex = (s / SAMPLES_PER_TICK) & 15;
		if (pindex == MAX_PATTERNS)
			break;
		for (int i = 0; i < MAX_INSTRUMENTS; i++)
		{
			Instrument* inst = &IntroInstruments[i];
			int whichPattern = inst->patternSeq[pindex];
			NotePattern* npat = &(((NotePattern*)(inst->patterns))[whichPattern]);
			int curpattern = ((WORD*)(inst->patterns))[whichPattern];
			int samples2Render = 0;	
			float playspeed = 1.0f;
			
			// percussion?
			if (inst->flags & NOTE_PATTERN_TYPE_BIT)
			{				
				BYTE note = npat->tick[tindex];
				if (note != inst->lastVal)
					inst->playPos = 0.0f;
				inst->lastVal = note;
				if (note)
				{				
					float mul; 
					if (note > 128)
					{
						note -= 128;
						mul = SQRT_12_2;
					}
					else
					{
						note = 128-note;
						mul = SQRT_12_2_INV;
					}
					float freq = 1.0f;
					while (note--)
						freq *= mul;

					playspeed = freq;
					samples2Render = 1;
				}
			}
			else
			{
				int beat = (curpattern >> tindex) & 1;
				// new tick pos?
				if (tindex != inst->lastVal)
				{
					inst->lastVal = tindex;
					// have to play?
					if (beat)
					{
						inst->playPos = 0.0f;
						samples2Render = inst->length;
					}
				}		
				// remember beat state at each ms for sync lateron
				BeatState[i][s] = beat;
			}

			int cs = s;
			while (samples2Render--)
			{
				Render_Instrument(inst, data, cs++, playspeed);
			}
		}
		BeatState[2][s] = pindex;
		Process_Effects(data,  s);

		if (pindex >= 40 && pindex < 48)
		{
			float fac = (((float)s/(float)SAMPLES_PER_PATTERN)-40.0f)/8.0f;
			vcf[3] = fac*fac;
		}
#ifdef EXPORT_SOUND
		lpSoundBuffer[exportoffset] = ClampSound(data[0][s] + data[1][s]);
		exportoffset++;
#endif
	}
#ifdef EXPORT_SOUND
	*((DWORD*)(&lpSoundBuffer[2])) = exportoffset*2 - 8;
	*((DWORD*)(&lpSoundBuffer[20])) = exportoffset*2 - 44;
	fwrite(lpSoundBuffer, 1, exportoffset*2, ef);
	fclose(ef);
#endif
	SAFE_CALL(lpDSBuffer[0]->Unlock(data[0], size, 0, 0), "Sound Unlock failed");	
	SAFE_CALL(lpDSBuffer[1]->Unlock(data[1], size, 0, 0), "Sound Unlock failed");	
}

#pragma code_seg(".initsnd")
void  Init_Sound()
{
	// init sound objects
	LPDIRECTSOUND8 lpDS;
	LPDIRECTSOUNDBUFFER lpDSB;
	SAFE_CALL(DirectSoundCreate8(NULL, &lpDS, NULL), "Sound DirectSoundCreate8 failed");
	SAFE_CALL(lpDS->SetCooperativeLevel(screen_params.hDeviceWindow, DSSCL_PRIORITY), "Sound SetCooperativeLevel failed");
	SAFE_CALL(lpDS->CreateSoundBuffer(&SoundDesc, &lpDSB, 0), "Sound CreateSoundBuffer failed");
	SAFE_CALL(lpDSB->QueryInterface( IID_IDirectSoundBuffer8, (LPVOID*) &lpDSBuffer[0] ), "Sound QueryInterface failed");
	SAFE_CALL(lpDS->CreateSoundBuffer(&SoundDesc, &lpDSB, 0), "Sound CreateSoundBuffer failed");
	SAFE_CALL(lpDSB->QueryInterface( IID_IDirectSoundBuffer8, (LPVOID*) &lpDSBuffer[1] ), "Sound QueryInterface failed");

	// open gm.dls file
	DWORD size = GetSystemDirectory(lpFileBuffer, 0x7f);
	HzDCopyMemory(lpFileBuffer+size, DLSPath, sizeof(DLSPath));
	_lread(_lopen(lpFileBuffer, 0), lpFileBuffer, 0x800000);

	// add a synth base drum to the basedrum of the gm.dls 
	short* src = (short*)(lpFileBuffer+0x26b3d0);
	int samples = 4930/2;
	int amp = 20000;
	float freq = 220.0f/22050.0f;
	float phase = 0.0f;
	while (samples--)
	{
		int bla = *src >> 2;
		bla += lrintf(amp*HzDsinf(phase*2.0f*D3DX_PI));
		phase += freq;
		freq *= 0.999f;
		if (samples < 500)
			amp -= 40;
		*src++ = ClampSound(bla);
	}

	Render_Sound();
	// play sound	
	lpDSBuffer[0]->Play(0, 0, 0);	
	lpDSBuffer[1]->Play(0, 0, 0);
}

#pragma code_seg(".initmb")
void  Init_Graphics()
{	
	SAFE_CALL(lpD3DDevice->CreateVertexBuffer(sizeof(SpriteVertex)*METAGRID_DIM*METAGRID_DIM*METAGRID_DIM, 
				D3DUSAGE_DYNAMIC | D3DUSAGE_WRITEONLY | D3DUSAGE_POINTS, FVF_SPRITEVERTEX, D3DPOOL_DEFAULT, &lpSpriteVB, NULL), "Sprite CreateVertexBuffer failed");
	
	SAFE_CALL(lpD3DDevice->CreateTexture( 256, 256, 1, 0, 
		D3DFMT_A8R8G8B8, D3DPOOL_MANAGED, &lpSpriteTex, NULL ), "Sprite CreateTexture failed");
	
	// create a sphere texture
	D3DLOCKED_RECT lr;
	SAFE_CALL(lpSpriteTex->LockRect(0, &lr, 0, 0), "Sprite LockRect failed");
	D3DCOLOR* pixel = (D3DCOLOR*)lr.pBits; 
	int texcount = 256*256;
	while (texcount--)
	{
		int x = (texcount & 0xff) - 128;
		int y = ((texcount >> 8) & 0xff) -128;
		int cval = lrintf((1.0f-HzDsqrtf(x*x + y*y)/128.0f)*256.0f);
        if (cval < 0)
            cval = 0;
		int aval = cval > 0 ? 255 : 0;
		*pixel++ = MY_RGBA(cval, cval, cval, aval);
	} 
	SAFE_CALL(lpSpriteTex->UnlockRect(0), "Sprite UnlockRect failed");
}

#pragma code_seg(".init")
void  Init()
{
	// create the window
	screen_params.hDeviceWindow = CreateWindowEx(
									WS_EX_TOPMOST | WS_EX_APPWINDOW, WindowName, WindowName,
									WS_VISIBLE | WS_POPUP,0,0,
			   						SCREEN_WIDTH,SCREEN_HEIGHT,
									0,0,0,0); 

	// create d3d object
	lpD3D = Direct3DCreate9(D3D_SDK_VERSION);

	// create 3d3 device
    SAFE_CALL(lpD3D->CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, screen_params.hDeviceWindow, 
									D3DCREATE_HARDWARE_VERTEXPROCESSING | D3DCREATE_PUREDEVICE, 
									&screen_params, &lpD3DDevice), "Create Device Failed");

	// create the screen map
	CreateRenderTarget(&lpRenderTarget[SCREEN_TARGET], SCREEN_WIDTH, SCREEN_HEIGHT);
	// create the half screen map
	CreateRenderTarget(&lpRenderTarget[BLUR1_TARGET], BLUR_WIDTH, BLUR_HEIGHT);
	// create the half screen map
	CreateRenderTarget(&lpRenderTarget[BLUR2_TARGET], BLUR_WIDTH, BLUR_HEIGHT);
	// create the text map
	CreateRenderTarget(&lpRenderTarget[TEXT_TARGET], TEXT_WIDTH, TEXT_HEIGHT);
	SAFE_CALL(lpD3DDevice->CreateOffscreenPlainSurface( TEXT_WIDTH, TEXT_HEIGHT, D3DFMT_A8R8G8B8, 
							D3DPOOL_SYSTEMMEM, &lpTextSurface, NULL ), "CreateOffscreenPlainSurface Failed");

	// save original color and depth surfaces
	SAFE_CALL(lpD3DDevice->GetRenderTarget( 0, &(lpRenderTarget[ORIGINAL_TARGET].lpColorSurface) ), "GetRenderTarget Failed");
	SAFE_CALL(lpD3DDevice->GetDepthStencilSurface( &(lpRenderTarget[ORIGINAL_TARGET].lpDepthSurface) ), "GetDepthStencilSurface Failed");

	// some state init
	lpD3DDevice->SetRenderState(D3DRS_LIGHTING, false); 	
	lpD3DDevice->SetSamplerState(0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR);
	lpD3DDevice->SetSamplerState(0, D3DSAMP_ADDRESSU, D3DTADDRESS_BORDER );
	lpD3DDevice->SetSamplerState(0, D3DSAMP_ADDRESSV, D3DTADDRESS_BORDER );

	// create the pixel shader
	SAFE_CALL(lpD3DDevice->CreatePixelShader((DWORD*)DirBlurPS, &lpDirBlurPS), "CreatePixelShader Failed");

	// create the font
	SAFE_CALL(D3DXCreateFont( lpD3DDevice,		   // D3D device
							0,					   // Height
							0,                     // Width
							FW_DONTCARE,             // Weight
							0,                     // MipLevels, 0 = autogen mipmaps
							FALSE,                 // Italic
							ANSI_CHARSET,       // CharSet
							OUT_DEFAULT_PRECIS,    // OutputPrecision
							DEFAULT_QUALITY,       // Quality
							DEFAULT_PITCH | FF_DONTCARE, // PitchAndFamily
							FontName,              // pFaceName
							&lpFont), "D3DXCreateFont failed");             // ppFont */

	// create a matrix stack
	SAFE_CALL(D3DXCreateMatrixStack(0, &lpMatrixStack), "D3DXCreateMatrixStack failed");

	// sound
	Init_Graphics();	
	Init_Sound();	

	// hide the mouse cursor
	ShowCursor(false);
}


/////////////////////////////////////////////////////////////////////////////////
// entry point for the executable if msvcrt is not used
/////////////////////////////////////////////////////////////////////////////////
#pragma code_seg(".main")
#ifndef MYDEBUG
void mainCRTStartup(void)
#else
void main()
#endif
{
	Init();

	while(!GetAsyncKeyState(VK_ESCAPE))
	{
		DWORD playpos;
		lpDSBuffer[0]->GetCurrentPosition(&playpos, 0);
		PatternTick = HzDfmodf(playpos*0.5f/(float)SAMPLES_PER_PATTERN, 1.0f);
		RadPatternTick = playpos*D3DX_PI/(float)SAMPLES_PER_PATTERN;
		RenderIntro(playpos>>1);
		if (playpos > 4762800)
			ExitProcess(0);
	}
	ExitProcess(0);
}
