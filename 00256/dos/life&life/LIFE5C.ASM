;Classic Game of Life by TomCat/Abaddon
;Life is Life speaker music with lyrics
;thanks to ern0 for the cooperation

;Compatibility version without IRQ0 speedup
;poor quality drums on newer machines
;but on some old machines it works only this way

notes EQU 512

ORG 100H
 MOV	FS,AX
 IN	AL,61H
 PUSH	AX
 MOV	AL,13H
 INT	10H

 MOV	SI,packed
 MOV	BL,notes-packed
 LEA	DI,[BX+SI]
unpack:
 LODSW
 ADD	CL,AH
 CBW
 DEC	AX
 JS	copy
 STOSB
 JZ	fill
 MOVSB
 SALC
fill:
 DEC	AX
copy:
 XCHG	AX,SI
 ADD	SI,DI
 REP	MOVSB
 XCHG	AX,SI
 DEC	BX
 JNZ	unpack

 MOV	AX,9FB6H
 MOV	ES,AX
 OUT	43H,AL

 MOV	BP,-320
 SUB	BX,BP			; 320 -> BX

main1:
 MOV	SI,[BX] 		; 46CH -> SI (SI>768+320)
 MOV	CH,64000/256
main2:
 CMP	CL,5
 JNZ	nosound
 MOV	DX,DI
 IMUL	AX,[FS:046CH],21	; BPM 95
 PUSH	AX
 SHR	AX,CL			; CL = 5
 MOV	AH,2			; notes = 512
 XCHG	AX,DI
 POP	AX
 CMP	[DI],BH
 JB	drums
 JNL	newnote

 MOV	AL,16
 MUL	BYTE [DI]

beep:
 OUT	42H,AL
 MOV	AL,AH
 OUT	42H,AL
 STC
silent:
 SALC
 OUT	61H,AL

nosound:
 MOV	AH,[ES:BP+SI]
 AND	AH,BH			; Assuming white pixel as blue
 XCHG	AH,[BP+SI]
 ADD	AH,[BX+SI]
 LODSB
 ADD	AX,[BP+SI]
 ADD	AX,[SI]
 ADD	AX,[BX+SI]
 ADD	AL,AH
 CMP	AL,4
 JE	next2
 CMP	[SI],BH
 JNE	next1
change:
 AND	BYTE [ES:SI],BH 	; Converting white pixel to blue
 XOR	BYTE [ES:SI],BH
next1:
 SUB	AL,3
 JZ	change
next2:

 LOOP	main2

 IN	AL,60H
 DEC	AL
 JNZ	main1
 POP	AX
 OUT	61H,AL
 MOV	AL,3
 INT	10H
RETN

tNA DB "NA$"
tIS DB "IS$"
tDAB DB "DAB$"
tLIFE DB "LIFE$"

newnote:
 CMP	DI,DX
 JE	drums
print:
 PUSH	AX
 MOV	DX,BX
 ADD	DL,[DI]
 MOV	AH,9
 INT	21H
 POP	AX
drums:
 TEST	AL,AL
 JNS	kick
 TEST	AH,7
 JNZ	silent
 SUB	AL,128+64+32
 JNC	kick
 ADD	AL,64
 JC	kick
 ADD	AL,32
kick:
 MOV	AH,13
 CMP	AH,AL
 JNC	beep
 MOV	AH,AL
 JMP	beep

tN EQU tNA-320+1
tL EQU tLIFE-320+1
tI EQU tIS-320+1
tD EQU tDAB-320+1
tA EQU tDAB-319+1

;440Hz
C5 EQU 143 ;2280
B4 EQU 151 ;2416
A4 EQU 169 ;2712
G4 EQU 190 ;3044
F4 EQU 214 ;3417
E4 EQU 226 ;3620
D4 EQU 254 ;4063

packed:
DB 1,8,tL,3,A4,1,6
DB tN,2,E4,tN,3,F4,1,2,-7,4,tN,0,G4,tN,3,D4
DB 1,12,tL,3,C5,1,2

DB tI,3,B4,-63,51
DB tA,0,C5,-1,2,tD,2,B4

DB tD,2,A4,tD,2,G4,-127,56,1;,63

;original
;DB 0,0,0,0,0,0,0,0,tL,A4,A4,A4,A4,0,0,0,0,0,0,0
;DB tN,E4,E4,E4,tN,F4,F4,F4,F4,0,0,0,tN,F4,F4,F4,tN,G4,tN,D4,D4,D4,D4
;DB 0,0,0,0,0,0,0,0,0,0,0,0,0,tL,C5,C5,C5,C5,0,0,0

;DB tI,B4,B4,B4,B4,0,0,0,tL,A4,A4,A4,A4,0,0,0,0,0,0,0
;DB tN,E4,E4,E4,tN,F4,F4,F4,F4,0,0,0,tN,F4,F4,F4,tN,G4,tN,D4,D4,D4,D4
;DB 0,0,0,0,0,0,0,0,0,0,0,0,0,tA,C5,tA,C5,tD,B4,B4,B4

;DB tD,A4,A4,A4,tD,G4,G4,G4,tL,A4,A4,A4,A4,0,0,0,0,0,0,0
;DB tN,E4,E4,E4,tN,F4,F4,F4,F4,0,0,0,tN,F4,F4,F4,tN,G4,tN,D4,D4,D4,D4
;DB 0,0,0,0,0,0,0,0,0,0,0,0,0,tL,C5,C5,C5,C5,0,0,0

;DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
;DB 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
