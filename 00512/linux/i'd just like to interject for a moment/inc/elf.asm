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

; TODO: jmina lo makfa stodi la'e zo tamselgau.asm

    org   0x141000
ehdr:                   ; Elf32_Ehdr
    db    0x7F, "ELF"   ;  e_ident
    db    1, 1, 1, 0
;fb0_lerpoi:
    ;db "/dev/fb0",0
    times 8 db   0
    dw    2             ;  e_type
    dw    ELFOSABI_LINUX;  e_machine
    dd    1             ;  e_version
    dd    _nuncfastu    ;  e_entry
    dd    phdr - $$     ;  e_phoff
    dd    0             ;  e_shoff
    dd    0             ;  e_flags
    dw    ehdrnilbra    ;  e_ehsize
    dw    phdrnilbra    ;  e_phentsize
phdr:
    dd    1             ; e_phnum       ; p_type
                        ; e_shentsize
    dd    0             ; e_shnum       ; p_offset
                        ; e_shstrndx
ehdrnilbra equ $ - ehdr
    dd    $$            ; p_vaddr
    dd    $$            ; p_paddr
    dd    datnyrejnilbra; p_filesz
    dd    datnyrejnilbra; p_memsz
    dd    5             ; p_flags
    dd    0x1000        ; p_align
phdrnilbra equ $ - phdr

