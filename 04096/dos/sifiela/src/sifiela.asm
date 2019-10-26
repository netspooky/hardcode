.model tiny
.386

.DATA
;System-stuff
oldtimeroffs		dw	?
oldtimerseg		dw	?

;Global stuff
buffer			dw	?
framecounter		dw	-100
tempint			dw	?
tempreal		dd	?
templong		dd	?
rndseed			dd	1;3713942343
rndseed2		dd	1;81363361
x			dw	?
y			dw	?
color			dw	?

part			dw	0

;Line
fx			dd	?
fy			dd	?
fkx			dd	?
fky			dd	?

;Mandel
mandelcounter		dw	0
mandelswapcounter	dw	0
mandelbuffer1		dw	?
mandelbuffer2		dw	?
mandelbackbuffer	dw	?
mandelx			dq	?
mandely			dq	?
mandelxslope		dq	0.00000001
mandelyslope		dq	0.00000001
mandelx1		dq	?;-1.0
mandely1		dq	?;-1.0
mandelx2		dq	?;1.0
mandely2		dq	?;1.0
;mandeltargetx		dq	-1.27755134601495300000
;mandeltargety		dq	-0.07625233905877038000
;mandeltargetx		dq	0.43362156065801610000
;mandeltargety		dq	-0.23008415331001830000
;mandeltargetx		dq	0.15633055067251350000
;mandeltargety		dq	0.63824909139885590000
mandeltargetx		dq	-0.64761106764636660000
mandeltargety		dq	-0.47911836783711840000
mandeldx		dq	4.0
mandeldy		dq	3.0
;mandeltargetx		dd	-0.75
;mandeltargety		dd	0.0
;mandelzoom		dq	0.005
mandelzoom		dq	6.0
MANDELZOOM2		dq	0.005
mx			dq	?
my			dq	?
mx2			dq	?
my2			dq	?
nmx			dq	?
nmy			dq	?
mandelsize		dd	?
mandelyphase		dw	0
mandelystart		dw	0
mandelyend		dw	200

;Texture
x1			dw	?
y1			dw	?
x2			dw	?
y2			dw	?
xd			dw	?
yd			dw	?
tx1			dw	?
ty1			dw	?
tx2			dw	?
ty2			dw	?
txd			dw	?
tyd			dw	?
txk			dd	?
tyk			dd	?
tx			dw	?
ty			dw	?

;Bilerp
btx			dd	?
bty			dd	?
btx1			dd	?
bty1			dd	?
btextx1			dw	?
btexty1			dw	?
btextx2			dw	?
btexty2			dw	?
btextfx			dd	?
btextfy			dd	?
btext1fx		dd	?
btext1fy		dd	?
color1			dw	?
color2			dw	?
color3			dw	?
color4			dw	?


;Constants
CONST65536		dd	65536.0
CONST255		dd	255.0
CONST63			dd	63.0
CONST4			dd	4.0
CONST2			dd	2.0
CONST0_5		dd	0.5
CONST320		dd	320.0
CONST200		dd	200.0
CONSTOO320		dd	0.003125
CONSTOO200		dd	0.005
CONSTASPECT		dd	0.75
CONSTEPSILON		dd	0.000001

MANDELSPEED		dw	100
;MANDELZOOMBASE		dd	1.0139594797900291386901659996282
MANDELZOOMBASE		dd	?
ZOOMMUL			dd	0.9
ZOOMCONST		dd	0.1
ZOOMSTART		dd	10.0

PART1LENGHT		=	1150
PART2LENGHT		=	200
PART3LENGHT		=	3000
PART4LENGHT		=	3500
PART5LENGHT		=	1050
PART6LENGHT		=	200

;Name
font			dw	?
namelenght		db	7
letter			dw	?
charx			dw	?
chary			dw	?
introname		db	"Sifiela"

endstring		db	"Sifiela  -  4kB-intro for Assembly'02 by Itchi / Lonely Coders$"





;3D-stuff

vector_s struc
	vector_x	dd	?
	vector_y	dd	?
	vector_z	dd	?
vector_s ends

VECTORSIZE		=	size vector_s

;Spring
spring_s struc
	spring_v1	dw	?
	spring_v2	dw	?
	spring_length	dd	?
spring_s ends

SPRINGSIZE		=	size spring_s

;Transformed vertex
vertex_s struc
	vertex_x	dd	?
	vertex_y	dd	?
	vertex_z	dd	?
	vertex_rx	dd	?
	vertex_ry	dd	?
	vertex_rz	dd	?
	vertex_px	dd	?
	vertex_py	dd	?
	vertex_color	db	?
	
	;Movement
;	vertex_mass	dd	?
	vertex_vx	dd	?
	vertex_vy	dd	?
	vertex_vz	dd	?
vertex_s ends

VERTEXSIZE		=	size vertex_s

;line_s struc
;	line_v1		dw	?
;	line_v2		dw	?
;line_s ends
;
;LINESIZE		=	size line_s

triangle_s struc
	triangle_v1	dw	?
	triangle_v2	dw	?
	triangle_v3	dw	?
	triangle_color	db	?
	triangle_fcolor	db	?
	triangle_z	dd	?
triangle_s ends

TRIANGLESIZE		=	size triangle_s


vertexcount		dw		?
vertices		dw		?
;vertices2		dw		?

;linecount		dw		480
;lines			dw		?

trianglecount		dw		?;450
triangles		dw		?

springcount		dw		0
springs			dw		?


camerapos		vector_s	<-1.0, 1.0, -1.3>
cameratarget		vector_s	<0.0, 0.0, 0.0>
cameramatrix		dd		1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0

PERSPECTIVEMUL		dd		177.0

tempvector		vector_s	<?, ?, ?>
vertex1			dw		?
vertex2			dw		?
vertex3			dw		?
vector1			vector_s	<?, ?, ?>
vector2			vector_s	<?, ?, ?>
normal			vector_s	<?, ?, ?>
light			vector_s	<0.0, -1.0, 0.0>

;Cloth
;gridsize		dw		16
CLOTHSCALE		dd		0.05
CLOTHWIDTHC		=		56
CLOTHHEIGHTC		=		8
CLOTHCENTER		=		VERTEXSIZE*(CLOTHWIDTHC*(CLOTHHEIGHTC/2)+CLOTHWIDTHC/2)
CLOTHCENTER1		=		VERTEXSIZE*(CLOTHWIDTHC*(CLOTHHEIGHTC/2)+CLOTHWIDTHC/3)
CLOTHCENTER2		=		VERTEXSIZE*(CLOTHWIDTHC*(CLOTHHEIGHTC/2)+CLOTHWIDTHC*2/3)
clothwidth		dw		CLOTHWIDTHC
clothheight		dw		CLOTHHEIGHTC
v1			dw		?
v2			dw		?
springlength		dd		?
springforce		dd		?
SMALLAMOUNT		dd		0.0005
SMALLAMOUNT2		dd		0.03
INTERPOL		dd		0.999
INTERPOL2		dd		0.99
FRICTION		dd		0.985
GRAVITY			dd		-0.001
GRAVITY2		dd		-0.0002
clothvertices		dw		?
clothtriangles		dw		?
clothvertexcount	dw		?
clothtrianglecount	dw		2*(CLOTHWIDTHC-1)*(CLOTHHEIGHTC-1);450
clip			dw		0

clothcounter		dw		0
oldclothcounter		dw		0

;Triangle
trideltax1		dd		?
trideltay1		dd		?
trideltax2		dd		?
trideltay2		dd		?
trideltax3		dd		?
trideltay3		dd		?
trik1			dd		?
trik2			dd		?
triy			dw		?
trix1			dd		?
trix2			dd		?
triex1			dd		?
triey1			dd		?
triex2			dd		?
triey2			dd		?



;Raytrace
SCREENWIDTH		dw		320
SCREENHEIGHT		dw		200
rayleft			dd		-0.86602540
rayright		dd 		0.86602540
raytop			dd		0.541265875
raybottom		dd		-0.541265875
;raytop			dd		0.59126588
;raybottom		dd		-0.59126588
raydeltax		dd		?,?,?
raydeltay		dd		?,?,?
rayleftside		dd		?,?,?
raycurrent		dd		?,?,?
rayshoot		dd		?,?,?
origin			dd		0.0, 0.0, 0.0
raycorners      	dd 		?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?

.CODE
org 100h

start:
	mov	cs:[datasegment],ds
	jmp	main
datasegment		dw	?




include math.asm

include texture.asm

include font.asm

include timer.asm

include mandel.asm

include triangle.asm

include raytrace.asm

include cloth.asm

include main.asm


end start
