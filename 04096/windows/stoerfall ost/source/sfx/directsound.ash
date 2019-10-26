comment #+

    This is the source-release of "Stoerfall Ost", our winning 4kb
    multimedia presentation that was first shown at Dialogos 2000.
    If you have any questions concerning the sourcecode drop us a
    line at freestyle@freestylas.org. Feel free to visit our
    webpage at http://www.freestylas.org.
    Copyright (C) 2001 freestyle
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    
+#



IDirectSound_Release			equ 00000008h
IDirectSound_CreateSoundBuffer		equ 0000000Ch
IDirectSound_SetCooperativeLevel	equ 00000018h

IDirectSoundBuffer_Release		equ 00000008h
IDirectSoundBuffer_GetCurrentPosition	equ 00000010h
IDirectSoundBuffer_Lock			equ 0000002Ch
IDirectSoundBuffer_Play			equ 00000030h
IDirectSoundBuffer_Stop			equ 00000048h
IDirectSoundBuffer_Unlock		equ 0000004Ch

DSSCL_PRIORITY				equ 00000002h
DSBCAPS_GETCURRENTPOSITION2		equ 00010000h
DSBCAPS_GLOBALFOCUS			equ 00008000h
DSBPLAY_LOOPING				equ 00000001h

DSBUFFERDESC	struct
	dwSize		dd ?
	dwFlags		dd ?
	dwBufferBytes	dd ?
	dwReserved	dd ?
	lpwfxFormat	dd ?
DSBUFFERDESC	ends

tdsndData	struct
	playsnd		dd ?
	threadrunning	dd ?	
	samples		dd ?
	dsnd		dd ?
	dsndbuf		dd ?
	playpos		dd ?
	writepos	dd ?
	lastpos		dd ?
	mixcnt		dd ?
	bufptr1		dd ?
	buflen1		dd ?
	bufptr2		dd ?
	buflen2		dd ?
	ticks		dd ?
	spt		dd ?
tdsndData	ends


	.data

if LOW_SOUND
SAMPLERATE	= 22050
ONEoSampleRate	dd	0.000045351	; 1/22050
else
SAMPLERATE	= 44100
ONEoSampleRate	dd	0.000022675 	; 1/44100
endif

NUMCHANNELS	= 2
DSBUFSMPCNT	= ((SAMPLERATE/100)*16*NUMCHANNELS)
DSBUFFERSIZE	= (2*DSBUFSMPCNT)

wfx		WAVEFORMATEX <WAVE_FORMAT_PCM,NUMCHANNELS,SAMPLERATE,SAMPLERATE*2*NUMCHANNELS,2*NUMCHANNELS,16,0>
dsbd		DSBUFFERDESC <sizeof DSBUFFERDESC, \
			      DSBCAPS_GETCURRENTPOSITION2 or DSBCAPS_GLOBALFOCUS, \
			      DSBUFFERSIZE,0,offset wfx>

	.data?

dsndData	tdsndData <?>
threadbuf	db DSBUFFERSIZE+16 dup(?)
;mix_int		dd DSBUFSMPCNT+4 dup(?)


	.code

dsndThread	proc data:dword

if SAFE_CODE
	finit
endif
	fldcw	[cwTrunc]
	
	mov	ebx,offset dsndData
	
if SAFE_CODE	
	inc	byte ptr [ebx+tdsndData.threadrunning]
endif
	
	threadloop:
		push	10
		call	Sleep
		;invoke	 Sleep,10
		
		lea	eax,[ebx+tdsndData.writepos]
		push	eax
		;lea	eax,[ebx+tdsndData.playpos]
		add	eax,tdsndData.playpos-tdsndData.writepos
		push	eax
		mov	eax,[ebx+tdsndData.dsndbuf]
		mov	ecx,[eax]
		push	eax
		call	dword ptr [ecx+IDirectSoundBuffer_GetCurrentPosition]
		
		mov	eax,[ebx+tdsndData.playpos]
		sub	eax,[ebx+tdsndData.lastpos]
		jns	noinc
		add	eax,DSBUFFERSIZE
	noinc:
		mov	[ebx+tdsndData.mixcnt],eax

		;hier buffer füllen
		shr	eax,NUMCHANNELS
		jz	threadloop
		mov	ecx,eax
;		push	ecx
		
;		mov	edi,offset mix_int
;		push	edi
		mov	edi,offset threadbuf
		mov	esi,edi

		dsndMachineWork:

			dec	[ebx+tdsndData.spt]
			jns	no_tick_inc

			pushad
			mov	edi,[ebx+tdsndData.samples]
			call	scptRun
			mov	eax,[ebx+tdsndData.ticks]	;samplecount
			call	seProceedPattern
			popad

			mov	[ebx+tdsndData.spt],SE_SPT-1
			inc	[ebx+tdsndData.ticks]

		no_tick_inc:

			pushad

atsc			
			call	[seCodePtr]
			;call	eax
etsc

			mov	edi,(offset script_dword) + trigger_bd*4			
			;mov	ecx,7*4
			push	SE_NUM_PATTERN*4
			pop	ecx
			xor	eax,eax
			rep	stosb

			if	SE_MASTER_HACK
			else
			fld	[seOutputRight]
			fld	[seOutputLeft]			
			endif
			
			popad

;			fldz
;			fldz
			;fmulp	st(1),st(0)

			fmul	[script_dword+19*4]			
			fistp	word ptr [edi]			;left  channel
			fmul	[script_dword+19*4]			
			fistp	word ptr [edi+2]		;right channel

			inc	[ebx+tdsndData.samples]

			add	edi,NUMCHANNELS*2
		if	DEBUG
		dec	ecx
		jnz	dsndMachineWork
		else
		loop	dsndMachineWork
		endif

		;push	0
		push	ecx

		lea	eax,[ebx+tdsndData.buflen2]
		push	eax
		sub	eax,4
		push	eax
		sub	eax,4
		push	eax
		sub	eax,4
		push	eax

comment #+
		push	offset len2
		push	offset data2
		push	offset len1
		push	offset data1
+#
		push	[ebx+tdsndData.mixcnt]
		push	[ebx+tdsndData.lastpos]
		mov	eax,[ebx+tdsndData.dsndbuf]
		mov	ecx,[eax]
		push	eax
		call	dword ptr [ecx+IDirectSoundBuffer_Lock]

		; hier buffer in dsoundbuffer kopieren
		;mov	esi,offset threadbuf
		;mov	edi,[data1]
		;mov	ecx,[len1]
		mov	edi,[ebx+tdsndData.bufptr1]
		mov	ecx,[ebx+tdsndData.buflen1]
		rep	movsb

		;mov	edi,[data2]
		;mov	ecx,[len2]
		mov	edi,[ebx+tdsndData.bufptr2]
		or	ecx,[ebx+tdsndData.buflen2]
		;mov	ecx,[ebx+tdsndData.buflen2]
		;or	ecx,ecx
		jz	nosecondcopy
			rep	movsb
		nosecondcopy:

		;mov	ecx,offset data1
		;push	[ecx+12]
		;push	[ecx+8]
		;push	[ecx+4]
		;push	[ecx]
		push	[ebx+tdsndData.buflen2]
		push	[ebx+tdsndData.bufptr2]
		push	[ebx+tdsndData.buflen1]
		push	[ebx+tdsndData.bufptr1]
		mov	eax,[ebx+tdsndData.dsndbuf]
		mov	ecx,[eax]
		push	eax
		call	dword ptr [ecx+IDirectSoundBuffer_Unlock]

		mov	eax,[ebx+tdsndData.playpos]
		mov	[ebx+tdsndData.lastpos],eax

	cmp	byte ptr [ebx+tdsndData.playsnd],0
	jnz	threadloop

if SAFE_CODE
	dec	[ebx+tdsndData.threadrunning]
endif

	ret
dsndThread	endp

; in	esi = windowhandle
dsndInit	macro	;proc near
	pusha

	mov	ebp,offset dsndData

	push	NULL
	lea	eax,[ebp+tdsndData.dsnd]
	push	eax
	push	NULL
	call	dword ptr [ebx+impDirectSoundCreate]
	;invoke	DirectSoundCreate, NULL,addr dsnd,NULL
if SAFE_CODE
	or	eax,eax
	jnz	done
endif

	push	DSSCL_PRIORITY
	;push	[hwndMain]
	push	esi	; windowhandle
	mov	esi,[ebp+tdsndData.dsnd]
	mov	edi,[esi]
	push	esi
	call	dword ptr [edi+IDirectSound_SetCooperativeLevel]
if SAFE_CODE
	or	eax,eax
	jnz	release_dsnd
endif

	push	eax
	lea	eax,[ebp+tdsndData.dsndbuf]
	push	eax
	push	offset dsbd
	;mov	esi,[dsnd]
	;mov	edi,[esi]
	push	esi
	call	dword ptr [edi+IDirectSound_CreateSoundBuffer]
if SAFE_CODE
	or	eax,eax
	jnz	release_dsnd
endif

	;xor	esi,esi			; esi = NULL  bzw.  esi = 0

	push	DSBPLAY_LOOPING
	push	eax	;0
	push	eax	;0
	mov	eax,[ebp+tdsndData.dsndbuf]
	mov	ecx,[eax]
	push	eax
	call	dword ptr [ecx+IDirectSoundBuffer_Play]
if SAFE_CODE
	or	eax,eax
	jnz	release_dsnd
endif

	inc	byte ptr [ebp+tdsndData.playsnd]

	lea	esi,[ebp+tdsndData.buflen2]
	push	esi		; pointer zum speichern der threadid
	push	eax	;0
	push	eax	;NULL
	push	offset dsndThread
	push	120 	;vorher 65536
	push	eax	;NULL
	call	CreateThread
	;invoke	 CreateThread, NULL,65536,addr dsndThread,NULL,0,addr threadid
if SAFE_CODE
	or	eax,eax
	jz	dsndDeinit
endif

	;push	THREAD_PRIORITY_HIGHEST
	;push	eax
	;call	SetThreadPriority
	;invoke	 SetThreadPriority, threadhnd,THREAD_PRIORITY_HIGHEST

done:
	popa
	;ret
endm ;dsndInit	endp

if SAFE_CODE
dsndDeinit	proc near
	pusha

	mov	ebp,offset dsndData
	cmp	byte ptr [ebp+tdsndData.playsnd],0
	je	release_done

		dec	byte ptr [ebp+tdsndData.playsnd]

release_thread_loop:
		cmp	byte ptr [ebp+tdsndData.threadrunning],0
		jne	release_thread_loop

release_dsnd::
		mov	eax,[ebp+tdsndData.dsnd]
		mov	ecx,[eax]
		push	eax
		call	dword ptr [ecx+IDirectSound_Release]
release_done:
	popa
	ret
dsndDeinit	endp
endif
