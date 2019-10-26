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




value_links	label byte

	; robot
	gleValLink	VL_POS,205*16+0,1
	gleValLink	VL_POS,205*16+3,14
	gleValLink	VL_POS,205*16+6,20
	gleValLink	VL_POS,205*16+9,26

	; press
	gleValLink	VL_POS,205*16+12,7
	gleValLink	VL_POS,205*16+15,11

	; traverse
	gleValLink	VL_POS,205*16+18,32
	gleValLink	VL_POS,205*16+21,33
	gleValLink	VL_POS,205*16+24,34

	; band
	gleValLink	VL_POS,205*16+27,10
	gleValLink	VL_POS,205*16+30,35
	gleValLink	VL_POS,205*16+33,36
	gleValLink	VL_POS,205*16+36,37

	; press ani
	gleValLink	VL_POSY,80*16-1,8
	gleValLink	VL_POSY,60*16-1,12

	; robot 1 ani
	gleValLink	VL_ANGZ,20*16-3,1+1
	gleValLink	VL_ANGZ,20*16-2,1+2
	gleValLink	VL_ANGZ,20*16-1,1+3
	;gleValLink	VL_ANGY,23*16-1,1+0
	gleValLink	VL_ANGY,22*16-2,1+0

	; robot 2 ani
	gleValLink	VL_ANGY,30*16-5,14+0
	gleValLink	VL_ANGZ,30*16-4,14+1
	gleValLink	VL_ANGZ,30*16-3,14+2
	gleValLink	VL_ANGZ,30*16-2,14+3
	gleValLink	VL_ANGX,30*16-1,14+4

	; robot 3 ani
	gleValLink	VL_ANGY,30*16-5,20+0
	gleValLink	VL_ANGZ,30*16-4,20+1
	gleValLink	VL_ANGZ,30*16-3,20+2
	gleValLink	VL_ANGZ,30*16-2,20+3
	gleValLink	VL_ANGX,30*16-1,20+4

	; robot 4 ani
	gleValLink	VL_ANGZ,20*16-3,26+1
	gleValLink	VL_ANGZ,20*16-2,26+2
	gleValLink	VL_ANGZ,20*16-1,26+3
	gleValLink	VL_ANGY,22*16-1,26+0
	
	; band plates
	gleValLink	VL_POS,205*16+39,42
	gleValLink	VL_POS,205*16+39,43
	gleValLink	VL_POS,205*16+39,44
	
	; band plates ani
	gleValLink	VL_POSX,50*16-1,42
	gleValLink	VL_POSX,50*16-2,43
	gleValLink	VL_POSX,50*16-3,44
	
	; traverse plates
	gleValLink	VL_POS,205*16+42,38
	gleValLink	VL_POS,205*16+42,39
	gleValLink	VL_POS,205*16+42,40
	gleValLink	VL_POS,205*16+42,41
	
	; traverse plates ani
	gleValLink	VL_POSX,70*16-1,38
	gleValLink	VL_POSX,70*16-2,39
	gleValLink	VL_POSX,70*16-3,40
	gleValLink	VL_POSX,70*16-4,41

	; visibility of plates (rob,robcopy1,press)
	gleValLink	VL_VIS,100*16,6
	gleValLink	VL_VIS,100*16,19
	gleValLink	VL_VIS,100*16,9

	; visibility of plates (robcopy2,robcopy3,presscopy1)
	gleValLink	VL_VIS,101*16,25
	gleValLink	VL_VIS,101*16,31
	gleValLink	VL_VIS,101*16,13

	; camera
	;gleValLink	VL_TGT,210*16-3,0
	;;gleValLink	VL_CAM,220*16-3,0
	;gleValLink	VL_CAM,210*16-6,0
	gleValLink	VL_CAM,210*16-6,0

	db 0	; terminator
