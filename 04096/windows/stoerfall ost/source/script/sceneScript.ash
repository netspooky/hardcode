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



sgSceneScript	label byte

; ----- scene -----------------------------------
	sgNewObject
;obj 0
	;sgColor		00C0C0C0h
	;sgCylinder	80,20,8

; ----- robot -----------------------------------
        sgNewObject			; robot's stand
;obj 1
        sgLink		-1
        ;sgPivot		-100,0,0
        sgColor		008Fh ;000080F0h
        sgCylinder	40,2,5
        sgTranslateY	30
        sgCylinder	40,2,5
        sgColor		0888h ;00808080h
        sgTranslateY	15
        sgCylinder	35,15,5
        ;sgTranslateX	-12
        ;sgTranslateY	36
        ;sgCone		20,28,6,2
        sgTranslateX	-6
        sgTranslateY	38
        sgCone		20,28,6,2
        ;sgCylinder	28,6,2

        sgNewObject			; upper arm
;obj 2
        sgLink		-1
        sgPivot		12,45,0
        sgColor		008Fh ;000080F0h

        sgCylinder	18,7,4
        sgTranslateY	-8
        sgCone		18,16,1,4
        sgTranslateY	8
        sgCone		16,18,1,4
        sgSwapZY	(16+16+16)*3
        ;sgCylinder	18,9,4
        ;sgSwapZY	16*3

        sgTranslateY	50
        sgTranslateX	-4
        sgCone		6,12,50,2
        sgTranslateX	4
        sgCone		6,12,50,2
        sgSwapYX	8*3

        sgNewObject			; arm
;obj 3
	sgLink		-1
        sgPivot		100,0,0
        ;sgColor		000080F0h
        sgCylinder	10,6,4
        ;sgTranslateY	6
        ;sgCone		9,10,1,16
        ;sgTranslateY	-6
        ;sgCone		10,9,1,16
        sgSwapZY	16*3;(16+16+16)*3
        sgTranslateY	40
        sgTranslateX	-2
        sgCone		3,7,40,2
        sgTranslateX	2
        sgCone		3,7,40,2
        sgSwapYX	8*3

        sgNewObject			; hand
;obj 4
        sgLink		-1
        sgPivot		80,0,0
        ;sgColor		000080F0h
        sgCylinder	5,4,4
        sgSwapZY	16*3

        sgNewObject			; manipulator
;obj 5
        sgLink		-1
        sgColor		0888h ;00808080h
        sgTranslateY	4
        sgCylinder	4,4,4
        ;sgTranslateY	9
        ;sgCone		3,4,1,4
        sgSwapYX	16*3;(16+16)*3
        sgColor		0CCCh ;00C0C0C0h
        sgTranslateY	0
        sgTranslateX	10
        sgDisc		3,2

        sgNewObject			; plate
;obj 6
        sgLink		-1
        sgPivot		51,0,0
        sgColor		0F80h ;00F08000h
        sgDisc		56,2

; ----- press -----------------------------------
	sgNewObject
;obj 7
	sgLink		-7
	;sgPivot		0,0,-100
	sgColor		0888h ;00808080h
	sgTranslateY	15
	sgCylinder	70,15,2
	sgTranslateY	100
	sgTranslateX	50
	sgTranslateZ	50
	sgCylinder	7,100,4
	sgTranslateZ	-50
	sgCylinder	7,100,4
	sgTranslateX	-50
	sgCylinder	7,100,4
	sgTranslateZ	50
	sgCylinder	7,100,4

	sgNewObject
;obj 8
	sgLink		-1
	;sgPivot		0,120,0
	sgTranslateY	10
	sgCylinder	60,10,2
	sgTranslateY	25
	sgCylinder	85,5,2

        sgNewObject			; plate
;obj 9
        sgLink		-2
        sgPivot		0,31,0
        sgColor		0F80h ;00F08000h
        sgDisc		56,2

; ----- band ------------------------------------
	sgNewObject
;obj 10
	sgLink		-10
	;sgPivot		100,8,0
	sgColor		0888h ;00808080h
	sgCylinder	8,55,4
	sgTranslateZ	-100
	sgCylinder	8,55,4
	sgTranslateZ	100
	sgCylinder	8,55,4
	sgSwapZY	(16+16+16)*3
	sgTranslateZ	0
	sgTranslateY	6
	sgTranslateX	50
	sgDisc		71,2
	sgTranslateX	-50
	sgDisc		71,2

; ----- press copy 1 ----------------------------
	sgCopyObject	-4,3
;obj 11,12,13

; ----- robot copy 1 ----------------------------
	sgCopyObject	-13,6
;obj 14-19

; ----- robot copy 2 ----------------------------
	sgCopyObject	-6,6
;obj 20-25

; ----- robot copy 3 ----------------------------
	sgCopyObject	-6,6
;obj 26-31

; ----- traverse --------------------------------
	sgNewObject
;obj 32
	sgLink		-32
	sgTranslateZ	-70
	sgCylinder	3,83,2
	sgTranslateZ	0
	sgTranslateX	83
	sgCylinder	3,200,2
	sgSwapYX	4*3
	sgTranslateY	-35
	sgCylinder	3,37,2
	sgSwapZY	4*3

; ----- traverse copy 1 -------------------------
	sgCopyObject	-1,1
; obj 33

; ----- traverse copy 2 -------------------------
	sgCopyObject	-1,1
; obj 34

; ----- band copy 1 -----------------------------
	sgCopyObject	-25,1
; obj 35

; ----- band copy 2 -----------------------------
	sgCopyObject	-1,1
; obj 36

; ----- band copy 3 -----------------------------
	sgCopyObject	-1,1
; obj 37

; ----- traverse plates -------------------------
	sgNewObject
; obj 38
	sgLink		-38
        sgColor		0F80h ;00F08000h
        sgDisc		56,2
        sgSwapYX	4*3
	
; ----- traverse plates copy 1 ------------------
	sgCopyObject	-1,1
; obj 39

; ----- traverse plates copy 2 ------------------
	sgCopyObject	-1,1
; obj 40

; ----- traverse plates copy 3 ------------------
	sgCopyObject	-1,1
; obj 41

; ----- band plates -----------------------------
	sgNewObject
; obj 42
	sgLink		-42
        ;sgColor		00F08000h
        sgDisc		56,2
        sgTranslateX	100
        sgDisc		56,2
        sgTranslateX	-100
        sgDisc		56,2

; ----- band plates copy 1 ----------------------
	sgCopyObject	-1,1
; obj 43

; ----- band plates copy 2 ----------------------
	sgCopyObject	-1,1
; obj 44

; ----- positions -------------------------------
        sgLinear	200,4,1
        	sgCPoint	0/SPL_MUL,300/SPL_MUL,0/SPL_MUL,1	; light 0

        sgLinear	205,3,15
        	sgCPoint	550/SPL_MUL, 0/SPL_MUL, 150/SPL_MUL	; robot 1
        	sgCPoint	550/SPL_MUL, 0/SPL_MUL, -150/SPL_MUL	; robot 2
        	sgCPoint	-550/SPL_MUL, 0/SPL_MUL, -150/SPL_MUL	; robot 3
        	sgCPoint	-550/SPL_MUL, 0/SPL_MUL, 150/SPL_MUL	; robot 4
        	sgCPoint	-550/SPL_MUL, 0/SPL_MUL, 0/SPL_MUL	; press 1
        	sgCPoint	550/SPL_MUL, 0/SPL_MUL, 0/SPL_MUL	; press 2
        	sgCPoint	0/SPL_MUL, 80/SPL_MUL, -300/SPL_MUL	; traverse 1
        	sgCPoint	400/SPL_MUL, 80/SPL_MUL, -300/SPL_MUL	; traverse 2
        	sgCPoint	-400/SPL_MUL, 80/SPL_MUL, -300/SPL_MUL	; traverse 3
        	sgCPoint	300/SPL_MUL, 5/SPL_MUL, 150/SPL_MUL	; band 1
        	sgCPoint	100/SPL_MUL, 5/SPL_MUL, 150/SPL_MUL	; band 2
        	sgCPoint	-100/SPL_MUL, 5/SPL_MUL, 150/SPL_MUL	; band 3
        	sgCPoint	-300/SPL_MUL, 5/SPL_MUL, 150/SPL_MUL	; band 4
        	sgCPoint	0/SPL_MUL, 15/SPL_MUL, 150/SPL_MUL	; band plates
        	sgCPoint	0/SPL_MUL, 120/SPL_MUL, -300/SPL_MUL	; trav plates
        	
; ----- camera animation ------------------------

comment #+
        ; campos
        sgLinear	220,3,8
        	sgCPoint	-280/SPL_MUL,50/SPL_MUL,50/SPL_MUL
        	sgCPoint	350/SPL_MUL,200/SPL_MUL,50/SPL_MUL
        	sgCPoint	450/SPL_MUL,70/SPL_MUL,-40/SPL_MUL
        	sgCPoint	200/SPL_MUL,50/SPL_MUL,-50/SPL_MUL
        	sgCPoint	-200/SPL_MUL,200/SPL_MUL,-100/SPL_MUL
        	sgCPoint	100/SPL_MUL,150/SPL_MUL,100/SPL_MUL
        	sgCPoint	450/SPL_MUL,450/SPL_MUL,600/SPL_MUL
        	sgCPoint	-450/SPL_MUL,550/SPL_MUL,600/SPL_MUL

	; lookat
        sgLinear	210,3,8
        	sgCPoint	-200/SPL_MUL,0/SPL_MUL,150/SPL_MUL
        	sgCPoint	200/SPL_MUL,0/SPL_MUL,150/SPL_MUL
        	sgCPoint	600/SPL_MUL,70/SPL_MUL,50/SPL_MUL
        	sgCPoint	550/SPL_MUL,100/SPL_MUL,0
        	sgCPoint	-500/SPL_MUL,100/SPL_MUL,0/SPL_MUL
        	sgCPoint	500/SPL_MUL,100/SPL_MUL,-300/SPL_MUL
        	sgCPoint	150/SPL_MUL,0/SPL_MUL,0/SPL_MUL
        	sgCPoint	-150/SPL_MUL,100/SPL_MUL,0/SPL_MUL
+#
        sgLinear	210,6,8
        	sgCPoint	-280/SPL_MUL,50/SPL_MUL,50/SPL_MUL,	-200/SPL_MUL,0/SPL_MUL,150/SPL_MUL
        	sgCPoint	350/SPL_MUL,200/SPL_MUL,50/SPL_MUL,	200/SPL_MUL,0/SPL_MUL,150/SPL_MUL
        	sgCPoint	450/SPL_MUL,70/SPL_MUL,-40/SPL_MUL,	600/SPL_MUL,70/SPL_MUL,50/SPL_MUL
        	sgCPoint	200/SPL_MUL,50/SPL_MUL,-50/SPL_MUL,	550/SPL_MUL,100/SPL_MUL,0
        	sgCPoint	-200/SPL_MUL,200/SPL_MUL,-100/SPL_MUL,	-500/SPL_MUL,100/SPL_MUL,0/SPL_MUL
        	sgCPoint	100/SPL_MUL,150/SPL_MUL,100/SPL_MUL,	500/SPL_MUL,100/SPL_MUL,-300/SPL_MUL
        	sgCPoint	450/SPL_MUL,450/SPL_MUL,600/SPL_MUL,	150/SPL_MUL,0/SPL_MUL,0/SPL_MUL
        	sgCPoint	-450/SPL_MUL,550/SPL_MUL,600/SPL_MUL,	-150/SPL_MUL,100/SPL_MUL,0/SPL_MUL

; ----- robot animation -------------------------
        sgLinear	20,3,7		; pos/16,dim,points
        	sgCPoint	4,-15,11
        	sgCPoint	23,-18,-23
        	sgCPoint	23,-18,-23
        	sgCPoint	8,-24,16
        	sgCPoint	23,-18,-23
        	sgCPoint	23,-18,-23
        	sgCPoint	4,-15,11
comment #+
        sgLinear	22,1,7		; pos/16,dim,points
        	sgCPoint	0
        	sgCPoint	0
        	sgCPoint	18
        	sgCPoint	18
        	sgCPoint	18
        	sgCPoint	0
 	      	sgCPoint	0

        sgLinear	23,1,7		; pos/16,dim,points
        	sgCPoint	36
        	sgCPoint	36
        	sgCPoint	18
        	sgCPoint	18
        	sgCPoint	18
        	sgCPoint	36
        	sgCPoint	36
+#
        sgLinear	22,2,7		; pos/16,dim,points
        	sgCPoint	36,0
        	sgCPoint	36,0
        	sgCPoint	18,18
        	sgCPoint	18,18
        	sgCPoint	18,18
        	sgCPoint	36,0
 	      	sgCPoint	36,0

        sgLinear	30,5,5		; pos/16,dim,points
        	sgCPoint	54,8,-24,16,0
        	sgCPoint	54,23,-18,-23,-5
        	sgCPoint	18,18,-21,3,18
        	sgCPoint	54,23,-18,-23,-5
        	sgCPoint	54,8,-24,16,0
        	
; ----- band animation --------------------------
        sgLinear	50,3,2
        	sgCPoint	-30,10,50
        	sgCPoint	-50,-10,30

; ----- traverse animation ----------------------
        sgLinear	70,4,2
        	sgCPoint	-110,-55,0,55
        	sgCPoint	-55,0,55,110
        	;sgCPoint	-80,-40,10,60
        	;sgCPoint	-60,-10,40,90

; ----- press animation 1 -----------------------
        sgLinear	60,1,3		; pos/16,dim,points
        	sgCPoint	30
        	sgCPoint	6
        	sgCPoint	30

; ----- press animation 2 -----------------------
        sgLinear	80,1,3		; pos/16,dim,points
        	sgCPoint	30
        	sgCPoint	6
        	sgCPoint	30

        sgEnd
