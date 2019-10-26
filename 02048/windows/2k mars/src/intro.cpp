/*
** 2k DirectX 9.0c Mars Intro
** Copyright (C) 2008 Wael EL ORAIBY, All Rights Reserved
**
** This program is free software: you can redistribute it and/or modify
** it under the terms of the GNU General Public License as published by
** the Free Software Foundation, either version 3 of the License, or
** (at your option) any later version.
**
** This program is distributed in the hope that it will be useful,
** but WITHOUT ANY WARRANTY; without even the implied warranty of
** MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
** GNU General Public License for more details.
**
** You should have received a copy of the GNU General Public License
** along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
** This is the Tim Clarke's 5.5k MARS remake (well kinda =)
**
** This remake relies heavily on shaders 2a. Shaders are used to generate the terrain
** and the sky. Some parts use assembly programming to optimize code size.
*/

#include <windows.h>
#include <multimon.h>
#include <crtdbg.h>

#include <d3d9.h>
#include <d3dx9.h>

#define _USE_MATH_DEFINES
#include <cmath>
#include <d3d9.h>
#include <d3dx9.h>

typedef unsigned char	uint8;
typedef unsigned short	uint16;
typedef unsigned int	uint32;
typedef signed char		sint8;
typedef signed short	sint16;
typedef signed int		sint32;

#define MAP_SIZE		256
#define MAP_SIZE_MASK	0xFF
#define MAP_POWER		8
#define INV_MAP_SIZE_F	((float)(1.0f / (float)MAP_SIZE))

#define SCREEN_WIDTH	640
#define SCREEN_HEIGHT	480

#define HALF_PLANE_SIZE		16384
#define FULL_PLANE_SIZE		(HALF_PLANE_SIZE << 1)

// variable used for floating point access
extern "C" int			_fltused	= 0;

LPDIRECT3DDEVICE9		g_d3d_device;

LPDIRECT3DVERTEXBUFFER9	g_plane_vb, g_quad_vb;
LPDIRECT3DINDEXBUFFER9	g_plane_ib;

LPDIRECT3DPIXELSHADER9  g_perlin_ps, g_sky_ps, g_terr_ps;
LPDIRECT3DVERTEXSHADER9	g_perlin_vs, g_sky_vs, g_terr_vs;
LPDIRECT3DTEXTURE9		g_noise_tex, g_perlin_tex;
LPDIRECT3DSURFACE9		g_perlin_surface;

/*
** pixel shader entry
*/
struct ps_entry
{
	char					*name;
	LPDIRECT3DPIXELSHADER9	*shader;
};

#define NUM_PS_ENTRIES	3
ps_entry ps_entries[] = {
	{ "perlin_ps", &g_perlin_ps },
	{ "sky_ps", &g_sky_ps },
	{ "terr_ps", &g_terr_ps }
};

/*
** vertex shader entry
*/
struct vs_entry
{
	char					*name;
	LPDIRECT3DVERTEXSHADER9	*shader;
};

#define NUM_VS_ENTRIES 3
vs_entry vs_entries[] = {
	{ "perlin_vs", &g_perlin_vs },
	{ "sky_vs", &g_sky_vs },
	{ "terr_vs", &g_terr_vs }
};

/*
** final viewing matrix
*/
float					g_mat[] = {
	-1.5574f,	0.0f,	0.0f,	0.0f,
	0.0f,		2.0765f,	0.0f,	-8721.3877f,
	0.0f,		0.0f,	-1.0f,	999.03f,
	0.0f,		0.0f,	-1.0f,	1000.0f
};

struct vec2 {
	float	x, y;
};

struct vec3 {
	float	x, y, z;
};

/*
** intro vertex format
*/
struct intro_vertex {
	vec3 pos;
	vec3 normal;
	vec2 tex;
};

#define D3DFVF_INTROVERTEX (D3DFVF_XYZ | D3DFVF_NORMAL | D3DFVF_TEX1)

/*
** render vertices are sent as they are to direct3d and they are used for
** render targets (simple ones that is ;)
*/
#define D3DFVF_RENDERVERTEX (D3DFVF_XYZ)
#define RENDER_QUAD_STRIDE	(sizeof(float)*2)
float g_render_quad[] =
{
	-1.0f,  1.0f,
     1.0f,  1.0f,
     1.0f, -1.0f,

	 1.0f, -1.0f,
    -1.0f, -1.0f,
    -1.0f,  1.0f
};

// filled with random noise
float					g_noise[16 * 16];

// plain vertes
intro_vertex			g_plane_vb_buff[MAP_SIZE * MAP_SIZE];

// index buffer
uint32					g_plane_ib_buff[(MAP_SIZE - 1) * (MAP_SIZE - 1) * 6];

/*
** include the shaders
*/
#include "shaders.inl"

uint32 g_w = 521288629;
uint32 g_z = 362436069;

void __forceinline randomize()
{
	uint32 l = timeGetTime();
	g_w	= l >> 16;
	g_z	= l & 0xFFFF;
}

uint32 __forceinline rand_ui32()
{
	g_z = 36969 * (g_z & 65535) + (g_z >> 16);
	g_w = 18000 * (g_w & 65535) + (g_w >> 16);
	return (g_z << 16) + g_w;
}

void* memcpy (void *destaddr, void const *srcaddr, size_t len)
{
	_asm mov	edi, dword ptr [destaddr];
	_asm mov	esi, dword ptr [srcaddr];
	_asm mov	ecx, len;
	_asm rep	movsb;

	return destaddr;
}

void* memset (void *_str, int c, size_t len)
{
	_asm mov	edi, dword ptr [_str];
	_asm mov	ecx, len;
	_asm mov	al, byte ptr [c];
	_asm rep	stosb;
	return _str;
}

/*
** create the plane index buffer
*/
void __forceinline create_plane_ib()
{
	for( sint32 y = 0; y < MAP_SIZE - 1; y++ )
		for( sint32 x = 0; x < MAP_SIZE - 1; x++ )
		{
			uint32	i = (y * MAP_SIZE + x);
			uint32 offset	= (y * (MAP_SIZE - 1) + x) * 6;
			g_plane_ib_buff[offset + 0] = 
			g_plane_ib_buff[offset + 5] = i;
			g_plane_ib_buff[offset + 1] = i + 1;
			g_plane_ib_buff[offset + 2] =
			g_plane_ib_buff[offset + 3] =
			g_plane_ib_buff[offset + 4] = i + 1 + MAP_SIZE;
			g_plane_ib_buff[offset + 4]--;
		}
}


/*
** creates an horizontal plane
*/
void __forceinline create_horizontal_plane()
{

	for( uint32 i = 0; i < MAP_SIZE * MAP_SIZE; i++ )
	{
		float tu, tv;
		g_plane_vb_buff[i].tex.x	= tu = (float)(i & MAP_SIZE_MASK) * INV_MAP_SIZE_F;
		g_plane_vb_buff[i].tex.y	= tv = (float)(i >> MAP_POWER) * INV_MAP_SIZE_F;
		g_plane_vb_buff[i].pos.x	= (float)(-HALF_PLANE_SIZE) + tu * (float)FULL_PLANE_SIZE;
		g_plane_vb_buff[i].pos.z	= (float)(-HALF_PLANE_SIZE) + tv * (float)FULL_PLANE_SIZE;
//		g_plane_vb_buff[i].pos.y	= (float)elev;
//		g_plane_vb_buff[i].normal.y	= 1.0f;
	}
}

/*
** render the perlin noise
*/
void __forceinline render_perlin()
{
	D3DLOCKED_RECT lock_rect;
	randomize();
	for( uint32 i = 0; i < 16 * 16; i++ )
		g_noise[i]=(float)(rand_ui32()&0xFF)*(1.0f/256.0f);

	if(!FAILED(g_noise_tex->LockRect(0, &lock_rect, NULL, D3DLOCK_DISCARD)))
	{
		memcpy(lock_rect.pBits, g_noise, 16 * 16 * sizeof(float));
		
		g_noise_tex->UnlockRect(0);
	}

	// Clear the back buffer to a blue color
	g_d3d_device->Clear( 0, NULL, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER, D3DCOLOR_XRGB(0,0,255), 1.0f, 0 );
	// Begin the scene
	g_d3d_device->BeginScene();

	g_d3d_device->SetPixelShader(g_perlin_ps);
	g_d3d_device->SetVertexShader(g_perlin_vs);
	// Rendering of scene objects happens here

    g_d3d_device->SetTexture(0, g_noise_tex);

	g_d3d_device->SetStreamSource( 0, g_quad_vb, 0, RENDER_QUAD_STRIDE);
	g_d3d_device->SetFVF( D3DFVF_RENDERVERTEX );
	g_d3d_device->DrawPrimitive( D3DPT_TRIANGLELIST, 0, 2 );

	// End the scene
	g_d3d_device->EndScene();
	g_d3d_device->Present( NULL, NULL, NULL, NULL );
}

/*
** generate terrain and sky geometry
*/
void __forceinline generate_geometry()
{
	void *buff;

	/*
	** render quads
	*/
	// create quad vertex buffer
	if( FAILED( g_d3d_device->CreateVertexBuffer( 6 * RENDER_QUAD_STRIDE,
         0 /*Usage*/, D3DFVF_RENDERVERTEX, D3DPOOL_DEFAULT, &g_quad_vb, NULL ) ) )
		goto intro_end;

	if( FAILED( g_quad_vb->Lock( 0, 6 * RENDER_QUAD_STRIDE, (void**)&buff, 0 ) ) )
		goto intro_end;

	memcpy( buff, g_render_quad, 6 * RENDER_QUAD_STRIDE );

	g_quad_vb->Unlock();

	/*
	** create a plane (will be used for the elevation geometry and the sky some)
	*/
	// create sky plane
	create_horizontal_plane();

	// create vertex buffer for sky plane
	if( FAILED( g_d3d_device->CreateVertexBuffer( MAP_SIZE * MAP_SIZE * sizeof(intro_vertex),
		0, D3DFVF_INTROVERTEX, D3DPOOL_DEFAULT, &g_plane_vb, NULL) ) )
		goto intro_end;
	if( FAILED( g_plane_vb->Lock( 0, MAP_SIZE * MAP_SIZE * sizeof(intro_vertex), (void**)&buff, 0 ) ) )
		goto intro_end;

	memcpy(buff, g_plane_vb_buff, MAP_SIZE * MAP_SIZE * sizeof(intro_vertex));
	
	g_plane_vb->Unlock();

	/*
	** create index buffer
	*/
	create_plane_ib();
	if( FAILED( g_d3d_device->CreateIndexBuffer((MAP_SIZE - 1)*(MAP_SIZE - 1)*sizeof(uint32)*6, 0, D3DFMT_INDEX32,D3DPOOL_DEFAULT,&g_plane_ib, NULL) ) )
		goto intro_end;

	if( FAILED( g_plane_ib->Lock(0, (MAP_SIZE - 1)*(MAP_SIZE - 1)*sizeof(uint32)*6, (void**)&buff, 0) ) )
		goto intro_end;
	memcpy(buff, g_plane_ib_buff, (MAP_SIZE - 1)*(MAP_SIZE - 1)*sizeof(uint32)*6);
	g_plane_ib->Unlock();

	/*
	** now render the perlin surface (compute elevation and normals
	*/

	LPDIRECT3DSURFACE9 backbuff_surface;
	g_d3d_device->GetRenderTarget(0, &backbuff_surface);
	g_d3d_device->SetRenderTarget(0, g_perlin_surface);
	
	render_perlin();
	
	g_d3d_device->SetRenderTarget(0, backbuff_surface);

	return;

intro_end:
	ExitProcess(0);
}

void __forceinline render()
{
	static int start_pos = 0;

	// Clear the back buffer to a blue color
	g_d3d_device->Clear( 0, NULL, D3DCLEAR_TARGET | D3DCLEAR_ZBUFFER, D3DCOLOR_XRGB(255,255,255), 1.0f, 0 );

	// Begin the scene
	g_d3d_device->BeginScene();

	g_d3d_device->SetRenderState(D3DRS_CULLMODE, D3DCULL_NONE);

	// Rendering of scene objects happens here
	g_d3d_device->SetTexture(0, g_perlin_tex);
	g_d3d_device->SetTexture(D3DVERTEXTEXTURESAMPLER0, g_perlin_tex);
	//g_d3d_device->SetSamplerState(D3DVERTEXTEXTURESAMPLER1, D3DSAMP_MINFILTER, D3DTEXF_POINT);
	//g_d3d_device->SetSamplerState(D3DVERTEXTEXTURESAMPLER1, D3DSAMP_MAGFILTER, D3DTEXF_POINT);
	//g_d3d_device->SetSamplerState(D3DVERTEXTEXTURESAMPLER1, D3DSAMP_MIPFILTER, D3DTEXF_NONE);

	g_d3d_device->SetStreamSource(0, g_plane_vb, 0, sizeof(intro_vertex));
	g_d3d_device->SetIndices(g_plane_ib);
	g_d3d_device->SetPixelShader(g_sky_ps);
	g_d3d_device->SetVertexShader(g_sky_vs);
	g_d3d_device->SetFVF(D3DFVF_INTROVERTEX);

	g_d3d_device->SetVertexShaderConstantF(0, (const float*)&g_mat, 4);
	float v[4];
	v[0]=0.0f;
	v[1]=-((float)start_pos) * INV_MAP_SIZE_F;
	g_d3d_device->SetVertexShaderConstantF(4, v, 1);
	g_d3d_device->SetPixelShaderConstantF(4, v, 1);
	start_pos = (start_pos+1)&0xFF;

	g_d3d_device->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, MAP_SIZE * MAP_SIZE, 0, (MAP_SIZE - 1) * (MAP_SIZE - 1) * 2);
	
	g_d3d_device->SetPixelShader(g_terr_ps);
	g_d3d_device->SetVertexShader(g_terr_vs);

	g_d3d_device->DrawIndexedPrimitive(D3DPT_TRIANGLELIST, 0, 0, MAP_SIZE * MAP_SIZE, 0, (MAP_SIZE - 1) * (MAP_SIZE - 1) * 2);

	// End the scene
	g_d3d_device->EndScene();
	g_d3d_device->Present( NULL, NULL, NULL, NULL );

}



extern "C"
void entry_point()
{
//	AllocConsole();
//	freopen ( "CONOUT$", "w", stdout );

	// Create the application's window.
	HWND hWnd = CreateWindow( "static", "Mars 4k", 
		WS_OVERLAPPEDWINDOW | WS_VISIBLE, 100, 100, SCREEN_WIDTH, SCREEN_HEIGHT,
		GetDesktopWindow(), NULL, /*wc.hInstance*/ NULL, NULL );

	ShowCursor(FALSE);

	LPDIRECT3D9		d3d;

	if( NULL == ( d3d = Direct3DCreate9( D3D_SDK_VERSION ) ) )
		goto intro_end;

	D3DPRESENT_PARAMETERS d3dpp; 
	ZeroMemory( &d3dpp, sizeof(d3dpp) );
	d3dpp.Windowed = FALSE;
	d3dpp.SwapEffect = D3DSWAPEFFECT_DISCARD;
	d3dpp.EnableAutoDepthStencil = TRUE;
	d3dpp.AutoDepthStencilFormat = D3DFMT_D16;
	d3dpp.BackBufferFormat = D3DFMT_X8R8G8B8;
	d3dpp.BackBufferWidth	= SCREEN_WIDTH;
	d3dpp.BackBufferHeight	= SCREEN_HEIGHT;
	
	if( FAILED( d3d->CreateDevice( D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, hWnd,
		D3DCREATE_HARDWARE_VERTEXPROCESSING,
		&d3dpp, &g_d3d_device ) ) )
		goto intro_end;

	// create perlin/normal noise shader
    ID3DXBuffer *tmp;

	// create pixel shaders
	for( int i = 0; i < NUM_PS_ENTRIES; i++ ) {
		if( FAILED(D3DXCompileShader( g_shaders, sizeof(g_shaders)-1, 0, 0,
			ps_entries[i].name, "ps_3_0",
			D3DXSHADER_OPTIMIZATION_LEVEL3|D3DXSHADER_PREFER_FLOW_CONTROL, &tmp, 0, 0 )) )
			goto intro_end;

		g_d3d_device->CreatePixelShader((DWORD*)tmp->GetBufferPointer(), ps_entries[i].shader );
	}

	// create vertex shaders
	for( int i = 0; i < NUM_VS_ENTRIES; i++ ) {
		if( FAILED(D3DXCompileShader( g_shaders, sizeof(g_shaders)-1, 0, 0,
			vs_entries[i].name, "vs_3_0",
			D3DXSHADER_OPTIMIZATION_LEVEL3|D3DXSHADER_PREFER_FLOW_CONTROL, &tmp, 0, 0 )) )
			goto intro_end;

		g_d3d_device->CreateVertexShader((DWORD*)tmp->GetBufferPointer(), vs_entries[i].shader );
	}

	if(FAILED(D3DXCreateTexture(g_d3d_device, 16, 16, 1, D3DUSAGE_DYNAMIC, D3DFMT_R32F, D3DPOOL_DEFAULT, &g_noise_tex)))
		goto intro_end;

	// create perlin render target
	if( FAILED(g_d3d_device->CreateTexture(MAP_SIZE, MAP_SIZE, 1, D3DUSAGE_RENDERTARGET,
		D3DFMT_A32B32G32R32F, D3DPOOL_DEFAULT, &g_perlin_tex, NULL)) )
		goto intro_end;

	if( FAILED(g_perlin_tex->GetSurfaceLevel(0, &g_perlin_surface)) )
		goto intro_end;

    //g_d3d_device->SetTextureStageState( 0, D3DTSS_COLOROP,   D3DTOP_MODULATE );
    //g_d3d_device->SetTextureStageState( 0, D3DTSS_COLORARG1, D3DTA_TEXTURE );
    //g_d3d_device->SetTextureStageState( 0, D3DTSS_COLORARG2, D3DTA_DIFFUSE );
    //g_d3d_device->SetTextureStageState( 0, D3DTSS_ALPHAOP,   D3DTOP_DISABLE );
	g_d3d_device->SetSamplerState( 0, D3DSAMP_MINFILTER, D3DTEXF_LINEAR );
	g_d3d_device->SetSamplerState( 0, D3DSAMP_MAGFILTER, D3DTEXF_LINEAR );

	// create geometry
	generate_geometry();

	do {
		render();
	} while(!GetAsyncKeyState(VK_ESCAPE));

intro_end:
	ExitProcess(0);
}

