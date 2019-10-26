;  ES   v
; J  K  E (The Cavern)
;     YN
; a 128-byte intro by rrrola <rrrola@gmail.com>
; greets to everyone who thinks squarish tunnels are 27.32395% cooler

  org 100h  ; assume ah=bx=0 cx=255 si=100h di=sp=-2

  mov  al,93h        ; int16[100h] = -27728 = BIG
  push 09FCEh        ; screen-aligning trick from Puls
  pop  es
  int  10h           ; mode 320x200 without clearing the screen

; bx = sp+2 = time = ptr to current metaball position (-= 16 each frame)
M fninit             ; { } = fpu stack
  inc  cx            ; cx=1 (256 on first frame: precompute states, set palette)

N mov  bp,8         ; Create a new state for the 4 metaballs: m[i].x, m[i].y
S xchg ax,bx
  mul  word[bp+si]   ; frequencies = { int16[108h]...int16[101h] }
  mov  bx,sp         ; dx = time * frequency[i] / 65536
  push dx            ; bx = sp+2
  fild   word[bx+di]
  fdiv   dword[byte si-100h+C-2] ; -111.498
  fsin               ; {position = sin(time * frequency[i] / 65536 / -111.498)}
  fimul  word[si]
  fistp  word[bx]    ; int16[bx] = BIG*position
  dec  bp
  jnz  S

  mov  dx,3C9h       ; palette[i].rgb = [2*i 2*i-8 max(i-1,0)]
  mov  ax,cx
  out  dx,al         ; blue uses running index from last time
  dec  dx
  out  dx,al
  inc  dx
  add  al,al
  out  dx,al
  sub  al,8
  out  dx,al
  loop N

  mov  [di],es       ; uint32[-4]=9FCE0059h ah=cx=bp=0 dx=3C9h
                     ; x = int0_16[-3] ~ -0.5..0.5 (+= 0.003125 each column)
                     ; y = int0_16[-2] ~ -0.4..0.4 (+= 0.00390625 each row)

X xor  ax,ax        ; For 29 layers
  mov  al,29         ; al=layer=29 carry=0 ZF=1
  push bp            ; store pixel address to [bx-4]
  lea  bp,[bx+si]    ; go back 32 frames (32 * 16 bytes/frame = 0x200 = bx+si+si)

Z fldl2t            ; Sum 4 metaball potentials: carry=0 ZF=(initial pass ? 1 : 0)
  fimul  word[bp+si] ; load metaball coord (m[i].y or m[i].x) * 3.322
  lea  bp,[bp+di]    ; =sub bp,2 without modifying carry or ZF
  jz   I             ; initial pass: skip computing absolute differences
  fsub   st3
  fabs
I cmc                ; load both coords; loop using carry
  jc   Z
  jz   J             ; initial pass: {cy=m[0].y cx=m[0].x}, skip to J
  faddp  st1         ; otherwise: {dy=|m[i].y-cy| dx=|m[i].x-cx| sum cy cx}
  fidivr word[si]
  fsubp  st1         ;  {sum+=-BIG/(dy+dx) cy cx}
  add  al,40h
  jnc  Z             ;  loop 4 times (al is never zero here, so ZF=0)

  fistp  word[bx+di]; If we're inside the isosurface: go to next layer
  cmp  [bx+di],dh    ; carry = ((int16)sum<3 ? 1 : 0)
J dec  ax            ; ZF = (--layer==0 ? 1 : 0), carry unchanged

  fiadd  word[di]
  fild   word[di-1]
C faddp  st2
  fld1               ; {sum=1 cy+=y cx+=x}

  jnbe Z             ;-) if (!initial pass && ((int)sum>=3 || --layer==0)) break

  fninit             ; { }
  xor  al,1Fh        ; al = 31-al (use 3Fh to get blue->white)
  pop  bp
  add  word[di-2],0CCCDh ; advance x, y and address
  adc  word[di],cx       ;cx=0
  inc  bp
  mov  [es:bp+si],al ; Draw pixel: al = depth = color
  jnz  X             ; do all 65536 pixels

  in   al,60h
  dec  ax            ;ah=0
  jne  M
  int  20h           ; can't use ret
