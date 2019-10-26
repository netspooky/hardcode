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



CPU_ATHLON	= 0
CPU_P2		= 1

DEBUGSTRING_LENGTH = 102

	.data?

asize		macro
	@debug_asize LABEL byte
endm

esize		macro
	@debug_esize LABEL byte
endm



	.data


debugstring	db DEBUGSTRING_LENGTH dup (' ')
		db 0

	
starttsc	dq 0
debug_avr_sum 	dq 0
debug_avr_cnt 	dd 0
debug_min 	dd 10000000
debug_max 	dd 0
	.code
	



atsc		macro
	pushad
	rdtsc
	mov	dword ptr [starttsc],eax
	mov	dword ptr [starttsc+4],edx	
	popad

	jmp	@label_a	;clear pipelines (prevent from pairing)
	@label_a:
endm
		

etsc		macro
	wait			;waiting for results

	pushad
	rdtsc
	fild	qword ptr [starttsc]
	
	if	CPU_ATHLON
	sub	eax,25
	endif
	
	if	CPU_P2
	sub	eax,48
	endif	
		
	sbb	edx,0
	push	edx
	push	eax
	fild	qword ptr [esp]
	fsubrp	st(1),st(0)
	
	fld	[debug_avr_sum]
	fadd	st(0),st(1)
	fstp	[debug_avr_sum]
		
	fistp	qword ptr [esp]			
	pop	eax
	pop	edx
	
		
	mov	edi,offset debugstring

;current tsc
	push	eax
	mov	eax,":ruc"
	stosd	
	pop	eax
	
	mov	cl,5
	call	int2str

;minimum	
	push	eax	
	mov	eax,':nim'
	stosd
	pop	eax
	
	cmp	eax,[debug_min]
	jg	@old_min
		mov	[debug_min],eax
	@old_min:
	
	push	eax
	mov	eax,[debug_min]
	mov	cl,5
	call	int2str	
	pop	eax	
	
;maximum
	push	eax	
	mov	eax,':xam'
	stosd
	pop	eax
	
	cmp	eax,[debug_max]
	jl	@old_max
		mov	[debug_max],eax
	@old_max:
	
	push	eax
	mov	eax,[debug_max]
	mov	cl,9
	call	int2str	
	pop	eax	

;avarage	
	push	eax	
	mov	eax,':rva'
	stosd
	pop	eax	
	
	inc	[debug_avr_cnt]	
	fld	[debug_avr_sum]	
	fidiv	[debug_avr_cnt]
	push	eax
	fistp	dword ptr [esp]
	pop	eax
		
	mov	cl,5
	call	int2str	

;count	
	mov	eax,':tnc'
	stosd	
	mov	eax,[debug_avr_cnt]
	mov	cl,8
	call	int2str		
	
;size
	add	edi,15
	mov	eax,(offset @debug_esize)-(offset @debug_asize)
	mov	cl,3
	call	int2str	
	sub	edi,3
	mov	eax,'etyb'
	stosd	
		


	
	popad


endm

; in	eax - number
;	edi - adress of string to store in
;	cl  - number of digits
;	ch  - number of digits
int2str		proc near
	push	ebx
	movzx	ebx,cl
	add	edi,ebx	
	pop	ebx	
	
	pushad	
	mov	ebx,10	
store_loop:
	cdq
	idiv	ebx
	or	dl,30h
	mov	[edi],dl
	dec	edi
		
	dec	cl
	jnz	store_loop	
	
done_store:	
	popad		
	add	edi,5
	ret
int2str		endp




debugout	macro

		push	DEBUGSTRING_LENGTH
		push	offset debugstring
		push	10
		push	20
		push	[hdc]
		call	TextOut ;(hdc, r.left, r.top, "Defenestration can be hazardous", 4);

endm

