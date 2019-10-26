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



;semPercussion (macro)
;
;ACTION:	
;
;PANEL:
;       		     
;		>    <	      _______________
;	GATE	[0||1]	--0--|               |
;	OscFrq	[-..+]	--1--|               |
;	PtcTon	[0..+]	--2--|  	     |
;	PtcDec	[0..1]	--3--| semPercussion |-- out
;	VolSus	[0..+]	--4--|               |
;	VolDec	[0..1]	--5--|               |
;	  		     |_______________|
;				
;COMMENT: a kick


semPercussion_gate	= 5
semPercussion_freq1	= 4
semPercussion_tone	= 3
semPercussion_pdec	= 2
semPercussion_vsus	= 1
semPercussion_vdec	= 0

semPercussionData struct			

	;output_data (must 4*NUM_OUTPORTS_MAX bytes)
	out_dummy0	dd ?		
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
		
semPercussionData ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.data

semPercussionWork	LABEL byte		;macro_ensemble

;1
module		semSR			;Pitch-Env
connect		0,semPercussion_tone	;inp
connect		0,semPercussion_gate	;gate
connect_const	const_0			;sustain time
connect		0,semPercussion_pdec	;release decay

;2
module		semAdder
connect		1,0
connect		0,semPercussion_freq1

;3
sampler		SES_SIN, SMP_READ+SMP_LOOP
connect		2,0
connect_const	0

;4
module		semSR			;VOLUME SR-Env
connect		3,0			;inp
connect		0,semPercussion_gate	;gate
connect		0,semPercussion_vsus	;sustain time
connect		0,semPercussion_vdec	;release decay

;5
module		semOut
connect		4,0 	;out3
connect		4,0	;out2
connect		4,0	;out1
connect		4,0	;out0
		
db -1		;end of macro