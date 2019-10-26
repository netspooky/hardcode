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

%define ELFOSABI_LINUX 3
%define ELFOSABI_FREEBSD 9

; in: error
; out: /
%define SYS_exit 1
; in: filed, data, len
; out: bytes written
%define SYS_write 4
; in: filen, flags, mode
; out: filed/result
%define SYS_open 5
; in: filed, cmd, arg
; out: result
%define SYS_ioctl 54
; in: TODO
; out: addr
%define SYS_mmap 90
; in: addr, len
; out: /
%define SYS_munmap 91
; in: filed
; out: /
%define SYS_close 6

;%define SAMPLE_RATE 16000
%define SAMPLE_RATE 0x4000
%define SMALLEST_U  4
%define BASELEN SAMPLE_RATE / SMALLEST_U

%define O_RDWR 2
; ioctl(fbd, FBIOGET_FSCREENINFO, &finf)
%define FBIOGET_FSCREENINFO 0x4602
; ioctl(fbd, FBIOGET_VSCREENINFO, &finf)
%define FBIOGET_VSCREENINFO 0x4600
%define PROT_READ 1
%define PROT_WRITE 2
%define PROT_RDWR PROT_READ | PROT_WRITE
%define MAP_SHARED 1

struc fb_bitfield
    .off         : resd 1
    .len         : resd 1
    .msb_is_right: resd 1
    .size        :
endstruc

struc fb_fix_screeninfo
    .id         : resb 16
    .smem_start : resd 1
    .smem_len   : resd 1
    .type       : resd 1
    .type_aux   : resd 1
    .visual     : resd 1
    .xpanstep   : resw 1
    .ypanstep   : resw 1
    .ywrapstep  : resw 1
    ._pad0      : resw 1
    .line_length: resd 1
    .mmio_start : resd 1
    .mmio_len   : resd 1
    .accel      : resd 1
    .caps       : resw 1
    .reserved   : resw 2
    .size       :
endstruc

struc fb_var_screeninfo
    .xres     : resd 1
    .yres     : resd 1
    .xres_virt: resd 1
    .yres_virt: resd 1
    .xoff     : resd 1
    .yoff     : resd 1
    .bits_p_px: resd 1
    .is_greysc: resd 1 ; bool
    .red      : resb fb_bitfield.size
    .green    : resb fb_bitfield.size
    .blue     : resb fb_bitfield.size
    .transp   : resb fb_bitfield.size
    .is_nonstd: resd 1 ; bool
    .activate : resd 1
    .height   : resd 1
    .width    : resd 1
    .accel_flg: resd 1 ; mo'u plixau
    .pixclock : resd 1
    .left_mrg : resd 1
    .right_mrg: resd 1
    .upper_mrg: resd 1
    .lower_mrg: resd 1
    .hsync_len: resd 1
    .vsync_len: resd 1
    .sync     : resd 1
    .vmode    : resd 1
    .rotate   : resd 1 ; jganu .iku'i grade ji radno?
    .colourspc: resd 1
    .reserved : resd 4
    .size     :
endstruc

struc mmap_arg
    .addr : resd 1
    .len  : resd 1
    .prot : resd 1
    .flags: resd 1
    .filed: resd 1
    .off  : resd 1
    .size :
endstruc

