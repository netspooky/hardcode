;*****************************************************************************
;  This intro was made by Spyko (Petrik Clarberg, Sweden) in December 1996.
;    e-mail:  spyko@geocities.com   (or: spykoo@hotmail.com)
;    visit:   http://hem1.passagen.se/spyko   - my new demo coding page!
;*****************************************************************************
        IDEAL
        P386
        MODEL tiny
NrStars         EQU     175
Xsize           EQU     3
Ysize           EQU     4
        CODESEG
        ORG 100h
Start:  ASSUME  es:@code
        ASSUME  ds:@code
;----------- Set video mode ------------
        mov     al,13h          ; assumes ah=0
        int     10h             ; set mode 13h (320*200)
        push    ax              ; ah=0 is used later as a loopcounter
;---- Set color 7 (text color) to black, (12 byte) ------
        mov     al,7
        mov     dx,03C8h
        out     dx,al
        inc     dx
        xor     al,al
        out     dx,al
        out     dx,al
        out     dx,al
;----------- (4 byte) -----------
        mov     ah,0A0h
        mov     fs,ax           ; fs = A000h (video mem)
;------------ Calculate Stars (22 byte) ------------
        mov     di,OFFSET Stars
        mov     cl,NrStars
@@st1:  stosw
        add     ax,23500
        rol     al,1		; some fake random stuff
        push    ax
        and     al,011b
        inc     al
        stosb
        pop     ax
        dec     cl
        jnz     SHORT @@st1
;/////////////  MAIN LOOP  //////////////
Main:   mov     ah,02h
        xor     dx,dx
        xor     bx,bx
        int     10h		; set cursor position to 0,0
        mov     dx,OFFSET Msg
        mov     ah,09h
        int     21h		; write the text with color 7 (black)

        mov     di,(40*320)
        mov     dx,0102h
        pop     ax
        inc     ah      	; ah = counter of x-value
        push    ax
;---------- write the scroll to screen -----------
@@scroll:
        xor     si,si
        mov     ch,8
@@1:    mov     bl,ah
        mov     cl,80
@@2:    mov     al,[fs:bx+si]
        or      al,al
        jz      SHORT @@3
        mov     al,bl
        and     al,00111111b
        add     al,32
        add     al,ch
@@3:    push    cx
        mov     ch,Ysize
@@i1:   mov     cl,Xsize
@@i2:   mov     [fs:di],al
        inc     di
        dec     cl
        jnz     SHORT @@i2
        add     di,(320-Xsize)
        dec     ch
        jnz     SHORT @@i1

        add     bl,dh
        sub     di,(Ysize*320-4)
        pop     cx
        dec     cl
        jnz     SHORT @@2
        add     si,320
        add     di,(4*320)
        dec     ch
        jnz     SHORT @@1

        mov     di,(110*320)
        mov     dh,-1
        dec     dl
        jnz     SHORT @@scroll
;-----------  Update Stars (41 byte) -------------
        mov     si,OFFSET Stars
        mov     di,si
        mov     cl,NrStars
@@ds1:  lodsw
        push    ax
        xor     ah,ah
        lodsb
        pop     bx
        mov     [BYTE fs:bx],0
        push    ax
        mov     dx,321
        mul     dx
        add     bx,ax
        mov     ax,bx
        stosw
        pop     ax
        stosb
        shl     al,1
        add     al,23
        mov     [BYTE fs:bx],al
        dec     cl
        jnz     SHORT @@ds1
;------- Wait for vertical retrace (13 byte) -------
        mov     dx,03DAh
@@vr1:  in      al,dx
        and     al,08h
        jnz     SHORT @@vr1
@@vr2:  in      al,dx
        and     al,08h
        jz      SHORT @@vr2
;--------- Key check (8 byte) ---------
        mov     ah,11h
        int     16h
        jz      Main
;/////////// MAIN LOOP END ///////////
;------------- EXIT -------------
        mov     ax,0003h
        int     10h             ; return to text-mode
        mov     ah,09h
        mov     dx,OFFSET Msg+18        
        int     21h             ; write "by Spyko..."
        mov     ah,4Ch
        int     21h		; return to dos
;------------ Data section (33 byte) ------------
Msg             DB      "A 256-bytes INTRO by SPYKO...   ",36
Stars           DB      (NrStars*3) DUP (?)             ; memory to stars
        END Start
