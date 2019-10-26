Dosseg
;
; Quick 'n' Dirty play    for Surprise! Adlib Tracker SA2 files (version 9)
;
.Model Small
.Stack 40H
.286
locals

.Data

NoAdlib         db 7,"No Adlib found!$"

.Code

;include memtools.blk

locals
.286

public start
public end_of_all
public get_file


fname db "praises.sa2"
      db 130 dup (0)


fsong dw ?

dsong dw ?

Okt1 equ 0010000000000000B
Okt2 equ 0010010000000000B
Okt3 equ 0010100000000000B
Okt4 equ 0010110000000000B
Okt5 equ 0011000000000000B
Okt6 equ 0011010000000000B
Okt7 equ 0011100000000000B
Okt8 equ 0011110000000000B

_patternorder   equ 966
_songlength     equ 1096
_restart        equ 1097
_bpm            equ 1098
_arpeggio       equ 1100
_acommands      equ 1356
_trackorder     equ 1612
_channels       equ 2188
_trackdata      equ 2190


Adwrite macro r,w
        mov     dx,388h
        mov     al,r
        out     dx,al
        call    waitlong
        mov     dx,389h
        mov     al,w
        out     dx,al
endm

NoteTab dw 0                                                         ; dummy note
        dw Okt1+343,Okt1+363,Okt1+385,Okt1+408,Okt1+432,Okt1+458
        dw Okt1+485,Okt1+514,Okt1+544,Okt1+577,Okt1+611,Okt1+647     ; Oktave3
        dw Okt2+343,Okt2+363,Okt2+385,Okt2+408,Okt2+432,Okt2+458
        dw Okt2+485,Okt2+514,Okt2+544,Okt2+577,Okt2+611,Okt2+647     ; Oktave3
        dw Okt3+343,Okt3+363,Okt3+385,Okt3+408,Okt3+432,Okt3+458
        dw Okt3+485,Okt3+514,Okt3+544,Okt3+577,Okt3+611,Okt3+647     ; Oktave3
        dw Okt4+343,Okt4+363,Okt4+385,Okt4+408,Okt4+432,Okt4+458
        dw Okt4+485,Okt4+514,Okt4+544,Okt4+577,Okt4+611,Okt4+647     ; Oktave4
        dw Okt5+343,Okt5+363,Okt5+385,Okt5+408,Okt5+432,Okt5+458
        dw Okt5+485,Okt5+514,Okt5+544,Okt5+577,Okt5+611,Okt5+647     ; Oktave5
        dw Okt6+343,Okt6+363,Okt6+385,Okt6+408,Okt6+432,Okt6+458
        dw Okt6+485,Okt6+514,Okt6+544,Okt6+577,Okt6+611,Okt6+647     ; Oktave6
        dw Okt7+343,Okt7+363,Okt7+385,Okt7+408,Okt7+432,Okt7+458
        dw Okt7+485,Okt7+514,Okt7+544,Okt7+577,Okt7+611,Okt7+647     ; Oktave7
        dw Okt8+343,Okt8+363,Okt8+385,Okt8+408,Okt8+432,Okt8+458
        dw Okt8+485,Okt8+514,Okt8+544,Okt8+577,Okt8+611,Okt8+647;    ; Oktave8
        dw 16 dup (Okt8+647)

InsTab  dw 32 dup (0)

Register_map db 0,1,2,8,9,10,16,17,18

Vibratotab db    0, 24, 49, 74, 97,120,141,161
           db  180,197,212,224,235,244,250,253
           db  255,253,250,244,235,224,212,197
           db  180,161,141,120, 97, 74, 49, 24

arpeggio_table  db 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1

channel_active  db 9 dup (0)
channel_ins     db 9 dup (0)
channel_note    db 9 dup (0)
channel_note2   db 9 dup (0)
channel_vol2    db 9 dup (0)    ; connector
channel_vol     db 9 dup (0)    ; carrier
channel_vpos    db 9 dup (0)
channel_vspeed  db 9 dup (0)
channel_vdepth  db 9 dup (0)
channel_eff     dw 9 dup (0)
channel_freq    dw 9 dup (0)
channel_fshift  dw 9 dup (0)
channel_pdest   dw 9 dup (0)
channel_pspeed  dw 9 dup (0)
channel_aspeed  db 9 dup (0)
channel_acurpos db 9 dup (0)
channel_acursp  db 9 dup (0)
channel_vsubt   db 9 dup (0)
channel_segment db 9 dup (0)

mainvol         db 64           ; 64 = max, 0 = min
count           db 0
Register_bypass db 246 dup (0)
current_pos     db 9 dup (0)
current_speed   db 9 dup (6)
s_count         db 9 dup (0)
current_line    db 9 dup (0)
work_pattern    dw 9 dup (_trackorder)
position_jump   db 9 dup (0)
new_position    db 9 dup (0)
break_pos       db 9 dup (0)
pattern_break   db 9 dup (0)
polling         db 1
segments        dw 9 dup (0)
stopped         db 9 dup (1)

segnum          dw 0
current_bpm     dw 0

waitlong proc
;
; waits 23.3 ys
;
        rept 35
        in      al,dx
        endm
        ret
waitlong endp


Fastwrite proc
        cmp     cs:Register_bypass[bx],ah
        je      f_w_1

        mov     cs:Register_bypass[bx],ah

        mov     dx,388h
        mov     al,bl
        out     dx,al
        call    waitlong
        mov     dx,389h
        mov     al,ah
        out     dx,al
f_w_1:
        ret
Fastwrite endp


WriteThrough proc
        mov     cs:Register_bypass[bx],ah

        mov     dx,388h
        mov     al,bl
        out     dx,al
        call    waitlong
        mov     dx,389h
        mov     al,ah
        out     dx,al
        ret
WriteThrough endp

empty proc
        ret
empty endp

general_ret:
        sti
        ret

TestAdlib proc
;
; Checks for adlib
; carry flag:
;         1...........no Adlib detected
;         0...........Adlib found (yeah!)
;
        Adwrite 1,0
        Adwrite 4,60H
        Adwrite 4,80H

        mov     dx,388h
        in      al,dx
        and     al,11100000b
        mov     bl,al

        Adwrite 2,0ffH
        Adwrite 4,00100001b

        mov     cx,6
t_a_1:
        call    waitlong
        loop    t_a_1

        mov     dx,388h
        in      al,dx
        and     al,11100000b
        mov     bh,al

        Adwrite 4,60H
        Adwrite 4,80H

        cmp     bl,0
        jne     t_a_2
        cmp     bh,11000000b
        jne     t_a_2

        clc
        ret
t_a_2:
        stc
        mov     ax,4
        ret
TestAdlib endp

Init_Adlib proc
        mov     bx,1
        mov     cx,245
I_a_1:
        mov     ah,0
        call    WriteThrough
        inc     bx
        loop    I_a_1

        mov     bx,1
        mov     ah,00100000b
        call    WriteThrough
        mov     bx,8
        mov     ah,01000000B
        call    WriteThrough
        mov     bx,0bdh
        mov     ah,11000000B
        call    WriteThrough

        lea     bx,InsTab
        mov     ax,5
        mov     cx,31
I_a_3:
        mov     cs:[bx],ax
        add     bx,2
        add     ax,15
        loop    I_a_3


        mov     mainvol,64

        clc
        ret
Init_Adlib endp

Init_Adlib_Tables proc
;
; Initialisiert Tabellen, etc.
;
        mov     si,0
        mov     bx,0
        mov     cx,9
@@l1:
        mov     stopped         [si],1
        mov     channel_active  [si],0
        mov     channel_ins     [si],0
        mov     channel_note    [si],0
        mov     channel_note2   [si],0
        mov     channel_vol     [si],0
        mov     channel_vol2    [si],0
        mov     channel_vpos    [si],0
        mov     channel_vspeed  [si],0
        mov     channel_vdepth  [si],0
        mov     channel_eff     [bx],0
        mov     channel_freq    [bx],0
        mov     channel_fshift  [bx],0
        mov     channel_pdest   [bx],0
        mov     channel_pspeed  [bx],0
        mov     channel_aspeed  [si],0
        mov     channel_acurpos [si],0
        mov     channel_acursp  [si],0
        mov     channel_vsubt   [si],0
        mov     current_speed   [si],6
        mov     current_line    [si],0
        mov     break_pos       [si],0
        mov     pattern_break   [si],0
        mov     position_jump   [si],0
        inc     si
        add     bx,2
        jumps
        loop    @@l1
        nojumps
        mov     mainvol,64
        ret
Init_Adlib_Tables endp

DefineBoth proc
        add     bl,cl
        lodsw
        mov     ch,ah
        mov     ah,al
        call    Fastwrite               ; Connector
        add     bl,3
        mov     ah,ch
        call    Fastwrite               ; Carrier
        ret
DefineBoth endp

CalcVol proc
        sub     al,63
        neg     al
        mov     dl,mainvol
        mul     dl
        shr     ax,6
        sub     al,63
        neg     al
        ret
calcvol endp

Set_Volume proc
        mov     di,bx
        mov     bx,40h
        add     bl,Register_map[di]     ; bl = KSL / TL offset

        mov     cx,ax

        mov     al,ch
        and     al,63
        mov     channel_vol2[di],al
        call    calcvol
        mov     ah,al
        mov     al,register_bypass[bx]
        and     al,11000000b
        or      ah,al
        call    Fastwrite

s_v_1:
        add     bl,3

        mov     al,cl
        and     al,63
        mov     channel_vol[di],al
        call    calcvol
        mov     ah,al
        mov     al,register_bypass[bx]
        and     al,11000000b
        or      ah,al
        jmp     Fastwrite
Set_Volume endp

calc_freq_up proc
        mov     dx,cx
        mov     di,cx
        and     dx,0011110000000000b
        and     cx,1023
        add     cx,ax
        cmp     cx,647
        jl      @@fu_ok
        mov     ax,di
@@fu_2:
        and     ax,0001110000000000b
        cmp     ax,0001110000000000b
        jne     @@next_okt
        mov     cx,di
        jmp     @@fu_ok
@@next_okt:
        sar     cx,1
        add     ax,0000010000000000b
        and     di,0010000000000000b
        or      ax,di
        mov     dx,ax
        cmp     cx,647
        jg      @@fu_2
@@fu_ok:
        or      cx,dx
        ret
calc_freq_up endp

calc_freq_down proc
        mov     dx,cx
        mov     di,cx
        and     dx,0011110000000000b
        and     cx,1023
        sub     cx,ax
        cmp     cx,343
        jg      @@fd_ok
        mov     ax,di
@@fd_2:
        and     ax,0001110000000000b
        cmp     ax,0
        jne     @@prev_okt
        mov     cx,di
        jmp     @@fd_ok
@@prev_okt:
        sal     cx,1
        sar     ah,2
        dec     ah
        sal     ah,2
        and     di,0010000000000000b
        or      ax,di
        mov     dx,ax
        cmp     cx,343
        jl      @@fd_2
@@fd_ok:
        or      cx,dx
        ret
calc_freq_down endp

Frequenz_up2 proc
        shl     bp,1
        mov     cx,cs:channel_freq[bp]
        shr     bp,1
        call    calc_freq_up
        add     bx,0a0h
        mov     ah,cl
        call    Fastwrite
        add     bx,10h
        mov     ah,register_bypass[bx]
        and     ah,32
        and     ch,31
        or      ah,ch
        call    Fastwrite
        ret
Frequenz_up2 endp

Frequenz_down2 proc
        shl     bp,1
        mov     cx,cs:channel_freq[bp]
        shr     bp,1
        add     bx,0a0h
        call    calc_freq_down
        mov     ah,cl
        call    Fastwrite
        add     bx,10h
        mov     ah,register_bypass[bx]
        and     ah,32
        and     ch,31
        or      ah,ch
        call    Fastwrite
        ret
Frequenz_down2 endp

Release_note proc
        add     bx,0b0h
        mov     ah,register_bypass[bx]
        test    ah,32
        jz      @@released
        and     ah,255-32
        jmp     WriteThrough
@@released:
        ret
release_note endp

Retrig_note proc
        add     bx,0b0h
        mov     ah,register_bypass[bx]
        test    ah,32
        jnz     @@still_on
        or      ah,32
        call    WriteThrough
@@released:
        ret
@@still_on:
        mov     bx,bp
        call    release_note
        mov     bx,bp
        jmp     retrig_note
retrig_note endp;

Play_Note2 proc
        pusha
        call    release_note


        sub     bx,10h
        xor     ch,ch
        mov     si,cx
        shl     si,1
        add     si,offset NoteTab
        mov     cx,cs:[si]
        mov     ah,cl
        call    Fastwrite

        add     bx,10h
        mov     ah,ch
        call    WriteThrough

        mov     bx,bp
        shl     bx,1
        mov     channel_freq[bx],cx
        mov     channel_fshift[bx],0

        popa
        ret
play_note2 endp

Set_Freq proc
        add     bx,0a0h

        mov     ah,cl
        call    Fastwrite

        add     bx,10h
        mov     ah,register_bypass[bx]
        and     ah,32
        and     ch,31
        or      ah,ch
        call    FastWrite

        mov     bx,bp
        shl     bx,1
        mov     channel_freq[bx],cx
        ret
Set_Freq endp

Init_Instrument2 proc
        pusha

        mov     bl,ch
        dec     bl
        xor     bh,bh
        shl     bx,1
        mov     si,cs:instab[bx]

;--- spec. arpeggio init ----------------------------------

        mov     bx,si

        add     si,11
        lodsb
        mov     cs:channel_acurpos[bp],al
        lodsb
        cmp     al,0
        jne     @@alok
        inc     al
@@alok:
        mov     cs:channel_acursp[bp],0
        mov     cs:channel_aspeed[bp],al

@@no_spec:
        mov     si,bx

;----------------------------------------------------------


        mov     bx,bp

        mov     cl,bl

        mov     bx,0c0h
        add     bl,cl
        lodsb
        mov     ah,al
        mov     ch,al
        call    Fastwrite

        mov     bx,bp
        add     bx,offset Register_map
        mov     cl,cs:[bx]

        mov     bx,20h
        call    DefineBoth

        mov     bx,60h
        call    DefineBoth

        mov     bx,80h
        call    DefineBoth

        mov     bx,0e0h
        call    DefineBoth

        mov     bx,40h
        add     bl,cl

        lodsw
        mov     cx,ax

        mov     di,bp
        mov     al,byte ptr channel_vol2[di]
        mov     ah,byte ptr channel_vol[di]
        and     ax,0011111100111111b
        and     cx,1100000011000000b
        or      ax,cx
        or      cx,ax

        and     al,63
        call    calcvol
        mov     ah,al
        and     cl,11000000b
        or      ah,cl
        call    Fastwrite

        add     bl,3

        mov     al,ch
        and     al,63
        call    calcvol
        mov     ah,al
        and     ch,11000000b
        or      ah,ch
        call    Fastwrite

        popa
        ret
@@seperate_vol:
        ret
Init_Instrument2 endp

select_wave proc
        mov     bl,register_map[bx]
        xor     bh,bh
        add     bx,0e0h
        mov     ah,cl
        dec     ah
        js      @@none1
        call    fastwrite
@@none1:
        add     bx,3
        mov     ah,ch
        dec     ah
        js      @@none2
        jmp     fastwrite
@@none2:
        ret
select_wave endp

Mute_voice proc
        push    bx
        mov     dl,register_map[bx]
        mov     cl,dl
        add     dl,60h
        mov     bl,dl
        mov     di,bx
        mov     ah,0ffh
        call    fastwrite
        mov     bx,di
        add     bx,3
        mov     ah,0ffh
        call    fastwrite
        mov     bx,di
        add     bx,20h
        mov     ah,0ffh
        call    fastwrite
        mov     bx,di
        add     bx,23h
        mov     ah,0ffh
        call    fastwrite
        pop     bx
        add     bx,0b0h
        mov     di,bx
        mov     ah,032
        call    fastwrite
        mov     bl,cl
        add     bx,40h
        mov     ah,register_bypass[bx]
        or      ah,63
        call    fastwrite
        mov     ah,0
        mov     bx,di
        jmp     fastwrite
m_v:
        ret
Mute_voice endp

Clear_All_Voices proc
        mov     cx,9
        mov     bp,0
c_a_v_2:
        push    cx
        mov     bx,bp
        call    mute_voice
        inc     bp
        pop     cx
        loop    c_a_v_2

        ret
Clear_All_Voices endp

Set_Main_Volume proc
        cmp     bl,64
        jbe     s_m_v_ok
        mov     ax,0
        stc
        ret
s_m_v_ok:
        cmp     mainvol,bl
        je      s_m_v_end
        mov     mainvol,bl
        mov     si,0
        mov     cx,9
s_m_v_1:
        cmp     channel_active[si],0
        je      s_m_v_2

        mov     di,si
        add     di,offset channel_vol2

        mov     bx,40h
        add     bl,register_map[si]

        mov     al,cs:[di]
        call    calcvol
        mov     ah,al
        mov     al,register_bypass[bx]
        and     al,11000000b
        or      ah,al
        call    Fastwrite

        add     bl,3
        add     di,9

        mov     al,cs:[di]
        call    calcvol
        mov     ah,al
        mov     al,register_bypass[bx]
        and     al,11000000b
        or      ah,al
        call    Fastwrite

s_m_v_2:
        inc     si
        loop    s_m_v_1
s_m_v_end:
        ret
Set_Main_Volume endp

shift_helper proc
        mov     bx,bp
        cmp     ax,0
        jl      @@down
        call    calc_freq_up
        jmp     @@doit
@@down:
        neg     ax
        call    calc_freq_down
@@doit:
        add     bx,0a0h
        mov     ah,cl
        call    Fastwrite
        add     bx,10h
        mov     al,register_bypass[bx]
        and     al,32
        mov     ah,ch
        and     ah,11011111b
        or      ah,al
        call    Fastwrite

        mov     bx,bp
        shl     bx,1
        mov     channel_freq[bx],cx
        ret
shift_helper endp

effect_arpeggio proc
        mov     cl,cs:channel_note2[bp]
        mov     bl,byte ptr count
        xor     bh,bh
        mov     bl,byte ptr arpeggio_table[bx]
        cmp     bl,0
        je      @@arp_found
        cmp     bl,1
        jne     @@arp2
        shr     ah,4
        add     cl,ah
        jmp     @@arp_found
@@arp2:
        and     ah,15
        add     cl,ah
@@arp_found:
        cmp     cl,96
        jbe     @@note_ok
        mov     cl,96
@@note_ok:
        xor     ch,ch
        mov     bx,cx
        shl     bx,1
        mov     cx,word ptr notetab[bx]
        mov     bx,bp
        call    set_freq
        ret
effect_arpeggio endp

effect_slide_up proc
        mov     bx,bp
        shl     bx,1
        mov     al,ah
        xor     ah,ah
        add     word ptr channel_fshift[bx],ax
        mov     ax,word ptr channel_fshift[bx]
        mov     bl,byte ptr cs:channel_note2[bp]
        xor     bh,bh
        shl     bx,1
        mov     cx,word ptr notetab[bx]

        call    shift_helper
        ret
effect_slide_up endp

effect_slide_down proc
        mov     bx,bp
        shl     bx,1
        mov     al,ah
        xor     ah,ah
        sub     word ptr channel_fshift[bx],ax
        mov     ax,word ptr channel_fshift[bx]
        mov     bl,byte ptr cs:channel_note2[bp]
        xor     bh,bh
        shl     bx,1
        mov     cx,word ptr notetab[bx]

        call    shift_helper
        ret
effect_slide_down endp

effect_portamento proc
        cmp     count,0
        ja      @@not_first
        mov     bx,bp
        shl     bx,1
        cmp     ah,0
        je      @@no_new_speed
        mov     al,ah
        xor     ah,ah
        mov     word ptr channel_pspeed[bx],ax
@@no_new_speed:
        mov     bl,byte ptr cs:channel_note[bp]
        cmp     bl,0
        je      @@not_first
        xor     bh,bh
        shl     bx,1
        mov     dx,word ptr notetab[bx]
        mov     bx,bp
        shl     bx,1
        mov     word ptr channel_pdest[bx],dx
@@not_first:
        jmp     execute_portamento
effect_portamento endp

execute_portamento proc
        mov     bx,bp
        add     bx,0a0h
        mov     al,byte ptr register_bypass[bx]
        add     bx,10h
        mov     ah,byte ptr register_bypass[bx]

        mov     bx,bp
        shl     bx,1
        mov     dx,word ptr channel_pdest[bx]
        mov     cx,word ptr channel_pspeed[bx]
        cmp     ax,dx
        jumps
        je      @@kill_porta
        ja      @@pdown
@@up:
        nojumps
        mov     bx,bp
        mov     ax,cx
        push    dx
        add     bx,0b0h
        mov     ch,byte ptr register_bypass[bx]
        sub     bx,10h
        mov     cl,byte ptr register_bypass[bx]
        call    calc_freq_up
        pop     dx
        mov     bx,cx
        mov     ax,dx
        and     bx,0011100000000000b
        and     ax,0011100000000000b
        cmp     bx,ax
        jb      @@puok
        mov     bx,cx
        mov     ax,dx
        and     bx,0000011111111111b
        and     ax,0000011111111111b
        cmp     bx,ax
        jb      @@puok
        mov     cx,dx
@@puok:
        mov     bx,bp
        call    set_freq
        ret
@@pdown:
        mov     bx,bp
        mov     ax,cx
        push    dx
        add     bx,0b0h
        mov     ch,byte ptr register_bypass[bx]
        sub     bx,10h
        mov     cl,byte ptr register_bypass[bx]
        call    calc_freq_down
        pop     dx
        mov     bx,cx
        mov     ax,dx
        and     bx,0011100000000000b
        and     ax,0011100000000000b
        cmp     bx,ax
        ja      @@pdok
        mov     bx,cx
        mov     ax,dx
        and     bx,0000011111111111b
        and     ax,0000011111111111b
        cmp     bx,ax
        ja      @@pdok
        mov     cx,dx
@@pdok:
        mov     bx,bp
        call    set_freq
@@kill_porta:
        ret
execute_portamento endp

effect_vibrato proc
        cmp     count,0
        ja      @@not_first
        cmp     ah,0
        je      @@not_first
        mov     al,ah
        and     al,15
        shr     ah,4
        mov     cs:channel_vspeed[bp],ah
        mov     cs:channel_vdepth[bp],al
        mov     dl,ah
        jmp     do_vibrato
@@not_first:
        jmp     execute_vibrato
effect_vibrato endp

execute_vibrato proc
        mov     dl,cs:channel_vspeed[bp]
        mov     al,cs:channel_vdepth[bp]
do_vibrato:
        mov     bl,cs:channel_vpos[bp]
        xor     bh,bh
        add     bl,dl
        mov     cs:channel_vpos[bp],bl
        mov     dh,bl
        and     bx,1fh
        mov     dl,byte ptr vibratotab[bx]
        mul     dl
        rol     ax,1
        xchg    ah,al
        and     ah,1
        test    dh,32
        jne     @@vibup
        jmp     @@vibdown
@@vibup:
        mov     bx,bp
        call    frequenz_up2
        ret
@@vibdown:
        mov     bx,bp
        call    frequenz_down2
        ret
execute_vibrato endp

effect_volume_slide proc
        cmp     count,0
        jne     @@just_vslide
        mov     dl,ah
        cmp     dl,16
        jb      @@dlok
        shr     dl,4
        neg     dl
@@dlok:
        mov     bx,bp
        shl     bx,1
        mov     byte ptr channel_eff[bx+1],dl
        mov     ah,dl
        mov     byte ptr cs:channel_vsubt[bp],0
@@just_vslide:
        mov     dl,ah
        mov     dh,byte ptr cs:channel_vsubt[bp]
        add     dh,dl
        mov     ch,dh
        sar     ch,2
        mov     ah,byte ptr cs:channel_vol2[bp]
        mov     al,byte ptr cs:channel_vol[bp]
        add     ah,ch
        add     al,ch
        cmp     al,0
        jge     @@alok
        xor     al,al
@@alok:
        cmp     ah,0
        jge     @@ahok
        xor     ah,ah
@@ahok:
        cmp     ah,63
        jb      @@ahok2
        mov     ah,63
@@ahok2:
        cmp     al,63
        jb      @@alok2
        mov     al,63
@@alok2:
        sal     ch,2
        sub     dh,ch
        mov     byte ptr cs:channel_vsubt[bp],dh
        mov     bx,bp
        call    set_volume
        ret
effect_volume_slide endp

effect_portamento_volume_slide proc
        call    effect_volume_slide
        call    execute_portamento
        ret
effect_portamento_volume_slide endp

effect_vibrato_volume_slide proc
        call    effect_volume_slide
        call    execute_vibrato
        ret
effect_vibrato_volume_slide endp

effect_release_note proc
        mov     bx,bp
        call    release_note
        mov     bx,bp
        shl     bx,1
        mov     word ptr channel_eff[bx],0
        ret
effect_release_note endp

effect_position_jump proc
        mov     bx,segnum
        mov     position_jump[bx],1
        mov     al,ah
        xor     ah,ah
        mov     cs:new_position[bx],al
        mov     cs:break_pos[bx],0
        mov     cs:pattern_break[bx],1
        mov     bx,bp
        shl     bx,1
        mov     word ptr channel_eff[bx],0
        ret
effect_position_jump endp

effect_set_volume proc
        cmp     ah,63
        jb      @@ahok
        mov     ah,63
@@ahok:
        mov     al,63
        sub     al,ah
        mov     ah,al
        mov     bx,bp
        call    set_volume
        ret
effect_set_volume endp

effect_pattern_break proc
        mov     bx,segnum
        mov     cs:pattern_break[bx],1
        mov     bx,ax
        mov     al,ah
        shr     al,4
        mov     cl,10
        mul     cl
        and     bh,0fh
        add     al,bh
        xor     ah,ah
        mov     cs:break_pos[bx],al
        mov     bx,bp
        shl     bx,1
        mov     word ptr channel_eff[bx],0
        ret
effect_pattern_break endp

effect_set_speed proc
        mov     bx,segnum
        cmp     ah,0
        ja      @@ahok
        mov     ah,1
@@ahok:
        cmp     ah,31
        ja      @@high_speed
        mov     current_speed[bx],ah
        jmp     @@aout
@@high_speed:
        cmp     polling,1
        je      @@aout
        mov     bl,ah
        xor     bh,bh
        cmp     bx,50
        ja      @@bxok
        mov     bx,50
@@bxok:
;        mov     current_bpm,bx
;        add     bx,3

        cli
        mov     dx,2dh
        mov     ax,8426h
        div     bx
        push    ax
        mov     al,54
        out     43h,al

        pop     ax
        out     40h,al
        xchg    ah,al
        out     40h,al
        sti
@@aout:
        mov     bx,bp
        shl     bx,1
        mov     word ptr channel_eff[bx],0
        ret
effect_set_speed endp

spec_arpeggio proc
        pusha
        cmp     byte ptr cs:channel_acurpos[bp],0
        jumps
        je      @@no_arp
        dec     byte ptr cs:channel_acursp[bp]
        jg      @@no_arp
        nojumps

        mov     al,byte ptr cs:channel_acurpos[bp]
        xor     ah,ah
        mov     di,ax
        mov     al,byte ptr ds:[_acommands+di]
        cmp     al,254
        jb      @@no_verw
        cmp     al,255
        jne     @@no_end
        mov     byte ptr cs:channel_acurpos[bp],0
        jmp     @@no_arp
@@no_end:
        mov     al,byte ptr ds:[_arpeggio+di]
        mov     di,ax
        mov     byte ptr cs:channel_acurpos[bp],al
        mov     al,byte ptr ds:[_acommands+di]
@@no_verw:

        cmp     al,0
        je      @@no_command
        cmp     al,44
        ja      @@no_wave
        xor     ah,ah
        mov     bl,10
        div     bl
        xchg    al,ah
        mov     cx,ax
        mov     bx,bp
        call    select_wave
        jmp     @@no_command
@@no_wave:
        cmp     al,253
        jne     @@no_release
        mov     bx,bp
        call    release_note
@@no_release:
        cmp     al,252
        jne     @@no_setvol
        mov     ah,byte ptr ds:[_arpeggio+di]
        call    effect_set_volume
@@no_setvol:
        cmp     al,251
        jne     @@no_retrig_vol
        mov     ah,byte ptr ds:[_arpeggio+di]
        call    effect_set_volume
        mov     bx,bp
        call    retrig_note
        jmp     @@no_half
@@no_retrig_vol:

@@no_command:
        mov     al,byte ptr ds:[_arpeggio+di]
        cmp     al,100
        ja      @@abs_note_found
        mov     ah,byte ptr cs:channel_note[bp]
        add     al,ah
        jmp     @@note_check
@@abs_note_found:
        sub     al,99
@@note_check:
        cmp     al,96
        jbe     @@note_found
        mov     al,96
@@note_found:
        xor     ah,ah
        mov     byte ptr cs:channel_note2[bp],al
        mov     bx,ax
        shl     bx,1
        mov     cx,word ptr notetab[bx]

        mov     bx,bp
        shl     bx,1
        mov     ax,word ptr channel_fshift[bx]

        call    shift_helper

@@no_half:
        mov     al,byte ptr cs:channel_aspeed[bp]
        mov     byte ptr cs:channel_acursp[bp],al
        inc     byte ptr cs:channel_acurpos[bp]

@@no_arp:
        popa
        ret
spec_arpeggio endp

do_volume proc
        pusha
        mov     bl,al
        dec     bl
        xor     bh,bh
        shl     bx,1
        mov     si,word ptr InsTab[bx]
        add     si,9
        mov     al,[si]
        mov     ah,al
        mov     al,[si+1]
        and     ax,3F3FH
        mov     bx,bp
        call    set_volume
dov2:
        popa
        ret
do_volume endp

calc_work_pattern proc
        xor     ah,ah
        mov     bp,ax
        add     bp,_patternorder
        mov     al,ds:[bp]
        mov     dx,ax
        shl     dx,3
        add     ax,dx
        add     ax,_trackorder
        mov     work_pattern[bx],ax
        ret
calc_work_pattern endp

effect_calls    dw offset effect_arpeggio                       ; 0
                dw offset effect_slide_up                       ; 1
                dw offset effect_slide_down                     ; 2
                dw offset effect_portamento                     ; 3
                dw offset effect_vibrato                        ; 4
                dw offset effect_portamento_volume_slide        ; 5
                dw offset effect_vibrato_volume_slide           ; 6
                dw offset empty                                 ; 7
                dw offset effect_release_note                   ; 8
                dw offset empty                                 ; 9
                dw offset effect_volume_slide                   ; A
                dw offset effect_position_jump                  ; B
                dw offset effect_set_volume                     ; C
                dw offset effect_pattern_break                  ; D
                dw offset empty                                 ; E
                dw offset effect_set_speed                      ; F
                

_eff  db 0
_para db 0

play_line proc

        mov     cx,9
        mov     bp,0
@@l1:
        push    cx

        cmp     byte ptr cs:channel_active[bp],1
        je      @@play
        jmp     @@no_effect

@@play:
        mov     bl,cs:channel_segment[bp]
        xor     bh,bh
        mov     segnum,bx
        mov     al,s_count[bx]
        mov     count,al
        shl     bx,1
        mov     dx,cs:segments[bx]
        mov     ds,dx
        shr     bx,1
        cmp     al,0
        jumps
        jne     @@effects
        nojumps
        xor     ah,ah
        mov     al,current_line[bx]
        mov     si,ax
        shl     si,1
        add     si,ax
        shl     bx,1
        mov     bx,work_pattern[bx]
        add     bx,bp
        mov     al,[bx]
        cmp     al,0
        jumps
        je      @@no_effect
        nojumps
        dec     ax
        mov     bx,192
        mul     bx
        add     si,ax
        add     si,_trackdata

        cmp     count,0
        jbe     @@do_note
        jmp     @@effects
@@do_note:
        lodsb
        mov     cl,al
        lodsb
        mov     ah,al
        lodsb

        mov     _para,al
        mov     ch,ah
        and     ch,15
        mov     _eff,ch
        and     ah,0f0h
        shr     cl,1
        rcr     ah,4
        mov     al,ah

        mov     ch,al
        jcxz    @@nothing_there
        cmp     al,0
        je      @@no_ins
        mov     byte ptr cs:channel_ins[bp],al
        call    do_volume
@@no_ins:
        cmp     cl,0
        je      @@nothing_there
        mov     byte ptr cs:channel_note[bp],cl
        mov     byte ptr cs:channel_note2[bp],cl
        cmp     _eff,3
        je      @@nothing_there
        mov     ch,byte ptr cs:channel_ins[bp]
        call    init_instrument2
        mov     bx,bp
        mov     byte ptr cs:channel_vpos[bp],0
        call    play_note2

@@nothing_there:
        mov     al,_eff
        mov     ah,_para
        mov     bx,bp
        shl     bx,1
        mov     word ptr channel_eff[bx],ax
@@effects:

        call    spec_arpeggio

        mov     bx,bp
        shl     bx,1
        mov     ax,word ptr channel_eff[bx]
        mov     bx,ax
        cmp     bx,0
        je      @@no_effect
        xor     bh,bh
        shl     bx,1
        mov     bx,effect_calls[bx]
        call    bx

@@no_effect:
        inc     bp
        pop     cx
        jumps
        loop    @@l1
        nojumps

        mov     cx,9
        xor     bx,bx
        xor     si,si
@@l2:
        mov     ax,segments[bx]
        cmp     ax,0
        je      @@fuck_off
        cmp     stopped[si],1
        je      @@fuck_off
        mov     ds,ax
        inc     s_count[si]
        mov     al,current_speed[si]
        cmp     s_count[si],al
        jl      @@no_advance
        mov     s_count[si],0
        inc     current_line[si]
        cmp     current_line[si],64
        je      @@advance
        cmp     pattern_break[si],1
        je      @@advance
        jmp     @@no_advance
@@advance:
        inc     current_pos[si]
        mov     al,current_pos[si]
        cmp     al,ds:[_songlength]
        jb      @@norestart
        mov     al,ds:[_restart]
@@norestart:
        cmp     position_jump[si],0
        je      @@noposjump
        mov     al,new_position[si]
@@noposjump:
        mov     current_pos[si],al

        call    calc_work_pattern
        mov     al,break_pos[si]
        mov     current_line[si],al
        mov     break_pos[si],0
        mov     pattern_break[si],0
        mov     position_jump[si],0
@@no_advance:
@@fuck_off:
        inc     si
        add     bx,2
        jumps
        loop    @@l2
        nojumps

        clc

        ret
play_line endp

test_device proc
        call    testadlib
        ret
test_device endp

oldone_got db 0

init_device proc
        call    init_adlib
        call    init_adlib_tables
        cmp     oldone_got,0
        jne     @@got
        call    getold
@@got:
        mov     oldone_got,1
        clc
        ret
init_device endp

stop_all proc
        cli
        call    clear_all_voices
        call    init_adlib
        call    init_adlib_tables
        sti
        cmp     oldone_got,0
        je      @@not
        call    setold
@@not:
        call    reset_clock_ticks
        clc
        ret
stop_all endp

load_song proc
;
; bl = num (0..8)
; dx = segment
;
        xor     bh,bh
        cmp     bx,8
        ja      @@err
        mov     si,bx
        shl     si,1
        cmp     segments[si],0
        jne     @@err
        mov     ds,dx
        mov     ax,ds:[_channels]
        xor     si,si
        mov     cx,9
@@l1:
        shl     ax,1
        jnc     @@nop
        cmp     channel_active[si],0
        jne     @@err
@@nop:
        inc     si
        loop    @@l1
        mov     ax,ds:[_channels]
        xor     si,si
        mov     cx,9
@@l2:
        shl     ax,1
        jnc     @@nop2
        mov     channel_active[si],0
        mov     channel_segment[si],bl
@@nop2:
        inc     si
        loop    @@l2
        mov     stopped[bx],1
        shl     bx,1
        mov     segments[bx],dx
        mov     ax,ds:[_BPM]
        mov     current_bpm,ax
@@noerr:
        clc
        ret
@@err:
        stc
        ret
load_song endp

unload_song proc
;
; bl = num (0..8)
;
        xor     bh,bh
        cmp     bx,8
        ja      merr
        mov     si,bx
        shl     si,1
        cmp     segments[si],0
        je      merr
        mov     dx,segments[si]
        mov     segments[si],0
        mov     ds,dx
        mov     ax,ds:[_channels]
        xor     si,si
        mov     cx,9
@@l1:
        shl     ax,1
        jnc     @@nop
        cmp     channel_active[si],0
        je      merr
        cmp     channel_segment[si],bl
        jne     merr
@@nop:
        inc     si
        loop    @@l1
        mov     ax,ds:[_channels]
        xor     si,si
        mov     cx,9
@@l2:
        shl     ax,1
        jnc     @@nop2
        mov     channel_active[si],0
        mov     channel_segment[si],0
        pusha
        mov     bx,si
        call    mute_voice
        popa
@@nop2:
        inc     si
        loop    @@l2
        mov     stopped[bx],1
        shl     bx,1
        mov     segments[bx],0
noerr:
        clc
        ret
merr:
        stc
        ret
unload_song endp

start_song proc
;
; bl = num
;
        xor     bh,bh
        cmp     bl,8
        ja      merr
        shl     bx,1
        mov     ax,segments[bx]
        cmp     ax,0
        je      merr
        mov     ds,ax
        mov     al,0
        push    bx
        call    calc_work_pattern
        pop     bx
        shr     bx,1
        mov     current_line[bx],0
        mov     current_speed[bx],6
        mov     pattern_break[bx],0
        mov     current_pos[bx],0
        mov     s_count[bx],0
        mov     position_jump[bx],0
        mov     stopped[bx],0
        mov     ax,ds:[_channels]
        xor     si,si
        mov     cx,9
@@l2:
        shl     ax,1
        jnc     @@nop2
        mov     channel_active[si],1
@@nop2:
        inc     si
        loop    @@l2
        clc
        ret
start_song endp

play_independent proc
        mov     polling,0
        mov     ax,current_bpm
        mov     ah,al
        cli
        mov     bp,0
        call    effect_set_speed
        call    setnew
        sti
        ret
play_independent endp

service_calls dw offset test_device             ; 0
              dw offset init_device             ; 1
              dw offset load_song               ; 2
              dw offset unload_song             ; 3
              dw offset start_song              ; 4
              dw offset play_line               ; 5
              dw offset play_independent        ; 6
              dw offset set_main_volume         ; 7
              dw offset empty                   ; 8
              dw offset empty                   ; 9
              dw offset stop_all                ; 10

adlib proc
        push    ds
        cmp     al,10
        jg      @@finish
        xor     ah,ah
        mov     si,ax
        shl     si,1
        mov     bp,service_calls[si]
        call    bp
        pop     ds
        ret
@@finish:
        pop     ds
        stc
        ret
adlib endp

;-------------------------------------------------------------------------------

old08_seg  dw ?
old08_offs dw ?

GetOld PROC
        mov     ah,35h
        mov     al,8
        int     21h
        mov     ax,es
        mov     old08_seg,ax
        mov     old08_offs,bx
        ret
GetOld ENDP

SetOld PROC
        mov     ax,old08_seg
        mov     ds,ax
        mov     dx,old08_offs
        mov     ah,25h
        mov     al,8
        int     21h
        ret
SetOld  ENDP

SetNew PROC
        push    cs
        push    cs
        pop     ds
        lea     dx,new08
        mov     ah,25h
        mov     al,8
        int     21h
        pop     ds
        ret
SetNew ENDP

New08 PROC
        pusha
        push    ds
        push    es

        call    play_line

        mov     al,20h
        out     20h,al

        pop     es
        pop     ds
        popa
        iret
New08 ENDP

Reset_Clock_Ticks PROC
        cli
        mov     al,54
        out     43h,al
        mov     al,0
        out     40h,al
        out     40h,al
        sti
        ret
Reset_Clock_Ticks ENDP


;-------------------------------------------------------------------------------

usage db 'Usage: qdplay <filename>',13,10,'$'

bad_use:
        push    cs
        pop     ds
        mov     ah,9
        lea     dx,usage
        int     21h
        mov     ah,4ch
        int     21h

get_file proc pascal f:word
        pusha
        push ds
        push es
        mov  ax,0b800h
        mov  es,ax
        mov ax,f
        mov es:[0],ah
        mov es:[2],al

        mov fsong,ax
        mov dsong,ax
        pop es
        pop ds
        popa
        ret
get_file endp

vol db 64


start:

        pusha
        push ds
        push es
        push    ax
        mov     ax,dsong
        mov     fsong,ax
        pop     ax
;        call    setfree                 ; init memory..

;        call    get_file

        push    cs
        pop     ds
        push    ax
        mov     ax,dsong
        mov     fsong,ax
        pop     ax
        lea     dx,fname
        lea     di,fsong
;        call    loadseg
        push    ax
        mov     ax,dsong
        mov     fsong,ax
        pop     ax
        mov     al,1
        call    adlib                   ; init

        mov     bl,0
        push    fsong
        pop     dx
        mov     al,2
        call    adlib                   ; loadsong

        mov     al,4
        mov     bl,0
        call    adlib                   ; startsong

        mov     al,6
        call    adlib                   ; play using timer interrupt...
        pop es
        pop ds
        popa
        ret
again:
        sti

        mov     ah,11
        int     21h
        cmp     al,0
        je      again
        mov     ah,8
        int     21h
        cmp     al,'+'
        jne     @@no_p
        cmp     vol,64
        jge     again
        inc     vol
        mov     bl,vol
        mov     al,7
        call    adlib
        jmp     again
@@no_p:
        cmp     al,'-'
        jne     @@no_m
        cmp     vol,0
        jle     again
        dec     vol
        mov     bl,vol
        call    set_main_volume                 ; change main volume
        jmp     again
@@no_m:
end_of_all:
        pusha
        push ds
        push es

        mov     al,10
        call    adlib                           ; end of all
        pop es
        pop ds
        popa
        ret
end start

;    ‹ﬂﬂﬂﬂﬂﬂﬂﬂ≤ﬂﬂﬂﬂﬂﬂﬂﬂ≤   ≤ﬂﬂﬂﬂﬂﬂﬂﬂﬂ≤‹‹
;   ≤ ‹€≤ﬂﬂﬂﬂ   ‹€€€€‹ ﬂﬂ€ € ±≤€ ±≤€   €
;   €  ﬂﬂﬂﬂ€‹  ﬁ€€  €€›  ≤ € ≤€€ ≤€€ﬂﬂ €‹‹
;   €  ‹‹› €€› €€≤  €€€  ≤ € ≤€€ ≤€€ ﬁ‹‹ ˛≤
;   € €€≤  €€€ €€≤  €€€  ≤‹≤ €€€ €€€  €€€ €
;   € €€≤  €€€ €€€‹‹€€€  ‹‹‹‹€€€ €€€  €€€ €
;   € €€€  €€≤ €€€  €€≤ ﬁ€€  €€≤ €€€  €€≤ €
;   € €€€  €€≤ €€€  €€≤ €€€  €€≤ €€€  €€≤ €
;   ﬁ›ﬁ€€± €€≤ €€€± €€≤ €€€± €€≤ ﬁ€€± €€≤ €
;    € ﬂ€≤‹€≤± €€€≤ €≤± ﬂ€€≤‹€≤±  ﬂ€≤‹€≤± €
;    ≤˛‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹≤‹‹‹‹‹‹‹‹≤ v2.00 - Quick'n'Dirty Play
