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



;störfall ost sound engine

if PARTY
ENABLE_P2_OPCODES	= 1		;fcmovxx/fcomi/cmovxx
else
ENABLE_P2_OPCODES	= 0		;fcmovxx/fcomi/cmovxx
endif


SE_SPS	equ 	SAMPLERATE 			;SamplesPerSecond
SE_BPM	equ 	115				;BeatsPerMinute
SE_TPB	equ	4				;TicksPerBeat   
SE_SPT	equ	((SE_SPS*60)/(SE_BPM*SE_TPB))	;SamplesPerTick

trigger			=	((offset @trigger - offset seFloatTab)/4)+1
trigger_bd		=	trigger+0
trigger_sd		=	trigger+1
trigger_ch		=	trigger+2
trigger_alpha		=	trigger+3
trigger_alpha_slide	=	trigger+4

pattern			=	((offset @pattern - offset seFloatTab)/4)+1
pattern_bd1		=	pattern+0
pattern_bd2		=	pattern+1
pattern_sd1		=	pattern+2
pattern_ch1		=	pattern+3
pattern_alpha2		=	pattern+4
pattern_alpha_slide1	=	pattern+5
pattern_alpha1		=	pattern+6

notes			= 	((offset @notes - offset seFloatTab)/4)+1
note_c5			=	notes+0
note_f5			=	notes+1
note_d_5		=	notes+2
note_c6			=	notes+3
note_a_5		=	notes+4
note_c4			=	notes+5
note_f_5		=	notes+6

delay			= 	((offset @delay - offset seFloatTab)/4)+1

pattern_play		=	trigger+SE_NUM_PATTERN
pattern_play_bd		=	pattern_play+0
pattern_play_sd		=	pattern_play+1
pattern_play_ch		=	pattern_play+2
pattern_play_alpha	=	pattern_play+3
pattern_play_alpha_slide=	pattern_play+4

include seModule.ash
include seEnsemble.ash
include	seSample.ash
include	sePattern.ash

const_0		=	0
const_1		=	1
alpha_freq	=	trigger+SE_NUM_PATTERN*2
overdrive_val	=	trigger+SE_NUM_PATTERN*2+1

;modules
include	macros+modules\semOut.ash
include macros+modules\semAdder.ash
include	macros+modules\semNoise.ash
include macros+modules\semFilter.ash
include	macros+modules\semMuller.ash
include	macros+modules\semMaster.ash
include	macros+modules\semSampler.ash
include	macros+modules\semDelay.ash
include	macros+modules\semMulladder.ash
include	macros+modules\semClipper.ash
include	macros+modules\semSR.ash
include	macros+modules\semFader.ash

;macros
include	macros+modules\semPercussion.ash
include	macros+modules\semNoiser.ash

.data?

if	SE_MASTER_HACK
else
seOutputLeft	dd	?
seOutputRight	dd	?
endif

seCodePtr	dd 	?	;ptr 2 the generated code

.data

seCodeSize	=	20000	;maximum size of the generated code

seFloatTab LABEL dword		;global float_tab for module_communication

	;dd	0.0		;0
	dd	1.0		;1	

@delay LABEL dword	
	dd	33792.0		;2	delay_length_l			oooooooo
	dd	16896.0		;3	delay_length_r			oooooooo
	
@notes LABEL dword
	dd	261.635		;4	C-5
	dd	349.23		;5	F-5
	dd	311.13		;6	D#5
	dd	523.25		;7	C-6		
	dd	466.16		;8	A#5
	dd	130.81		;9	C-4
	dd	369.99		;10	F#5

	dd	100.0		;11	;o1
	dd	99.0		;12	;detune o2
	dd	101.0		;13	;detune o3
	
	dd	2.6163		;14	C-5
	dd	1.7461		;15	F-4
	dd	2.3308		;16	A#4
	dd	2.0765		;17	G#4
	
	dd	0.1564625850340136054421768707483	;18	away_fade_frequency (SE_BPM*60/44100)
		
@volumefade LABEL dword
	dd	32000.0		; 19
	dd	32000.0		; 20
	dd	0.0		; 21

@pattern label dword
;		0	1	2	3
;		|...:...|...:...|...:...|...:...
	dd	10000010000000001010001001010010b	;bd1
	dd	10000010000000001010001001010010b	;bd2
	dd	00001000000010000000100000001000b	;sd
	dd	10101010101010101010101010101011b	;ch	
	
	dd	00100000000010000000000000000000b	;alpha1		
	dd	00001100110000000000000011000000b	;alpha slide	
	dd	00101000100000100000100010000010b	;alpha2		
	
@trigger LABEL dword	

seFloatTabEnd LABEL dword


fto = (((seFloatTabEnd - seFloatTab)/4) + SE_NUM_PATTERN*2 + 2)	;number of the first precalculated float
								;+ SE_NUM_SAMPLES*2 to reserve place for trigger and pattern_play
								;+ 1 for alpha_freq
								;(strange but works)

;alpha dword_script_index
alpha_sld_cut	=	fto+8
alpha_sld_res	=	1
alpha_vol_sus	=	0
alpha_vol_dec	=	fto+7
alpha_delay_fb	=	fto+58
alpha_delay_mixl=	fto+57
alpha_delay_mixr=	fto+58
alpha_delay_ll	=	delay+0
alpha_delay_lr	=	delay+1
alpha_sld_sus	=	fto+120
alpha_sld_dec	=	1
alpha_volume	=	fto+57
	
.code 

asize
seInit		macro
;SIZE:	257
	pushad	
	
	;copy seFloatTab into script_dword
	mov	esi,offset seFloatTab
	mov	edi,offset script_dword + 4
	push	((seFloatTabEnd-seFloatTab)/4)		;num of floats in seFloatTab
	pop	ecx	
	rep 	movsd	

	;calculate FloatTab	
	fpush	0.00009					;startvalue	
	mov	edi,offset script_dword + fto*4  	;target is in script_dword behind the seFloatTab_Mirror	
		
	push	143					;num of floats
	pop	ecx
	@@FloatLoop:		
		fld	dword ptr [esp]			;old
		fld	dword ptr [esp]			;old
		fldpi					;pi
		fadd	st(0),st(0)			;pi*2 = fac
		fdivp	st(1),st(0)			;old/fac
		faddp	st(1),st(0)			;old += old/fac				
		fstp	dword ptr [esp]			;store on stack
		pop	eax				;get from stack				
		stosd					;store 	
		push	eax
	loop @@FloatLoop
	pop	eax					;clear stack
	
	;init seSampleList and generate waveforms	
	seSampleInit	

	;compile sound_script
	seModuleInit		

	popad
endm
esize