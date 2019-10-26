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



;seSampler
;
;INPUT: 	st(0) SYNC (if ((SMP_SYNC) && (SYNC!=0)) start_playing_sample(); )
;		st(1) FREQ/INPUT (depends on Read/Write-Mode)  
;
;OUTPUT:  	0: audio
;		1: control
;      
;PANEL:
;	 		   _______________
;		>    <	  |               |       
;			  |               |
;	FRQ/INP	[0..+]	--|               |--	audio out	[-1 .. +1]
;			  |  semSampler	  |
;	SYNC	[0||1]	--|               |--	control out	[ 0 .. +1]		// for LFOs ...
;			  |               |
;			  |_______________|
;
;COMMENT:	reads and writes samples.  
; 
;SIZE: 	102
;STAMP:	41-79

semSampler_read		= 4
semSampler_write	= 5
semSampler_loop		= 6
semSampler_sync		= 7

SMP_READ	= (1 SHL semSampler_read)
SMP_WRITE	= (1 SHL semSampler_write)
SMP_LOOP	= (1 SHL semSampler_loop)
SMP_SYNC	= (1 SHL semSampler_sync)

semSamplerData struct			

	;output_data (must 4*NUM_OUTPORTS_MAX bytes)
	out_audio	dd ?		
	out_control	dd ?
	out_dummy2	dd ?
	out_dummy3	dd ?	
	
	;input_data (must 4*NUM_INPORTS_MAX bytes)	(in fpu_stack_order [st(0), st(1), st(2) ...])
	;frequency	dd ?
	sync		dd ?	
	frequency	dd ?
	in_dummy2	dd ?
	in_dummy3	dd ?
	in_dummy4	dd ?
	in_dummy5	dd ?
	in_dummy6	dd ?
	in_dummy7	dd ?
		
	;module_data	
	smp_data	dd ?		;dataptr
	smp_length	dd ?		
	smp_info	dd ?
		
	smp_pos	 	dd ?		;pos in sample
	
semSamplerData ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.code

semSamplerWork		proc				;work code

	test	byte ptr [ebp+semSamplerData.smp_info],SMP_SYNC	
	jz	@no_wait_for_sync	
	
		IF	ENABLE_P2_OPCODES
		.686P		
		fldz	
		fcomip	st(0),st(1)		;"cmp 0,sync" and pop stack
		je	@no_wait_for_sync
			push	0
			pop	[ebp+semSamplerData.smp_pos]	;restart sample			
		
		.586P
		ELSE
		push	eax
		fst	dword ptr [esp]	
		pop	eax		
		or	eax,eax
		jz	@no_wait_for_sync
			push	0
			pop	[ebp+semSamplerData.smp_pos]	;restart sample					
		ENDIF
			
	@no_wait_for_sync:

	fstp	st(0)	;sync
	
	test	byte ptr [ebp+semSamplerData.smp_info],SMP_WRITE	
	jz	@read_only
		fstp	st(0)		;free freq
		fld1		
	@read_only:
	
	fadd	[ebp+semSamplerData.smp_pos]		;freq + pos = new_pos
	fild	[ebp+semSamplerData.smp_length]	
	fxch
	
	test	byte ptr [ebp+semSamplerData.smp_info],SMP_LOOP	
	jnz	@is_looping
	
		IF	ENABLE_P2_OPCODES
		.686P
		fcomi	st(0),st(1)	;cmp pos,length
		jb	@pos_ready			
		fxch				
		fld1
		fsubp	st(1),st(0)	;length - 1				
		.586P
		ELSE
		fcom	st(1)		;cmp pos,length
		fnstsw ax                                         
		sahf			;load flags
		jb	@pos_ready			
		fxch				
		fld1
		fsubp	st(1),st(0)	;length - 1
		ENDIF
	
	@is_looping:
	
	fprem						;rollover
	
	@pos_ready:			
	
	fst	[ebp+semSamplerData.smp_pos]		;store new_pos	
	ffree	st(1)
	
	push	eax
	fistp	dword ptr [esp]				;store (int)pos
	pop	eax	
	
	mov	ebx,[ebp+semSamplerData.smp_data]	;get base_address		


	test	byte ptr [ebp+semSamplerData.smp_info],SMP_WRITE	
	jz	@no_write		 
		fld	[ebp+semSamplerData.frequency]				
		fstp	dword ptr [ebx+eax*4]		
	@no_write:

	fld	dword ptr [ebx+eax*4]			;get sample

	fst	[ebp+semSamplerData.out_audio]		;audio output
	
	fld1		
	faddp	st(1),st(0)
	fpush	0.5	
	fmul	dword ptr [esp]	
	pop	eax
	fstp	[ebp+semSamplerData.out_control]	;control output		
	

semSamplerWorkEnd::
semSamplerWork		endp
