org 100h

ADDSHIFT equ 4

  aas           ; db 3Fh: float[si-3] = 0.5
PSCALE:         ;=-16256
  db 0x80,0xC0,13h  ; long "add al,13h"
  int  10h

  add  dh,al    ; cs = ss = constants, stack, scratch
  mov  fs,dx    ; teal screen
  add  dh,al
  mov  gs,dx    ; orange screen
  add  dh,al
  mov  es,dx    ; 32768 stored points (TODO: bytes are enough when normalized correctly)
  mov  bp,SHAPE+1 ; u16[bp]=shape, [bp+si]=scratch, [bp+si+4]=MIN, [bp+si+8]=MAX

  mov  dx,3c8h  ; palette: ttttoooo (teal * orange)
  salc          ; al=0
  out  dx,al
  inc  dx
P:or   ax,1100001111000011b
  push ax
  out  dx,al    ; R
  add  al,ah
  shr  al,1
  out  dx,al    ; G
  add  al,ah
  shr  al,2
  out  dx,al    ; B
  pop  ax
  inc  ax
  jnz  P

M2:
  fninit
  fldz
  fldz
  fldz          ; {c b a}
  dec  bp
;  fst    qword[bp+si+4]  ; zero MAX and MAX2(=-MIN): needed for normalization
  pop  bx
  xor  di,di

M:
  push di       ;=0 ; sp counts frames
  call I

; combine orange and blue screens and fade them out, store to vram
; di=0, cx=0, bx=al=junk

  push es

S:xor  ax,ax
  xchg al,[gs:di]
  xchg ah,[fs:di]
  shr  ah,4
  and  al,0xF0
ROTSPEED:       ;=0x68
  push 0xA000
WIDTH: equ $-1  ;=160
  add  al,ah
  pop  es
  stosb
  loop S

;S:mov  dl,0xF0
;  mov  al,[gs:di]
;  shr  byte[gs:di],1
;  and  dl,[fs:di]
;  shr  byte[fs:di],1
;  shr  al,4
;ROTSPEED:       ;=0x68
;  push 0xA000
;WIDTH: equ $-1  ;=160
;  add  al,dl
;  pop  es
;  stosb
;  loop S

  pop  es


; draw all 32768 points with perspective
; di=0(index into points)
  mov  [bp+si],sp
  fild   word[bp+si]
  fidiv  word[byte si-100h+ROTSPEED] ; {t/ROTSPEED . . .}
  fsincos              ; {s c . . .}
  fdiv   st1,st0       ; {s c/s . . .}
D:
;rotate
  fld    st0           ; {s s c/s . . .}
  fimul  word[es:di]   ; {s*(x=p[i]) s c/s . . .}
  fld    st0           ; {sx sx s c/s . . .}
  fmul   st3           ; {cx sx s c/s . . .}
  scasw
  fld    st2           ; {s cx sx s c/s . . .}
  fimul  word[es:di]   ; {s*(z=p[i]) cx sx s c/s . . .}
  fadd   st1,st0       ; {sz sz+cx sx s c/s . . .}
  fmul   st4           ; {cz sz+cx sx s c/s . . .}
  fsubrp st2,st0       ; {Z=sz+cx X=cz-sx s c/s . . .}
  scasw
  mov  al,[es:di+3]    ; (color=p[i+6]>>8): 0..255


;rotate
;  fild   word[es:di]   ; {x=p[i] s c/s . . .}
;  fmul   st1           ; {sx s c/s . . .}
;  fld    st0           ; {sx sx s c/s . . .}
;  fmul   st3           ; {cx sx s c/s . . .}
;  scasw
;  fild   word[es:di]   ; {z=p[i+2] cx sx s c/s . . .}
;  fmul   st3           ; {sz cx sx s c/s . . .}
;  fadd   st1,st0       ; {sz sz+cx sx s c/s . . .}
;  fmul   st4           ; {cz sz+cx sx s c/s . . .}
;  fsubrp st2,st0       ; {Z=sz+cx X=cz-sx s c/s . . .}
;  scasw
;  mov  al,[es:di+3]       ; (color=p[i+6]>>8): 0..255


;don't rotate
;  fild   word[di]
;  scasw
;  fild   word[di]
;  scasw
;  fild   word[di]


  fiadd  word[si]   ; {BIG+Z X s c . . .}
  fiadd  word[si]   ; {2*BIG+Z X s c . . .}
  fidivr word[byte si-100h+WIDTH]; {w=WIDTH/(Z+2*BIG) X s c . . .}

  fmul   st1,st0       ; {w X*w s c . . .}
  fimul  word[es:di]   ; {(Y=p[i+4])*w X*w s c/s . . .}
  fistp  word[bp+si]   ; Y*w {X*w s c . . .}
  imul bx,[bp+si],320  
  fistp  word[bp+si]   ; X*w {s c . . .}
  ;jo   O              ; handle Y overflow?
  add  bx,[bp+si]
  add  bx,100*320+160  ; bx = adr = (iy+100)*320 + (ix+160)

  add  al,al
  add  al,128
  shr  al,ADDSHIFT     ; 0..31

C:add  [fs:bx],al
  ;jnc  E
  ;sub  [fs:bx],al     ; saturate?
E:
  xor  al,255>>ADDSHIFT

  add  [gs:bx],al
  ;jnc  F
  ;sub  [gs:bx],al     ; saturate?
F:

O:dec  di
  dec  di
  jnz  D               ; i++

  fcompp               ; s c/s {. . .}  get rid of rotation coefficients

; esc check
  in   al,60h
  dec  al
  jnz  M

; generate about 1000 new points
; bx=constant
; di=0
; c b a = a*sin(p0*c+p1)+sin(p2*b+p3) c b
I:mov  ch,1024/256+1
  imul bx,sp,1024+128 ; where to start: sp decreases by 2
  jz   M2  ; switch to next fractal after making a rotation

R:pusha

  mov  cx,2          ; {c b a}
H:fld    st1         ; {b c b a}              ; {c sin(p0*b+p1) c b a}
  fimul  word[bp+di] ; {p0*b c b a}           ; {p2*c sin(p0*b+p1) c b a}
  ror  word[bp+di],4
  fiadd  word[bp+di] ; {p0*b+p1 c b a}        ; {p2*c+p3 sin(p0*b+p1) c b a}
  ror  word[bp+di],4
  fidiv  word[byte si-100h+PSCALE]
  fsin               ; {sin(p0*b+p1) c b a}   ; {sin(p2*c+p3) sin(p0*b+p1) c b a}
  loop H

  fmul   st4         ; {a*sin(p2*c+p3) sin(p0*b+p1) c b a}
  faddp  st1,st0     ; {a*sin(p2*c+p3)+sin(p0*b+p1) c b a}
  ffree  st3         ; {d=a*sin(p2*c+p3)+sin(p0*b+p1) c b}  ; can preserve rest with two fxch

; [B]=MAX=max(d_i), [B+4]=MAX2=max(-d_i) = -min(d_i)
; branchless min: mid = (a+b)/2; radius = abs(a-b)/2; max = mid+radius
; the qword zero store is necessary

;;  fld    st0
;;  fchs               ; {-d d . .}
;;  mov  cl,2
;;L:add  bp,4
;;  fld    st1         ; {d -d d . .}                  ; {-d MAX -d d . .}
;;  fadd   dword[bp+si]; {d+MAX -d d . .}              ; {-d+MAX2 MAX -d d . .}
;;  fld    st2         ; {d d+MAX -d d . .}            ; {-d -d+MAX2 MAX -d d . .}
;;  fsub   dword[bp+si]; {d-MAX d+MAX -d d . .}        ; {-d-MAX2 -d+MAX2 MAX -d d . .}
;;  fabs               ; {abs(d-MAX) d+MAX -d d . .}   ; {abs(-d-MAX2) -d+MAX2 MAX -d d . .}
;;  faddp  st1,st0     ; {2*max(d,MAX) -d d . .}       ; {2*max(-d,MAX2) MAX -d d . .}
;;  fmul   dword[si-3]; {MAX=max(d,MAX) -d d . .}     ; {MAX2=max(-d,MAX2) MAX -d d . .}
;;  fst    dword[bp+si]; {MAX -d d . .}                ; {-MIN=MAX2 MAX -d d . .}
;;  loop L
;;
;;; normalize
;;  fadd   st1,st0     ; {-MIN MAX-MIN -d . . .}
;;  fsubrp st2,st0     ; {MAX-MIN d-MIN . . .}
;;  fdivp  st1,st0     ; {d(0..1)=(d-MIN)/(MAX-MIN) . . .}
;;  fadd   st0         ; {d(0..2) . . .}
;;  fimul  word[si] ; {d(0..2*BIG) . . .}
;;  fisub  word[si] ; {d(-BIG..BIG) . . .}


; no normalization
;  fld    st0           ; 0..1 -> -6000..6000
;  fimul  word[si+0x17]
;  fisub  word[si+12]
;;

; no normalization, larger, messy
  fld    st0           ; 0..1 -> -6000..6000
  fimul  word[si+6]
  fisub  word[si+0x17]
;;


  fistp  word[es:bx]
  popa

  inc  bx
  inc  bx
  loop R

  ret
       db 0x98, 0x67
       db 0xfc, 0xbb, 0x77, 0xfc
       db 0x9c, 0xfe, 0x65, 0xBD
       db 0x58, 0x7C, 0xA1, 0x78
       db 0x06, 0x5C, 0x8B, 0xEB
       db 0x7C, 0x08, 0x80, 0x5F
       db 0xC6
SHAPE: equ $-2
