org 100h

  aas           ; db 3Fh: float[100h-3] = 0.5
  mov  al,13h   ; 320x200
  int  10h

  add  dh,al
  mov  fs,dx    ; teal screen
  add  dh,al
  mov  gs,dx    ; orange screen
  add  dh,al
  mov  ds,dx    ; 32768 stored points (TODO: are bytes enough?)
  push 0xA000
  pop  es       ; vram

  mov  dx,3c8h  ; palette: ttttoooo (teal * orange)
  xor  ax,ax
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

  fninit

; junk just to get started
J:sbb  cx,di    ; add/adc/sub/sbb ax/si/bp/cx,di
  sbb  [di],cx  ; adc/sbb
  ror  cx,3
  dec  di
  jnz  J

M:add  word[di],100
  inc  di
  inc  di
  jnz  M

; draw all points with perspective
; TODO rotate, scale, timing
; di=0(index)
D:fild   word[ss:BIG]
  fadd   st0           ; {2*BIG . . .}
  fiadd  word[di]      ; {2*BIG+(z=[i]) . . .}
  fidivr word[ss:WIDTH]   ; {w=WIDTH/(z+2*BIG) . . .}

  fld    st0           ; {w w . . .}
  scasw
  fimul  word[di]      ; {(y=[i+2])*w w . . .}
  fistp  word[bp+si]   ; {w . . .}
  scasw
  fimul  word[di]      ; {(x=[i+4])*w . . .}
  imul bx,[bp+si],320  ; don't bother with overflow
  fistp  word[bp+si]   ; {. . .}
  jo   O
  add  bx,[bp+si]      
  add  bx,100*320+160  ; bx = adr = (iy+100)*320 + (ix+160)

  mov  al,128
  add  al,[di+3]       ; (color=[i+6]>>8): 0..255
  
;  mov  [fs:bx],al
;  not  al
;  mov  [gs:bx],al
  add  [fs:bx],al
  jnc  F
  mov  byte[fs:bx],255
F:not  al              ; 255..0
  add  [gs:bx],al
  jnc  G
  mov  byte[gs:bx],255
G:
O:dec  di
  dec  di
  jnz  D               ; di+=2


;  mov  dl,255
;  sub  dl,[bx+di]
;  shr  dl,5         ; blend with max color: branchless, looks good
;  add  [bx+di],dl   ; P[adr] = P[adr] + (255 - P[adr])/32 = (255 + P[adr]*31)/32


; combine orange and blue screens, store to vram
; di=0, bx=al=junk

S:mov  dx,0xF0F0
  and  dx,[fs:di]
  mov  word[fs:di],0
  mov  ax,[gs:di]
  mov  word[gs:di],0
  shr  ax,4
  and  al,0x0F
  add  ax,dx
  stosw
  or   di,di
  jnz  S

  in   al,60h   ; esc check
  dec  al
  jnz  M

; generate a point
; bx=constant
; a b c = b c a*sin(p0*c+p1)+sin(p2*b+p3)
I:mov  cl,2          ; {c b a}

H:fld    st1         ; {b c b a}              ; {c sin(p0*b+p1) c b a}
  fimul  word[bx]    ; {p0*b c b a}           ; {p2*c sin(p0*b+p1) c b a}
  ror  bx,4
  fiadd  word[bx]    ; {p0*b+p1 c b a}        ; {p2*c+p3 sin(p0*b+p1) c b a}
  fsin               ; {sin(p0*b+p1) c b a}   ; {sin(p2*c+p3) sin(p0*b+p1) c b a}
  ror  bx,4
  loop H
  fmul   st4         ; {a*sin(p2*c+p3) sin(p0*b+p1) c b a}
  faddp  st1,st0     ; {a*sin(p2*c+p3)+sin(p0*b+p1) c b a}
  ffree  st3         ; {d=a*sin(p2*c+p3)+sin(p0*b+p1) c b}  ; can preserve rest with two fxch

; [B]=max(d_i), [B+4]=max(-d_i) = -min(d_i)
; branchless min: mid = (a+b)/2; radius = abs(a-b)/2; max = mid+radius
  fld    st0
  fchs               ; {-d d . .}
L:fld    st1         ; {d -d d . .}                  ; {-d MAX -d d . .}
  fadd   dword[B+si] ; {d+MAX -d d . .}              ; {-d+MAX2 MAX -d d . .}
  fld    st2         ; {d d+MAX -d d . .}            ; {-d -d+MAX2 MAX -d d . .}
  fsub   dword[B+si] ; {d-MAX d+MAX -d d . .}        ; {-d-MAX2 -d+MAX2 MAX -d d . .}
  fabs               ; {abs(d-MAX) d+MAX -d d . .}   ; {abs(-d-MAX2) -d+MAX2 MAX -d d . .}
  faddp  st1,st0     ; {2*max(d,MAX) -d d . .}       ; {2*max(-d,MAX2) MAX -d d . .}
  fmul   dword[si-3] ; {MAX=max(d,MAX) -d d . .}     ; {MAX2=max(-d,MAX2) MAX -d d . .}
  fst    dword[B+si] ; {MAX -d d . .}                ; {-MIN=MAX2 MAX -d d . .}
  xor  si,4
  jnp  L

; normalize
  fadd   st1,st0     ; {-MIN MAX-MIN -d . . .}
  fsubrp st2,st0     ; {MAX-MIN d-MIN . . .}
  fdivp  st1,st0     ; {d(0..1)=(d-MIN)/(MAX-MIN) . . .}
  fimul  word[BIG]   ; {d(0..BIG) . . .}
  fadd   st0         ; {d(0..BIG*2) . . .}
  fisub  word[BIG]   ; {d(-BIG..BIG) . . .}
  fistp  word[es:di]
  scasw  ;di+=2

  ret

BIG  dw 32767
WIDTH: dw 160
B:

;// draws the next frame
;void draw(void)
;{
;  int i,j,k;
;  float sa = sin(T*SPEED), sb = sin(T*SPEED*1.4426950408889634),
;        ca = cos(T*SPEED), cb = cos(T*SPEED*1.4426950408889634);
;
;  blur(sa, sb);
;
;  generate();
;
;  for (k = 4; k < DRAW_POINTS; k++)
;  { unsigned mx, my;
;    float t, u = p[k], v = p[k-1], w = p[k-2];
;    t = u*ca + v*sa;
;    v = -u*sa + v*ca;
;    u = t*cb + w*sb;
;    w = -t*sb + w*cb;
;    t = PERSPMULY / (w+PERSPADD);
;
;    if ((my = v*t + HEIGHT/2) < HEIGHT-1)
;    { if ((mx = (PERSPMULX/PERSPMULY)*u*t + WIDTH/2) < WIDTH-1)
;      { unsigned adr = my*WIDTH+mx,
;                 c = DARK + 0.5*(256-DARK) - w*0.57735027*(256-DARK);
;        pset(adr + (k>>0&1) + (k>>0&2)*WIDTH/2, c, q[k-3], q[k-4]);
;        pset(adr + (k>>2&1) + (k>>2&2)*WIDTH/2, c, q[k-3], q[k-4]);
;        pset(adr + (k>>4&1) + (k>>4&2)*WIDTH/2, c, q[k-3], q[k-4]);
;      }
;    }
;  }
;
;  if (++frame >= FRAMES) restart=1, searches=0;
;}
