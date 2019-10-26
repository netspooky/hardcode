  ;*******************************************************************************
  ;*   Betrunkene Ameise auf dem Weg zum Klo by T$ & [neo] / ByTeGeiZ   *
  ;*******************************************************************************

code segment
assume cs:code,ds:nothing,es:nothing,ss:code

org 100h
.386

;[neo] - Palette

  Start:
  mov    al,13h
  int    10h
  lds    ax,[bx]
  mov    dx,3C9h
  mov    ch,3
  locloop_1:
  ror    eax,8 ;"rol" für rot/orange
  cmp    al,3Fh
  jb     loc_2
  mov    al,3Fh
  inc    ah
  loc_2:
  test   cl,3
  jz     loc_3
  out    dx,al
  loc_3:
  loop   locloop_1

;T$ - Ameisenalgo

 x equ cx
 y equ bp
 t equ di
 pos equ bx

  inc x
  sub y,y
  ameise:
  push   y
  mov    t,y
  shl    y,2
  lea    y,[y+t]
  shl    y,6
  add    pos,x
  add    pos,y
  mov    y,x
  pop    x
  inc    byte ptr [pos] ;hier geht auch "dec" oder "xor [pos],val"
  jp     rechts ;hier geht auch "ja","jbe","jge","jl","jno","jnp","jns","jnz","jo","js" oder "jz"
  links:
  neg    y
  neg    x
  rechts:
  neg    x
  jmp    ameise

  ; in    al,60h
  ; dec   al
  ; jnz   ameise
  ; mov   ax,3
  ; int   10h
  ; mov    ah,4ch
  ; int    20h
  ; ret

code ends

END Start