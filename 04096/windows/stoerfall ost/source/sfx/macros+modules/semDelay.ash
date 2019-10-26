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



;semDelay
;INPUT:   st(0) LENGTH
;         st(1) MIX
;	  st(2) FEEDBACK
;	  st(3) INP
;
;
;OUTPUT:  st(0)
;      
;PANEL:
;	 		   _______________
;		>    <	  |               |       
;	INP	[-..+]	--|               |
;	FEEDBACK[0..1]	--|               |
;			  |   semDelay	  |--	AUDIO OUT
;	MIX	[0..1]	--|               |
;	LENGTH	[1..+]	--|               |
;			  |_______________|
;
;SIZE:	35


DELAY_BUFFER_LENGTH_MAX	= 35000

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.data

semDelayData struct			

	;output_data (must 4*NUM_OUTPORTS_MAX bytes)
	output		dd ?		
	out_dummy1	dd ?
	out_dummy2	dd ?
	out_dummy3	dd ?	
	
	;input_data (must 4*NUM_INPORTS_MAX bytes)	(in fpu_stack_order [st(0), st(1), st(2) ...])
	input		dd ?
	m		dd ?	
	f		dd ?
	l		dd ?
	in_dummy4	dd ?
	in_dummy5	dd ?
	in_dummy6	dd ?
	in_dummy7	dd ?
		
	;module_data	
	write_pos		dd ?	
	
	;delay_buffer
	buffer		dd DELAY_BUFFER_LENGTH_MAX dup (?)
	
semDelayData ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.code

semDelayWork		proc			
		
	push	ebx
	fistp	dword ptr [esp]
	pop	ebx					;length in ebx
		
	mov 	eax,[ebp+semDelayData.write_pos]		
	inc	eax					;go on in buffer
	xor 	edx,edx
	div	ebx
	mov 	[ebp+semDelayData.write_pos],edx	;remainder is our new write_position	
			
	fld	[ebp+semDelayData.buffer+edx*4]		;buf (read)
	fmul	st(2),st(0)				;buf*feedback	
	fmulp	st(1),st(0)				;buf*mix
	
	fadd	st(0),st(2)				;buf*mix+inp
	fstp	[ebp+semDelayData.output]
	
	faddp	st(1),st(0)				;buf*feedback+inp	
	fstp	[ebp+semDelayData.buffer+edx*4]		;store inp in buffer
	
semDelayWorkEnd::
semDelayWork		endp
