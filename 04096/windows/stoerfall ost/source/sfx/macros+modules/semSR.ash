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



;semSR
;INPUT:		st(0) DECAY
;		st(2) SUSTAIN_TIME
;		st(3) GATE
;	  	st(4) INP
;
;OUTPUT:	st(0)
;
;PANEL:
;       	>    <	   ______________
;	INP	[-..+]	--|		 |      
;			  |		 |
;	GATE	[0||1]	--|		 |
;		          |  semSR-Env	 |--	SR-Envelope * INP
;	SUSTIME	[0..+]  --|		 |
;			  |		 |
;	RELDEC  [0..1]	--|______________|
;
;COMMENT:  Sustain-Release-Envelope
;
;SIZE:	54


semSRData struct		; modules local DataStructure 

	;output_data (must 4*NUM_OUTPORTS_MAX bytes)
	output		dd ?		
	out_dummy1	dd ?
	out_dummy2	dd ?
	out_dummy3	dd ?	
	
	;input_data (must 4*NUM_INPORTS_MAX bytes)	
	in_dummy0	dd ?
	in_dummy1	dd ?
	in_dummy2	dd ?
	in_dummy3	dd ?
	in_dummy4	dd ?
	in_dummy5	dd ?
	in_dummy6	dd ?
	in_dummy7	dd ?
	
	; private data
	ticks		dd ?
	old		dd ?
	
semSRData ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.code

semSRWork		proc				;work code
	
	fld	[ebp+semSRData.old]		
	fmul	st(1),st(0)			;old*dec
	fsubrp	st(1),st(0)			;old-(old*dec)
	fstp	[ebp+semSRData.old]		
				
	push	eax	
	fistp	dword ptr [esp]			;sustain_time
	pop	eax		
	cmp	eax,[ebp+semSRData.ticks]
	jle	@no_sustain
		fld1					
		fstp	[ebp+semSRData.old]		;env = 1.0
	@no_sustain:
		
	push	eax
	fstp	dword ptr [esp]				;store gate
	pop	eax
	or	eax,eax
	jz	@no_restart				;if (gate!=0) restart envelope;			
		xor	ebx,ebx				;ticks = 0
		mov	[ebp+semSRData.ticks],ebx		
		fld1					
		fstp	[ebp+semSRData.old]		;env = 1.0
	@no_restart:

	
	@ready:	
	fmul	[ebp+semSRData.old]		;env*inp
	fstp	[ebp+semSRData.output]
		
	inc	[ebp+semSRData.ticks]


semSRWorkEnd::
semSRWork		endp
