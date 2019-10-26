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



SCPT_DELAY		equ 000h
SCPT_SET_BIT		equ 001h
SCPT_CLEAR_BIT		equ 002h
;SCPT_SET_DWORD		equ 003h
SCPT_LOOP		equ 003h
SCPT_COPY		equ 004h
SCPT_LINEAR_TWEEN	equ 005h
;SCPT_SPLINE_TWEEN	equ 007h
;SCPT_CALL		equ 008h

SCPT_TIME_CALL		equ 010000h

scptDelay	macro time
	dw	time
	db	SCPT_DELAY
endm

scptEnd		macro
	dw	0FFFFh		; 380.43 s, 6:20.43 min, maximum
endm

scptSet		macro time,num
	dw	time
	db	SCPT_SET_BIT+(((num) and 0fh) shl 4)
	db	((num) shr 4) and 0ffh
endm

scptClear	macro time,num
	dw	time
	db	SCPT_CLEAR_BIT+(((num) and 0fh) shl 4)
	db	((num) shr 4) and 0ffh
endm

;scptCall	macro time,layer
;	dw 	time
;	db	SCPT_CALL+((layer and 0fh) shl 4)
;	db	(layer shr 4) and 0ffh
;endm

;scptSpline	macro time,num,flts,pnts
;	dw	time
;	db	SCPT_SPLINE_TWEEN+((num and 0fh) shl 4)
;	db	(num shr 4) and 0ffh
;	db	((flts shl 5) and 0e0h)+(pnts and 01fh)
;endm

scptDword	macro time,num,val
	dw	time
	db	SCPT_SET_DWORD+(((num) and 0fh) shl 4 )
	db	((num) shr 4) and 0ffh
	dd	val
endm

scptLoop	macro time, back
	dw	time
	db	SCPT_LOOP+(((back) and 0fh) shl 4)
	db	((back) shr 4) and 0ffh
endm

scptCopy	macro time,num,src
	dw	time
	db	SCPT_COPY+(((num) and 0fh) shl 4 )
	db	((num) shr 4) and 0ffh
	;dw	src
	db	src
endm

scptLinear	macro time,num,flts,pnts
	dw	time
	db	SCPT_LINEAR_TWEEN+(((num) and 0fh) shl 4)
	db	((num) shr 4) and 0ffh
	db	(((flts) shl 5) and 0e0h)+((pnts) and 01fh)
endm


	.data

script_opcadd	db 1
		db 2
		db 2
		;db 6
		db 2
		db 3 ;4
		db 3
;		db 3
;		db 2

script_jmptbl	dd offset script_delay
		dd offset script_set_bit
		dd offset script_clear_bit
		;dd offset script_set_dword
		dd offset script_loop
		dd offset script_copy
		dd offset script_linear_tween
;		dd offset script_spline_tween
;		dd offset script_call

comment #+
script_ptr_dat	label byte
	dd	offset script_ptr
	dd	offset scriptAlpha0
	db	scriptRoboter1-scriptAlpha0
	db	scriptRoboter2-scriptRoboter1
	db	scriptRoboter3-scriptRoboter2
	db	scriptRoboter4-scriptRoboter3
	db	scriptRoboter5-scriptRoboter4
	db	scriptRoboter6-scriptRoboter5
	db	scriptTrav1-scriptRoboter6
	db	scriptBand1-scriptTrav1
	db	scriptPresse1-scriptBand1
	db	scriptPresse2-scriptPresse1
	db	scriptLookat-scriptPresse2
	db	scriptCamera-scriptLookat
	db	-1
+#


NUM_SCRIPT_TRACKS	= 12 ;13 ;14

script_ptr	label dword
	dd	scriptAlpha0
	dd	scriptRoboter1
	dd	scriptRoboter2
	;dd	scriptRoboter3
	dd	scriptRoboter4
	dd	scriptRoboter5
	dd	scriptRoboter6
	dd	scriptTrav1
	dd	scriptBand1
	dd	scriptPresse1
	dd	scriptPresse2
	;dd	scriptLookat
	dd	scriptCamera
	dd	scriptPerc

include scptSound.ash
include scptAnime.ash


	.data?

scriptrunning	dd ?

	align 16
script_dword	dd 4096	dup(?)
;script_ptr	dd 64 dup(?)
;script_adder	dd 64 dup(?)


	.code

scptWork	proc scpt:dword, ta:dword, ti:dword
	pusha

	scptWorkLoop:
		mov	esi,[scpt]

		scptWorkTimeLoop:
			xor	eax,eax

			lodsw
			imul	eax,SE_SPT
			add	eax,[ta]
			;cmp	eax,[ti]
			;ja	done

			xchg	ecx,eax			; anfangszeit in ecx

			movzx	eax,word ptr [esi]
			mov	ebx,eax
			shr	ebx,4			; opcodedaten in ebx
			and	eax,00Fh
			xchg	edx,eax			; opcode in edx
			movzx	eax,byte ptr [script_opcadd+edx]
			add	esi,eax

			movzx	eax,word ptr [esi]
			imul	eax,SE_SPT
			add	eax,[ta]		; endzeit in eax

		cmp	eax,[ti]
		jb	scptWorkTimeLoop

		jmp	[script_jmptbl+edx*4]

	script_loop::
		imul	ebx,SE_SPT
		add	[ta],ebx
		jmp	scptWorkLoop

	script_set_bit::
		push	1
		pop	eax
		;mov	eax,1
		jmp	scptSetDwd
	script_clear_bit::
		xor	eax,eax
		jmp	scptSetDwd
	;script_set_dword::
	;	mov	eax,[esi-4]
	;	jmp	scptSetDwd
	script_copy::
		;movzx	eax,word ptr [esi-2]
		movzx	eax,byte ptr [esi-1]
		mov	eax,[script_dword+eax*4]
	scptSetDwd:
		mov	[script_dword+ebx*4],eax
		jmp	done

;	script_call::
;		mov	[script_adder+ebx*4],ecx
;		jmp	done

;	script_spline_tween::
;		jmp	done

	script_linear_tween::
		movzx	edx,byte ptr [esi-1]
		mov	edi,edx
		and	edx,01Fh	; edx = number of points
		shr	edi,5		; edi = dimension
		mov	esi,[ti]
		sub	esi,ecx
		push	esi
		fild	dword ptr [esp]
		pop	esi
		sub	eax,ecx
		push	eax
		fild	dword ptr [esp]
		pop	eax
		fdivp	st1,st0
		;call	getlinearv
		getlinearv
		;jmp	done

	script_delay::

done:
	popa

	ret
scptWork	endp


scptRun		proc near
;	pusha

	mov	edi,[dsndData.samples]

;	xor	ecx,ecx

;	mov	ebx,offset scriptrunning
;scptRunWait:
;	cmp	byte ptr [ebx],cl
;	jne	scptRunWait

;	inc	byte ptr [ebx]

;	mov	cl,63
	push	NUM_SCRIPT_TRACKS
	pop	ecx
scptRunWork:
		mov	esi,[script_ptr-4+ecx*4]
;		or	esi,esi
;		jz	skipit
		push	edi
;		push	[script_adder-4+ecx*4]
		push	0
		push	esi
		call scptWork
;	skipit:
	;dec	cl
	;jns	scptRunWork
	loop	scptRunWork

;	dec	byte ptr [ebx]

;	popa
	ret
scptRun		endp
