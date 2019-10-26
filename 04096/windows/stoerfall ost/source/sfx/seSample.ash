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



;seSample

seSampleInfo 	struct
	smp_data	dd ?	;ptr to data	
	smp_length	dd ?	;number of samples		
seSampleInfo	ends

.data?

seBlafaselAlignfix	dd ?	;don't remove this

	align 16
seSampleMem	dd	2501000	dup (?)

;sample_emum
SES_SIN = 0
SES_SAW = 1
SES_SQR	= 2
SES_BD	= 3
SES_SD	= 4
SES_CH 	= 5
SES_AWAY= 6

;------------------------------------------------
.data

SE_SMP_LENGTH	= (SAMPLERATE*4)
SE_NUM_SAMPLES	= (((offset seSampleListEnd)-(offset seSampleList))/(SIZEOF seSampleInfo))

seSampleList	seSampleInfo	<0,SAMPLERATE>		;sin
		seSampleInfo	<0,SAMPLERATE>		;saw
		seSampleInfo	<0,SAMPLERATE>		;sqr		
		seSampleInfo	<0,SE_SMP_LENGTH>	;bd
		seSampleInfo	<0,SE_SMP_LENGTH>	;sd
		seSampleInfo	<0,SE_SMP_LENGTH>	;ch
		seSampleInfo	<0,SE_SMP_LENGTH>	;away
seSampleListEnd LABEL byte
				
;------------------------------------------------
.code

seSampleInit		macro
;SIZE:	84

	;init seSampleList
	mov	edi,offset seSampleList
	mov	ebx,offset seSampleMem	
	push	ebx				;save
	push	SE_NUM_SAMPLES
	pop	ecx	
	@SampleListInitLoop:
		mov	eax,ebx
		stosd				;store sample_offset
		mov	esi,edi
		lodsd				;get sample_length
		lea	ebx,[ebx+eax*4]
		mov	edi,esi
	loop @SampleListInitLoop

	;generate basic waveforms	
	pop 	eax				;offset seSampleMem
	mov 	edx,SAMPLERATE	
	
	xor 	ecx,ecx	
	@sample_loop:
		fld1
		
		push 	ecx					;save counter 
		fild 	dword ptr [esp]				;load counter
		
		if LOW_SOUND
		fpush	9.0702947845804988662131519274376e-5	; 2/22050 = 1 Hz		
		else
		fpush	4.5351473922902494331065759637188e-5	; 2/44100 = 1 Hz		
		endif
		
		fmul	dword ptr [esp]				;i * 2/SAMPLERATE
		pop	esi					;fpush
				
		lea	ecx,[eax+ecx*4]
		
		;sin
		fldpi
		fmul  	st(0),st(1)
		fsin
		fstp 	dword ptr [ecx]				;sintab
						
		;saw		
		fsub	st(0),st(1)				;-1
		fstp 	dword ptr [ecx + edx*4]			;sawtab
		
		;sqr		
		bt	dword ptr [ecx + edx*4],31		;get sqr from saw's signed_bit
		jc	@l
			fchs			
		@l:		
		fstp	dword ptr [ecx + edx*8]			;sqrtab
		
		pop 	ecx			;restore counter
		inc 	ecx
	cmp	ecx,edx
	jne	@sample_loop
	
endm