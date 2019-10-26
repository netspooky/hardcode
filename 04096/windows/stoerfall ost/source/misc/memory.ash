comment #+

    This is the source-release of "Stoerfall Ost", our winning 4kb
    multimedia presentation that was first shown at Dialogos 2000.
    If you have any questions concerning the sourcecode drop us a
    line at freestyle@freestylas.org. Feel free to visit our
    webpage at http://www.freestylas.org.
    Copyright (C) 2001 freestyle
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.
    
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.
    
    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
    
+#



        .data

heapptr         dd offset heap

        
        .data?

heap            db 32*1024*1024 dup(?)

        
        .code
        
; in    ecx = number of bytes to allocate
; out   ebx = basepointer
; uses  ecx,edi,eax
calloc          proc near
        mov ebx,ecx
        mov eax,offset heapptr
        add ebx,[eax]
        xchg ebx,[eax]
        mov edi,ebx
        xor al,al
        rep stosb
        ret     
calloc          endp


        