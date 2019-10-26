;
; Demo music player
;
; Author:
;	s_tec
;

;%define mute

%include "win32n.inc"
%include "math.inc"

;-----------------------------------------------------------------------------
; Import and export:
;-----------------------------------------------------------------------------

		global	_synth_init
		global	_synth_write

;-----------------------------------------------------------------------------
; Constants:
;-----------------------------------------------------------------------------

k_synth_voices	equ	64		;Maximum concurrent voices
k_synth_voice	equ	16*4		;Bytes per voice
k_synth_cols	equ	5		;Tracker columns
x		equ	0		;Tracker no-op

%imacro octave 1
a%1f		equ	%1*12 + -1	;black
a%1		equ	%1*12 + 0
a%1s		equ	%1*12 + 1	;black
b%1f		equ	%1*12 + 1	;black
b%1		equ	%1*12 + 2
c%1		equ	%1*12 + 3
c%1s		equ	%1*12 + 4	;black
d%1f		equ	%1*12 + 4	;black
d%1		equ	%1*12 + 5
d%1s		equ	%1*12 + 6	;black
e%1f		equ	%1*12 + 6	;black
e%1		equ	%1*12 + 7
f%1		equ	%1*12 + 8
f%1s		equ	%1*12 + 9	;black
g%1f		equ	%1*12 + 9	;black
g%1		equ	%1*12 + 10
g%1s		equ	%1*12 + 11	;black
%endmacro

octave	0	;0   -  12    13.75 Hz -    27.50 Hz
octave	1	;12  -  24    27.50 Hz -    55.00 Hz
octave	2	;24  -  36    55.00 Hz -   110.00 Hz
octave	3	;36  -  48   110.00 Hz -   220.00 Hz
octave	4	;48  -  60   220.00 Hz -   440.00 Hz
octave	5	;60  -  72   440.00 Hz -   880.00 Hz
octave	6	;72  -  84   880.00 Hz -  1760.00 Hz
octave	7	;84  -  96  1760.00 Hz -  3520.00 Hz
octave	8	;96  - 108  3520.00 Hz -  7040.00 Hz
octave	9	;108 - 120  7040.00 Hz - 14080.00 Hz

;-----------------------------------------------------------------------------
; Unitialized data:
;-----------------------------------------------------------------------------
		section .bss

		
s_synth_notes:	resd	g9s + 1			;Note frequency table
s_synth_count:	resd	1			;Current row counter
s_synth_time:	resd	1			;Current sample being rendered
s_synth_state:	resb	k_synth_voices*k_synth_voice	;Voice storage area

;-----------------------------------------------------------------------------
; Initialized data:
;-----------------------------------------------------------------------------
		section	.data

%include "music.inc"

s_synth_note0:	dd	0.000623582746		;Starting frequency
s_synth_noted:	dd	1.059463143349		;Frequency step
s_synth_row:	dd	s_music			;Current row pointer

		;Instrument to tracker column mapping:
s_synth_inst:	dd	_synth_wind
		dd	_synth_wind
		dd	_synth_tink
		dd	_synth_horn
		dd	_synth_bass

;-------------------------------------------------------------------------------
; length
;
; Terminates the note when its sample count exceeds its length.
;
; Parameters:
;	%1	Length
;-------------------------------------------------------------------------------
%imacro length 1
		mov	eax, [ebp+8]
		inc	eax
		cmp	eax, %1
		jl	%%skip
		mov	dword[ebp], 0
%%skip:		mov	[ebp+8], eax
		add	ebp, 12
%endmacro

;-------------------------------------------------------------------------------
; oscillate
;
; Generates a sawtooth wave between -1 and 1. This wave can be processed to
; make triangle waves, sine waves, or whatever.
;
; Parameters:
;	st0	Frequency
;	[ebp]	Oscillator state (incremented after call)
; Returns:
;	st0	Sawtooth wave
;-------------------------------------------------------------------------------
%imacro oscillate 0
		fadd	dword[ebp]		;o+=f
		fld1				;1,o
		fcomip	st0, st1		;o
		jnc	%%skip			;Jump if o <= 1
		fsub	dword[s_f2]		;o-=2
%%skip:		fst	dword[ebp]		;o
		add	ebp, 4
%endmacro

;-------------------------------------------------------------------------------
; triangle
;
; Shapes the output of the oscillate macro into a triangle wave.
;
; Parameters:
;	st0	Sawtooth wave
; Returns:
;	st0	Triangle wave
;-------------------------------------------------------------------------------
%imacro triangle 0
		fadd	st0, st0		;2*o
		fabs				;abs(2*o)
		fld1				;1,abs(2*o)
		fsubp	st1, st0		;abs(2*o)-1
%endmacro

;-------------------------------------------------------------------------------
; sine
;
; Shapes the output of the oscillate macro into a sine wave.
;
; Parameters:
;	st0	Sawtooth wave
; Returns:
;	st0	Sine wave
;-------------------------------------------------------------------------------
%imacro sine 0
		fldpi				;pi,o
		fmulp	st1, st0		;pi*o
		fsin				;sin(pi*o)
%endmacro

;-------------------------------------------------------------------------------
; iir1
;
; Single-pole lowpass filter with gain of 1 at DC.
;
; Parameters:
;	%1	Pole location
;	st0	Input wave
;	[ebp]	Filter state (incremented after call)
; Returns:
;	st0	Sine wave
;-------------------------------------------------------------------------------
%imacro iir1 1
		fld	dword[ebp]		;y,x
		fmul	dword[%1]		;y*k,x
		faddp	st1, st0		;x+=y*k
		fst	dword[ebp]		;x
		add	ebp, 4
		fld1				;1,x
		fsub	dword[%1]		;1-k,x
		fmulp	st1, st0		;x*=(1-k)
%endmacro

;-----------------------------------------------------------------------------
; _synth_init
;
; Initializes and plays the demo's music.
;
; Preserves:
;	esi
;-----------------------------------------------------------------------------
		section	.text
_synth_init:
		;Generate the note table:
		mov	edi, s_synth_notes
		mov	ecx, g9s + 1
		fld	dword[s_synth_note0]	;f
.repeat:	fst	dword[edi]		;f
		fmul	dword[s_synth_noted]	;f*=1.059463143349
		add	edi, 4
		loop	.repeat
		fstp	st0			;

		ret

;-----------------------------------------------------------------------------
; _synth_write
;
; Fills a buffer with samples
;
; Parameters:
;	edi	Destination buffer address
;	ecx	Number of bytes to render
; Register use:
;	ebp	Instrument state address
; Preserves:
;	esi
;-----------------------------------------------------------------------------
_synth_write:
%ifdef linux
		push	esi
		push	edi
		push	ebx
		push	ebp
		mov	edi, [esp+20]
		mov	ecx, [esp+24]
		shr	ecx, 1
.repeat:	jnz	_synth_write1
		pop	ebp
		pop	ebx
		pop	edi
		pop	esi
		ret
%else
		push	esi
		shr	ecx, 1
.repeat:	jnz	_synth_write1
		pop	esi
		ret
%endif
;-----------------------------------------------------------------------------
; _synth_write1
;
; Reads the stream of music data.
;-----------------------------------------------------------------------------
_synth_write1:
		;Do we need to advance the row?
		mov	ebx, [s_synth_row]	;Score pointer
		movzx	eax, byte[ebx]		;Row duration
		imul	eax, k_music_tempo
		cmp	eax, [s_synth_count]	;Sample counter
		jg	.skip3
%ifdef mute
		jmp	.skip3			;Mute
%endif
		;Advance to the next row:
		add	ebx, 1 + k_synth_cols
		mov	[s_synth_row], ebx
		mov	dword[s_synth_count], 0

		;Prepare for the loop:
		push	ecx
		mov	ecx, k_synth_cols
		mov	ebp, s_synth_state
		
		;Find an empty slot in the active voice table:
.repeat:	cmp	dword[ebp], 0	
		jz	.skip1
		add	ebp, k_synth_voice
		jmp	.repeat

		;Write a note into the slot:
.skip1:		inc	ebx
		movzx	eax, byte[ebx]
		cmp	al, x
		je	.skip2
		mov	edx, k_synth_voice/4
.erase:		mov	dword[ebp + 4*edx - 4], 0
		loop	.erase, edx
		mov	eax, [s_synth_notes + 4*eax]
		mov	[ebp+4], eax
		mov	eax, [s_synth_inst + 4*ecx - 4]
		mov	[ebp], eax

.skip2:		loop	.repeat
		pop	ecx
		
		;Advance the sample count:
.skip3:		inc	dword[s_synth_count]

;-----------------------------------------------------------------------------
; _synth_write2
;
; Renders the active voices and writes them to the output buffer.
;-----------------------------------------------------------------------------
_synth_write2:
		;Render the active voices:	
		push	ecx
		mov	ecx, k_synth_voices
		mov	ebp, s_synth_state
		fldz				;s
.repeat:	cmp	dword[ebp], 0
		jz	.skip
		push	ebp
		call	dword[ebp]		;x,s
		faddp	st1, st0		;s+=x
		pop	ebp
.skip:		add	ebp, k_synth_voice
		loop	.repeat
		pop	ecx

		;Master volume slider:
		mov	eax, [s_synth_time]
		mov	esi, s_synth_master
		call	_path			;v,s
		fmulp	st1, st0		;s*=v
		inc	dword[s_synth_time]

		;Clip and write:
		fmul	dword[s_f32767]		;s*=32768
		fmin	dword[s_f32767]		;max(s,32768)
		fchs				;-s
		fmin	dword[s_f32767]		;max(-s,32768)
		fistp	dword[s_temp]		;
		mov	eax, [s_temp]
		stosw

		;Render another sample:
		dec	ecx
		jmp	_synth_write.repeat

;-----------------------------------------------------------------------------
; _music_bass
;
; Creates a sample of the bass instrument.
;
; Parameters:
;	Same as _music_horn
;-----------------------------------------------------------------------------
_synth_bass:
		;Envelope:
		mov	eax, [ebp+8]
		mov	esi, s_bass_env
		call	_path			;v

		;Read the next note:
		fld	dword[ebp+4]		;f,v

		;Advance the sample count:
		length	k_bass_length

		;Oscillator:
		oscillate			;x
		triangle			;x
		fmin	dword[s_bass_level]	;x
		fchs
		fmin	dword[s_bass_level]	;x

                ;LFO effect: 
                fld     dword[s_bass_lfo0]      ;f,x 
                oscillate                       ;lfo,x 
                sine                            ;lfo,x 
                fmul    dword[s_bass_lfo1]      ;lfo,x 
                fmul	st0, st1                ;lfo*x,x 
                faddp   st1, st0                ;x+=lfo*x

		;Mix:
		fmulp	st1, st0		;x*=v
		ret

;-----------------------------------------------------------------------------
; _music_horn
;
; Creates a sample of the horn instrument.
;
; Parameters:
;	ebp	Instrument state block
;	[epb]	Instrument function pointer (set to 0 when the note ends)
;	[ebp+4]	Instrument frequency
; Preserves:
;	ecx
;-----------------------------------------------------------------------------
_synth_horn:
		;Envelope:
		mov	eax, [ebp+8]
		mov	esi, s_horn_env
		call	_path			;v

		;Read the next note:
		fld	dword[ebp+4]		;f,v

		;Advance the sample count:
		length	k_horn_length

		;Oscillator:
		oscillate			;x

                ;LFO effect: 
                fld     dword[s_horn_lfo0]      ;f,x 
                oscillate                       ;lfo,x 
                sine                            ;lfo,x 
                fmul    dword[s_horn_lfo1]      ;lfo,x 
                fmul	st0, st1                ;lfo*x,x 
                faddp   st1, st0                ;x+=lfo*x

		;Filter:
		iir1	s_horn_lpf		;x

		;Mix:
		fmulp	st1, st0		;x*=v
		ret

;-----------------------------------------------------------------------------
; _music_tink
;
; Creates a sample of the tink instrument.
;
; Parameters:
;	Same as _music_horn
;-----------------------------------------------------------------------------
_synth_tink:
		;Envelope:
		mov	eax, [ebp+8]
		mov	esi, s_tink_env
		call	_path			;v

		;Frequency:
		fld	dword[ebp+4]		;f,v

		;Advance the sample count:
		length	k_tink_length

		;Sine wave:
		oscillate			;x,v
		sine				;x,v

		;Mix:
		fmulp	st1, st0
		ret

;-----------------------------------------------------------------------------
; _music_wind
;
; Creates a sample of the wind instrument.
;
; Parameters:
;	Same as _music_horn
;-----------------------------------------------------------------------------
_synth_wind:
		;Envelope:
		mov	eax, [ebp+8]
		mov	esi, s_wind_env
		call	_path			;v

		;Frequency:
		fld	dword[ebp+4]		;f,v

		;Advance the sample count:
		length	k_wind_length

		;Oscillator 1:
		fld	st0			;f,f,v
		oscillate			;x,f,v
		triangle			;x,f,v
		fxch	st0, st1		;f,x,v

		;Oscillator 2:
		random				;r,f,x,v
		fmul	dword[s_wind_shift]	;r,f,x,v
		faddp	st1, st0		;f+r,x,v
		oscillate			;x,x,v
		triangle			;x,x,v
		faddp	st1, st0		;x,v

		;Mix:
		fmulp	st1, st0
		ret
