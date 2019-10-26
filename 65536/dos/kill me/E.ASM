public _a_dorow
public _a_init

    .model small
    .stack 200
    .386
locals
.data
;=== data structures
a_musiccnt dw   1
a_chdelaycnt db 9 dup(0)
a_chdelay db    9 dup(0)
a_inst_table label byte
        db 20h+0,20h+1,20h+2,20h+8,20h+9,20h+10,20h+16,20h+17,20h+18
ntb equ 8192 ;+1024*1
a_note_table label word
        dw ntb+323,ntb+385,ntb+408,ntb+432,ntb+458,ntb+485
        dw ntb+514,ntb+544,ntb+577,ntb+611,ntb+647,ntb+868
;################## music - (tune by skaven/fc) ###################
;generated with st3->simplexadlib, handoptimized by psi (283 bytes)
music_channels equ 8
music_speed equ 7
music_instruments label byte
dw offset ains6
dw offset ains2
dw offset ains4
dw offset ains3
dw offset ains3
dw offset ains1
dw offset ains1
dw offset ains4
ains1 label byte
db 65,194,6,0,35,242,240,240,1,0,4
ains2 label byte
db 145,64,135,128,243,111,35,3,1,1,2
ains3 label byte
db 225,33,17,128,17,19,34,34,0,0,12
ains4 label byte
db 97,33,27,0,98,132,86,85,0,0,14
ains6 label byte
db 145,64,135,136,243,111,35,3,1,1,2
music_patterns label byte
ach0 dw offset ach0d,offset ach0dr
ach1 dw offset ach1d,offset ach1dr
ach2 dw offset ach2d,offset ach2dr
ach3 dw offset ach3d,offset ach3d
ach4 dw offset ach4d,offset ach4d
ach5 dw offset ach5d,offset ach5d
ach6 dw offset ach6d,offset ach6d
ach7 dw offset ach7d,offset ach7d
ach0d label byte
db 081h
ach0dr label byte
db 057h,050h,050h,055h,057h,050h,055h,057h
db 050h,055h,057h,050h,055h,057h,050h,055h
db 0
ach1d label byte
db 081h
ach1dr label byte
db 050h,055h,057h,050h,055h,057h,050h,055h
db 057h,050h,055h,057h,050h,055h,057h,050h
db 0
ach2d label byte
db 0c0h,050h,084h
db 030h,020h,030h,020h,02ah,01ah,02ah,01ah
db 030h,020h,030h,020h,02ah,01ah,02ah,01ah
ach2dr label byte
db 030h,020h,030h,020h,02ah,01ah,02ah,01ah
db 025h,015h,025h,015h,028h,018h,02ah,01ah
db 0
ach3d label byte
db 0a0h,050h,040h,0c0h,040h,088h,040h,040h
db 03ah,042h,090h,045h,088h,040h,042h,040h
db 047h,090h,04ah,088h,045h,098h,040h
db 0
ach4d label byte
db 0a0h,050h,030h,0c0h,047h,088h,047h,043h
db 042h,045h,047h,045h,048h,047h,047h,050h
db 052h,084h,050h,04ah,088h,050h,098h,045h
db 0
ach5d label byte
db 0c0h,020h,0a0h,010h,010h,090h,010h,02ah
db 025h,088h,028h,02ah,090h,010h,02ah,025h
db 088h,028h,02ah
db 0
ach6d label byte
db 0c0h,020h,0a0h,020h,020h,090h,020h,01ah
db 015h,088h,018h,01ah,090h,020h,01ah,015h
db 088h,018h,01ah
db 0
ach7d label byte
db 0c0h,00ch,0feh,050h,090h,00ch,081h,04ah
db 050h,084h,052h,055h,086h,04ah,081h,050h
db 04ah,086h,050h,082h,055h,098h,045h
db 0
;#########################################################
    .code
;=== code includes
;=== subroutines
a_lodsboutaw03: ;size optimization related entry (instrument loading)
        call    a_lodsboutaw
        add     ah,3
a_lodsboutaw: ;size optimization related entry (instrument loading)
        lodsb

a_outaw proc near ;ah=reg,al=data
        push    ax
        push    cx
        xchg    al,ah
        mov     dx,388h
        out     dx,al
        mov     cx,7
        call    a_wait
        mov     dx,389h
        mov     al,ah
        out     dx,al

        mov     cx,30
        call    a_wait
        pop     cx
        pop     ax
skipit: ret

a_wait: in      al,dx
        loop    a_wait
        ret
a_outaw endp

a_loadinstrument proc near
        mov     ah,ds:a_inst_table[bx]
        mov     cx,4
l@@1:    call    a_lodsboutaw03
        add     ah,20h-3
        loop    l@@1
        add     ah,40h
        call    a_lodsboutaw03
        mov     ah,bl
        add     ah,0c0h
        jmp     a_lodsboutaw
a_loadinstrument endp

a_playnote proc near
        push    bx
        xchg    ah,bl
        add     ah,0a0h
        call    a_outaw
        mov     al,bl
        add     ah,010h
        pop     bx
        jmp     a_outaw
a_playnote endp

_a_init proc near
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	si
	push	di
	push	bp
        
        mov     ax,00120h
        call    a_outaw
        mov     ax,00800h
        call    a_outaw
        mov     ah,0bdh
        call    a_outaw
        mov     bp,9
        xor     bx,bx
        mov     di,offset music_instruments
l@@11:    mov     si,ds:[di]
        add     di,2
        call    a_loadinstrument
        xor     ax,ax
        call    a_playnote
        inc     bx
        dec     bp
        jnz     l@@11
	pop	bp
	pop	di
	pop	si
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
        
        retf
_a_init endp

_a_dorow proc near
	push	ax
	push	bx
	push	cx
	push	dx
	push	es
	push	ds
	push	si
	push	di
	push	bp

        sub     ds:a_musiccnt,1
        jnc     xl@@0
        mov     ds:a_musiccnt,music_speed
        mov     cx,music_channels
        mov     di,offset music_patterns
        xor     bx,bx
kl@@1:    sub     ds:a_chdelaycnt[bx],1
        jns     l@@2
        mov     si,ds:[di]
        xor     ax,ax
        call    a_playnote
l@@4:    lodsb
        or      al,al
        jz      l@@7
        jns     l@@6
        sub     al,81h
        mov     ds:a_chdelay[bx],al
        lodsb
l@@6:    mov     dl,al
        and     ax,15
        mov     bp,ax
        add     bp,bp
        mov     ax,ds:a_note_table[bp]
        shr     dl,2
        and     dl,not 3
        add     ah,dl
        call    a_playnote
        mov     al,ds:a_chdelay[bx]
        mov     ds:a_chdelaycnt[bx],al
        mov     ds:[di],si
l@@2:    add     di,4
        inc     bx
        loop    kl@@1
xl@@0:  pop     bp
	pop	di
	pop	si
	pop	ds
	pop	es
	pop	dx
	pop	cx
	pop	bx
	pop	ax
        retf
l@@7:   mov     si,ds:[di+2]
        jmp     l@@4
_a_dorow endp

end

