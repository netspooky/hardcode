; ms2k invitation
;
; particle sphere

; ---------------------------------------------------- initialized data -----

bits          32

section       .data

global        flashtime

const:
  ._spradius    dd 240.0
  ._spxcenter   dd 384.0
  ._spycenter   dd 304.0
  ._63          dd 63.0
  ._127         dd 127.0
  ._192         dd 192.0
  ._256         dd 256.0
  ._1by2        dd 0.5
  ._1by4        dd 0.25
  ._1by8        dd 0.125
  ._1by65536    dd 0.0000152587890625
  ._tf          dd 0.07
  ._zoffs       dd 420.0
  ._afactor     dd 0.00049

%define       rc(a)     [ebp+a-const]

flashtime     dd -256

; -------------------------------------------------- uninitialized data -----

section       .bss

orgpal        resd 256
palette       resd 256

points        resd 4096
sprites       resb 103680              ; exakt. jawoll.
offsets       resd 64
relmove       resd 64
yotab         resd 608

vbuf          resb 466944              ; (640+128)*(480+128)

struc         data
  .i            resd 1
  .ic           resd 1
  .ih           resd 1
  .size:
endstruc

psphdata      resb data.size
mySeed        resd 1
temp          resd 1

extern        vScreen
extern        vPitch

; -------------------------------------------- code section starts here -----

section       .code

global        psphereInit
global        psphereRender

; ----------------------------------------------------- initialisierung -----

psphereInit:
  push     ebp
  mov      ebp, const

  ; offtab berechnen

  mov      ecx, 608
  xor      eax, eax
  mov      edi, yotab
.offlp:
  stosd
  add      eax, 768
  loop     .offlp

  ; palette berechnen

  xor      ecx, ecx
  mov      edi, orgpal

.calcpal:
  mov      bl, cl
  shl      bl, 1
  sbb      dl, dl
  or       bl, dl

  mov      al, bl
  shl      al, 1
  sbb      dl, dl
  or       al, dl

  shl      eax, 16
  mov      ah, bl
  mov      al, bl
  shl      eax, 8
  bswap    eax

  stosd
  inc      cl
  jnz      .calcpal

  ; punkte berechnen

  finit
  xor      edx, edx
  mov      dh, 4
  mov      edi, points
  mov      ebx, mySeed

.calcpoints:
  xor      ecx, ecx
  mov      cl, 3

.genrandom:
  mov      eax, 15625
  push     edx
  imul     dword [ebx]
  pop      edx
  inc      eax
  mov      [ebx], eax

  fild     word [ebx]
  fmul     dword rc(const._1by65536)
  loop     .genrandom

  fld      st0                         ; z z y x
  fmul     st0                         ; zz z y x
  fld      st2                         ; y zz z y x
  fmul     st0                         ; yy zz z y x
  fld      st4                         ; x yy zz z y x
  fmul     st0                         ; xx yy zz z y x
  faddp    st1, st0                    ; xx+yy zz z y x
  faddp    st1, st0                    ; xx+yy+zz z y x
  fsqrt                                ; len z y x
  fld      dword rc(const._192)        ; 192 len z y x
  fdivrp   st1, st0                    ; 192/len z y x
  fxch     st3                         ; x z y 192/len
  fmul     st3                         ; xn z y 192/len
  fxch     st2                         ; y z xn 192/len
  fmul     st3                         ; yn z xn 192/len
  fxch     st3                         ; 192/len z xn yn
  fmulp    st1, st0                    ; zn xn yn
  fstp     dword [edi+8]               ; xn yn
  fstp     dword [edi]                 ; yn
  fmul     dword rc(const._spradius)   ; 120*yn
  fstp     dword [edi+4]               ; empty

  lea      edi, [edi+16]
  dec      edx
  jnz      .calcpoints

  ; sprites berechnen (argh)

  mov      edi, sprites
  xor      esi, esi

.calcsprites:
  mov      edx, psphdata
  mov      [offsets+esi*4], edi

  lea      eax, [esi+1]
  mov      [edx+data.ic], eax
  add      al, 15
  and      al, ~15
  mov      [edx+data.i], eax

  shr      eax, 1
  mov      ebx, [edx+data.ic]
  shr      ebx, 1
  mov      ebx, [yotab+ebx*4]
  add      ebx, eax
  mov      [relmove+esi*4], ebx

  finit

  mov      eax, [edx+data.i]
  shr      eax, 1
  mov      [edx+data.ih], eax
  fild     dword [edx+data.ih]         ; ih
  mov      eax, [edx+data.ic]
  shr      eax, 1
  mov      [edx+data.ih], eax
  fild     dword [edx+data.ih]         ; ich ih
  fild     dword [edx+data.ic]         ; dp ich ih
  fmul     dword rc(const._1by2)       ; dp ich ih
  fld1                                 ; 1 dp ich ih
  fdivrp   st1, st0                    ; df ich ih

  xor      edx, edx
.yloop:
  xor      ecx, ecx
.xloop:
  push     ecx
  fild     dword [esp]                 ; p df ich ih
  pop      ecx
  fsub     st3                         ; p-ih df ich ih
  fmul     st1                         ; x df ich ih
  fmul     st0                         ; xx df ich ih
  push     edx
  fild     dword [esp]                 ; n xx df ich ih
  pop      edx
  fsub     st3                         ; n-ich xx df ich ih
  fmul     st2                         ; y xx df ich ih
  fmul     st0                         ; yy xx df ich ih
  faddp    st1, st0                    ; xx+yy df ich ih
  fsqrt                                ; len df ich ih
  fld1                                 ; 1 len df ich ih
  fsubrp   st1, st0                    ; z df ich ih
  fimul    dword [psphdata+data.ic]    ; t df ich ih
  fmul     dword rc(const._1by4)
  fistp    dword [temp]                ; ich df ih
  mov      eax, [temp]
  or       eax, eax
  jns      .npx

  xor      al, al

.npx:
  stosb
  inc      ecx
  cmp      ecx, [psphdata+data.i]
  jne      .xloop
  inc      edx
  cmp      edx, [psphdata+data.ic]
  jne      .yloop

  inc      esi
  cmp      esi, byte 64
  je       .end
  jmp      .calcsprites

.end:
  pop      ebp

  finit
  ret

; ------------------------------------------------------------ zeichnen -----

psphereRender:
  push     ebp
  mov      ebp, const
  finit

  push     eax

  mov      edi, vbuf
  pxor     mm0, mm0
  mov      ecx, 58367

.clearlp:
  movq     [edi+ecx*8], mm0
  movq     [edi+ecx*8+8], mm0
  movq     [edi+ecx*8+16], mm0
  movq     [edi+ecx*8+24], mm0
  sub      ecx, 4
  jns      .clearlp

  emms

  ; palette updaten (fuer flashes)

  mov      eax, [flashtime]
  mov      ebx, 256
  cmp      eax, ebx
  jb       .fadeok
  mov      eax, ebx

.fadeok:
  mov      esi, orgpal
  mov      edi, palette
  mov      ecx, 1023
  mov      ebx, eax

.fade:
  xor      edx, edx
  dec      dl
  movzx    eax, byte [esi+ecx]
  sub      eax, edx
  imul     ebx
  sar      eax, 8
  xor      edx, edx
  dec      dl
  add      edx, eax
  mov      [edi+ecx], dl
  dec      ecx
  jns      .fade

  pop      eax
  mov      edx, temp
  mov      [edx], eax

  fild     dword [edx]                 ; time
  fmul     dword rc(const._tf)         ; tf
  fmul     dword rc(const._1by2)       ; .5*tf
  fsubr    dword rc(const._zoffs)      ; zoffs

  fild     dword [edx]                 ; time zoffs
  fmul     dword rc(const._afactor)    ; angle zofss
  fsincos                              ; ca sa zoffs

  xor      ecx, ecx
  mov      ch, 4
  mov      esi, points

.pointloop:
  fld      dword [esi]                 ; px ca sa zoffs
  fmul     st1                         ; pxca ca sa zoffs
  fld      dword [esi+8]               ; pz pxca ca sa zoffs
  fmul     st3                         ; pzsa pxca ca sa zoffs
  faddp    st1, st0                    ; pxca+pzsa ca sa zoffs
  fmul     dword rc(const._spradius)   ; x ca sa zoffs

  fld      dword [esi]                 ; px x ca sa zoffs
  fmul     st3                         ; pxsa x ca sa zoffs
  fld      dword [esi+8]               ; pz pxsa x ca sa zoffs
  fmul     st3                         ; pzca pxsa x ca sa zoffs
  fsubrp   st1, st0                    ; pzca-pxsa x ca sa zoffs
  fadd     st4                         ; z x ca sa zoffs

  fadd     dword rc(const._256)        ; z' x ca sa zoffs
  fld      st0                         ; z' z' x ca sa zoffs
  fld1                                 ; 1 z' z' x ca sa zoffs
  fdivrp   st1, st0                    ; iz z' x ca sa zoffs
  fxch     st2                         ; x z' iz ca sa zoffs
  fmul     st2                         ; xt z' iz ca sa zoffs
  fadd     dword rc(const._spxcenter)  ; xp z' iz ca sa zoffs
  fxch     st2                         ; iz z' xp ca sa zoffs
  fmul     dword [esi+4]               ; yt z' xp ca sa zoffs
  fadd     dword rc(const._spycenter)  ; yp z' xp ca sa zoffs
  push     eax
  push     eax
  fistp    dword [esp]                 ; z' xp ca sa zoffs
  fxch     st1                         ; xp z' ca sa zoffs
  fistp    dword [esp+4]               ; z' ca sa zoffs
  pop      ebx                         ; =y
  pop      eax                         ; =x

  fmul     dword rc(const._1by8)       ; z' ca sa zoffs
  fsubr    dword rc(const._63)         ; c ca sa zoffs
  push     eax
  fistp    dword [esp]                 ; ca sa zoffs
  pop      edx

  or       edx, edx
  jns      .blalabel
  jmp      .nextpoint

.blalabel:
  cmp      edx, byte 63
  jbe      .cok
  jmp      .nextpoint

.cok:
  push     ecx
  xor      ecx, ecx
  mov      cl, 32

  cmp      eax, ecx
  jl       .nextpointb
  cmp      ebx, ecx
  jl       .nextpointb
  cmp      eax, 736
  jge      .nextpointb
  cmp      ebx, 576
  jge      .nextpointb
  jmp      short .auaaa

.nextpointb:
  pop      ecx
  jmp      short .nextpoint

.auaaa:
  push     esi

  mov      esi, [offsets+edx*4]
  mov      edi, [yotab+ebx*4]
  lea      edi, [edi+eax+vbuf]
  sub      edi, [relmove+edx*4]
  push     edx
  add      dl, 16
  shr      edx, 3
  and      dl, ~1
  lea      esi, [esi+edx*8]
  lea      edi, [edi+edx*8]

.drawyloop:
  mov      ecx, edx
  neg      ecx

  jmp      short .drawxloop
  align    32

.drawxloop:
  mov       eax, [esi+ecx*8]
  mov       ebx, [esi+ecx*8+4]
  add       eax, [edi+ecx*8]
  add       ebx, [edi+ecx*8+4]
  mov       [edi+ecx*8], eax
  mov       [edi+ecx*8+4], ebx
  inc       ecx
  jnz       .drawxloop

  add       edi, 768
  lea       esi, [esi+edx*8]
  dec       dword [esp]
  jns       .drawyloop

  pop       edx
  pop       esi
  pop       ecx
  
.nextpoint:
  add      esi, byte 16
 
  dec      ecx
  jz       .blit
  jmp      .pointloop

.blit:
  mov      esi, vbuf+(64*768)+64
  mov      edi, [vScreen]
  mov      edx, palette
  mov      dword [temp], 480

.blitylp:
  mov      ecx, 319

.blitxlp:
  movzx    eax, byte [esi+ecx*2]
  movzx    ebx, byte [esi+ecx*2+1]
  mov      eax, [edx+eax*4]
  mov      ebx, [edx+ebx*4]
  mov      [edi+ecx*8], eax
  mov      [edi+ecx*8+4], ebx
  dec      ecx
  jns      .blitxlp

  add      esi, 768
  add      edi, [vPitch]
  dec      dword [temp]
  jnz      .blitylp
  
.end:
  pop      ebp
  finit
  ret
