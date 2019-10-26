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

_nuncfastu_be_lo_zgike:
    mov ebx, seltoha_sisydatni

    ; la e'ax zo'u: se jalge
    ; la ebyx zo'u: se krefu
    ; la ecyx zo'u: indice
    ; la edyx zo'u: nilcla lo snadatnygunma

    xor ecx, ecx
.pa_snadatnygunma:
    xor eax, eax
    mov ax, BASELEN
    mov edx, eax

    ; lo ti darxi pe'a mo'isro bazi sarcu
    ; .ije .aunai daspo lo darxi pe'a datnyvau
    ; .i je'u feglyzvi .iku'i na xlali lo demri'a
    ; ni'i lo krefu
    push edx
    push edx
    push edx
    ; ca'e preti lo mo'isro
    mov edi, esp
    sub esp, edx

.pa_snamupli:
    ; ca'e kanji lo snamupli
    ; daspo a'y je la esis je dy
    xor eax, eax
    mov al, byte [ebx]
    mul ecx
    shr eax, 2
    and al, 0xC0

    mov byte [esp], al
    inc ecx
    inc esp

    cmp esp,edi
    jne .pa_snamupli

    ; -------- ti fanmo la pa snamupli

    pop edx
    pop edx
    pop edx
    ; ca'e ciska
    push ebx
    push ecx

    push SYS_write
    pop eax
    xor ebx, ebx
    inc ebx
    mov ecx, edi
    sub ecx, edx
    ; la edyx xa'o se kanji

    int 0x80

    pop ecx
    pop ebx

    ; ---

    inc ebx
    push dword [ebx]
    pop eax
    cmp al,0
    jne .pa_snadatnygunma

    ; -------- ti fanmo la pa snadatnygunma

