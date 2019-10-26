global synth			

%ifdef TRACKER_EMBED
global synth_update
%endif
	
section .data

;;; filter constants
fc1:
	dd 3.296875
fc2:
	dd 0.00497436523438
flt_fb:
	dd 1.3
flt_co:
	dd 0.2
flt_decay:
	dd 0.99995

;;; oscillator constants
sq_mult:
	dd 100.0

;;; other constants
stereo_mod:
	dd 1.003	; adjustment for 2nd ch
main_tune:
	dd 0.00074156906264342    ; synth global tuning
;; main_tune:	dd 0.000200
oct_semitones:
	dd 12		; number of notes per octave

%define SONG_TICKLEN 30000

%ifdef TRACKER_EMBED
	;; TODO: include empty data for tracker use
%else
	;; include tracker-generated asm version
	%include "song.asm"
%endif

;;; enabled features
	%define ENABLE_OSCILLATOR
	%define ENABLE_FILTER
	%define ENABLE_ENVELOPE
	;; %define ENABLE_COMPRESSOR
	%define ENABLE_DELAY

	%define NUM_TRACKS 4

;;; oscillator flags
	;; %define OSC_FLAG_SINE 0x01
	;; %define OSC_FLAG_SQUARE 0x02
	%define OSC_FLAG_STEREO  0x80

	%define	ELEMENT_DATA_SIZE 6
	%define ELEMENT_DATA_BYTES ELEMENT_DATA_SIZE * 4
	%define ELEMENT_WORK_BYTES 65536

	%define MODULE_OUT_OFFSET  4

	;; module types
	%define MODULE_TYPE_OSC        0x00
	%define MODULE_TYPE_FILTER     0x01
	%define MODULE_TYPE_ENV        0x02
	%define MODULE_TYPE_COMPRESSOR 0x03
	%define MODULE_TYPE_DELAY      0x04

	;; oscillator params & state
	%define OSC_PARAM_GAIN	   8
	%define OSC_PARAM_FREQ_MOD 12
	%define OSC_PARAM_ADD	   16
	%define OSC_PARAM_DETUNE2  20 ; 2nd osc detune

	%define OSC_STATE_CTR1	   0
	%define OSC_STATE_CTR2	   4

	;; filter params & state
	%define FLT_PARAM_INPUT      8
	%define FLT_PARAM_CUTOFF     12
	%define FLT_PARAM_FB_GAIN    16

	%define FLT_STATE_FB1	   0
	%define FLT_STATE_FB2	   4

	;; envelope params & state
	%define ENV_PARAM_ATT      8  ; linear attack add
	%define ENV_PARAM_SWITCH   12 ; level for A -> D switch (or how about just doing at 1?)
	%define ENV_PARAM_DECAY    16 ; multiplier for exp decay
	%define ENV_PARAM_STAGE    20 ; env stage A: 0, D: 1

	%define ENV_STATE_LEVEL    0  ; current level

	%define COMP_VAL_IN        8
	%define COMP_VAL_THRESHOLD 12
	%define COMP_VAL_ATTACK    16
	%define COMP_VAL_RELEASE   20
	%define COMP_VAL_GAIN      24 ; current gain value

	%define DELAY_PARAM_IN       8
	%define DELAY_PARAM_LEN      12
	%define DELAY_PARAM_FB       16
	%define DELAY_PARAM_WET      20

	%define DELAY_STATE_POS      0

	;; output ops
	%define MODULE_OUT_OP_SET  0
	%define MODULE_OUT_OP_ADD  1
	%define MODULE_OUT_OP_MULT 2

;;; Element data area

trigger_points:
	;; each track can trigger two instruments.
	;; triggering happens as follows:
	;;
	;;  - set pitch of osc at module <trigger point>
	;;  - reset phase of env at module <trigger point + 1>
	dd 0
	dd 8

	dd 0
	dd 8

	dd 0
	dd 8			; bass

	dd 0
	dd 5

%ifdef TRACKER_EMBED
	
instr_data:	
	%include "lead1.asm"

song:
	%include "song.asm"

%endif

	;; We replace .bss with g_buffer + N references in converted
	;; intro version, so define constants for it. These must match
	;; offsets of corresponding vars in bss (as they would be in
	;; a build without TRACKER_EMBED)
	%define BOFF_ORDER_POS     0
	%define BOFF_PATTERN_POS   4
	%define BOFF_STEREO_FACTOR 8
	%define BOFF_MASTER_OUT	   12
	%define BOFF_TICK_CTR      16
	%define BOFF_TEMP1         20
	%define BOFF_MODULES       24
	%define BOFF_WORK          24 + NUM_TRACKS * NUM_MODULES * ELEMENT_DATA_BYTES
	
section .bss
	
%ifdef TRACKER_EMBED
state_setup_done: resd 1
%endif

g_buffer:			; for non-intro builds from AT&T syntax
	

bss_order_pos:
	resd 1
bss_pattern_pos:
	resd 1
bss_stereo_factor:
	;; extra modulation source that varies per channel, to create stereo diff
	resd 1

bss_master_out:
	resd 1
	
bss_tick_ctr:
	resd 1
	;; misc temp vars
bss_temp1:
	resd 1

	;; copy of all elements per track, + work area per channel
	%define STATE_BYTES_PER_CHANNEL ELEMENT_WORK_BYTES * NUM_MODULES
	
;;;
;;; Work area structure:
;;;
;;; NUM_TRACKS * [element set]
;;; NUM_TRACKS * NUM_MODULES * [work area]
;;; 
bss_modules:
	resd NUM_TRACKS * NUM_MODULES * ELEMENT_DATA_BYTES / 4
bss_work:
	resd STATE_BYTES_PER_CHANNEL * 2 * NUM_TRACKS * NUM_MODULES / 4
	

section .text

;;; calling convention:
;;; in:
;;;  esi - ptr to element params & inputs
;;;  ebp - ptr to element state
;;; out:
;;;  st0 - element output
;;; regs:
;;; ecx, esi, edx, ebp  callee-saved
;;; eax, ebx, edi       caller-saved

;;; oscillator module
;;;
;;; data area:
;;;  0: type & output op.
;;;  4: dest offset
;;; state area

module_oscillator:
	pusha

	fld1
	fld dword [esi + OSC_PARAM_ADD] ; st0: osc add, st1: 1

	;; freq modulation
	fld dword [esi + OSC_PARAM_FREQ_MOD]
	fadd st2		; 1
	fmulp                   ; st0: modulated add, st1: 1
	;; stereo factor
	fld dword [bss_stereo_factor]
	fmulp                   ; st0: modulated add, st1: 1

	fxch st0, st1
	fld dword [ebp + OSC_STATE_CTR1] ; st0: osc counter, st1: 1, st2: modulated add
	fadd st0, st2
	fprem1
	fstp dword [ebp + OSC_STATE_CTR1] ; st0: 1, st1: modulated add

	fld dword [esi + OSC_PARAM_DETUNE2]
	fmulp st2, st0                   ; st0: 1, st1: modulated + detuned add

	fld dword [ebp + OSC_STATE_CTR2]
	fadd st0, st2
	fprem1
	fst dword [ebp + OSC_STATE_CTR2] ; st0: osc2, st1: 1, st2: modulated + detuned add

	;; square shaper
;; 	test dword [esi], OSC_FLAG_SQUARE
;; 	jz _osc_skip_square
;; 	fmul dword [sq_mult]
;; 	fprem1
;; _osc_skip_square:

;;	;; sine shaper
;; 	test dword [esi], OSC_FLAG_SINE
;; 	jz _osc_skip_sine
;; 	fldpi
;; 	fadd st0
;; 	fmulp
;; 	fsin
;; _osc_skip_sine:

;;	;; amp modulation
;;	fld dword [esi + 4]	; amp mod
;;	fadd st2		; + 1
;;	fmul

	fld dword [ebp + OSC_STATE_CTR1]
	faddp

	;; some shaping?
	;; fld st0
	;; fabs
	;; fmul st1, st0
	;; fmulp

	fxch st0, st2
	fstp st0
	fstp st0

	fmul dword [esi + OSC_PARAM_GAIN]
	;; output in st0

	popa
	ret

%ifdef ENABLE_FILTER
;;; rez lp filter
;;;
;;; data area:
;;;  0: type & output op.
;;;  4: dest offset
;;; state
;;;
;;;  8: cutoff
;;;  12: feedback gain
;;;  16: fb1 buf
;;;  20: fb2 buf
;;;  24: input

module_filter:
	;; feedback coefficient
	fld dword [esi + FLT_PARAM_FB_GAIN]
	fld dword [esi + FLT_PARAM_CUTOFF]
	fmul dword [fc1]
	fsub dword [fc2]
	fmulp
	;; st0: fb_coeff

	fld dword [ebp + FLT_STATE_FB1]
	fld dword [ebp + FLT_STATE_FB2]
	fsubp
	fmulp
	;; st0: feedback
	fsin

	fld dword [esi + FLT_PARAM_INPUT]  ; input
	fld dword [esi + FLT_PARAM_CUTOFF] ; cutoff
	fabs				   ; safety measure: negative cutoff makes unstable
	fmulp
	;; st0: (in * cutoff), st1: feedback

	fld dword [ebp + FLT_STATE_FB1]
	fld1
	fld dword [esi + FLT_PARAM_CUTOFF] ; cutoff
	fabs			; safety
	fsubp st1		    ; 1 - cutoff
	fmulp
	;; st0: flt_p1 * (1 - cutoff), st1: (in * cutoff), st2: feedback

	faddp
	faddp
	fst dword [ebp + FLT_STATE_FB1]
	;; st0: flt_p1
	;; TODO: kill denormals here?

	fld dword [esi + FLT_PARAM_CUTOFF]
	fabs			; safety
	fadd st0
	fld1
	fsub st0, st1
	;; st0: (1 - flt_co * 2), st1: (flt_co * 2), st2: flt_p1

	fmul dword [ebp + FLT_STATE_FB2]
	fxch st0, st1
	fmul st0, st2
	;; st0: (1 - flt_co * 2) * flt_p1, st1: (flt_co * 2) * flt_p1, st2: flt_p

	faddp
	fst dword [ebp + FLT_STATE_FB2]

	fxch st0, st1
	fstp st0

	;; output in st0
	ret
%endif				; ENABLE_FILTER
	
;;; AD envelope generator
;;;  - linear attack
;;;  - switch at defined gain level
;;;  - exponential decay
;;;
;;; data area:
;;;  0: type & output op.
;;;  4: dest offset
module_envelope:
	fld dword [ebp + ENV_STATE_LEVEL]
	mov eax, [esi + ENV_PARAM_STAGE]
	test eax, eax
	jnz .in_decay
	fld dword [esi + ENV_PARAM_ATT]
	faddp
	;; test for state switch
	fld dword [esi + ENV_PARAM_SWITCH]
	fcomip
	jnc .no_switch
	inc eax
	mov [esi + ENV_PARAM_STAGE], eax
.no_switch:
	jmp .no_decay
.in_decay:
	fld dword [esi + ENV_PARAM_DECAY]
	fmulp
.no_decay:
	fst dword [ebp + ENV_STATE_LEVEL]

	;; output in st0
	ret

%ifdef ENABLE_COMPRESSOR
;;; dynamic compressor with threshold, attack & release
;;;
;;; data area:
;;; 0: type & output op
;;; 4: dest offset
;;;
;;; 8: signal in
;;; 12: threshold
;;; 16: attack
;;; 20: release
;;; 24: current gain
module_compressor:
	fld dword [esi + COMP_VAL_GAIN]
	fld dword [esi + COMP_VAL_IN]
	fmul st1
	;; st0: output, st1: gain

	fld st0
	fabs
	;; st0: abs(output), st1: output, st2: gain

	fld dword [esi + COMP_VAL_THRESHOLD]
	;; st0: threshold, st1: abs(output), st2: output, st3: gain
	fcomip st1
	fstp st0
	;; st0: output, st1: gain
	fxch st0, st1
	;; st0: gain, st1: output
	jnc .do_release		; jmp if threshold > abs(output)
	fld dword [esi + COMP_VAL_ATTACK]
	fmulp
	jmp .skip_release
.do_release:
	fld dword [esi + COMP_VAL_RELEASE]
	faddp
.skip_release:
	fld1
	fcomip st1
	jnc .no_update
.no_update:
	;; st0: updated gain, st1: output signal
	fstp dword [esi + COMP_VAL_GAIN] ; store new gain

	;; st0: output


	;; test
	;; fstp st0
	;; fld dword [esi + COMP_VAL_GAIN]

	ret
%endif				; ENABLE_COMPRESSOR
	
;;; delay with feedback & lp filter
;;; 0: type & output op
;;; 4: dest offset
;;;
;;; 8: signal in
;;; 12: delay len (samples)
;;; 16: delay feedback
;;; 20: delay damping (lp filter coeff)
;;; 24: delay wet ratio

;;; idea: instead of adding single values from past, iterate through buffer,
;;; accumulate sin(diff) * val[diff] (or sin^2 or sin^n for less lp filtering)
module_delay:
	fld dword [esi + DELAY_PARAM_IN]
	;; update delay buf ptr
	mov ebx, [ebp + DELAY_STATE_POS]
	add ebx, 4
	and ebx, 0x7ffff
	mov [ebp + DELAY_STATE_POS], ebx
	add ebx, 4

	fld dword [ebp + ebx]
	fld dword [esi + DELAY_PARAM_FB]
	fmulp
	faddp

	fst dword [ebp + ebx]

	;;  bler
	ret

;;;
;;; synth main
;;;
;;; regparm convention, args:
;;; eax: output addr
;;; edx: frames to render (stereo float, 8 bytes each)
synth:
	pusha
	;; reorder register args to proper places
	;; TODO: make this unnecessary
	mov edi, eax
	mov ecx, edx

;;;
;;; Synth initial setup
;;; 
;;; create copies of elements for each track

	pusha
%ifdef TRACKER_EMBED
	;; setup must be done only once
	mov eax, [state_setup_done]
	test eax, eax
	jnz skip_setup
%endif

	lea edi, [bss_modules]
	mov ecx, NUM_TRACKS
setup_loop:
	push ecx

	;; make one copy of the element set
	lea esi, [instr_data]
	mov ecx, ELEMENT_DATA_BYTES * NUM_MODULES
	rep movsb

	pop ecx
	loop setup_loop

%ifdef TRACKER_EMBED
skip_setup:
	mov eax, 1
	mov [state_setup_done], eax
%endif
	popa	

;;;
;;; Synth main loop
;;;
;;; registers:

synth_loop:
	push ecx

	fldz			; master out accumulator

;;; 
;;; Track loop
;;;
;;; Run once for each track, increments pattern pointer once for each on
;;; new tick, so that a whole pattern row is consumed
;;;

	;; load first track's module & area pointer, will stay in esi for duration of loop
	lea esi, [bss_modules]
	;; work area pointer for module
	lea ebp, [bss_work]
	
	mov ecx, NUM_TRACKS
tracks_loop:
	push ecx

	;; 
	;; song & pattern stuff here
	;; 
	mov ebx, [bss_tick_ctr]
	test ebx, ebx
	jnz notick

	;;
	;; start of tick, can trigger new notes
	;; 

	;; get pattern start
	mov ebx, [bss_order_pos]
	mov bl, [ebx + order]
	imul ebx, 96
	;; add pattern offset
	mov eax, [bss_pattern_pos]
	add ebx, eax
	;; add channel

	xor eax, eax
	mov al, [ebx + patterns]
	cmp al, 0
	je notrig		 ; 0 -> emptry cell, don't trigger note at all
	
	;; trigger envelope

	;;
	;; Set osc pitch for channel
	;;
	push eax		; save for trigger control
	
	and al, 0x7f		; pitch, bits 0-7, bit 8 alt instr

	mov bl, 12
	div bl			; quotient to al, remainder to ah
	mov [bss_temp1], ah

	;; 2 fld:s would work here too because of reasons
	fild dword [bss_temp1]
	fild dword [oct_semitones]
	fdivp

	f2xm1
	fld1
	faddp

	;; octave
	mov ebx, 1
	mov cl, al
	shl ebx, cl
	mov [bss_temp1], ebx
	fild dword [bss_temp1]
	fmulp

	;; synth main tune
	fld dword [main_tune]
	fmulp

	pop eax			; restore for trigger control
	pop ecx			; get track no for trigger control
	push ecx

	pusha

	;;
	;; trigger primary or alternate instrument for track
	;;  
	neg ecx
	add ecx, 4
	imul ecx, 8

	test al, 0x80
	jz no_alt_instr
	add ecx, 4
no_alt_instr:	
	
	add ecx, trigger_points
	mov ecx, [ecx]

	imul ecx, ELEMENT_DATA_BYTES

	add esi, ecx
	add ebp, ecx

	;; set osc pitch
	fstp dword [esi + OSC_PARAM_ADD]

	;; trigger envelope
	mov dword [esi + ELEMENT_DATA_BYTES + ENV_PARAM_STAGE], 0

	popa
notrig:				; no trigger note

	mov eax, [bss_pattern_pos]
	inc eax
	cmp eax, 96
	jne no_advance
	;; advance order
	mov eax, [bss_order_pos]
	inc eax
	mov [bss_order_pos], eax
	xor eax, eax
no_advance:	
	mov [bss_pattern_pos], eax

notick:				; no tick starting


	;; process all elements
	mov ecx, NUM_MODULES
element_loop:
	push ecx

	;;; call elements according to types
	mov eax, dword [esi] ; load element type

	push ebp		; save ebp, in case incremented because of stereo
	
	;; stereo things
	test edi, 0x4
	fld1
	jz .ch_left

	;; if stereo effect not enabled in osc flags, run both channels with same param
	test al, OSC_FLAG_STEREO
	jz .mono_only
	
	fld dword [stereo_mod]
	fmulp
.mono_only:
	add ebp, STATE_BYTES_PER_CHANNEL
.ch_left:
	fstp dword [bss_stereo_factor]

	and al, 0x7f		; strp stereo flag

%ifdef ENABLE_OSCILLATOR
	cmp al, MODULE_TYPE_OSC
	jne no_osc
	call module_oscillator
no_osc:
%endif

%ifdef ENABLE_FILTER
	cmp al, MODULE_TYPE_FILTER
	jne no_filter
	call module_filter
no_filter:
%endif

%ifdef ENABLE_ENVELOPE
	cmp al, MODULE_TYPE_ENV
	jne no_envelope
	call module_envelope
no_envelope:
%endif

%ifdef ENABLE_COMPRESSOR
	cmp al, MODULE_TYPE_COMPRESSOR
	jne no_compressor
	call module_compressor
no_compressor:
%endif

%ifdef ENABLE_DELAY
	cmp al, MODULE_TYPE_DELAY
	jne no_delay
	call module_delay
no_delay:
%endif
	;; element output now in st0
	mov ebx, [esi + MODULE_OUT_OFFSET]
	cmp ebx, -1
	jne not_master_out

	;; add to master (TODO: keep master out in fpu stack?)
	faddp
	jmp was_master_out
	
not_master_out:	
	add ebx, esi

	;; set, add or multiply target
	cmp ah, MODULE_OUT_OP_SET
	je no_op

	fld dword [ebx]
	cmp ah, MODULE_OUT_OP_MULT
	jne no_op_mult
	fmulp
no_op_mult:
	cmp ah, MODULE_OUT_OP_ADD
	jne no_op_add
op_add:	
	faddp
no_op_add:

no_op:
	fstp dword [ebx]

was_master_out:	

	;; next element
	add esi, ELEMENT_DATA_BYTES
	pop ebp			; restore ebp in case was adjusted for stereo
	add ebp, STATE_BYTES_PER_CHANNEL * 2

	;;
	;; end element loop
	;; 
	pop ecx
	dec ecx
	jnz element_loop

	;;
	;; end tracks loop
	;; 
	pop ecx
	dec ecx
	jnz tracks_loop
;;;
;;; End track loop
;;; 

	;; decrement tick counter
	;; TODO: would this fit in a reg?
	mov esi, [bss_tick_ctr]
	dec esi			; update tick counter
	jns .no_newtick
 	mov esi, SONG_TICKLEN
.no_newtick:
	mov [bss_tick_ctr], esi
	
	fstp dword [edi]
	add edi, 4

	pop ecx
	dec ecx
	jnz synth_loop

	popa
	ret

%ifdef TRACKER_EMBED
;;;
;;; update synth data from memory
;;;
;;; normal args:
;;;  ptr to patterns
;;;  pattern bytes
;;;  ptr to order
;;;  order bytes
;;;  ptr to instruments
;;;  instrument bytes
synth_update:
	mov eax, esp
	pusha

	mov esi, [eax + 4]	; patterns
	mov ecx, [eax + 8]
	mov edi, patterns
	rep movsb

	mov esi, [eax + 12]	; order
	mov ecx, [eax + 16]
	mov edi, order
	rep movsb

	mov esi, [eax + 20]     ; instruments
	mov ecx, [eax + 24]
	mov edi, instr_data
	rep movsb

	xor eax, eax
	mov [bss_order_pos], eax
	mov [bss_pattern_pos], eax
	mov [bss_tick_ctr], eax

	;; zero state
	mov edi, bss_work
	mov ecx, STATE_BYTES_PER_CHANNEL * 2 * NUM_TRACKS * NUM_MODULES
	rep stosb

	;; need to set up work are again
	xor eax, eax
	mov [state_setup_done], eax
	
	popa
	ret
	
%endif
