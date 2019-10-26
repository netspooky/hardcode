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



;seModule

;some consts
SEM_BFS_MODULE		= 5				;Size of the BitField used in "ensemble_opcodes" to store the module_number in
SEM_BFM_MODULE		= ((1 shl SEM_BFS_MODULE)-1)	;Mask to unmask the module_number_BitField 

SEM_BFS_MACRO		= 4				;Size of the BitField to store the macro_depth in
SEM_BFM_MACRO		= ((1 shl SEM_BFS_MACRO)-1) 	;Mask to unmask the macro_depth_BitField 

SEM_NUM_OUTPORT_MAX	= 4				;maximum number of module/macro outports
SEM_NUM_INPORT_MAX	= 8				;maximum number of module/macro inports
SEM_NUM_MODULE_MAX	= (1 shl SEM_BFS_MODULE)	;maximum number of modules/macros in one macro/ensemble
SEM_NUM_MACRO_MAX	= (1 shl SEM_BFS_MACRO)		;maximum level of "macro_in_macro_in_macro_in_macr...."

SEM_MEMSIZE_SHIFT	= 12				;memory blocksize for modules (1 SHL SEM_MEMSIZE_SHIFT)


semConst	= -1
semAdder	= ((semAdderInfo 	- seModuleList)/(sizeof semInfo))
semFilter	= ((semFilterInfo	- seModuleList)/(sizeof semInfo))
semNoise	= ((semNoiseInfo 	- seModuleList)/(sizeof semInfo))
semMaster	= ((semMasterInfo 	- seModuleList)/(sizeof semInfo))
semMuller	= ((semMullerInfo 	- seModuleList)/(sizeof semInfo))
semSampler	= ((semSamplerInfo 	- seModuleList)/(sizeof semInfo))
semSR		= ((semSRInfo		- seModuleList)/(sizeof semInfo))
semOut		= ((semOutInfo		- seModuleList)/(sizeof semInfo))
semDelay	= ((semDelayInfo 	- seModuleList)/(sizeof semInfo))
semMulladder	= ((semMulladderInfo	- seModuleList)/(sizeof semInfo))
semClipper	= ((semClipperInfo 	- seModuleList)/(sizeof semInfo))
semFader	= ((semFaderInfo	- seModuleList)/(sizeof semInfo))
semPercussion	= ((semPercussionInfo	- seModuleList)/(sizeof semInfo))
semNoiser	= ((semNoiserInfo	- seModuleList)/(sizeof semInfo))

.data?

SE_SIZE_DS	= 0C4000h ;~800000
seDS	db 	SE_SIZE_DS dup (?)

.data 

;Module/Macro-Info-Structure
semInfo	struct		
	num_inport	dw ?	
	num_memblock	db ?	
	work_ptr	dd ?		
	code_size	db ?	
semInfo	ends

;list of all modules available 
seModuleList		LABEL	semInfo
;					<in,	num of memomry_blocks used by module,				offset work(),			module's code_size in byte			>
semOutInfo		semInfo		<4,	((sizeof semOutData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semOutWork,		(semOutWorkEnd		- semOutWork)		>
semAdderInfo		semInfo		<2,	((sizeof semAdderData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semAdderWork,		(semAdderWorkEnd	- semAdderWork)		>
semFilterInfo		semInfo		<3,	((sizeof semFilterData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semFilterWork,		(semFilterWorkEnd	- semFilterWork)	>
semNoiseInfo		semInfo		<0,	((sizeof semNoiseData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semNoiseWork,		(semNoiseWorkEnd	- semNoiseWork)		>
semMasterInfo		semInfo		<2,	((sizeof semMasterData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semMasterWork,		(semMasterWorkEnd	- semMasterWork)	>
semMullerInfo		semInfo		<2,	((sizeof semMullerData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semMullerWork,		(semMullerWorkEnd	- semMullerWork)	>
semSamplerInfo		semInfo		<2,	((sizeof semSamplerData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semSamplerWork,		(semSamplerWorkEnd	- semSamplerWork)	>
semSRInfo		semInfo		<4,	((sizeof semSRData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semSRWork,		(semSRWorkEnd		- semSRWork)		>
semDelayInfo		semInfo		<4,	((sizeof semDelayData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semDelayWork,		(semDelayWorkEnd	- semDelayWork)		>
semMulladderInfo	semInfo		<3,	((sizeof semMulladderData	) shr SEM_MEMSIZE_SHIFT)+1,	offset semMulladderWork,	(semMulladderWorkEnd	- semMulladderWork)	>
semClipperInfo		semInfo		<1,	((sizeof semClipperData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semClipperWork,		(semClipperWorkEnd	- semClipperWork)	>
semFaderInfo		semInfo		<3,	((sizeof semFaderData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semFaderWork,		(semFaderWorkEnd	- semFaderWork)		>

;list of all macros available
seMacroList		LABEL	semInfo
;					<in,	num of memomry_blocks used by module,				offset work(),			macros don't need code_size			>
semPercussionInfo	semInfo		<6,	((sizeof semPercussionData	) shr SEM_MEMSIZE_SHIFT)+1,	offset semPercussionWork,	0						>
semNoiserInfo		semInfo		<4,	((sizeof semNoiserData		) shr SEM_MEMSIZE_SHIFT)+1,	offset semNoiserWork,		0						>

.code		

seRun	macro
		pushad		
		
		;run sound_ocde
		call	[seCodePtr]			
	
		;clear trigger	
		mov	edi,(offset script_dword) + trigger*4
		push	SE_NUM_PATTERN*4
		pop	ecx				
		xor	eax,eax
		rep	stosb
			
		popad
endm

	
seModuleInit	macro

	;init stuff
	mov	edi,[seCodePtr]						;target			
	
	lea	ebp,seDS						;data_memory
	
	lea	edx,semFramePtrList
	add	edx,SEM_NUM_MODULE_MAX*SEM_NUM_MACRO_MAX		;alignment
	and 	edx,not (SEM_NUM_MODULE_MAX*SEM_NUM_MACRO_MAX-1)	;alignment
	
	;add	edx,4							;init: macro = 0; module = 1
	inc	edx
	inc	edx
	inc	edx
	inc	edx	
		
	;sound precalculation		
	pushad

	mov	byte ptr [script_dword+trigger*4],1
		
	mov 	esi,(offset pre_ens)		;source			
	call	ensemble2code
	mov	byte ptr [edi],0C3h		;'ret'
	
	mov	ecx,SE_SMP_LENGTH
	@precalc_loop:
		seRun
	loop	@precalc_loop
	
	popad

comment #+
	;clear mem after precalc
	pushad
	xor	eax,eax
	mov	edi,ebp
	mov	ecx,SE_SIZE_DS
	rep	stosb	
	popad
+#
	
	;use clean mem for realtime_code
	add	ebp,SE_SIZE_DS/2

	;compile realtime_sound_code
	mov 	esi,(offset main_ens)		;source			
	call	ensemble2code
	mov	byte ptr [edi],0C3h		;'ret'	
		
endm


