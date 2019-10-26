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



;seEnsemble

; ------------------------------ ENSEMBLE SCRIPT MACROS ------------------------------------

module 		macro typ:REQ	
;use module/macro
	db typ
endm

connect 	macro module:REQ, port:REQ
;establish connection to module [module] on modules outport [port]
	db ((port and ((1 shl (8-SEM_BFS_MODULE))-1))  shl SEM_BFS_MODULE) + (module and SEM_BFM_MODULE)
endm

connect_const 	macro float_index:REQ
;establish connection to the dword at position [float_index] in [script_dword]   (see seFloatTab.txt)
	db semConst
	db float_index
endm

sampler		macro sample:REQ, flags:REQ
;reads/writes from/to sample_buffer [sample] with looping+syncing
;flags:
;	SMP_READ	enable reading
;	SMP_WRITE	enable writing
;	SMP_LOOP	loop sample
;	SMP_SYNC	wait for sync

	db semSampler
	db sample + flags
endm

; --------------------------------------------------------------------------------------------


.data?

semFramePtrList	dd	SEM_NUM_MODULE_MAX*SEM_NUM_MACRO_MAX*2	dup (?)		;list of pointers to module_frames
ebp_temp	dd 	?
is_macro	db 	?
module_type	db	?	

.data

pre_ens			LABEL byte 		;precalc ensemble
include ensembles\precalc.ens

main_ens		LABEL byte 		;realtime ensemble
include ensembles\sound.ens

.code

ensemble2code	proc	;JIT_compiler
;INPUT:
;	edi	- 	ptr 2 code (output)
;	esi	-	ptr 2 an ensemble/macro terminated by 'db -1'
;	ebp	-	ptr 2 a lot of free mem (data_segment for modules/macros) 
;	edx	-	ptr 2 semFramePtrList
;
;SIZE:	283

	@@ensemble_loop:

	mov	[ebp_temp],ebp				;SIZE!!!
	
	xor 	eax,eax
	lodsb						;get module (proto)type
	
	mov	ecx,eax
	and	al,SEM_BFM_MODULE	
	mov	[module_type],al

	;module or macro?
	mov 	[is_macro],0	
	cmp	al,(((offset seMacroList)-(offset seModuleList))/(sizeof semInfo))
	jl	@no_m
		mov 	[is_macro],1	
	@no_m:

	;if (module_type==sampler) { setup_sampler }
	cmp	al,semSampler
	jne 	@@no_sampler
	pusha
		lodsb
		mov	[ebp+semSamplerData.smp_info],eax
		and	eax,1111b				
		lea	esi,[eax*(sizeof seSampleInfo)+(offset seSampleList)]
		mov	ebx,[esi+seSampleInfo.smp_length]			;get sample_length
		mov	[ebp+semSamplerData.smp_length],ebx	
		mov 	ebx,[esi+seSampleInfo.smp_data]				;get sample_ptr
		mov	[ebp+semSamplerData.smp_data],ebx
	popa
	inc	esi					
	@@no_sampler:			
	

	lea 	ebx,[eax*(sizeof semInfo)+(offset seModuleList)]		;get module_info	
	movzx	ecx,[ebx+semInfo.num_inport]				;get num_inports
		
	mov 	[edx],ebp						;store mem_frame in FramePtrList!		
	mov	eax,ebp

	cmp	[module_type],semOut						;if (semOut) get_input_from_macro_frame();
	jne	@no_out							
		push	edx
		and	edx,not ((SEM_BFM_MODULE shl 2) + 11b)		;set module_index to zero  -> index for the current macro/ensemble
		mov	eax,[edx]
		sub	eax,SEM_NUM_OUTPORT_MAX*4
		pop	edx
	@no_out:	
	
	;store opcode to load modules frame_ptr ... 	
	mov	byte ptr [edi],0BDh			;'mov	ebp,imm32'
	inc	edi
	stosd						;imm32
	
	movzx	eax,[ebx+semInfo.num_memblock]		;get number of memory_blocks used by module 	
	shl	eax,SEM_MEMSIZE_SHIFT			;num_memblock*(1<<SEM_MEMSIZE_SHIFT) = memoryusage in byte
	add	ebp,eax					;reserve memory

	;get modules input ...
	jecxz	@@got_input				;if no input data ... 		
	@@input_loop:	
		push	ebx
		push	edx
		
		xor 	eax,eax		
		lodsb					;get source_module_number und source_modules outport		

		cmp	al,semConst
		jne	@@no_const		
			lodsb					;get indexnum in seFloatTab
			lea	eax,[eax*4+(offset script_dword)]	;get floatofs ...					
			jmp 	@@inputofs_ready								
		@@no_const:	
			
		mov 	ebx,eax
		and	ebx,SEM_BFM_MODULE			;unmask source_module_number					
		and 	edx,not ((SEM_BFM_MODULE shl 2) + 11b)	;clear module_number and keep macro_number
		mov 	edx,[edx+ebx*4]				;get source_modules FramePtr (macroframe + modulenumber*4)
				
		or	ebx,ebx
		jnz	@nbbvcx
			add	edx,SEM_NUM_OUTPORT_MAX*4
		@nbbvcx:
		
		shr	eax,SEM_BFS_MODULE			;unmask outport		
		lea	eax,[edx+eax*4]				;final source_address (module_mem + outport*4)
	
	
		@@inputofs_ready:						
		
		
		;store 'fld	dword ptr [input_offset]'
		mov	word ptr [edi],005D9h		;fld 	dword ptr [imm32]
		inc	edi
		inc 	edi		
		stosd					;imm32

;comment #+		
		;store opcode to mirror modules input in modules local mem ('fst [ebp+imm8]' or 'fstp [ebp+imm8])
		push	eax
		
		mov	al,0D9h
		mov	ah,055h				;'fst 	dword ptr [ebp+imm8]'
				
		cmp	[module_type],semOut
		jne	@no_pop_out
			mov	ah,05Dh			;'fstp 	dword ptr [ebp+imm8]'
		@no_pop_out:
		
		cmp	[is_macro],1
		jne	@no_pop_macro
			mov	ah,05Dh			;'fstp	dword ptr [ebp+imm8]'
		@no_pop_macro:		
			
		stosw					
					
		mov	al,cl
		shl	al,2
		add	al,SEM_NUM_OUTPORT_MAX*4-4
		stosb					;imm8
		
		pop	eax					
;+#		

		pop	edx
		pop 	ebx		
	
	loop @@input_loop
	@@got_input:





	;call ensemble2code() for macros
	cmp	[is_macro],1
	jne	@no_macro	
	
		push	esi					;save ensemble_pointer
		push 	edx					;save FramePtrIndex
						
		mov 	esi,[ebx+semInfo.work_ptr]		;get address of macro_ensemble (saved in work_ptr)
		
		and	edx,not ((SEM_BFM_MODULE shl 2) + 11b)	;clear module_index and keep macro_index
		add	edx,(SEM_NUM_MODULE_MAX+1)*4		;go on in FramePtrList: next macroframe, module_number = 1 (0 reserved)
				
		push	ebp		
		mov	ebp,[ebp_temp]				;get base of macro_mem				
		mov	[edx-4],ebp				;store macro_frame_ptr in local FramePtrList on position 0
		pop	ebp
						
		call	ensemble2code				;convert macro_ensemble 2 a stream
				
		pop	edx					;restore FramePtrIndex
		pop	esi					;restore ensemble_pointer

		jmp	@fine
	@no_macro:	

	;copy modules code ...
	push	esi
	mov	esi,[ebx+semInfo.work_ptr]		;get work()
	movzx	ecx,[ebx+semInfo.code_size]		;get code_size
	rep	movsb					;copy work()
	pop	esi

	@fine:	
	;go on in semFramePtrList ...
	add	edx,4					
		
	cmp	byte ptr [esi],-1			;end of ensemble?
	jne	@@ensemble_loop
		
ret
ensemble2code	endp

