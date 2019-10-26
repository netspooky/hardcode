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



;sePattern

SE_NUM_PATTERN	= 5		;number of active pattern

.code

seProceedPattern	proc
;IN:	eax	- ticks since music starts
;SIZE:	31
		
	and	eax,11111b	
	push	31		;todo: reverse pattern!!!
	pop	ebx		;todo: reverse pattern!!!
	sub	ebx,eax		;todo: reverse pattern!!!	
	
	mov	edi,(offset script_dword)+trigger*4
	push	SE_NUM_PATTERN
	pop	ecx	
	@instr_loop:							
		bt	[edi+(pattern_play*4-trigger*4)],ebx		;test bit in pattern (ebx=31)
		sbb	eax,eax
		neg	eax						;just to prevent fpu_exceptions
		stosd							;store trigger				
	loop	@instr_loop

ret
seProceedPattern	endp
