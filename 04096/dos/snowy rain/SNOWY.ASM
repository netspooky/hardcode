;" Da Elite snowy rain"
; Again another 2 day project
; We are busy coding our demo, but I still had time for this production.
; by L™K™ of Napalm Software

; This 4K intro contains nothing really smashing or cool, but maybe someone
; finds this code useful. If so, we would really be happy if he could give
; us some greetings/credits. The zooming tricky is really neat hack.
; Program does not allocate any memory from DOS, but still uses 60000 bytes
; for the zoom!

; As you propably know, there are many many places where you could easily
; squeeze some bytes off. But WHO CARES ABOUT TEN BYTES IN THESE DAYS OF
; GIGA WAREZ ?! Anyway there is some optimisation in this code.

; Greetingz & other stuff:
;  -Juffo-WUP/Stealers?    Howya doing?
;  -Billy-boy/microsoft    WINDOWS SUCKS!
;  -MPS Labs               Smooth palette fading impossible for ya?
;  -Future Crew            Doing fine stuff
;  -Iguana                 Fine heartquake, !no design?
;  -Nordic Vision          .-.
;  -the rest

; btw. The intro requires VGA & 286 compatible processor!

cseg            segment
                assume  cs:cseg
                org 100h
                .286

main:
  ;*******Checka for 286 processor*******
  push sp
  pop  dx
  cmp  dx,sp
  jz   @was_it
  lea  dx,no286
  jmp  @displ_string
  @was_it:
  ; *****Check for VGA*******
  mov  ax,01a00h
  int  10h
  cmp  al,01ah
  jne  @dansi
  cmp  bl,7
  jb   @dansi

  ;*******System has 286 and VGA. Let's rock
  call white_pal  ;Do a palette tricky
  mov ax,13h
  int 10h                                                      
  call initsnow
  mov ax,01130h   ;Load 8x8 font pointer
  mov bh,3
  int 10h
  push es
  pop  ds         ;Segments now inited.. DS points to font, ES points vidmem
  push 0a000h
  pop  es

  cld             ;Dangerous? in proper applications this should be done right
                  ;before every MOVSB/MOVSW yms. intruction
  @lopez:
    call vertr

    cmp byte ptr cs:[offset temp_count],speedy
    jle @no_text
    call dotext
    mov byte ptr cs:[offset temp_count],0
    @no_text:
    inc byte ptr cs:[offset temp_count]
    call movesnow
    call drawsnow
    mov ah,1    ;Wait a keypress
    int 16h
    jz  @lopez

  ;Let's zoom the piccy away!
  ;****Init zooming buffer****   
                push    es
                mov     cx,32000-2048
                xor     si,si
                mov     di,offset imagepointer
                push    0a000h
                pop     ds
                push    cs
                pop     es
                rep     movsw
                pop     es

  mov cx,200
  @zloop:
    call vertr
    call teezoomi
    loop @zloop

  ;Do a palette trick
  call white_pal
  mov ax,3h
  int 10h
  @dansi:
  lea dx,endansi
  @displ_string:                         ;Diz can be called from other places too!
  push cs
  pop  ds
  mov ah,9
  int 21h
  ret                         ;This "exit to dos" works only with com files

;RANDOM NUMBER GENERATOR
;IN:
;  CX=random number ranges
;OUT:
;  DX=random number
random          proc    near
                push ax
                push bx
                mov ax,cs:[offset seed]
                mov bx,9821
                imul bx
                inc ax
                ror al,1
                add ax,8191
                rol ah,1
                mov cs:[offset seed],ax
                      
                xor dx,dx
                div cx
                pop bx
                pop ax
                ret
                endp

dotext          proc    near             ;Make (lame) writer happen
                pusha
                mov si,cs:[offset char_counter]
                xor bh,bh
                mov bl,cs:[offset texte+si]   ;Character to displayed to BX
                shl bx,3
                add bp,bx                     ;BP points to character data

                mov di,cs:[offset yplace]
                xor dx,dx
                mov ax,320
                mul di
                mov di,ax
                add di,cs:[offset xplace]     ;DI points to right place in vidmem

                ;Display character
                mov cx,8                      ;Horizontal counter
                @horiz_loop:
                mov bx,8
                @vert_loop:
                mov dl,ds:[bp]
                mov al,1
                shl al,cl
                and dl,al
                jz  @ei_pikseli
                mov al,14
                mov es:[di],al
                @ei_pikseli:
                add di,320                ;Next row
                inc bp
                dec bx
                jnz @vert_loop
                sub di,320*8-1
                sub bp,8
                loop @horiz_loop

                ;Update message counters
                inc word ptr cs:[offset char_counter]
                add word ptr cs:[offset xplace],9
                mov si,cs:[offset char_counter]
                cmp byte ptr cs:[offset texte+si],0            ;End of Line?
                jne @fake_alarm
                add word ptr cs:[offset char_Counter],2        ;Skip  "paska" data
                mov al,cs:[offset texte+si+1]
                xor ah,ah
                mov cs:[offset yplace],ax                      ;New coordinates
                mov word ptr cs:[offset xplace],20
                add si,2
                @fake_alarm:
                cmp byte ptr cs:[offset texte+si],1            ;End of Text?
                jne @fake_fake
                mov word ptr cs:[offset char_counter],1
                mov word ptr cs:[offset yplace],20
                @fake_fake:
                popa
                ret
                endp

movesnow        proc    near
                pusha
                xor bx,bx
                xor di,di
                @move_loop1:
                inc word ptr cs:[offset snowy+di+2]
                cmp word ptr cs:[offset snowy+di+2],180
                jle @not_yet                              ;Y coord. out of screen?
                mov word ptr cs:[offset snowy+di+2],0     ;Yes, clear Y
                mov cx,320                                ;Random X
                call random
                mov cs:[offset snowy+di],dx
                mov cx,3                                  ;Random color
                call random
                inc dx
                mov cs:[offset snoww+bx],dl
                @not_yet:

                mov cx,2                                  ;Random X movement
                call random
                cmp dx,1
                jne @ei_oikea
                add word ptr cs:[offset snowy+di],2
                @ei_oikea:
                dec word ptr cs:[offset snowy+di]

                add di,4
                inc bx
                cmp bx,snowcount
                jl  @move_loop1    ;Try JLE instead -)
                popa
                ret
                endp

drawsnow        proc    near
                pusha
                xor di,di
                mov bx,snowcount
                @draw_loop:
                mov si,320
                xor dx,dx
                mov ax,cs:[offset snowy+di+2]
                mul si
                mov si,ax
                add si,cs:[offset snowy+di]
                mov al,cs:[offset snoww+bx]
                add al,20
                mov es:[si],al
                add di,4
                dec bx
                jnz @draw_loop
                popa
                ret
                endp

initsnow        proc    near             ;Initialize snow array with random values
                pusha
                mov bx,snowcount
                xor di,di
                @loopi_joo:
                mov cx,320
                call random
                mov cs:[offset snowy+di],dx
                mov cx,200
                call random
                mov cs:[offset snowy+di+2],dx
                add di,4
                
                mov cx,3    ;Try disabling these four lines :=)
                call random
                inc dx
                mov cs:[offset snoww+bx],dl

                dec bx
                jnz @loopi_joo
                popa
                ret
                endp

;IN:
;  CX=zooming factor
;OUT:
;  none
teezoomi        proc    near             ;Zoom the picture
                pusha

                ;Calculate zooming buffer
                mov bx,180              ;For 180 vertical lines
                @zbcalc:
                mov byte ptr cs:[offset zbuffer+bx],0
                mov ax,bx
                xor dx,dx
                mul cx
                mov si,200
                div si
                cmp bp,ax
                je  @ei_piks
                inc byte ptr cs:[offset zbuffer+bx]
                @ei_piks:
                mov bp,ax
                dec bx
                jnz @zbcalc

                ;Perform actual zooming
                mov di,100
                shr cx,1
                sub di,cx
                mov ax,320
                xor dx,dx
                mul di
                mov di,ax                     ;DI points vidmem

                mov cx,160
                xor ax,ax
                rep stosw

                mov si,offset imagepointer    ;SI points original image
                push cs
                pop ds                        ;DS=CS, DS:SI points orig. image
                mov bx,180
                @zoloop:
                cmp byte ptr cs:[offset zbuffer+bx],1   ;Draw horiz. line?
                jne @ei_viivaa                          ;NOT!
                mov cx,160
                push si
                rep movsw
                pop si
                @ei_viivaa:
                add si,320
                dec bx
                jnz @zoloop

                mov cx,160
                xor ax,ax
                rep stosw
                popa
                ret
                endp

vertr           proc    near
    push ax
    push dx
    mov dx,3dah         ;Wait Vertical Retrace
    @vv1:
    in al,dx
    test al,8
    jnz @vv1
    @vv2:
    in al,dx
    test al,8
    jz @vv2
    pop  dx
    pop  ax
    ret
    endp

white_pal       proc    near
  pusha
  ;Lame palette trick, but who cares?
  mov dx,3c8h
  xor ax,ax
  out dx,al            ;Start from color 0
  mov al,63
  inc dx
  @aga:
  call vertr
    mov cx,768
    @onetime:
    out dx,al
    out dx,al
    out dx,al
    loop @onetime
  dec al
  jnz @aga
  popa
  ret
white_pal       endp

  include endansi.raw                    ;Include ansi screen
  endmarker     db 0dh,0ah,'$'

  no286         db 'NO i286!',0dh,0ah,'$'

  zbuffer       db  200 dup(0)           ;Buffer used for zooming

  ;************ After "rain" effect the following data is overwritten!! **********
  imagepointer label byte

  ;*********** DATA ************
  snowcount     EQU  400                 ; 400 "snowy" pixels
  seed          dw   9821                ; Random number seed
  
  filler        db   3                   ; Make the file size exactly 4096 bytes=4KBs

  texte         label byte
                db   20,'Hia! Napalm Software codes again',0
                db   40,'After releasing Shade Bob intro',0
                db   50,'We are back in notime with this.',0
                db   185,'***** Intro code by L™K™ *****',0
                db   60,'Did someone say we are not fast?!',0
                db   80,'Greetingz JMP to ...',0
                db   90,'hehehe... We greet nobody ...',0
                db   100,'Just coz We rule and U don',39,'t',0
                db   140,'B happy, txt will repeat!',0,0,1

  speedy        EQU  8   ;Text will be advanced only each 8th frame
  temp_count    db   0
  char_counter  dw   1
  xplace        dw   20
  yplace        dw   20

  ;Using "?" instead of 0 is wise. You don't need any "POSTPROC.EXE"!
  snowy         dw   snowcount*2 dup (?) ; Snow pixel coordinates
  snoww         db   snowcount dup (?)   ; Snow pixel colors

cseg            ends                               
                end main
