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



;semClipper
;
;INPUT:   st(0) INP
;
;OUTPUT:  INP clipped [-1.0..+1.0]
;      
;PANEL:
;	 		   ________________
;		>    <	  |                |    >   	   <
;		          |		   |
;	INP	[-..+]	--|   semClipper   |--	[-1.0..+1.0] OUTPUT   
;			  |                |
;			  |________________|
;
;SIZE:	21

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.data

semClipperData struct			

	;output_data (must 4*NUM_OUTPORTS_MAX bytes)
	output		dd ?		
	out_dummy1	dd ?
	out_dummy2	dd ?
	out_dummy3	dd ?	
	
	;input_data (must 4*NUM_INPORTS_MAX bytes)	(in fpu_stack_order [st(0), st(1), st(2) ...])
	input		dd ?
	in_dummy1	dd ?	
	in_dummy2	dd ?
	in_dummy3	dd ?
	in_dummy4	dd ?
	in_dummy5	dd ?
	in_dummy6	dd ?
	in_dummy7	dd ?
			
semClipperData ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.code

semClipperWork		proc				;work code
    
if ENABLE_P2_OPCODES
.686p
	fld1				;range
	fxch	st(1)			
	fcomi	st(0),st(1)		;cmp (inp,+range)
	fcmovnb	st(0),st(1)		;if  (inp>+range) { st(0) = +range; }
	fxch	st(1)
	fchs				;-range			
	fcomi	st(0),st(1)		;cmp (inp,-range)
	fcmovb	st(0),st(1)		;if  (inp<-range) { st(0) = -range; }
		
	fstp	[ebp+semClipperData.output]
	fstp	st(0)			;free clip
.586p
else
	;SIZE!!!
	fcom [ClipO]                          
	fnstsw ax                                         
	sahf
	ja @@ClipOben                                                      
	
	fcom [ClipU]  
	fnstsw ax    
	sahf
	jb @@ClipUnten                
    
	jmp @@ClipReady                                    
    
	@@ClipOben:                                                             
	ffree st(0)   
	fld [ClipO]  
	jmp @@ClipReady                                                      
	@@ClipUnten:                                       
	ffree st(0)                                         
	fld [ClipU]                                                      
	@@ClipReady:  

	fstp	[ebp+semClipperData.output]

endif

if ENABLE_P2_OPCODES
else

jmp	semClipperWorkEnd

ClipO	dd +1.0
ClipU	dd -1.0
endif

semClipperWorkEnd::
semClipperWork		endp







