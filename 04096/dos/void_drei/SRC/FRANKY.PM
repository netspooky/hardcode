
; ƒƒƒ copyright (c) 2k-1 by frank baumgartner (franky@scene.at) ƒƒƒ

; ow, ow! shiva did all the gfx, so why has only franky such a cool
; headline in this source file? Just because he wrote it? Bad franky!

;
; ƒƒƒ special thanks to: ƒƒƒ
;
;  - Masamichi Kirikae ... designer of voice spectra vocoder,
;                          gave me cool tips & techical info!
;  - Acoustical Society
;    of America	       ... for sending me a copy of
;                          Dennis H. Klatt's article about
;                          speech analysis & synthesis
;  - Danko,
;    Magic^Singularity
;    Wilfried Welti    ... for more general tips
;

;DEBUG		=	1

DELAY_LEN	=	( SAMP_RATE / 9 )

DELAY_OFF	=	( 4 SHL 20 )	;ƒƒƒ mem-pool ƒƒƒ
VOCODER_OFF     =       DELAY_OFF + 10000h

VC_SPF		=	110

T_INTRO_ZERO	STRUC           	;ƒƒƒ zero data ƒƒƒ

        timer           dd      ?       ;ƒƒƒ intro timer ƒƒƒ
	timer_ctrl	dw	?
	timer_ctrl_pos	dd	?
	timer_flags	db	?
        sq_pos          dd      ?
        pm_mpool        dd      ?
        pm_ds           dw      ?

        sb_dma          dw      ?       ;ƒƒƒ SB DMA output ƒƒƒ
        sb_base         dw      ?
        sb_dmaseg       dw      ?
        sb_mixpos       dd      ?

	vc_pos		dd	?

        tb_il           dd      ?       ;ƒƒƒ tb 303 ƒƒƒ
        tb_uc           dd      ?
        tb_saw          dd      ?
        tb_env          dd      ?
        tb_reso         dd      ?
        tb_len          dd      ?
        tb_sqpos        dd      ?

        ch_i1           dd      ?       ;ƒƒƒ closed hihat ƒƒƒ
        ch_i2           dd      ?
        ch_env          dd      ?

        sn_uc           dd      ?       ;ƒƒƒ u96 sonar ƒƒƒ
        sn_il           dd      ?
        sn_env          dd      ?

        bd_il           dd      ?       ;ƒƒƒ bass drum ƒƒƒ
        bd_uc           dd      ?
        bd_env          dd      ?

        dl_pos          dd      ?       ;ƒƒƒ delay, flanger ƒƒƒ
        fl_pos          dd      ?
        fl_lfo          dd      ?

        fpu_save        dd      32 dup ( ? )

ENDS

T_INTRO_INIT    STRUC                   ;ƒƒƒ initialized ƒƒƒ

                                        ;ƒƒƒ closed hihat ƒƒƒ
        ch_gain         dd      0.000000000075
        ch_env_mul      dd      0.999
        ch_seq          db      1, 1, 6, 1

        tb_saw_inc      dd      0.0014  ;ƒƒƒ tb 303 ƒƒƒ
        tb_cut          dd      0.01	;.01
        tb_reso_init    dd      0.15	;.15
        tb_env_init     dd      0.1	;.1
        tb_env_mul      dd      0.9996	;.9996
        tb_reso_mul     dd      1.0002
        tb_seq          db      1, 0, 1, 1, 0
	tb_mul		dw	5

        sn_cut          dd      0.075   ;ƒƒƒ u96 sonar ƒƒƒ
        sn_env_mul      dd      0.999975
        sn_reso         dd      0.999
        sn_gain         =       ch_gain

        bd_cut          dd      0.025	;ƒƒƒ bass drum ƒƒƒ
        bd_env_mul      dd      0.99975

        dl_feedback     dd      0.2     ;ƒƒƒ delay, flanger ƒƒƒ
        fl_lfo_frq      dd      0.000588
        fl_max          dw      350

        vc_f0           dd      0.00075 ;ƒƒƒ vocoder ƒƒƒ
	vc_speed	dd	0.002
	vc_gain		dd	0.003
	vc_asp_gain	dd	0.000000000001

        snd_gain        dw      14

ENDS

tb_hit  MACRO                           ;ƒƒƒ tb 303 note hit ƒƒƒ

	xor	eax, eax
        mov     [ebx].tb_saw, eax 

        mov     eax, [edx].tb_env_init
        mov     [ebx].tb_env, eax

ENDM

tb_wav  MACRO                           ;ƒƒƒ tb wave function ƒƒƒ

        fld     [edx].tb_env_mul        ;ƒƒƒ filter env. ƒƒƒ
        fmul    [ebx].tb_env
        fst     [ebx].tb_env
        fadd    [edx].tb_cut

        fld     [ebx].tb_saw            ;ƒƒƒ saw-tooth ƒƒƒ
	frndint
        fsubr   [ebx].tb_saw
        dec     [ebx].tb_len            ;end of note ?
	js	@@tb_done
        fadd    [edx].tb_saw_inc
@@tb_done:
        fst     [ebx].tb_saw

        fsub    [ebx].tb_uc             ;ƒƒƒ IIR low-pass ƒƒƒ
        fld     [ebx].tb_il
        fld     [edx].tb_reso_mul
        fmul    [ebx].tb_reso           ;reso env.
        fst     [ebx].tb_reso
        fmulp   st(1)
        fsubp	st(1)
	fmul	st(0), st(1)
        fadd    [ebx].tb_il
        fst     [ebx].tb_il
	fmulp	st(1)
        fadd    [ebx].tb_uc
        fst     [ebx].tb_uc

        fldpi                          	;ƒƒƒ distortion ƒƒƒ
	fmulp	st(1)
	fld1
	fpatan

ENDM

ch_wav  MACRO                           ;ƒƒƒ closed hihat wave ƒƒƒ

        fld     [edx].ch_env_mul        ;ƒƒƒ envelope ƒƒƒ
        fmul    [ebx].ch_env
        fst     [ebx].ch_env
        fimul   dptr [esp]              ;random

	fld	st(0)
	fsub	[ebx].ch_i2		;ƒƒƒ IIR high-pass ƒƒƒ
	fld	[ebx].ch_i1
	fstp	[ebx].ch_i2
	fxch	st(1)
	fstp	[ebx].ch_i1

ENDM

sn_wav  MACRO                           ;ƒƒƒ u96 sonar wave ƒƒƒ

        fld     [edx].sn_env_mul      	;ƒƒƒ envelope ƒƒƒ
        fmul    [ebx].sn_env
        fst     [ebx].sn_env
        fimul	dptr [esp]              ;random

        fld     [ebx].sn_uc             ;ƒƒƒ IIR band-pass ƒƒƒ
	fmul	[edx].sn_cut
        fadd    [ebx].sn_il
        fmul    [edx].sn_reso
        faddp   st(1)
        fst     [ebx].sn_il

	fmul	[edx].sn_cut
        fsubr   [ebx].sn_uc
        fst     [ebx].sn_uc

ENDM

bd_wav  MACRO                           ;ƒƒƒ bass drum ƒƒƒ

        fld     [edx].bd_env_mul      	;ƒƒƒ envelope ƒƒƒ
        fmul    [ebx].bd_env
        fst     [ebx].bd_env

        fld     [ebx].bd_uc             ;ƒƒƒ oscillator ƒƒƒ
        fmul    st(0), st(1)
        fsubr   [ebx].bd_il
        fst     [ebx].bd_il

        fmulp   st(1)
        fadd    [ebx].bd_uc
	fmul	[edx].bd_env_mul
        fst     [ebx].bd_uc

        fldlg2                          ;ƒƒƒ distortion ƒƒƒ
	fpatan

ENDM

fx_delay        MACRO                   ;ƒƒƒ delay ƒƒƒ

	mov	eax, [ebx].dl_pos
	dec	eax
	jns	@@dl_ok
	mov	eax, DELAY_LEN - 1
@@dl_ok:
	mov	[ebx].dl_pos, eax
        mov     ecx, [ebx].pm_mpool
        lea     ecx, [ecx].DELAY_OFF

	fld	dptr [ecx + 4*eax]	;delay w/ feedback
	fmul	[edx].dl_feedback
	faddp	st(1)
	fst	dptr [ecx + 4*eax]

ENDM

T_BIQUAD        STRUC                   ;ƒƒƒ biquad IIR filter ƒƒƒ

        i1              dd      ?       ;delay line (input)
        i2              dd      ?
        z1              dd      ?       ;delay line (output)
        z2              dd      ?

ENDS

T_BAND          STRUC                   ;ƒƒƒ vocoder band ƒƒƒ

        b               dd      ?       ;IIR coeff's
        c               dd      ?
        a               dd      ?

        vc_amp          dd      ?	;band modulation
	vc_newamp	dd	?

ENDS

T_VC_ZERO       STRUC                   ;ƒƒƒ vocoder ƒƒƒ

                        dd      ?
        vc_dirac        dd      4 dup ( ? )

        vc_timer        dd      ?
	vc_sptr		dd	?
        vc_asp          dd      ?       ;aspiration noise
        vc_newasp       dd      ?

        vc_band T_BAND   12   dup ( )   ;vocoder band
        vc_iir  T_BIQUAD 12*6 dup ( )   ;IIR biquads (12 dB)

ENDS

bq_init MACRO                           ;ƒƒƒ init IIR biquad ƒƒƒ

	lea	ebx, bq_bands
        lea     edi, intro_vocoder.vc_band

        mov     cl, 12
@@bq_init:
        fild    wptr [ebx + 2]
        fisub   wptr [ebx]
        fmul    mpi_ln2                 ;r = e^( -pi*Ta*bw )
	f2xm1
	fld1
	faddp	st(1)

        fild    wptr [ebx]              ;b = 2 * r * cos( 2*pi*Ta*f )
	inc	ebx
	inc	ebx
        fiadd   wptr [ebx]
        fmul    pi_Ta
        fcos
        fadd    st(0), st(0)
        fmul    st(0), st(1)
        fstp    dptr [edi].b

        fmul    st(0), st(0)            ;c = r^2
        fst     dptr [edi].c

        fld1                            ;a = 1.0 - r^2
        fsubrp  st(1)
        fstp    dptr [edi].a		;( normally: 1.0 - 2.0*r + r^2 )

	lea	edi, [edi].SIZE T_BAND
        loop    @@bq_init

ENDM

bq_wav	MACRO                           ;ƒƒƒ biquad IIR filter ƒƒƒ

        ; [eax] -> T_BIQUAD
        ; [ebx] -> T_BAND
        ; st(0) = input/output

        fld     st(0)
        fsub    [eax].i2                ;y = a*(in - i2) + b*z1 - c*z2
	fld	[eax].z2
	fmul	[ebx].c
	fxch	st(1)
        fmul    [ebx].a
        fsubrp	st(1)
        fld     [eax].z1
        fst     [eax].z2
        fmul    [ebx].b
        faddp   st(1)
	fld	[eax].i1
	fstp	[eax].i2
        fst     [eax].z1
	fxch	st(1)
        fstp    [eax].i1

ENDM

vc_wav 	MACRO                           ;ƒƒƒ vocoder wave ƒƒƒ

	push	ebx
	lea	ebx, intro_vocoder

	fldz

        mov     eax, [ebx].vc_timer
        test    eax, eax                ;activated ?
        js      @@vc_done

        xor     ecx, ecx
	push	ecx
        mov     cl, 4
@@s_dirac:				;ƒƒƒ super-dirac ƒƒƒ
	fadd	[edx].vc_f0
        fld     dptr [ebx + 4*ecx]

        fld     st(0)                   ;saw
	frndint
        fsubr   st(0), st(1)
        fadd    st(0), st(2)
        fst     dptr [ebx + 4*ecx]

        fsubp	st(1)			;f' -> dirac
	fadd	dptr [esp]
	fstp	dptr [esp]

        loop	@@s_dirac
	ffree	st(0)
	fld	dptr [esp]
	pop	ecx

        fld     [ebx].vc_newasp         ;ƒƒƒ aspiration noise ƒƒƒ
        fsub    [ebx].vc_asp
        fmul    [edx].vc_speed
        fadd    [ebx].vc_asp
        fst     [ebx].vc_asp
	fimul	dptr [esp + 4]		;random
	fmul	[edx].vc_asp_gain
        faddp   st(1)

	fldz
        lea     eax, [ebx].vc_iir
	lea	ebx, [ebx].vc_band

        mov     ch, 12                  ;ƒƒƒ filter bank ƒƒƒ
@@bank:

        fld     [ebx].vc_newamp         ;env. follower
        fsub    [ebx].vc_amp
        fmul    [edx].vc_speed
        fadd    [ebx].vc_amp
        fst     [ebx].vc_amp
        fmul    st(0), st(2)            ;modulator

        mov     cl, 6
@@bq:					;6 x 12 dB
        bq_wav
	lea	eax, [eax].SIZE T_BIQUAD
        dec     cl
	jnz	@@bq

	faddp	st(1)
	lea	ebx, [ebx].SIZE T_BAND
        dec     ch
        jnz     @@bank
	ffree	st(1)

	fmul	[edx].vc_gain

@@vc_done:
	pop	ebx

ENDM

vc_ctrl	MACRO				;ƒƒƒ vocoder control ƒƒƒ

	pushad
	lea	ebx, intro_vocoder

        dec     [ebx].vc_timer
	jns	@@vcc_done

@@vcc:					;ƒƒƒ new frame ƒƒƒ
	mov	eax, [ebx].vc_sptr
	inc	[ebx].vc_sptr
	lea	esi, vc_speech[ 2*eax ]
	lodsb				;get timing, phoneme
	movzx	ecx, al
        mov     [ebx].vc_timer, ecx
	lodsb
	imul	eax, 13

	lea	esi, vc_franky[ eax ]
	xor	eax, eax

	lodsb				;ƒƒƒ new aspiration ƒƒƒ
	push	eax
	fild	dptr [esp]
	pop	eax
	fstp	[ebx].vc_newasp

	xor	ecx, ecx
	mov	cl, 12
@@bloop:				;ƒƒƒ new bq-target ƒƒƒ
	lodsb
	push	eax
	fild	dptr [esp]
	pop	eax
	fstp	[ebx].vc_band[0].vc_newamp
	lea	ebx, [ebx].SIZE T_BAND
	loop	@@bloop

@@vcc_done:
	popad

ENDM

vc_precalc      MACRO                   ;ƒƒƒ precalculator ƒƒƒ

	bq_init
	lea	ebx, intro_zero
	lea	edx, intro_init

        mov     edi, [ebx].pm_mpool
        lea     edi, [edi].VOCODER_OFF
	mov	[ebx].vc_pos, edi

        mov     cx, 300 * 14
@@vc_fl:
        push    ecx

        vc_ctrl                         ;ƒƒƒ vocoder control ƒƒƒ
        add     [ebx].fl_lfo, 4

        mov     esi, VC_SPF
@@vc_l:
	call	rand
	push	eax
        vc_wav
	pop	eax
        call    fx_flanger
        fstp    dptr [edi]
        lea     edi, [edi].4
	dec	esi
	jnz	@@vc_l

        pop    	ecx
        cmp cl, 0
        jnz @nodot
        call precalc_dot
        @nodot:
	dec	ecx
        jnz	@@vc_fl

	mov	[ebx].fl_lfo, ecx

ENDM

	CODE_32		SEGMENT
baseoffset:

rnd_seed        LABEL   DWORD

pm_entry:                               ;˛˛˛˛ CS, DS = ES = SS ˛˛˛˛
        prepareblitter
        initfastperlin
        makenoise ;once at init.. one mb of pure random noise
        makealltextures
        makeshademap
        initfont

        mov     intro_zero.pm_ds, ds
        mov     intro_zero.pm_mpool, ebp

        vc_precalc			;ƒƒƒ vocoder precalc ƒƒƒ
        push    ecx

	mov	ax, 0204h		;ƒƒƒ get RTC int ƒƒƒ
	mov	bl, 08h
	int	31h

	inc	eax			;ƒƒƒ set RTC int ƒƒƒ
	pushad
	mov	cx, cs
	lea	edx, pm_timer
	int	31h

pm_main:

        @loopy:

            mov eax, intro_zero.timer
            shr eax, 3
            mov globalt, eax

            makematrix
            runscript
            ;first back fx
            mov edi, ebp
            db 0bbh
            backfx1:
            dd offset grid_putlinear
            rendergrid

            lea ebx, [bigflag]
            ;postfx for screen1
            test byte ptr[ebx], 01b
            jz @noinvert1
            mov edi, ebp
            call invert
            @noinvert1:

            ;xfade the two
            test byte ptr[ebx], 0100b
            jz @noxfade
            mov edi, ebp
            fild globalt
            fidiv i_32
            fsin
            fabs
            fimul i_255
            push eax
            fistp dword ptr [esp]
            pop eax
             xfade
            @noxfade:

            ;render first particels
            mov edi, ebp
            db 0bbh ;mov ebx
            particelfunc1:
            dd offset particel_starfield
            call renderparticels

            test byte ptr bigflag, 01000b
            jz @nofatfx
            mov edi, ebp
            call invert
            ;render second particels
            mov edi, ebp
            lea ebx, [particel_star]
            call renderparticels
            @nofatfx:

            writestring

            call flipfunction
        in al, 60h
        dec al
        jnz @loopy

@exit:         
pm_exit:

        popad                           ;ƒƒƒ reset RTC int ƒƒƒ
	int	31h

;       mov     al, 36h                 ;ƒƒƒ reset RTC freq. ƒƒƒ
;	out     43h, al
;	xor     eax, eax
;	out     40h, al
;	out     40h, al
                                        ;ƒƒƒ stop DMA output ƒƒƒ
;	push    eax
        mov     edx, dptr intro_zero.sb_base
        call    dsp_reset

IFDEF	DEBUG

;	debug_save "coeff.dat", intro_vocoder.vc_band, 5*4*12

	mov	ebp, DMA_BUFOFF - 4096
	debug_save "debug.smp", [ebp], DMA_BUFSIZE*2

ENDIF

	mov	ax, 03h			;textmode
	int	10h

	.exit				;(ret/cd20h don't work!)

pm_timer	PROC                    ;ƒƒƒ RTC timer ƒƒƒ
	cld
	pushad
	push	ds es
        lea     ebx, intro_zero
        mov     ds, cs:[ebx].pm_ds
	inc	[ebx].timer
        fnsave  [ebx].fpu_save
	fninit

	mov     edx, dptr [ebx].sb_base	;ƒƒƒ SB IRQ ACK ƒƒƒ
	add     dl, _DSP_STATUS
	in      al, dx

	lea	edx, intro_init

	dec	[ebx].timer_ctrl	;ƒƒƒ control script ƒƒƒ
	jns	@@no_ctrl

	mov	esi, [ebx].timer_ctrl_pos
	lea	esi, [esi].intro_script
	lodsw
	mov	[ebx].timer_ctrl, ax
	lodsb
	mov	[ebx].timer_flags, al
	add	wptr [ebx].timer_ctrl_pos, 3
@@no_ctrl:

        test    [ebx].timer_flags, 2    ;ƒƒƒ flanger control ƒƒƒ
        jz      @@no_fl
        inc     [ebx].fl_lfo
@@no_fl:

        mov     eax, [ebx].timer        ;ƒƒƒ sequencer ƒƒƒ
	test	al, SPEED - 1
	jnz	@@no_seq

	test	[ebx].timer_flags, 4
	jz	@@no_tb2

        mov     ecx, [ebx].tb_sqpos   	;ƒƒƒ tb 303 ƒƒƒ
        test    [edx].tb_seq[ ecx ], -1
	jz	@@no_tb
        tb_hit
        mov     [ebx].tb_len, 8192
@@no_tb:
	inc	ecx
	cmp	cl, 4
	jna	@@tb_wrap
	xor	ecx, ecx
@@tb_wrap:
        mov     [ebx].tb_sqpos, ecx
@@no_tb2:
        mov     eax, [edx].tb_reso_init
        mov     [ebx].tb_reso, eax

        movzx   eax, bptr [ebx].sq_pos
        inc     [ebx].sq_pos
	and	al, 31

	test	[ebx].timer_flags, 64	;ƒƒƒ tb 303 env. mod ƒƒƒ
	jz	@@no_tbe
        cmp     al, 20
        jne     @@no_tbe
        fld     [edx].tb_env_init       ;env. trigger
	fimul	[edx].tb_mul
        fstp    [ebx].tb_env
	fldlg2
	fmul	[edx].tb_reso_init	;increase reso
	fstp	[ebx].tb_reso
@@no_tbe:

	test	[ebx].timer_flags, 32
	jz	@@no_sn
        cmp	al, 20                  ;ƒƒƒ u96 sonar ƒƒƒ
        jne     @@no_sn
	fld	[edx].sn_gain
	fadd	st(0), st(0)
        fstp    [ebx].sn_env
@@no_sn:

	test	[ebx].timer_flags, 8
	jz	@@no_bd
        cmp     al, 31 - 12             ;ƒƒƒ bass drum ƒƒƒ
        je      @@bd_btw
        and     al, 3
        jnz     @@no_bd
@@bd_btw:
	fld1
        fstp    [ebx].bd_il
        mov     ecx, [edx].bd_cut
        mov     [ebx].bd_env, ecx
@@no_bd:

	test	[ebx].timer_flags, 16
	jz	@@no_ch
	and	al, 3
        mov     al, [edx].ch_seq[eax]   ;ƒƒƒ closed hihat ƒƒƒ
	push	eax
	fild	dptr [esp]
	pop	eax
	fmul	[edx].ch_gain
	fstp	[ebx].ch_env
@@no_ch:

@@no_seq:

	push	ebx edx
	sb_dma_pos			;ƒƒƒ get DMA pos ƒƒƒ
	pop	edx ebx
        mov     edi, [ebx].sb_mixpos
        mov     [ebx].sb_mixpos, esi

@@sb_mixloop:                           ;ƒƒƒ synthesizer wave-loop ƒƒƒ

        call    rand
	push	eax			;random -> [esp]

        tb_wav

	test	[ebx].timer_flags, 1	;vc
	jz	@@no_vc_w
	mov	eax, [ebx].vc_pos
	fadd	dptr [eax]
	lea	eax, [eax].4
	mov	[ebx].vc_pos, eax
@@no_vc_w:
        sn_wav
        faddp   st(1)
        fx_delay
        bd_wav
	faddp	st(1)
	ch_wav
	faddp	st(1)
        call    fx_flanger

        fimul   [edx].snd_gain          ;amplify, convert ...
	fistp	dptr [esp]
	pop	eax
	xor	al, 80h
	stosb
	and	di, DMA_BUFSIZE - 1
	cmp	edi, esi		;do another sample ?
	jne	@@sb_mixloop

	mov	al, 20h			;EOI
	out	20h, al
        fnrstor [ebx].fpu_save
        pop     es ds
	popad
	iretd
pm_timer	ENDP

rand    PROC                            ;ƒƒƒ permutational random ƒƒƒ

        mov     eax, rnd_seed
        mov     ecx, eax
        shr     ecx, 3
        xor     ecx, eax
        shr     ecx, 1
        rcr     eax, 1
	mov	rnd_seed, eax

        ret
rand    ENDP

fx_flanger      PROC                    ;ƒƒƒ flanger ƒƒƒ

        lea     ecx, flange_buf

        mov     eax, [ebx].fl_pos
        inc     eax
        and     ah, 1
        mov     [ebx].fl_pos, eax

        fst     dptr [ecx + 4*eax]

        fild    [ebx].fl_lfo            ;LFO
	fmul	[edx].fl_lfo_frq
	fsin
	fabs
	fimul	[edx].fl_max
	push	eax
	fistp	dptr [esp]
        sub     ax, [esp]
        and     ah, 1
        fadd    dptr [ecx + 4*eax]
        pop     eax
@nullfunc:
        ret
fx_flanger      ENDP

        CODE_32 	ENDS

	DATA		SEGMENT		;ƒƒƒ initialized data ƒƒƒ

intro_init      T_INTRO_INIT    { }     ;ƒƒƒ initialized ƒƒƒ

bq_bands        LABEL   WORD            ;ƒƒƒ IIR bands ƒƒƒ

        dw      90, 130, 190, 280, 410, 610, 900
        dw      1340, 1950, 2800, 4100, 6070, 15000

mpi_ln2         dd     -0.00007
		;-0.000102775     ; - pi * (ln(2)*44100)^-1
pi_Ta           dd      0.000071238     ;   pi * 44100^-1

vc_franky	LABEL	BYTE		;ƒƒƒ dictionary ƒƒƒ
	;
        ;ƒƒƒƒƒƒƒ ASP ƒƒƒƒƒ//ƒƒƒƒƒ- EQ setup ƒƒƒƒƒƒƒ//ƒƒƒƒƒƒƒƒ-
	;
        db        0,    0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0
        db        0,  128, 128,   0,   0,   0, 255, 255, 128,  32,  16,   0,   0        ;a
        db        0,  128, 128, 255, 255, 128,   0,   0,   0, 128,  64,   0,   0        ;e
        db        0,  128, 128,   0,   0,   0,   0,   0,   0,  32,  64,  64,   4        ;i
        db        0,  128, 128,   0, 255, 255,   0,   0,   0,   0,   0,   0,   0        ;o
        db        0,  255, 255, 255,   0,   0,   0,   0,   0,   0,   0,   0,   0        ;u
        db      255,    4,   4,   4,   4,   4,   4,   8,   8,   8,   8,   4,   4        ;f
        db        0,  255, 255, 255, 0, 0, 0, 255, 255, 255,   0,   0,   0        	;k
        db        0,  255, 255, 255,   0,   0,   0,   0,   0,   0,   0,   0,   0        ;m
        db        0,  255, 255,   0,  64,  32,  16,  32,  16,   0,   0,   0,   0        ;n
        db        0,  64, 64, 64, 64, 64, 64,  32,  16,  8,   4,   0,   0               ;r
        db      200,   0,  0,   0,   0,   0,   0,  0,  0,  0,  0,  0,  6                ;s
        db      255,    0,   0,   0,   0,   0,   0,  0,  0,  24,  16, 16,   0           ;sch
        db      255,    0,   0,   0,   0,   0,   0,  64, 128, 255, 255, 255,   0        ;t
        db      255,    0,   0,   0,   0,   0,   0,   0,   0,   0,  64,  64,  24        ;d
        db        0,  255, 255, 255,   0,   0,   0,  32,  128,  128,  32,   0,   0      ;Å
        db      255,  255,   0, 255, 255, 255, 255,   0,   0,   0,   0,   0,   0        ;p
	;
        ;ƒƒƒƒƒ//ƒƒƒƒƒ- index  ƒƒƒƒƒƒƒ//ƒƒƒƒƒƒƒ
	;
	_vPause	=	0
	_vA	=	1
        _vE     =       2
        _vI     =       3
        _vO     =       4
        _vU     =       5
        _uD     equ     < 40, 0,  0,14,  10, 0 >
        _vF     =       6
        _uK     equ     < 20, 0,  0, 7,  20, 0 >
        _vM     =       8
        _vN     =       9
        _uR2    equ     < 20, 10 >
        _vS     =       11
        _vSCH   =       12
        _uT     equ     < 40, 0,  0, 13 >
	_uT2	equ	< 40, 0,  0, 13,  20, 0 >
        _vö     =       15
        _uP     equ     < 10, 16, 10, 0 >

        _vAND   equ     < 15, _vA,  40, _vE,  70, _vN,  _uD >
        _vARE   equ     < 40, _vA,  _uR >

vc_speech	LABEL	BYTE		;ƒƒƒ vocoder script ƒƒƒ

	db	255, 0

        db      _uT2,  30, _vE		;the future is now
        db      80, 0
        db      20, _vF, 4, _vI,  60, _vU,  _uT,  30, _vSCH,  30, _vA
        db      200, 0
        db      30, _vI,  20, _vS
        db      32, 0
        db      20, _vN, 50, _vA, 40, _vO

REPT	2
	db	255, 0
ENDM
                                        ;shiva
        db      20, _vSCH,  40, _vI,  30, _vF,  40, _vA
	db	128, 0

        db      _vAND                   ; &
	db	128, 0

                                        ;franky
        db      40, _vF,  _uR2,  0, _vA, 35, _vE,  50, _vN,  _uK,  40, _vI

REPT 2
	db	255, 0
ENDM

        db      20, _vA,  30, _vE,  _uT ;at symposium
        db      128, 0
        db      50, _vS,  50, _vö,  50, _vM,  _uP,  60, _vO,  50, _vS,  50, _vI,  50, _vU,  50, _vM

	db	48, 0

					;1999
	db	20, _vN,  10, _vA,  30, _vI,  20, _vN,  _uT2,  40, _vI,  30, _vN,  40, 0
        db      20, _vN,  10, _vA,  30, _vI,  20, _vN,  _uT2,  40, _vI,  40, 0
	db	20, _vN,  10, _vA,  40, _vI,  70, _vN

REPT 3
	db	255, 0
ENDM

intro_script	LABEL WORD		;ƒƒƒ intro script ƒƒƒ

	;1 = vc, 2 = flanger, 4 = tb, 8 = bd, 16 = ch, 32 = u96, 64 = tb-env

        ;ticks: 0
	dw	TIMER_FREQ * 12
	db	32
        ;ticks: 460
        dw      TIMER_FREQ * 3 + TIMER_FREQ / 2
	db	1
        ;ticks: 134
	dw	TIMER_FREQ * 6
	db	8
        ;ticks: 230
        dw      TIMER_FREQ * 7 + TIMER_FREQ / 4
	db	16 + 8
        ;ticks: 278
        dw      TIMER_FREQ * 11 + TIMER_FREQ / 2
        db      16 + 8 + 4
        ;ticks: 441
        dw      TIMER_FREQ * 15
        db      64 + 32 + 16 + 8 + 4
        ;ticks: 576
	dw	TIMER_FREQ * 4
	db	32 + 16
        ;ticks: 154
	dw	TIMER_FREQ * 3 + TIMER_FREQ / 2
	db	32 + 16 + 1
        ;ticks: 134
        dw      TIMER_FREQ * 5 + TIMER_FREQ * 3 / 4
        db      32 + 16
        ;ticks: 221
	dw	TIMER_FREQ * 18
	db	32 + 16 + 8 + 4 + 2
        ;ticks: 691
	dw	TIMER_FREQ * 1 + TIMER_FREQ / 2
	db	32 + 16 + 8 + 4
        ;ticks: 57
        dw      TIMER_FREQ * 6
        db      32 + 16 + 8 + 4 + 2
        ;ticks: 230
	dw	TIMER_FREQ * 4
	db	32 + 16
        ;ticks: 154
	dw	TIMER_FREQ * 5
	db	32 + 16 + 1
        ;ticks: 192
	dw	TIMER_FREQ * 1
	db	32 + 16
        ;ticks: 38
        dw      TIMER_FREQ * 8
        db      32
        ;ticks: 154

	DATA	ENDS

        ZDATA	SEGMENT			;ƒƒƒ zero data ƒƒƒ
ZERO_START:

intro_zero      T_INTRO_ZERO    { }
intro_vocoder   T_VC_ZERO       { }

sb_dmasel       dw      ?

font_buf        db 8*256 dup ( ? )
flange_buf      db 360 dup ( ? )

	ZDATA		ENDS

