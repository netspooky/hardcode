;------------------------------------------------------------------------------
;       The LAAL Software Engineers present INDECENT.COM
;
;       an amazing 256 colours, 256 levels, 256 bytes, 0 variables VGA PC Game
;
;       Programmed by :         Daniel Navarro Medrano
;                               Luis Fernando Fernandez
;------------------------------------------------------------------------------
;       Assemble with: TASM /M indecent
;       and then link: TLINK /t indecent
;------------------------------------------------------------------------------

        assume cs:code, ds:code, es:code, ss:code; xs:code, zs:code, js:code
code    segment
        org 100H
        p386
prog    proc

        mov dh,ds:[82h] ;Ask the user what level he wanna play

        mov dl,128 ;Set the mountains high from sea level

        mov bp,104 ;Deep of rubbish zone

        mov al,13h ;Activate mega ultra 256 colours 320x200 SVGA video mode
        int 10h

        mov ax,ds ;Init copy segment register
        inc ah
        mov ds,ax
        mov es,ax

        mov ax,0a000h ;Set vga segment register and clear AL register

        mov ch,255 ;Clear screen copy 
        rep stosb

        mov es,ax ;Init vga segment register

        mov al,00110110b ;Turbo accelerate int 8, your processor dot clock
        out 43h,al
        out 40h,al
        mov al,dl
        out 40h,al

        dec cx ;Draw window (a beautiful Cindy Crawford background)
        rep stosb

        mov di,320*172+84 ;Reset the HUD (Pilot general information)
        mov cl,76
        rep stosw

        pop di ;Initializate di

        mov si,32+256*15 ;Set ship space coordinates
        mov sp,si ;Set stack frame

        inc ch ;What the hell is going on?

p01:    push bx ;Save geographical information

        push ds ;Sincronization (CPU Benchmark)
        xor bx,bx
        mov ds,bx
        mov al,ds:[46ch]
p02:    cmp al,ds:[46ch]
        je p02
        pop ds

        pusha ;Save the begining of the scroll and ship coordinates

        push es ;Dump the first copy to the second
        push ds
        pop es
        mov ch,128
        mov si,di
        add di,cx
        rep movsb
        pop es

        shr di,1 ;Parallax (moves the starfield background)
star:   inc di
        and di,255
        mov al,cs:[di+256]
        shr al,1
        mov bh,al
        and al,7
        add al,20
        cmp byte ptr [si+bx],cl
        jne star2
        mov byte ptr [si+bx],al
star2:  inc bl
        jnz star

        mov di,32+320*24 ;Dumping to the VGA memory ...
        mov bx,128
p03:    inc ch
        rep movsb
        add di,320-256
        dec bx
        jnz p03

        popa ;Restore the previous pushed values

m000:   mov [di+bx],bl ;Clear the new scan line
        add bh,1
        jne m000

        mov bh,dh ;Draw yellow fractal mines, according to the level
        rcr bh,1
        add bh,dl
        mov byte ptr [bx+di],14

        mov bh,dl ;Draw goraud textured 2D mountains
        mov ax,bp
m01:    mov [di+bx],al
        out 61h,al ;Play VOC file (COMMAND.COM) trought the PC Speaker
        inc bh
        dec ax
        jne m01

        cmp dl,32 ;Don't let the sun go down ...
        jb m04
        cmp dl,128
        ja m03

        mov bx,di ;Fractal Floating Point Routine
        xor dh,bl
        xor dh,dl

        ror dh,1 ;Increment or decrement mountain high
        jc m03
m04:    inc dx
        inc dx
m03:    dec dx

        pop bx ;Of course, restore geographical information

        mov [bx],ax ;USS Enterprise mask (the shield in the movie)

        inc di ;Advance the scroll

        mov bx,di ;Test collisions with the first parallax
        add bx,si
        cmp [bx],ax
        je sigue

fin:    xor ax,ax ;Please -= Press ESC to exit =-
        int 16h
        xor ah,ch
        jnz fin

        mov al,3 ;Switch back to text mode
        int 10h

        int 20h ;Back to OS

sigue:  mov word ptr[bx],1f1fh ;Put USS Enterprise compiled bitmap

        test di,1fh ;Increment dificulty trought the level
        jnz m05

        mov es:[bp+320*172-20],ah ;Fill score bar
        inc bp

m05:    mov ah,ch ;Our Own Keyboard Routines OOKR (tm)
        int 16h
        jz p01
        mov ah,cl
        int 16h

        cmp ah,48h ;Cursor UP activate anti-gravity reactors
        jne m06
        sub si,cx

m06:    cmp ah,50h ;Cursor DOWN, activate flaps
        jne m05
        add si,cx

m07:    jmp m05 ;We must do something right above

prog    endp
code    ends
        end     prog
