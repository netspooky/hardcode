include \a!\file.ini

;        copyright 1996, to Daniel Groth (a.k.a ice/pulse) 
;        all rights reserved until further comments        


; ş equates ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
TRUE                    equ             1
FALSE                   equ             0
octreeColumns           equ             256
octreeRows              equ             256

; ş colour structure ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
sOctreeColour struc
        red             db              ?
        green           db              ?
        blue            db              ?
sOctreeColour ends

; ş general tree structure ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
sOctree struc
        level           dw              ?
        isleaf          db              ?
        index           dd              ?
        npixels         dd              ?
        redsum          dd              ?
        greensum        dd              ?
        bluesum         dd              ?
        color           sOctreeColour   <?,?,?>
        child           dd              8 dup(?)
        nextnode        dd              ?
sOctree ends

; ş variables ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
octreeColourBits        equ             8
octreeTreeDepth         equ             6
octreePossibleColours   equ             256-32
octreeBitMasks:         db              01,02,04,08,10h,20h,40h,80h
octreeBase              dd              0
octreeReduceList        dd              octreeTreeDepth dup(0)
octreeGlbLeafLevel      dw              octreeTreeDepth
octreeGlbTotalLeaves    dd              0
octreeColour            sOctreeColour   <0,0,0>
octreeSource            dd              0
octreeDestination       dd              0
octreePalette           dd              0



; ş colour substance Ä transparent ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
mtrimColourTransparence macro X
        pushad
        movzx   eax,b [esi+ecx+X]
        shl     eax,2
        mov     edx,768
        sub     edx,ebp
        imul    eax,edx
        movzx   ebx,b [ebx+ebp+X]
        shl     ebx,2
        imul    ebx,ebp
        add     eax,ebx
        mov     ebx,768
        cdq
        div     ebx
        mov     [edi+X],al
        popad
endm
trimColourTransparence proc
        mtrimColourTransparence 0
        mtrimColourTransparence 1
        mtrimColourTransparence 2
        ret
trimColourTransparence endp

; ş colour substance Ä medium ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
mtrimColourMedium macro X
        local @@yoyo1
        pushad
        movzx   eax,b [esi+ecx+X]
        add     eax,eax
        movzx   ebx,b [ebx+ebp+X]
        add     ebx,ebx
        add     eax,ebx
        cmp     eax,255
        jbe     @@yoyo1
        mov     al,255
@@yoyo1:mov     [edi+X],al
        popad
endm
trimColourMedium proc
        mtrimColourMedium 0
        mtrimColourMedium 1
        mtrimColourMedium 2
        ret
trimColourMedium endp

; ş colour substance Ä bright ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
mtrimColourBright macro X
        local   groda34,groda44
        push    ebx
        movzx   eax,b [ebx+ebp+X]
        movzx   ebx,b [esi+ecx+X]
        shl     eax,3
        shl     ebx,2
        sub     eax,128*2
        add     eax,ebx
        cmp     eax,255
        jl      groda34
        mov     eax,255
groda34:cmp     eax,0
        jg      groda44
        xor     eax,eax
groda44:mov     [edi+X],al
        pop     ebx
endm
mtrimColourBright2 macro X
        local   groda34,groda44
        push    ebx
        movzx   eax,b [ebx+ebp+X]
        movzx   ebx,b [esi+ecx+X]
        shl     eax,2+3
        shl     ebx,2+3
        add     eax,ebp
        add     eax,ebx
        lea     eax,[eax+2*eax]
        shr     eax,2+3
        cmp     eax,255
        jb      groda34
        mov     eax,255
groda34:mov     [edi+X],al
        pop     ebx
endm
trimColourBright proc
        mtrimColourBright 0
        mtrimColourBright 1
        mtrimColourBright 2
        ret
trimColourBright endp

; ş colour substance Ä spacy ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
mtrimColourSpacy macro X
local   @@roda
        push    ebx
        movzx   eax,b [ebx+ebp+X]
        movzx   ebx,b [esi+ecx+X]
        shl     eax,2
        shl     ebx,2
        imul    eax,ebx
        sar     eax,8
        imul    eax,ebp
        lea     eax,[eax+2*eax]
        sar     eax,8+1
        cmp     eax,255
        jb      @@roda
        mov     eax,255
@@roda: mov     [edi+X],al
        pop     ebx
endm
trimColourSpacy proc
        mtrimColourSpacy 0
        mtrimColourSpacy 1
        mtrimColourSpacy 2
        ret
trimColourSpacy endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; build a 24 bits colour image using a special substance
; in  ESI - base palette
;     EDI - light palette
;     EBP - destination buffer
;     EAX - methode
remapBuild proc
        mov     @@methodeActif,eax
        mov     @@aPalette1,esi
        mov     @@aPalette2,edi
        mov     @@remapTemp,ebp
        push    _himembase
        mov     eax,octreeRows*octreeColumns*3
        call    _gethimem
        mov     @@aRemap24bits,eax
        xor     eax,eax
        mov     edi,@@aRemap24bits
        mov     esi,@@aPalette1
        mov     ebx,@@aPalette2
        xor     ebp,ebp
@@ver:  xor     ecx,ecx
@@hor:  pushad
        mov     eax,@@methodeActif
        call    @@methode[4*eax]
        popad
        add     edi,3
        add     ecx,3
        cmp     ecx,octreeColumns*3
        jnz     @@hor
        add     ebp,3
        cmp     ebp,octreeRows*3
        jnz     @@ver
        ; write output file
;        mov     edx,o outname
;        call    FileCreate
;        mov     edx,@@aRemap24bits
;        mov     ecx,256*256*3
;        call    FileWrite
;        call    FileClose
        mov     ecx,octreeTreeDepth
        mov     edi,o octreeReduceList
        xor     eax,eax
        rep     stosd
        mov     octreeGlbLeafLevel,octreeTreeDepth
        mov     octreeGlbTotalLeaves,0
        mov     ebx,o Palette
        mov     esi,@@aRemap24bits
        mov     edi,@@remapTemp
        call    octreeReduction
        pop     _himembase
        ret
@@remapTemp             dd              ?
@@aPalette1             dd              ?
@@aPalette2             dd              ?
@@aRemap24bits          dd              ?
@@methodeActif          dd              ?
@@methode               dd              o trimColourSpacy
                        dd              o trimColourBright
                        dd              o trimColourTransparence
                        dd              o trimColourMedium
;outname db 'a.raw',0
remapBuild endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; reduce a 24 bits colour image down to 256 colours
; in  ESI - source data RAW 24bit
;     EDI - destination data
;     EBX - destination palette
octreeReduction proc
        pushad
        push    _himembase
        mov     octreeSource,esi
        mov     octreeDestination,edi
        mov     octreePalette,ebx
        xor     eax,eax
        mov     edi,o octreeReduceList
        mov     ecx,octreeTreeDepth
        rep     stosd
        xor     ebx,ebx
        call    octreeCreateNode
        mov     octreeBase,edi
        mov     esi,o octreeColour
        mov     ebp,octreeSource
        mov     ecx,octreeRows*octreeColumns
@@lp:   push    ecx
        mov     al,[ebp+00]
        shr     al,2
        mov     octreeColour.red,al
        mov     al,[ebp+01]
        shr     al,2
        mov     octreeColour.green,al
        mov     al,[ebp+02]
        shr     al,2
        mov     octreeColour.blue,al
        add     ebp,3
        push    ebp
        mov     ebp,o octreeBase
        mov     ebx,0
        call    octreeInsertTree
        pop     ebp
@@more: cmp     octreeGlbTotalLeaves,octreePossibleColours
        jbe     @@nRed
        call    octreeReduceTree
        jmp     @@more
@@nRed: pop     ecx
        dec     ecx
        jnz     @@lp
        mov     esi,octreePalette
        xor     ebx,ebx
        mov     edi,octreeBase
        call    octreeMakePalette
        mov     ebp,octreeDestination
        mov     ebx,octreeSource
        mov     edx,octreeColumns
@@ver:  mov     ecx,octreeRows
@@hor:  mov     al,[ebx+00]
        shr     al,2
        mov     octreeColour.red,al
        mov     al,[ebx+01]
        shr     al,2
        mov     octreeColour.green,al
        mov     al,[ebx+02]
        shr     al,2
        mov     octreeColour.blue,al
        add     ebx,3
        push    edx ecx ebx
        mov     edi,octreeBase
        mov     esi,o octreeColour
        call    octreeQuantizeColour
        mov     [ebp],bl
        inc     ebp
        pop     ebx ecx edx
        dec     ecx
        jnz     @@hor
        dec     edx
        jnz     @@ver
        pop     _himembase
        popad
        ret
octreeReduction endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; build a new tree out of the old one by inserting a branch at the base
; in  EDI - tree
;     ESI - colour
;     EBX - depth
octreeInsertTree proc
        test    edi,edi
        jnz     @@nEmpt
        call    octreeCreateNode
@@nEmpt:mov     [ebp],edi
        cmp     [edi].isleaf,TRUE
        jne     @@nLeaf
        inc     [edi].npixels
        xor     eax,eax
        mov     al,[esi].red
        add     [edi].redsum,eax
        mov     al,[esi].green
        add     [edi].greensum,eax
        mov     al,[esi].blue
        add     [edi].bluesum,eax
        jmp     @@else
@@nLeaf:push    edi ebx ebp
        mov     ecx,octreeTreeDepth
        sub     ecx,ebx
        call    octreeReturnLevel
        lea     ebp,[edi+4*edx].child
        mov     edi,[ebp]
        inc     ebx
        call    octreeInsertTree
        pop     ebp ebx edi
@@else: ret
octreeInsertTree endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; return the level of a node
; in  ESI - colour
;     ECX - depth
; out EDX - level
octreeReturnLevel proc
        push    eax
        xor     edx,edx
        mov     al,[esi].red
        and     al,b octreeBitMasks[ecx]
        shr     al,cl
        shl     al,2
        mov     dl,al
        mov     al,[esi].green
        and     al,b octreeBitMasks[ecx]
        shr     al,cl
        shl     al,1
        or      dl,al
        mov     al,[esi].blue
        and     al,b octreeBitMasks[ecx]
        shr     al,cl
        or      dl,al
        pop     eax
        ret
octreeReturnLevel endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; create a node on an existing tree
; in  EBX - level
; out EDI - newnode
octreeCreateNode proc
        push    eax ecx
        mov     eax,size sOctree
        call    _gethimem
        mov     edi,eax
        push    edi
        xor     eax,eax
        mov     ecx,size sOctree
        rep     stosb
        pop     edi
        mov     [edi].level,bx
        cmp     bx,octreeGlbLeafLevel
        sete    al
        mov     [edi].isleaf,al
        cmp     al,TRUE
        jne     @@nLeaf
        inc     octreeGlbTotalLeaves
        jmp     @@oLeaf
@@nLeaf:call    octreeMakeReductible
@@oLeaf:mov     [edi].npixels,0
        mov     [edi].index,0
        mov     [edi].redsum,0
        mov     [edi].greensum,0
        mov     [edi].bluesum,0
        mov     ecx,octreeColourBits-1
@@lpClr:mov     [edi+4*ecx].child,0
        dec     ecx
        jns     @@lpClr
        pop     ecx eax
        ret
octreeCreateNode endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; build a reduction list from a level
; in  EBX - level
;     EDI - new node
octreeMakeReductible proc
        push    eax
        mov     eax,octreeReduceList[4*ebx]
        mov     [edi].nextnode,eax
        mov     octreeReduceList[4*ebx],edi
        pop     eax
        ret
octreeMakeReductible endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; use a reduction list-adress to remove the less significant colours
octreeReduceTree proc
        pushad
        mov     @@sumred,0
        mov     @@sumgreen,0
        mov     @@sumblue,0
        xor     ebx,ebx
        call    octreeGetReductible
        mov     ecx,0
@@lp:   cmp     [edi+4*ecx].child,0
        je      @@nEqu
        inc     ebx
        mov     edx,[edi+4*ecx].child
        mov     eax,[edx].redsum
        add     @@sumred,eax
        mov     edx,[edi+4*ecx].child
        mov     eax,[edx].greensum
        add     @@sumgreen,eax
        mov     edx,[edi+4*ecx].child
        mov     eax,[edx].bluesum
        add     @@sumblue,eax
        mov     edx,[edi+4*ecx].child
        mov     eax,[edx].npixels
        add     [edi].npixels,eax
@@nEqu: inc     ecx
        cmp     ecx,octreeColourBits
        jne     @@lp
        mov     [edi].isleaf,TRUE
        mov     eax,@@sumred
        mov     [edi].redsum,eax
        mov     eax,@@sumgreen
        mov     [edi].greensum,eax
        mov     eax,@@sumblue
        mov     [edi].bluesum,eax
        dec     ebx
        sub     octreeGlbTotalLeaves,ebx
        popad
        ret
        @@sumred        dd ?
        @@sumgreen      dd ?
        @@sumblue       dd ?
octreeReduceTree endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; return a first reduction occurance
; out EDI - node
octreeGetReductible proc
        push    eax ebx
        movzx   ebx,octreeGlbLeafLevel
@@more: cmp     octreeReduceList[4*ebx-4],0
        jne     @@nEqu
        dec     ebx
        jmp     @@more
@@nEqu: mov     edi,octreeReduceList[4*ebx-4]
        mov     eax,[edi].nextnode
        mov     octreeReduceList[4*ebx-4],eax
        pop     ebx eax
        ret
octreeGetReductible endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; build the palette from the reduced list (use a 24bits image as well)
; in  EDI - tree
;     EBX - start index
;     ESI - colour table offset
octreeMakePalette proc
        cmp     [edi].isleaf,TRUE
        jne     @@else
        push    ebp ebx
        lea     ebx,[2*ebx+ebx]
        mov     ebp,[edi].npixels
        xor     edx,edx
        mov     eax,[edi].redsum
        div     ebp
        mov     [esi+ebx].red,al
        xor     edx,edx
        mov     eax,[edi].greensum
        div     ebp
        mov     [esi+ebx].green,al
        xor     edx,edx
        mov     eax,[edi].bluesum
        div     ebp
        mov     [esi+ebx].blue,al
        pop     ebx ebp
        mov     [edi].index,ebx
        inc     ebx
        jmp     @@over
@@else: xor     ecx,ecx
@@lp:   cmp     [edi+4*ecx].child,0
        je      @@next
        push    ecx edi
        mov     edi,[edi+4*ecx].child
        call    octreeMakePalette
        pop     edi ecx
@@next: inc     ecx
        cmp     ecx,octreeColourBits
        jb      @@lp
@@over: ret
octreeMakePalette endp

; °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; check which colour is the nearest colour from a RGV value
; in  EDI - tree
;     ESI - offset 1 colour
; out EBX - index
octreeQuantizeColour proc
        cmp     [edi].isleaf,TRUE
        jne     @@else
        mov     ebx,[edi].index
        jmp     @@over
@@else: push    ecx
        mov     ecx,6
        sub     cx,[edi].level
        call    octreeReturnLevel
        push    edi
        mov     edi,[edi+4*edx].child
        call    octreeQuantizeColour
        pop     edi ecx
@@over: ret
octreeQuantizeColour endp
