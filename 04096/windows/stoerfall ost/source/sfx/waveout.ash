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

tdsndData	struct
	playsnd		dd ?
	threadrunning	dd ?	
	samples		dd ?
	playpos		dd ?
	lastpos		dd ?
	ticks		dd ?
	spt		dd ?
	
	wfd		dd ?
	wpp		MMTIME <?>
	hdr		WAVEHDR <?>
tdsndData	ends

	.data
	
wfx		WAVEFORMATEX <WAVE_FORMAT_PCM,NUMCHANNELS,SAMPLERATE,SAMPLERATE*2*NUMCHANNELS,2*NUMCHANNELS,16,0>

	.data?

dsndData	tdsndData <?>
threadbuf	db DSBUFFERSIZE+16 dup(?)


	.code
	
dsndThread	proc data:dword

if SAFE_CODE
	finit
endif
	fldcw	[cwTrunc]
	
	mov	ebx,offset dsndData
	mov	esi,offset wincalltbl
	
if SAFE_CODE	
	inc	byte ptr [ebx+tdsndData.threadrunning]
endif
	
	threadloop:
		push	12
		call	Sleep

		lea	eax,[ebx+tdsndData.wpp]
		mov	byte ptr [eax+MMTIME.wType],TIME_BYTES
		push	sizeof MMTIME
		push	eax
		push	[ebx+tdsndData.wfd]
		call	dword ptr [esi+impWaveOutGetPosition]

		mov	ecx,DSBUFFERSIZE
		mov	eax,[ebx+tdsndData.wpp.u.cb]
		xor	edx,edx
		div	ecx
		mov	[ebx+tdsndData.playpos],edx
		push	edx
		sub	edx,[ebx+tdsndData.lastpos]
		jns	noinc
		add	edx,ecx
	noinc:
		mov	edi,[ebx+tdsndData.lastpos]
		pop	eax		
		mov	[ebx+tdsndData.lastpos],eax
	
		shr	edx,NUMCHANNELS
		;jz	threadloop
		xchg	ecx,edx
		
		dsndMachineWork:

			dec	[ebx+tdsndData.spt]
			jns	no_tick_inc

			pushad
			call	scptRun
			mov	eax,[ebx+tdsndData.ticks]	;samplecount
			call	seProceedPattern
			popad

			mov	[ebx+tdsndData.spt],SE_SPT-1
			inc	[ebx+tdsndData.ticks]

		no_tick_inc:

atsc			
			seRun
etsc			
			if	SE_MASTER_HACK
			else
			fld	[seOutputRight]
			fld	[seOutputLeft]			
			endif
						
			lea	eax,[threadbuf+edi]
			fmul	[script_dword+19*4]			
			fistp	word ptr [eax]			;left  channel
			fmul	[script_dword+19*4]			
			fistp	word ptr [eax+2]		;right channel

			inc	[ebx+tdsndData.samples]

			xor	eax,eax
			add	edi,NUMCHANNELS*2
			cmp	edi,edx   ;DSBUFFERSIZE
		if ENABLE_P2_OPCODES
			.686p
			cmovae	edi,eax
			.586p
		else
			jb	no_reset
			mov	edi,eax
			no_reset:
		endif

	if	DEBUG
		dec	ecx
		jnz	dsndMachineWork
	else
		loop	dsndMachineWork
	endif

	cmp	byte ptr [ebx+tdsndData.playsnd],0
	jnz	threadloop

if SAFE_CODE	
	dec	[ebx+tdsndData.threadrunning]
endif

	ret
dsndThread	endp


dsndInit	macro ;proc near
	pusha
	
	mov	ebp,offset dsndData
	lea	esi,[ebp+(tdsndData.hdr)]
	lea	edi,[ebp+(tdsndData.wfd)]
	
	push	WAVE_ALLOWSYNC
	push	NULL
	push	NULL
	push	offset wfx
	push	WAVE_MAPPER
	push	edi
	call	dword ptr [ebx+impWaveOutOpen]
if SAFE_CODE
	cmp	eax,MMSYSERR_NOERROR
	jnz	done
endif

	mov	[ebp+tdsndData.hdr.lpData],offset threadbuf
	mov	[ebp+tdsndData.hdr.dwBufferiLength],DSBUFFERSIZE
	push	sizeof WAVEHDR
	push	esi
	push	[edi]
	call	dword ptr [ebx+impWaveOutPrepareHeader]
if SAFE_CODE
	cmp	eax,MMSYSERR_NOERROR
	jnz	done
endif
	
	or	[ebp+tdsndData.hdr.dwFlags],WHDR_BEGINLOOP+WHDR_ENDLOOP
	dec	eax
	mov	[ebp+tdsndData.hdr.dwLoops],eax
	;mov	[ebp+tdsndData.hdr.dwLoops],-1
	push	sizeof WAVEHDR
	push	esi
	push	[edi]
	call	dword ptr [ebx+impWaveOutWrite]
if SAFE_CODE
	cmp	eax,MMSYSERR_NOERROR
	jnz	done
endif

comment #+
	mov	[ebp+tdsndData.hdr.lpData],offset threadbuf
	mov	[ebp+tdsndData.hdr.dwBufferiLength],DSBUFFERSIZE
	
	push	1
	pop	ecx

prepare_write_loop:
	push	ecx

	push	sizeof WAVEHDR
	push	esi
	push	[edi]
	call	dword ptr [ebx+ecx*4+impWaveOutWrite]

	or	[ebp+tdsndData.hdr.dwFlags],WHDR_BEGINLOOP+WHDR_ENDLOOP
	dec	eax
	mov	[ebp+tdsndData.hdr.dwLoops],eax
	
	pop	ecx
	
	loop	prepare_write_loop
+#
	inc	byte ptr [ebp+tdsndData.playsnd]

	push	offset threadbuf	; pointer zum speichern der threadid
	push	eax		;0
	push	eax		;NULL
	push	offset dsndThread
	push	120 		;vorher 65536
	push	eax		;NULL
	call	CreateThread
	
if SAFE_CODE
	xor	eax,eax
endif

done:
	popa
;	ret
endm ;dsndInit	endp


if SAFE_CODE
dsndDeinit	proc near
	pusha

	mov	ebp,offset dsndData
	cmp	byte ptr [ebp+tdsndData.playsnd],0
	je	release_done

		dec	byte ptr [ebp+tdsndData.playsnd]

		push	[dsndData.wfd]
		call	dword ptr [ebx+impWaveOutReset]
		push	sizeof WAVEHDR
		push	offset dsndData.hdr
		push	[dsndData.wfd]
		call	dword ptr [ebx+impWaveOutUnprepareHeader]
		
		push	[dsndData.wfd]
		call	dword ptr [ebx+impWaveOutClose]
		
	release_done:
	
	popa
	ret
dsndDeinit	endp
endif
