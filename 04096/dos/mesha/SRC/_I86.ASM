ideal
include "std.inc"
include "_i86.inc"

segdata
ifndef __NO_INT386
Reg386    REG386 <>
endif
SelOfs    dd @0
PSP       dd @0
ends

segcode
proc PtrToPhy
                add     eax,[d SelOfs]
                ret
endp
proc LowToPtr
                and     eax,0FFFFh
                and     edx,0FFFFh
                shl     eax,4
                add     eax,edx
                sub     eax,[d SelOfs]
                ret
endp
proc Int386
proc Int386X
                push    ebx ecx edi
                mov     edi,edx
                or      edi,edi
                jne     @@Ok
                mov     edi,o Reg386
                mov     [d edi+REG386._sp],0
@@Ok:           xor     ebx,ebx
                xor     ecx,ecx
                mov     bl,al
                mov     eax,300h
                int     31h
                pop     edi ecx ebx
                ret
endp
endp
proc GetEnv
                mov     eax,[PSP]
                movzx   eax,[w eax+2Ch]
                push    ebx ecx edx
                mov     ebx,eax
                mov     eax,6
                int     31h
                push    cx
                push    dx
                pop     eax
                pop     edx ecx ebx
                p2o     eax,eax
                ret
endp
proc ZeroReg386
                push eax edi ecx
                mov ecx,size REG386 / 4
                mov edi,o Reg386
                xor eax,eax
                rep stosd
                pop ecx edi eax
                ret
endp

proc DosAlloc
                push    ebx edx
                mov     ebx,eax
                add     ebx,15 + 4
                shr     ebx,4
                mov     eax,100h
                int     31h
                jc      @@Error
                movzx   eax,ax
                shl     eax,4
                sub     eax,[SelOfs]
                mov     [eax],edx
                add     eax,4
                pop     edx ebx
                ret
@@Error:        xor     eax,eax
                pop     edx ebx
                ret
endp
proc DosFree
                pushad
                mov     edx,[eax-4]
                mov     eax,101h
                int     31h
                popad
                ret
endp
proc DosReAlloc
                push    ebx edx
                mov     ebx,edx
                add     ebx,15 + 4
                shr     ebx,4
                mov     edx,[eax-4]
                mov     eax,102h
                int     31h
                jnc     @@Ok
                xor     eax,eax
@@Ok:           pop     edx ebx
                ret
endp

ends
end