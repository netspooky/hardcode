;#####################################################################################
;
;
; Farb-Rausch ViruZ II  -  wer das liest, ist rule
;
;
;#####################################################################################


%define		POLY			32  							 ; maximum polyphony
%define		LOWEST		39000000h					 ; out of 16bit range
%define		MDMAXOFFS 1024


%define   FRAME_SIZE 128

section .bss

temp				resd 16
oldfpcw			resd 1


section .text

global _AUX_
_AUX_

fci128         dd 0.0078125
fc64           dd 64.0



pow:
		fyl2x
		fld1
		fld	st1
		fprem
		f2xm1
		faddp		st1, st0
		fscale
		fstp	st1
		ret


;#####################################################################################
;#
;#                            E L I T E G R O U P
;#                             we are very good.
;#
;# World Domination Intro Sound System
;# -> Stereo reverb plugin (reads aux1)
;#
;# Written and (C) 1999 by The Artist Formerly Known As Doctor Roole
;#
;# This is a modified  Schroeder reverb (as found in  csound et al) consisting
;# of four parallel comb filter delay lines (with low pass filtered feedback),
;# followed by two  allpass filter delay lines  per channel. The  input signal
;# is feeded directly into half of the comb delays, while it's inverted before
;# being feeded into the other half to  minimize the response to DC offsets in
;# the incoming signal, which was a  great problem of the original implementa-
;# tion. Also, all of the comb delays are routed through 12dB/oct IIR low pass
;# filters before feeding the output  signal back to the input to simulate the
;# walls' high damping, which makes this  reverb sound a lot smoother and much
;# more realistic.
;#
;# This leaves nothing but the conclusion that we're simply better than you.
;#
;#####################################################################################

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

global _REVERB_
_REVERB_

struc syVReverb
	.revtime	resd 1
	.highcut  resd 1
	.vol      resd 1
	.size
endstruc

revsettings dd 60.0,120.0,7.0

struc syCReverb
  .gainc0	resd 1 					; feedback gain for comb filter delay 0
  .gainc1	resd 1          ; feedback gain for comb filter delay 1
  .gainc2	resd 1          ; feedback gain for comb filter delay 2
  .gainc3	resd 1          ; feedback gain for comb filter delay 3
  .gaina0	resd 1          ; feedback gain for allpass delay 0
  .gaina1	resd 1          ; feedback gain for allpass delay 1
  .gainin	resd 1          ; input gain
  .damp		resd 1          ; high cut   (1-val≤)
	.size
endstruc

struc syWReverb
 .setup   resb syCReverb.size
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

; see struct above
syRvDefs  dd 0.966384599, 0.958186359, 0.953783929, 0.950933178, 0.994260075, 0.998044717
  				dd 1.0  ; input gain
					dd 0.8	; high cut



global _ReverbInit@0
_ReverbInit@0
	pushad
	xor    eax, eax
 	mov    ecx, syWReverb.size
	lea    ebp, [revws]
  mov    edi, ebp
	rep    stosb
  lea    esi, [revsettings]

  fld    dword [esi + syVReverb.revtime]
	fld1
	faddp  st1, st0
	fld    dword [fc64]
	fdivrp st1, st0
	fmul   st0, st0
	xor    ecx, ecx
.rtloop
	  fld  st0
    fld  dword [syRvDefs+4*ecx]
		call pow
		fstp dword [ebp + syWReverb.setup + syCReverb.gainc0 + 4*ecx]
		inc  ecx
		cmp  cl, 6
	jne .rtloop
	fstp   st0

	fld    dword [esi + syVReverb.highcut]
	fmul   dword [fci128]
	fstp    dword [ebp + syWReverb.setup + syCReverb.damp]
	fld    dword [esi + syVReverb.vol]
	fmul   dword [fci128]
	fstp   dword [ebp + syWReverb.setup + syCReverb.gainin]

	popad
	ret


global _ReverbProcess@8
_ReverbProcess@8:
  pushad
  lea    ebp,  [revws]
  mov    esi,  [esp + 36]
  mov    ecx,  [esp + 40]
	fld    dword [ebp + syWReverb.setup + syCReverb.damp]             	; <damp>
  xor    ebx, ebx

.sloop          ; prinzipiell nur ne groﬂe schleife
	; step 1: get input sample
	fld		 dword [esi]																  						; <in''> <damp>
	fadd	 dword [esi+4]  														  						; <in'> <damp>
	fmul	 dword [ebp + syWReverb.setup + syCReverb.gainin]     	; <in> <damp>

	; step 2a: process the 4 left lpf filtered comb delays
	; left comb 0
	mov    edx,  [ebp + syWReverb.poscl0]
	fld    dword [ebp + syWReverb.linecl0+4*edx]    	; <dv> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gainc0]           	; <dv'> <in> <damp>
	fadd   st0,  st1                		; <nv>  <in> <damp>
	fsub   dword [ebp + syWReverb.lpfcl0]           	; <v-lp> <in> <damp>
	fmul   st0,  st2                		; <d*(v-lp)> <in> <damp>
	fadd   dword [ebp + syWReverb.lpfcl0]           	; <dout> <in> <damp>
	fst    dword [ebp + syWReverb.lpfcl0]           	; <dout> <in> <damp>
	fst    dword [ebp + syWReverb.linecl0+4*edx]    	; <asuml> <in> <damp>
	inc    edx
	cmp    dx,  lencl0
  cmove  edx, ebx
	mov    [ebp + syWReverb.poscl0], edx

	; left comb 1
	mov    edx,  [ebp + syWReverb.poscl1]
	fld    dword [ebp + syWReverb.linecl1+4*edx]    	; <dv> <asuml> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gainc1]           	; <dv'> <asuml> <in> <damp>
	fsub   st0,  st2                		; <nv>  <asuml> <in> <damp>
	fsub   dword [ebp + syWReverb.lpfcl1]           	; <v-lp> <asuml> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asuml> <in> <damp>
	fadd   dword [ebp + syWReverb.lpfcl1]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + syWReverb.lpfcl1]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + syWReverb.linecl1+4*edx]    	; <dout> <asuml> <in> <damp>
	faddp  st1,  st0                		; <asuml'> <in> <damp>
	inc    edx
	cmp    dx,  lencl1
  cmove  edx, ebx
	mov    [ebp + syWReverb.poscl1], edx

	; left comb 2
	mov    edx,  [ebp + syWReverb.poscl2]
	fld    dword [ebp + syWReverb.linecl2+4*edx]    	; <dv> <asuml> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gainc2]           	; <dv'> <asuml> <in> <damp>
	fadd   st0,  st2                		; <nv>  <asuml> <in> <damp>
	fsub   dword [ebp + syWReverb.lpfcl2]           	; <v-lp> <asuml> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asuml> <in> <damp>
	fadd   dword [ebp + syWReverb.lpfcl2]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + syWReverb.lpfcl2]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + syWReverb.linecl2+4*edx]    	; <dout> <asuml> <in> <damp>
	faddp  st1,  st0                		; <asuml'> <in> <damp>
	inc    edx
	cmp    dx,  lencl2
  cmove  edx, ebx
	mov    [ebp + syWReverb.poscl2], edx

	; left comb 3
	mov    edx,  [ebp + syWReverb.poscl3]
	fld    dword [ebp + syWReverb.linecl3+4*edx]    	; <dv> <asuml> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gainc3]           	; <dv'> <asuml> <in> <damp>
	fsub   st0,  st2                		; <nv>  <asuml> <in> <damp>
	fsub   dword [ebp + syWReverb.lpfcl3]           	; <v-lp> <asuml> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asuml> <in> <damp>
	fadd   dword [ebp + syWReverb.lpfcl3]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + syWReverb.lpfcl3]           	; <dout> <asuml> <in> <damp>
	fst    dword [ebp + syWReverb.linecl3+4*edx]    	; <dout> <asuml> <in> <damp>
	faddp  st1,  st0                		; <asuml'> <in> <damp>
	inc    edx
	cmp    dx,  lencl3
  cmove  edx, ebx
	mov    [ebp + syWReverb.poscl3], edx

	; step 2b: process the 2 left allpass delays
	; left allpass 0
	mov    edx,  [ebp + syWReverb.posal0]
	fld    dword [ebp + syWReverb.lineal0+4*edx]    	; <d0v> <asuml> <in> <damp>
	fld    st0                      		; <d0v> <d0v> <asuml> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gaina0]           	; <d0v'> <d0v> <asuml> <in> <damp>
	faddp  st2, st0                 		; <d0v> <d0z> <in> <damp>
	fxch   st0, st1                 		; <d0z> <d0v> <in> <damp>
	fst    dword [ebp + syWReverb.lineal0+4*edx]
	fmul   dword [ebp + syWReverb.setup + syCReverb.gaina0]           	; <d0z'> <d0v> <in> <damp>
	fsubp  st1, st0                 		; <d0o> <in> <damp>
	inc    edx
  cmp    dl, lenal0
  cmove  edx, ebx
	mov    [ebp + syWReverb.posal0], edx

	; left allpass 1
	mov    edx,  [ebp + syWReverb.posal1]
	fld    dword [ebp + syWReverb.lineal1+4*edx]    	; <d1v> <d0o> <in> <damp>
	fld    st0                      		; <d1v> <d1v> <d0o> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gaina1]           	; <d1v'> <d1v> <d0o> <in> <damp>
	faddp  st2, st0                 		; <d1v> <d1z> <in> <damp>
	fxch   st0, st1                 		; <d1z> <d1v> <in> <damp>
	fst    dword [ebp + syWReverb.lineal1+4*edx]
	fmul   dword [ebp + syWReverb.setup + syCReverb.gaina1]           	; <d1z'> <d1v> <in> <damp>
	fsubp  st1, st0                 		; <d1o> <in> <damp>
	inc    edx
	cmp    dl, lenal1
  cmove  edx, ebx
	mov    [ebp + syWReverb.posal1], edx

	; step 2c: update left mixing buffer
	fadd  dword [esi]                     ; <out> <in> <damp>
	fstp  dword [esi]                     ; <in> <damp>

	; step 3a: process the 4 right lpf filtered comb delays
	; right comb 0
	mov    edx,  [ebp + syWReverb.poscr0]
	fld    dword [ebp + syWReverb.linecr0+4*edx]    	; <dv> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gainc0]           	; <dv'> <in> <damp>
	fadd   st0,  st1                		; <nv>  <in> <damp>
	fsub   dword [ebp + syWReverb.lpfcr0]           	; <v-lp> <in> <damp>
	fmul   st0,  st2                		; <d*(v-lp)> <in> <damp>
	fadd   dword [ebp + syWReverb.lpfcr0]           	; <dout> <in> <damp>
	fst    dword [ebp + syWReverb.lpfcr0]           	; <dout> <in> <damp>
	fst    dword [ebp + syWReverb.linecr0+4*edx]    	; <asumr> <in> <damp>
	inc    edx
	cmp    dx,  lencr0
  cmove  edx, ebx
	mov    [ebp + syWReverb.poscr0], edx

	; right comb 1
	mov    edx,  [ebp + syWReverb.poscr1]
	fld    dword [ebp + syWReverb.linecr1+4*edx]    	; <dv> <asumr> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gainc1]           	; <dv'> <asumr> <in> <damp>
	fsub   st0,  st2                		; <nv>  <asumr> <in> <damp>
	fsub   dword [ebp + syWReverb.lpfcr1]           	; <v-lp> <asumr> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asumr> <in> <damp>
	fadd   dword [ebp + syWReverb.lpfcr1]           	; <dout> <asumr> <in> <damp>
	fst    dword [ebp + syWReverb.lpfcr1]           	; <dout> <asumr> <in> <damp>
	fst    dword [ebp + syWReverb.linecr1+4*edx]    	; <dout> <asumr> <in> <damp>
	faddp  st1,  st0                		; <asumr'> <in> <damp>
	inc    edx
	cmp    dx,  lencr1
  cmove  edx, ebx
	mov    [ebp + syWReverb.poscr1], edx

	; right comb 2
	mov    edx,  [ebp + syWReverb.poscr2]
	fld    dword [ebp + syWReverb.linecr2+4*edx]    	; <dv> <asumr> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gainc2]           	; <dv'> <asumr> <in> <damp>
	fadd   st0,  st2                		; <nv>  <asumr> <in> <damp>
	fsub   dword [ebp + syWReverb.lpfcr2]           	; <v-lp> <asumr> <in> <damp>
	fmul   st0,  st3                		; <d*(v-lp)> <asumr> <in> <damp>
	fadd   dword [ebp + syWReverb.lpfcr2]           	; <dout> <asumr> <in> <damp>
	fst    dword [ebp + syWReverb.lpfcr2]           	; <dout> <asumr> <in> <damp>
	fst    dword [ebp + syWReverb.linecr2+4*edx]    	; <dout> <asumr> <in> <damp>
	faddp  st1,  st0                		; <asumr'> <in> <damp>
	inc    edx
	cmp    dx,  lencr2
  cmove  edx, ebx
	mov    [ebp + syWReverb.poscr2], edx

	; right comb 3
	mov    edx,  [ebp + syWReverb.poscr3]
	fld    dword [ebp + syWReverb.linecr3+4*edx]    	; <dv> <asumr> <in> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gainc3]           	; <dv'> <asumr> <in> <damp>
	fsubrp st2,  st0                		; <asumr> <nv> <damp>
	fxch   st0,  st1                		; <nv> <asumr> <damp>
	fsub   dword [ebp + syWReverb.lpfcr3]           	; <v-lp> <asumr> <damp>
	fmul   st0,  st2                		; <d*(v-lp)> <asumr> <damp>
	fadd   dword [ebp + syWReverb.lpfcr3]           	; <dout> <asumr> <damp>
	fst    dword [ebp + syWReverb.lpfcr3]           	; <dout> <asumr> <damp>
	fst    dword [ebp + syWReverb.linecr3+4*edx]    	; <dout> <asumr> <damp>
	faddp  st1,  st0                		; <asumr'> <damp>
	inc    edx
	cmp    dx,  lencr3
  cmove  edx, ebx
	mov    [ebp + syWReverb.poscr3], edx


	; step 2b: process the 2 right allpass delays
	; right allpass 0
	mov    edx,  [ebp + syWReverb.posar0]
	fld    dword [ebp + syWReverb.linear0+4*edx]    	; <d0v> <asumr> <damp>
	fld    st0                      		; <d0v> <d0v> <asumr> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gaina0]           	; <d0v'> <d0v> <asumr> <damp>
	faddp  st2, st0                 		; <d0v> <d0z> <damp>
	fxch   st0, st1                 		; <d0z> <d0v> <damp>
	fst    dword [ebp + syWReverb.linear0+4*edx]
	fmul   dword [ebp + syWReverb.setup + syCReverb.gaina0]           	; <d0z'> <d0v> <damp>
	fsubp  st1, st0                 		; <d0o> <damp>
	inc    edx
	cmp    dl, lenar0
  cmove  edx, ebx
	mov    [ebp + syWReverb.posar0], edx

	; right allpass 1
	mov    edx,  [ebp + syWReverb.posar1]
	fld    dword [ebp + syWReverb.linear1+4*edx]    	; <d1v> <d0o> <damp>
	fld    st0                      		; <d1v> <d1v> <d0o> <damp>
	fmul   dword [ebp + syWReverb.setup + syCReverb.gaina1]           	; <d1v'> <d1v> <d0o> <damp>
	faddp  st2, st0                 		; <d1v> <d1z> <damp>
	fxch   st0, st1                 		; <d1z> <d1v> <damp>
	fst    dword [ebp + syWReverb.linear1+4*edx]
	fmul   dword [ebp + syWReverb.setup + syCReverb.gaina1]           	; <d1z'> <d1v> <damp>
	fsubp  st1, st0                 		; <d1o> <damp>
	inc    edx
	cmp    dl, lenar1
  cmove  edx, ebx
	mov    [ebp + syWReverb.posar1], edx

	; step 2c: update right mixing buffer
	fadd  dword [esi+4]               ; <out> <damp>
	fstp  dword [esi+4]            		; <damp>

	lea    esi,  [esi+8]
	dec    ecx
	jnz    near .sloop

	fstp   st0                      ; -
	popad
	ret 8

section .bss

revws resb syWReverb.size
