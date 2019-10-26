;--------------------------------------------------------------------------
; File: EFnet #asm Competition #8, entry therefor
; Author: Two9A, December 2003 - February 2004
; Contributions: KaliPara: * Code/Stack sharing
;                          * PlotPixel
;			   * Self-modifying code in sine plotter
;                Scali:    * AL->EAX filling (now unused)
;                vulture:  * 6-byte clearbuf
;--------------------------------------------------------------------------

[bits 16]                              ; Booted up in real mode

    org 0                              ; Code at start of sector
NewX db 0xb8,0x13                      ; This code only gets exec'd once
NewY db 0x00,0xcd                      ; so can be used as var storage
NewZ db 0x10,0xfa                      ; The code is:
ProjX db 0x0E,0x17                     ; mov ax,0x0013
ProjY db 0xBC,0xFE                     ; int 0x10; cli; push cs; pop ds
    db 0xFF                            ; mov sp,0xFFFE
    sti
    
    push 0x9000                        ; Point to the backbuffer
    pop es                             ; for writing
    call ClearBuf                      ; Clear the backbuf

    mov dx,0x03C8                      ; Port for palette setting
    xor al,al                          ; Start at colour 0
    out dx,al                          ; Tell the VGA
    inc dx                             ; Move along to palette data
pallp:                                 ; Setting the paldata
    out dx,al                          ; RED
    out dx,al                          ; GRN
    out dx,al                          ; BLU (greyscale, then)
    inc al                             ; Move along the scale
    jnz pallp                          ; If 106 (0), then all done

;--------------------------------------------------------------------------

main:                                  ; Main loop

    push 0x07C0                        ; Set the code segment
    pop ds                             ; for source
    push 0x9000                        ; Point to the backbuffer
    pop es                             ; for writing
    call ClearBuf                      ; Clear that backbuf

;--------------------------------------------------------------------------

    mov si,Points                      ; Point to the cube data
    mov cx,8                           ; For 8 points

pointlp:                               ; Process a point

    fild word [si+2]                   ; Read in the Y
    fild word [si+4]                   ; and Z
    fld dword [AngleX]                 ; and the rotation amount
    call Rotate2                       ; Call the l33t-assed 2d rot
    fistp word [NewY]                  ; Save the results
    fild word [si+0]                   ; Read in X (Z is on the stack)
    fld dword [AngleY]                 ; and the rotation amount
    call Rotate2                       ; Call the l33t-assed 2d rot
    fistp word [NewZ]                  ; Save the results
    fild word [si+2]                   ; Read in Y (X is on stack)
    fld dword [AngleZ]                 ; and the rotation amount
    call Rotate2                       ; Call the l33t-assed 2d rot
    fistp word [NewX]                  ; Save the results
    fistp word [NewY]                  ; to new ints

    fild word [NewX]                   ; Read in the
    fild word [NewY]                   ; final rotated
    fild word [NewZ]                   ; point coords
    call Project                       ; and project
    fistp word [ProjX]                 ; Save the final
    fistp word [ProjY]                 ; screen coords
    
    mov di,[ProjY]                     ; Read in the Y
    add di,64                          ; and centre it
    mov dx,[ProjX]                     ; Do the same
    add dx,128                         ; for X
    mov al,0xFF                        ; Glenz a pixel
    call PlotPixel                     ; Do it

    add si,6                           ; Move along one coord-set
    loop pointlp                       ; and loop back

    fld dword [AngleZ]                 ; Read in the angle
    fadd dword [Increment]             ; Move along by 2PI/2048
    fstp dword [AngleZ]                ; and save
    fld dword [AngleX]                 ; Read in the angle
    fadd dword [Increment]             ; Move along by 2PI/2048
    fstp dword [AngleX]                ; and save

;--------------------------------------------------------------------------

    mov dx,0x03DA                      ; From the CRTC flags
VSync1:                                ; Loop point 1
    in al,dx                           ; Get the flags
    test al,8                          ; Mask in the vflyback flag
    jz VSync1                          ; Loop until it's set (begin fb)
VSync2:                                ; Loop point 2
    in al,dx                           ; Get the flags
    test al,8                          ; Mask in vflyback
    jnz VSync2                         ; Loop until it clears (end fb)

    push es                            ; Copy the current ES
    pop ds                             ; to source seg
    push 0xA000                        ; And overwrite the vidmem
    pop es                             ; to destination
    xor di,di                          ; Set offset pointers
    xor si,si                          ; both to start of segment
    mov cx,0x3C00                      ; For 16000 dwords
    rep movsd                          ; Do the copy

    mov ah,1                           ; Test for a key
    int 16h                            ; through keyboard int
    jz main                            ; If none, loop back

reboot:                                ; If we finish the loop
    db 0xEA                            ; Far JMP
    dw 0x0000                          ; to the BIOS
    dw 0xFFFF                          ; reset procedure

;--------------------------------------------------------------------------

AddPixel:                              ; Draw a pixel in the backbuf
    add di,36                          ; Centre our 128-range in Y
    imul di,320                        ; y*xwidth
    add di,dx                          ; +x
    add di,32                          ; As X only stretches for one byte
    mov bl,[es:di]
    cmp bl,0xF0
    jle AddPixelUp
    sub bl,al
    xchg al,bl
    jmp AddPixelWrite
AddPixelUp:
    sub al,bl
AddPixelWrite:    
    mov [es:di],al
    ret                                ; And we're done!

PlotPixel:                             ; Draw a pixel in the backbuf
    add di,36                          ; Centre our 128-range in Y
    imul di,320                        ; y*xwidth
    add di,dx                          ; +x
    add di,32                          ; As X only stretches for one byte
    mov [es:di],al                     ; Write out the result
    ret                                ; And we're done!

;--------------------------------------------------------------------------

Rotate2:                               ; Rotate st2(x):st1(y) by st0(theta)
    fld st2                            ; x,y,r,x
    fld st2                            ; x,y,r,x,y
    fxch st2                           ; x,y,y,x,r
    fsincos                            ; x,y,y,x,cosr,sinr
    fmul st3,st0                       ; x,y,ysinr,x,cosr,sinr
    fmulp st5,st0                      ; xsinr,y,ysinr,x,cosr
    fmul st1,st0                       ; xsinr,y,ysinr,xcosr,cosr
    fmulp st3,st0                      ; xsinr,ycosr,ysinr,xcosr
    fsubp st1,st0                      ; xsinr,ycosr,xcosr-ysinr
    fxch st1                           ; xsinr,xcosr-ysinr,ycosr
    faddp st2,st0                      ; xsinr+ycosr,xcosr-ysinr
    ret                                ; newy,newx
    
Project:                               ; Project st2(x):st1(y):st0(z)
    fisub word [ZOffset]               ; z-=zoffset
    fdiv st2,st0                       ; x/z,y,z
    fdivp st1,st0                      ; x/z,y/z
    fimul word [ProjScale]             ; x/z,40y/z
    fxch st1                           ; 40y/z,x/z
    fimul word [ProjScale]             ; 40y/z,40x/z
    ret                                ; newy,newx

;--------------------------------------------------------------------------

ClearBuf:                              ; To clear the backbuf
    xor ax,ax                          ; Clear to 0x00
    mov ch,0x80                        ; for at least 0x8000 words
    rep stosw                          ; Do the write
    ret                                ; and we're done

AngleX dd 0.0                          ; Amount to rotate round x axis
AngleY dd 0.0                          ; Amount to rotate round y axis
AngleZ dd 0.0                          ; Amount to rotate round z axis
Increment dd 0.0015339808              ; 2PI/2048
ProjScale dw 32                        ; Scale up the projection by this
ZOffset dw 256                         ; An offset plane of z=256

Points:                                ; It's a cube!
    dw  1023, 1023, 1023
    dw  1023,-1023, 1023
    dw -1023,-1023, 1023
    dw -1023, 1023, 1023
    dw  1023, 1023,-1023
    dw  1023,-1023,-1023
    dw -1023,-1023,-1023
    dw -1023, 1023,-1023 

;--------------------------------------------------------------------------
; We need the sector to be a sector in size, and have the BIOS boot
; signature (55,AA) at position 510.

    times 510-($-$$) db 0              ; Pad out sector
    dw 0xAA55                          ; BIOS Signature

;----EOS-------------------------------------------------------------------
