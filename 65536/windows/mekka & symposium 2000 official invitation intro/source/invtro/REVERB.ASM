;-----------------------------------------------------------------------------
;
;                            E L I T E G R O U P
;                             we are very good.
;
; World Domination Intro Sound System
; -> Stereo reverb plugin (reads aux1)
;
; Written and (C) 1999 by The Artist Formerly Known As Doctor Roole
;
; This is a modified  Schroeder reverb (as found in  csound et al) consisting
; of four parallel comb filter delay lines (with low pass filtered feedback),
; followed by two  allpass filter delay lines  per channel. The  input signal
; is feeded directly into half of the comb delays, while it's inverted before
; being feeded into the other half to  minimize the response to DC offsets in
; the incoming signal, which was a  great problem of the original implementa-
; tion. Also, all comb delays are routed through 6dB/oct IIR low pass filters
; before feeding the output  signal back to the input to  simulate the walls'
; treble damping, which makes this reverb  sound a lot smoother and much more
; realistic.
;
; This leaves nothing but the conclusion that we're simply better than you.
;
;-----------------------------------------------------------------------------

SECTION .bss

; lengths of delay lines in samples
lencl0 	equ 1309    		; left comb filter delay 0
lencl1	equ 1635		; left comb filter delay 1
lencl2 	equ 1811                ; left comb filter delay 2
lencl3 	equ 1926                ; left comb filter delay 3
lenal0 	equ 220                 ; left all pass delay 0
lenal1 	equ 74                  ; left all pass delay 1
lencr0 	equ 1327		; right comb filter delay 0
lencr1 	equ 1631                ; right comb filter delay 1
lencr2 	equ 1833                ; right comb filter delay 2
lencr3 	equ 1901                ; right comb filter delay 3
lenar0 	equ 205		; right all pass delay 0
lenar1 	equ 77		; right all pass delay 1

struc rvbdata
 ; positions of delay lines
 .poscl0 	resd 1
 .poscl1 	resd 1
 .poscl2 	resd 1
 .poscl3 	resd 1
 .posal0 	resd 1
 .posal1 	resd 1
 .poscr0 	resd 1
 .poscr1 	resd 1
 .poscr2 	resd 1
 .poscr3 	resd 1
 .posar0 	resd 1
 .posar1 	resd 1
 ; comb delay low pass filter buffers (y(k-1))
 .lpfcl0        resd 1
 .lpfcl1        resd 1
 .lpfcl2        resd 1
 .lpfcl3        resd 1
 .lpfcr0        resd 1
 .lpfcr1        resd 1
 .lpfcr2        resd 1
 .lpfcr3        resd 1
 ; memory for the delay lines
 .linecl0 	resd lencl0
 .linecl1 	resd lencl1
 .linecl2 	resd lencl2
 .linecl3 	resd lencl3
 .lineal0 	resd lenal0
 .lineal1 	resd lenal1
 .linecr0 	resd lencr0
 .linecr1 	resd lencr1
 .linecr2 	resd lencr2
 .linecr3 	resd lencr3
 .linear0 	resd lenar0
 .linear1 	resd lenar1
 .size
endstruc

rg              resb rvbdata.size


SECTION .code

struc rvbcons
  .gainc0	resd 1 	; feedback gain for comb filter delay 0
  .gainc1	resd 1          ; feedback gain for comb filter delay 1
  .gainc2	resd 1          ; feedback gain for comb filter delay 2
  .gainc3	resd 1          ; feedback gain for comb filter delay 3
  .gaina0	resd 1          ; feedback gain for allpass delay 0
  .gaina1	resd 1          ; feedback gain for allpass delay 1
  .gainin	resd 1          ; input gain
  .damp         resd 1          ; high cut   (1-val²)
endstruc

; see struct above
rc              dd 0.966384599, 0.958186359, 0.953783929, 0.950933178, 0.994260075, 0.998044717
  	dd 0.1  ; input gain
	dd 0.8	; high cut


global rvbInit
global rvbProcess


;------------------------------------------------------------------------------
; rvbProcess: init reverb module
; on entry:   nothing
; on exit:    all regs preserved
;------------------------------------------------------------------------------

rvbInit	pushad
	; clear bss data
	xor    eax, eax
 	mov    ecx, rvbdata.size
	mov    edi, rg
	rep    stosb
	popad
	ret


;------------------------------------------------------------------------------
; rvbProcess: process reverb
; on entry:   esi is ptr to 4x32bit mixing buffer (l,r,aux1,aux2)
;             ecx is number of samples to process
;             FPU is empty and set up correctly
; on exit:    reverb of signal in aux1 channel mixed into l and r channels
;             all regs preserved
;------------------------------------------------------------------------------

rvbProcess      pushad
	mov    ebp,  rg
	mov    ebx,  rc
	fld    dword [ebx + rvbcons.damp]             	; <damp>   <- fpu stack, is klar

.sloop          ; prinzipiell nur ne große schleife


	; step 1: get input sample
	fild   dword [esi + 8]    			; <in'> <damp>
	fmul   dword [ebx + rvbcons.gainin]     	; <in> <damp>

	; step 2a: process the 4 left lpf filtered comb delays
	; left comb 0
	mov    edx,  [ebp + rvbdata.poscl0]
	fld    dword [ebp + rvbdata.linecl0+4*edx]    	; <dv> <in> <damp>
	fmul   dword [ebx + rvbcons.gainc0]           	; <dv'> <in> <damp>
	fadd   st0,  st1                		; <nv>  <in> <damp>
	fsub   dword [ebp + rvbdata.lpfcl0]           	; <v-lp> <in> <damp>
	fmul   st0,  st2                		; <d*(v-lp)> <in> <damp>
	fadd   dword [ebp + rvbdata.lpfcl0]           	; <dout> <in> <damp>
	fst    dword [ebp + rvbdata.lpfcl0]           	; <dout> <in> <damp>
	fst    dword [ebp + rvbdata.linecl0+4*edx]    	; <asuml> <in> <damp>
	inc    edx
	cmp    dx,  lencl0
	jne    .norescl0

	xor    edx, edx
.norescl0	mov    [ebp + rvbdata.poscl0], edx
	; left comb 1
	mov    edx,  [ebp + rvbdata.poscl1]
	fld    dword [ebp + rvbdata.linecl1+4*edx]    	; <dv> <asuml> <in> <damp>
	fmul   dword [ebx + rvbcons.gainc1]           	; <dv'> <asuml> <in> <damp>
	fsub   st0,  st2                		; <nv>  <asuml> <in> <damp>
	fsub   dword [ebp + rvbdata.lpfcl1]           	; <v-lp> <asuml> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asuml> <in> <damp>
	fadd   dword [ebp + rvbdata.lpfcl1]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + rvbdata.lpfcl1]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + rvbdata.linecl1+4*edx]    	; <dout> <asuml> <in> <damp>
	faddp  st1,  st0                		; <asuml'> <in> <damp>
	inc    edx
	cmp    dx,  lencl1
	jne    .norescl1
	xor    edx, edx
.norescl1	mov    [ebp + rvbdata.poscl1], edx
	; left comb 2
	mov    edx,  [ebp + rvbdata.poscl2]
	fld    dword [ebp + rvbdata.linecl2+4*edx]    	; <dv> <asuml> <in> <damp>
	fmul   dword [ebx + rvbcons.gainc2]           	; <dv'> <asuml> <in> <damp>
	fadd   st0,  st2                		; <nv>  <asuml> <in> <damp>
	fsub   dword [ebp + rvbdata.lpfcl2]           	; <v-lp> <asuml> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asuml> <in> <damp>
	fadd   dword [ebp + rvbdata.lpfcl2]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + rvbdata.lpfcl2]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + rvbdata.linecl2+4*edx]    	; <dout> <asuml> <in> <damp>
	faddp  st1,  st0                		; <asuml'> <in> <damp>
	inc    edx
	cmp    dx,  lencl2
	jne    .norescl2
	xor    edx, edx
.norescl2	mov    [ebp + rvbdata.poscl2], edx
	; left comb 3
	mov    edx,  [ebp + rvbdata.poscl3]
	fld    dword [ebp + rvbdata.linecl3+4*edx]    	; <dv> <asuml> <in> <damp>
	fmul   dword [ebx + rvbcons.gainc3]           	; <dv'> <asuml> <in> <damp>
	fsub   st0,  st2                		; <nv>  <asuml> <in> <damp>
	fsub   dword [ebp + rvbdata.lpfcl3]           	; <v-lp> <asuml> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asuml> <in> <damp>
	fadd   dword [ebp + rvbdata.lpfcl3]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + rvbdata.lpfcl3]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + rvbdata.linecl3+4*edx]    	; <dout> <asuml> <in> <damp>
	faddp  st1,  st0                		; <asuml'> <in> <damp>
	inc    edx
	cmp    dx,  lencl3
	jne    .norescl3
	xor    edx, edx
.norescl3	mov    [ebp + rvbdata.poscl3], edx

	; step 2b: process the 2 left allpass delays
	; left allpass 0
	mov    edx,  [ebp + rvbdata.posal0]
	fld    dword [ebp + rvbdata.lineal0+4*edx]    	; <d0v> <asuml> <in> <damp>
	fld    st0                      		; <d0v> <d0v> <asuml> <in> <damp>
	fmul   dword [ebx + rvbcons.gaina0]           	; <d0v'> <d0v> <asuml> <in> <damp>
	faddp  st2, st0                 		; <d0v> <d0z> <in> <damp>
	fxch   st0, st1                 		; <d0z> <d0v> <in> <damp>
	fst    dword [ebp + rvbdata.lineal0+4*edx]
	fmul   dword [ebx + rvbcons.gaina0]           	; <d0z'> <d0v> <in> <damp>
	fsubp  st1, st0                 		; <d0o> <in> <damp>
	inc    edx
	cmp    dl, lenal0
	jne    .noresal0
	xor    edx,edx
.noresal0       mov    [ebp + rvbdata.posal0], edx
	; left allpass 1
	mov    edx,  [ebp + rvbdata.posal1]
	fld    dword [ebp + rvbdata.lineal1+4*edx]    	; <d1v> <d0o> <in> <damp>
	fld    st0                      		; <d1v> <d1v> <d0o> <in> <damp>
	fmul   dword [ebx + rvbcons.gaina1]           	; <d1v'> <d1v> <d0o> <in> <damp>
	faddp  st2, st0                 		; <d1v> <d1z> <in> <damp>
	fxch   st0, st1                 		; <d1z> <d1v> <in> <damp>
	fst    dword [ebp + rvbdata.lineal1+4*edx]
	fmul   dword [ebx + rvbcons.gaina1]           	; <d1z'> <d1v> <in> <damp>
	fsubp  st1, st0                 		; <d1o> <in> <damp>
	inc    edx
	cmp    dl, lenal1
	jne    .noresal1
	xor    edx,edx
.noresal1       mov    [ebp + rvbdata.posal1], edx

	; step 2c: update left mixing buffer
	fiadd  dword [esi]              		; <l> <in> <damp>
	fistp  dword [esi]              		; <in> <damp>



	; step 3a: process the 4 right lpf filtered comb delays
	; right comb 0
	mov    edx,  [ebp + rvbdata.poscr0]
	fld    dword [ebp + rvbdata.linecr0+4*edx]    	; <dv> <in> <damp>
	fmul   dword [ebx + rvbcons.gainc0]           	; <dv'> <in> <damp>
	fadd   st0,  st1                		; <nv>  <in> <damp>
	fsub   dword [ebp + rvbdata.lpfcr0]           	; <v-lp> <in> <damp>
	fmul   st0,  st2                		; <d*(v-lp)> <in> <damp>
	fadd   dword [ebp + rvbdata.lpfcr0]           	; <dout> <in> <damp>
	fst    dword [ebp + rvbdata.lpfcr0]           	; <dout> <in> <damp>
	fst    dword [ebp + rvbdata.linecr0+4*edx]    	; <asumr> <in> <damp>
	inc    edx
	cmp    dx,  lencr0
	jne    .norescr0
	xor    edx, edx
.norescr0	mov    [ebp + rvbdata.poscr0], edx
	; right comb 1
	mov    edx,  [ebp + rvbdata.poscr1]
	fld    dword [ebp + rvbdata.linecr1+4*edx]    	; <dv> <asumr> <in> <damp>
	fmul   dword [ebx + rvbcons.gainc1]           	; <dv'> <asumr> <in> <damp>
	fsub   st0,  st2                		; <nv>  <asumr> <in> <damp>
	fsub   dword [ebp + rvbdata.lpfcr1]           	; <v-lp> <asumr> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asumr> <in> <damp>
	fadd   dword [ebp + rvbdata.lpfcr1]           	; <dout> <asumr> <in> <damp>
	fst    dword [ebp + rvbdata.lpfcr1]           	; <dout> <asumr> <in> <damp>
	fst    dword [ebp + rvbdata.linecr1+4*edx]    	; <dout> <asumr> <in> <damp>
	faddp  st1,  st0                		; <asumr'> <in> <damp>
	inc    edx
	cmp    dx,  lencr1
	jne    .norescr1
	xor    edx, edx
.norescr1	mov    [ebp + rvbdata.poscr1], edx
	; right comb 2
	mov    edx,  [ebp + rvbdata.poscr2]
	fld    dword [ebp + rvbdata.linecr2+4*edx]    	; <dv> <asumr> <in> <damp>
	fmul   dword [ebx + rvbcons.gainc2]           	; <dv'> <asumr> <in> <damp>
	fadd   st0,  st2                		; <nv>  <asumr> <in> <damp>
	fsub   dword [ebp + rvbdata.lpfcr2]           	; <v-lp> <asumr> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asumr> <in> <damp>
	fadd   dword [ebp + rvbdata.lpfcr2]           	; <dout> <asumr> <in> <damp>
	fst    dword [ebp + rvbdata.lpfcr2]           	; <dout> <asumr> <in> <damp>
	fst    dword [ebp + rvbdata.linecr2+4*edx]    	; <dout> <asumr> <in> <damp>
	faddp  st1,  st0                		; <asumr'> <in> <damp>
	inc    edx
	cmp    dx,  lencr2
	jne    .norescr2
	xor    edx, edx
.norescr2	mov    [ebp + rvbdata.poscr2], edx
	; right comb 3
	mov    edx,  [ebp + rvbdata.poscr3]
	fld    dword [ebp + rvbdata.linecr3+4*edx]    	; <dv> <asumr> <in> <damp>
	fmul   dword [ebx + rvbcons.gainc3]           	; <dv'> <asumr> <in> <damp>
	fsubrp st2,  st0                		; <asumr> <nv> <damp>
	fxch   st0,  st1                		; <nv> <asumr> <damp>
	fsub   dword [ebp + rvbdata.lpfcr3]           	; <v-lp> <asumr> <damp>
	fmul   st0,  st2                		; <d*(v-lp)> <asumr> <damp>
	fadd   dword [ebp + rvbdata.lpfcr3]           	; <dout> <asumr> <damp>
	fst    dword [ebp + rvbdata.lpfcr3]           	; <dout> <asumr> <damp>
	fst    dword [ebp + rvbdata.linecr3+4*edx]    	; <dout> <asumr> <damp>
	faddp  st1,  st0                		; <asumr'> <damp>
	inc    edx
	cmp    dx,  lencr3
	jne    .norescr3
	xor    edx, edx
.norescr3	mov    [ebp + rvbdata.poscr3], edx

	; step 2b: process the 2 right allpass delays
	; right allpass 0
	mov    edx,  [ebp + rvbdata.posar0]
	fld    dword [ebp + rvbdata.linear0+4*edx]    	; <d0v> <asumr> <damp>
	fld    st0                      		; <d0v> <d0v> <asumr> <damp>
	fmul   dword [ebx + rvbcons.gaina0]           	; <d0v'> <d0v> <asumr> <damp>
	faddp  st2, st0                 		; <d0v> <d0z> <damp>
	fxch   st0, st1                 		; <d0z> <d0v> <damp>
	fst    dword [ebp + rvbdata.linear0+4*edx]
	fmul   dword [ebx + rvbcons.gaina0]           	; <d0z'> <d0v> <damp>
	fsubp  st1, st0                 		; <d0o> <damp>
	inc    edx
	cmp    dl, lenar0
	jne    .noresar0
	xor    edx,edx
.noresar0       mov    [ebp + rvbdata.posar0], edx
	; right allpass 1
	mov    edx,  [ebp + rvbdata.posar1]
	fld    dword [ebp + rvbdata.linear1+4*edx]    	; <d1v> <d0o> <damp>
	fld    st0                      		; <d1v> <d1v> <d0o> <damp>
	fmul   dword [ebx + rvbcons.gaina1]           	; <d1v'> <d1v> <d0o> <damp>
	faddp  st2, st0                 		; <d1v> <d1z> <damp>
	fxch   st0, st1                 		; <d1z> <d1v> <damp>
	fst    dword [ebp + rvbdata.linear1+4*edx]
	fmul   dword [ebx + rvbcons.gaina1]           	; <d1z'> <d1v> <damp>
	fsubp  st1, st0                 		; <d1o> <damp>
	inc    edx
	cmp    dl, lenar1
	jne    .noresar1
	xor    edx,edx
.noresar1       mov    [ebp + rvbdata.posar1], edx

	; step 2c: update right mixing buffer
	fiadd  dword [esi+4]            		; <r> <damp>
	fistp  dword [esi+4]            		; <damp>

	lea    esi,  [esi+16]
	dec    ecx
	jnz    near .sloop

	fstp   st0                      ; -
	popad
	ret
