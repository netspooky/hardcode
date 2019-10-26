
LeftP	label dword
	INCLUDE INC\persp.l

_512	dw 512
_128	dw 128
_180	dw 180
yayoX	dw -90
yayoY	dw -90

bump_x	dw ?
bump_y	dw ?

SegFont dw ?
OfsFont dw ?

stosF	dw ?
liczN	dw ?

wyn	dw ?
_x	dw ?
_y	dw ?

obrazek label byte
kolo	db 128*128 DUP (?)
trasaBump dw 360 DUP (?,?)
trasaWater dw 360 DUP (?,?)
_sin	dw ?
_cos	dw ?
_angle	dw ?

WaterY	dw ?
WaterX	dw ?

ple6	db 100 DUP (?)

cos	dw 1024 DUP (?)

kat dw ?
