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



;semFilter
;
;INPUT:   st(0) INP	  
;         st(1) RES
;         st(2) CUT
;
;OUTPUT:  st(0) lowpass
;   	  st(1) bandpass
;   	  st(2) highpass
;
;PANEL:	
;       		   _______________
;		>    <	  |               |       
;	CUT	[0..1]	--|               |--	LowPass
;			  |               |
;	RES/BW	[1..0]	--|   semFilter   |--	BandPass
;	      		  |               |
;	INP	[-..+]	--|               |--	HighPass
;			  |_______________|
;
;SIZE:	65

semFilterTmp	struct
	s1a 	dd ?       
 	s2a 	dd ?         
 	s1b 	dd ?         
 	s2b 	dd ?
semFilterTmp	ends



semFilterData struct		; modules data

	;output data	
	out_lp		dd ?	
	out_bp		dd ?
	out_hp		dd ?	
	out_dummy3	dd ? 

	;input data	
	in_smp		dd ?
	in_cut		dd ?
	in_res		dd ?
	in_dummy3	dd ?
	in_dummy4	dd ?
	in_dummy5	dd ?
	in_dummy6	dd ?
	in_dummy7	dd ?

	;private data	
	tmp		semFilterTmp <?>
	
semFilterData ends


;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.code

semFilterWork		proc				; work code	
	lea 	edx,[ebp+semFilterData.tmp]
	
	push	2
	pop	ecx
	@@POLE_LOOP:
	
		fld	[edx+semFilterTmp.s1a]
		fld	[edx+semFilterTmp.s2a]
		mov	al,2
		@@FREQ_LOOP:
		
			fld	st(1)                   	;T1
			fmul	st,st(4)                	;T1*res
			fadd	st,st(1)                	;T2 + T1*res
			fsubr	st,st(3)                	;Input - (T2 + T1*res)
			fmul	st,st(5)                	;(Input - (T2 + T1*res))*cut
			faddp	st(2),st(0)                	;T1 += (Input - (T2 + T1*res))*cut
			fld	st(4)                   	;cut
			fmul	st,st(2)                	;cut*T1
			faddp	st(1),st                	;T2 += T1*cut
		
		dec	al
		jnz	@@FREQ_LOOP  
	
		fxch	st(2)					;xchg(s2x,Input)
		fstp	st(0)					;free(Input)
		
		fst	[ebp+semFilterData.out_bp]		;store(bandpass)		
		fstp	[edx+semFilterTmp.s1a]     	    	;store(T1)		
		fst	[edx+semFilterTmp.s2a]     	    	;store(T2)
		add	edx,2*4
 	 	
	loop	@@POLE_LOOP
	
	fst	[ebp+semFilterData.out_lp]
	fsubr	[ebp+semFilterData.in_smp]			;input-lp(input) = hp(input)
	fstp	[ebp+semFilterData.out_hp]
	
	fstp	st(0)						;free(RES)
	fstp	st(0)						;free(CUT)
semFilterWorkEnd::
semFilterWork		endp
