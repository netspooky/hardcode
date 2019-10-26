; ms2k invitation
;
; bitmap font stuff

; -------------------------------------------- includes and definitions -----

bits          32

; -------------------------------------------------- uninitialized data -----

section       .bss

struc           blitData
  .fpitch         resd 1
  .opitch         resd 1
  .pos            resd 1
  .height         resd 1
  .cwidth         resd 1
  .bmask          resb 1
  .size:
endstruc

bdata         resb blitData.size

; -------------------------------------------- code section starts here -----

section       .code

struc         sprite
  .w            resd 1
  .h            resd 1
  .data:
  .size:
endstruc

struc         charInfo
  .loc          resd 1
  .prekern      resb 1
  .cellwidth    resb 1
  .totalwidth   resb 1
  .size:
endstruc

struc         bmapFont
  .map          resd 1
  .first        resb 1
  .count        resb 1
  .unused       resb 1
  .height       resb 1
  .width        resd 1
  .charinfo:
  .size:
endstruc

; ---------------- fontBlitChar. edi=out, esi=font, al=ch, ebx=x, ecx=y -----

global fontBlitChar
fontBlitChar:
  sub         al, [esi+bmapFont.first]
  js          .chclip

  cmp         al, [esi+bmapFont.count]
  jb          .noclip

.chclip:
  mov         al, [esi+bmapFont.unused]

.noclip:
  movzx       eax, al

  xor         edx, edx
  mov         dl, 7                    
  mul         edx
  lea         eax, [eax+esi+bmapFont.charinfo]

  mov         edx, [edi+sprite.w]
  mov         [bdata+blitData.opitch], edx
  imul        ecx, edx

  lea         edi, [edi+ebx+sprite.data]
  movzx       edx, byte [eax+charInfo.prekern]
  add         edi, ecx
  add         edi, edx

  mov         edx, bdata

  mov         ecx, [eax+charInfo.loc]
  mov         ebx, ecx
  lea         ebx, [ebx+7]
  shr         ebx, 3
  add         ebx, [esi]
  mov         [edx+blitData.pos], ebx

  xor         ebx, ebx
  inc         ebx
  and         ecx, 7
  xor         cl, 7
  shl         bl, cl
  mov         [edx+blitData.bmask], bl

  mov         ebx, [esi+bmapFont.width]
  lea         ebx, [ebx+7]
  shr         ebx, 3
  mov         [edx+blitData.fpitch], ebx

  movzx       ebx, byte [eax+charInfo.cellwidth]
  mov         [edx+blitData.cwidth], ebx
  sub         [edx+blitData.opitch], ebx

  movzx       ebx, byte [esi+bmapFont.height]
  mov         [edx+blitData.height], ebx

.yloop:
  mov         ecx, [edx+blitData.cwidth]
  mov         esi, [edx+blitData.pos]
  mov         bl, [edx+blitData.bmask]

.xloop:
  mov         al, [esi]
  test        al, bl
  jz          .noset

  mov         byte [edi], 6

.noset:
  inc         edi
  ror         bl, 1
  jnc         .nowrap

  inc         esi

.nowrap:
  loop        .xloop

  add         edi, [edx+blitData.opitch]
  mov         eax, [edx+blitData.fpitch]
  add         [edx+blitData.pos], eax

  dec         dword [edx+blitData.height]
  jnz         .yloop

  ret

; --------- fontBlitString. edi=out, esi=font, edx=string, ebx=x, ecx=y -----

global fontBlitString
fontBlitString:
  mov         al, [edx]
  inc         edx
  or          al, al
  jz          .end

  pushad
  call        fontBlitChar
  popad

  call        fontCharWidth
  add         ebx, eax

  jmp         short fontBlitString

.end:
  ret

; ------------------------------------ fontCharWidth. esi=font, al=char -----

global fontCharWidth
fontCharWidth:
  push        edx

  sub         al, [esi+bmapFont.first]
  js          .chclip

  cmp         al, [esi+bmapFont.count]
  jb          .noclip

.chclip:
  mov         al, [esi+bmapFont.unused]

.noclip:
  movzx       eax, al
  xor         edx, edx
  mov         dl, 7
  mul         edx

  lea         eax, [eax+esi+bmapFont.charinfo]

  movzx       edx, byte [eax+charInfo.prekern]
  movzx       eax, byte [eax+charInfo.totalwidth]
  add         eax, edx

  pop         edx
  ret

; ------------------------------- fontStringWidth. esi=font, edx=string -----

global fontStringWidth
fontStringWidth:
  xor         ebx, ebx

.lp:
  mov         al, [edx]
  inc         edx
  or          al, al
  jz          .end

  call        fontCharWidth
  add         ebx, eax
  jmp         short .lp

.end:
  xchg        ebx, eax

  ret
