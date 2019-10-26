;			By SpaceCommander / ByTeGeiZ
.MODEL SMALL
.STACK 200h
 Stackgrî·e=200h
.486p
.CODE
Start:
 mov	ax,@DATA
 mov	ds,ax
 mov	es,ax
 call	Optionen_lesen
 jmp	MenÅ

;<<<---Includes--->>>
include Inc\Routins.inc
include Inc\Ki.inc
include Work.inc		;îî
include Inc\Modi.inc
include Inc\Logo.inc
include Inc\Daten.inc

END Start
