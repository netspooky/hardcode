; ddraw.inc for MASM32 by Tbyte
;
; This include file does not contain all definitions,
; because it is not necessary for this intro.
;
; For more information, see ddraw.h.

; DirectDraw SetCooperativeLevel flags
DDSCL_FULLSCREEN		equ	1
DDSCL_ALLOWREBOOT		equ	2
DDSCL_NOWINDOWCHANGES		equ	4
DDSCL_NORMAL			equ	8
DDSCL_EXCLUSIVE			equ	10h
DDSCL_ALLOWMODEX		equ	40h
DDSCL_SETFOCUSWINDOW		equ	80h
DDSCL_SETDEVICEWINDOW		equ	100h
DDSCL_CREATEDEVICEWINDOW	equ	200h
DDSCL_MULTITHREADED		equ	400h
DDSCL_FPUSETUP			equ	800h
DDSCL_FPUPRESERVE		equ	1000h

; DDSURFACEDESC2 flags
DDSD_CAPS		equ	1
DDSD_HEIGHT		equ	2
DDSD_WIDTH		equ	4
DDSD_PITCH		equ	8
DDSD_BACKBUFFERCOUNT	equ	20h
DDSD_ZBUFFERBITDEPTH	equ	40h
DDSD_ALPHABITDEPTH	equ	80h
DDSD_LPSURFACE		equ	800h
DDSD_PIXELFORMAT	equ	1000h
DDSD_CKDESTOVERLAY	equ	2000h
DDSD_CKDESTBLT		equ	4000h
DDSD_CKSRCOVERLAY	equ	8000h
DDSD_CKSRCBLT		equ	10000h
DDSD_MIPMAPCOUNT	equ	20000h
DDSD_REFRESHRATE	equ	40000h
DDSD_LINEARSIZE		equ	80000h
DDSD_TEXTURESTAGE	equ	100000h
DDSD_FVF		equ	200000h
DDSD_SRCVBHANDLE	equ	400000h
DDSD_ALL		equ	7ff9eeh


; DirectDrawSurface capability flags
DDSCAPS_RESERVED1		equ	1
DDSCAPS_ALPHA			equ	2
DDSCAPS_BACKBUFFER		equ	4
DDSCAPS_COMPLEX			equ	8
DDSCAPS_FLIP			equ	10h
DDSCAPS_FRONTBUFFER		equ	20h
DDSCAPS_OFFSCREENPLAIN		equ	40h
DDSCAPS_OVERLAY			equ	80h
DDSCAPS_PALETTE			equ	100h
DDSCAPS_PRIMARYSURFACE		equ	200h
DDSCAPS_RESERVED3		equ	400h
DDSCAPS_PRIMARYSURFACELEFT	equ	0
DDSCAPS_SYSTEMMEMORY		equ	800h
DDSCAPS_TEXTURE			equ	1000h
DDSCAPS_3DDEVICE		equ	2000h
DDSCAPS_VIDEOMEMORY		equ	4000h
DDSCAPS_VISIBLE			equ	8000h
DDSCAPS_WRITEONLY		equ	10000h
DDSCAPS_ZBUFFER			equ	20000h
DDSCAPS_OWNDC			equ	40000h
DDSCAPS_LIVEVIDEO		equ	80000h
DDSCAPS_HWCODEC			equ	100000h
DDSCAPS_MODEX			equ	200000h
DDSCAPS_MIPMAP			equ	400000h
DDSCAPS_RESERVED2		equ	800000h
DDSCAPS_ALLOCONLOAD		equ	4000000h
DDSCAPS_VIDEOPORT		equ	8000000h
DDSCAPS_LOCALVIDMEM		equ	10000000h
DDSCAPS_NONLOCALVIDMEM		equ	020000000h
DDSCAPS_STANDARDVGAMODE		equ	40000000h
DDSCAPS_OPTIMIZED		equ	80000000h
DDSCAPS2_HARDWAREDEINTERLACE	equ	2
DDSCAPS2_HINTDYNAMIC		equ	4
DDSCAPS2_HINTSTATIC		equ	8
DDSCAPS2_TEXTUREMANAGE		equ	10
DDSCAPS2_RESERVED1		equ	20h
DDSCAPS2_RESERVED2		equ	40h
DDSCAPS2_OPAQUE			equ	80h
DDSCAPS2_HINTANTIALIASING	equ	100h
DDSCAPS2_CUBEMAP		equ	200h
DDSCAPS2_CUBEMAP_POSITIVEX	equ	400h
DDSCAPS2_CUBEMAP_NEGATIVEX	equ	800h
DDSCAPS2_CUBEMAP_POSITIVEY	equ	1000h
DDSCAPS2_CUBEMAP_NEGATIVEY	equ	2000h
DDSCAPS2_CUBEMAP_POSITIVEZ	equ	4000h
DDSCAPS2_CUBEMAP_NEGATIVEZ	equ	8000h
DDSCAPS2_CUBEMAP_ALLFACES	equ	0fc00h
DDSCAPS2_MIPMAPSUBLEVEL		equ	10000h
DDSCAPS2_D3DTEXTUREMANAGE	equ	20000h
DDSCAPS2_DONOTPERSIST		equ	40000h
DDSCAPS2_STEREOSURFACELEFT	equ	80000h

; DirectDrawSurface Lock flags
DDLOCK_SURFACEMEMORYPTR	equ	0
DDLOCK_WAIT		equ	1
DDLOCK_EVENT		equ	2
DDLOCK_READONLY		equ	10h
DDLOCK_WRITEONLY	equ	20h
DDLOCK_NOSYSLOCK	equ	800h
DDLOCK_NOOVERWRITE	equ	000h
DDLOCK_DISCARDCONTENTS	equ	2000h
DDLOCK_OKTOSWAP		equ	2000h
DDLOCK_DONOTWAIT	equ	4000h

; DirectDrawSurface Flip flags
DDFLIP_WAIT		equ	1
DDFLIP_EVEN		equ	2
DDFLIP_ODD		equ	4
DDFLIP_NOVSYNC		equ	8
DDFLIP_INTERVAL2	equ	2000000h
DDFLIP_INTERVAL3	equ	3000000h
DDFLIP_INTERVAL4	equ	4000000h
DDFLIP_STEREO		equ	10h
DDFLIP_DONOTWAIT	equ	20h

DDSCAPS2	struct

dwCaps		dword	?
dwCaps2		dword	?
dwCaps3		dword	?
dwCaps4		dword	?

DDSCAPS2	ends

DDPIXELFORMAT		struct

dwSize			dword	?
dwFlags			dword	?
dwFourCC		dword	?

			union

dwRGBBitCount		dword	?
dwYUVBitCount		dword	?
dwZBufferBitDepth	dword	?
dwAlphaBitDepth		dword	?
dwLuminanceBitCount	dword	?
dwBumpBitCount		dword	?

			ends

			union

dwRBitMask		dword	?
dwYBitMask		dword	?
dwStencilBitDepth	dword	?
dwLuminanceBitMask	dword	?
dwBumpDuBitMask		dword	?

			ends

			union

dwGBitMask     		dword	?
dwUBitMask     		dword	?
dwZBitMask     		dword	?
dwBumpDvBitMask		dword	?

			ends

			union

dwBBitMask		dword	?
dwVBitMask		dword	?
dwStencilBitMask	dword	?
dwBumpLuminanceBitMask	dword	?

			ends

			union

dwRGBAlphaBitMask	dword	?
dwYUVAlphaBitMask	dword	?
dwLuminanceAlphaBitMask	dword	?
dwRGBZBitMask		dword	?
dwYUVZBitMask		dword	?

			ends

DDPIXELFORMAT		ends

DDCOLORKEY		struct

dwColorSpaceLowValue	dword	?
dwColorSpaceHighValue	dword	?

DDCOLORKEY		ends

DDSURFACEDESC2		struct

dwSize			dword	?
dwFlags			dword	?
dwHeight		dword	?
dwWidth			dword	?

			union

lPitch			sdword	?
dwLinearSize		dword	?

			ends

dwBackBufferCount	dword	?

			union

dwMipMapCount		dword	?
dwRefreshRate		dword	?
dwSrcVBHandle		dword	?

			ends

dwAlphaBitDepth		dword	?
dwReserved		dword	?
lpSurface		dword	?

			union

ddckCKDestOverlay	DDCOLORKEY<>
dwEmptyFaceColor	dword	?

			ends

ddckCKDestBlt		DDCOLORKEY<>
ddckCKSrcOverlay	DDCOLORKEY<>
ddckCKSrcBlt		DDCOLORKEY<>

			union

ddpfPixelFormat		DDPIXELFORMAT<>
dwFVF			dword	?

			ends

ddsCaps			DDSCAPS2<>
dwTextureStage		dword	?

DDSURFACEDESC2		ends

; IDirectDraw methods
IDirectDraw7		struct

_QueryInterface		dword	?
_AddRef			dword	?
_Release		dword	?
_Compact		dword	?
_CreateClipper		dword	?
_CreatePalette		dword	?
_CreateSurface		dword	?
_DuplicateSurface	dword	?
_EnumDisplayModes	dword	?
_EnumSurfaces		dword	?
_FlipToGDISurface	dword	?
_GetCaps		dword	?
_GetDisplayMode		dword	?
_GetFourCCCodes		dword	?
_GetGDISurface		dword	?
_GetMonitorFrequency	dword	?
_GetScanLine		dword	?
_GetVerticalBlankStatus	dword	?
_Initialize		dword	?
_RestoreDisplayMode	dword	?
_SetCooperativeLevel	dword	?
_SetDisplayMode		dword	?
_WaitForVerticalBlank	dword	?
_GetAvailableVidMem	dword	?
_GetSurfaceFromDC	dword	?
_RestoreAllSurfaces	dword	?
_TestCooperativeLevel	dword	?
_GetDeviceIdentifier	dword	?
_StartModeTest		dword	?
_EvaluateMode		dword	?

IDirectDraw7		ends

; IDirectDrawSurface7 methods
IDirectDrawSurface7	struct

_QueryInterface		dword	?
_AddRef			dword	?
_Release		dword	?
_AddAttachedSurface	dword	?
_AddOverlayDirtyRect	dword	?
_Blt			dword	?
_BltBatch		dword	?
_BltFast		dword	?
_DeleteAttachedSurface	dword	?
_EnumAttachedSurfaces	dword	?
_EnumOverlayZOrders	dword	?
_Flip			dword	?
_GetAttachedSurface	dword	?
_GetBltStatus		dword	?
_GetCaps		dword	?
_GetClipper		dword	?
_GetColorKey		dword	?
_GetDC			dword	?
_GetFlipStatus		dword	?
_GetOverlayPosition	dword	?
_GetPalette		dword	?
_GetPixelFormat		dword	?
_GetSurfaceDesc		dword	?
_Initialize		dword	?
_IsLost			dword	?
_Lock			dword	?
_ReleaseDC		dword	?
_Restore		dword	?
_SetClipper		dword	?
_SetColorKey		dword	?
_SetOverlayPosition	dword	?
_SetPalette		dword	?
_Unlock			dword	?
_UpdateOverlay		dword	?
_UpdateOverlayDisplay	dword	?
_UpdateOverlayZOrder	dword	?
_GetDDInterface		dword	?
_PageLock		dword	?
_PageUnlock		dword	?
_SetSurfaceDesc		dword	?
_SetPrivateData		dword	?
_GetPrivateData		dword	?
_FreePrivateData	dword	?
_GetUniquenessValue	dword	?
_ChangeUniquenessValue	dword	?
_SetPriority		dword	?
_GetPriority		dword	?
_SetLOD			dword	?
_GetLOD			dword	?

IDirectDrawSurface7	ends

; ddraw.lib prototypes
D3DParseUnknownCommand	proto	:dword,:dword
DDGetAttachedSurfaceLcl	proto	:dword,:dword,:dword
DDHAL32_VidMemAlloc	proto	:dword,:dword,:dword,:dword
DDHAL32_VidMemFree	proto	:dword,:dword,:dword
DDInternalLock		proto	:dword,:dword
DDInternalUnlock	proto	:dword
DSoundHelp		proto	:dword,:dword,:dword
DirectDrawCreate	proto	:dword,:dword,:dword
DirectDrawCreateClipper	proto	:dword,:dword,:dword
DirectDrawCreateEx	proto	:dword,:dword,:dword,:dword
DirectDrawEnumerateA	proto	:dword,:dword
DirectDrawEnumerate	equ	<DirectDrawEnumerateA>
DirectDrawEnumerateExA	proto	:dword,:dword,:dword
DirectDrawEnumerateEx	equ	<DirectDrawEnumerateExA>
GetDDSurfaceLocal	proto	:dword,:dword,:dword
GetSurfaceFromDC	proto	:dword,:dword,:dword
HeapVidMemAllocAligned	proto	:dword,:dword,:dword,:dword,:dword
LateAllocateSurfaceMem	proto	:dword,:dword,:dword,:dword
VidMemAlloc		proto	:dword,:dword,:dword
VidMemAmountFree	proto	:dword
VidMemFini		proto	:dword
VidMemFree		proto	:dword,:dword
VidMemInit		proto	:dword,:dword,:dword,:dword,:dword
VidMemLargestFree	proto	:dword

