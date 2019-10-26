
;ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»;
;º                                                                           º;
;º 256 byte phong shaded torus!                                              º;
;º                                                                           º;
;º Source code by Maxwell Sayles (Fysx/Xi)                                   º;
;º August 19, 1997.                                                          º;
;º                                                                           º;
;ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼;

  LOCALS
  .386p

b EQU byte ptr
w EQU word ptr
d EQU dword ptr
o EQU offset

Code SEGMENT PARA PUBLIC USE16
  ASSUME CS:Code, DS:Code, SS:Code

INNER_RAD       EQU (30)  ; inner circle radius
OUTER_RAD       EQU (62)  ; outer circle radius
BASE_COLOR      EQU (85h) ; base color of torus
ROTATE_VELOCITY EQU (237) ; rate of rotation of torus

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿;
;³ Program Entry                                                             ³;
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ;
ORG 100h
Start:

;  db 'FYSX'           ; this executes relatively harmlessly

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  push w 0A000h       ; video segment
  pop es

  mov dh,50h          ; sine/cosine table segment (5000h)
  mov fs,dx

  mov dh,60h          ; z-buffer segment (6000h)
  mov gs,dx

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; set 320x200x256
  mov al,13h
  int 10h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ; generate Sine/Cosine table
  fldz
  @@SinLoop:
    fld st
    fsin
    fstp d FS:[bx]
    fadd RadAdd
    add bx,4
    jnz @@SinLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  xor dx,dx           ; torus rotation index
  @@FrameLoop:

      xor cx,cx         ; index into outer angle as well as loop counter
      @@Outer:

        xor bp,bp         ; index into inner angle as well as loop counter
        @@Inner:

          push dx           ; save rotation index
                            ; DX is used for param passing in Put_Pixel

          xor ax,ax         ; set EAX to zero for coordinate init

          ; rotate inner ring (also normal)
          mov si,o x            ; rotate on XZ axis
          mov di,o z
          mov [si],eax          ; X=0, Y=0
          mov w [di],INNER_RAD  ; Z=radius of inner circle
          mov bx,bp             ; BX = inner angle
          call Rotate_Axis      ; rotate on XZ axis
          dec di
          dec di
          call Rotate_3_Axis    ; rotate point relative to torus position
                                ; and outer circle

          ; rotate center of first ring
          mov si,o Center_x     ; Rotate ring Center
          mov di,o Center_y
          mov w [si],OUTER_RAD  ; X=radius of outer circle
          mov [di],eax          ; Y=0, Z=0
          call Rotate_3_Axis    ; rotate point relative to torus position
                                ; and outer circle

          ; calculate color value
          mov ax,x              ; color value is 2(NX*NX+NY*NY)+Base_Color
          imul ax
          mov bx,ax
          mov ax,y
          imul ax
          add ax,bx
          add ax,ax
          add ah,BASE_COLOR
          mov dh,ah             ; store in color field of DX
                                ; for param passing to Put_Pixel

          ; calculate Z value
          mov dl,b z            ; actual z=inner circle+outer circle
          add dl,[di]           ; store in z field of DX
                                ; for param passing to Put_Pixel

          ; calculate screen offset
          ; screen offset = Y*320+X
          mov ax,y              ;   inner circle y
          add ax,Center_y       ; + outer circle y
          sar ax,1              ; >>1
          imul bx,ax,320        ; * 320
          mov ax,x              ;   inner circle x
          add ax,Center_x       ; + outer circle x
          sar ax,1              ; >>1
          add ax,159+69*320     ; + "center on screen" value
          add bx,ax             ; + Y value

          ; render a 4x4 voxel
          ; DH = color
          ; DL = Z Value
          ; BX = pixel offset
          ; Put_Pixel returns with BX++
          call Put_Pixel        ; put X,Y
          call Put_Pixel        ; put X+1,Y
          add bx,318
          call Put_Pixel        ; put X,Y+1
          call put_Pixel        ; put X+1,Y+1

          pop dx            ; restore rotation index

          add bp,200h     ; increment inner loop index and counter
          jnz @@Inner     ; finished inner loop?

        add ch,2          ; increment outer loop index and counter
        jnz @@Outer       ; finished outer loop?

    ; copy buffered image
    ; clear buffered image
    ; clear z-buffer
    ; CX is now zero
    ; operate on 32kb of data
    @@10:
      mov b GS:[si],127   ; z-buffer far value
      movsb               ; copy pixel from offscreen to visual
      mov b [si-1],0      ; erase offscreen
      dec cx              ; count down by two
      loop @@10           ; decrement and test for loop?

    add dx,ROTATE_VELOCITY*4    ; perform rotation around 2 axis

  ; test for ESC key
  in al,60h
  cmp al,1
  jnz @@FrameLoop


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿;
;³ Put Pixel                                                                 ³;
;³                                                                           ³;
;³ Entry:                                                                    ³;
;³   BX - offset of pixel                                                    ³;
;³   DH - color of pixel                                                     ³;
;³   DL - z value of pixel                                                   ³;
;³                                                                           ³;
;³ Exit:                                                                     ³;
;³   BX++                                                                    ³;
;³                                                                           ³;
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ;
Put_Pixel:
  cmp GS:[bx],dl
  jl @@10
    mov [bx],dh
    mov GS:[bx],dl
  @@10:
  inc bx

  ret   ; comment this line to gain 1 byte optimization


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿;
;³ Performs rotation on three axis                                           ³;
;³                                                                           ³;
;³ Orients point relative to outter angle and torus orientation              ³;
;³                                                                           ³;
;³ Entry:                                                                    ³;
;³   SI - X coordinate                                                       ³;
;³   DI - Y coordinate                                                       ³;
;³                                                                           ³;
;³ Exit:                                                                     ³;
;³   Oriented point                                                          ³;
;³                                                                           ³;
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ;
Rotate_3_Axis:
  ; rotate on outer axis
  ; rotate XY axis by outer angle index
  mov bx,cx
  call Rotate_Axis

  ; orient relative to torus

  ; rotate XZ axis by torus angle index
  inc di
  mov bx,dx
  inc di
  call Rotate_Axis

  ; rotate YZ axis by torus angle index*2
  ; (times two for less redundant rotation)
  inc si
  add bx,dx
  inc si
  call Rotate_Axis

  ret


;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿;
;³ Rotate Axis                                                               ³;
;³                                                                           ³;
;³ Entry:                                                                    ³;
;³   DI - first component of axis to be rotated                              ³;
;³   SI - second component of axis to be rotated                             ³;
;³   BX - index into sine/cosine table for rotation                          ³;
;³                                                                           ³;
;³ Exit:                                                                     ³;
;³  Rotated coordinate                                                       ³;
;³                                                                           ³;
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ;
Rotate_Axis:

  fld d FS:[bx-4096*4]
  fild w [si]
  fld st
  fmul d FS:[bx]
  fild w [di]
  fmul st,st(3)
  fsubp
  fistp w [si]
  fmulp
  fild w [di]
  fmul d FS:[bx]
  faddp
  fistp w [di]

  ret


;*****************************************************************************;
  ; DATA
RadAdd dd 39C90FDBh   ; (PI/8192)


;*****************************************************************************;
  ; BSS
ORG 1800h

  ; inner circle x,y,z
  ; normal x,y,z
x dw ?
y dw ?
z dw ?

  ; aligner
dw ?

  ; center of inner circle x,y,z
Center_x dw ?
Center_y dw ?
Center_z dw ?

Code ENDS

  END Start
