    DOSSEG

    .MODEL SMALL
    .386
    .CODE

    GLOBAL  PrintByte:PROC, PrintWord:PROC, PrintBig:PROC

    TextNumBIG  db  "00000"
    TextNum     db  "00000"
    TextNumEnd  db  0,"$"
    
BinToAscII PROC
        mov     bx,10
        mov     si,SEG TextNum
        mov     es,si
        mov     si,offset textnumend-1
        mov     cx,5
DivLoop:
        sub     dx,dx
        div     bx
        add     dl,'0'
        mov     es:[si],dl
        dec     si
        loop    DivLoop
        ret
ENDP BinToAscII

B2ABig PROC
        mov     ebx,10
        mov     si,SEG TextNum
        mov     es,si
        mov     si,offset textnumend-1
        mov     cx,10
DLBig:
        sub     edx,edx
        div     ebx
        add     dl,'0'
        mov     es:[si],dl
        dec     si
        loop    DLBig
        ret
ENDP B2ABig

PrintBig PROC
    pushad

    call    b2aBig
    mov     ax,SEG TextNumBig
    mov     ds,ax
    mov     dx,offset textnumBig
    mov     ah,9
    int     21h

    popad
    ret
ENDP PrintBig

PrintByte PROC
    pusha
    jnc     skipsignb
    xor     ah,ah
    test    al,10000000b
    jz      skipsignb
    neg     al
    push    ax
    mov     ah,2
    mov     dl,"-"
    int     21h
    pop     ax
    jmp     skipb

skipsignb:
    xor     ah,ah
    push    ax
    mov     ah,2
    mov     dl," "
    int     21h
    pop     ax
skipb:
    call    bintoascii
    mov     ax,SEG TextNum
    mov     ds,ax
    mov     dx,offset textnum+2
    mov     ah,9
    int     21h
    popa
    ret
ENDP PrintByte

PrintWord PROC
    pusha
    jnc     skipsignw
    test    ah,10000000b
    jz      skipsignw
    neg     ax
    push    ax
    mov     ah,2
    mov     dl,"-"
    int     21h
    pop     ax
    jmp     skipw
Skipsignw:        
    push    ax
    mov     ah,2
    mov     dl," "
    int     21h
    pop     ax
Skipw:
    call    bintoascii
    mov     ax,SEG TextNum
    mov     ds,ax
    mov     dx,offset textnum
    mov     ah,9
    int     21h
    popa
    ret
ENDP PrintWord

    END
    

