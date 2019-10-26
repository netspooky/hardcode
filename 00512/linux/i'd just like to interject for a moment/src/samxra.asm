;
; This file is part of "fingubni samselpla selsa'a" (FSS)
; Copyright (C) 2017 PoroCYon
;
; FSS is free software: you can redistribute it and/or modify
; it under the terms of the GNU General Public License version 3,
; or at your option, any later version, as
; published by the Free Software Foundation.
;
; FSS is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with FSS. If not, see <https://www.gnu.org/licenses/>.
;
; ---------------------------------------------------------------------
;
; lo ti datnyvei cu pagbu la fingubni samselpla selsa'a goi fysysy
; noi proga gi'e se fukyzifpo'e la'oi PoroCYon de'i li 2017
;
; .i fysysy fingubni .ija'ebo do .e'a ti fairgau gi'e galfi
; ti ja'i la'o gy. GNU General Public License .gy poi se versiio
; li su'o 3 gi'e se finti la'o gy. Free Software Foundation .gy
;
; .i fysysy se fairgau tezu'e lo nu plixau SECAU LO SI'O SIDJU kuku'i
; .i .e'u ko catlu gypyly tezu'e lo nu zvafa'i lo tcila
;
; .i .a'o do te bevri lo fukpi be gypyly sepa'u fysysy .i va'onai
; la'edi'u ko catlu zoi .url. https://www.gnu.org/licenses/ .url.
;

; .aunai ciksi
; .i di'ai nitcu be la'e zo di'ai

; ... .oi mi mo'u morji lodu'u mokau .akti
; .i ja'o di'ai mi

_nuncfastu_be_lo_skina:
    sub esp, fb_fix_screeninfo.size
    mov esi, esp
    sub esp, fb_var_screeninfo.size
    mov edi, esp

    push O_RDWR
    push SYS_open
    pop eax
    pop ecx

    mov ebx, fb0_lerpoi
    int 0x80
    mov ebx, eax
    push ebx

    mov al, SYS_ioctl
    mov cx, FBIOGET_FSCREENINFO
    mov edx, esi
    int 0x80

    mov al, SYS_ioctl
    mov cx, FBIOGET_VSCREENINFO
    mov edx, edi
    int 0x80

    pop ecx
    xor edx, edx
    push edx ; mmap_arg.off
    push ecx ; mmap_arg.filed
    push MAP_SHARED ; mmap_arg.flags
    push PROT_RDWR  ; mmap_arg.prot
    ; TODO: kanji va'o lo nu raunzu lo ni nu'o selpli
    push 0x20 >> 3
    pop eax
    mul dword [edi + fb_var_screeninfo.xres]
    mul dword [edi + fb_var_screeninfo.yres]
    ; xres * yres * (bbp >> 3)
    ;mov eax, 0x0012C000<<1;0x7F0000 ; li ji'ima'u 640*480*4
    mov ebp, eax
    push eax ; mmap_arg.len
    push edx ; mmap_arg.addr
    mov ebx, esp
    ;add sp, mmap_arg.size ; xrugau lo bebna ; .i la'edi'u na sarcu

    xor eax, eax
    xor ecx, ecx
    mov al, SYS_mmap
    int 0x80
    mov ebp, eax

%define DATAS 0x020
%define FBUFS 0x100
%define RESTS (1<<(FBUFS/DATAS))
%define L2FDS 3 ; log2(FBUFS/DATAS)
%define BINBS 8
%define L2BIB 3

    mov edi, pixra
    shl edi, L2BIB + L2FDS ; log2(sizeof(uint8_t) * FBUFS/DATAS)

    xor ecx, ecx
    xor edx, edx

.y_zei_bavlahi:
.x_zei_bavlahi:
    ; kanji lo te ciska
    push edx
    mov ebx, ebp

    mov eax, [esi + fb_fix_screeninfo.line_length]
    mul edx
    add ebx, eax

    push 4
    pop eax
    mul ecx
    add ebx, eax

    mov eax, ebx
    pop edx

    push ecx
    push edx
        ; kanji lo se ciska
        mov ebx, edi
        shr ebx, L2FDS
        mov ecx, ebx
        and ecx, BINBS - 1
        shr ebx, L2BIB

        mov ebx, [ebx]
        xor edx, edx
        inc edx

        shl edx, cl
        and edx, ebx

        cmp dl,0
        jne .selska
        mov dl,0xFF
        jmp .klina
.selska:
        xor edx, edx
.klina:

        ; ciska
        mov byte [eax], dl
        inc eax
        mov byte [eax], dl
        inc eax
        mov byte [eax], dl
        ; na sarcu fa lo nu ciska fi lo vomoi

    pop edx
    pop ecx

    inc ecx
    inc edi
    cmp cl, 0
    jne .x_zei_bavlahi

    ; ebx?
    push edx
        and edx, 7 ;RESTS-1
        cmp edx, 7 ;RESTS-1
        je .cnano
        sub edi, FBUFS
.cnano:
    pop edx

    xor ecx, ecx
    inc edx
    cmp dl,0
    jne .y_zei_bavlahi

