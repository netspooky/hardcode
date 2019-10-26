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

;malnunrinsa:
;    db "Fuckings to M$",0xA,0
;malnunrinsa_fanmo:
fb0_lerpoi:
    db "/dev/fb0",0
seltoha_sisydatni: ; "LUT"
    db 0x24,0x24,0x20,0x1E,0x1E,0x1B,0x1B
    db 0x1E,0x1E,0x20,0x1E,0x1B,0x18,0x18
    db 0x18,0x18,0x18,0x1B,0x1B,0x1B,0x1E
    db 0x20,0x20,0x20,0x1E,0x1E,0x24,0x24
    db 0x1B,0x1B,0x1B,0x1B,0x1B,0x1B,0x1B
    db 0x24,0x24,0x20,0x1E,0x1E,0x1E,0x1E
    ; lo pamoi bivjetka'u pe lo pixra cu mintu li no
pixra:
    incbin "pixra.dtn"

