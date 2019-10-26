
; The Syna functions in assembler
; The tune is "4k" by NF
; Some instruments updated by NF.

	bits	32
	global	syna_init,syna_play,rnd,counter
        extern  smp

%ifdef DEBUG
        extern  printf,fflush
%endif

        section .text

%define c1 1
%define C1 2
%define d1 3
%define D1 4
%define e1 5
%define f1 6
%define F1 7
%define g1 8
%define G1 9
%define a1 10
%define A1 11
%define B1 12
%define c2 13
%define C2 14
%define d2 15
%define D2 16
%define e2 17
%define f2 18
%define F2 19
%define g2 20
%define G2 21
%define a2 22
%define A2 23
%define B2 24
%define c3 25
%define C3 26
%define d3 27
%define D3 28
%define e3 29
%define f3 30
%define F3 31
%define g3 32
%define G3 33
%define a3 34
%define A3 35
%define B3 36
%define c4 37
%define C4 38
%define d4 39
%define D4 40
%define e4 41
%define f4 42
%define F4 43
%define g4 44
%define G4 45
%define a4 46
%define A4 47
%define B4 48
%define c5 49
%define C5 50
%define d5 51
%define D5 52
%define e5 53
%define f5 54
%define F5 55
%define g5 56
%define G5 57
%define a5 58
%define A5 59
%define B5 60
%define c6 61
%define C6 62
%define d6 63
%define D6 64
%define e6 65
%define f6 66
%define F6 67
%define g6 68
%define G6 69
%define a6 70
%define A6 71
%define B6 72

%define KANTTI 0
%define SINI 1
%define SAHA 2
%define KOHINA 3

%define END -2
%define LOOP -3
%define ECHON -4
%define ECHOFF -5
%define STOP -6

; Global settings. Mycket impotent!
%define INSTS 10
%define SLEN 168            ; Main freq per base note
%define UPDATE (6*44100/50) ; Row distance in samples /50 = 125 BPM
%define EKOLEN (UPDATE*3)
%define BFREQ 262

%define PDE 12
%define PLE 16

syna_play:
        push    ebp
        mov     ebp,esp
        pushad
        mov     edi,[ebp+PDE]

do_sample:
        mov     eax,[counter]
        mov     ebx,UPDATE
        cdq
        div     ebx
        or      edx,edx
        jz      yesrow
        jmp     norow

yesrow: mov     ecx,4
rovvi:  mov     eax,[ti+ecx] ; Handle new row
        cmp     eax,END
        jne     chnnotdone
        jmp     chndne

chnnotdone:
        inc     dword [pi+ecx]
        cmp     eax,-1
        je      newpos

        call    getcmd
        cmp     al,END
        jne     nonewpos

newpos: inc     dword [ti+ecx]
        mov     eax,[ti+ecx]
        mov     ebx,[trak+ecx]
        add     ebx,eax
        mov     al,[ebx]
        xor     edx,edx
        cmp     al,LOOP
        jne     nlp
        mov     [ti+ecx],edx
nlp:    cmp     al,END
        jne     nend
        mov     dword [ti+ecx],END
nend:   mov     [pi+ecx],edx

nonewpos:
        call    getcmd          ; Handle the commands
        or      al,al
        jz      chndne
        cmp     al,STOP
        jne     nost
        mov     dword [ecx+off],-1
        je      chndne
nost:   cmp     al,ECHON
        jne     noeon
        mov     [ecx+eko],al
        je      chndne
noeon:  cmp     al,ECHOFF
        jne     noeoff
        xor     dl,dl
        mov     [ecx+eko],dl
        jz      chndne

noeoff: add     eax,eax
        mov     ax,[notei-2+eax]
        shl     eax,16
        mov     ebx,BFREQ
        cdq
        div     ebx
        mov     [plus+ecx],eax
        cdq
        mov     [off+ecx],edx

chndne: add     ecx,4
        cmp     ecx,(INSTS+1)*4
        je      norow
        jmp     rovvi

; The summing loop
norow:  xor     eax,eax
        mov     [sum],eax
        mov     ecx,4
        mov     esi,65536*4+echo

sumlp:  mov     eax,[counter]  ; Echo first
        inc     eax
        call    ekou
        mov     ebx,[edx]
        add     [sum],ebx
        sar     ebx,1
        push    ebx
        mov     eax,[counter]
        call    ekou
        pop     ebx
        mov     [edx],ebx
        mov     [tmp],edx

        mov     ebx,[off+ecx]  ; Then the channel
        cmp     ebx,-1
        je      skipchan

        shr     ebx,16
        shl     ebx,2
        add     ebx,instr
        mov     eax,ecx
        shl     eax,16
        mov     eax,[eax+ebx]
        add     [sum],eax
        test    byte [eko+ecx],0ffh
        jz      noeko
        mov     ebx,5
        cdq
        idiv    ebx
        mov     ebx,[tmp]
        mov     [ebx],eax
        
noeko:  mov     eax,[off+ecx]
        add     eax,[plus+ecx]
        cmp     eax,44100<<16
        jb      hobla
        mov     eax,-1
hobla:  mov     [off+ecx],eax
        shr     eax,16

skipchan:
        add     esi,65536*4
        add     ecx,4
        cmp     ecx,(INSTS+1)*4
        je      jeah
        jmp     sumlp

jeah:   mov     eax,[sum]
        cmp     eax,-32767*3
        jge     clip2
        mov     eax,-32767*3
clip2:  cmp     eax,32767*3
        jle     done
        mov     eax,32767*3
done:   cdq
        mov     ebx,3
        idiv    ebx
        stosw
        inc     dword [counter]
        sub     dword [ebp+PLE],2
        jz      gone
        jmp     do_sample

gone:   

; Was: analyysi(signed short *data,int length)
; Analysoitava data 16-bittisina sampleina ja samplejen maara
        mov     edi,[ebp+PDE]
        mov     [smp],edi

        popad   
        pop     ebp
        ret

getcmd: mov     eax,[ti+ecx]
        mov     ebx,[trak+ecx]
        add     ebx,eax
        xor     eax,eax
        mov     al,[ebx]
        shl     eax,2
        mov     ebx,[ptn+eax]
        add     ebx,[pi+ecx]
        mov     al,[ebx]
        ret

ekou:   mov     ebx,EKOLEN
        cdq
        div     ebx
        shl     edx,2
        add     edx,esi
        ret

; The init routine of Syna
syna_init:
        pushad

	std
notet:  mov     esi,notei+(6*12-1)*2
        mov     edi,notei+(5*12-1)*2
        mov     ecx,5*12
notex:  lodsw
	shr	ax,1
        stosw
        loop    notex
        cld

aallot: mov     edi,aalto
        xor     ebx,ebx
        mov     ebp,SLEN
        mov     ecx,65536

uallot: mov     eax,ebx
        add     eax,ebx
        cdq
        div     ebp
        and     al,1
        mov     eax,32767        
        jz      kantoh
        neg     eax
kantoh: stosd
        
        mov     eax,ebx ; Saha-aalto
        cdq
        div     ebp
        shl     edx,16
        mov     eax,edx
        cdq
        div     ebp
        sub     eax,32768
        mov     [edi+(65535+65536)*4],eax

        call    rnd
        and     eax,0ffffh
        sub     eax,32768
        mov     [edi+(65535+65536*2)*4],eax

        ; My first ever x86 FPU code...
        fld     qword [f_tmp]
        fld     st0
        fsin
        fmul    qword [f_mul]
        fistp   dword [f_int]
        fadd    qword [f_plus]
        fstp    qword [f_tmp]

        mov     eax,[f_int]
        mov     [edi+65535*4],eax

        inc     ebx
        loop    uallot

instrut:mov     ebp,i1
        mov     ecx,INSTS
ilupi:  push    ecx
        call    adsr
        add     ebp,32
        pop     ecx
        loop    ilupi

        popad
        ret

; param[]=A,D,S,R,modulation,ins,wave,sweep
%define PI 0
%define PW 4
%define PA 8
%define PD 12
%define PS 16
%define PR 20
%define PM 24
%define SW 28

adsr:   xor     eax,eax
        mov     [op_h],eax
        mov     [op_l],eax
        mov     [oh_h],eax
        mov     [oh_l],eax
        mov     [vol],eax
        mov     [ii],eax
        inc     al
        shl     eax,16
        mov     [iip],eax

        mov     eax,[ebp+SW]
        shl     eax,16
        cdq
        mov     ebx,1000*SLEN
        idiv    ebx
        mov     [swp],eax

        xor     eax,eax
        add     eax,[ebp+PM]
        jz      nomod
        mov     ebx,103
        cdq
        div     ebx
        mov     [op_h],eax
        mov     eax,edx
        mov     edx,4294967295/103
        mul     edx
        mov     [op_l],eax
        jmp     go_on
nomod:  mov     dword [oh_h],(SLEN/4)

go_on:  mov     eax,[ebp+PI]
        shl     eax,18
        lea     edi,[eax+instr]
        mov     eax,[ebp+PW]
        shl     eax,18
        lea     esi,[eax+aalto]

        mov     eax,2048*1024
        mov     ecx,[ebp+PA]
        cdq
        div     ecx
        call    phase1

        neg     dword [dv]
        mov     ecx,[ebp+PD]
        call    phase

        xor     eax,eax
        mov     ecx,[ebp+PS]
        call    phase1

        mov     ecx,[ebp+PR]
        mov     eax,[vol]     
        cdq
        idiv    ecx
        neg     eax
        call    phase1

        ret

phase1: mov     [dv],eax
phase:  or	ecx,ecx
	jnz	menox
	ret
menox:	;lodsd
        mov     eax,[iip]
        add     [ii],eax
        mov     eax,[swp]
        add     [iip],eax
        mov     eax,[ii]
        shr     eax,16
        shl     eax,2
        mov     eax,[esi+eax]

        mov     ebx,[vol]
        sar     ebx,10
        imul    ebx
        sar     eax,11

        mov     ebx,eax
        mov     edx,[oh_h]
        and     edx,0ffffh
        shl     edx,2
        mov     eax,[edx+65536*4+aalto]
        sar     eax,4
        imul    ebx
        sar     eax,12
        stosd

        mov     eax,[dv]
        add     [vol],eax
        mov     eax,[op_l]
        add     [oh_l],eax
        mov     eax,[op_h]
        adc     [oh_h],eax
        loop    phase
        ret

%define RANDOM_SEED 0f31782ceh

rnd:    mov     eax,[rndi]
        add     eax,RANDOM_SEED
        xor     eax,RANDOM_SEED
        ror     eax,1
        mov     [rndi],eax
        ret

%ifdef DEBUG
peax:   pushad
        push    eax
        mov     eax,printhi
        push    eax
        call    printf
        pop     eax
        pop     eax
        xor     eax,eax
        push    eax
        call    fflush
        pop     eax
        popad
        ret
%endif

	section	.data

; Instrumentit. ADSR:ssa ei saa olla nollaa, pienin arvo 1.

; bd
i1:	dd    	1,SINI,2,12,1,4000,0,-60
; snare
i2:	dd	2,KOHINA,2,6,1,5600,0,0
; snare2
i3:	dd	3,SAHA,2,4,1,10000,1299,0

; basso-main
i4:	dd	4,KANTTI,2,3,1,2000,0,4

; hit
i5:	dd	5,KOHINA,2,4,1,20000,0,-20

; tomdrum
i6:	dd	6,SINI,2,5,1,6000,0,-7

; basso-tausta
i7:	dd	7,KANTTI,2,4,1,2000,0,0

; melodia-saha
i8:     dd  8,SAHA,2,4,1,40000,00,0

; melodia-sini
i9:    dd  9,SINI,2,10,1,6000,100,0

; basso-2
i10:	 dd  10,KANTTI,2,3,1,2000,1555,4


; bd
t1:     db  1,5,5,5,5,5,5,5, 14,21, 3,3,3,3, 3,3,3,24,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,24,5,3,3,15,5,5,5,5,5,5,5,5,    LOOP
                                                                                                            ;uus
t2:	db  2,5,5,5,5,5,5,5, 14,21, 4,4,13,22,4,4,13,4,4,4,13,4,4,4,13,22,5,5,5,5,5,5,5,5,5,5,14,  LOOP
t3:	db  2,5,5,5,5,5,5,5, 14,21, 4,4,13,22,4,4,13,4,4,4,13,4,4,4,13,22,5,5,5,5,5,5,5,5,5,5,14,  LOOP

;basso 2
t4:	db  2,5,5,5,5, 8,8,16,8,               8,8,16,8,5,5,5,5, 8,8,8,8,5,5,5,5,5,5,3,3, 3,3,3,3,3,3,3,5,5,5,5,LOOP

; hit
t5:	db  2,5,5,5,5,5,5,5,5, 15,5,5,5,14,15,14,15,14,15,14,15,5,5,5,5,5,5,5,5,14,15,5,5,5,5,5,5,5,5,LOOP
;t5: db 2,LOOP
                                                                   					                                    ;uus
; tom-rummut
t6:	db  2,7,7, 7,7,7, 7,7,7,7,7,7,7,5,5,5,5,5,7,7,7,    5,5,LOOP

;basso
t7:	db  1,5,5,5,5,3,3,3,3,3,3,3,3, 8,8,16,8, 8,8,8,8,                  8,8,8,8, 16,16,16,16, 20,3,3,3,3,3,3,3,3,3,3,3,3,5,5,5,5,LOOP

; melodiasaha
t8:	db  2,5,5,5,5,5,5,5,5,5,5,5,5,         11,12,5,9,5,14,23,5,5,17,14, 14,15,5,5,5,5,5,5,5,5,5,5,14,   5,5,LOOP
; melodiasini
t9:	db  2,3,3,3,3,     3,3,3,3, 3,3,3,3,5,5, 3 ,3 ,3 ,3 ,3 ,3 ,3 ,3 ,11,5,14,23, 11,12,17,5,14,5,5,5,5, 14,7,7,5,5,5,5,5,5,5,5,5,5,5,5,5,5,LOOP

; basso-tausta
t10:	db  1,4,22,4,22, 4,22,5,5,5,5,5,5, 11, 5,14,23, 8,8,8,8, 16,16,16,16, 20,5,5,5,5,5,5,5,5,5,5,5,5,5,5,LOOP
                                                                                                               ; uus
trak:   dd  0,t1,t2,t3,t4,t5,t6,t7,t8,t9,t10

p1:    db  0,END
p2:    db ECHON,END
p3:	db g3,00,00,00,g6,00,00,g3,00,g3,00,g3,g5,00,00,g5,END
p4:	db c6,00,c5,00,c4,00,c6,c5,00,00,c6,c5,c4,00,c6,c5, c6,00,c5,00,c4,00,c6,00,00,00,c6,c5,c4,c6,00,c4,END
p5:	db 00,00,00,00,00,00,00,00, 00,00,00,00,00,00,00,00, 00,00,00,00,00,00,00,00, 00,00,00,00,00,00,00,00,END
p6:     db END
p7:	db B4,B4,00,B3,00,C4,f3,00,a4,c5,c5,00,c6,c4,c3,a4,a2,00,a4,00,a3,00,c4,e3,00,a4,c5,c5,00,c6,c4,c3,    B3,B4,B4,00,B3,00,C4,f3,00,a4,c5,c5,00,c6,c4,c3,a4,a2,00,a4,00,a3,00,c4,e3,00,a4,c5,c5,00,c6,c4,END
p8:     db a2,a1,g2,g2,a2,a2,e1,e2,a2,a2,g1,g2,a2,a1,c2,c2,a2,a1,g2,g2,a2,a2,d1,d2,a2,a2,g1,g2,a2,a1,g2,g2,END
p9:    	db a3,g4,a4,00,00,00,c5,d5,c5,00,00,00,a4,g4,a3,00,00,00,c5,d5,c4,00,00,00,a3,g4,a4,g3,a3,c4,d4,a5,END
p10: 	db END
p11:	db a4,e4,00,a4,D4,00,a4,d4, 00,a4,c4,00,a4,e4,00,a4, D4,00,a4,d4,00,a4,c4,00, a4,a3,00,d4,00,D4,00,e4, a5,e5,00,a5,D5,00,a5,d5, 00,a5,c5,00,a5,e5,00,a5, D5,00,a5,d5,00,a5,c5,a5, a5,a5,a3,d5,a4,D5,a3,e5, END
p12:	db a3,e3,00,a3,D3,00,a3,d3, 00,a3,c3,00,a3,e3,00,a3, D3,00,a3,d3,00,a3,c3,00, a3,a2,00,d3,00,D3,00,e3, a5,e5,00,a5,D5,00,a5,d5, 00,a5,c5,00,a5,e5,00,a5, D5,00,a5,d5,00,a5,c5,a5, a5,a5,a4,d5,a4,D5,a3,e5, END
p13:	db c6,00,c5,00, c4,c4,c6,c5, 00,00,c6,c5, c4,00,c6,c4, c6,c4,c5,00, c4,00,c6,B3, 00,A3,c6,c5, c4,00,c6,c4,  END

p14:	db 00,00,00,00,00,00,00,00, 00,00,00,00,00,00,00,00, END

p15:	db a2,00,00,00,00,00,00,00, 00,00,00,00,00,00,00,00, END
p16:  	db c3,c2,A2,A2,c3,c3,g1,g2,c3,c3,A1,A2,c3,c2,D2,D2,c3,c2,A2,A2,c3,c3,f1,f2,c3,c3,A1,A2,c3,c2,A2,A2,END
p17:    db c4,A4,c5,00,00,00,D5,f5,D5,00,00,00,c5,A4,c4,00,00,00,D5,f5,D4,00,00,00,c4,A4,c5,A3,c4,D4,f4,c6,END
p18:	db END
p19:	db END
p20:	db a6,00,00,a6,00,00,a6,00, 00,00,a6,e6,a5,e5,a4,e4, a3,e3,a2,e2,a1,e1,a2,e2, a3,e3,a3,a4,00,00,00,00,END

p21:    db 00,00,a5,a5,a5,00,a5,00,a4,a4,a2,a2,a3,a2,a2,a3,END

p22:	db c6,00,c5,00,c4,00,c6,c5,00,00,c6,c5,c4,00,c6,c5, c6,00,c5,a5,c4,00,c6,00,a5,a5,a4,a5,a5,a4,a5,a5,END

p23:	db a5,g5,D5,d5, d5,c5,a4,g4, D4,d4,d4,c4, a3,g3,D3,d4,END
p24:    db g3,00,00,00,g6,00,00,g3,a4,a4,a3,a4,a4,a3,a4,a4,END

ptn:    dd      0,p1,p2,p3,p4,p5,p6,p7,p8,p9,p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20,p21,p22,p23,p24

rndi:   dd      RANDOM_SEED

notei:  dw	0,0,0,0, 0,0,0,0, 0,0,0,0
	dw	0,0,0,0, 0,0,0,0, 0,0,0,0
        dw      0,0,0,0, 0,0,0,0, 0,0,0,0
        dw      0,0,0,0, 0,0,0,0, 0,0,0,0
        dw      0,0,0,0, 0,0,0,0, 0,0,0,0
        dw      1047,1109,1175,1245, 1319,1397,1480,1568, 1661,1760,1864,1976

; Tarvii olla kanavien maara +1
off:    dd      -1,-1,-1,-1,-1, -1,-1,-1,-1,-1, -1
ti:     dd      -1,-1,-1,-1,-1, -1,-1,-1,-1,-1, -1

f_int:  dd      0
f_plus: dq      0.0374
f_tmp:  dq      0.0
f_mul:  dq      32767.0

counter: dd     0

%ifdef DEBUG
printhi: dd     "%d:",0
%endif

        section .bss

op_h:   resd    1
op_l:   resd    1
oh_h:   resd    1
oh_l:   resd    1
vol:    resd    1
dv:     resd    1
sum:    resd    1
tmp:    resd    1
ii:     resd    1
iip:    resd    1
swp:    resd    1
ple:    resd    1

aalto:  resd    65536*(INSTS+1)
instr:  resd    65536*(INSTS+1)
echo:   resd    65536*(INSTS+1)
plus:   resd    INSTS+1
pi:     resd    INSTS+1
eko:    resd    INSTS+1

; Loppu!
