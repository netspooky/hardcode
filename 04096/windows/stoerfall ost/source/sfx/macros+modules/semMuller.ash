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



;semMuller :)
;
;INPUT:	st(0)	INP1
;	st(1)	INP2
;
;OUTPUT:  (INP1*INP2)
;
;PANEL:
;	 		   _______________
;		  >    <  |               |   >    <
;			  |               |
;	INP1 	  [-..+]--|               |
;			  |   semMuller	  |-- [-..+] OUTPUT
;	INP2      [-..+]--|               |
;		          |		  |
;			  |_______________|
;
;COMMENT:	semMaster stops executing seCode !!!
;
;SIZE:	5

semMullerData struct	 

	;output_data (must 4*NUM_OUTPORTS_MAX bytes)
	output		dd ?		
	out_dummy1	dd ?
	out_dummy2	dd ?
	out_dummy3	dd ?	
	
	;input_data (must 4*NUM_INPORTS_MAX bytes)	
	in1		dd ?
	in2		dd ?
	in_dummy2	dd ?
	in_dummy3	dd ?
	in_dummy4	dd ?
	in_dummy5	dd ?
	in_dummy6	dd ?
	in_dummy7	dd ?	
	
semMullerData ends

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.code 

semMullerWork		proc
		
	fmulp 	st(1),st(0)
	fstp	dword ptr [ebp+semMullerData.output]

semMullerWorkEnd::
semMullerWork		endp


