;----------------------------------------------------------------------------
;
;                            E L I T E G R O U P
;                             we are very good.
;
; MXMPlay/Win32 v0.9 (based on MXMPlay 1.6)
; done by Domin8R and The Artist Formerly Known As Doctor Roole in 1999
; original MXMPlay done and (C) by Niklas Beisert / pascal
;
; -> main player and mixer code
;
;----------------------------------------------------------------------------

SECTION .bss

%include "mxmallfx.inc"

%define USEVOLCOL      (USEVVOL || USEVVOLSLIDE || USEVFVOLSLIDE || USEVVIBRATE || USEVVIBRATO || USEVPAN || USEVPANSLIDE || USEVPORTANOTE)
%define USEAMIGAFREQ   ((USEFREQTAB == 1) == 0)
%define USELINEARFREQ  ((USEFREQTAB == 0) == 0)
%define USEBOTHFREQ    (USEAMIGAFREQ && USELINEARFREQ)


mixfreq     equ 44100
channelsize equ 256
headersize  equ 750h

struc mxmheader
  .MXMSig             resd 1
  .NOrders            resd 1
  .OrdLoopStart       resd 1
  .NChannels          resd 1
  .NPatterns          resd 1
  .NInstruments       resd 1
  .IniTempo           resb 1
  .IniBPM             resb 1
  .Options            resw 1
  .SampTable          resd 1
  .SampMem8           resd 1
  .SampMem16          resd 1
  .PitchMin           resd 1
  .PitchMax           resd 1
  .PanPos             resb 32
  .OrderTable         resb 256
  .InstrTable         resd 128
  .PatternTable       resd 256
  .size
endstruc


struc instrument
  .NSamples          resd 1
  .Samples           resb 96
  .VolFade           resw 1
  .VibType           resb 1
  .VibSweep          resb 1
  .VibDepth          resb 1
  .VibRate           resb 1
  .VNum              resb 1
  .VSustain          resb 1
  .VLoopS            resb 1
  .VLoopE            resb 1
  .VEnv              resw 24
  .PNum              resb 1
  .PSustain          resb 1
  .PLoopS            resb 1
  .PLoopE            resb 1
  .PEnv              resw 24
  .reserved          resb 46
endstruc

struc sample
  .LoopStart         resd 1
  .End               resd 1
  .MixMode           resb 1
  .DefVol            resb 1
  .DefPan            resb 1
  .NormNote          resw 1
  .Index             resw 1
  .reserved          resb 1
endstruc


struc channel
  .MixInited          resb 1
  .MixStartPos        resd 1
  .MixEndPos          resd 1
  .MixLoopPos         resd 1
  .MixMode            resb 1
  .MixStopIt          resb 1
  .MixChangeSamp      resb 1
  .MixNextPos         resd 1
  .MixFrq             resw 1
  .MixVol             resw 1
  .MixPan             resb 1
  .MixPosW            resd 1
  .MixPosF            resd 1
  .MixFL              resd 1
  .MixFB              resd 1
  .MixCutoff          resq 1
  .MixReso            resq 1
  .Vol                resb 1
  .FinalVol           resb 1
  .Pan                resb 1
  .FinalPan           resb 1
  .Pitch              resd 1
  .FinalPitch         resd 1
  .AuxSend1           resb 1
  .AuxSend2           resb 1
  .Cutoff             resb 1
  .FEnvAmnt           resb 1
  .FinalCutoff        resb 1
  .Reso               resd 1
  .CurIns             resb 1
  .EnvIns             resd 1
  .CurNormNote        resw 1
  .Sustain            resb 1
  .FadeVol            resw 1
  .AVibPos            resb 1
  .AVibSwpPos         resb 1
  .VolEnvPos          resd 1
  .VolEnvSegPos       resw 1
  .PanEnvPos          resd 1
  .PanEnvSegPos       resw 1
  .DefVol             resb 1
  .DefPan             resb 1
  .Command            resb 1
  .VCommand           resb 1
  .PortaToPitch       resd 1
  .PortaToVal         resd 1
  .VolSlideVal        resb 1
  .GVolSlideVal       resb 1
  .VVolPanSlideVal    resb 1
  .PanSlideVal        resb 1
  .FineVolSlideUVal   resb 1
  .FineVolSlideDVal   resb 1
  .PortaUVal          resd 1
  .PortaDVal          resd 1
  .FinePortaUVal      resb 1
  .FinePortaDVal      resb 1
  .XFinePortaUVal     resb 1
  .XFinePortaDVal     resb 1
  .VibRate            resb 1
  .VibPos             resb 1
  .VibType            resb 1
  .VibDep             resb 1
  .TremRate           resb 1
  .TremPos            resb 1
  .TremType           resb 1
  .TremDep            resb 1
  .PatLoopCount       resb 1
  .PatLoopStart       resb 1
  .ArpPos             resb 1
  .ArpNotes           resb 3
  .ActionTick         resb 1
  .MRetrigPos         resb 1
  .MRetrigLen         resb 1
  .MRetrigAct         resb 1
  .DelayNote          resb 1
  .Offset             resb 1
  .Glissando          resb 1
  .TremorPos          resb 1
  .TremorLen          resb 1
  .TremorOff          resb 1
endstruc


struc GDS
  .globalvol            resb 1
  .uservol              resb 1
  .syncval              resb 1
  .curtick              resb 1
  .curtempo             resb 1
  .tick0                resb 1
  .currow               resd 1
  .patptr               resd 1
  .patlen               resd 1
  .curord               resd 1
  .jumptoord            resd 1
  .jumptorow            resd 1
  .patdelay             resb 1
  .procnot              resb 1
  .procins              resb 1
  .procvol              resb 1
  .proccmd              resb 1
  .procdat              resb 1
  .notedelayed          resb 1
  .stimerlen            resd 1
  .portatmp             resb 1
  .keyofftmp            resb 1
  .head                 resb headersize
  .chandata             resb channelsize*32
  .vibtabs              resb 1024
  .samplestogib         resd 1
  .samplesleft          resd 1
  .freqf                resd 1
  .freqw                resd 1
  .smptomix             resd 1
  .destbuf              resd 1
  .smpremain            resd 1
  .isplaying            resb 1
  .cycles               resq 1
  .rsmp                 resd 1
  .actch                resd 1
  .temp                 resd 1
endstruc




GDP resd 1

section .data

global _ficken
_ficken dd 0

global _ficken2
_ficken2 dd 0

SECTION .code


%if USECOPYRIGHT
  db "We lost pascal's copyright notice, but MXMPlay is still (C) Niklas "
  db "Beisert somewhen in the 90s."
%endif


extern rvbInit
extern rvbProcess

;//*************************************************************************
;// Mixer

mixerproc:

    ; ecx: # of samples
    ; edi: 4x32bit destbuffer (ist nachher aktualisiert)
    ; * edi: nach dem 32bit destbuffer

    mov     dword [ebp + GDS.actch], 0


    mov     [ebp + GDS.smptomix], ecx
    mov     [ebp + GDS.destbuf],  edi

    shl     ecx, 2
    xor     eax, eax
    rep     stosd

    mov     ecx, 32

    lea     esi, [ebp+GDS.chandata]         ; instr ptr.

.ChanLoop:

    push    ecx
    push    esi

    cmp     byte [esi + channel.MixInited], 0
    je      near .NextChan

    inc     dword [ebp + GDS.actch]

    cmp     dword [esi + channel.MixNextPos], -1
    je      .NoNextPos

    mov     ebx,  [esi + channel.MixNextPos]     ; nextpos handling
    mov     dword [esi + channel.MixNextPos], -1
    mov     dword [esi + channel.MixPosW], ebx
    xor     eax,   eax
    mov     dword [esi + channel.MixPosF], eax
    mov     dword [esi + channel.MixFL], eax
    mov     dword [esi + channel.MixFB], eax

.NoNextPos:

    mov     ecx, [ebp + GDS.smptomix]
    mov     [ebp + GDS.smpremain], ecx
    mov     edi,[ebp + GDS.destbuf]


.FragLoop:

    mov     ecx, [ebp + GDS.smpremain]
    or      ecx, ecx
    jz      near .NextChan

    ; das SOLLTE klappen
    movzx   eax, word [esi + channel.MixFrq]
    xor     ebx,ebx
    shld    ebx,eax,22
    shl     eax,22

    test    byte [esi + channel.MixMode],32
    jz      .isfwd1

    not     eax
    add     eax,1
    not     ebx
    adc     ebx,0

.isfwd1:
    mov     dword [ebp + GDS.freqw], ebx
    mov     dword [ebp + GDS.freqf], eax

    xor     eax, eax
    sub     eax, [esi + channel.MixPosF]
    mov     edx, [esi + channel.MixEndPos]
    sbb     edx, [esi + channel.MixPosW]

    ; edx:eax -> 32:32bit Bis End
    ; ebx     ->  6:10bit Freq

    ; PrÑmisse: 1/1 == 1
    ;

    shrd    eax, edx, 22
    sar     edx, 22

    movzx   ebx, word [esi + channel.MixFrq]
    test    byte [esi + channel.MixMode],32
    jz      .isfwd2
    neg     ebx
.isfwd2:
    add     eax, ebx
    sub     eax, 1
    idiv    ebx


    mov     ecx, eax
    cmp     ecx, [ebp + GDS.smpremain]
    jbe     .passt
    mov     ecx, [ebp + GDS.smpremain]
.passt:
    sub     [ebp + GDS.smpremain],ecx

    or      ecx,ecx
    je      near .mixend
    js      near .mixend

    ; hier: ecx = wie viel wir mixen mÅssen
    ; d.h. theoretisch kînnten wir anfangen
    ; problem: ich habe angst.

    movzx   eax,word [esi + channel.MixVol]
    movzx   ebx,byte [esi + channel.MixPan]
    imul    eax,ebx
    mov     edx,eax
    movzx   eax, word [esi + channel.MixVol]
    shl     edx,16
    xor     ebx,0ffh
    imul    eax,ebx
    or      edx,eax
    movd    mm3,edx

    movzx   eax, word [esi + channel.MixVol]
    movzx   ebx, byte [esi + channel.AuxSend2]
    imul    eax, ebx
    mov     edx, eax
    movzx   eax, word [esi + channel.MixVol]
    movzx   ebx, byte [esi + channel.AuxSend1]
    shl     edx, 16
    imul    eax, ebx
    or      edx, eax
    movd    mm4, edx
    psllq   mm4, 32
    por     mm3, mm4

    psrlw   mm3, 1

    pxor    mm0, mm0
    movd    mm4, [esi + channel.MixFL]
    movd    mm5, [esi + channel.MixFB]
    mov     ebx, [esi + channel.MixStartPos]
    mov     eax, [esi + channel.MixPosW]
    mov     edx, [esi + channel.MixPosF]

%if USE8BIT && USE16BIT
    test    byte [esi + channel.MixMode], 4
    jz      near .m8loop
%endif


%if USE16BIT
.m16loop:
    ; linear interpolation
    movd      mm0, [ebx + 2*eax]
;    movd      mm2, edx
;    psrld     mm2, 17
;    movq      mm1, mm0
;    psrld     mm1, 16
;    psubw     mm1, mm0
;    pmulhw    mm2, mm1
    add       edi, 16
;    psllw     mm2, 1
;    paddw     mm0, mm2
    ;filter:
    pmulhw    mm5, [esi + channel.MixReso]
    psubsw    mm0, mm4
    psllw     mm5, 1
    pmulhw    mm0, [esi + channel.MixCutoff]
    psllw     mm0, 1
    paddsw    mm5, mm0
    movq      mm6, mm5
    pmulhw    mm6, [esi + channel.MixCutoff]
    psllw     mm6, 1
    paddsw    mm4, mm6
    movq      mm0, mm4
    ; volume and mixing
    punpcklwd mm0, mm0
    punpckldq mm0, mm0 ; auxsend, bla
    pmulhw    mm0, mm3
    add       edx, [ebp + GDS.freqf]
    adc       eax, [ebp + GDS.freqw]
    ; paddusw mm3, irgendwas, weil volramping rult
    psllw     mm0, 1
    movq      mm2, [edi-16]
    movq      mm6, mm0
    punpcklwd mm0, mm0
    dec       ecx
    psrlq     mm6, 32
    punpcklwd mm6, mm6
    psrad     mm0, 16
    paddd     mm2, mm0
    movq      [edi-16], mm2
    movq      mm2, [edi-8]
    psrad     mm6, 16
    paddd     mm2, mm6
    movq      [edi-8], mm2
    jnz       near .m16loop

    mov       [esi + channel.MixPosW], eax
    mov       [esi + channel.MixPosF], edx
    movd      [esi + channel.MixFL], mm4
    movd      [esi + channel.MixFB], mm5
%if USE8BIT
    jmp       .mixend
%endif

%endif


%if USE8BIT
.m8loop:
    movd      mm0, [ebx + eax]
    movd      mm2, edx
    punpcklbw mm0, mm0
    psrlq     mm2, 17
    movq      mm1, mm0
    psrlq     mm1, 16
    psubw     mm1, mm0
    pmulhw    mm1, mm2
    add       edi, 16
    psllw     mm1, 1
    paddw     mm0, mm1

    ;filter:
    pmulhw    mm5, [esi + channel.MixReso]
    psubsw    mm0, mm4
    psllw     mm5, 1
    pmulhw    mm0, [esi + channel.MixCutoff]
    psllw     mm0, 1
    paddsw    mm5, mm0
    movq      mm6, mm5
    pmulhw    mm6, [esi + channel.MixCutoff]
    psllw     mm6, 1
    paddsw    mm4, mm6
    movq      mm0, mm4

    punpcklwd mm0, mm0
    punpckldq mm0, mm0 ; auxsend, bla
    pmulhw    mm0, mm3
    add       edx, [ebp + GDS.freqf]
    adc       eax, [ebp + GDS.freqw]
                                    ; paddusw mm3, irgendwas, weil volramping rult
    psllw     mm0, 1
    movq      mm2, [edi-16]
    movq      mm6, mm0
    punpcklwd mm0, mm0
    dec       ecx
    psrlq     mm6, 32
    punpcklwd mm6, mm6
    psrad     mm0, 16
    paddd     mm2, mm0
    movq      [edi-16], mm2
    movq      mm2, [edi-8]
    psrad     mm6, 16
    paddd     mm2, mm6
    movq      [edi-8], mm2
    jnz       near .m8loop

    mov       [esi + channel.MixPosW], eax
    mov       [esi + channel.MixPosF], edx
    movd      [esi + channel.MixFL], mm4
    movd      [esi + channel.MixFB], mm5
%endif

.mixend:

    mov     eax, [esi + channel.MixPosW]

    test    byte [esi + channel.MixMode], 32
    jz      .isfwd3

    cmp     eax, [esi + channel.MixEndPos]
    jl      .irgendwas
    jmp     .FragLoop

.isfwd3:

    cmp     eax, [esi + channel.MixEndPos]
    jl      near .FragLoop

.irgendwas:

    ; (hier entweder sampleende oder loop)
    ; (nachteil: beides mu· man coden)

    test    byte [esi + channel.MixMode], 24
    jz      .samplezuende

    test    byte [esi + channel.MixMode], 16
    jz      .fwdloop

    ; Bidi-Loops stinken

    ; plan A: spiegeln
    mov     edx, [esi + channel.MixEndPos]
    shl     edx, 1
    xor     eax, eax
    sub     eax, [esi + channel.MixPosF]
    mov     [esi + channel.MixPosF], eax
    sbb     edx, [esi + channel.MixPosW]
    mov     [esi + channel.MixPosW], edx

    ; plan B: andersrum
    xor     byte [esi + channel.MixMode], 32

    ; plan C: BÑumchen Wechsel Dich
    mov     eax,[esi + channel.MixEndPos]
    xchg    eax,[esi + channel.MixLoopPos]
    mov     [esi + channel.MixEndPos],eax
    jmp     .FragLoop



.fwdloop:
    mov     ebx, [esi + channel.MixEndPos]
    sub     ebx, [esi + channel.MixLoopPos]
    sub     eax, ebx
    mov     [esi + channel.MixPosW], eax
    jmp     .FragLoop

.samplezuende:
    mov     byte [esi + channel.MixInited],0


.NextChan:

    pop     esi
    pop     ecx
    add     esi, channelsize

    dec     ecx
    jnz     near .ChanLoop

    emms

    mov     ecx, [ebp + GDS.smptomix]
    mov     edi, ecx
    shl     edi, 4
    add     edi, [ebp + GDS.destbuf]

    ret




global xmpRender
xmpRender:     ; eax: anzahl der samples, die der typ haben will.
             ; edi: destbuffer
    pushad

    or      eax,eax
    jnz     .losnu
    jmp     .nuaber
.losnu

    push    edi
    push    eax

    call    loadebp
    cld

    mov     dword [ebp + GDS.cycles], 0
    mov     dword [ebp + GDS.cycles+4 ], 0
    mov     [ebp + GDS.rsmp],   eax

    mov     [ebp + GDS.samplestogib], eax

    cmp     byte [ebp+GDS.isplaying], 0
    jne     .gibloop

    mov     ecx,eax
    xor     eax,eax
    shl     ecx,1
    rep     stosd
    jmp     .ende

.gibloop:
    mov     eax, [ebp + GDS.samplestogib]
    or      eax, eax
    jz      .ende

    mov     ebx, [ebp + GDS.samplesleft]
    cmp     ebx, 256
    jae     .nonewtick

    pushad
    call    PlayTick
    mov     eax, mixfreq*125*256
    mov     ebx, [ebp + GDS.stimerlen]
    xor     edx, edx
    imul    ebx, 50
    idiv    ebx
    add     [ebp + GDS.samplesleft], eax
    popad

.nonewtick:
    mov     ecx, [ebp + GDS.samplesleft]
    shr     ecx, 8
    cmp     ecx, [ebp + GDS.samplestogib]
    jbe     .nagut
    mov     ecx, [ebp + GDS.samplestogib]
.nagut:

    mov     eax,ecx
    shl     eax,8
    sub     [ebp + GDS.samplesleft],eax
    sub     [ebp + GDS.samplestogib],ecx

    rdtsc
    sub     [ebp + GDS.cycles], eax
    sbb     [ebp + GDS.cycles+4], edx
    call    mixerproc
    rdtsc
    add     [ebp + GDS.cycles], eax
    adc     [ebp + GDS.cycles+4], edx

    jmp     .gibloop
.ende:
    mov     eax, [ebp + GDS.cycles]
    mov     edx, [ebp + GDS.cycles+4]
    idiv    dword [ebp + GDS.rsmp]
    mov     [_ficken],eax

    mov     dword [_ficken2],0
    cmp     dword [ebp + GDS.actch],0
    je      .ende2

    xor     edx, edx
    idiv    dword [ebp + GDS.actch]
    mov     [_ficken2],eax

.ende2

    pop     ecx
    pop     esi
    call    rvbProcess


.nuaber
    popad
    ret





;//*************************************************************************
;// XM player

loadebp:
    call    .loadebp_getadr
.loadebp_getadr:
    pop     ebp
    mov     ebp, [GDP]
    ret

inittables:
%if (USEVIBRATO || USEVVIBRATO || USEAUTOVIBRATO)
    call    .inittables_getadr
.inittables_getadr:
    pop     esi
    add     esi, sintab - .inittables_getadr
    lea     edi,[ebp + GDS.vibtabs]
    mov     ecx,16
    rep     movsd
    mov     al,64
    stosb
    mov     cl,63
.inittables_sintabloop1:
    dec     esi
    mov     al,[esi]
    stosb
    dec     cl
    jnz     .inittables_sintabloop1

    lea esi,[ebp + GDS.vibtabs]
    mov     cl,128
.inittables_sintabloop2:
    lodsb
    neg     al
    stosb
    dec     cl
    jnz .inittables_sintabloop2

%if (USEVIBTYPE || USETREMTYPE || USEAUTOVIBRATOTYPE)
.inittables_dwntabloop:

    mov     al,cl
    sar     al,1
    neg     al
    stosb
    dec     cl
    jnz     .inittables_dwntabloop

.inittables_rectabloop:

    mov     al,cl
    and     al,80h
    sub     al,40h
    stosb
    dec cl
    jnz     .inittables_rectabloop

.inittables_uptabloop:

    mov     al,cl
    sar     al,1
    stosb
    dec     cl
    jnz     .inittables_uptabloop
%endif
%endif
    ret


global xmpInit
xmpInit:  ;
    pushad
    mov     [GDP],edi
    xchg    ebp,edi
    mov     ebx,4000h
.xmpInit_inilp:
    dec     ebx
    mov     byte [ebp+ebx],0
    jnz     .xmpInit_inilp

    mov     byte [ebp + GDS.uservol],40h
    cmp     dword [esi + mxmheader.MXMSig],004D584Dh
    jne     near .xmpInit_fail

    lea     edi,[ebp + GDS.head + mxmheader.MXMSig]
    mov     ecx,headersize/4
    rep     movsd

    ; relocation loop:
    sub     esi,headersize
    sub     edi,600h
    mov     ecx,600h/4
.xmpInit_relloop:
    add     [edi],esi
    lea     edi, [edi+4]
    loop    .xmpInit_relloop

    call    inittables
    xor     eax, eax
    inc     eax
    jmp     .xmpInit_done

.xmpInit_fail:
    xor     eax,eax
.xmpInit_done:
    mov     byte [ebp + GDS.isplaying], 0
    popad

    call    rvbInit

    ret






getfreq6848:
    push    edx
    push    ebx
    push    ecx
    push    esi
    push    edi
    add     eax, 8000h
    mov     edi, 15
    mov     edx, eax
    mov     ebx, eax
    mov     ecx, eax
    shr     eax, 12
    shr     edx, 8
    shr     ebx, 4
    and     eax, edi
    and     ebx, edi
    and     ecx, edi
    and     edx, edi
    call    .getfreq6848_getadr
.getfreq6848_getadr:
    pop     esi
    add     esi, logfreqtab-.getfreq6848_getadr
    mov     eax, [esi+6*16+eax*4]
    movzx   edx, word [esi+4*16+edx*2]
    movzx   ebx, word [esi+2*16+ebx*2]
    movzx   ecx, word [esi+0*16+ecx*2]
    mul     edx
    shrd    eax, edx,15
    mul     ebx
    shrd    eax, edx,15
    mul     ecx
    shrd    eax, edx,15
    pop     edi
    pop     esi
    pop     ecx
    pop     ebx
    pop     edx
    ret




PlayNote:
    mov     byte [ebp + GDS.portatmp],  0
    mov     byte [ebp + GDS.keyofftmp], 0
    cmp     byte [ebp + GDS.proccmd],   3
    jne     .PlayNote_noportac
    mov     byte [ebp + GDS.portatmp],  1
.PlayNote_noportac:

    cmp     byte [ebp + GDS.proccmd],   5
    jne     .PlayNote_noportacv
    mov     byte [ebp + GDS.portatmp],  1
.PlayNote_noportacv:

    cmp     byte [ebp + GDS.procvol],   0f0h
    jb      .PlayNote_noportav
    mov     byte [ebp + GDS.portatmp],  1
.PlayNote_noportav:

    cmp     byte [ebp + GDS.proccmd],   20
    jne     .PlayNote_nokeycmd
    cmp     byte [ebp + GDS.procdat],   0
    je      .PlayNote_dokeycmd
.PlayNote_nokeycmd:

    cmp     byte [ebp + GDS.procnot],   97
    jne     .PlayNote_nokeyoff
    mov     byte [ebp + GDS.procnot],   0

.PlayNote_dokeycmd:
    mov     byte [ebp + GDS.keyofftmp], 1
    mov     byte [edi + channel.Sustain],0
    ;// if no instrument and no volenv. kill note

.PlayNote_nokeyoff:
    movzx   eax, byte [ebp + GDS.procins]
    cmp     al,0
    je      .PlayNote_noins1
    cmp     eax,[ebp + GDS.head + mxmheader.NInstruments]
    ja      .PlayNote_noins1
    mov     [edi + channel.CurIns],al

.PlayNote_noins1:
    cmp     byte [edi + channel.CurIns],0
    je      near .PlayNote_done

    movzx   eax, byte [ebp + GDS.procnot]
    cmp     al,0
    je      near .PlayNote_nonote
    cmp     byte [ebp + GDS.procins],0

    je      .PlayNote_nohit
    mov     byte [edi + channel.Sustain],1

.PlayNote_nohit:

    mov     byte [edi + channel.DelayNote],al
    cmp     byte [ebp + GDS.proccmd],49
    jne     .PlayNote_nodelay
    cmp     byte [ebp + GDS.procdat],0
    jne     near .PlayNote_done
.PlayNote_nodelay:

    dec     al
    cmp     byte [ebp + GDS.portatmp],1
    je      near .PlayNote_portanote
    mov     byte [edi + channel.MixStopIt],1

    movzx   edx, byte [edi + channel.CurIns]

    mov     edx,[ebp + GDS.head + mxmheader.InstrTable +4*edx-4]
    movzx   ebx, byte [edx + instrument.Samples + eax]
    cmp     ebx,[edx + instrument.NSamples]
    jae     near .PlayNote_done
    shl     ebx,4
    lea     ebx,[ebx+edx+256]

    mov     byte [edi + channel.MixInited],1
    mov     byte [edi + channel.MixChangeSamp],1

    push    eax
    push    edx
    movzx   edx,word [ebx + sample.Index]
    mov     eax,[ebp + GDS.head + mxmheader.SampTable]
    mov     eax,[eax + 4*edx]
    mov     [edi + channel.MixStartPos],eax
    mov     eax,[ebx + sample.LoopStart]
    mov     [edi + channel.MixLoopPos],eax
    mov     eax,[ebx + sample.End]
    mov     [edi + channel.MixEndPos],eax
    mov     al,[ebx + sample.MixMode]
    mov     [edi + channel.MixMode],al
    pop     edx
    pop     eax

    cmp     byte [ebp + GDS.procins],0
    je      .PlayNote_noins2
    mov     [edi + channel.EnvIns],edx
    mov     dl,[ebx + sample.DefVol]
    mov     [edi + channel.DefVol],dl
    mov     dl,[ebx + sample.DefPan]
    mov     [edi + channel.DefPan],dl
.PlayNote_noins2:

    mov     dx,[ebx + sample.NormNote]
    mov     [edi + channel.CurNormNote],dx

    ; process finetune here (proccmd==41)
    ; overwrite top 4 bits of instrument finetune value
    ; cannot do this correctly, since conversion reduced information... :(
    ; this command sucks anyway!!!

    shl     eax,8
    add     ax,dx
    neg     ax
    add     ah,48
    movsx   eax,ax
%if USEBOTHFREQ
    test    byte [ebp + GDS.head + mxmheader.Options],1
    jnz     .PlayNote_noamiga1
%endif
%if USEAMIGAFREQ
    neg    eax
    call   getfreq6848
.PlayNote_noamiga1:
%endif
    mov     [edi + channel.Pitch],eax
    mov     [edi + channel.FinalPitch],eax
    mov     [edi + channel.PortaToPitch],eax

    xor     eax,eax
%if USEOFFSET
    cmp     byte [ebp + GDS.proccmd],9
    jne     .PlayNote_nooffset
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .PlayNote_reuseoffset
    mov     [edi + channel.Offset],al
.PlayNote_reuseoffset:
    movzx   eax,byte [edi + channel.Offset]

    shl     eax,8
.PlayNote_nooffset:
%endif

    mov     [edi + channel.MixNextPos],eax
    mov     byte [edi + channel.VibPos],0
    mov     byte [edi + channel.TremPos],0
    mov     byte [edi + channel.ArpPos],0
    mov     byte [edi + channel.MRetrigPos],0
    mov     byte [edi + channel.TremorPos],0
    jmp     .PlayNote_nonote

.PlayNote_portanote:
    shl     eax,8
    add     ax,[edi + channel.CurNormNote]

    neg     ax
    add     ah,48
    movsx   eax,ax
%if USEBOTHFREQ
    test    byte [ebp + GDS.head + mxmheader.Options],1
    jnz     .PlayNote_noamiga2
%endif
%if USEAMIGAFREQ
    neg     eax
    call    getfreq6848
.PlayNote_noamiga2:
%endif
    mov     [edi + channel.PortaToPitch],eax
.PlayNote_nonote:

    cmp     byte [edi + channel.Sustain],0
    je      .PlayNote_killbug
    cmp     byte [ebp + GDS.procins],0
    je      .PlayNote_killbug
    cmp     byte [ebp + GDS.notedelayed],1
    je      .PlayNote_noinsvolpan
    mov     al, [edi + channel.DefVol]

    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    test    byte [ebp + GDS.head + mxmheader.Options],2
    jnz     .PlayNote_noinsvolpan
    mov     al,[edi + channel.DefPan]

    mov     [edi + channel.Pan],al
    mov     [edi + channel.FinalPan],al
.PlayNote_noinsvolpan:
    xor     eax,eax
    mov     word [edi + channel.FadeVol],8000h
    mov     [edi + channel.AVibPos],al
    mov     [edi + channel.AVibSwpPos],al
    mov     [edi + channel.VolEnvPos],eax
    mov     [edi + channel.VolEnvSegPos],ax
    mov     [edi + channel.PanEnvPos],eax
    mov     [edi + channel.PanEnvSegPos],ax

.PlayNote_killbug:
    cmp     byte [ebp + GDS.keyofftmp],0
    je      .PlayNote_done
    cmp     byte [ebp + GDS.procins],0
    jne     .PlayNote_done
    mov     ebx,[edi + channel.EnvIns]

    cmp     byte [ebx + instrument.VNum],0
    jne     .PlayNote_done
    mov     word [edi + channel.FadeVol],0

.PlayNote_done:
    ret



global xmpSetVolume
xmpSetVolume:
    push    ebp
    call    loadebp
    mov     [ebp + GDS.uservol],al
    pop     ebp
    ret



global xmpGetSync
xmpGetSync:
    push    ebp
    call    loadebp
    mov     al,[ebp + GDS.syncval]
    pop     ebp
    ret



global xmpGetPos
xmpGetPos:
    push    ebp
    call    loadebp
    mov     al,byte [ebp + GDS.currow]
    mov     ah,byte [ebp + GDS.curord]
    pop     ebp
    ret




freqrange:
    cmp     eax,[ebp + GDS.head + mxmheader.PitchMin]
    jg      .freqrange_lowlimok
    mov     eax,[ebp + GDS.head + mxmheader.PitchMin]
.freqrange_lowlimok:
    cmp     eax,[ebp + GDS.head + mxmheader.PitchMax]
    jl      .freqrange_highlimok
    mov     eax,[ebp + GDS.head + mxmheader.PitchMax]
.freqrange_highlimok:
    ret




;//***************************************************************************
;//effects

procnothing:
  ret


%if USEJUMP
procjump:
    movzx   eax, byte [ebp + GDS.procdat]
    mov     [ebp + GDS.jumptoord],eax
    mov     dword [ebp + GDS.jumptorow],0
    ret
%else
procjump equ procnothing
%endif


%if USEBREAK
procbreak:
    cmp     dword [ebp + GDS.jumptoord],-1
    jne     .procbreak_onlyrow
    mov     eax, [ebp + GDS.curord]
    inc     eax
    mov     [ebp + GDS.jumptoord], eax
.procbreak_onlyrow:
    movzx   eax, byte [ebp + GDS.procdat]
    mov     ebx,eax
    shr     al,4
    imul    eax,10
    and     bl,0fh
    add     eax,ebx
    mov     [ebp + GDS.jumptorow],eax
    ret
%else
procbreak equ procnothing
%endif


%if USEPATLOOP
procpatloop:
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .procpatloop_set
    inc     byte [edi + channel.PatLoopCount]

    cmp     [edi + channel.PatLoopCount],al
    ja      .procpatloop_nextrow
    movzx   eax, byte [edi + channel.PatLoopStart]

    mov     [ebp + GDS.jumptorow],eax
    mov     eax,[ebp + GDS.curord]
    mov     [ebp + GDS.jumptoord],eax
    jmp     .procpatloop_done
.procpatloop_nextrow:
    mov     byte [edi + channel.PatLoopCount],0
    mov     al,byte [ebp + GDS.currow]
    inc     al
    mov     [edi + channel.PatLoopStart],al
    jmp     .procpatloop_done
.procpatloop_set:
    mov     al,byte [ebp + GDS.currow]
    mov     [edi + channel.PatLoopStart],al
.procpatloop_done:
    ret
%else
procpatloop equ procnothing
%endif


%if USEPATDELAY
procpatdelay:
    mov     al,[ebp + GDS.procdat]
    mov     [ebp + GDS.patdelay],al
    ret
%else
procpatdelay equ procnothing
%endif


%if USESPEED
proctempo:
    movzx   ebx, byte[ebp + GDS.procdat]
    cmp     bl,20h
    jb      .proctempo_speed
    mov     [ebp + GDS.stimerlen],ebx
    ret
.proctempo_speed:
    cmp     bl,0
    je      .proctempo_ignore
    mov     [ebp + GDS.curtempo],bl
.proctempo_ignore:
    ret
%else
proctempo equ procnothing
%endif


%if USEVOL
procnvol:
    mov     al,[ebp + GDS.procdat]
    cmp     al,40h
    jbe     .procnvol_vok
    mov     al,40h
.procnvol_vok:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret
%else
procnvol equ procnothing
%endif


%if USEGVOL
procgvol:
    mov     al,[ebp + GDS.procdat]
    cmp     al,40h
    jbe     .procgvol_vok
    mov     al,40h
.procgvol_vok:
    mov     [ebp + GDS.globalvol],al
    ret
%else
procgvol equ procnothing
%endif


%if USEPAN
procpan:
    mov     al,[ebp + GDS.procdat]
    mov     [edi + channel.Pan],al
    mov     [edi + channel.FinalPan],al
    ret
%else
procpan equ procnothing
%endif


%if USESPAN
procspan:
    mov     al,[ebp + GDS.procdat]
    shl     al,4
    or      al,[ebp + GDS.procdat]
    mov     [edi + channel.Pan],al
    mov     [edi + channel.FinalPan],al
    ret
%else
procspan equ procnothing
%endif


%if USEVPAN
procvpan:
    mov     al,[ebp + GDS.procvol]
    shl     al,4
    or      al,[ebp + GDS.procvol]
    mov     [edi + channel.Pan],al
    mov     [edi + channel.FinalPan],al
    ret
%else
    procvpan equ procnothing
%endif


%if USEARPEGGIO
procarpeggio:
    movzx   eax,byte [ebp + GDS.procdat]
    cmp     al,0
    jne     .procarpeggio_doit
    mov     byte [edi + channel.Command],0ffh
.procarpeggio_doit:
    shl     eax,4
    shr     al,4
    mov     byte [edi + channel.ArpNotes + 0],0
    mov     [edi + channel.ArpNotes + 1],ah
    mov     [edi + channel.ArpNotes + 2],al
    ret

doarpeggio:
    movzx   eax, byte [edi + channel.ArpPos]
    mov     al,[edi + channel.ArpNotes + eax]

%if USEBOTHFREQ
    test    byte [ebp + GDS.head + mxmheader.Options],1
    jz      .doarpeggio_amiga
%endif
%if USELINEARFREQ
    shl     eax,8
    neg     eax
    add     eax,[edi + channel.FinalPitch]

    call    freqrange
    mov     [edi + channel.FinalPitch],eax
%endif
%if USEBOTHFREQ
    jmp     .doarpeggio_noamiga
%endif
%if USEAMIGAFREQ
.doarpeggio_amiga:
    call    .doarpeggio_getadr
  .doarpeggio_getadr:
    pop     edx
    mov     ax,[edx+eax*2+16*4+(logfreqtab-.doarpeggio_getadr)]
    mul     dword [edi + channel.FinalPitch]

    shrd    eax,edx,15
    call    freqrange
    mov     [edi + channel.FinalPitch],eax
%endif

.doarpeggio_noamiga:
    inc     byte [edi + channel.ArpPos]

    cmp     byte [edi + channel.ArpPos],3
    jne     .doarpeggio_done
    mov     byte [edi + channel.ArpPos],0
.doarpeggio_done:
    ret

%else
procarpeggio equ procnothing
doarpeggio equ procnothing
%endif



%if (USETREMTYPE && USETREMOLO)
proctremtype:
    mov     al,[ebp + GDS.procdat]
    and     al,3
    mov     [edi + channel.TremType],al
    ret
%else
proctremtype equ procnothing
%endif



%if USETREMOLO
proctremolo:
    mov     al,[ebp + GDS.procdat]
    and     al,0Fh
    jz      .proctremolo_reusel
    shl     al,2
    mov     [edi + channel.TremDep],al
.proctremolo_reusel:
    mov     al,[ebp + GDS.procdat]
    and     al,0F0h
    jz      .proctremolo_reuseh
    shr     al,2
    mov     [edi + channel.TremRate],al
.proctremolo_reuseh:
    ret

dotremolo:
    movzx   eax,byte [edi + channel.TremPos]

    movsx   eax,byte [ebp + GDS.vibtabs + eax]
    imul    byte [edi + channel.TremDep]

    sar     eax,6
    add     al,[edi + channel.FinalVol]

    jns     .dotremolo_lok
    xor     al,al
.dotremolo_lok:
    cmp     al,40h
    jbe     .dotremolo_tok
    mov     al,40h
.dotremolo_tok:
    mov     [edi + channel.FinalVol],al

    cmp     byte [ebp + GDS.tick0],0
    jne     .dotremolo_done
    mov     al,[edi + channel.TremRate]

    add     [edi + channel.TremPos],al
.dotremolo_done:
    ret
%else
proctremolo equ procnothing
dotremolo equ procnothing
%endif


%if USEFPORTA
procfportau:
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .procfportau_reuse
    mov     [edi + channel.FinePortaUVal],al
.procfportau_reuse:
    movzx   eax,byte [edi + channel.FinePortaUVal]

    shl     eax,4
    neg     eax
    add     eax,[edi + channel.Pitch]

    call    freqrange
    mov     [edi + channel.Pitch],eax
    mov     [edi + channel.FinalPitch],eax
    ret

procfportad:
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .procfportad_reuse
    mov     [edi + channel.FinePortaDVal],al
.procfportad_reuse:
    movzx   eax,byte [edi + channel.FinePortaDVal]

    shl     eax,4
    add     eax,[edi + channel.Pitch]

    call    freqrange
    mov     [edi + channel.Pitch],eax
    mov     [edi + channel.FinalPitch],eax
    ret
%else
procfportau equ procnothing
procfportad equ procnothing
%endif


%if USEXFPORTA
procxfporta:
    movzx   eax,byte [ebp + GDS.procdat]
    shl     eax,4
    shr     al,4
    cmp     ah,2
    je      .procxfporta_down
    cmp     ah,1
    jne     .procxfporta_done

    cmp     al,0
    je      .procxfporta_reuseu
    mov     [edi + channel.XFinePortaUVal],al
.procxfporta_reuseu:
    movzx   eax,byte [edi + channel.XFinePortaUVal]

    shl     eax,2
    neg     eax
    add     eax,[edi + channel.Pitch]

    call    freqrange
    mov     [edi + channel.Pitch],eax
    mov     [edi + channel.FinalPitch],eax
    jmp     .procxfporta_done

.procxfporta_down:
    cmp     al,0
    je      .procxfporta_reused
    mov     [edi + channel.XFinePortaDVal],al
.procxfporta_reused:
    movzx   eax,byte [edi + channel.XFinePortaDVal]

    shl     eax,2
    add     eax,[edi + channel.Pitch]

    call    freqrange
    mov     [edi + channel.Pitch],eax
    mov     [edi + channel.FinalPitch],eax

.procxfporta_done:
    ret
%else
procxfporta equ procnothing
%endif


%if USEFVOLSLIDE
procfvolup:
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .procfvolup_reuse
    mov     [edi + channel.FineVolSlideUVal],al
.procfvolup_reuse:
    mov     al,[edi + channel.Vol]

    add     al,[edi + channel.FineVolSlideUVal]

    cmp     al,40h
    jbe     .procfvolup_vok
    mov     al,40h
.procfvolup_vok:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret

procfvoldn:
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .procfvoldn_reuse
    mov     [edi + channel.FineVolSlideDVal],al
.procfvoldn_reuse:
    mov     al,[edi + channel.Vol]
    sub     al,[edi + channel.FineVolSlideDVal]
    jnc     .procfvoldn_vok
    mov     al,0
.procfvoldn_vok:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret
%else
procfvolup equ procnothing
procfvoldn equ procnothing
%endif



%if USEVVOL
procvvol:
procvvol4:
    mov     byte [ebp + GDS.procvol],10h
procvvol3:
    add     byte [ebp + GDS.procvol],10h
procvvol2:
    add     byte [ebp + GDS.procvol],10h
procvvol1:
    add     byte [ebp + GDS.procvol],10h
procvvol0:
    mov     al,[ebp + GDS.procvol]
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret
%else
procvvol0 equ procnothing
procvvol1 equ procnothing
procvvol2 equ procnothing
procvvol3 equ procnothing
procvvol4 equ procnothing
%endif



%if (USEVPANSLIDE || USEVVOLSLIDE)
procvvpsl:
    mov     al,[ebp + GDS.procvol]
    mov     [edi + channel.VVolPanSlideVal],al
    ret
%else
procvvpsl equ procnothing
%endif



%if USEVVOLSLIDE
dovvolsld:
    mov     al,[edi + channel.Vol]

    cmp     byte [ebp + GDS.tick0],0
    jne     .dovvolsld_done
    sub     al,[edi + channel.VVolPanSlideVal]

    jnc     .dovvolsld_done
    mov     al,0
.dovvolsld_done:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret

dovvolslu:
    mov     al,[edi + channel.Vol]

    cmp     byte [ebp + GDS.tick0],0
    jne     .dovvolslu_done
    add     al,[edi + channel.VVolPanSlideVal]

    cmp     al,40h
    jbe     .dovvolslu_done
    mov     al,40h
.dovvolslu_done:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret
%else
dovvolsld equ procnothing
dovvolslu equ procnothing
%endif


%if USEVPANSLIDE
dovpansll:
    mov     al,[edi + channel.Pan]
    cmp     byte [ebp + GDS.tick0],0
    jne     .dovpansll_done
    sub     al,[edi + channel.VVolPanSlideVal]
    jnc     .dovpansll_done
    mov     al,0
.dovpansll_done:
    mov     [edi + channel.Pan],al
    mov     [edi + channel.FinalPan],al
    ret

dovpanslr:
    mov     al,[edi + channel.Vol]

    cmp     byte [ebp + GDS.tick0],0
    jne     .dovpanslr_done
    add     al,[edi + channel.VVolPanSlideVal]

    jnc     .dovpanslr_done
    mov     al,0ffh
.dovpanslr_done:
    mov     [edi + channel.Pan],al
    mov     [edi + channel.FinalPan],al
    ret
%else
dovpansll equ procnothing
dovpanslr equ procnothing
%endif


%if USEVFVOLSLIDE
procvfvolup:
    mov     al,[edi + channel.Vol]

    add     al,[ebp + GDS.procvol]
    cmp     al,40h
    jbe     .procvfvolup_vok
    mov     al,40h
.procvfvolup_vok:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret

procvfvoldn:
    mov     al,[edi + channel.Vol]

    sub     al,[ebp + GDS.procvol]
    jnc     .procvfvoldn_vok
    mov     al,0
.procvfvoldn_vok:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret
%else
procvfvolup equ procnothing
procvfvoldn equ procnothing
%endif


%if USESYNC
procsync:
    mov     al,[ebp + GDS.procdat]
    mov     [ebp + GDS.syncval],al
    ret
%else
procsync equ procnothing
%endif


%if USETREMOR
proctremor:
    movzx   eax, byte [ebp + GDS.procdat]
    cmp     al,0
    je      .proctremor_reuse
    shl     eax,4
    shr     al,4
    inc     al
    inc     ah
    add     al,ah
    mov     [edi + channel.TremorLen],al
    mov     [edi + channel.TremorOff],ah
    mov     byte [edi + channel.TremorPos],0
.proctremor_reuse:
    ret

dotremor:
    mov     al,[edi + channel.TremorPos]
    cmp     al,[edi + channel.TremorOff]
    jb      .dotremor_on
    mov     byte [edi + channel.FinalVol],0
.dotremor_on:
    cmp     byte [ebp + GDS.tick0],0
    jne     .dotremor_done
    mov     al,[edi + channel.TremorPos]
    inc     al
    cmp     al,[edi + channel.TremorLen]
    jb      .dotremor_noloop
    xor     al,al
.dotremor_noloop:
    mov     [edi + channel.TremorPos],al
.dotremor_done:
    ret
%else
proctremor equ procnothing
dotremor equ procnothing
%endif

; set aux send 1/2
%if USEAUX
procaux:
    mov     al, byte [ebp + GDS.procdat]
    mov     ebx, eax
    shl     al, 4
    and     bl, 0f0h
    mov     [edi + channel.AuxSend1], al
    mov     [edi + channel.AuxSend2], bl
    ret
%else
procaux equ procnothing
%endif

; set filter cutoff
%if USECUTOFF
proccutoff:
    mov     al , byte [ebp + GDS.procdat]
    mov     byte [edi + channel.Cutoff], al
    ret
%else
proccutoff equ procnothing
%endif

; set filter reso
%if USERESO
procreso:
    movzx    eax , byte [ebp + GDS.procdat]
    mov      [edi + channel.Reso], eax
    ret
%else
procreso equ procnothing
%endif

; set filter env amount
%if USEENVAMNT
procenvamount:
    mov     al , byte [ebp + GDS.procdat]
    mov     byte [edi + channel.FEnvAmnt], al
    ret
%else
procenvamount equ procnothing
%endif



%if USEENVPOS
procenvpos:
    cmp     dword [edi + channel.EnvIns],0
    je      .procenvpos_noenvins
    mov     ebx,[edi + channel.EnvIns]
    xor     eax,eax
    movzx   edx, byte [ebp + GDS.procdat]
    jmp     .procenvpos_venvloops
.procenvpos_venvloop:
    sub     dx,[ebx+instrument.VEnv + 4*eax]
    jb      .procenvpos_venvok
    inc     eax
.procenvpos_venvloops:
    cmp     al,[ebx + instrument.VNum]
    jne     .procenvpos_venvloop
    xor     edx,edx
    sub     dx,[ebx+instrument.VEnv+4*eax]
.procenvpos_venvok:
    add     dx,[ebx + instrument.VEnv +4*eax]
    mov     [edi + channel.VolEnvPos],eax
    mov     [edi + channel.VolEnvSegPos],dx
    xor     eax,eax
    movzx   edx,byte [ebp + GDS.procdat]
    jmp     .procenvpos_penvloops
.procenvpos_penvloop:
    sub     dx,[ebx+instrument.PEnv + 4*eax]
    jb      .procenvpos_penvok
    inc     eax
.procenvpos_penvloops:
    cmp     al,[ebx + instrument.PNum]
    jne     .procenvpos_penvloop
    xor     edx,edx
    sub     dx,[ebx+instrument.PEnv + 4*eax]
.procenvpos_penvok:
    add     dx,[ebx+instrument.PEnv + 4*eax]
    mov     [edi + channel.PanEnvPos],eax
    mov     [edi + channel.PanEnvSegPos],dx
.procenvpos_noenvins:
    ret
%else
procenvpos equ procnothing
%endif




%if USEPORTA
procportau:
    movzx   eax,byte [ebp + GDS.procdat]
    cmp     al,0
    je      .procportau_reuse
    shl     eax,4
    mov     [edi + channel.PortaUVal],eax
.procportau_reuse:
    ret

procportad:
    movzx   eax,byte [ebp + GDS.procdat]
    cmp     al,0
    je      .procportad_reuse
    shl     eax,4
    mov     [edi + channel.PortaDVal],eax
.procportad_reuse:
    ret

doportau:
    cmp     byte [ebp + GDS.tick0],0
    jne     .doportau_done
    mov     eax,[edi + channel.Pitch]
    sub     eax,[edi + channel.PortaUVal]
    call    freqrange
    mov     [edi + channel.Pitch],eax
    mov     [edi + channel.FinalPitch],eax
.doportau_done:
    ret

doportad:
    cmp     byte [ebp + GDS.tick0],0
    jne     .doportad_done
    mov     eax,[edi + channel.Pitch]
    add     eax,[edi + channel.PortaDVal]
    call    freqrange
    mov     [edi + channel.Pitch],eax
    mov     [edi + channel.FinalPitch],eax
.doportad_done:
    ret
%else
procportau equ procnothing
procportad equ procnothing
doportau equ procnothing
doportad equ procnothing
%endif


%if USEPORTANOTE
procportanote:
    movzx   eax,byte [ebp + GDS.procdat]
    cmp     al,0
    je      .procportanote_reuse
    shl     eax,4
    mov     [edi + channel.PortaToVal],eax
.procportanote_reuse:
    ret
%else
procportanote equ procnothing
%endif


%if USEVPORTANOTE
procvportanote:
    movzx   eax,byte [ebp + GDS.procvol]
    cmp     al,0
    je      .procvportanote_reuse
    shl     eax,8
    mov     [edi + channel.PortaToVal],eax
.procvportanote_reuse:
    ret
%else
procvportanote equ procnothing
%endif


%if (USEGLISSANDO && (USEPORTANOTE || USEVPORTANOTE))
procgliss:
    mov     al,[ebp + GDS.procdat]
    mov     [edi + channel.Glissando],al
    ret
%else
procgliss equ procnothing
%endif


%if (USEPORTANOTE || USEVPORTANOTE)
doportanote:
    mov     eax,[edi + channel.Pitch]

    cmp     byte [ebp + GDS.tick0],0
    jne     .doportanote_set
    cmp     eax,[edi + channel.PortaToPitch]

    je      .doportanote_set
    jg      .doportanote_down
    add     eax,[edi + channel.PortaToVal]
    cmp     eax,[edi + channel.PortaToPitch]
    jle     .doportanote_set
    mov     eax,[edi + channel.PortaToPitch]

    jmp     .doportanote_set
.doportanote_down:
    sub     eax,[edi + channel.PortaToVal]
    cmp     eax,[edi + channel.PortaToPitch]
    jge     .doportanote_set
    mov     eax,[edi + channel.PortaToPitch]

.doportanote_set:
    mov     [edi + channel.Pitch],eax

%if USEGLISSANDO
    cmp     byte [edi + channel.Glissando],0
    je      .doportanote_setfinpitch
%if USEBOTHFREQ
    test    byte [ebp + GDS.head + mxmheader.Options],1
    jz      .doportanote_amiga
%endif



%if USELINEARFREQ
    movzx   ebx,word [edi + channel.CurNormNote]

    add     eax,ebx
    add     eax,80h
    xor     al,al
    sub     eax,ebx
%endif
%if USEBOTHFREQ
    jmp     .doportanote_setfinpitch
%endif
%if USEAMIGAFREQ
.doportanote_amiga:
    mov     edx,eax ;// search for closest note
    mov     ebx,eax ;// how should i do it??
    push    ecx
    mov     ecx,-1
    mov     eax,-48*256
.doportanote_aloop:
    push    eax
    add     ax,[edi + channel.CurNormNote]

    movsx   eax,ax
    call    getfreq6848
    sub     eax,edx
    jae     .doportanote_apos
    neg     eax
.doportanote_apos:
    cmp     eax,ecx
    jae     .doportanote_aold
    mov     ecx,eax
    mov     eax,[esp]
    add     ax,[edi + channel.CurNormNote]

    movsx   eax,ax
    call    getfreq6848
    mov     ebx,eax
.doportanote_aold:
    pop     eax
    inc     ah
    cmp     ah,48
    jne     .doportanote_aloop
    pop     ecx
    mov     eax,ebx
%endif
%endif

.doportanote_setfinpitch:
    mov     [edi + channel.FinalPitch],eax
.doportanote_done:
    ret
%else
doportanote equ procnothing
%endif


%if (USEVIBTYPE && (USEVIBRATO || USEVVIBRATO))
procvibtype:
    mov     al,[ebp + GDS.procdat]
    and     al,3
    mov     [edi + channel.VibType], al
    ret
%else
procvibtype equ procnothing
%endif


%if USEVIBRATO
procvibrato:
    mov     al,[ebp + GDS.procdat]
    and     al,0Fh
    jz      .procvibrato_reusel
    shl     al,2
    mov     [edi + channel.VibDep],al
.procvibrato_reusel:
    mov     al,[ebp + GDS.procdat]
    and     al,0F0h
    jz      .procvibrato_reuseh
    shr     al,2
    mov     [edi + channel.VibRate],al
.procvibrato_reuseh:
    ret
%else
procvibrato equ procnothing
%endif


%if USEVVIBRATE
procvvibrat:
    mov     al,[ebp + GDS.procvol]
    shl     al,2
    je      .procvvibrat_reuse
    mov     [edi + channel.VibRate],al
.procvvibrat_reuse:
    ret
%else
procvvibrat equ procnothing
%endif


%if USEVVIBRATO
procvvib:
    mov al,[ebp + GDS.procvol]
    shl al,2
    je .procvvib_reuse
    mov [edi + channel.VibDep],al
.procvvib_reuse:
    ret
%else
    procvvib equ procnothing
%endif


%if (USEVIBRATO || USEVVIBRATO)
dovibrato:
    movzx   eax,byte [edi + channel.VibPos]

    movsx   eax,byte [ebp + GDS.vibtabs + eax]
    imul    byte [edi + channel.VibDep]

    sar     eax,3
    add     eax,[edi + channel.FinalPitch]

    call    freqrange
    mov     [edi + channel.FinalPitch],eax

    cmp     byte [ebp + GDS.tick0],0
    jne     .dovibrato_done
    mov     al,[edi + channel.VibRate]
    shr     al, 1

    add     [edi + channel.VibPos],al
.dovibrato_done:
    ret
%else
    dovibrato equ procnothing
%endif


%if (USEVOLSLIDE || USEVIBRATOVOL || USEPORTAVOL)
procvolsl:
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .procvolsl_reuse
    mov     [edi + channel.VolSlideVal],al
.procvolsl_reuse:
    ret

dovolsl:
    mov     bl,[edi + channel.VolSlideVal]
    mov     al,[edi + channel.Vol]
    cmp     byte [ebp + GDS.tick0],0
    jne     .dovolsl_done
    test    bl,0f0h
    jnz     .dovolsl_up
    sub     al,bl
    jnc     .dovolsl_done
    mov     al,0
    jmp     .dovolsl_done
.dovolsl_up:
    shr     bl,4
    add     al,bl
    cmp     al,40h
    jbe     .dovolsl_done
    mov     al,40h
.dovolsl_done:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
    ret
%else
procvolsl equ procnothing
dovolsl equ procnothing
%endif



%if (USEVIBRATOVOL && USEVIBRATO)
dovibvol:
    call    dovibrato
    jmp     dovolsl
%else
dovibvol equ procnothing
%endif


%if (USEPORTAVOL && USEPORTANOTE)
doportavol:
    call    doportanote
    jmp     dovolsl
%else
doportavol equ procnothing
%endif


%if USEGVOLSLIDE
procgvolsl:
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .procgvolsl_reuse
    mov     [edi + channel.GVolSlideVal],al
.procgvolsl_reuse:
    ret

dogvolsl:
    mov     bl,[edi + channel.GVolSlideVal]
    mov     al,[ebp + GDS.globalvol]
    cmp     byte [ebp + GDS.tick0],0
    jne     .dogvolsl_done
    test    bl,0f0h
    jnz     .dogvolsl_up
    sub     al,bl
    jnc     .dogvolsl_done
    mov     al,0
    jmp     .dogvolsl_done
.dogvolsl_up:
    shr     bl,4
    add     al,bl
    cmp     al,40h
    jbe     .dogvolsl_done
    mov     al,40h
.dogvolsl_done:
    mov     [ebp + GDS.globalvol],al
    ret
%else
procgvolsl equ procnothing
dogvolsl equ procnothing
%endif


%if USEPANSLIDE
procpansl:
    mov     al,[ebp + GDS.procdat]
    cmp     al,0
    je      .procpansl_reuse
    mov     [edi + channel.PanSlideVal],al
.procpansl_reuse:
    ret

dopansl:
    mov     bl,[edi + channel.PanSlideVal]
    mov     al,[edi + channel.Pan]
    cmp     byte [ebp + GDS.tick0],0
    jne     .dopansl_done
    test    bl,0f0h
    jnz     .dopansl_left
    add     al,bl
    jnc     .dopansl_done
    mov     al,0ffh
    jmp     .dopansl_done
.dopansl_left:
    shr     bl,4
    sub     al,bl
    jnc     .dopansl_done
    mov     al,0
.dopansl_done:
    mov     [edi + channel.Pan],al
    mov     [edi + channel.FinalPan],al
    ret
%else
procpansl equ procnothing
dopansl equ procnothing
%endif


%if (USEDELAY || USEKEYOFFCMD || USENOTECUT)
proctick:
    mov     al,[ebp + GDS.procdat]
    mov     [edi + channel.ActionTick],al
    ret
%else
proctick equ procnothing
%endif


%if USEDELAY
dodelay:
    cmp     byte [ebp + GDS.tick0],0
    jne     .dodelay_done
    mov     al,[ebp + GDS.curtick]
    cmp     al,[edi + channel.ActionTick]
    jne     .dodelay_done

    mov     byte [ebp + GDS.notedelayed],1
    mov     al,[edi + channel.DelayNote]

    mov     [ebp + GDS.procnot],al
    mov     al,[edi + channel.CurIns]

    mov     [ebp + GDS.procins],al
    mov     byte [ebp + GDS.proccmd],0ffh
    mov     byte [ebp + GDS.procvol],0
    call    PlayNote
.dodelay_done:
    ret
%else
dodelay equ procnothing
%endif


%if USEKEYOFFCMD
dokeyoff:
    cmp     byte [ebp + GDS.tick0],0
    jne     .dokeyoff_done
    mov     al,[ebp + GDS.curtick]
    cmp     al,[edi + channel.ActionTick]
    jne     .dokeyoff_done
    mov     byte [edi + channel.Sustain],0
    mov     eax,[edi + channel.EnvIns]
    cmp     eax,0
    je      .dokeyoff_done
    cmp     byte [eax + instrument.VNum],0
    jne     .dokeyoff_done
    mov     word [edi + channel.FadeVol],0
.dokeyoff_done:
    ret
%else
dokeyoff equ procnothing
%endif


%if USENOTECUT
donotecut:
    cmp     byte [ebp + GDS.tick0],0
    jne     .donotecut_done
    mov     al,[ebp + GDS.curtick]
    cmp     al,[edi + channel.ActionTick]

    jne     .donotecut_done
    mov     byte [edi + channel.Vol],0
    mov     byte [edi + channel.FinalVol],0
.donotecut_done:
    ret
%else
donotecut equ procnothing
%endif


%if USERETRIG
doretrig:
    cmp     byte [edi + channel.ActionTick],0
    je      .doretrig_done
    movzx   eax,byte [ebp + GDS.curtick]
    xor     edx, edx
    div     byte [edi + channel.ActionTick]

    cmp     ah,0
    jne     .doretrig_done
    mov     dword [edi + channel.MixNextPos],0
.doretrig_done:
    ret
%else
    doretrig equ procnothing
%endif


%if USEMRETRIG
procmretrig:
    movzx   eax,byte [ebp + GDS.procdat]
    cmp     al,0
    je      .procmretrig_reuse
    shl     eax,4
    shr     al,4
    mov     [edi + channel.MRetrigLen],al
    mov     [edi + channel.MRetrigAct],ah
    mov     byte [edi + channel.MRetrigPos],0
.procmretrig_reuse:
    ret

domretrig:
    mov     al,[edi + channel.MRetrigPos]
    inc     byte [edi + channel.MRetrigPos]
    cmp     al,[edi + channel.MRetrigLen]
    jne     .domretrig_done
    mov     byte [edi + channel.MRetrigPos],0
    mov     dword [edi + channel.MixNextPos],0
    mov     al,[edi + channel.Vol]
    mov     bl,[edi + channel.MRetrigAct]

    mov     ah,128
    xchg    bl,cl
    rol     ah,cl
    xchg    bl,cl
    test    bl,7
    jz      .domretrig_done
    test    bl,8
    jnz     .domretrig_up
    cmp     bl,5
    ja      .domretrig_nosub
    sub     al,ah
.domretrig_nosub:
    cmp     bl,6
    jne     .domretrig_not6
    mov     ah,al
    shr     al,2
    add     al,ah
    shr     al,1
.domretrig_not6:
    cmp     bl,7
    jne     .domretrig_setvol
    shr     al,1
    jmp     .domretrig_setvol

.domretrig_up:
    cmp     bl,13
    ja      .domretrig_noadd
    add     al,ah
.domretrig_noadd:
    cmp     bl,14
    jne     .domretrig_not14
    mov     ah,al
    shr     al,1
    add     al,ah
.domretrig_not14:
    cmp     bl,15
    jne     .domretrig_setvol
    shl     al,1
    jns     .domretrig_setvol
    dec     al

.domretrig_setvol:
    cmp     al,0
    jge     .domretrig_lok
    mov     al,0
.domretrig_lok:
    cmp     al,40h
    jbe     .domretrig_tok
    mov     al,40h
.domretrig_tok:
    mov     [edi + channel.Vol],al
    mov     [edi + channel.FinalVol],al
.domretrig_done:
    ret
%else
procmretrig equ procnothing
domretrig equ procnothing
%endif





;//***************************************************************************
;//effects end

callproccmdtab:
    call    .callproccmdtab_getadr
.callproccmdtab_getadr:
    pop     ebx
    mov     eax,[ebx+4*eax+(proccmdtab-.callproccmdtab_getadr)]
    lea     eax,[eax+ebx+(procnothing-.callproccmdtab_getadr)]
    jmp     eax


PlayTick:
    mov     byte [ebp + GDS.tick0],0
    lea     edi,[ebp + GDS.chandata]
    xor     ecx,ecx
.PlayTick_resetvalloop:
    mov     al,[edi + channel.Vol]

    mov     [edi + channel.FinalVol],al
    mov     al,[edi + channel.Pan]

    mov     [edi + channel.FinalPan],al
    mov     eax,[edi + channel.Pitch]

    mov     [edi + channel.FinalPitch],eax
    add     edi,channelsize
    inc     ecx
    cmp     ecx,[ebp + GDS.head + mxmheader.NChannels]
    jne     .PlayTick_resetvalloop

    inc     byte [ebp + GDS.curtick]
    mov     al,[ebp + GDS.curtick]
    cmp     al,[ebp + GDS.curtempo]
    jne     near .PlayTick_notnextrow

    mov     byte [ebp + GDS.curtick],0
    cmp     byte [ebp + GDS.patdelay],0
    jz      .PlayTick_nextrow
    dec     byte [ebp + GDS.patdelay]
    jmp     .PlayTick_notnextrow
.PlayTick_nextrow:
    mov     byte [ebp + GDS.tick0],1

    inc     dword [ebp + GDS.currow]
    cmp     dword [ebp + GDS.jumptoord],-1
    jne     .PlayTick_dojump
    mov     eax,[ebp + GDS.currow]
    cmp     eax,[ebp + GDS.patlen]
    jb      near .PlayTick_donotjump
    mov     eax,[ebp + GDS.curord]
    inc     eax
    mov     [ebp + GDS.jumptoord],eax
    mov     dword [ebp + GDS.jumptorow],0
.PlayTick_dojump:

    mov     eax,[ebp + GDS.jumptoord]
    cmp     [ebp + GDS.curord],eax
    je      .PlayTick_noresetploop
    lea     edi,[ebp + GDS.chandata]
    xor     ecx,ecx
.PlayTick_resetplloop:
    mov     byte [edi + channel.PatLoopCount],0
    mov     byte [edi + channel.PatLoopStart],0
    add     edi,channelsize
    inc     ecx
    cmp     ecx,[ebp + GDS.head + mxmheader.NChannels]
    jne     .PlayTick_resetplloop
.PlayTick_noresetploop:

    mov     eax,[ebp + GDS.jumptoord]
    cmp     eax,[ebp + GDS.head + mxmheader.NOrders]
    jb      .PlayTick_dontloop
    mov     eax,[ebp + GDS.head + mxmheader.OrdLoopStart]
.PlayTick_dontloop:
    mov     [ebp + GDS.curord],eax
    mov     eax,[ebp + GDS.jumptorow]
    mov     [ebp + GDS.currow],eax
    mov     dword [ebp + GDS.jumptoord],-1
    mov     eax,[ebp + GDS.curord]
    movzx   eax,byte [ebp + GDS.head + mxmheader.OrderTable + eax]
    mov     esi,[ebp + GDS.head + mxmheader.PatternTable + 4*eax]
    lodsd
    mov     [ebp + GDS.patlen],eax
    cmp     dword [ebp + GDS.jumptorow],0
    je      .PlayTick_rowfound
.PlayTick_rowfind:
.PlayTick_chanskip:
    lodsb
    cmp     al,0
    je      .PlayTick_rowend

    test    al,20h
    jz      .PlayTick_not20
    add     esi,2
.PlayTick_not20:
    test    al,40h
    jz      .PlayTick_not40
    inc     esi
.PlayTick_not40:
    test    al,80h
    jz      .PlayTick_chanskip
    add     esi,2
    jmp     .PlayTick_chanskip
.PlayTick_rowend:
    dec     dword [ebp + GDS.jumptorow]
    jnz     .PlayTick_rowfind
.PlayTick_rowfound:
    mov     [ebp + GDS.patptr],esi
.PlayTick_donotjump:

    mov     esi,[ebp + GDS.patptr]
    lea     edi,[ebp + GDS.chandata]
    xor     ecx,ecx
.PlayTick_processrow:
    mov     byte  [ebp + GDS.procnot],0
    mov     dword [ebp + GDS.procins],0
    mov     byte [edi + channel.Command],0ffh

    mov     al,[esi]
    cmp     al,0
    je      .PlayTick_procnextchan

    and     al,1fh
    cmp     al,cl
    jne     .PlayTick_procnextchan

    lodsb
    mov     ah,al
    test    ah,20h
    jz      .PlayTick_nonot
    lodsb
    mov     [ebp + GDS.procnot],al
    lodsb
    mov     [ebp + GDS.procins],al
.PlayTick_nonot:
    test    ah,40h
    jz      .PlayTick_novol
    lodsb
    mov     [ebp + GDS.procvol],al
    .PlayTick_novol:
    test    ah,80h
    jz      .PlayTick_nocmd
    lodsb
    mov     [ebp + GDS.proccmd],al
    lodsb
    mov     [ebp + GDS.procdat],al
.PlayTick_nocmd:
.PlayTick_procnote:
    mov     byte [ebp + GDS.notedelayed],0
    call    PlayNote

%if USEVOLCOL
    movzx   eax,byte [ebp + GDS.procvol]
    and     byte [ebp + GDS.procvol],0fh
    shr     eax,4
    mov     [edi + channel.VCommand],al
    add     eax,(procvoltab-proccmdtab)/4
    call    callproccmdtab
%endif
    movzx   eax,byte [ebp + GDS.proccmd]
    cmp     al,52
    jae     .PlayTick_procnextchan
    mov     [edi + channel.Command],al
    call    callproccmdtab
.PlayTick_procnextchan:
    add     edi,channelsize
    inc     ecx
    cmp     ecx,[ebp + GDS.head + mxmheader.NChannels]
    jne     near .PlayTick_processrow
    inc     esi
    mov     [ebp + GDS.patptr],esi
.PlayTick_notnextrow:
    lea     edi,[ebp + GDS.chandata]
    xor     ecx,ecx
.PlayTick_dotickloop:
%if USEVOLCOL
;//process volume column
    movzx   eax,byte [edi + channel.VCommand]
    add     eax,(dovoltab-proccmdtab)/4
    call    callproccmdtab
%endif

;//process command
    movzx   eax,byte [edi + channel.Command]
    cmp     al,52
    jae     .PlayTick_donocmd
    add     eax,(docmdtab-proccmdtab)/4
    call    callproccmdtab
.PlayTick_donocmd:
    mov     ebx,[edi + channel.EnvIns]
    cmp     ebx,0
    je      near .PlayTick_noenvins

;//process fadeout
    movzx   eax,byte [edi + channel.FinalVol]

    mul     byte [ebp + GDS.uservol]
    shr     eax,6
    mul     byte [ebp + GDS.globalvol]
    mul     word [edi + channel.FadeVol]

    shr     edx,4
    mov     [edi + channel.FinalVol],dl

    cmp     byte [edi + channel.Sustain],0
    jne     .PlayTick_sustain
    mov     ax,[ebx + instrument.VolFade]
    sub     [edi + channel.FadeVol],ax
    jnb     .PlayTick_sustain
    mov     word [edi + channel.FadeVol],0
.PlayTick_sustain:

%if USEVOLENV
;//process volume envelope
    mov     eax,[edi + channel.VolEnvPos]
    cmp     word [edi + channel.VolEnvSegPos],0
    je      .PlayTick_vnoloop
    cmp     al,[ebx + instrument.VLoopE]
    jne     .PlayTick_vnoloop
    mov     al,[ebx + instrument.VLoopS]
    mov     [edi + channel.VolEnvPos],eax
.PlayTick_vnoloop:
    lea     esi,[ebx + instrument.VEnv + 4*eax]

    cmp     al,[ebx + instrument.VNum]
    je      .PlayTick_venvlast

    mov     ax,[esi+4+2]
    mov     dx,[esi+0+2]
    sub     eax,edx
    imul    word [edi + channel.VolEnvSegPos]

    idiv    word   [esi+0]
    add     al,byte [esi+2]
    mul     byte [edi + channel.FinalVol]

    shr     eax,6
    mov     [edi + channel.FinalVol],al

    mov     ax,[edi + channel.VolEnvSegPos]

    cmp     ax,0
    jne     .PlayTick_vnosustain
    cmp     byte [edi + channel.Sustain],0
    je      .PlayTick_vnosustain
    mov     edx,[edi + channel.VolEnvPos]

    cmp     dl,[ebx + instrument.VSustain]
    je      .PlayTick_venvnostep
.PlayTick_vnosustain:
    inc     eax
    cmp     ax,[esi+0]
    jb      .PlayTick_venvnostep
    xor     eax,eax
    inc     dword [edi + channel.VolEnvPos]
.PlayTick_venvnostep:
    mov     [edi + channel.VolEnvSegPos],ax
    jmp     .PlayTick_venvend
.PlayTick_venvlast:
    mov     al,byte [esi+2]
    mul     byte [edi + channel.FinalVol]
    shr     eax,6
    mov     [edi + channel.FinalVol],al
.PlayTick_venvend:
%endif


%if USEPANENV
;//process panning envelope
    mov     eax, [edi + channel.PanEnvPos]
    cmp     word [edi + channel.PanEnvSegPos],0
    je      .PlayTick_pnoloop
    cmp     al,[ebx + instrument.PLoopE]
    jne     .PlayTick_pnoloop
    mov     al,[ebx + instrument.PLoopS]
    mov     [edi + channel.PanEnvPos],eax
.PlayTick_pnoloop:
    lea     esi,[ebx + instrument.PEnv + 4*eax]
    cmp     al,[ebx + instrument.PNum]
    je      .PlayTick_penvlast
    mov     ax,[esi+4+2]
    mov     dx,[esi+0+2]
    sub     eax,edx
    imul    word [edi + channel.PanEnvSegPos]
    idiv    byte [esi+0]
    add     al,byte [esi+2]
    sub     al,32

    movsx   edx,byte [edi + channel.FinalPan]
    xor     dl,dh
    imul    dl

    shr     eax,5
    add     [edi + channel.FinalPan],al

    mov     ax,[edi + channel.PanEnvSegPos]

    cmp     ax,0
    jne     .PlayTick_pnosustain
    cmp     byte [edi + channel.Sustain],0
    je      .PlayTick_pnosustain
    mov     edx,[edi + channel.PanEnvPos]

    cmp     dl,[ebx + instrument.PSustain]
    je      .PlayTick_penvnostep
.PlayTick_pnosustain:
    inc     eax
    cmp     ax,[esi+0]
    jb      .PlayTick_penvnostep
    xor     eax,eax
    inc     dword [edi + channel.PanEnvPos]

.PlayTick_penvnostep:
    mov     [edi + channel.PanEnvSegPos],ax
    jmp     .PlayTick_penvend

.PlayTick_penvlast:
    mov     al,byte [esi+2]
    sub     al,32
    movsx   edx,byte [edi + channel.FinalPan]

    xor     dl,dh
    imul    dl
    shr     eax,5
    add     [edi + channel.FinalPan],al
.PlayTick_penvend:
%else
%if USEFILTENV
;//process cutoff envelope
    mov     eax, [edi + channel.PanEnvPos]
    cmp     word [edi + channel.PanEnvSegPos],0
    je      .PlayTick_fnoloop
    cmp     al,[ebx + instrument.PLoopE]
    jne     .PlayTick_fnoloop
    mov     al,[ebx + instrument.PLoopS]
    mov     [edi + channel.PanEnvPos],eax
.PlayTick_fnoloop:
    lea     esi,[ebx + instrument.PEnv + 4*eax]
    cmp     al,[ebx + instrument.PNum]
    je      .PlayTick_fenvlast
    mov     ax,[esi+4+2]
    mov     dx,[esi+0+2]
    sub     eax,edx
    imul    word [edi + channel.PanEnvSegPos]
    idiv    byte [esi+0]
    add     al,byte [esi+2]
    mul     byte [edi + channel.FEnvAmnt]
    shr     eax, 6
    mov     [edi + channel.FinalCutoff],al

    mov     ax,[edi + channel.PanEnvSegPos]

    cmp     ax,0
    jne     .PlayTick_fnosustain
    cmp     byte [edi + channel.Sustain],0
    je      .PlayTick_fnosustain
    mov     edx,[edi + channel.PanEnvPos]

    cmp     dl,[ebx + instrument.PSustain]
    je      .PlayTick_fenvnostep
.PlayTick_fnosustain:
    inc     eax
    cmp     ax,[esi+0]
    jb      .PlayTick_fenvnostep
    xor     eax,eax
    inc     dword [edi + channel.PanEnvPos]

.PlayTick_fenvnostep:
    mov     [edi + channel.PanEnvSegPos],ax
    jmp     .PlayTick_fenvend

.PlayTick_fenvlast:
    mov     al,byte [esi+2]
    mul     byte [edi + channel.FEnvAmnt]
    shr     eax, 6
    mov     [edi + channel.FinalCutoff],al

.PlayTick_fenvend:
%endif
%endif

%if USEAUTOVIBRATO
;//process auto vibrato
    movzx   eax,byte [edi + channel.AVibPos]

    mov     ah,[ebx + instrument.VibType]
    mov     al,[ebp + GDS.vibtabs + eax]
    imul    byte [ebx + instrument.VibDepth]
    shr     eax,4

    mov     dl,[edi + channel.AVibSwpPos]

    cmp     dl,[ebx + instrument.VibSweep]
    jae     .PlayTick_nosweep
    imul    dl
    idiv    byte [ebx + instrument.VibSweep]
    inc     byte [edi + channel.AVibSwpPos]
.PlayTick_nosweep:
    neg     eax
    movsx   eax,al
    add     eax,[edi + channel.FinalPitch]

    call    freqrange
    mov     [edi + channel.FinalPitch],eax

    mov     al,[ebx + instrument.VibRate]
    add     [edi + channel.AVibPos],al
%endif

.PlayTick_noenvins:

;//conv vals for Mix
    movzx   eax,byte [edi + channel.FinalVol]
;   shl     eax, 1
    mov     [edi + channel.MixVol],ax
    mov     al,[edi + channel.FinalPan]
    mov     [edi + channel.MixPan],al
    mov     eax,[edi + channel.FinalPitch]
%if USEBOTHFREQ
    test    byte [ebp + GDS.head + mxmheader.Options],1
    jz      .PlayTick_amiga
%endif
%if USELINEARFREQ
    call    getfreq6848
    imul    eax, 14
    mov     ebx,494
    xor     edx, edx
    div     ebx
%endif
%if USEBOTHFREQ
    jmp     .PlayTick_noamiga
%endif
%if USEAMIGAFREQ
.PlayTick_amiga:
    cmp     eax,100
    jb      .PlayTick_noamiga
    mov     ebx,eax
    mov     eax,94929*14
    xor     edx, edx
    div     ebx
.PlayTick_noamiga:
%endif
    and     al, ~1
    mov     [edi + channel.MixFrq],ax

;//calc LPF vals
    movzx   eax, byte [edi + channel.Cutoff]
    add     al,  byte [edi + channel.FinalCutoff]
    sbb     bl, bl
    or      al, bl
    mov     [ebp + GDS.temp], eax
    fild    dword [ebp + GDS.temp]    		; <ic>
    fsub    dword [n255]                        ; <ic-255>
    fmul    dword [i24]               		; <(ic-255)/24 = ic'>
    fld1                              		; <1> <ic'>
    fld     st1                       		; <ic'> <1> <ic'>
    fprem                             		; <ic'frac> <1> <ic'>
    f2xm1                             		; <2^ic'frac-1> <1> <ic'>
    faddp   st1,st0                   		; <2^ic'frac> <ic'>
    fscale                            		; <2^ic'> <???>
    fxch    st1                       		; <???> <mcutn>
    fstp    st0                       		; <mcutn>
    fld     st0                       		; <mcutn> <mcutn>
    fmul    dword [n32767]            		; <mcut> <mcutn>
    fistp   dword [edi + channel.MixCutoff]     ; <mcutn>
    xor     eax, eax
    mov     [edi + channel.MixReso], eax
    mov     al, byte [edi + channel.Reso]
    or      al, al
    je      .PlayTick_ResoIs0
    fild    dword [edi + channel.Reso]          ; <res> <mcutn>
    fmul    dword [i255]                        ; <resn> <mcutn>
    fyl2x                    			; <mcutn*log2(resn)>
    fld1                              		; <1> <we>
    fld     st1                       		; <we> <1> <we>
    fprem                             		; <wefrac> <1> <we>
    f2xm1                             		; <2^wefrac-1> <1> <we>
    faddp   st1,st0                   		; <2^wefrac> <we>
    fscale                            		; <mresn> <???>
    fmul    dword [n32767]                      ; <mres> <???>
    fistp   dword [edi + channel.MixReso]       ; <???>
.PlayTick_ResoIs0
    fstp    st0

    add     edi,channelsize
    inc     ecx
    cmp     ecx,[ebp + GDS.head + mxmheader.NChannels]
    jne     near .PlayTick_dotickloop
    ret




global xmpPlay
xmpPlay:
    push    ebp
    call    loadebp

    cmp     byte [ebp + GDS.isplaying],0
    jne     .ente

    mov     [ebp + GDS.jumptoord],eax
    mov     [ebp + GDS.curord],eax
    xor     eax,eax
    mov     [ebp + GDS.currow],eax

    lea     edi,[ebp + GDS.chandata]
    mov     ecx,channelsize*8
    xor     eax,eax
    rep     stosd

    lea     edi,[ebp + GDS.chandata]
    xor     ecx,ecx
.xmpPlay_panloop:
    mov     al,[ebp + GDS.head + mxmheader.PanPos + ecx]
    mov     [edi + channel.Pan],al
    mov     byte [edi + channel.Cutoff], 0xff
    mov     byte [edi + channel.Reso]  , 0x00
    add     edi,channelsize
    inc     ecx
    cmp     cl,32
    jne     .xmpPlay_panloop

    xor     eax,eax
    mov     byte [ebp + GDS.globalvol],40h
    mov     [ebp + GDS.jumptorow],eax
    mov     [ebp + GDS.syncval],al

    mov     al,[ebp + GDS.head + mxmheader.IniTempo]
    mov     [ebp + GDS.curtempo],al
    dec     al
    mov     [ebp + GDS.curtick],al

    movzx   ebx,byte [ebp + GDS.head + mxmheader.IniBPM]
    mov     [ebp + GDS.stimerlen],ebx

    inc     byte [ebp + GDS.isplaying]
.ente:
    pop     ebp
    ret



global xmpStop
xmpStop:
    push    ebp
    call    loadebp
    cmp     byte [ebp + GDS.isplaying],0
    je      .ente
    dec     byte [ebp + GDS.isplaying]
.ente:
    pop     ebp
    ret


i24    dd 0.025
i255   dd 0.00392156862745098
n255   dd 255.0
n32767 dd 32767.0


sintab db 0,2,3,5,6,8,9,11,12,14,16,17,19,20,22,23,24,26,27,29,30,32,33
       db 34,36,37,38,39,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56
       db 56,57,58,59,59,60,60,61,61,62,62,62,63,63,63,64,64,64,64,64

logfreqtab dw 32768,32761,32753,32746,32738,32731,32724,32716,32709,32702,32694,32687,32679,32672,32665,32657
           dw 32768,32650,32532,32415,32298,32182,32066,31950,31835,31720,31606,31492,31379,31266,31153,31041
           dw 32768,30929,29193,27554,26008,24548,23170,21870,20643,19484,18390,17358,16384,15464,14596,13777
           dd 11131415,4417505,1753088,695713,276094,109568,43482,17256,6848,2718,1078,428,170,67,27,11


proccmdtab:
  dd procarpeggio-procnothing
  dd procportau-procnothing
  dd procportad-procnothing
  dd procportanote-procnothing
  dd procvibrato-procnothing
  dd procvolsl-procnothing
  dd procvolsl-procnothing
  dd proctremolo-procnothing
  dd procpan-procnothing
  dd 0
  dd procvolsl-procnothing
  dd procjump-procnothing
  dd procnvol-procnothing
  dd procbreak-procnothing
  dd 0
  dd proctempo-procnothing
  dd procgvol-procnothing
  dd procgvolsl-procnothing
  dd 0
  dd 0
  dd proctick-procnothing
  dd procenvpos-procnothing
  dd 0
  dd 0
  dd 0
  dd procpansl-procnothing
  dd procreso-procnothing
  dd procmretrig-procnothing
  dd procsync-procnothing
  dd proctremor-procnothing
  dd procaux-procnothing
  dd procenvamount-procnothing
  dd procsync-procnothing
  dd procxfporta-procnothing
  dd 0
  dd proccutoff-procnothing

  dd 0
  dd procfportau-procnothing
  dd procfportad-procnothing
  dd procgliss-procnothing
  dd procvibtype-procnothing
  dd 0
  dd procpatloop-procnothing
  dd proctremtype-procnothing
  dd procspan-procnothing
  dd proctick-procnothing
  dd procfvolup-procnothing
  dd procfvoldn-procnothing
  dd proctick-procnothing
  dd proctick-procnothing
  dd procpatdelay-procnothing
  dd procsync-procnothing

docmdtab:
  dd doarpeggio-procnothing
  dd doportau-procnothing
  dd doportad-procnothing
  dd doportanote-procnothing
  dd dovibrato-procnothing
  dd doportavol-procnothing
  dd dovibvol-procnothing
  dd dotremolo-procnothing
  dd 0
  dd 0
  dd dovolsl-procnothing
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd dogvolsl-procnothing
  dd 0
  dd 0
  dd dokeyoff-procnothing
  dd 0
  dd 0
  dd 0
  dd 0
  dd dopansl-procnothing
  dd 0
  dd domretrig-procnothing
  dd 0
  dd dotremor-procnothing
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0

  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd doretrig-procnothing
  dd 0
  dd 0
  dd donotecut-procnothing
  dd dodelay-procnothing
  dd 0
  dd 0

%if USEVOLCOL
procvoltab:
  dd 0
  dd procvvol0-procnothing
  dd procvvol1-procnothing
  dd procvvol2-procnothing
  dd procvvol3-procnothing
  dd procvvol4-procnothing
  dd procvvpsl-procnothing
  dd procvvpsl-procnothing
  dd procvfvoldn-procnothing
  dd procvfvolup-procnothing
  dd procvvibrat-procnothing
  dd procvvib-procnothing
  dd procvpan-procnothing
  dd procvvpsl-procnothing
  dd procvvpsl-procnothing
  dd procvportanote-procnothing

dovoltab:
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd 0
  dd dovvolsld-procnothing
  dd dovvolslu-procnothing
  dd 0
  dd 0
  dd 0
  dd dovibrato-procnothing
  dd 0
  dd dovpansll-procnothing
  dd dovpanslr-procnothing
  dd doportanote-procnothing
%endif


end
