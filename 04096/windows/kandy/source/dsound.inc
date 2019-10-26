; dsound.inc - NASM-compatible include file for Microsoft DirectX 8.1.
;
; *** PLEASE NOTE: THIS FILE IS INCOMPLETE. To Be completed at a later
; 	date; if desired.  This file gives the 4kb intro from the 
;	Northern Dragons enough for it's audio functions ***
; 
; Please see S_Tec's d3d8.inc for usage, and details.
;
; Coded by:
;	Polaris of Northern Dragons
;	polaris@northerndragons.ca
;
; Revision History:
;	Coder:	| Description:						| #:
;	Polaris	| First Cut						| 1
;

%ifndef dsound_inc_included
%define dsound_inc_included

;-----------------------------------------------------------------------------
; Constants:
;-----------------------------------------------------------------------------
DSCAPS_PRIMARYMONO			EQU	000000001h
DSCAPS_PRIMARYSTEREO			EQU	000000002h
DSCAPS_PRIMARY8BIT			EQU	000000004h
DSCAPS_PRIMARY16BIT			EQU	000000008h
DSCAPS_CONTINUOUSRATE			EQU	000000010h
DSCAPS_EMULDRIVER			EQU	000000020h
DSCAPS_CERTIFIED			EQU	000000040h
DSCAPS_SECONDARYMONO			EQU	000000100h
DSCAPS_SECONDARYSTEREO			EQU	000000200h
DSCAPS_SECONDARY8BIT			EQU	000000400h
DSCAPS_SECONDARY16BIT			EQU	000000800h

DSSCL_NORMAL				EQU	000000001h
DSSCL_PRIORITY				EQU	000000002h
DSSCL_EXCLUSIVE				EQU	000000003h
DSSCL_WRITEPRIMARY			EQU	000000004h

DSSPEAKER_DIRECTOUT			EQU	000000000h
DSSPEAKER_HEADPHONE			EQU	000000001h
DSSPEAKER_MONO				EQU	000000002h
DSSPEAKER_QUAD				EQU	000000003h
DSSPEAKER_STEREO			EQU	000000004h
DSSPEAKER_SURROUND			EQU	000000005h
DSSPEAKER_5POINT1			EQU	000000006h
DSSPEAKER_7POINT1			EQU	000000007h

DSSPEAKER_GEOMETRY_MIN			EQU	000000005h	  ;    5 degrees
DSSPEAKER_GEOMETRY_NARROW		EQU	00000000Ah	  ;   10 degrees
DSSPEAKER_GEOMETRY_WIDE			EQU	000000014h	  ;   20 degrees
DSSPEAKER_GEOMETRY_MAX			EQU	0000000B4h	  ; 180 degrees

DSBCAPS_PRIMARYBUFFER			EQU	000000001h
DSBCAPS_STATIC				EQU	000000002h
DSBCAPS_LOCHARDWARE			EQU	000000004h
DSBCAPS_LOCSOFTWARE			EQU	000000008h
DSBCAPS_CTRL3D				EQU	000000010h
DSBCAPS_CTRLFREQUENCY			EQU	000000020h
DSBCAPS_CTRLPAN				EQU	000000040h
DSBCAPS_CTRLVOLUME			EQU	000000080h
DSBCAPS_CTRLPOSITIONNOTIFY		EQU	000000100h
DSBCAPS_CTRLFX				EQU	000000200h
DSBCAPS_STICKYFOCUS			EQU	000004000h
DSBCAPS_GLOBALFOCUS			EQU	000008000h
DSBCAPS_GETCURRENTPOSITION2		EQU	000010000h
DSBCAPS_MUTE3DATMAXDISTANCE		EQU	000020000h
DSBCAPS_LOCDEFER			EQU	000040000h

DSBPLAY_LOOPING				EQU	000000001h
DSBPLAY_LOCHARDWARE			EQU	000000002h
DSBPLAY_LOCSOFTWARE			EQU	000000004h
DSBPLAY_TERMINATEBY_TIME		EQU	000000008h
DSBPLAY_TERMINATEBY_DISTANCE		EQU	0000000010h
DSBPLAY_TERMINATEBY_PRIORITY		EQU	0000000020h

DSBSTATUS_PLAYING			EQU	000000001h
DSBSTATUS_BUFFERLOST			EQU	000000002h
DSBSTATUS_LOOPING			EQU	000000004h
DSBSTATUS_LOCHARDWARE			EQU	000000008h
DSBSTATUS_LOCSOFTWARE			EQU	000000010h
DSBSTATUS_TERMINATED			EQU	000000020h

DSBLOCK_FROMWRITECURSOR			EQU	000000001h
DSBLOCK_ENTIREBUFFER			EQU	000000002h

DSBFREQUENCY_MIN			EQU	100
DSBFREQUENCY_MAX			EQU	100000
DSBFREQUENCY_ORIGINAL			EQU	0

DSBPAN_LEFT				EQU	-10000
DSBPAN_CENTER				EQU	0
DSBPAN_RIGHT				EQU	10000

DSBVOLUME_MIN				EQU	-10000
DSBVOLUME_MAX				EQU	0

DSBSIZE_MIN				EQU	4
DSBSIZE_MAX				EQU	00FFFFFFFh
DSBSIZE_FX_MIN				EQU	150  ;  NOTE: Milliseconds, not bytes

DS3DMODE_NORMAL				EQU	000000000h
DS3DMODE_HEADRELATIVE			EQU	000000001h
DS3DMODE_DISABLE			EQU	000000002h

DS3D_IMMEDIATE				EQU	000000000h
DS3D_DEFERRED				EQU	000000001h

;-----------------------------------------------------------------------------
; Interfaces (with full name prefixes):
;-----------------------------------------------------------------------------
IDirectSound8_SetCooperativeLevel 		equ 00000018h
IDirectSound8_CreateSoundBuffer	  		equ 0000000Ch
IDirectSoundFXWavesReverb_SetAllParameters 	equ 0000000Ch
IDirectSoundBuffer_Play				equ 00000030h


IDirectSoundBuffer8_QueryInterface			EQU	0x00000000
IDirectSoundBuffer8_AddRef				EQU	0x00000004
IDirectSoundBuffer8_Release				EQU	0x00000008
IDirectSoundBuffer8_GetCaps				EQU	0x0000000C
IDirectSoundBuffer8_GetCurrentPosition			EQU	0x00000010
IDirectSoundBuffer8_GetFormat				EQU	0x00000014
IDirectSoundBuffer8_GetVolume				EQU	0x00000018
IDirectSoundBuffer8_GetPan				EQU	0x0000001C
IDirectSoundBuffer8_GetFrequency			EQU	0x00000020
IDirectSoundBuffer8_GetStatus				EQU	0x00000024
IDirectSoundBuffer8_Initialize				EQU	0x00000028
IDirectSoundBuffer8_Lock				EQU	0x0000002C
IDirectSoundBuffer8_Play				EQU	0x00000030
IDirectSoundBuffer8_SetCurrentPosition			EQU	0x00000034
IDirectSoundBuffer8_SetFormat				EQU	0x00000038
IDirectSoundBuffer8_SetVolume				EQU	0x0000003C
IDirectSoundBuffer8_SetPan				EQU	0x00000040
IDirectSoundBuffer8_SetFrequency			EQU	0x00000044
IDirectSoundBuffer8_Stop				EQU	0x00000048
IDirectSoundBuffer8_Unlock				EQU	0x0000004C
IDirectSoundBuffer8_Restore				EQU	0x00000050
IDirectSoundBuffer8_SetFX				EQU	0x00000054
IDirectSoundBuffer8_AcquireResources			EQU	0x00000058
IDirectSoundBuffer8_GetObjectInPath			EQU	0x0000005C

;-----------------------------------------------------------------------------
; Structures:
;-----------------------------------------------------------------------------

				struc	DSEFFECTDESC
.dwSize:			resd	1
.dwFlags:			resd	1
.guidDSFXClass:			resb	16
.dwReserved1:			resd	1
.dwReserved2:			resd	1
				endstruc

				struc	DSBUFFERDESC
dwSize:				resd	1
dwFlags:			resd	1
dwBufferBytes:			resd	1
dwReserved:			resd	1
lpwfxFormat:			resd	1
guid3DAlgorithm:		resb	16
				endstruc

;-----------------------------------------------------------------------------
; GUID's:
;-----------------------------------------------------------------------------

%define GUID_DSFX_WAVES_REVERB	0x68,0x02,0xFC,0x87,0x55,0x9A,0x60,0x43,\
				0x95,0xAA,0x00,0x4A,0x1D,0x9D,0xE2,0x6C

%define IID_IDirectSoundFXWavesReverb8 \
				0x3A,0x8C,0x85,0x46,0xC6,0x0D,0xE3,0x45,\
				0xB7,0x60,0xD4,0xEE,0xF1,0x6C,0xB3,0x25
%ifndef GUID_NULL
%define GUID_NULL		0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,\
				0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
%endif

%endif