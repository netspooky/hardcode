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



;OutputModule for macros

;HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!
; its doing nothing but being called! actually its moving output_data of a macro to macro.output,
; so the upper level ensemble can use it!
; when called in proceed_stream(), input data will be stored at [frame_ptr + SEM_NUM_OUTPORT_MAX*4]
; frame_ptr will have an (-SEM_NUM_OUTPU_MAX*4) offset!!! 
;HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!HACK!
;
;INPUT:   st(0) INP	  
;         st(1) INP
;         st(2) INP
;	  st(3) INP
;
;OUTPUT:  none
;       	
;PANEL:			   ______________
;		INP3	--|              |       
;			  |              |
;		INP2	--|              |
;			  |    semOut    |
;	      	INP1	--|              |
;			  |              |
;		INP0	--|______________|


semOutData struct		

	;output data	
	out0		dd ?		;-> INP0
	out1		dd ?		;-> INP1
	out2		dd ?		;-> INP2
	out3		dd ? 		;-> INP3

	;input data	
	in_dummy0	dd ?
	in_dummy1	dd ?
	in_dummy2	dd ?
	in_dummy3	dd ?
	in_dummy4	dd ?
	in_dummy5	dd ?
	in_dummy6	dd ?
	in_dummy7	dd ?
	
semOutData ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
semOutWork		proc
		
semOutWorkEnd::
semOutWork		endp

