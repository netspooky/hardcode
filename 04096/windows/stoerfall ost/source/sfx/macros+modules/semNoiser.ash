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



;semNoiser (macro)
;
;INPUT:		GATE	(to restart envelope)
;		CUT
;		RES
;		SR-ENV-DECAY
;
;PANEL:
;       		      _______________
;		>    <	     |               |
;	GATE	[0||1]	--0--|               |-- lp	
;	Cut	[0..1]	--1--|   semNoiser   |-- bp
;	Res	[0..1]	--2--|      	     |-- hp
;	VolDec	[0..1]	--3--|      	     |-- bp
;			     |_______________|
;
;COMMENT: filtered noise with SR-Volume-Envelope


semNoiser_gate		= 3
semNoiser_cut		= 2
semNoiser_res		= 1
semNoiser_decay		= 0

semNoiserData struct			

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
		
semNoiserData ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
.data

semNoiserWork	LABEL byte		;macro_ensemble

;1
module 		semNoise

;2
module		semSR			;NseVolume-Env
connect		1,0			;inp
connect		0,semNoiser_gate	;gate
connect_const	const_0			;sustain time
connect		0,semNoiser_decay	;release decay

;3
module		semFilter
connect		0,semNoiser_cut		;cut
connect		0,semNoiser_res		;res/bw
connect		2,0			;inp	

;4
module		semOut
connect		3,1 	;out3
connect		3,2	;out2	hp
connect		3,1	;out1	bp
connect		3,0	;out0	lp
		
db -1		;end of macro