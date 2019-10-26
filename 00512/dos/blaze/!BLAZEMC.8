; ******* Blaze *******
; * Written by Gopher *
; *********************

; The macros in this file allow one to quickly make a fire
; simulation. They fit together like Tinkertoys. However, they do
; fit together precisely. Keep in mind:

; Blaze memory management

; Blaze is a .COM program, so DOS allocates 64K for it to use. Less
; than 500 bytes are used for the actual program. The rest of the
; 64K goes to the current random number, a buffer of 64 past random
; numbers to increase the 'randomness' of the numbers, and an
; internal buffer. This buffer mirrors the screen image, but it has
; 2x2 'pixels,' enabling the program algorithm to work with 1/4 the
; number of calculations. When the buffer is output to the screen,
; each pixel is blurred, creating the impression of smoothness.

; So far, so good. But when you get to the reflection simulations,
; an additional wrinkle is thrown in. These Blit functions cannot
; always output the entire screen in one retrace, so they use
; another buffer, called the double-buffer. This buffer lies
; immediately after the 64K allocated by DOS in memory. The
; reflection Blits produce the finished image in the double-buffer.
; The macro M_Blit simply transfers the double-buffer to the
; screen.

; As is usual, in a COM program, CS, DS, and SS are equal. Except
; in the Blit, LRnd, and initialization sections, ES points to screen
; memory.

; Blaze macros

; This is how a Blaze program looks:

; M_Init

; M_StdPal
; or
; M_SmallPal

; M_MainLoop_Normal_1
; or
; M_MainLoop_Reflect_1

; M_Blit_Simple
; or
; M_Blit_Reflect_Mirror or M_Blit_Reflect_Water
; M_WaitVRT if wanted
; M_Blit

; M_MouseCheck

; M_MainLoop_2

; M_LRnd

; (M_RippleTable if M_Blit_Reflect_Water used)


; Macros:

; M_Init incorporates M_ZeroBuf and M_Randomize, sets up
;        MouseCheck, and sets mode 013
; M_StdPal sets a palette for a 'normal' simulation
; M_SmallPal sets a palette for a reflection simulation
; M_MainLoop_Normal_1
; M_WaitVRT waits for the vertical retrace
; M_Blit copies the double-buffer to the screen
; M_Blit_Pixel blurs a single pixel to the screen
; M_Blit_Simple blurs the buffer to the screen
; M_Blit_Reflect_Water
; M_Blit_Reflect_Mirror
; M_MouseCheck checks if the mouse has moved
; M_MainLoop_2
; M_LRnd produces a random number
; M_RippleTable includes the table needed for
;               M_Blit_Reflect_Water


data segment

  rSeed: dd ?
  rVals: dd 65 dup ?
  Buf: dw 32160 dup ?

data ends


; ****** Zero the buffer

; Should be called first.
; Assumes: AX = 0
;          ES -> data segment.
; Ends with: DI trashed
;            CX = 0.

M_ZeroBuf macro
  ; xor ax, ax
  mov di, Buf
  mov cx, 32160
  rep stosw
#EM


; ****** Randomize

; Sets the first seed and initializes the random number buffer of
;   previous values.
; Assumes: AH = 0.
; Ends: AX, DX, DI trashed
;       CX = 0.

M_Randomize macro
;  xor ah, ah       ; Function 0 - Get ticks
  int 01A

  xchg ax, cx

  mov di, rSeed
  mov cl, 65
M1:
  call LRnd
  stosw
  xchg ax, dx
  stosw
  loop M1
#EM


; ****** M_Init

; Initializes the buffer, random number generator, and mouse tester.

M_Init macro
  M_ZeroBuf
  M_Randomize

  mov ax, 013      ; Set mode 013 - 320x200x256.
  int 010
#EM


; ****** Standard Palette

; Sets up a palette for a standard flame simulation.
; Assumes: CH = 0.
; Ends: AL = 63
;       CX = 0
;       DX = 03C9.

M_StdPal macro
  mov dx, 03C9     ; Routine to set up the palette 
  mov cl, 32       ; CH is already zero
L1:
  mov al, cl       ; Set up the reds. Less red (only 32 or so
  dec dx           ;   palette entries) makes the flames seem
  out dx, al       ;   hotter
  shl al, 1
  dec ax           ; Same effect as dec al, but with one less byte
  inc dx
  out dx, al
  xor al, al
  out dx, al
  out dx, al
  loop L1

  mov cl, 63       ; CH is already zero
L1:
  mov al, cl       ; Set the oranges
  add al, 32
  dec dx
  out dx, al
  mov al, 63
  inc dx
  out dx, al
  mov al, cl
  out dx, al
  xor al, al
  out dx, al

  mov al, cl       ; This section sets the yellows
  add al, 95
  dec dx
  out dx, al
  mov al, 63
  inc dx
  out dx, al
  out dx, al
  mov al, cl
  out dx, al

  mov al, cl       ; This section sets the blues
  add al, 158
  dec dx
  out dx, al
  mov al, 64
  sub al, cl
  inc dx
  out dx, al
  out dx, al
  mov al, 63
  out dx, al
  loop L1
#EM


; ****** Small Palette

; Prepares a small palette for reflection simulations.
; Assumes: CH = 0.
; Ends: AL = 63
;       CX = 0
;       DX = 03C9.

M_SmallPal macro
  mov dx, 03C9     ; Routine to set up the palette
  mov cl, 32       ; CH is already zero
L1:
  mov al, cl       ; Set up the reds.
  dec dx
  out dx, al
  shl al, 1
  dec ax           ; Same effect as dec al, but with one less byte
  inc dx
  out dx, al
  xor al, al
  out dx, al
  out dx, al

  mov al, cl       ; Set the oranges
  add al, 32
  dec dx
  out dx, al
  mov al, 63
  inc dx
  out dx, al
  mov al, cl
  shl al, 1
  dec ax
  out dx, al
  xor al, al
  out dx, al

  mov al, cl       ; This section sets the yellows
  add al, 64
  dec dx
  out dx, al
  mov al, 63
  inc dx
  out dx, al
  out dx, al
  mov al, cl
  shl al, 1
  dec ax
  out dx, al
  loop L1

  mov cl, 63
L1:
  mov al, cl       ; This section sets the blues
  add al, 96
  dec dx
  out dx, al
  mov al, 64
  sub al, cl
  inc dx
  out dx, al
  out dx, al
  mov al, 63
  out dx, al
  loop L1
#EM


; ****** Blit section


; ****** Wait for vertical retrace

; Assumes: nothing.
; Ends: AL trashed
;       DX = 03DA.

M_WaitVRT macro
  mov dx, 03DA
M1:
  in al, dx
  test al, 08
  jnz M1
M2:
  in al, dx
  test al, 08
  jz M2
#EM


; ****** Blit

; Copies the double-buffer immediately after the .COM's 64K to the
;   screen
; Assumes: ES -> double-buffer
; Ends: SI, DI trashed
;       ES, AX = 0A000
;       CX = 0.

M_Blit macro
  push ds
  mov ax, es
  mov ds, ax
  mov ax, 0A000
  mov es, ax
  xor si, si
  mov di, 320
  mov cx, 63360/2
  rep movsw
  pop ds
#EM


; ****** Blit_Pixel

; Blurs a pixel to the screen.
; Assumes: DS:SI -> current location in buffer memory
;          ES:DI -> current location in screen memory
;          AH, DH = 0.
; Ends: SI, DI incremented
;       AH, DH = 0.

M_Blit_Pixel macro
  mov al, [si-320] ; To blur on-screen, the four adjacent pixels
  mov dl, [si-1]   ;   are averaged and the resulting value is used
  add ax, dx       ;   for the pixel
  mov dl, [si+1]
  add ax, dx
  mov dl, [si+320]
  add ax, dx
  shr ax, 2
  inc si           ; Go to next pixel
  stosb
#EM


; ****** Blit_Simple

; Blurs the buffer to the screen
; Assumes: DS normal
;          ES -> screen memory
; Ends: AX, DX, SI, DI trashed
;       CX = 0.

M_Blit_Simple macro
  mov si, Buf+320  ; Skip the top line
  mov di, 320
  mov cx, 63360    ; And the bottom line
  xor ah, ah
  cwd
M1:
  M_Blit_Pixel
  dec cx
  jnz M1
#EM


; ****** Blit_Reflect_Water

; Outputs the reflection image to the double-buffer. MUST be
;   followed by M_Blit (possibly after a M_WaitVRT).
; Assumes: nothing.
; Ends: AX, BX, DX trashed
;       CX = BP = 0
;       ES -> double-buffer.

M_Blit_Reflect_Water macro
  mov ax, cs
  add ax, 01000
  mov es, ax

  mov si, Buf+320  ; Skip the top line
  xor di, di
  mov bp, 66
  mov bx, 63360-320
  xor ah, ah
  cwd
M1:
  mov cx, 320
M2:
  M_Blit_Pixel
  sub al, 8
  if s xor al, al
  es mov [bx], al

  push bp, bx, ax, di, bx
  call LRnd
  pop bx, di
  xchg ax, bp
  and bp, 0F
  shl bp, 1
  add bp, RippleTable
  add bx, [bp]
  pop ax
  es mov [bx], al
  pop bx, bp

  xor dh, dh

  inc bx
  dec cx
  jnz M2

  mov cx, 320
M3:
  M_Blit_Pixel
  dec cx
  jnz M3

  sub bx, 640
  dec bp
  jnz M1
#EM


; ****** M_Blit_Reflect_Mirror

; See M_Blit_Reflect_Water. This does not use the ripple table.
; Assumes: nothing.
; Ends: AX, BX, DX trashed
;       CX = BP = 0
;       ES -> double-buffer.

M_Blit_Reflect_Mirror macro
  mov ax, cs
  add ax, 01000
  mov es, ax

  mov si, Buf+320  ; Skip the top line
  xor di, di
  mov bp, 66
  mov bx, 63360-320
  xor ah, ah
  cwd
M1:
  mov cx, 320
M2:
  M_Blit_Pixel
  sub al, 8
  if s xor al, al
  es mov [bx], al
  inc bx
  dec cx
  jnz M2

  mov cx, 320
M3:
  M_Blit_Pixel
  dec cx
  jnz M3

  sub bx, 640
  dec bp
  jnz M1
#EM


; ****** Ripple Table

; Needed for M_Blit_Reflect_Water.

M_RippleTable macro

RippleTable:
  dw 0,0,0,0,0,0
  dw 1,-1,1,-1,320,-320,319,321,-319,-321

#EM


; ****** End of Blit section


; ****** Main loop for normal simulations, first part

; Draws the next frame to the buffer.
; Assumes: CH = 0.

M_MainLoop_Normal_1 macro
  push 0A000       ; Finally, done with the palette
  pop es           ; Set ES to point to the graphics memory

; In the loop:
; AX and DX are used to calculate the current pixel
; BX is used as the current offset in buffer memory.
; CX is used as a loop counter Y-wise.
; BP is used as a loop counter X-wise.
; BP counts from 0 to 319 because the flames 'lean' right. If they
;   'leaned' left, we could code it more efficiently.

MainLoop:
  xor bp, bp

  InsideLoop1:
    mov cl, 100         ; 100 "pixels" (Y-wise) to calculate
    mov bx, Buf+640     ; BX holds the "segment" of buffer memory
    add bx, bp
    xor dh, dh

    InsideLoop2:
      xor ah, ah
      mov al, [bx]
      mov dl, [bx+2]
      add ax, dx
      mov dl, [bx-2]
      add ax, dx
      cmp cl, 1         ; If this were not here, the last line
      jbe >L1           ;   would look rather weird
      mov dl, [bx+642]
      add ax, dx
    L1:
      shr ax, 2         ; Average of the four above values
      if nz dec ax      ; Fade the flames out as they rise
      mov ah, al
      mov [bx-640], ax  ; Write two pixels to the draw buffer
      mov [bx-320], ax  ; Write another two pixels
      add bx, 640       ; Move down
      dec cx            ; Slightly faster than loop InsideLoop2
      jnz InsideLoop2

    call LRnd           ; Generate the next random numbers
    and al, 1
    if nz or al, 255
    mov [64000+Buf+bp], al   ; Ready to move up the screen
    inc bp                   ; Increase X
    inc bp
    cmp bp, 320
    jb InsideLoop1
#EM


; ****** Main loop for reflection simulations, part 1

; Draws the next frame into the buffer.
; Assumes: CH = 0.

M_MainLoop_Reflect_1 macro
  push 0A000       ; Finally, done with the palette
  pop es           ; Set ES to point to the graphics memory

; In the loop:
; AX and DX are used to calculate the current pixel
; BX is used as the current offset in buffer memory.
; CX is used as a loop counter Y-wise.
; BP is used as a loop counter X-wise.

MainLoop:
  xor bp, bp

  InsideLoop1:
    mov cl, 67          ; 67 "pixels" (Y-wise) to calculate
    mov bx, Buf+640     ; BX holds the "segment" of buffer memory
    add bx, bp
    xor dh, dh

    InsideLoop2:
      xor ah, ah
      mov al, [bx]
      mov dl, [bx+2]
      add ax, dx
      mov dl, [bx-2]
      add ax, dx
      cmp cl, 1         ; If this were not here, the last line
      jbe >L1           ;   would look rather weird
      mov dl, [bx+642]
      add ax, dx
    L1:
      shr ax, 2         ; Average of the four above values
      if nz dec ax      ; Fade the flames out as they rise
      mov ah, al
      mov [bx-640], ax  ; Write two pixels to the draw buffer
      mov [bx-320], ax  ; Write another two pixels
      add bx, 640       ; Move down
      dec cx            ; Slightly faster than loop InsideLoop2
      jnz InsideLoop2

    call LRnd           ; Generate the next random numbers
    and al, 1
    if nz mov al, 172
    mov [42880+Buf+bp], al   ; Ready to move up the screen
    inc bp                   ; Increase X
    inc bp
    cmp bp, 320
    jb InsideLoop1
#EM


; ****** Main loop, part 2

; Checks for a keystroke and ends the program if necessary.
; Assumes: nothing.

M_MainLoop_2 macro
  mov ah, 06       ; Better than the port solution because if a key
  mov dl, 0FF      ;   is waiting, the function reads it and you
  int 021          ;   don't see it until after the program ends.
  if z jmp MainLoop     ; Z flag -> no key is waiting

E1:
  mov ax, 0 BY 3   ; Return to text mode
  int 010
  mov ax, 04C BY 0 ; End the program, exit code 0.
  int 021
#EM


; ****** LRnd

; Produces the next semirandom number.
; Assumes: ES != DS.
; Ends: BX, DI trashed
;       DX:AX = next semirandom number.

M_LRnd macro
LRnd:
  push es, cx, si, ds
  pop es                ; so the stosw at the end points to DS

  mov si, 0113
  mov di, rSeed
  lodsw
  mov bx, ax
  mul w [di+2]
  mov cx, ax
  lodsw
  mul w [di]
  add cx, ax
  xchg ax, bx
  mul w [di]
  add dx, cx
  inc ax
  mov bl, dh            ; This section exchanges part of the current
  xor bh, bh            ;   seed with an old seed to make the
  xchg ax, [rVals+bx]   ;   sequence more random.
  stosw                 ; Store the next seed in rSeed
  mov [di], dx

  pop si, cx, es   ; Restore clobbered registers
  ret
#EM
