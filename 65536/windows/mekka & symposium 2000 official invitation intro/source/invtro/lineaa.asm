SECTION .bss

PITCH   equ (320)

struc line
        .x1:      resd 1
        .y1:      resd 1
        .x2:      resd 1
        .y2:      resd 1
        .size:
endstruc

struc vector
  .x            resd 1
  .y            resd 1
  .z            resd 1
  .size:
endstruc

struc triangle
  .pt0          resb vector.size
  .pt1          resb vector.size
  .pt2          resb vector.size
  .size:
endstruc

struc object
  .npoly        resd 1
  .poly         resd 1
  .size:
endstruc


align 32

ldata:  resb    line.size
RopData resd 1

SECTION .data

align 32

valmask:  db  63,  63,  63,  63
valmask2: db 192, 192, 192, 192

onehalf:      dd    0.5
consts:       dd    0.0
              dd    1.0
              dd   -1.0
seed:         dd    01000000000100010000010000000110b
              dd    00001000000000010010000010000000b
              dd    01010000010000000100000010000100b
              dd    10000000001010000000100000001000b
              dd    10000100000000101111111111111111b


SECTION _TEXT ; ------------------------------------------------------------

SECTION .code

global lineaa8sub
global sDiv64Save       ; eax = (eax<<16)/ecx, trashes edx
global lineclip8
global gensphere
global RectRopFill
global mymemcpy
global bsearch32
global sort32
global equalvec

extern _engine_xmin
extern _engine_ymin
extern _engine_xmax
extern _engine_ymax
extern myfree_
extern mymalloc_
extern _SurfacePtr
extern _SurfacePitch


        align 16

sDiv64Save:
        cmp     ecx, 10000h
        jle     .special
        mov     edx,eax
        shl     eax,16
        sar     edx,16
        idiv    ecx
        ret
.special:
        push    ebx
        xor     edx, edx
        mov     ebx, eax
        mov     eax, 40000000h
        idiv    ecx
        imul    ebx
        pop     ebx
        shrd    eax, edx, 14
        ret

        align 16

lineaa8sub:
        pushad
        movd    mm7, [valmask]
        movd    mm6, [valmask2]
        mov     ebp, ldata
        push    esi
        push    edi
        mov     [ebp + line.x1], eax
        mov     [ebp + line.y1], ebx
        mov     [ebp + line.x2], ecx
        mov     [ebp + line.y2], edx
        sub     ecx, eax
        sub     edx, ebx
        mov     edi, ecx
        mov     esi, edx
        sar     ecx, 31
        push    ebp
        sar     edx, 31
        mov     ebp, 1
        xor     edi, ecx
        xor     esi, edx
        and     ecx, ebp
        and     edx, ebp
        add     ecx, edi
        add     edx, esi
        pop     ebp
        pop     edi
        cmp     ecx, edx
        pop     esi
        jb      near .MajorY
; -----------------------------------------------
        cmp     eax, [ebp + line.x2]
        je      near .EndeX
        call    .Swap
        mov     ecx, [ebp + line.x2]
        mov     eax, [ebp + line.y2]
        sub     ecx, [ebp + line.x1]
        sub     eax, [ebp + line.y1]
        call    sDiv64Save
        push    eax
        mov     edx, 0ffffh
        mov     eax, [ebp + line.x1]
        mov     ebx, [ebp + line.x2]
        add     eax, edx
        add     ebx, edx
        shr     eax, 16
        mov     ecx, [ebp + line.y1]
        shr     ebx, 16
        lea     edi, [edi + eax]
        sub     ebx, eax
        mov     edx, [ebp + line.x1]
        pop     ebp
        jz      .EndeX
        shl     eax, 16
        sub     eax, edx
        imul    ebp
        shrd    eax, edx, 16
        add     ecx, eax
        align   8
.NextX:
        mov     edx, ecx
        mov     eax, ecx
        push    ecx
        and     eax, 0ff00h
        shr     edx, 16
        shr     eax, 8
        mov     ecx, 255
        imul    edx, PITCH
        sub     ecx, eax
        movd    mm2, [esi+eax*4]
        movd    mm3, [esi+ecx*4]
        movd    mm0, [edi+edx]
        movd    mm1, [edi+edx+PITCH]
        movq    mm4, mm0
        movq    mm5, mm1

        pand    mm0, mm7
        pand    mm1, mm7
        pand    mm4, mm6
        pand    mm5, mm6

        psubusb mm0, mm3
        psubusb mm1, mm2
        por     mm0, mm4
        por     mm1, mm5
        push    ebx
        movd    ecx, mm0
        movd    ebx, mm1
        mov     [edi+edx],       cl
        mov     [edi+edx+PITCH], bl
        inc     edi
        pop     ebx
        pop     ecx
        dec     ebx
        lea     ecx, [ecx+ebp]
        jnz     .NextX
.EndeX:
        emms
        popad
        ret
; -----------------------------------------------
.MajorY:
        cmp     ebx, [ebp + line.y2]
        je      .EndeX
        call    .Swap
        mov     ecx, [ebp + line.y2]
        mov     eax, [ebp + line.x2]
        sub     ecx, [ebp + line.y1]
        sub     eax, [ebp + line.x1]
        call    sDiv64Save
        push    eax
        mov     edx, 0ffffh
        mov     eax, [ebp + line.y1]
        mov     ebx, [ebp + line.y2]
        add     eax, edx
        add     ebx, edx
        shr     eax, 16
        mov     ecx, [ebp + line.x1]
        shr     ebx, 16
        push    eax
        imul    eax, PITCH
        lea     edi, [edi + eax]
        pop     eax
        sub     ebx, eax
        mov     edx, [ebp + line.y1]
        pop     ebp
        jz      .EndeY
        shl     eax, 16
        sub     eax, edx
        imul    ebp
        shrd    eax, edx, 16
        add     ecx, eax
        align   8
.NextY:
        mov     eax, ecx
        mov     edx, ecx
        and     eax, 0ff00h
        push    ecx
        shr     edx, 16
        mov     ecx, 255
        shr     eax, 8
        movd    mm0, [edi+edx]
        movd    mm1, [edi+edx+1]
        sub     ecx, eax
        movd    mm2, [esi+eax*4]
        movd    mm3, [esi+ecx*4]
        movq    mm4, mm0
        movq    mm5, mm1

        pand    mm0, mm7
        pand    mm1, mm7
        pand    mm4, mm6
        pand    mm5, mm6

        psubusb mm0, mm3
        psubusb mm1, mm2
        por     mm0, mm4
        por     mm1, mm5

        push    ebx
        movd    ebx, mm0
        movd    ecx, mm1
        mov     [edi+edx],   bl
        mov     [edi+edx+1], cl
        pop     ebx
        pop     ecx
        add     edi, PITCH
        add     ecx, ebp
        dec     ebx
        jnz     .NextY
.EndeY:
        emms
        popad
        ret
        align  8
.Swap:
        jle     .NoSwap
        movq    mm0, [ebp + line.x1]
        movq    mm1, [ebp + line.x2]
        movq    [ebp + line.x2], mm0
        movq    [ebp + line.x1], mm1
.NoSwap:
        ret

        align 16

;---------------------------------------------------------------------------

lineclip8:
        pushad
        mov     [ldata],   esi
        mov     [ldata+4], edi

        align 16

.nochmal:
        xor     esi, esi
        xor     ebp, ebp
        push    eax
        push    ebx
        push    ecx
        push    edx

        push    edx
        mov     edx, [_engine_xmin]

        mov     edi, eax
        sub     edi, edx
        add     edi, edi
        adc     esi, esi
        mov     edi, ecx
        sub     edi, edx
        add     edi, edi
        adc     ebp, ebp

        mov     edx, [_engine_xmax]
        mov     edi, edx
        sub     edi, eax
        add     edi, edi
        adc     esi, esi
        mov     edi, edx
        sub     edi, ecx
        add     edi, edi
        adc     ebp, ebp

        pop     edx

        mov     eax, [_engine_ymin]
        mov     edi, ebx
        sub     edi, eax
        add     edi, edi
        adc     esi, esi
        mov     edi, edx
        sub     edi, eax
        add     edi, edi
        adc     ebp, ebp

        mov     eax, [_engine_ymax]
        mov     edi, eax
        sub     edi, ebx
        add     edi, edi
        adc     esi, esi
        sub     eax, edx
        add     eax, eax
        adc     ebp, ebp

        pop     edx
        pop     ecx
        pop     ebx
        pop     eax

        test    esi, ebp
        mov     edi, esi
        jnz     near .Ende

        or      edi, ebp
        jz      .NoSwap

.clip0:
        test    esi, esi
        jz      .Swap

        shr     esi, 1
        jc      near .ClipBottom
        shr     esi, 1
        jc      near .ClipTop
        shr     esi, 1
        jc      near .ClipRight
.ClipLeft:
        mov     edi, edx        ; save y2
        mov     ebp, [_engine_xmin]
        mov     esi, ecx
        sub     eax, ebp        ; ca
        sub     esi, ebp        ; cb
        mov     edx, eax
        sub     edx, esi
        mov     esi, edx        ; ca-cb
.Xclip:
        mov     edx, eax
        sar     edx, 16
        shl     eax, 16
        idiv    esi
        mov     esi, eax
        mov     eax, edi
        sub     eax, ebx
        imul    esi
        add     eax, 0ffffh
        shrd    eax, edx, 16
        add     ebx, eax        ; new y1
        mov     eax, ebp        ; new x1
        mov     edx, edi
        jmp     .nochmal

        align 16
.Swap:
        test    ebp, ebp
        jz      .NoSwap
        xchg    esi,  ebp
        xchg    eax,  ecx
        xchg    ebx,  edx
        jmp     short .clip0

.NoSwap:
        mov     esi, [ldata],
        mov     edi, [ldata+4],
        call    lineaa8sub
.Ende:
        popad
        ret

        align 16
.ClipBottom:
        mov     ebp, [_engine_ymax]
        mov     edi, eax      ; save x1
        push    edx           ; save y2
        neg     ebx           ; -y1
        neg     edx           ; -y2
        add     ebx, ebp      ; ca
        add     edx, ebp      ; cb
        jmp     short .ClipY

        align 16
.ClipRight:
        mov     ebp, [_engine_xmax]
        mov     edi, ecx
        mov     esi, eax
        sub     edi, ebp       ; cb
        sub     esi, ebp       ; ca
        mov     eax, esi       ; ca
        sub     esi, edi       ; ca-cb
        mov     edi, edx       ; save y2
        jmp     near .Xclip

        align 16
.ClipTop:
        mov     ebp, [_engine_ymin]
        mov     edi, eax      ; save x1
        push    edx           ; save y2
        sub     ebx, ebp      ; ca
        sub     edx, ebp      ; cb
.ClipY:
        mov     eax, ebx
        sub     ebx, edx      ; ca-cb
        mov     edx, eax
        sar     edx, 16
        shl     eax, 16
        idiv    ebx
        mov     esi, eax
        mov     eax, ecx
        sub     eax, edi
        imul    esi
        add     eax, 0ffffh
        shrd    eax, edx,16
        add     eax, edi        ; new x1
        pop     edx             ; restore y2
        mov     ebx, ebp        ; new y1
        jmp     .nochmal

; ---------------------------------------------------------------------------

mymymalloc:
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi
        push    ebp
        call    mymalloc_
        pop     ebp
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        ret

mymyfree:
        pushad
        call    myfree_
        popad
        ret


gensphere:
; -------------------------------------------------------
; generates a tesselated sphere (simple object structure)
; -------------------------------------------------------
; input:  ecx = subdivision level
; output: eax = ret-object (will be alloced)
; -------------------------------------------------------
        enter   3*vector.size,0                 ; wow! ich hab enter geschnallt!
        push    ecx
        mov     edx, mymymalloc
        push    edx
        xor     eax, eax
        mov     al, 8
        mov     ebx, eax
        call    edx
        mov     ecx, eax
        mov     [ecx+object.npoly], ebx
        mov     eax, 8*triangle.size
        call    edx
        mov     edi, eax
        mov     [ecx+object.poly], eax
        cdq
        mov     esi, seed
        lea     edx, [esi-6]
        push    ecx

 .OctNextByte:
        lodsd
        xchg    eax, ebx
        mov     cl,  16

.OctUnpack:
        xor     eax, eax
        add     ebx, ebx
        adc     eax, eax
        add     ebx, ebx
        adc     eax, eax
        cmp     al,  3
        je      .OctEnde
        mov     eax,  [eax*4 + consts]
        stosd
        dec     cl
        jnz     .OctUnpack
        jmp     short .OctNextByte
.OctEnde:
        pop     esi     ; ptr to object
        pop     ebx     ; ptr to mymalloc
        pop     ecx     ; gen level
        jecxz   .Quit

.NextLevel:
        ; alloc new object:
        xor     eax, eax
        cdq
        mov     al, object.size
        mov     dl, triangle.size
        call    ebx
        mov     edi, eax                        ; the new object ptr..
        mov     eax, [esi + object.npoly]
        shl     eax, 2
        push    edi
        stosd
        mul     edx
        call    ebx
        stosd
        pop     edi

        pushad
        ; generate new polygons..
        mov     ecx, [esi + object.npoly]       ; old poly count
        mov     esi, [esi + object.poly]        ; old poly ptr
        mov     edi, [edi + object.poly]        ; new poly ptr
.NextTriangle:
        push    ecx
        ; generate normalized polygon midpoints.
        mov     ecx, .normmidpoint
        mov     ebx, ebp
        lea     eax, [esi + 0 * vector.size]
        lea     edx, [esi + 2 * vector.size]
        push    edx
        call    ecx
        lea     edx, [esi + 1 * vector.size]
        call    ecx
        pop     eax
        call    ecx

        mov     eax, esi
        mov     edx, .copyvec
        ; generate 4 new triangles
        lea     ebx, [ebp - 2*vector.size]
        lea     ecx, [ebp - 1*vector.size]
        push    ebx
        push    ecx
        call    edx
        mov     esi, ebx
        lea     ebx, [eax + 1*vector.size]
        lea     ecx, [ebp - 3*vector.size]
        call    edx
        pop     esi
        pop     ebx
        push    esi
        call    edx
        pop     esi
        mov     ebx, ecx
        lea     ecx, [eax + 2*vector.size]
        call    edx
        ; esi points to next src-poly
        ; edi points to next dest-poly
        pop     ecx
        loop    .NextTriangle
        popad
        ; myfree temporary object
        mov     edx, mymyfree
        mov     eax, [esi + object.poly]
        call    edx
        mov     eax, esi
        call    edx
        ; make old object the new one
        mov     esi, edi
        loop    .NextLevel
.Quit:
        mov     eax, esi
        leave
        ret

.normmidpoint:
        lea     ebx,  [ebx-vector.size]
        fld     dword [onehalf]
        fld     dword [eax + vector.x]
        fadd    dword [edx + vector.x]
        fmul    st1
        fld     dword [eax + vector.y]
        fadd    dword [edx + vector.y]
        fmul    st2
        fld     dword [eax + vector.z]
        fadd    dword [edx + vector.z]
        fmulp   st3, st0
        fld     st0
        fmul    st0
        fld     st2
        fmul    st0
        faddp   st1
        fld     st3
        fmul    st0
        faddp   st1
        fsqrt
        fld1
        fdivrp  st1
        fmul    st1, st0
        fmul    st2, st0
        fmulp   st3, st0
        fstp    dword [ebx + vector.y]
        fstp    dword [ebx + vector.x]
        fstp    dword [ebx + vector.z]
        ret

.copyvec:
        movsd
        movsd
        movsd
        mov     esi, ebx
        movsd
        movsd
        movsd
        mov     esi, ecx
        movsd
        movsd
        movsd
        ret

; -------------------------------------------------------

%macro cmovcc 3
          j%-1 %%skip
          mov %2, %3
%%skip:
%endmacro




ClampSwap:
        xor     edi, edi
        cmp     eax, edi
        cmovcc l, eax, edi
        cmp     ebx, edi
        cmovcc l,   ebx, edi
        cmp     ecx, edi
        cmovcc l,   ecx, edi
        cmp     edx, edi
        cmovcc l,   edx, edi
        mov     edi, 240
        cmp     ebx, edi
        cmovcc g,   ebx, edi
        cmp     edx, edi
        cmovcc g,   edx, edi
        mov     edi, 320
        cmp     eax, edi
        cmovcc g,   eax, edi
        cmp     ecx, edi
        cmovcc g,   ecx, edi

        cmp     eax, ecx
        jl      .NoSwapX
        xchg    eax, ecx
.NoSwapX:
        cmp     ebx, edx
        jl      .NoSwapY
        xchg    ebx, edx
.NoSwapY:
        ret


RectRopFill:
        pushad
        mov     [RopData], esi
        call    ClampSwap
        cmp     eax, ecx
        je      near .Ende
        cmp     ebx, edx
        je      near .Ende

        movd    mm1, [RopData]
        mov     esi, ebx
        mov     ebp, [_SurfacePitch]
        mov     edi, [_SurfacePtr]
        imul    esi, ebp
        punpcklbw mm1, mm1
        add     edi, esi
        punpcklbw mm1, mm1
        add     edi, eax
        punpcklbw mm1, mm1
        sub     edx, ebx        ; y counter
        sub     ecx, eax        ; x counter
        and     eax, 3          ; unaligned count

.NextLine:
        push    edi
        push    ecx
        push    eax
        mov     ebx, [RopData]

        cmp     eax, ecx
        cmovcc g,   eax, ecx
        test    eax, eax        ; is aligned?
        jz      .Aligned

        align 16
.NextX1:
        mov     [edi], bl
        inc     edi
        dec     ecx
        dec     eax
        jnz     .NextX1

.Aligned:

        mov     eax, ecx
        shr     ecx, 3
        jz      .NoQuads

.NextX2:
        movq    [edi], mm1
        add     edi, 8
        dec     ecx
        jnz     .NextX2

.NoQuads:
        and     eax, 7
        jz      .EndeX
.NextX3:
        mov     [edi], bl
        inc     edi
        dec     eax
        jnz     .NextX3

.EndeX:
        pop     eax
        pop     ecx
        pop     edi
        dec     edx
        lea     edi, [edi+ebp]
        jnz     .NextLine

.Ende:
        popad
        emms
        ret


; ----------------------------------

        align 16

equalvec:
        mov     eax, [esi]
        cmp     eax, [edi]
        jne     .failed
        mov     eax, [esi+4]
        cmp     eax, [edi+4]
        jne     .failed
        mov     eax, [esi+8]
        cmp     eax, [edi+8]
        jne     .failed
        xor     eax, eax
        inc     eax
        ret
.failed:
        xor     eax, eax
        ret

        align 16

bsearch32:
        xor     eax, eax
        lea     ebx, [ecx-1]
.Weiter:
        cmp     ebx, eax
        jb      .Ende
        mov     ecx, ebx
        sub     ecx, eax
        sar     ecx, 1
        add     ecx, eax
        mov     edx, [edi+ecx*4]
        cmp     edx, esi
        je      .Ende
        jg      .blah1
        lea     eax, [ecx+1]
        jmp     short .Weiter
.blah1:
        lea     ebx, [ecx-1]
        jmp     short .Weiter
.Ende:
        mov     eax, ecx
        ret

        align 16

sort32:
         pushad
         lea    ebx, [ecx-1]
         xor    edx, edx
         mov    eax, edi
         call   .qsort32
         popad
         ret
         align 16
.qsort32:
         push      ecx
         push      esi
         push      edi
         push      ebp
         push      eax
         push      edx
         push      ebx

.ReStart:
         mov       eax, [esp]
         mov       edx, [esp+4]
         cmp       eax, edx
         jle       .Ende
         mov       edi, [esp+8]
         mov       esi, [edi+eax*4]
         lea       ecx, [edx-1]
         mov       ebx, eax

         align     16

.While1: mov       ebp, [edi+ecx*4+4]
         inc       ecx
         cmp       esi, ebp
         jg        .While1

         lea       eax, [edi-4]
         align     16

.While2: mov       ebp, [eax+ebx*4]
         dec       ebx
         cmp       esi, ebp
         jl        .While2

         cmp       ecx, ebx
         jge       .break
         mov       ebp, [edi+ecx*4]
         mov       eax, [edi+ebx*4]
         mov       [edi+ebx*4],ebp
         mov       [edi+ecx*4],eax
         jmp       short .While1

.break:  mov       eax, [esp]
         mov       edx, [edi+ecx*4]
         mov       ebx, [edi+eax*4]
         mov       [edi+eax*4],edx
         mov       [edi+ecx*4],ebx
         mov       edx, [esp+4]
         lea       ebx, [ecx-1]
         mov       eax, edi
         inc       ecx
         call      .qsort32
         mov       [esp+4],ecx
         jmp       short  .ReStart

.Ende:   lea       esp, [esp+12]
         pop       ebp
         pop       edi
         pop       esi
         pop       ecx
         ret

        align 16

mymemcpy:
    pushad
    mov    eax, ecx
    sub    ecx, edi
    sub    ecx, eax
    and    ecx, 3
    sub    eax, ecx
    jle    short .LEndBytes
    rep    movsb
    mov    ecx, eax
    and    eax, 7
    shr    ecx, 3
    jz     .LEndBytes
    push   eax
.DWordLoop:
    mov    edx, [esi]
    mov    eax, [esi+4]
    add    esi, 8
    mov    [edi], edx
    mov    [edi+4], eax
    add    edi, 8
    dec    ecx
    jnz    .DWordLoop
    pop    eax
.LEndBytes:
    add    ecx, eax
    rep    movsb
    popad
    ret




