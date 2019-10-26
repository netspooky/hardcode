; Some equates for d3d (incomplete)

SND_SYNC            		equ	00000h
SND_ASYNC			equ	00001h
SND_NODEFAULT			equ	00002h
SND_MEMORY			equ	00004h
SND_LOOP			equ	00008h
SND_NOSTOP			equ	00010h

SND_NOWAIT			equ	000002000h
SND_ALIAS			equ	000010000h
SND_ALIAS_ID			equ	000110000h
SND_FILENAME			equ	000020000h
SND_RESOURCE			equ	000040004h
SND_PURGE			equ	00040h
SND_APPLICATION			equ	00080h
SND_ALIAS_START			equ	0

D3DFMT_UNKNOWN			equ	0
D3DFMT_R8G8B8			equ	20
D3DFMT_A8R8G8B8			equ	21
D3DFMT_X8R8G8B8			equ	22
D3DFMT_R5G6B5			equ	23
D3DFMT_X1R5G5B5			equ	24
D3DFMT_A1R5G5B5			equ	25
D3DFMT_A4R4G4B4			equ	26
D3DFMT_R3G3B2			equ	27
D3DFMT_A8			equ	28
D3DFMT_A8R3G3B2			equ	29
D3DFMT_X4R4G4B4			equ	30
D3DFMT_A2B10G10R10		equ	31
D3DFMT_G16R16			equ	34

D3DFMT_A8P8			equ	40
D3DFMT_P8			equ	41

D3DFMT_L8			equ	50
D3DFMT_A8L8			equ	51
D3DFMT_A4L4			equ	52

D3DFMT_V8U8			equ	60
D3DFMT_L6V5U5			equ	61
D3DFMT_X8L8V8U8			equ	62
D3DFMT_Q8W8V8U8			equ	63
D3DFMT_V16U16			equ	64
D3DFMT_W11V11U10		equ	65
D3DFMT_A2W10V10U10		equ	67

D3DFMT_D16_LOCKABLE		equ	70
D3DFMT_D32			equ	71
D3DFMT_D15S1			equ	73
D3DFMT_D24S8			equ	75
D3DFMT_D16			equ	80
D3DFMT_D24X8			equ	77
D3DFMT_D24X4S4			equ	79

D3DFMT_VERTEXDATA		equ	100
D3DFMT_INDEX16			equ	101
D3DFMT_INDEX32			equ	102

D3DTEXF_NONE			equ	0
D3DTEXF_POINT			equ	1
D3DTEXF_LINEAR			equ	2
D3DTEXF_ANISOTROPIC		equ	3
D3DTEXF_PYRAMIDALQUAD		equ	6
D3DTEXF_GAUSSIANQUAD		equ	7
D3DTEXF_FORCE_DWORD		equ	07fffffffh

D3DSAMP_ADDRESSU		equ	1
D3DSAMP_ADDRESSV		equ	2
D3DSAMP_ADDRESSW		equ	3
D3DSAMP_BORDERCOLOR		equ	4
D3DSAMP_MAGFILTER		equ	5
D3DSAMP_MINFILTER		equ	6
D3DSAMP_MIPFILTER		equ	7
D3DSAMP_MIPMAPLODBIAS		equ	8
D3DSAMP_MAXMIPLEVEL		equ	9
D3DSAMP_MAXANISOTROPY		equ	10
D3DSAMP_SRGBTEXTURE		equ	11
D3DSAMP_ELEMENTINDEX		equ	12
D3DSAMP_DMAPOFFSET		equ	13
D3DSAMP_FORCE_DWORD		equ	07fffffffh

D3DUSAGE_RENDERTARGET		equ	000000001h
D3DUSAGE_DEPTHSTENCIL		equ	000000002h
D3DUSAGE_DYNAMIC		equ	000000200h

D3DUSAGE_AUTOGENMIPMAP		equ	000000400h
D3DUSAGE_DMAP			equ	000004000h

D3DUSAGE_QUERY_LEGACYBUMPMAP	equ	000008000h
D3DUSAGE_QUERY_SRGBREAD		equ	000010000h
D3DUSAGE_QUERY_FILTER		equ	000020000h
D3DUSAGE_QUERY_SRGBWRITE	equ	000040000h
D3DUSAGE_QUERY_POSTPIXELSHADER_BLENDING	equ 000080000h
D3DUSAGE_QUERY_VERTEXTEXTURE	equ	000100000h
D3DUSAGE_QUERY_WRAPANDMIP	equ	000200000h

D3DUSAGE_WRITEONLY		equ	000000008h
D3DUSAGE_SOFTWAREPROCESSING	equ	000000010h
D3DUSAGE_DONOTCLIP		equ	000000020h
D3DUSAGE_POINTS			equ	000000040h
D3DUSAGE_RTPATCHES		equ	000000080h
D3DUSAGE_NPATCHES		equ	000000100h

; --- DX equates and structures
;D3D_SDK_VERSION			equ	220
D3D_SDK_VERSION			equ	32
D3DSWAPEFFECT_DISCARD		equ	1
D3DSWAPEFFECT_FLIP		equ	2
D3DPRESENT_RATE_DEFAULT		equ	0
D3DFMT_D32F_LOCKABLE		equ	82
D3DFMT_D24FS8			equ	83
D3DPRESENT_INTERVAL_IMMEDIATE   equ	080000000h
D3DADAPTER_DEFAULT		equ	0
D3DDEVTYPE_HAL			equ	1
D3DCREATE_SOFTWARE_VERTEXPROCESSING	equ	000000020h
D3DCREATE_HARDWARE_VERTEXPROCESSING     equ	000000040h
D3DCLEAR_TARGET			equ	000000001h
D3DCLEAR_ZBUFFER		equ	000000002h
D3DCLEAR_STENCIL		equ	000000004h
D3DFVF_RESERVED0		equ	0001h
D3DFVF_POSITION_MASK		equ	0400Eh
D3DFVF_XYZ			equ	0002h
D3DFVF_XYZRHW			equ	0004h
D3DFVF_XYZB1			equ	0006h
D3DFVF_XYZB2			equ	0008h
D3DFVF_XYZB3			equ	000ah
D3DFVF_XYZB4			equ	000ch
D3DFVF_XYZB5			equ	000eh
D3DFVF_XYZW			equ	04002h
D3DFVF_NORMAL           	equ	0010h
D3DFVF_PSIZE            	equ	0020h
D3DFVF_DIFFUSE          	equ	0040h
D3DFVF_SPECULAR         	equ	0080h
D3DFVF_TEXCOUNT_MASK    	equ	0f00h
D3DFVF_TEXCOUNT_SHIFT   	equ	8
D3DFVF_TEX0             	equ	0000h
D3DFVF_TEX1             	equ	0100h
D3DFVF_TEX2             	equ	0200h
D3DFVF_TEX3             	equ	0300h
D3DFVF_TEX4             	equ	0400h
D3DFVF_TEX5             	equ	0500h
D3DFVF_TEX6             	equ	0600h
D3DFVF_TEX7             	equ	0700h
D3DFVF_TEX8             	equ	0800h
D3DFVF_TEXTUREFORMAT2		equ	0
D3DFVF_TEXTUREFORMAT1		equ	3
D3DFVF_TEXTUREFORMAT3		equ	1
D3DFVF_TEXTUREFORMAT4 		equ	2
D3DTS_VIEW			equ	2
D3DTS_PROJECTION		equ	3
D3DTS_TEXTURE0			equ	16
D3DTS_WORLD			equ	0 + 256
D3DTS_WORLD1			equ	1 + 256
D3DTS_WORLD2			equ	2 + 256
D3DTS_WORLD3			equ	3 + 256
D3DPT_POINTLIST			equ	1
D3DPT_LINELIST			equ	2
D3DPT_LINESTRIP			equ	3
D3DPT_TRIANGLELIST		equ	4
D3DPT_TRIANGLESTRIP		equ	5
D3DPT_TRIANGLEFAN		equ	6
D3DLIGHT_POINT			equ	1
D3DLIGHT_SPOT			equ	2
D3DLIGHT_DIRECTIONAL		equ	3
D3DFILL_POINT			equ	1
D3DFILL_WIREFRAME		equ	2
D3DFILL_SOLID			equ	3
D3DCULL_NONE			equ	1
D3DCULL_CW			equ	2
D3DCULL_CCW			equ	3
D3DRS_ZENABLE			equ	7
D3DRS_FILLMODE			equ	8
D3DRS_SHADEMODE			equ	9
D3DRS_LINEPATTERN		equ	10		; unverified from here
D3DRS_ZWRITEENABLE		equ	14
D3DRS_ALPHATESTENABLE		equ	15
D3DRS_LASTPIXEL			equ	16
D3DRS_SRCBLEND			equ	19
D3DRS_DESTBLEND			equ	20
D3DRS_CULLMODE			equ	22
D3DRS_ZFUNC			equ	23
D3DRS_ALPHAREF			equ	24
D3DRS_ALPHAFUNC			equ	25
D3DRS_DITHERENABLE		equ	26
D3DRS_ALPHABLENDENABLE		equ	27
D3DRS_FOGENABLE			equ	28
D3DRS_SPECULARENABLE		equ	29
D3DRS_ZVISIBLE			equ	30
D3DRS_FOGCOLOR			equ	34
D3DRS_FOGTABLEMODE		equ	35
D3DRS_FOGSTART			equ	36
D3DRS_FOGEND			equ	37
D3DRS_FOGDENSITY		equ	38
D3DRS_EDGEANTIALIAS		equ	40
D3DRS_ZBIAS			equ	47
D3DRS_RANGEFOGENABLE		equ	48
D3DRS_STENCILENABLE		equ	52
D3DRS_STENCILFAIL		equ	53
D3DRS_STENCILZFAIL		equ	54
D3DRS_STENCILPASS		equ	55
D3DRS_STENCILFUNC		equ	56
D3DRS_STENCILREF		equ	57
D3DRS_STENCILMASK		equ	58
D3DRS_STENCILWRITEMASK		equ	59
D3DRS_TEXTUREFACTOR		equ	60
D3DRS_WRAP0			equ	128
D3DRS_WRAP1			equ	129
D3DRS_WRAP2			equ	130
D3DRS_WRAP3			equ	131
D3DRS_WRAP4			equ	132
D3DRS_WRAP5			equ	133
D3DRS_WRAP6			equ	134
D3DRS_WRAP7			equ	135
D3DRS_CLIPPING			equ	136
D3DRS_LIGHTING			equ	137
D3DRS_AMBIENT			equ	139
D3DRS_FOGVERTEXMODE		equ	140
D3DRS_COLORVERTEX		equ	141
D3DRS_LOCALVIEWER		equ	142
D3DRS_NORMALIZENORMALS		equ	143
D3DRS_DIFFUSEMATERIALSOURCE	equ	145
D3DRS_SPECULARMATERIALSOURCE	equ	146
D3DRS_AMBIENTMATERIALSOURCE	equ	147
D3DRS_EMISSIVEMATERIALSOURCE	equ	148
D3DRS_VERTEXBLEND		equ	151
D3DRS_CLIPPLANEENABLE		equ	152
D3DRS_SOFTWAREVERTEXPROCESSING	equ	153
D3DRS_POINTSIZE			equ	154
D3DRS_POINTSIZE_MIN		equ	155
D3DRS_POINTSPRITEENABLE		equ	156
D3DRS_POINTSCALEENABLE		equ	157
D3DRS_POINTSCALE_A		equ	158
D3DRS_POINTSCALE_B		equ	159
D3DRS_POINTSCALE_C		equ	160
D3DRS_MULTISAMPLEANTIALIAS	equ	161
D3DRS_MULTISAMPLEMASK		equ	162
D3DRS_PATCHEDGESTYLE		equ	163
D3DRS_PATCHSEGMENTS		equ	164
D3DRS_DEBUGMONITORTOKEN		equ	165
D3DRS_POINTSIZE_MAX		equ	166
D3DRS_INDEXEDVERTEXBLENDENABLE	equ	167
D3DRS_COLORWRITEENABLE		equ	168
D3DRS_TWEENFACTOR		equ	170
D3DRS_BLENDOP			equ	171
D3DRS_POSITIONORDER		equ	172
D3DRS_NORMALORDER		equ	173
D3DRS_SCISSORTESTENABLE		equ	174
D3DRS_SLOPESCALEDEPTHBIAS	equ	175
D3DRS_ANTIALIASEDLINEENABLE	equ	176
D3DRS_MINTESSELLATIONLEVEL	equ	178
D3DRS_MAXTESSELLATIONLEVEL	equ	179
D3DRS_ADAPTIVETESS_X		equ	180
D3DRS_ADAPTIVETESS_Y		equ	181
D3DRS_ADAPTIVETESS_Z		equ	182
D3DRS_ADAPTIVETESS_W		equ	183
D3DRS_ENABLEADAPTIVETESSELLATION equ	184
D3DRS_TWOSIDEDSTENCILMODE	equ	185
D3DRS_CCW_STENCILFAIL		equ	186
D3DRS_CCW_STENCILZFAIL		equ	187
D3DRS_CCW_STENCILPASS		equ	188
D3DRS_CCW_STENCILFUNC		equ	189
D3DRS_COLORWRITEENABLE1		equ	190
D3DRS_COLORWRITEENABLE2		equ	191
D3DRS_COLORWRITEENABLE3		equ	192
D3DRS_BLENDFACTOR		equ	193
D3DRS_SRGBWRITEENABLE		equ	194
D3DRS_DEPTHBIAS			equ	195
D3DRS_WRAP8			equ	198
D3DRS_WRAP9			equ	199
D3DRS_WRAP10			equ	200
D3DRS_WRAP11			equ	201
D3DRS_WRAP12			equ	202
D3DRS_WRAP13			equ	203
D3DRS_WRAP14			equ	204
D3DRS_WRAP15			equ	205
D3DRS_SEPARATEALPHABLENDENABLE	equ	206
D3DRS_SRCBLENDALPHA		equ	207
D3DRS_DESTBLENDALPHA		equ	208
D3DRS_BLENDOPALPHA		equ	209

D3DFOG_NONE			equ	0
D3DFOG_EXP			equ	1
D3DFOG_EXP2			equ	2
D3DFOG_LINEAR			equ	3
D3DTOP_DISABLE			equ	1
D3DTOP_SELECTARG1		equ	2
D3DTOP_SELECTARG2		equ	3
D3DTOP_MODULATE			equ	4
D3DTOP_MODULATE2X		equ	5
D3DTOP_MODULATE4X		equ	6
D3DTOP_ADD			equ	7
D3DTOP_ADDSIGNED		equ	8
D3DTOP_ADDSIGNED2X		equ	9
D3DTOP_SUBTRACT			equ	10
D3DTOP_ADDSMOOTH		equ	11
D3DTOP_BLENDDIFFUSEALPHA	equ	12
D3DTOP_BLENDTEXTUREALPHA	equ	13
D3DTOP_BLENDFACTORALPHA		equ	14
D3DTOP_BLENDTEXTUREALPHAPM	equ	15
D3DTOP_BLENDCURRENTALPHA	equ	16
D3DTOP_PREMODULATE		equ	17
D3DTOP_MODULATEALPHA_ADDCOLOR	equ	18
D3DTOP_MODULATECOLOR_ADDALPHA	equ	19
D3DTOP_MODULATEINVALPHA_ADDCOLOR equ	20
D3DTOP_MODULATEINVCOLOR_ADDALPHA equ	21
D3DTOP_BUMPENVMAP		equ	22
D3DTOP_BUMPENVMAPLUMINANCE	equ	23
D3DTOP_DOTPRODUCT3		equ	24
D3DTOP_MULTIPLYADD		equ	25
D3DTOP_LERP			equ	26
D3DTSS_COLOROP			equ	1
D3DTSS_COLORARG1		equ	2
D3DTSS_COLORARG2		equ	3
D3DTSS_ALPHAOP			equ	4
D3DTSS_ALPHAARG1		equ	5
D3DTSS_ALPHAARG2		equ	6
D3DTSS_BUMPENVMAT00		equ	7
D3DTSS_BUMPENVMAT01		equ	8
D3DTSS_BUMPENVMAT10		equ	9
D3DTSS_BUMPENVMAT11		equ	10
D3DTSS_TEXCOORDINDEX		equ	11
D3DTSS_ADDRESSU			equ	13
D3DTSS_ADDRESSV			equ	14
D3DTSS_BORDERCOLOR		equ	15
D3DTSS_MAGFILTER		equ	16
D3DTSS_MINFILTER		equ	17
D3DTSS_MIPFILTER		equ	18
D3DTSS_MIPMAPLODBIAS		equ	19
D3DTSS_MAXMIPLEVEL		equ	20
D3DTSS_MAXANISOTROPY		equ	21
D3DTSS_BUMPENVLSCALE		equ	22
D3DTSS_BUMPENVLOFFSET		equ	23
D3DTSS_TEXTURETRANSFORMFLAGS	equ	24
D3DTSS_ADDRESSW			equ	25
D3DTSS_COLORARG0		equ	26
D3DTSS_ALPHAARG0		equ	27
D3DTSS_RESULTARG		equ	28
D3DTA_SELECTMASK		equ	00000000fh
D3DTA_DIFFUSE			equ	000000000h
D3DTA_CURRENT			equ	000000001h
D3DTA_TEXTURE			equ	000000002h
D3DTA_TFACTOR			equ	000000003h
D3DTA_SPECULAR			equ	000000004h
D3DTA_TEMP			equ	000000005h
D3DTA_COMPLEMENT		equ	000000010h
D3DTA_ALPHAREPLICATE		equ	000000020h
D3DBLEND_ZERO			equ	1
D3DBLEND_ONE			equ	2
D3DBLEND_SRCCOLOR		equ	3
D3DBLEND_INVSRCCOLOR		equ	4
D3DBLEND_SRCALPHA		equ	5
D3DBLEND_INVSRCALPHA		equ	6
D3DBLEND_DESTALPHA		equ	7
D3DBLEND_INVDESTALPHA		equ	8
D3DBLEND_DESTCOLOR		equ	9
D3DBLEND_INVDESTCOLOR		equ	10
D3DBLEND_SRCALPHASAT		equ	11
D3DBLEND_BOTHSRCALPHA		equ	12
D3DBLEND_BOTHINVSRCALPHA	equ	13
D3DCMP_NEVER			equ	1
D3DCMP_LESS			equ	2
D3DCMP_EQUAL			equ	3
D3DCMP_LESSEQUAL		equ	4
D3DCMP_GREATER			equ	5
D3DCMP_NOTEQUAL			equ	6
D3DCMP_GREATEREQUAL		equ	7
D3DCMP_ALWAYS			equ	8
D3DBACKBUFFER_TYPE_MONO		equ	0
D3DLOCK_READONLY		equ	000000010h
D3DLOCK_DISCARD			equ	000002000h
D3DLOCK_NOOVERWRITE		equ	000001000h
D3DLOCK_NOSYSLOCK		equ	000000800h
D3DLOCK_NO_DIRTY_UPDATE		equ	000008000h
D3DPRESENTFLAG_LOCKABLE_BACKBUFFER equ	000000001h
D3DCURSOR_IMMEDIATE_UPDATE	equ	000000001h
D3DPOOL_DEFAULT			equ	0
D3DPOOL_MANAGED			equ	1
D3DPOOL_SYSTEMMEM		equ	2
D3DPOOL_SCRATCH			equ	3
D3DPOOL_FORCE_DWORD		equ	07fffffffh

D3DTSS_TCI_PASSTHRU		equ	000000000h
D3DTSS_TCI_CAMERASPACENORMAL	equ	000010000h
D3DTSS_TCI_CAMERASPACEPOSITION	equ	000020000h
D3DTSS_TCI_CAMERASPACEREFLECTIONVECTOR	equ	000030000h
D3DTSS_TCI_SPHEREMAP		equ	000040000h

D3DVSD_TOKEN_NOP		equ	0
D3DVSD_TOKEN_STREAM		equ	1
D3DVSD_TOKEN_STREAMDATA		equ	2
D3DVSD_TOKEN_TESSELLATOR	equ	3
D3DVSD_TOKEN_CONSTMEM		equ	4
D3DVSD_TOKEN_EXT		equ	5
D3DVSD_TOKEN_END		equ	7
D3DVSD_FORCE_DWORD		equ	07fffffffh

D3DVSD_END			equ	0FFFFFFFFh
D3DVSD_NOP			equ	000000000h
D3DVSDT_FLOAT1			equ	000h		; 1D float expanded to (value, 0., 0., 1.)
D3DVSDT_FLOAT2			equ	001h		; 2D float expanded to (value, value, 0., 1.)
D3DVSDT_FLOAT3			equ	002h		; 3D float expanded to (value, value, value, 1.)
D3DVSDT_FLOAT4			equ	003h		; 4D float
D3DVSDT_D3DCOLOR		equ	004h		; 4D packed unsigned bytes mapped to 0. to 1. range
D3DVSDT_UBYTE4			equ	005h    	; 4D unsigned byte
D3DVSDT_SHORT2			equ	006h    	; 2D signed short expanded to (value, value, 0., 1.)
D3DVSDT_SHORT4			equ	007h		; 4D signed short
D3DVSDE_POSITION		equ	0
D3DVSDE_BLENDWEIGHT		equ	1
D3DVSDE_BLENDINDICES		equ	2
D3DVSDE_NORMAL			equ	3
D3DVSDE_PSIZE			equ	4
D3DVSDE_DIFFUSE			equ	5
D3DVSDE_SPECULAR		equ	6
D3DVSDE_TEXCOORD0		equ	7
D3DVSDE_TEXCOORD1		equ	8
D3DVSDE_TEXCOORD2		equ	9
D3DVSDE_TEXCOORD3		equ	10
D3DVSDE_TEXCOORD4		equ	11
D3DVSDE_TEXCOORD5		equ	12
D3DVSDE_TEXCOORD6		equ	13
D3DVSDE_TEXCOORD7		equ	14
D3DVSDE_POSITION2		equ	15
D3DVSDE_NORMAL2			equ	16
D3DDP_MAXTEXCOORD		equ	8

D3DPRESENT_PARAMETERS struct
BackBufferWidth			dd	?
BackBufferHeight		dd	?
BackBufferFormat		dd	?
BackBufferCount			dd	?
MultiSampleType			dd	?
MultiSampleQuality		dd	?
SwapEffect			dd	?
hDeviceWindow			dd	?
Windowed			dd	?
EnableAutoDepthStencil		dd	?
AutoDepthStencilFormat		dd	?
Flags	    			dd	?
; Following elements must be zero for Windowed mode
FullScreen_RefreshRateInHz	dd	?
FullScreen_PresentationInterval dd	?
D3DPRESENT_PARAMETERS ends

IDirect3D9 struct
; IUnknown methods
QueryInterface			dd	?
AddRef				dd	?
Release				dd	?
; IDirect3D9 methods
RegisterSoftwareDevice		dd	?
GetAdapterCount			dd	?
GetAdapterIdentifier		dd	?
GetAdapterModeCount		dd	?
EnumAdapterModes		dd	?
GetAdapterDisplayMode		dd	?
CheckDeviceType			dd	?
CheckDeviceFormat		dd	?
CheckDeviceMultiSampleType	dd	?
CheckDepthStencilMatch		dd	?
CheckDeviceFormatConversion	dd	?
GetDeviceCaps			dd	?
GetAdapterMonitor		dd	?
CreateDevice			dd	?
IDirect3D9 ends

IDirect3DDevice9 struct
; IUnknown methods
QueryInterface			dd	?
AddRef				dd	?
Release				dd	?
; IDirect3DDevice9 methods
TestCooperativeLevel		dd	?
GetAvailableTextureMem		dd	?
EvictManagedResources		dd	?
GetDirect3D			dd	?
GetDeviceCaps			dd	?
GetDisplayMode			dd	?
GetCreationParameters		dd	?
SetCursorProperties		dd	?
SetCursorPosition		dd	?
ShowCursor			dd	?
CreateAdditionalSwapChain	dd	?
GetSwapChain			dd	?
GetNumberOfSwapChains		dd	?
Reset				dd	?
Present				dd	?
GetBackBuffer			dd	?
GetRasterStatus			dd	?
SetDialogBoxMode		dd	?		; 20
SetGammaRamp			dd	?
GetGammaRamp			dd	?
CreateTexture			dd	?
CreateVolumeTexture		dd	?
CreateCubeTexture		dd	?
CreateVertexBuffer		dd	?		; 27
CreateIndexBuffer		dd	?		; 28
CreateRenderTarget		dd	?
CreateDepthStencilSurface	dd	?
UpdateSurface			dd	?
UpdateTexture			dd	?
GetRenderTargetData		dd	?
GetFrontBufferData		dd	?
StretchRect			dd	?
ColorFill			dd	?
CreateOffscreenPlainSurface	dd	?
SetRenderTarget			dd	?
GetRenderTarget			dd	?
SetDepthStencilSurface		dd	?
GetDepthStencilSurface		dd	?
BeginScene			dd	?
EndScene			dd	?
_Clear				dd	?
SetTransform			dd	?
GetTransform			dd	?
MultiplyTransform		dd	?
SetViewport			dd	?
GetViewport			dd	?
SetMaterial			dd	?
GetMaterial			dd	?		; 50
SetLight			dd	?
GetLight			dd	?
LightEnable			dd	?
GetLightEnable			dd	?
SetClipPlane			dd	?
GetClipPlane			dd	?
SetRenderState			dd	?
GetRenderState			dd	?
CreateStateBlock		dd	?
BeginStateBlock			dd	?
EndStateBlock			dd	?
SetClipStatus			dd	?
GetClipStatus			dd	?
GetTexture			dd	?
SetTexture			dd	?
GetTextureStageState		dd	?
SetTextureStageState		dd	?
GetSamplerState			dd	?
SetSamplerState			dd	?
ValidateDevice			dd	?
SetPaletteEntries		dd	?
GetPaletteEntries		dd	?
SetCurrentTexturePalette	dd	?
GetCurrentTexturePalette	dd	?
SetScissorRect			dd	?
GetScissorRect			dd	?
SetSoftwareVertexProcessing	dd	?
GetSoftwareVertexProcessing	dd	?
SetNPatchMode			dd	?
GetNPatchMode			dd	?
DrawPrimitive			dd	?
DrawIndexedPrimitive		dd	?
DrawPrimitiveUP			dd	?
DrawIndexedPrimitiveUP		dd	?
ProcessVertices			dd	?
CreateVertexDeclaration		dd	?
SetVertexDeclaration		dd	?
GetVertexDeclaration		dd	?
SetFVF				dd	?
GetFVF				dd	?
CreateVertexShader		dd	?
SetVertexShader			dd	?
GetVertexShader			dd	?
SetVertexShaderConstantF	dd	?
GetVertexShaderConstantF	dd	?
SetVertexShaderConstantI	dd	?
GetVertexShaderConstantI	dd	?
SetVertexShaderConstantB	dd	?
GetVertexShaderConstantB	dd	?
SetStreamSource			dd	?		; 100
GetStreamSource			dd	?
SetStreamSourceFreq		dd	?
GetStreamSourceFreq		dd	?
SetIndices			dd	?
GetIndices			dd	?
CreatePixelShader		dd	?
SetPixelShader			dd	?
GetPixelShader			dd	?
SetPixelShaderConstantF		dd	?
GetPixelShaderConstantF		dd	?
SetPixelShaderConstantI		dd	?
GetPixelShaderConstantI		dd	?
SetPixelShaderConstantB		dd	?
GetPixelShaderConstantB		dd	?
DrawRectPatch			dd	?
DrawTriPatch			dd	?
DeletePatch			dd	?
CreateQuery			dd	?		; 118
IDirect3DDevice9 ends

D3DMATRIX struct
_11				dd	?
_12				dd	?
_13				dd	?
_14				dd	?
_21				dd	?
_22				dd	?
_23				dd	?
_24				dd	?
_31				dd	?
_32				dd	?
_33				dd	?
_34				dd	?
_41				dd	?
_42				dd	?
_43				dd	?
_44				dd	?
D3DMATRIX ends

IDirect3DVertexBuffer9 struct
; IUnknown methods
QueryInterface			dd	?
AddRef				dd	?
Release				dd	?
; IDirect3DResource9 methods
GetDevice			dd	?
SetPrivateData			dd	?
GetPrivateData			dd	?
FreePrivateData			dd	?
SetPriority			dd	?
GetPriority			dd	?
PreLoad				dd	?
GetType				dd	?
_Lock				dd	?
Unlock				dd	?
GetDesc				dd	?
IDirect3DVertexBuffer9 ends

IDirect3DIndexBuffer9 struct
; IUnknown methods
QueryInterface			dd	?
AddRef				dd	?
Release				dd	?
; IDirect3DResource9 methods
GetDevice			dd	?
SetPrivateData			dd	?
GetPrivateData			dd	?
FreePrivateData			dd	?
SetPriority			dd	?
GetPriority			dd	?
PreLoad				dd	?
GetType				dd	?
_Lock				dd	?
Unlock				dd	?
GetDesc				dd	?
IDirect3DIndexBuffer9 ends

IDirect3DTexture9 struct
; IUnknown methods
QueryInterface			dd	?
AddRef				dd	?
Release				dd	?
; IDirect3DBaseTexture9 methods
GetDevice			dd	?
SetPrivateData			dd	?
GetPrivateData			dd	?
FreePrivateData			dd	?
SetPriority			dd	?
GetPriority			dd	?
PreLoad				dd	?
GetType				dd	?
SetLOD				dd	?
GetLOD				dd	?
GetLevelCount			dd	?
SetAutoGenFilterType		dd	?
GetAutoGenFilterType		dd	?
GenerateMipSubLevels		dd	?
GetLevelDesc			dd	?
GetSurfaceLevel			dd	?
LockRect			dd	?
UnlockRect			dd	?
AddDirtyRect			dd	?
IDirect3DTexture9 ends

IDirect3DSurface9 struct
; IUnknown methods
QueryInterface			dd	?
AddRef				dd	?
Release				dd	?
; IDirect3DSurface8 methods
GetDevice			dd	?
SetPrivateData			dd	?
GetPrivateData			dd	?
FreePrivateData			dd	?
GetContainer			dd	?
GetDesc				dd	?
LockRect			dd	?
UnlockRect			dd	?
IDirect3DSurface9 ends

ID3DXMesh struct
; IUnknown
QueryInterface			dd	?
AddRef				dd	?
Release				dd	?
; ID3DXBaseMesh
DrawSubset			dd	?
GetNumFaces			dd	?
GetNumVertices			dd	?
GetFVF				dd	?
GetDeclaration			dd	?
GetNumBytesPerVertex		dd	?
GetOptions			dd	?
GetDevice			dd	?
CloneMeshFVF			dd	?
CloneMesh			dd	?
GetVertexBuffer			dd	?
GetIndexBuffer			dd	?
LockVertexBuffer		dd	?
UnlockVertexBuffer		dd	?
LockIndexBuffer			dd	?
UnlockIndexBuffer		dd	?
GetAttributeTable		dd	?
ConvertPointRepsToAdjacency	dd	?
ConvertAdjacencyToPointReps	dd	?
GenerateAdjacency		dd	?
UpdateSemantics			dd	?
; ID3DXMesh
LockAttributeBuffer		dd	?
UnlockAttributeBuffer		dd	?
Optimize			dd	?
OptimizeInplace			dd	?
SetAttributeTable		dd	?
ID3DXMesh ends

ID3DXConstantTable struct
; IUnknown
QueryInterface			dd	?
AddRef				dd	?
Release				dd	?
; Buffer
GetBufferPointer		dd	?
GetBufferSize			dd	?
ID3DXConstantTable ends

D3DCOLORVALUE struct
r				dd	?
g				dd	?
b				dd	?
a				dd	?
D3DCOLORVALUE ends

D3DMATERIAL9 struct
Diffuse_r			real4	?
Diffuse_g			real4	?
Diffuse_b			real4	?
Diffuse_a			real4	?
Ambient_r			real4	?
Ambient_g			real4	?
Ambient_b			real4	?
Ambient_a			real4	?
Specular_r			real4	?
Specular_g			real4	?
Specular_b			real4	?
Specular_a			real4	?
Emissive_r			real4	?
Emissive_g			real4	?
Emissive_b			real4	?
Emissive_a			real4	?
Power				real4	?
D3DMATERIAL9 ends

D3DLIGHT9 struct
_Type				dd	?
Diffuse_r			real4	?
Diffuse_g			real4	?
Diffuse_b			real4	?
Diffuse_a			real4	?
Specular_r			real4	?
Specular_g			real4	?
Specular_b			real4	?
Specular_a			real4	?
Ambient_r			real4	?
Ambient_g			real4	?
Ambient_b			real4	?
Ambient_a			real4	?
Position_x			real4	?
Position_y			real4	?
Position_z			real4	?
Direction_x			real4	?
Direction_y			real4	?
Direction_z			real4	?
Range				real4	?
Falloff				real4	?
Attenuation0			real4	?
Attenuation1			real4	?
Attenuation2			real4	?
Theta				real4	?
Phi				real4	?
D3DLIGHT9 ends

D3DLOCKED_RECT struct
Pitch				dd	?
pBits				dd	?
D3DLOCKED_RECT ends

VERTEX				struct
x				real4	?
y				real4	?
z				real4	?
VERTEX				ends
LPVERTEX			typedef ptr VERTEX
				
Direct3DCreate9			proto	:dword
