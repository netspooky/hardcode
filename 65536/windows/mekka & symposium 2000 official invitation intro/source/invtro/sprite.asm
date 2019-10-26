; ms2k invitation
;
; sprite stuff

; -------------------------------------------- includes and definitions -----

bits          32

; -------------------------------------------------- uninitialized data -----

section       .bss

struc         sprdata
  .sw           resd 1
  .dw           resd 1
  .size:
endstruc

sprdat        resb sprdata.size

extern        vScreen
extern        vPitch

; ---------------------------------------------------- initialized data -----

section       .data

extern        _background

; -------------------------------------------- code section starts here -----

section       .code

struc         sprite
  .w            resd 1
  .h            resd 1
  .data:
  .size:
endstruc

; ------------------------------------ putSprite: esi=spr, eax=x, ebx=y -----

global putSprite

putSprite:
  push        ebp
  mov         ebp, sprdat

  ; preclipping

  cmp         eax, 639
  jg          .gotoend
  cmp         ebx, 479
  jg          .gotoend
  mov         ecx, [esi]
  mov         [ebp+sprdata.sw], ecx
  neg         ecx
  cmp         eax, ecx
  jle         .gotoend
  mov         ecx, [esi+4]
  neg         ecx
  cmp         ebx, ecx
  jle         .gotoend

  jmp         short .isok

.gotoend:
  jmp         .end

.isok:
  lea         edi, [esi+8]

  ; clipping

  mov         ecx, [esi]
  cmp         eax, byte 0
  jnl         .noxclip1

  add         ecx, eax
  sub         edi, eax
  xor         eax, eax

.noxclip1:
  mov         edx, 639
  sub         edx, ecx
  cmp         eax, edx
  jng         .noxclip2

  mov         ecx, 640
  sub         ecx, eax

.noxclip2:
  dec         ecx
  mov         [ebp+sprdata.dw], ecx

  mov         ecx, [esi+4]
  cmp         ebx, byte 0
  jnl         .noyclip1

  add         ecx, ebx
  mov         edx, [ebp+sprdata.dw]
  imul        ebx, edx
  add         edi, ebx
  xor         ebx, ebx

.noyclip1:
  mov         edx, 479
  sub         edx, ecx
  cmp         ebx, edx
  jng         .noyclip2

  mov         ecx, 480
  sub         ecx, ebx

.noyclip2:
  ; zeichnen

  xchg        esi, edi
  mov         edi, [vPitch]
  imul        edi, ebx
  add         edi, eax
  add         edi, [vScreen]
  xchg        edx, ecx

.yloop:
  mov         ecx, [ebp+sprdata.dw]

.xloop:
  mov         al, [esi+ecx]
  cmp         al, 2
  je          .dont
  mov         [edi+ecx], al
 .dont:
  dec         ecx
  jns         .xloop

  add         esi, [ebp+sprdata.sw]
  add         edi, [vPitch]
  dec         edx
  jnz         .yloop

.end:
  pop         ebp
  ret

; ----------------------- putText: esi=spr, eax=x, ebx=y, ecx=sy, edx=h -----

global putText

putText:
  push        ebp
  mov         ebp, sprdat

  push        edx
  push        ecx

  ; preclipping

  cmp         eax, 639
  jg          .gotoend
  cmp         ebx, 479
  jg          .gotoend
  mov         ecx, [esi]
  mov         [ebp+sprdata.sw], ecx
  neg         ecx
  cmp         eax, ecx
  jle         .gotoend
  neg         edx
  cmp         ebx, edx
  jle         .gotoend

  jmp         short .isok

.gotoend:
  jmp         .end

.isok:
  lea         edi, [esi+8]

  pop         ecx
  mov         edx, [ebp+sprdata.sw]
  imul        ecx, edx
  add         edi, ecx

  ; clipping

  mov         ecx, [esi]
  cmp         eax, byte 0
  jnl         .noxclip1

  add         ecx, eax
  sub         edi, eax
  xor         eax, eax

.noxclip1:
  mov         edx, 639
  sub         edx, ecx
  cmp         eax, edx
  jng         .noxclip2

  mov         ecx, 640
  sub         ecx, eax

.noxclip2:
  dec         ecx
  mov         [ebp+sprdata.dw], ecx

  pop         edx
  mov         ecx, [esi+4]
  cmp         ecx, edx
  jb          .shsmaller
  mov         ecx, edx

.shsmaller:
  cmp         ebx, byte 0
  jnl         .noyclip1

  add         ecx, ebx
  mov         edx, [ebp+sprdata.dw]
  imul        ebx, edx
  add         edi, ebx
  xor         ebx, ebx

.noyclip1:
  mov         edx, 479
  sub         edx, ecx
  cmp         ebx, edx
  jng         .noyclip2

  mov         ecx, 480
  sub         ecx, ebx

.noyclip2:
  ; zeichnen

  xchg        esi, edi
  mov         edi, [vPitch]
  imul        edi, ebx
  add         edi, eax
  add         edi, [vScreen]
  xchg        edx, ecx

.yloop:
  mov         ecx, [ebp+sprdata.dw]
  shr         ecx, 2
  rep         movsd

  mov         ecx, [ebp+sprdata.dw]
  and         ecx, 3
  rep         movsb

  add         esi, [ebp+sprdata.sw]
  add         edi, [vPitch]
  sub         edi, [ebp+sprdata.dw]
  dec         edx
  jnz         .yloop

.end:
  pop         ebp
  ret

; ------------------------------------------------------- putBackground -----

global putBackground

putBackground:
  mov         esi, _background
  mov         edi, [vScreen]
  mov         edx, 480
.yloop:
  xor         ecx, ecx
  mov         cl, 79
.xloop:
  mov         eax, [esi+ecx*8]
  mov         ebx, [esi+ecx*8+4]
  mov         [edi+ecx*8], eax
  mov         [edi+ecx*8+4], ebx
  dec         ecx
  jns         .xloop
  add         esi, 640
  add         edi, [vPitch]
  dec         edx
  jnz         .yloop
  ret
