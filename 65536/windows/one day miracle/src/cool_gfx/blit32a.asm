;
;       The assembly subroutines of blit32
;       Not all of them tested yet :v/
;
;       Created: 31.3.1999
;       Updated: 20.5.1999
;
;       -Marq
;

;       Other formats than ELF require underscores, define them:
%ifdef UNDERSCORE
%define blit32_array _blit32_array
%define blit32_8_gray _blit32_8_gray
%define blit32_8_raster _blit32_8_raster
%define blit32_8_raster_double _blit32_8_raster_double
%define blit32_15 _blit32_15
%define blit32_15_double _blit32_15_double
%define blit32_16 _blit32_16
%define blit32_16_double _blit32_16_double
%define blit32_24 _blit32_24
%define blit32_24_double _blit32_24_double
%define blit32_32 _blit32_32
%define blit32_32_double _blit32_32_double
%define blit32_tweak _blit32_tweak
%endif

        bits 32
        global blit32_array
        global blit32_8_gray,blit32_8_raster,blit32_8_raster_double
        global blit32_15,blit32_15_double
        global blit32_16,blit32_16_double
        global blit32_24,blit32_24_double
        global blit32_32,blit32_32_double
        global blit32_tweak

;       Macro for all the routine entries
%macro STD_ENTRY 0
        push    ebp
        mov     ebp,esp
        push    ebx
        push    ecx
        push    edx
        push    esi
        push    edi

%ifdef SELECTOR
        push    es
        mov     eax,[PRM_EXTRA]
        mov     es,ax
%endif
        mov     ecx,[PRM_LEN]
        mov     edi,[PRM_DEST]
        mov     esi,[PRM_DATA]

%endmacro

;       Macro for all the routine exits
%macro STD_EXIT 0
%ifdef SELECTOR
        pop     es
%endif
        pop     edi
        pop     esi
        pop     edx
        pop     ecx
        pop     ebx
        pop     ebp
        ret
%endmacro

;       Macro for portable mov (Use ES: if SELECTOR defined)
%macro PMOV 2
%ifdef SELECTOR
        db      026h    ;   ES: byte
%endif
        mov     %1,%2
%endmacro

;       Symbolic names for function parameters
%define PRM_DEST   ebp+8
%define PRM_DATA   ebp+12
%define PRM_LEN    ebp+16
%define PRM_ROWLEN ebp+20
%define PRM_EXTRA  ebp+24

        section .text

blit32_8_gray:
        STD_ENTRY

        xor     ebx,ebx
        align   4
muumi:  mov     bl,[esi]
        mov     eax,ebx
        mov     bl,[esi+1]
        add     eax,ebx
        mov     bl,[esi+2]
        add     eax,ebx
        shr     eax,3
        PMOV    [edi],al
        inc     edi
        add     esi,4
        dec     ecx
        jnz     muumi

        STD_EXIT

blit32_8_raster:
        STD_ENTRY    
        mov     edx,[PRM_ROWLEN]

        xor     ebx,ebx
        align   4  
paikka: mov     bl,[esi+2]
        shr     bl,2
        PMOV    [edi],bl
        mov     bx,[esi]
        mov     al,[blit32_array+ebx]
        PMOV    [edi+edx],al
        add     edi,1
        add     esi,4
        dec     ecx
        jnz     paikka

        STD_EXIT

blit32_8_raster_double:
        STD_ENTRY
        mov     edx,[PRM_ROWLEN]

        xor     ebx,ebx
        align   4     
vaikka: mov     bl,[esi+2]
        shr     bl,2
        PMOV    [edi],bl
        PMOV    [edi+edx+1],bl
        mov     bx,[esi]
        mov     al,[blit32_array+ebx]
        PMOV    [edi+1],al
        PMOV    [edi+edx],al
        add     edi,2
        add     esi,4
        dec     ecx
        jnz     vaikka

        STD_EXIT

blit32_15:
        STD_ENTRY

        xor     ebx,ebx
        shr     eax,1
        align   4     
kupla:  mov     eax,[esi]
        mov     ebx,eax
        shr     eax,6
        and     eax,1111100000b
        shr     bl,3
        add     al,bl
        shr     ebx,9
        and     bh,01111100b
        add     ah,bh
        add     esi,4
        mov     edx,eax

        mov     eax,[esi]
        mov     ebx,eax
        shr     eax,6
        and     eax,1111100000b
        shr     bl,3
        add     al,bl
        shr     ebx,9
        and     bh,01111100b
        add     ah,bh
        add     esi,4
        
        shl     eax,16
        mov     ax,dx
        PMOV    [edi],eax
        add     edi,4
        dec     ecx
        jnz     kupla

        STD_EXIT

blit32_15_double:
        STD_ENTRY

        xor     ebx,ebx
        align   4
rupla:  mov     eax,[esi]
        mov     ebx,eax
        shr     eax,6
        and     eax,1111100000b
        shr     bl,3
        add     al,bl
        shr     ebx,9
        and     bh,01111100b
        add     ah,bh
        mov     edx,eax
        shl     eax,16
        mov     ax,dx
        PMOV    [edi],eax
        add     edi,4
        add     esi,4  
        dec     ecx  
        jnz     rupla

        STD_EXIT

blit32_16:
        STD_ENTRY

        xor     ebx,ebx
        shr     ecx,1
        align   4    
tupla:  mov     eax,[esi]
        mov     ebx,eax
        shr     eax,5
        and     eax,11111100000b
        shr     bl,3
        add     al,bl
        shr     ebx,8
        and     bh,011111000b
        add     ah,bh
        add     esi,4
        mov     edx,eax

        mov     eax,[esi]
        mov     ebx,eax
        shr     eax,5
        and     eax,11111100000b
        shr     bl,3
        add     al,bl
        shr     ebx,8
        and     bh,011111000b
        add     ah,bh
        add     esi,4

        shl     eax,16
        mov     ax,dx
        PMOV    [edi],eax
        add     edi,4
        
        dec     ecx
        jnz     tupla

        STD_EXIT

blit32_16_double:
        STD_ENTRY

        xor     ebx,ebx
        align   4
dupla:  mov     eax,[esi]
        mov     ebx,eax
        shr     eax,5
        and     eax,11111100000b
        shr     bl,3
        add     al,bl
        shr     ebx,8
        and     bh,011111000b
        add     ah,bh
        mov     edx,eax
        shl     eax,16
        mov     ax,dx
        PMOV    [edi],eax
        add     edi,4
        add     esi,4
        dec     ecx
        jnz     dupla

        STD_EXIT

blit32_24:
        STD_ENTRY

        shr     ecx,2
        align   4
pitti:  mov     al,[esi+4]
        shl     eax,24
        mov     ebx,[esi]
        and     ebx,0ffffffh
        add     eax,ebx
        PMOV    [edi],eax
        mov     eax,[esi+8]
        shl     eax,16
        mov     ax,[esi+5]  
        PMOV    [edi+4],eax 
        mov     eax,[esi+12]
        shl     eax,8   
        mov     al,[esi+10]
        PMOV    [edi+8],eax
        add     edi,12
        add     esi,16
        dec     ecx
        jnz     pitti

        STD_EXIT

;       A strange converter, but it would be slow anyway...
blit32_24_double:
        STD_ENTRY

        shr     ecx,1
        xor     ebx,ebx
        align   4
conv:   mov     al,[esi]
        shl     eax,24
        add     eax,[esi]
        PMOV    [edi],eax
        mov     ebx,[esi+4]
        shl     ebx,16
        mov     bx,[esi+1]
        PMOV    [edi+4],ebx
        mov     eax,[esi+4]
        shl     eax,8
        mov     al,[esi+2]
        PMOV    [edi+8],eax
        add     edi,12
        add     esi,8
        dec     ecx
        jnz     conv

        STD_EXIT

;       Some systems need to copy the data... sigh.
blit32_32:
        STD_ENTRY

        shr     ecx,1
jcop:   mov     eax,[esi]
        add     esi,4
        PMOV    [edi],eax
        add     edi,4
        mov     eax,[esi]
        add     esi,4
        PMOV    [edi],eax
        add     edi,4
        dec     ecx
        jnz     jcop

        STD_EXIT

blit32_32_double:
        STD_ENTRY

        shr     ecx,1
        align   4
jcop2:  mov     eax,[esi]
        add     esi,4
        PMOV    [edi],eax
        PMOV    [edi+4],eax
        add     edi,8
        mov     eax,[esi]
        add     esi,4
        PMOV    [edi],eax
        PMOV    [edi+4],eax
        add     edi,8
        dec     ecx
        jnz     jcop2

        STD_EXIT

blit32_tweak:
        STD_ENTRY

        shr     ecx,4
        align   4
gather: mov     ah,[esi+12]
        mov     al,[esi+8]
        shl     eax,16
        mov     ah,[esi+4]
        mov     al,[esi]
        PMOV    [edi],eax
        add     esi,16
        add     edi,4
        dec     ecx
        jnz     gather

        STD_EXIT

        section .bss

;       The array for 8-bit colour converters
blit32_array    resb    65536

;       EOS
