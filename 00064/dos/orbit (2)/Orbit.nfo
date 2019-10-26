; Orbit by Baudsurfer/rsi 2014 aka olivier.poudade.free.fr
; A 64 bytes textured volume ray marching animation on x86.
; Greets to all assembly language lovers. Tested on xp sp3.
; Youtube video :    
    org 100h         ; assume ah=bx=0 cx=255 sp=di=-2 si=100h
vga:mov al,93h       ; switch mode 13h no cls cs:si=b093h 
    int 10h          ; bios vga video api
    les bp,[bx]      ; es=9fffh bp=20cdh=8397d
    mov bp,140h      ; bp=horizontal scanline width
mip:mov cl,0ffh      ; cl=visibility fostrum
ray:mov bl,cl        ; bl=distance
    not bl           ; bl=z
    mov ax,di        ; spot coord=di
    sub ax,10h       ; vga segment les paragraph fixup  
    cdq              ; xor dx,dx (cbw/cwd unusable)
    div bp           ; ax=y dx=x
    call cam         ; ah=(y-y0)*z
    xchg ax,dx       ; ah=dh=x dh=(y-y0)*z 
    call cam         ; ah=(x-x0)*z
    add bl,[fs:46ch] ; z+=rtc 18.2Hz bda lobyte
    mov al,ah        ; calc texel #1 t=x>>8 ah=x
vol:xor ah,dh        ; calc volume #1 dh=y
    and ah,bl        ; calc volume #2 bl=z
    and ah,[si]      ; calc volume #3 intersect (x,y,z) /w [si]=10110000b
    loopz ray        ; repeat until hit or d>255
tex:sub al,dh        ; calc texel #2 t=(x>>8)-y
    mul bl           ; calc texel #3 t=z*((x>>8)-y)
    and al,8h        ; calc texel #4 t=(z*((x>>8)-y))>>3 white palette idx
pix:stosb            ; write pixel t to screen di++
esc:jmp mip          ; automatic vga segment di wrap-up
cam:sub ax,64h       ; translate to arbitrary origin (100,100) 
    imul ax,bx       ; project ah=(x-x0)*z dh=(y-y0)*z
    add ax,[si]      ; translate back to cam position [si]=37808d
    ret              ; return to shell or fx caller  