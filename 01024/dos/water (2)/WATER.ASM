
.model small
.486
.code
org 100h

Include Macros.Inc

START:

    jmp     begin

    sinus:
    Include plwsinus.inc
    vb      dd  0
    fade    db  0
    cnt     dw  0
    key     db  0
    text    db "EMS/Goto10:  Water-1K intro for compo at Icing'98!$"

begin:

    mov     ax,13h                  ; regs.w.ax=0x13;
    int     10h                     ; int386(0x10,&regs,&regs);
    
    Outp    21h,0FFh                ; outp (0x21,255);    

    mov     ax,0A000h
    mov     es,ax
    xor     bx,bx
    mov     di,bx
    mov     ds,bx
    mov     fs,bx
    mov     gs,bx
mainloop:                           ; do
    cmp     key,1
    jne     nopress

    cmp     fade,0
    je      press
    dec     fade

    jmp press
nopress:
    cmp     fade,200
    je      press
    inc     fade
press:

    Outp    03C8h,1                 ; outp(0x3c8,0);
    
    mov     cnt,1                   ; for (ptr=0;ptr<32;ptr++)
palloop1:                           ; {
    
    mov     bl,63                   ; outp(0x3c9,63-ptr);
    sub     bl,byte ptr cnt                  ; outp(0x3c9,63-ptr);

    call    fixcolor

    Outp    03C9h,bl
    Outp    03C9h,bl
    
    mov     bh,byte ptr cnt         ; outp(0x3c9,63-(ptr>>1));
    shr     bh,1
    mov     bl,63
    sub     bl,bh

    call    fixcolor

    Outp    03C9h,bl
    
    inc     byte ptr cnt
    
    cmp     byte ptr cnt,32
    jb      palloop1                ; }
    
    mov     cnt,0                    ; for (ptr=0;ptr<96;ptr++)
palloop2:                           ; {
    
    mov     ax,cnt                  ; outp (0x3c9,32-(ptr/3));
    mov     bl,3
    div     bl
    
    mov     bl,32
    sub     bl,al

    call    fixcolor
    
    Outp    03C9h,bl                ; outp (0x3c9,32-(ptr/3));
    Outp    03C9h,bl
    
    mov     ax,cnt                  ; outp (0x3c9,48-(ptr/6));
    mov     bl,6
    div     bl
    
    mov     bl,48
    sub     bl,al

    call    fixcolor
    
    Outp    03C9h,bl
    
    inc     cnt
    
    cmp     cnt,96
    jb      palloop2                ; }
    
    mov     cnt,0                    ; for (ptr=0;ptr<96;ptr++)
palloop3:                           ; {
    
    mov     ax,cnt                   ; outp (0x3c9,ptr/3);
    mov     bl,3
    div     bl
    
    mov     bl,al
    
    call    fixcolor
    Outp    03C9h,bl                ; outp (0x3c9,ptr/3);
    Outp    03C9h,bl
    
    mov     ax,cnt                   ; outp (0x3c9,32+(ptr/6));
    mov     bl,6
    div     bl
    
    mov     bl,32
    add     bl,al

    call    fixcolor
    Outp    03C9h,bl
    
    inc     cnt
    
    cmp     cnt,96
    jb      palloop3                ; }

    mov     byte ptr cnt,0                    ; for (ptr=0;ptr<32;ptr++)
palloop4:                           ; {
    

    mov     bl,32                   ; outp(0x3c9,32+ptr);
    add     bl,byte ptr cnt                   
    call    fixcolor
    Outp    03C9h,bl
    Outp    03C9h,bl                ; outp(0x3c9,32+ptr);
    
    mov     bh,byte ptr cnt         ; outp(0x3c9,48+(ptr>>1));
    shr     bh,1
    mov     bl,48
    add     bl,bh
    call    fixcolor
    Outp    03C9h,bl
    
    
    inc     byte ptr cnt
    
    cmp     byte ptr cnt,32
    jb      palloop4                ; }


    xor     si,si                   ; {
    
    mov     ah,0                     ; for (y=0;y<200;y++) 
yloop:                              ; {
    mov     bx,ds                   ; precalc=sinus[(y+xsin)];
    add     bl,ah
    xor     bh,bh
    mov     fs,word ptr cs:[sinus+bx]
    
    mov     cx,0                     ; for (x=0;x<320;x++)
xloop:                              ; {

    mov     dx,fs                   ; vx=x+precalc
    add     dl,cl
                                    ; vy=y+sinus[(x+ysin)];
    mov     bx,ds
    xor     bh,bh
    add     bl,cl
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,ah
    mov     dh,bl
                                    ; vx=vx+sinus[(vy+xsin2)];
    add     bx,di
    xor     bh,bh
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,dl
    mov     dl,bl
                                    ; vy=vy+sinus[(vx+ysin2)];
    add     bx,di
    xor     bh,bh
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,dh
    
    mov     al,byte ptr cs:[sinus+bx]
    mov     bl,dl                   ; vb[0]=sinus[vx]+sinus[vy];
    add     al,byte ptr cs:[sinus+bx]
    mov     byte ptr cs:[vb+0],al
    
    inc     cx                      ; x++

    

    mov     dx,fs                   ; vx=x+precalc
    add     dl,cl
                                    ; vy=y+sinus[(x+ysin)];
    mov     bx,ds
    xor     bh,bh
    add     bl,cl
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,ah
    mov     dh,bl
                                    ; vx=vx+sinus[(vy+xsin2)];
    add     bx,di
    xor     bh,bh
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,dl
    mov     dl,bl
                                    ; vy=vy+sinus[(vx+ysin2)];
    add     bx,di
    xor     bh,bh
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,dh
    
    mov     al,byte ptr cs:[sinus+bx]
    mov     bl,dl                   ; vb[1]=sinus[vx]+sinus[vy];
    add     al,byte ptr cs:[sinus+bx]
    mov     byte ptr cs:[vb+1],al
    
    inc     cx                      ; x++

    

    mov     dx,fs                   ; vx=x+precalc
    add     dl,cl
                                    ; vy=y+sinus[(x+ysin)];
    mov     bx,ds
    xor     bh,bh
    add     bl,cl
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,ah
    mov     dh,bl
                                    ; vx=vx+sinus[(vy+xsin2)];
    add     bx,di
    xor     bh,bh
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,dl
    mov     dl,bl
                                    ; vy=vy+sinus[(vx+ysin2)];
    add     bx,di
    xor     bh,bh
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,dh
    
    mov     al,byte ptr cs:[sinus+bx]
    mov     bl,dl                   ; vb[2]=sinus[vx]+sinus[vy];
    add     al,byte ptr cs:[sinus+bx]
    mov     byte ptr cs:[vb+2],al
    
    inc     cx                      ; x++

    

    mov     dx,fs                   ; vx=x+precalc
    add     dl,cl
                                    ; vy=y+sinus[(x+ysin)];
    mov     bx,ds
    xor     bh,bh
    add     bl,cl
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,ah
    mov     dh,bl
                                    ; vx=vx+sinus[(vy+xsin2)];
    add     bx,di
    xor     bh,bh
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,dl
    mov     dl,bl
                                    ; vy=vy+sinus[(vx+ysin2)];
    add     bx,di
    xor     bh,bh
    mov     bl,byte ptr cs:[sinus+bx]
    add     bl,dh
    
    mov     al,byte ptr cs:[sinus+bx]
    mov     bl,dl                   ; vb[3]=sinus[vx]+sinus[vy];
    add     al,byte ptr cs:[sinus+bx]
    mov     byte ptr cs:[vb+3],al
    
    inc     cx                      ; x++

    
    
    mov     edx,vb
    mov     dword ptr es:[si],edx   ; video[ptr++]=vb32;
    add     si,4

    cmp     cx,320
    jb      xloop                   ; }
    
    inc     ah
    cmp     ah,200
    jb      yloop                   ; }
                                    
    dec     di
    mov     ax,ds
    inc     ax
    mov     ds,ax

    waitvbl
    

    mov     dx,60h
    in      al,dx
    
    cmp     al,1
    jne     nokey
    mov     key,1

nokey:
    cmp     fade,0
    jne     mainloop

    Outp    21h,0                   ; outp (0x21,0);    
    
    mov     ax,3h
    int     10h
    
    mov bx,cs
    mov ds,bx
    mov dx,offset text
    mov ah,9
    int 21h

    ret

    fixcolor:

    mov     al,bl
    mul     fade
    mov     cl,200
    div     cl
    mov     bl,al

    ret

    
END START
