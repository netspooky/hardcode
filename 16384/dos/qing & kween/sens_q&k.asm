;Qing & Kween a 16kb intro for the Optimise 97 demo compo, held on the 20th
;of July 1997.  Created by Andrew Griffiths(Raw-Hed)/SENSORY OVERLOAD.
;Much thanks to Shayde and his group Reality for the use of his music code,
;and so Neo Software for their tune.  Thanx guys!
;
;To contact me:ml98gria@sac.ecape.schoolza, or rawhed@hotmail.com
;or visit me in Grahamstown on Stones Hill, at a place called Ce
;
;Greetings must go to:
;
;Maverick - Thanks for everything man, you are a great person!
;Viper    - Hello!  Must meet you sometime dude.
;Celestial Software - Great work!  Keep it up.
;David Turner - So, here it is dude...Show me your megademo.
;Jonno - KaBOOM! hehe
;Timmy - hi there, this is much better than my last intro, yes?!
;Naff - Contact me dude!
;LSD, FLASH, CASTOR, Matthew, and Kyle - What do you think?  Contact me
;Brian Johnson - Hi there...what you think?  Can I code or what?
;Travis Bulford - Dude!  What do you think of this intro?
;Adrian Lopez - Thanx for your help with that keyboard stuff.
;Shayde/REALITY - Thanks for realeasing RAD and the full source dude!
;Neo Software   - I used a tune you made, hope you don't mind ;-)

     		jumps
     		locals

Code16		segment public use16
		assume cs:Code16, ds:Code16

  .MODEL small
   .stack 8192h
   .486
   .DATA

timer dw 0
seed dw 0
tempt dw 0
temp dw 0
source dw 0
dest dw 0
x dw 0
y dw 0
z dw 0
c1 dw 0
c2 dw 0
c3 dw 0
c4 dw 0
c5 dw 0
c  dw 0
d  dw 0
xt dw 0
yt dw 0
cosy dw 0
siny dw 0
ang dw 0
a1 dw 0
a2 dw 0
aa1 dw 0
aa2 dw 0
a dw 0
b dw 0
col db 0
pos2 dw 0

;VARs FOR 3D ROTATION
xx1 dw 0
yy1 dw 0
zz1 dw 0
atemp dw 0
btemp dw 0
ctemp dw 0
dtemp dw 0
tx dw 0
ty dw 0
tz dw 0
cxx dw 0
cyy dw 0
czz dw 0
xrot dw 0  ;the point to rot. around
yrot dw 0
zrot dw 0
xdeg dw 0  ;the rot. angles
ydeg dw 0
zdeg dw 0
xer dw 0
yer dw 0
zer dw 0

r db  0 ;temp var
zztemp dw 0
xer1 dw 0 ;temp var
yer1 dw 0 ;temp var
r1 db 0
g1 db 0
b1 db 0
t dw 0

;vars for polygon
pos   dw 0
angle dw 0
xoff dw 0
yoff dw 0
zoff dw 0
where dw 0
x1 dw 0
x2 dw 0
x3 dw 0
y1 dw 0
y2 dw 0
y3 dw 0
z1 dw 0
z2 dw 0
z3 dw 0
mnx dw 0
mxx dw 0
mny dw 0
mxy dw 0
m1 dw 0
m2 dw 0
m3 dw 0
d1 dw 0
d2 dw 0
d3 dw 0
f1 dw 0
f2 dw 0
f3 dw 0
lz dw 0
rz dw 0

;bumpmap vars
persbum dw 0
nx dw 0
ny dw 0
lx dw 0
ly dw 0
vlx dw 0
vly dw 0
tinc dw 0


;zoomer vars
destx dw 0
desty dw 0
astep dw 0
bstep dw 0

;random number vars
randseed dw 0
rr dw 0

;particles vars
loop1 dw 0
loop2 dw 0

;tmap vars


tmark0x dw 0
tmark1x dw 0
tmark2x dw 0
tmark0y dw 0
tmark1y dw 0
tmark2y dw 0
tstep0x dw 0
tstep1x dw 0
tstep2x dw 0
tstep0y dw 0
tstep1y dw 0
tstep2y dw 0
tmxx dw 0
tmnx dw 0
tmxy dw 0
tmny dw 0
dx1 dw 0
dy1 dw 0
tdx dw 0
tdy dw 0
tx1 dw 0
tx2 dw 0
tx3 dw 0
ty1 dw 0
ty2 dw 0
ty3 dw 0
yy dw 0

;tmap many polys vars
tt dw 0
txx dw 0
tyy dw 0

;font vars
xoffs dw 0
yoffs dw 0

;colchanger vars
colcount db 0

;3d scissors vars
cut dw 0
cutinc dw 0

;3dcube vars
xoffinc dw 0
yoffinc dw 0
zoffinc dw 0

;rotation patterns vars
pat db 0

Text1 DB "SENSORY$"
Text2 DB "OVERLOAD$"
Text3 DB "PRESENTS$"
Text4 DB "  QING  $"
Text5 DB "    &   $"
Text6 DB "  KWEEN $"
Cred1 DB " CODER: $"
Cred2 DB " RAW-HED$"
Endy1 DB "THE END $"
greet1 DB "GREETS:$"
greet2 DB "MAVERICK$"
greet3 DB "VIPER$"
greet4 DB "BURNER$"
greet5 DB "JONNO$"
greet6 DB "TIMMY$"
greet7 DB "NAFF$"


Endtext DB "ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSENSORY OVERLOAD 1997ÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸",0dh
        DB "³ Qing & Kween a 16kb intro for the Optimise 97 demo compo, held on the 20th   ³",0DH
        DB "³ of July 1997.  Created by Andrew Griffiths(Raw-Hed)/SENSORY OVERLOAD.  Much  ³",0DH
        DB "³ thanks to Shayde and his group Reality for the use of his music code, and to ³",0DH
        DB "³ Neo Software for their tune.  Thanx guys!  This is my biggest production yet.³",0dh
        DB "³ ..Source code will be released if requested.  I spent about 2 month working  ³",0dh
        DB "³ on and off, and am in the middle of exams, but it was worth it.  Hope you    ³",0dh
        DB "³ enjoyed the show, and look out for more of my stuff!  Read the .NFO file!    ³",0dh
        DB "³                                                                              ³",0dh
        DB "³ Maverick           - Thanks for everything man, you are a great person!      ³",0dh
        DB "³ Viper              - Hello!  Must meet you sometime dude.                    ³",0dh
        DB "³ David Turner       - So, here it is dude...Show me your megademo.            ³",0dh
        DB "³ Jonno              - KaBOOM! hehe                                            ³",0dh
        DB "³ Timmy              - hi there, this is much better than my last intro, yes?! ³",0dh
        DB "³ Naff               - Contact me dude!                                        ³",0dh
        DB "³ LSD, Matthew, Kyle - What do you think?  Contact me                          ³",0dh
        DB "³ Brian Johnson      - Hi there...what you think?  Can I code or what?         ³",0dh
        DB "³ Travis Bulford     - Dude!  What do you think of this intro?                 ³",0dh
        DB "³ Shayde/REALITY     - Thanks for realeasing RAD and the full source dude!     ³",0dh
	DB "³ Neo Software       - I used a tune you made, hope you don't mind ;-)         ³",0dh
        DB "³                                                                              ³",0dh
        DB "³ Contact me: ml98gria@sac.ecape.school.za, or rawhed@hotmail.com              ³",0dh
	DB "ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾$"


rotsin dw 360 dup (?)
rotcos dw 360 dup (?)

Palette LABEL BYTE
	i = 0
	REPT 128 SHR 1
		DB      i, 0, 63-i
		i = i+1
	ENDM
	i = 0
	REPT 128 SHR 1
		DB      63-i, 0, i
		i = i+1
	ENDM


lcosdata db 255,255,255,255,254,254,253,252,251,250,249,247
	db 246,244,242,240,238,236,233,231,228,225
	db 222,219,216,213,210,206,203,199,195,191
	db 188,184,180,176,171,167,163,159,154,150
	db 146,141,137,132,128,124,119,115,110,106
	db 102,97,93,89,85,80,76,72,68,64
	db 61,57,53,50,46,43,40,37,34,31
	db 28,25,23,20,18,16,14,12,10,9
	db 7,6,5,4,3,2,2,1,1

LCOS  dw 16384,16382,16374,16362,16344,16322,16294,16262,16225,16182,16135
      dw 16083,16026,15964,15897,15826,15749,15668,15582,15491,15396
      dw 15296,15191,15082,14968,14849,14726,14598,14466,14330,14189
      dw 14044,13894,13741,13583,13421,13255,13085,12911,12733,12551
      dw 12365,12176,11982,11786,11585,11381,11174,10963,10749,10531
      dw 10311,10087,9860,9630,9397,9162,8923,8682,8438,8192
      dw 7943,7692,7438,7182,6924,6664,6402,6138,5872,5604
      dw 5334,5063,4790,4516,4240,3964,3686,3406,3126,2845
      dw 2563,2280,1997,1713,1428,1143,857,572,286,0

bally db 900 dup (?);the array for the CIRCLE picture, in the bumpmapped part


nicepal db 0,0,0,0,1,1,0,2,3,1,4,5,1,5,7,2,6,9,2,8
db 11,3,9,13,3,11,15,3,12,17,4,13,19,4,15,21,5,16,23,5
db 17,25,6,19,27,6,20,29,7,22,31,7,23,33,7,24,35,8,26,37
db 8,27,39,9,28,41,9,30,43,10,31,45,10,33,47,10,34,49,11,35
db 51,11,37,53,12,38,55,12,39,57,13,41,59,13,42,61,14,44,63,15
db 44,63,17,45,63,18,45,63,20,46,63,21,47,63,23,47,63,24,48,63
db 26,49,63,28,49,63,29,50,63,31,50,63,32,51,63,34,52,63,35,52
db 63,37,53,63,39,54,63,40,54,63,42,55,63,43,55,63,45,56,63,46
db 57,63,48,57,63,49,58,63,51,59,63,53,59,63,54,60,63,56,60,63
db 57,61,63,59,62,63,60,62,63,62,63,63,0,0,0,2,1,0,4,1
db 1,6,2,1,8,2,1,10,3,2,12,4,2,14,4,2,16,5,3,18
db 6,3,20,6,4,22,7,4,24,7,4,26,8,5,28,9,5,30,9,5
db 31,10,6,33,10,6,35,11,6,37,12,7,39,12,7,41
db 13,7,43,13,8,45,14,8,47,15,9,49,15,9,51,16,9,53,17,10
db 55,17,10,57,18,10,59,18,11,61,19,11,63,20,12,63,21,14,63,23
db 15,63,24,17,63,25,18,63,27,20,63,28,22,63,29,23,63,31,25,63
db 32,27,63,34,28,63,35,30,63,36,31,63,38,33,63,39,35,63,40,36
db 63,42,38,63,43,39,63,44,41,63,46,43,63,47,44,63,48,46,63,50
db 47,63,51,49,63,53,51,63,54,52,63,55,54,63,57,56,63,58,57,63
db 59,59,63,61,60,63,62,62,0,0,0,0,0,0,1,1,1,1,2,1
db 2,2,2,2,3,2,3,4,3,4,5,3,4,5,4,5,6,4,5,7
db 5,6,7,5,7,8,6,7,9,6,8,10,7,8,10,7,9,11,8,10
db 12,8,10,12,9,11,13,9,11,14,10,12,15,10,13,15,11,13,16,11
db 14,17,12,14,17,12,15,18,13,16,19,13,16,20,14,17,20,14,17,21
db 15,18,22,15,19,23,16,20,24,17,21,25,19,23,26,20,24,28,22,26
db 29,23,27,30,25,28,31,26,30,33,28,31,34,29,33,35
db 31,34,37,32,35,38,34,37,39,35,38,40,37,40,42,38,41,43,40,42
db 44,41,44,46,43,45,47,44,47,48,46,48,49,47,49,51,49,51,52,50
db 52,53,52,54,55,53,55,56,55,56,57,56,58,58,58,59,60,59,61,61
db 61,62,62,62,0,0,0,1,1,1,2,2,3,3,3,4,4,4,6,5
db 5,7,6,5,9,7,6,10,8,7,12,9,8,13,10,9,15,11,10,16
db 12,11,18,13,12,19,14,13,21,15,14,22,17,14,24,18,15,25,19,16
db 27,20,17,28,21,18,30,22,19,31,23,20,33,24,21,34,25,22,36,26
db 23,37,27,23,39,28,24,40,29,25,42,30,26,43,31,27,45,32,28,46
db 34,29,48,35,30,48,36,31,49,37,32,49,38,33,50,39,34,50,40,35
db 51,41,36,51,41,38,52,42,39,52,43,40,53,44,41,53,45,42,54,46
db 43,54,47,44,55,48,45,55,49,46,56,50,47,56,51,48,57,52,49,57
db 53,50,58,54,51,58,55,52,59,56,53,59,56,55,60,57,56,60,58,57
db 61,59,58,61,60,59,62,61,60,62,62,61,63,63,62,63


photo db 4,66,89,84,69,143,177,143,177,143,177,143,177,143,177,143,177,143,177,143,177,143,177,143,177
db 143,177,143,177,71,1,1,1,69,177,65,13,65,177,61,20,62,177,59,27,57,177,57,15,1
db 1,1,13,55,177,55,19,1,1,1,13,53,177,53,24,1,15,50,177,52,18,1,1,1,14
db 1,5,50,177,51,7,1,14,2,1,1,1,1,6,1,3,1,1,1,3,48,177,50,25,1
db 1,1,4,1,7,1,5,47,177,49,6,1,7,1,2,1,3,1,6,1,6,1,3,1,3
db 1,3,47,177,48,12,1,11,3,1,1,1,2,5,1,12,45,177,47,21,1,2,1,2,2
db 1,2,1,1,5,1,6,1,5,44,177,46,18,1,1,1,2,2,2,2,1,6,1,1,3
db 1,2,1,4,1,3,44,177,45,18,1,2,2,1,14,17,43,177,44,17,1,2,1,1,19
db 3,1,2,1,4,1,4,42,177,44,16,1,1,24,5,1,10,41,177,43,15,30,14,41,177
db 43,15,30,4,1,6,1,2,41,177,42,14,34,13,40,177,41,15,34,2,1,11,39,177,41
db 14,36,2,1,11,38,177,41,13,38,2,1,10,38,177,40,13,39,14,37,177,40,12,42,12
db 37,177,40,12,2,1,40,11,37,177,39,12,5,1,38,12,36,177,39,11,46,11,36,177,39
db 10,3,1,2,1,41,11,35,177,38,12,47,11,35,177,38,10,3,1,1,1,43,11,35,177
db 38,10,1,1,5,1,41,12,34,177,38,9,1,2,2,1,45,11,34,177,37,10,2,1,47
db 12,34,177,37,9,1,2,2,1,46,12,33,177,37,10,1,1,3,1,45,12,33,177,36,10
db 1,1,2,1,47,12,33,177,36,10,1,1,1,1,1,3,1,1,42,12,33,177,36,9,1
db 1,1,1,1,1,1,1,1,7,37,13,32,177,35,14,1,1,2,1,1,1,1,6,16,6
db 1,1,11,13,32,177,35,10,1,1,1,2,1,2,1,1,1,1,1,2,1,4,12,4,1
db 4,1,1,10,13,32,177,35,9,1,2,1,1,1,1,6,1,1,6,11,3,1,2,3,1
db 2,1,1,1,1,1,1,1,4,12,32,177,34,12,1,1,5,1,6,1,2,1,1,1,10
db 1,2,1,1,1,13,1,3,13,31,177,34,10,1,1,1,2,2,1,2,1,2,2,1,1
db 2,1,1,1,33,13,31,177,34,10,1,1,1,1,1,1,1,2,3,1,1,2,1,2,1
db 1,12,1,1,1,1,1,1,1,10,1,4,13,31,177,33,12,2,1,1,2,2,10,1,1
db 1,1,11,1,1,8,9,1,1,13,31,177,33,11,1,2,1,1,1,9,1,4,15,1,2
db 7,1,1,1,1,7,12,31,177,33,11,1,1,1,2,1,3,1,6,1,1,1,1,1,1
db 12,2,3,5,1,2,4,1,3,14,30,177,33,11,2,1,1,2,1,1,4,3,1,2,1
db 1,2,1,12,1,3,4,1,2,1,1,8,13,30,177,33,10,1,1,1,1,2,2,1,2
db 3,1,6,1,20,1,4,1,9,13,30,177,32,12,2,1,4,1,1,1,8,1,1,2,33
db 14,30,177,33,2,2,6,2,1,2,1,11,1,5,1,33,8,3,2,30,177,33,4,1,5
db 1,1,2,1,15,1,3,1,32,7,5,1,30,177,32,3,3,4,1,1,1,1,2,1,15
db 2,35,6,2,2,32,177,31,2,5,5,2,1,16,1,38,6,2,3,31,177,32,3,1,1
db 1,4,2,1,2,1,13,1,1,2,36,6,4,2,30,177,32,2,2,1,1,4,1,1,1
db 1,18,2,35,6,4,1,31,177,31,2,6,2,1,1,1,1,3,1,2,1,10,1,38,5
db 5,2,30,177,32,2,2,4,1,1,1,1,1,1,15,1,1,1,37,2,1,2,6,1,30
db 177,31,2,3,1,1,4,1,1,2,1,16,2,36,2,1,2,6,1,30,177,32,1,2,1
db 1,1,2,1,1,2,1,1,1,1,1,1,12,1,2,1,34,1,3,2,6,1,30,177,32
db 1,1,1,1,3,1,1,1,1,1,1,1,1,3,1,2,1,6,1,2,1,41,2,36,177
db 32,1,2,2,3,2,1,1,1,1,1,1,15,2,34,1,5,3,6,1,28,177,32,1,2
db 2,3,1,1,1,1,1,1,1,2,1,2,1,10,1,1,3,32,1,5,1,7,1,28,177
db 32,3,1,2,3,1,1,1,1,1,1,1,2,1,4,1,6,1,1,4,1,1,2,3,32
db 1,6,1,28,177,34,2,1,1,3,1,1,2,1,1,1,1,2,1,10,5,1,3,1,4
db 22,1,8,1,5,2,28,177,30,2,4,1,3,1,1,1,1,2,1,1,1,1,2,1,1
db 1,8,1,1,2,6,2,21,1,16,2,28,177,30,2,1,1,2,2,1,1,3,1,1,2
db 1,1,2,1,10,1,1,1,4,1,5,1,24,1,12,2,28,177,30,1,3,1,3,2,1
db 2,1,1,2,1,1,1,3,1,2,1,5,2,1,1,47,2,28,177,30,3,11,2,1,1
db 1,2,2,1,10,1,47,4,27,177,30,3,2,1,7,1,1,2,1,1,2,1,9,2,2
db 1,29,1,16,3,28,177,31,4,2,1,1,1,2,1,1,1,1,2,1,1,2,1,1,1
db 1,1,3,1,2,1,47,5,27,177,30,6,2,1,3,2,2,1,1,2,1,1,6,1,2
db 1,2,1,45,6,27,177,30,8,2,5,1,1,2,2,1,2,1,1,3,1,1,1,31,1
db 15,6,28,177,30,14,1,2,1,1,2,1,2,1,2,1,2,1,1,1,1,1,33,2,7
db 9,27,177,30,14,2,2,1,2,2,1,1,1,1,2,2,1,2,3,31,3,1,1,2,11
db 27,177,30,15,1,1,1,1,1,1,1,1,1,1,3,1,1,1,1,2,1,6,1,5,22
db 17,27,177,30,16,1,1,1,1,1,1,1,1,1,2,1,2,1,6,2,3,1,7,18,18
db 27,177,30,16,1,2,1,2,1,1,1,1,1,1,1,7,2,1,10,1,16,1,1,13,1
db 2,1,2,26,177,30,15,1,1,2,1,1,2,1,1,3,1,2,1,7,1,27,19,27,177
db 30,16,1,2,3,1,1,2,1,1,1,2,1,1,34,11,1,7,27,177,30,17,1,2,1
db 1,1,1,2,1,1,1,1,6,10,1,18,1,1,14,1,2,1,2,26,177,30,16,1,1
db 2,2,1,1,1,1,1,1,1,1,2,2,1,1,2,1,3,1,2,1,3,1,17,10,1
db 9,26,177,31,16,1,2,2,1,1,2,1,1,1,2,2,1,1,2,2,1,2,1,23,18
db 1,1,27,177,30,16,1,1,1,1,1,2,2,1,2,1,1,1,1,1,1,1,1,2,1
db 2,2,1,22,21,26,177,30,3,1,13,1,1,1,1,1,1,1,1,1,2,1,1,1,1
db 1,1,4,1,3,1,22,11,1,4,1,5,26,177,31,17,1,1,1,1,1,1,1,1,1
db 2,1,2,1,1,1,1,30,17,1,2,27,177,30,17,1,2,1,2,1,1,1,1,2,1
db 2,1,1,1,2,1,25,1,2,18,1,2,26,177,30,2,1,15,1,2,2,1,1,1,1
db 1,1,2,1,1,30,1,1,11,1,3,1,6,26,177,30,3,1,13,1,1,1,2,1,2
db 2,2,1,1,2,1,28,1,2,16,1,4,27,177,31,17,1,2,1,1,1,1,1,1,2
db 1,1,1,2,1,26,1,3,17,1,2,1,1,26,177,31,16,1,2,1,2,1,2,1,1
db 2,1,5,1,23,1,4,21,27,177,31,2,1,14,1,2,1,1,2,1,1,2,3,1,26
db 2,4,16,1,4,27,177,30,17,1,1,1,2,1,2,1,1,1,2,1,1,26,1,5,20
db 1,1,27,177,31,17,1,1,1,3,1,1,1,1,2,1,1,1,21,1,1,2,5,23,27
db 177,31,2,1,13,1,1,2,2,1,3,1,1,1,1,2,1,18,1,2,1,1,1,2,1
db 3,16,1,4,28,177,31,17,1,2,2,2,1,2,1,2,1,1,2,1,15,1,2,1,1
db 1,6,13,1,4,1,4,27,177,31,17,1,1,2,2,1,1,1,2,2,2,3,1,12,1
db 2,2,1,1,7,22,28,177,30,17,1,1,1,1,3,3,1,3,1,3,2,1,2,1,4
db 1,1,2,1,2,2,1,7,14,1,4,1,4,27,177,30,3,1,14,2,2,3,1,1,1
db 1,3,1,2,1,1,1,2,1,1,1,1,2,1,1,2,1,1,2,1,7,1,1,16,1
db 4,28,177,30,18,1,1,2,1,1,1,1,2,1,1,1,1,1,3,1,2,1,6,1,1
db 2,1,1,1,9,14,1,5,1,2,2,1,25,177,29,18,1,1,1,1,2,1,2,1,1
db 1,1,1,1,2,1,3,1,2,1,1,1,1,1,1,1,1,4,1,8,1,1,15,1,10
db 23,177,28,20,1,1,1,1,3,1,3,1,1,2,1,1,1,4,1,2,1,2,2,1,1
db 1,11,14,1,4,1,5,1,15,10,177,25,24,2,1,1,1,1,1,1,1,2,1,2,1
db 1,1,2,1,1,2,1,1,3,1,3,1,9,2,1,19,1,2,1,21,5,177,10,1,1
db 36,1,1,2,1,3,1,1,1,8,1,5,1,2,1,6,1,8,12,1,4,1,4,1,4
db 1,20,3,177,7,41,1,1,1,1,1,2,3,2,1,1,1,1,5,1,2,1,2,1,3
db 1,11,1,1,13,1,10,1,12,1,1,1,3,1,4,2,177,3,46,1,1,3,1,2,1
db 2,1,3,1,27,19,1,3,1,6,1,4,1,1,1,1,5,1,1,1,1,2,1,177,1
db 47,1,1,1,1,1,1,1,2,1,1,3,1,4,1,12,1,10,2,1,12,1,11,1,2
db 1,8,10,229,1,1,1,1,4,1,1,1,1,1,10,1,4,1,4,1,8,20,1,7,1
db 4,1,1,1,1,5,1,9,226,2,1,1,2,1,1,1,1,1,1,2,1,28,13,1,7
db 1,2,1,6,1,5,2,1,11,227,4,1,1,1,1,1,1,1,1,1,1,1,13,1,12
db 19,1,7,1,2,1,4,2,1,3,1,2,1,7,227,1,2,2,1,1,1,1,1,1,1
db 1,1,2,1,4,1,3,1,5,1,7,1,1,22,1,11,1,3,2,1,5,1,5,227,1
db 1,1,2,1,1,1,2,2,1,2,1,26,27,1,4,1,2,4,1,8,1,2,227,2,1
db 2,1,1,1,1,2,1,2,1,1,1,1,6,1,1,1,2,1,4,1,6,13,1,6,1
db 2,1,3,1,4,1,1,1,2,4,1,9,229,1,1,2,1,2,1,1,2,2,1,1,1
db 1,1,2,1,3,1,4,1,8,1,2,30,1,2,2,1,1,2,4,1,2,1,4,185,1
db 1,1,1,1,2,1,29,1,4,1,2,1,1,1,2,1,1,2,1,1,1,1,2,1,1
db 2,1,5,1,9,1,1,19,1,2,1,3,1,6,1,3,3,1,2,1,5,1,3,192,1
db 1,1,2,1,2,1,27,2,1,1,1,2,2,1,3,1,1,1,1,1,1,1,1,1,1
db 2,1,4,1,2,1,6,28,1,3,1,2,2,1,1,1,12,179,2,1,2,9,1,1,1
db 2,1,2,1,26,1,2,2,1,2,2,2,1,1,1,2,1,1,1,3,1,4,1,6,1
db 3,2,1,28,1,2,3,1,1,1,1,1,2,1,2,1,5,178,1,2,1,2,1,1,1
db 34,1,7,1,2,1,2,1,2,1,1,1,2,1,2,1,1,1,1,2,1,1,1,4,1
db 4,1,2,1,1,17,1,2,1,9,1,2,4,2,7,1,2,1,1,177,1,7,1,1,2
db 1,1,37,1,1,1,2,1,2,1,2,1,1,2,1,2,1,1,1,8,1,7,1,2,27
db 1,4,1,2,1,1,2,1,2,1,5,1,3,181,1,1,1,2,1,2,1,1,2,2,1
db 33,1,1,2,1,2,1,2,1,1,1,2,1,2,1,2,1,2,1,2,1,5,1,4,21
db 1,12,2,1,2,2,3,1,2,1,5,178,1,1,1,42,1,6,1,1,1,2,1,2,1
db 2,1,1,2,1,2,1,2,1,7,1,7,25,1,7,1,2,1,3,7,1,4,178,1,1
db 6,2,1,2,1,38,1,1,1,1,1,1,1,1,1,2,1,1,1,1,2,1,2,1,2
db 1,1,1,1,1,7,1,1,23,1,11,1,2,1,2,2,1,2,1,2,1,4,177,3,1
db 2,1,3,6,1,34,1,2,1,2,1,1,1,1,1,2,1,1,1,1,2,1,5,1,12
db 36,1,1,1,2,2,1,5,1,2,1,1,177,7,1,2,1,2,39,2,2,1,1,1,1
db 1,1,1,2,1,3,1,2,1,2,2,1,9,1,1,24,1,12,1,1,1,1,3,1,2
db 2,5,177,1,1,2,1,2,1,3,1,2,1,1,1,1,2,1,31,1,1,2,1,1,1
db 1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,9,1,2,2,1,33,1,2,1
db 2,2,1,4,1,5,177,3,1,4,1,2,2,1,2,1,2,1,33,1,1,2,1,1,1
db 1,1,1,1,1,2,1,2,2,1,3,1,5,1,5,38,1,2,3,1,3,1,3,1,2
db 177,6,1,2,1,1,1,1,41,1,1,2,1,2,1,1,2,1,1,1,1,1,1,1,1
db 13,1,1,42,2,1,2,1,1,1,4,178,3,1,4,1,1,1,1,1,2,1,2,34,1
db 2,1,1,1,1,3,1,2,1,1,2,1,2,6,1,6,1,1,1,1,2,1,33,1,2
db 1,2,2,1,2,2,5,177,5,1,4,2,1,2,1,37,1,2,1,1,1,1,4,1,1
db 2,7,1,4,1,1,1,1,2,1,1,1,38,1,2,2,1,2,1,2,1,3,178,6,1
db 1,1,1,1,1,40,1,2,1,2,1,2,2,1,1,1,7,1,7,1,1,1,2,1,1
db 1,1,40,2,1,1,1,1,2,3,1,1,177,2,1,2,1,1,1,1,1,1,2,2,1
db 1,34,1,2,1,2,1,2,1,2,2,1,3,1,2,1,3,1,1,1,3,1,2,1,2
db 2,1,38,3,1,2,1,1,1,5,177,4,1,3,1,1,1,1,3,1,36,1,2,1,1
db 1,1,1,1,1,1,1,1,1,2,2,1,3,1,2,1,2,2,2,1,1,1,2,38,1
db 2,1,1,1,1,1,2,1,1,2,179,1,1,3,1,1,2,1,2,1,37,1,1,1,1
db 1,1,1,2,1,1,2,1,1,1,1,1,1,1,1,1,1,1,2,1,2,1,3,1,2
db 1,1,3,1,39,1,1,2,1,1,1,3,1,1,177,2,1,3,2,1,1,1,2,2,34
db 1,1,1,1,1,2,1,1,1,3,1,2,1,1,1,1,2,1,2,1,2,1,1,1,2
db 1,2,1,2,1,1,1,1,37,3,2,1,2,4,180,2,1,2,1,1,1,1,1,1,40
db 1,1,2,2,1,1,1,2,2,1,1,1,1,1,2,1,2,1,2,1,1,1,3,1,1
db 1,2,3,1,34,1,3,1,1,1,1,1,2,1,1,1,1,1,177,4,1,2,2,1,2
db 2,35,1,1,1,2,1,2,1,1,1,1,1,3,1,1,2,1,1,1,1,1,1,2,4
db 1,5,1,2,2,1,37,1,2,1,2,1,1,2,2,1,178,2,1,3,1,1,1,1,37
db 1,1,1,2,1,1,2,1,1,1,1,1,2,2,1,1,2,1,1,1,10,1,4,1,2
db 2,1,35,2,1,1,1,1,2,3,2,1,177,1,1,3,1,1,2,1,1,1,37,1,1
db 2,1,1,1,1,1,2,1,1,1,2,1,2,2,3,1,3,1,2,1,3,1,1,1,4
db 1,2,36,1,4,1,2,2,2,1,177,2,1,3,1,2,3,1,35,1,1,1,2,1,2
db 1,2,2,1,1,1,2,1,2,1,1,1,2,1,1,1,2,1,7,1,1,1,2,38,2
db 2,1,3,2,2,1,178,3,1,2,1,1,37,1,2,1,1,2,1,2,1,1,1,1,1
db 2,1,2,1,5,1,7,2,1,1,8,2,2,34,1,2,1,2,1,1,2,2,1,178,2
db 1,2,1,1,1,1,1,1,35,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 1,1,1,1,2,1,3,1,1,2,6,1,3,1,2,1,1,2,1,34,1,4,1,1,2
db 2,2,178,2,1,2,2,1,2,1,33,1,2,2,1,1,1,1,1,3,1,2,1,2,1
db 2,2,2,1,1,1,3,1,1,1,10,1,3,36,1,2,1,4,2,2,1,178,3,1,2
db 1,1,37,1,1,1,1,1,1,1,1,1,1,4,1,4,1,2,1,2,1,3,1,6,1
db 3,1,6,2,1,2,1,32,1,3,1,1,2,3,1,177,1,1,2,1,1,1,1,1,2
db 28,1,2,1,1,1,2,1,1,2,1,2,1,1,2,4,1,21,1,2,1,2,1,2,1
db 1,39,1,2,2,2,2,178,2,1,1,1,1,36,1,1,2,1,1,1,2,1,5,2,1
db 1,2,1,2,1,11,1,14,1,1,41,2,2,1,179,5,1,1,30,1,1,1,5,1,1
db 1,2,2,1,1,1,3,1,3,1,2,1,1,1,1,2,1,2,1,1,3,1,1,1,5
db 1,2,1,3,2,1,2,1,34,1,2,1,2,2,179,1,1,1,2,1,1,1,29,1,1
db 2,1,2,1,3,1,1,1,2,1,2,1,3,1,6,1,7,1,5,1,1,1,9,41,1
db 1,1,2,2,178,2,1,2,2,1,28,1,4,2,1,2,2,2,1,2,1,2,1,2,1
db 3,1,1,1,4,1,2,1,3,1,2,1,6,1,3,1,3,38,1,2,2,1,1,1,1
db 179,2,1,1,29,1,2,1,1,1,2,1,1,1,1,2,1,2,1,2,1,5,1,5,1
db 2,1,2,1,2,1,7,1,8,1,2,2,1,2,1,36,1,2,1,180,1,1,1,1,1
db 25,1,1,1,1,1,1,2,1,2,1,1,1,4,1,2,1,3,1,2,1,2,1,5,1
db 5,1,3,1,2,1,2,1,1,1,2,1,4,1,1,38,1,1,2,2,1,179,2,1,1
db 2,1,2,1,2,1,17,1,1,1,1,1,1,1,2,2,1,3,1,1,1,2,1,2,1
db 3,1,5,1,1,1,5,1,4,1,2,1,13,1,1,3,1,37,1,2,1,1,1,180,2
db 7,1,2,1,14,1,2,1,1,1,1,1,1,2,1,2,1,2,1,4,1,2,1,4,1
db 6,1,2,1,3,1,8,1,2,1,4,1,4,40,1,1,1,2,1,180,1,2,1,2,1
db 19,2,1,2,1,1,1,1,1,2,1,2,1,1,1,3,1,6,1,2,1,2,1,2,1
db 9,1,2,1,2,1,5,1,4,1,1,1,1,1,1,2,1,30,1,3,1,1,1,2,1
db 182,1,3,1,1,2,2,1,13,1,2,1,1,2,1,2,1,2,1,3,1,2,1,2,1
db 1,1,1,1,2,1,6,1,3,1,2,1,1,1,3,1,5,1,4,1,5,2,1,40,1
db 2,1,183,1,6,1,10,1,2,1,1,2,1,1,1,1,1,2,1,1,1,1,1,1,1
db 3,1,4,1,3,1,12,1,5,1,5,1,3,1,6,1,3,2,1,38,1,1,1,2,1
db 180,1,1,1,1,2,1,1,2,1,8,1,4,1,2,3,1,2,1,3,1,3,1,3,1
db 1,1,3,1,4,1,1,1,1,1,2,1,4,1,2,1,7,1,4,1,3,1,1,2,1
db 1,1,2,1,31,1,4,2,2,1,182,1,1,1,2,1,9,1,6,1,1,2,1,1,1
db 4,1,3,1,3,1,5,1,3,1,2,1,8,1,2,1,4,1,2,1,7,1,2,1,4
db 2,1,2,1,2,1,35,1,185,1,1,1,1,2,2,1,7,1,3,1,1,2,1,2,1
db 1,1,1,1,2,1,1,1,1,1,3,1,1,1,3,1,2,1,4,1,2,1,4,1,3
db 1,3,1,2,1,11,1,3,1,1,3,1,31,1,4,1,1,1,1,1,182,2,1,1,3
db 1,4,1,4,1,2,1,1,1,1,1,1,4,1,3,1,3,1,2,1,2,1,2,1,2
db 1,2,1,6,1,8,1,8,1,2,1,6,1,1,1,1,1,1,1,1,2,1,33,1,1
db 1,186,2,1,1,8,1,1,1,2,1,2,2,1,3,1,4,1,2,1,3,1,3,1,2
db 1,5,1,2,1,2,1,2,1,1,1,2,1,3,1,2,1,2,1,7,1,2,1,3,2
db 2,2,1,31,1,3,1,1,1,184,1,2,1,2,1,3,1,5,1,2,3,1,2,1,2
db 1,2,1,3,1,1,1,2,1,4,1,2,1,2,1,4,1,8,1,3,1,4,1,7,1
db 6,1,1,1,1,2,1,16,1,15,1,3,1,1,1,2,1,182,1,2,1,5,1,2,1
db 1,1,2,2,1,4,1,3,1,2,1,2,1,3,1,3,1,6,1,4,1,4,1,1,1
db 2,1,6,1,7,1,5,1,1,1,1,2,1,1,2,1,1,1,1,15,1,18,2,186,1
db 6,1,4,1,1,1,1,2,1,2,1,3,1,4,1,2,1,4,1,3,1,1,1,1,1
db 2,1,2,1,4,1,3,1,3,1,1,1,4,1,11,1,4,1,1,1,1,1,1,1,1
db 30,1,2,1,2,1,191,1,2,1,2,1,2,1,1,4,1,3,1,2,1,3,1,2,2
db 1,1,2,1,4,1,14,1,7,1,5,1,2,1,2,1,6,1,2,1,2,1,1,2,1
db 14,1,14,1,3,1,1,1,188,1,3,1,2,1,2,2,1,1,1,2,1,2,1,5,1
db 14,1,3,1,1,1,2,1,1,1,1,1,2,1,3,1,2,1,8,1,3,1,2,1,2
db 1,2,1,5,1,1,34,1,1,2,185,2,2,2,2,1,2,19,1,2,1,2,1,2,1
db 2,1,27,1,2,1,14,1,2,1,4,1,1,1,1,1,1,9,1,2,1,2,1,8,3
db 2,1,2,1,2,1,243



lsin dw 360 dup (?);the SIN = of LCOS, but calculated realtime from LCOS const

parts dw 9600 dup (?);the data for the particles...
		     ;1st 1200bytes=x co-ords
		     ;2nd 1200bytes=y co-ords
		     ;3rd 1200bytes=x direction
		     ;4th 1200bytes=y direction

.fardata? starstuff_seg
align 1
Starsxyz dw 1440 DUP (?) ;where all the data is held
starstuff_seg ends

.fardata? starstuff2_seg
align 1
Starsxyz2 dw 1440 DUP (?) ;where all the data is held
starstuff2_seg ends

.fardata? virtualscreen_seg
align 1
screen db 64000 dup (?) ; Virtual screen
virtualscreen_seg ends

.fardata? virtualscreen2_seg
align 1
screen2 db 64000 dup (?) ; Virtual screen
virtualscreen2_seg ends

.fardata? virtualscreen3_seg
align 1
screen3 db 64000 dup (?) ; Virtual screen
virtualscreen3_seg ends

.fardata? virtualscreen4_seg
align 1
screen4 db 64000 dup (?) ; Virtual screen
virtualscreen4_seg ends

.fardata? virtualscreen5_seg
align 1
screen5 db 64000 dup (?) ; Virtual screen
virtualscreen5_seg ends

    .CODE           ; Tells compiler that code is to follow.


;****************************************************************************
;Palettes - Firepal,Metal_rainbowpal,testpal,nicepal
;****************************************************************************

Firepal Proc Near
mov    dx,3c8h
mov    al,0
out    dx,al
inc    dx
mov bl,0
@pal1:
   mov    al,bl
   out    dx,al
   mov    al,0
   out    dx,al
   out    dx,al
   inc bl
cmp bl,64
jne @pal1
mov bl,0
@pal2:
   mov    al,63
   out    dx,al
   mov    al,bl
   out    dx,al
   mov    al,0
   out    dx,al
   inc    bl
cmp bl,64
jne @pal2
mov bl,0
@pal3:
   mov    al,63
   out    dx,al
   out    dx,al
   mov    al,bl
   out    dx,al
   inc    bl
cmp bl,64
jne @pal3
mov al,63
@pal4:
   out    dx,al
   out    dx,al
   out    dx,al
   dec    al
cmp al,0
jnl @pal4
ret
Firepal Endp

Metal_Rainbowpal Proc near
mov r,0
   mov    dx,3c8h
   mov    al,0
   out    dx,al
   inc    dx
@pal1a:
   mov    al,63
   out    dx,al
   mov    al,63
   sub    al,r
   out    dx,al
   mov    al,r
   out    dx,al
   inc    r
cmp r,64
jne @pal1a
mov r,0
@pal2a:
   mov    al,63
   sub    al,r
   out    dx,al
   mov    al,r
   out    dx,al
   mov    al,63
   out    dx,al
   inc    r
cmp r,64
jne @pal2a
mov r,0
@pal3a:
   mov    al,r
   out    dx,al
   mov    al,63
   sub    al,r
   out    dx,al
   mov    al,63
   out    dx,al
   inc    r
cmp r,64
jne @pal3a
mov r,0
@pal4a:
   mov    al,63
   out    dx,al
   mov    al,r
   out    dx,al
   mov    al,63
   sub    al,r
   out    dx,al
   inc    r
cmp r,64
jne @pal4a
ret
Metal_Rainbowpal endp

nicepal_set proc near
   mov    si,0
   mov    dx,3c8h
   mov    al,0
   out    dx,al
   inc    dx
@palnice1:
   mov    al,nicepal[si]
   out    dx,al
   mov    al,nicepal[si+1]
   out    dx,al
   mov    al,nicepal[si+2]
   out    dx,al
add si,3
cmp si,768
jne @palnice1
ret
nicepal_set endp

newpal1 proc near
   mov    si,768;384
   sub    si,3
   mov    dx,3c8h
   mov    al,0
   out    dx,al
   inc    dx
@palnew1:
   mov    al,nicepal[si]
   out    dx,al
   mov    al,nicepal[si+1]
   out    dx,al
   mov    al,nicepal[si+2]
   out    dx,al
sub si,3
cmp si,384;0;768
jne @palnew1
ret
newpal1 endp

redblue_pal proc near
PAL1:
	MOV     DX,3c8h
	MOV     AL,128;
	OUT     DX,AL
	INC     DX
	MOV     CX,(256 SHR 1)*3
	MOV     SI,offset palette
@@pl1:
	 LODSB
	 OUT    DX,AL
	 LOOP   @@pl1

	MOV     DX,3c8h                 ; Setup palette.
	MOV     AL,0
	OUT     DX,AL
	INC     DX
	MOV     CX,(256 SHR 1)*3
	MOV     SI,offset palette       ; Prestored...
@@pl2:
	 LODSB
	 OUT    DX,AL
	 LOOP   @@pl2
ret
redblue_pal endp

;***************************************************************************
;Basic, ground level procedures - flip_and_clear,Smooth_filter,
;                                 Create_LSIN_Table_from_LCOSconst,
;                                 Check_fake_sin_range,Check_fake_cos_range,
;                                 randomy,waitretrace,flip,cls,keypressed
;***************************************************************************

Flip_And_Clear Proc Near
    push ds
    mov     ax,0a000h
    mov     es,ax
    mov     cx,16000
    mov     ax,virtualscreen_seg
    mov     ds,ax
    xor     si,si
    xor     di,di
    rep     movsd
    pop ds
    mov     ax,virtualscreen_seg
    mov     es,ax
    xor     di,di
    xor     eax,eax
    mov     cx,16000
    rep     stosd
ret
Flip_and_clear endp

;FOR SMOOTH_FILTER:
;ES Must be defined(as 0a000h or Virtualscreen_seg)
Smooth_Filter Proc Near
		 xor di,di
		 xor ax,ax
		 mov al,es:[di]
		 xor cx,cx
		 @loopy:
		 inc di
		 mov cl,es:[di]
		 add ax,cx
		 add di,319
		 mov cl,es:[di]
		 add ax,cx
		 sub di,640
		 mov cl,es:[di]
		 add ax,cx
		 shr ax,2
		 add di,320
		 stosb
		 cmp di,63999
		 jnae @loopy

       xor di,di
       mov cx,640
       xor ax,ax
       rep stosw
       mov di,63360
       mov cx,640
       rep stosw
ret
Smooth_Filter Endp

Create_LSIN_Table_from_LCOSconst proc near
mov di,0
mov si,180
@lsin_loop:
mov ax,word ptr lcos[si]
mov word ptr lsin[di],ax
add di,2
sub si,2
cmp di,180
jne @lsin_loop
ret
Create_LSIN_Table_from_LCOSconst endp



Check_fake_sin_range proc near
    ;{if (a1>89) and (a1<180) then aa:=(90-(a1-90));
    ;if (a1>179) and (a1<270) then aa:=-(a1-180);
    ;if (a1>269) and (a1<360) then aa:=(a1-360);    }
    @chek_sinagain1:
    cmp a1,360
    jle @sinfine1
    sub a1,360
    jmp @chek_sinagain1
    @sinfine1:

    mov ax,a1
    cmp ax,90
    jl @out1sin
    cmp ax,179
    jg @out1sin
    sub ax,180
    neg ax
    mov aa1,ax
    @out1sin:
    mov ax,a1
    cmp ax,180
    jl @out2sin
    cmp ax,269
    jg @out2sin
    sub ax,179
    neg ax
    mov aa1,ax
    @out2sin:
    mov ax,a1
    cmp ax,270
    jl @out3sin
    cmp ax,360
    jg @out3sin
    sub ax,360
    mov aa1,ax
    @out3sin:

    @chek_sinagain2:
    cmp aa1,360
    jle @sinfine2
    sub aa1,360
    jmp @chek_sinagain2
    @sinfine2:

ret
check_fake_sin_range endp

Check_fake_cos_range proc near
    ;{if (a2>89) and (a2<180) then aa2:=-abs(90-(a2-90));
    ;if (a2>179) and (a2<269) then aa2:=-abs(a2-180);
    ;if (a2>270) and (a2<360) then aa2:=abs(a2-360); }
    @chek_cosagain1:
    cmp a2,360
    jle @cosfine1
    sub a2,360
    jmp @chek_cosagain1
    @cosfine1:

    mov ax,a2
    cmp ax,90
    jl @out1cos
    cmp ax,179
    jg @out1cos
    sub ax,180
    mov aa2,ax
    @out1cos:
    mov ax,a2
    cmp ax,180
    jl @out2cos
    cmp ax,269
    jg @out2cos
    sub ax,179
    neg ax
    mov aa2,ax
    @out2cos:
    mov ax,a2
    cmp ax,270
    jl @out3cos
    cmp ax,360
    jg @out3cos
    sub ax,360
    neg ax
    mov aa2,ax
    @out3cos:

    @chek_cosagain2:
    cmp aa2,360
    jle @cosfine2
    sub aa2,360
    jmp @chek_cosagain2
    @cosfine2:

    ret
Check_fake_cos_range endp

Randomy Proc near
pusha
mov ax,seed
mov bx,8403h  ;change this number to generate a different landscape
mul bx
inc ax
mov seed,ax
mov tempt,dx
popa
ret
Randomy Endp

waitretrace proc near
    mov dx,3DAh
@v1:
    in al,dx
    and al,08h
    jnz @v1
@v2:
    in al,dx
    and al,08h
jz  @v2
ret
waitretrace endp


FLIP proc near
push ds
    mov     es,dest
    mov     cx,16000
    mov     ds,source
    xor     si,si
    xor     di,di
    rep     movsd
pop ds
ret
FLIP endp

CLS proc near
mov es,ax
xor di,di
mov cx,32000
xor ax,ax
rep stosw
ret
CLS endp


keypressed proc near
mov ah,1
int 16h
jz @no_keypressed
mov ah,0
int 16h
cmp al,27                 ;looks for the ESC key(27)
jne @no_keypressed
;call	ResetInt
;call	EndPlayer
mov     ax,0003h
int     10h       ; Get into 80x25 text mode
xor ax,ax
mov ah,09h
mov dx,offset EndText
int 21h           ;writes the end message on the screen
call bounce_text
mov     ax,4c00h  ; This function exits the program
int     21h       ; and returns control to DOS.
@no_keypressed:
ret
keypressed endp

blur_off proc near
mov timer,0
@kill_with_smooth:
mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
mov ax,0a000h
mov dest,ax
mov ax,virtualscreen_seg
mov source,ax
call flip
inc timer
cmp timer,65
jne @kill_with_smooth
ret
blur_off endp

;****************************************************************************
;*                                                                          *
;*ALL the Starfield code, including patterns..drawing..moving..and morfing  *
;*The procedure are : 1)Init_points,init_points2,init_points3,init_points4  *
;*                    2)Display_stars,Move_stars                            *
;*                    3)Morphsf,Starfield_do,Complete_sf_seq                *
;*                                                                          *
;****************************************************************************

;****************************************************************************
;Starfield - Initpoints
;****************************************************************************

init_points proc near
mov di,0
mov cx,1
mov ax,Starstuff2_seg
mov es,ax
mov a,0
@morestars:
call randomy
mov ax,tempt
shl ax,7
shr ax,1
sub ax,16384
stosw

add di,718
call randomy
mov ax,tempt
shl ax,7
shr ax,1
sub ax,16384
stosw

add di,718
mov ax,cx
stosw

inc cx
sub di,1440
;cmp di,720
inc a
cmp a,360
jnae @morestars
;jnae @morestars
ret
Init_Points Endp

;****************************************************************************
;Starfield - Initpoints2
;****************************************************************************

init_points2 proc near
mov di,0
mov cx,1
mov a,0
@morestars2:
mov ax,Starstuff2_seg
mov es,ax

mov cx,a
mov a1,cx
mov aa1,cx
mov a2,cx
mov aa2,cx

call check_fake_sin_range
call check_fake_cos_range
mov si,aa1
cmp si,0
jg @fine1
neg si
@fine1:
shl si,1
mov ax,word ptr lsin[si]
cmp aa1,0
jg @noabs_now1
neg ax
@noabs_now1:
;sar ax,8
stosw

add di,718
mov si,aa2
cmp si,0
jg @fine2
neg si
@fine2:
shl si,1
mov ax,word ptr lcos[si]
cmp aa2,0
jg @noabs_now2
neg ax
@noabs_now2:
;sar ax,8
stosw

add di,718
mov ax,cx
stosw


inc a
sub di,1440
cmp a,360
jnae @morestars2
;cmp di,720
;jnae @morestars2
ret
Init_Points2 Endp

;****************************************************************************
;Starfield - Initpoints3
;****************************************************************************

init_points3 proc near
mov di,0
mov cx,1
mov a,0
mov b,0
@morestars3:
mov ax,Starstuff2_seg
mov es,ax

;mov di,a
;shl di,1
add b,15

mov cx,a
push cx
add cx,b
;shl cx,1
mov a1,cx
mov aa1,cx
mov a2,cx
mov aa2,cx
pop cx

call check_fake_sin_range
call check_fake_cos_range
mov si,aa1
cmp si,0
jg @fine4
neg si
@fine4:
shl si,1
mov ax,word ptr lsin[si]
shr ax,1
cmp aa1,0
jg @noabs_now4
neg ax
@noabs_now4:
;sar ax,8
stosw

add di,718
mov si,aa2
cmp si,0
jg @fine5
neg si
@fine5:
shl si,1
mov ax,word ptr lcos[si]
shr ax,1
cmp aa2,0
jg @noabs_now5
neg ax
@noabs_now5:
;sar ax,8
stosw

add di,718
mov ax,cx
stosw


inc a
sub di,1440
cmp a,360
jnae @morestars3
;cmp di,720
;jnae @morestars3
ret
Init_Points3 Endp

;****************************************************************************
;Starfield - Initpoints4
;****************************************************************************

init_points4 proc near
mov di,0
mov cx,1
mov a,0
mov b,0
@morestars4:
mov ax,Starstuff2_seg
mov es,ax

;mov di,a
;shl di,1
add b,16
add b,16

mov cx,a
push cx
add cx,b
;shl cx,1
mov a1,cx
mov aa1,cx
mov a2,cx
mov aa2,cx
pop cx

call check_fake_sin_range
call check_fake_cos_range
mov si,aa1
cmp si,0
jg @fine6
neg si
@fine6:
shl si,1
mov ax,word ptr lsin[si]
shr ax,1
cmp aa1,0
jg @noabs_now6
neg ax
@noabs_now6:
;sar ax,8
stosw

add di,718
mov si,aa2
cmp si,0
jg @fine7
neg si
@fine7:
shl si,1
mov ax,word ptr lcos[si]
shr ax,1
cmp aa2,0
jg @noabs_now7
neg ax
@noabs_now7:
;sar ax,8
stosw

add di,718
mov ax,cx
stosw


inc a
sub di,1440
cmp a,360
jnae @morestars4
;cmp di,720
;jnae @morestars4
ret
Init_Points4 Endp

;****************************************************************************
;Starfield - Initpoints5
;****************************************************************************

init_points5 proc near
mov di,0
mov cx,1
mov a,0
mov b,0
@morestars5:
mov ax,Starstuff_seg
mov es,ax

;mov di,a
;shl di,1
add b,16
add b,16

mov cx,a
push cx
add cx,b
;shl cx,1
mov a1,cx
mov aa1,cx
mov a2,cx
mov aa2,cx
pop cx

call check_fake_sin_range
call check_fake_cos_range
mov si,aa1
cmp si,0
jg @fine8
neg si
@fine8:
shl si,1
mov ax,word ptr lsin[si]
shr ax,1
cmp aa1,0
jg @noabs_now8
neg ax
@noabs_now8:
;sar ax,8
mov ax,160
stosw

add di,718
;mov si,aa2
;cmp si,0
;jg @fine8
;neg si
;@fine8:
;shl si,1
;mov ax,word ptr lcos[si]
;shr ax,1
;cmp aa2,0
;jg @noabs_now8
;neg ax
;@noabs_now8:
;;sar ax,8
shr ax,1
mov ax,100
stosw

add di,718
mov ax,cx
stosw


inc a
sub di,1440
cmp a,360
jnae @morestars5
;cmp di,720
;jnae @morestars5
ret
Init_Points5 Endp

;****************************************************************************
;Starfield - Initpoints6...same at points5, but just to different buffer
;****************************************************************************

init_points6 proc near
mov di,0
mov cx,1
mov a,0
mov b,0
@morestars6:
mov ax,Starstuff2_seg
mov es,ax

;mov di,a
;shl di,1
add b,16
add b,16

mov cx,a
push cx
add cx,b
;shl cx,1
mov a1,cx
mov aa1,cx
mov a2,cx
mov aa2,cx
pop cx

mov ax,160
stosw

add di,718
mov ax,100
stosw

add di,718
mov ax,cx
stosw


inc a
sub di,1440
cmp a,360
jnae @morestars6
ret
Init_Points6 Endp


;****************************************************************************
;Starfield - Display_stars
;****************************************************************************

Display_stars proc near
mov cx,0
@draw_more_stars:
;SEGMENT SET AND ZPOS
mov ax,starstuff_seg
mov es,ax
mov si,cx
add si,1440
mov bx,es:[si]
sub si,1440
mov ax,es:[si]
;cmp al,0
;jge @abs
;neg bx
;@abs:
;xor dx,dx
sar ax,8
mov  dx,ax
sal  ax,8
sar  dx,8
idiv bx
neg ax
add ax,160
cmp ax,319
jae @out_of_range
cmp ax,0
jle @out_of_range
mov di,ax
add si,720
mov ax,es:[si]
;cmp al,0
;jge @abs2
;neg bx
;@abs2:
;xor dx,dx
;idiv bx
sar ax,8
mov  dx,ax
sal  ax,8
sar  dx,8
idiv bx
neg ax
add ax,100
cmp ax,199
jae @out_of_range
mov dx,ax
shl ax,6
shl dx,8
add ax,dx
add di,ax

	    mov     dx,virtualscreen_seg
	    mov     es,dx

mov al,131;110
mov ah,130;161
dec di
stosw
stosb
sub di,322
stosb
add di,639
stosb


@out_of_range:
add cx,2
cmp cx,720
jnae @draw_more_Stars
ret
display_stars endp

;****************************************************************************
;Starfield - Move_stars
;****************************************************************************

Move_stars proc near
    mov ax,starstuff_seg
    mov es,ax
    mov di,1440
@move_next_star:
mov ax,es:[di]
sub ax,3
cmp ax,3
jnl @no_return_to_back
mov ax,360
@no_return_to_back:stosw
cmp di,2160
jnae @move_next_star
ret
Move_stars endp

;****************************************************************************
;Starfield - Morphsf
;****************************************************************************

morphsf proc near
mov timer,0
@repeat_morfing:
call move_stars
inc timer
mov a,0
@next_morf_star:
mov di,a
shl di,1

mov ax,starstuff2_seg
mov es,ax
mov ax,es:[di]
mov bx,starstuff_seg
mov es,bx
sub ax,es:[di]


mov bx,64
sar ax,8
mov  dx,ax
sal  ax,8
sar  dx,8
idiv bx
mov bx,timer
imul bx
add ax,es:[di]
mov x,ax


add di,720
mov ax,starstuff2_seg
mov es,ax
mov ax,es:[di]
mov bx,starstuff_seg
mov es,bx
sub ax,es:[di]

mov bx,64
sar ax,8
mov  dx,ax
sal  ax,8
sar  dx,8
idiv bx
mov bx,timer
imul bx
add ax,es:[di]
mov y,ax

mov ax,starstuff_seg
mov es,ax
mov si,a
shl si,1
add si,1440
mov bx,es:[si]
sub si,1440
mov ax,x;es:[si]
;cmp al,0
;jge @abs
;neg bx
;@abs:
;xor dx,dx
sar ax,8
mov  dx,ax
sal  ax,8
sar  dx,8
idiv bx
neg ax
add ax,160
cmp ax,319
jae @out_of_rangeno
cmp ax,0
jle @out_of_rangeno
mov di,ax
add si,720
mov ax,y;es:[si]
;cmp al,0
;jge @abs2
;neg bx
;@abs2:
;xor dx,dx
;idiv bx
sar ax,8
mov  dx,ax
sal  ax,8
sar  dx,8
idiv bx
neg ax
add ax,100
cmp ax,199
jae @out_of_rangeno
mov dx,ax
shl ax,6
shl dx,8
add ax,dx
add di,ax

	    mov     dx,virtualscreen_seg
	    mov     es,dx

mov al,131;110
mov ah,130;161
dec di
stosw
stosb
sub di,322
stosb
add di,639
stosb
@out_of_rangeno:

inc a
cmp a,360
jl @next_morf_star


       mov     ax,virtualscreen_seg
       mov     es,ax
       xor     di,di
       mov     cx,320
       xor     ax,ax

       rep     stosw
       mov     di,63360
       mov     cx,320
       rep     stosw


;FLIP
mov ax,virtualscreen_Seg
mov source,ax
mov ax,0a000h
mov dest,ax
call flip


;SMOOTH
mov ax,virtualscreen_seg
mov es,ax
Call Smooth_Filter


cmp timer,64
jnge @repeat_morfing


mov di,0
@copy_new_2_old:
mov si,di
shl si,1
mov ax,starstuff2_seg
mov es,ax
mov ax,es:[si]

mov bx,starstuff_seg
mov es,bx
mov es:[si],ax

inc di
cmp di,720
jl @copy_new_2_old

ret
morphsf endp

;****************************************************************************
;Starfield - Starfield_do
;****************************************************************************

starfield_do proc near
mov timer,0
@starfield:
call move_stars
call display_stars

;ERASE CORNERS
       mov     ax,virtualscreen_seg
       mov     es,ax
       xor     di,di
       mov     cx,320
       xor     ax,ax

       rep     stosw
       mov     di,63360
       mov     cx,320
       rep     stosw


;FLIP


mov ax,virtualscreen_Seg
mov source,ax
mov ax,0a000h
mov dest,ax
call flip

;SMOOTH
mov ax,virtualscreen_seg
mov es,ax
Call Smooth_Filter
inc timer
cmp timer,40
jne @starfield
ret
starfield_do endp

;****************************************************************************
;Starfield - Complete_sf_seq
;****************************************************************************

complete_sf_seq proc near
call init_points5
call starfield_do
call morphsf
call init_points2
call starfield_do
call morphsf
call init_points3
call starfield_do
call morphsf
call init_points4
call starfield_do
call morphsf
call init_points2
call starfield_do
call morphsf
call init_points6
call starfield_do
call morphsf
call starfield_do
call blur_off
mov orderpos,21
ret
complete_sf_seq endp



PERSPECTIVEPROJECT Proc Near
      mov cx,zz1
      add cx,256

      mov ax,xx1
      sub ax,160
      mov  dx,ax
      sal  ax,8
      sar  dx,8
      idiv cx
      add  ax,160
      mov  bx,ax

      mov ax,yy1
      sub ax,100
      mov  dx,ax
      sal  ax,8
      sar  dx,8
      idiv cx
      add  ax,100
      ret
PERSPECTIVEPROJECT Endp

RotatePointFast proc near
mov ax,xx1
sub ax,xrot
mov cxx,ax
mov ax,yy1
sub ax,yrot
mov cyy,ax
mov ax,zz1
sub ax,zrot
mov czz,ax

cmp xdeg,0
jle @YROT
   mov bx,xdeg
   mov a1,bx
   mov a2,bx
   mov aa2,bx
   call check_fake_cos_range
   mov bx,aa2

   cmp bx,0
   jge @noabs1x
   neg bx
   @noabs1x:
   shl bx,1
   mov ax,word ptr lcos[bx]
   cmp aa2,0
   jg @noneg1x
   neg ax
   @noneg1x:
   mov cx,ax
   imul cyy
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1

   mov ctemp,dx
   mov bx,xdeg
   mov aa1,bx
   call check_fake_sin_range
   mov bx,aa1
   cmp bx,0
   jge @noabs2x
   neg bx
   @noabs2x:

   shl bx,1
   mov ax,word ptr lsin[bx]
   cmp aa1,0
   jg @noneg2x
   neg ax
   @noneg2x:
   push ax
   imul czz
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   sub ctemp,dx
   mov ax,ctemp
   mov ty,ax

   pop ax
   imul cyy
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   mov ctemp,dx
   mov ax,cx
   imul czz
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   add ctemp,dx
   mov ax,ctemp
   mov czz,ax
   mov ax,ty
   mov cyy,ax
@YROT:

cmp ydeg,0
jle @ZROT
   mov bx,ydeg
   mov a1,bx
   mov a2,bx
   mov aa2,bx
   call check_fake_cos_range
   mov bx,aa2
   cmp bx,0
   jg @noabs1y
   neg bx
   @noabs1y:
   shl bx,1
   mov ax,word ptr lcos[bx]
   cmp aa2,0
   jge @noneg1y
   neg ax
   @noneg1y:
   mov cx,ax
   imul cxx
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   mov ctemp,dx
   mov bx,ydeg
   mov aa1,bx
   call check_fake_sin_range
   mov bx,aa1
   cmp bx,0
   jg @noabs2y
   neg bx
   @noabs2y:
   shl bx,1
   mov ax,word ptr lsin[bx]
   cmp aa1,0
   jge @noneg2y
   neg ax
   @noneg2y:
   push ax
   imul czz
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   add ctemp,dx
   mov ax,ctemp
   mov tx,ax

   pop ax
   neg ax
   imul cxx
   sal ax,1
   rcl dx,1
   sal ax,1

   rcl dx,1
   mov ctemp,dx
   mov ax,cx
   imul czz
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   add ctemp,dx
   mov ax,ctemp
   mov czz,ax
   mov ax,tx
   mov cxx,ax

@ZROT:
cmp zdeg,0
jle @ENDROT
   mov bx,zdeg
   mov a1,bx
   mov a2,bx
   mov aa2,bx
   call check_fake_cos_range
   mov bx,aa2
   cmp bx,0
   jge @noabs1z
   neg bx
   @noabs1z:
   shl bx,1
   mov ax,word ptr lcos[bx]
   cmp aa2,0
   jge @noneg1z
   neg ax
   @noneg1z:
   mov cx,ax
   imul cxx
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   mov ctemp,dx
   mov bx,zdeg
   mov aa1,bx
   call check_fake_sin_range
   mov bx,aa1
   cmp bx,0
   jge @noabs2z
   neg bx
   @noabs2z:
   shl bx,1
   mov ax,word ptr lsin[bx]
   cmp aa1,0
   jge @noneg2z
   neg ax
   @noneg2z:
   push ax
   imul cyy
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   sub ctemp,dx
   mov ax,ctemp
   mov tx,ax

   pop ax
   imul cxx
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   mov ctemp,dx
   mov ax,cx
   imul cyy
   sal ax,1
   rcl dx,1
   sal ax,1
   rcl dx,1
   add ctemp,dx
   mov ax,ctemp
   mov cyy,ax
   mov ax,tx
   mov cxx,ax


@ENDROT:
mov ax,cxx
add ax,xrot
mov xer,ax
mov ax,cyy
add ax,yrot
mov yer,ax
mov ax,czz
add ax,zrot
mov zer,ax
ret
rotatepointfast endp

nice_plasma proc near
mov     dx,3D4h
mov     al,9
out     dx,al
inc     dx
in      al,dx
and     al,0f0h
add     al,5
out     dx,al


mov a,0
mov c,0
mov d,0
mov timer,0
@againy:
mov ax,d
mov c2,ax
mov ax,c
mov c4,ax
mov c5,ax
mov x,0
mov temp,0


mov y,0
xor di,di
mov cx,720
mov bx,0a000h  ;0a000h/$9000
mov es,bx
@start_y_loop:
mov x,0
inc y
mov ax,temp
mov c1,ax
add c2,3
sub c5,2

@start_x_loop:
;add di,2
add x,2
mov c3,14
xor  dx,dx
mov  ax,c1
div  cx
mov  c1,dx

xor  dx,dx
mov  ax,c2
div  cx
mov  c2,dx

xor  dx,dx
mov  ax,c4
div  cx
mov  c4,dx

xor  dx,dx
mov  ax,c5
div  cx
mov  c5,dx

	 ;xor bx,bx
	 ;xor si,si
	 ;mov si,c1
	 ;mov al,byte ptr lcosdata[si]
	 ;mov bx,ax
xor ax,ax
mov si,c1
shr si,2
cmp si,90
jbe @nnormal1
sub si,180
neg si
@nnormal1:
mov al,byte ptr lcosdata[si]
mov bx,ax



	 ;mov si,c2
	 ;mov al,byte ptr lcosdata[si]
	 ;add bx,ax
mov si,c2
shr si,2
cmp si,90
jbe @nnormal2
sub si,180
neg si
@nnormal2:
mov al,byte ptr lcosdata[si]
add bx,ax
	 ;mov si,c3
	 ;mov al,byte ptr lcosdata[si]
	 ;add bx,ax
mov si,c3
shr si,2
cmp si,90
jbe @nnormal3
sub si,180
neg si
@nnormal3:
mov al,byte ptr lcosdata[si]
add bx,ax
	 ;mov si,c4
	 ;mov al,byte ptr lcosdata[si]
	 ;add bx,ax
mov si,c4
shr si,2
cmp si,90
jbe @nnormal4
sub si,180
neg si
@nnormal4:
mov al,byte ptr lcosdata[si]
add bx,ax
	 ;mov si,c5
	 ;mov al,byte ptr lcosdata[si]
	 ;sub bx,ax
mov si,c5
shr si,2
cmp si,90
jbe @nnormal5
sub si,180
neg si
@nnormal5:
mov al,byte ptr lcosdata[si]
sub bx,ax

	 shr bx,2
	 add c1,2
	 add c3,2
	 add c5,720
	 jmp @display
	 @black:inc bx
	 @display:
		  cmp     bx,0
		  je      @black
		  mov     ax,bx
		  mov     ah,al
		  stosw
		  ;mov     es:[di],ax

mov ax,318
cmp x,ax
je @here
jmp @start_x_loop
@here:
add di,2
cmp y,70
je @endp
mov ax,320
mov bx,318
sub ax,bx
add di,ax
sub di,2
jmp @start_y_loop

@endp:
     add d,10
     sub c,20
     mov ax,d
     mov temp,ax
     inc timer
     cmp timer,122
jne @againy
mov ax,0a000h
call cls
mov     dx,3D4h
mov     al,9
out     dx,al
inc     dx
in      al,dx
and     al,0f0h
add     al,1
out     dx,al
ret
nice_plasma endp



drawplasma proc near   ;old=290,new=85. lines
	 mov di,0;4480
	 mov ax,c
	 mov c2,ax
	 @yloop:
	 mov ax,d
	 mov c1,ax
	 mov c3,20
	 add c2,4

	 add di,320
	 mov bx,0
	 @xloop:
	 mov  cx,720
	 mov  ax,c1
	 cmp  ax,cx
	 jnae @doit
	 xor  dx,dx
	 div  cx
	 mov  c1,dx
   @doit:
	 mov  ax,c2
	 cmp  ax,cx
	 jnae @doit2
	 xor  dx,dx
	 div  cx
	 mov  c2,dx
  @doit2:


mov si,c1
shr si,2
cmp si,90
jbe @normal1
sub si,180
neg si
@normal1:
mov al,byte ptr lcosdata[si]

mov si,c2
shr si,2
cmp si,90
jbe @normal2
sub si,180
neg si
@normal2:
mov dl,byte ptr lcosdata[si]
xor dh,dh
add ax,dx
add ax,dx

mov si,c3
shr si,2
cmp si,90
jbe @normal3
sub si,180
neg si
@normal3:
mov dl,byte ptr lcosdata[si]
xor dh,dh
add ax,dx
add ax,dx
add ax,dx

	 add c1,8
	 add c3,4

	 cmp     al,0
	 jne     @noblack
	 inc     al
  @noblack:
	 mov ah,al
	 stosw     ;not words!!

	 add bx,2
	 cmp bx,320
	 jne @xloop
	 cmp di,64000;59520
	 jnae @yloop
ret
drawplasma endp



drawplasma2 proc near   ;old=290,new=85. lines
	 mov di,0;4480
	 mov ax,c
	 mov c2,ax
	 add di,320
	 @yloopa:

	 mov ax,d
	 mov c1,ax
	 mov c3,20
	 add c2,4



	 add di,320
	 mov bx,0
	 @xloopa:
	 mov  cx,720
	 mov  ax,c1
	 cmp  ax,cx
	 jnae @doita
	 xor  dx,dx
	 div  cx
	 mov  c1,dx
   @doita:
	 mov  ax,c2
	 cmp  ax,cx
	 jnae @doita2
	 xor  dx,dx
	 div  cx
	 mov  c2,dx
  @doita2:


mov si,c1
shr si,2
cmp si,90
jbe @normal1a
sub si,180
neg si
@normal1a:
mov al,byte ptr lcosdata[si]

mov si,c2
shr si,2
cmp si,90
jbe @normal2a
sub si,180
neg si
@normal2a:
mov dl,byte ptr lcosdata[si]
xor dh,dh
add ax,dx
add ax,dx

mov si,c3
shr si,2
cmp si,90
jbe @normal3a
sub si,180
neg si
@normal3a:
mov dl,byte ptr lcosdata[si]
xor dh,dh
add ax,dx
add ax,dx
add ax,dx

	 add c1,8
	 add c3,1


	 cmp     al,0
	 jne     @noblacka
	 inc     al
  @noblacka:
	 mov ah,al
	 stosw     ;not words!!
	 add bx,2
	 cmp bx,320
	 jne @xloopa
	 cmp di,64000;59520
	 jnae @yloopa
ret
drawplasma2 endp


Shadebob proc near
;@bob:
;call randomy
;xor bx,bx
;cmp tempt,12800
;jng @three_twenty
;mov bx,-319
;@three_twenty:add bx,320
;call randomy
;cmp tempt,12800
;jng @positive
;neg bx
;@positive:

;add di,bx
;mov bx,di
mov dl,6
@drawbob:
mov cl,6
@horiz_draw:
cmp byte ptr es:[di],56
jge @no_shady_dot
add byte ptr es:[di],00000111b;00000111b
@no_shady_dot:
add di,1
dec cl
cmp cl,0
jne @horiz_draw
add di,314
dec dl
cmp dl,0
jne @drawbob
ret
shadebob endp

changepal proc near
mov    dx,3c8h
mov    al,0
out    dx,al
inc    dx
mov bl,0
inc colcount
cmp colcount,1
je @palr
cmp colcount,2
je @palg
cmp colcount,3
je @palb
jmp @palb
@palr:
   mov    al,bl
   out    dx,al
   mov    al,0
   out    dx,al
   out    dx,al
   inc bl
cmp bl,64
jne @palr
jmp @end_changepal
@palg:
   mov    al,0
   out    dx,al
   mov    al,bl
   out    dx,al
   mov    al,0
   out    dx,al
   inc bl
cmp bl,64
jne @palg
jmp @end_changepal
@palb:
   mov    al,0
   out    dx,al
   out    dx,al
   mov    al,bl
   out    dx,al
   inc bl
   mov colcount,0
cmp bl,64
jne @palb

@end_changepal:
ret
changepal endp



shadebobs3d proc near
    mov xdeg,0
    mov ydeg,0
    mov zdeg,0
    mov a,0
    @bobs:
    mov xrot,90
    mov yrot,100
    mov zrot,180

    inc xdeg
    add xdeg,3
    add ydeg,2
    add zdeg,1

    cmp xdeg,360
    jl @xreset
    mov xdeg,0
    @xreset:
    cmp ydeg,360
    jl @yreset
    mov ydeg,0
    @yreset:
    cmp zdeg,360
    jl @zreset
    mov zdeg,0
    @zreset:


mov temp,2
@draw_more_stars2:
;SEGMENT SET AND ZPOS
mov ax,starstuff2_seg
mov es,ax
mov si,temp
add si,1440
mov bx,es:[si]
sub si,1440
mov ax,es:[si]
;cmp al,0
;jge @absy
;neg bx
;@absy:
;xor dx,dx
;idiv bx
sar ax,8
mov  dx,ax
sal  ax,8
sar  dx,8
idiv bx
neg ax
add ax,160
mov di,ax
add si,720
mov ax,es:[si]
;cmp al,0
;jge @abs2y
;neg bx
;@abs2y:
;xor dx,dx
;idiv bx
sar ax,8
mov  dx,ax
sal  ax,8
sar  dx,8
idiv bx
neg ax
add ax,100
mov xx1,di
mov yy1,ax
add si,720
mov ax,es:[si]
mov zz1,ax

pusha
call rotatepointfast
popa
add xer,160
mov ax,a
sub xer,ax
add yer,100
sub yer,ax
cmp xer,310
jae @out_of_range2
cmp xer,10
jle @out_of_range2
cmp yer,190
jae @out_of_range2
cmp yer,10
jle @out_of_range2
mov di,xer
mov ax,yer

mov dx,ax
shl ax,6
shl dx,8
add ax,dx
add di,ax
mov dx,virtualscreen_seg
mov es,dx
call shadebob

@out_of_range2:
add temp,2
cmp temp,720
jnae @draw_more_Stars2


mov ax,virtualscreen_seg
mov es,ax
call smooth_filter


       mov     ax,virtualscreen_seg
       mov     es,ax
       xor     di,di
       mov     cx,320
       xor     ax,ax
       rep     stosw
       mov     di,63360
       mov     cx,320
       rep     stosw

call waitretrace

    push ds
    mov     ax,0a000h
    mov     es,ax
    mov     cx,32000
    mov     ax,virtualscreen_seg
    mov     ds,ax
    xor     si,si
    xor     di,di
    rep     movsw
    pop ds


    call changepal
    call waitretrace
    inc a
    cmp a,360
    jnae @bobs
ret
shadebobs3d endp


;****************************************************************************
;Fire Effect - firesmooth,fire
;****************************************************************************

firesmooth proc near
;smoothing part
		 mov di,0
		 xor ax,ax
		 @loopy2:
		 inc di
		 xor cx,cx

		 add di,319
		 mov cl,es:[di]
		 add al,cl

		 xor cl,cl
		 add di,2
		 mov cl,es:[di]
		 add ax,cx

		 xor cx,cx
		 add di,319
		 mov cl,es:[di]
		 add ax,cx

		 xor cx,cx
		 sub di,640
		 mov cl,es:[di]
		 add ax,cx

		 shr ax,2

		 cmp di,63360
		 je @endnow

		 cmp ax,0
		 jle @loopy2

		 cmp al,64
		 jae @pixel

;3decs2incs...
		 dec ax
		 dec ax
		 dec ax
		 @pixel:
		 inc ax
		 inc ax

		 cmp al,127
		 jb @loopt
		 mov al,126
		 @loopt:

		 cmp ax,0
		 je @loopy2

		 mov es:[di],ax

		 jmp @loopy2

		 @endnow:
		 ret
firesmooth endp



Fire Proc Near   ;old=109,new=94.lines
mov dx,0
@fireloop:
      mov seed,dx ;to make MORE random, otherwise a pattern is easily noticed!
      mov cx,0
      mov ax,virtualscreen_seg
      mov es,ax
      mov di,63040
      @hotspots:
		call randomy
		mov bx,tempt
		mov ax,0
		cmp bl,0
		jle @twofivefive
		mov ax,-255
		@twofivefive:
		add ax,255
		stosb
		inc cx
      cmp cx,320
      jne @hotspots
      mov ax,virtualscreen_seg
      mov es,ax
      call firesmooth

;FLIP

    push ds
    mov     ax,0a000h
    mov     es,ax
    mov     cx,30560
    mov     ax,virtualscreen_seg
    mov     ds,ax
    mov     si,1280
    mov     di,si
    rep     movsw
    ;mov ax,virtualscreen_seg
    ;mov es,ax
    ;xor di,di
    ;mov cx,32000
    ;xor ax,ax
    ;rep stosw
pop ds
inc dx
cmp dx,260
jne @fireloop
ret
Fire Endp




;****************************************************************************
;Polygon stuff - draw_polygon,tmap_polygon
;****************************************************************************

Draw_Polygon Proc near
;{rotate 3 points fast in 3d space}
mov ax,x1
mov xx1,ax
mov ax,y1
mov yy1,ax
mov ax,z1
mov zz1,ax
call RotatePointFast
mov ax,xer
mov x1,ax
mov ax,yer
mov y1,ax
mov ax,zer
mov z1,ax

mov ax,x2
mov xx1,ax
mov ax,y2
mov yy1,ax
mov ax,z2
mov zz1,ax
call RotatePointFast
mov ax,xer
mov x2,ax
mov ax,yer
mov y2,ax
mov ax,zer
mov z2,ax

mov ax,x3
mov xx1,ax
mov ax,y3
mov yy1,ax
mov ax,z3
mov zz1,ax
call RotatePointFast
mov ax,xer
mov x3,ax
mov ax,yer
mov y3,ax
mov ax,zer
mov z3,ax        

;{now add the offsets}
mov ax,xoff
add x1,ax
add x2,ax
add x3,ax
mov ax,yoff
add y1,ax
add y2,ax
add y3,ax
mov ax,zoff
add z1,ax
add z2,ax
add z3,ax


;{now do 3 perpective transforms}
mov ax,x1
mov xx1,ax
mov ax,y1
mov yy1,ax
mov ax,z1
mov zz1,ax
call PerspectiveProject
mov x1,bx
mov y1,ax

mov ax,x2
mov xx1,ax
mov ax,y2
mov yy1,ax
mov ax,z2
mov zz1,ax
call PerspectiveProject
mov x2,bx
mov y2,ax

mov ax,x3
mov xx1,ax
mov ax,y3
mov yy1,ax
mov ax,z3
mov zz1,ax
call PerspectiveProject
mov x3,bx
mov y3,ax



;{start the actual polygon routine}
;(*mny:=y1; mxy:=y1;
;   if y2<mny then mny:=y2;
;   if y2>mxy then mxy:=y2;
;   if y3<mny then mny:=y3;      {chose min and max y's}
;   if y3>mxy then mxy:=y3; *)


mov bx,y1
mov mny,bx
mov mxy,bx


mov bx,y2
cmp bx,mny
jge @testnext1
mov mny,bx
@testnext1:cmp bx,mxy
jle @testnext2
mov mxy,bx
@testnext2:mov bx,y3
cmp bx,mny
jge @testnext3
mov mny,bx
@testnext3:cmp bx,mxy
jle @finishedhere_also
mov mxy,bx
@finishedhere_also:


  ;{If mxy<0 then exit;
  ; If mny<0 then mny:=0;
  ; If mny>199 then exit;
  ; If mxy>199 then mxy:=199;  }
cmp mxy,0
jl @totally_exit
cmp mny,0
jge @nexttest
mov mny,0
@nexttest:cmp mny,199
jg @totally_exit
cmp mxy,199
jle @finished_with_these
mov mxy,199
@finished_with_these:

mov ax,x1
sub ax,x3
mov m1,ax
mov ax,x2
sub ax,x1
mov m2,ax
mov ax,x3
sub ax,x2
mov m3,ax
mov ax,y1
sub ax,y3
mov d1,ax
mov ax,y2
sub ax,y1
mov d2,ax
mov ax,y3
sub ax,y2
mov d3,ax
mov ax,z1
sub ax,z3
mov f1,ax
mov ax,z2
sub ax,z1
mov f2,ax
mov ax,z3
sub ax,z2
mov f3,ax

mov bx,mny
dec bx
@this_is_hline_loop:
inc bx
     mov mnx,319             ;{to clip the screen}
     mov mxx,0               ;{to clip the screen}

     mov ax,y3
     cmp ax,y1
     je @finishedhere1
     cmp ax,bx
     jae @quitcheck1
     mov ax,bx
     cmp y1,ax
     jnae @finishedhere1
     @quitcheck1:
     cmp y3,bx
     jle @startthis1
     cmp y1,bx
     jg @finishedhere1
     @startthis1:
     mov ax,bx
     sub ax,y3
     imul m1
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d1
     sar ax,8
     add ax,x3
     mov x,ax

     mov ax,bx
     sub ax,y1
     imul f1
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d1
     sar ax,8
     add ax,z1
     mov z,ax

     mov ax,x
     mov dx,z
     cmp ax,mxx
     jna @nextcheck1
     mov mxx,ax
     mov rz,dx
     @nextcheck1:cmp ax,mnx
     jnb @finishedhere1
     mov mnx,ax
     mov lz,dx
     @finishedhere1:

   ;{If y1<>y2 then
   ;  If ((y2>=y) and (y1<=y)) or ((y1>=y) and (y2<=y)) then  }

     mov ax,y2
     cmp y1,ax
     je @finishedhere2

     cmp y2,bx
     jnae @quitcheck2
     cmp y1,bx
     jle @startthis2
     @quitcheck2:

     cmp y1,bx
     jnae @finishedhere2
     cmp y2,bx
     jnle @finishedhere2

     @startthis2:
     mov ax,bx
     sub ax,y1
     imul m2
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d2
     sar ax,8
     add ax,x1
     mov x,ax

     mov ax,bx
     sub ax,y2
     imul f2
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d2
     sar ax,8
     add ax,z2
     mov z,ax

     mov ax,x
     mov dx,z
     cmp ax,mxx
     jna @nextcheck2
     mov mxx,ax
     mov rz,dx
     @nextcheck2:cmp ax,mnx
     jnb @finishedhere2
     mov mnx,ax
     mov lz,dx
     @finishedhere2:

   ;{If y2<>y3 then
   ;  If ((y3>=y) and (y2<=y)) or ((y2>=y) and (y3<=y)) then    }

     mov ax,y3
     cmp y2,ax
     je @finishedhere3

     cmp y3,bx
     jnae @quitcheck3
     cmp y2,bx
     jle @startthis3
     @quitcheck3:

     cmp y2,bx
     jnae @finishedhere3
     cmp y3,bx
     jnle @finishedhere3
     @startthis3:
     mov ax,bx
     sub ax,y2
     imul m3
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d3
     sar ax,8
     add ax,x2
     mov x,ax

     mov ax,bx
     sub ax,y3
     imul f3
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d3
     sar ax,8
     add ax,z3
     mov z,ax

     mov ax,x
     mov dx,z
     cmp ax,mxx
     jna @nextcheck3
     mov mxx,ax
     mov rz,dx

     @nextcheck3:cmp ax,mnx
     jnb @finishedhere3
     mov mnx,ax
     mov lz,dx
     @finishedhere3:


   ;(*If mnx<1 then mnx:=1;
   ;If mxx>318 then mxx:=318;            ;{to clip the screen}
   ;if mnx<mxx then
   ;hline(mnx-1,mxx+1,y,col{col{col{(((x2-x1)*-(y1-y3))-((y2-y1)*-(x1-x3))) shr 5*)

     ;{do final clipping and checks before calling HLINE}
     cmp mnx,1                     ;{minx clip value}
     jae @finished_clip_check1
     mov mnx,1
     @finished_clip_check1:
     cmp mxx,318                   ;{maxx clip value}
     jle @finished_clip_check2
     mov mxx,318
     @finished_clip_check2:

     mov ax,mxx
     cmp mnx,ax
     jge @dont_draw_it

   ;{HLINE Drawer}
mov y,bx
pusha
mov cx,mnx    ;{cx is the place value}
mov ax,y
mov bh,al
shl ax,6
add ah,bh
mov di,ax
add di,cx

mov ax,zoff
sub lz,ax
sub rz,ax

mov ax,rz
sub ax,lz
mov dx,ax
sal ax,8
sar dx,8
mov bx,mxx
sub bx,cx
idiv bx
add bx,cx

mov dx,lz
mov dh,dl
xor dl,dl
@loop_Gouraud_line:

   push bx
   mov bx,virtualscreen2_seg   ;the Z-buffer
   mov es,bx
   pop bx
   cmp es:[di],dh
   jle @out
   mov es:[di],dh
   mov es,where                ;the drawarea
   add dh,col
   mov es:[di],dh
   sub dh,col
   @out:inc cx
	inc di

	add dx,ax

cmp cx,bx
jna @loop_gouraud_line
popa

     @dont_draw_it:
     cmp mxy,bx
     jne @this_is_hline_loop

     @totally_exit:
ret
Draw_polygon Endp



tmap_Polygon Proc near
;{rotate 3 points fast in 3d space}
mov ax,x1
mov xx1,ax
mov ax,y1
mov yy1,ax
mov ax,z1
mov zz1,ax
call RotatePointFast
mov ax,xer
mov x1,ax
mov ax,yer
mov y1,ax
mov ax,zer
mov z1,ax

mov ax,x2
mov xx1,ax
mov ax,y2
mov yy1,ax
mov ax,z2
mov zz1,ax
call RotatePointFast
mov ax,xer
mov x2,ax
mov ax,yer
mov y2,ax
mov ax,zer
mov z2,ax

mov ax,x3
mov xx1,ax
mov ax,y3
mov yy1,ax
mov ax,z3
mov zz1,ax
call RotatePointFast
mov ax,xer
mov x3,ax
mov ax,yer
mov y3,ax
mov ax,zer
mov z3,ax


;{now add the offsets}
mov ax,xoff
add x1,ax
add x2,ax
add x3,ax
mov ax,yoff
add y1,ax
add y2,ax
add y3,ax
mov ax,zoff
add z1,ax
add z2,ax
add z3,ax


;{now do 3 perpective transforms}
mov ax,x1
mov xx1,ax
mov ax,y1
mov yy1,ax
mov ax,z1
mov zz1,ax
call PerspectiveProject
mov x1,bx
mov y1,ax

mov ax,x2
mov xx1,ax
mov ax,y2
mov yy1,ax
mov ax,z2
mov zz1,ax
call PerspectiveProject
mov x2,bx
mov y2,ax

mov ax,x3
mov xx1,ax
mov ax,y3
mov yy1,ax
mov ax,z3
mov zz1,ax
call PerspectiveProject
mov x3,bx
mov y3,ax

;   m1:=x1-x3; d1:=y1-y3;
;   m2:=x2-x1; d2:=y2-y1;
;if memo<>'SHYD' then
;if (m2*-d1)-(d2*-m1)<0 then exit;
mov ax,y1
sub ax,y3
neg ax
mov bx,x2
sub bx,x1
imul bx
mov cx,ax

mov ax,x1
sub ax,x3
neg ax
mov bx,y2
sub bx,y1
imul bx
sub cx,ax
cmp cx,0
jl @ttotally_exit



;{start the actual polygon routine}
;(*mny:=y1; mxy:=y1;
;   if y2<mny then mny:=y2;
;   if y2>mxy then mxy:=y2;
;   if y3<mny then mny:=y3;      {chose min and max y's}
;   if y3>mxy then mxy:=y3; *)


mov bx,y1
mov mny,bx
mov mxy,bx


mov bx,y2
cmp bx,mny
jge @ttestnext1
mov mny,bx
@ttestnext1:cmp bx,mxy
jle @ttestnext2
mov mxy,bx
@ttestnext2:mov bx,y3
cmp bx,mny
jge @ttestnext3
mov mny,bx
@ttestnext3:cmp bx,mxy
jle @ffinishedhere_also
mov mxy,bx
@ffinishedhere_also:


  ;{If mxy<0 then exit;
  ; If mny<0 then mny:=0;
  ; If mny>199 then exit;
  ; If mxy>199 then mxy:=199;  }
cmp mxy,0
jl @ttotally_exit
cmp mny,0
jge @nnexttest
mov mny,0
@nnexttest:cmp mny,199
jg @ttotally_exit
cmp mxy,199
jle @ffinished_with_these
mov mxy,199
@ffinished_with_these:

mov ax,x1
sub ax,x3
mov m1,ax
mov ax,x2
sub ax,x1
mov m2,ax
mov ax,x3
sub ax,x2
mov m3,ax
mov ax,y1
sub ax,y3
mov d1,ax
mov ax,y2
sub ax,y1
mov d2,ax
mov ax,y3
sub ax,y2
mov d3,ax
mov ax,z1
sub ax,z3
mov f1,ax
mov ax,z2

sub ax,z1
mov f2,ax
mov ax,z3
sub ax,z2
mov f3,ax




;***new tmap add ons

mov ax,tx1
shl ax,7
mov tx1,ax
mov ax,tx2
shl ax,7
mov tx2,ax
mov ax,ty1
shl ax,7
mov ty1,ax
mov ax,ty2
shl ax,7
mov ty2,ax
mov ax,tx3
shl ax,7
mov tx3,ax
mov ax,ty3
shl ax,7
mov ty3,ax
;if (y1-y3)<>0 then
;tstep0y:=(ty3-ty1)  div (y3-y1);
mov ax,y3
sub ax,y1
cmp ax,0
je @tchek_out1
mov bx,ax
mov ax,ty3
sub ax,ty1
sar ax,8
mov dx,ax
sal ax,8
sar dx,8
;{xor dx,dx}
idiv bx
;xor dx,dx
;div bx
mov tstep0y,ax
@tchek_out1:

;if (y1-y2)<>0 then
;tstep1x:=(tx1-tx2)  div (y1-y2);
mov ax,y1   ;should these be the other way around?
sub ax,y2
cmp ax,0
je @tchek_out2
mov bx,ax
mov ax,tx1
sub ax,tx2
sar ax,8
mov dx,ax
sal ax,8
sar dx,8
;{xor dx,dx}
idiv bx
mov tstep1x,ax
@tchek_out2:

;if (y2-y3)<>0 then
;tstep2y:=(ty2-ty3)  div (y2-y3);
mov ax,y2
sub ax,y3
cmp ax,0
je @tchek_out3
mov bx,ax
mov ax,ty2
sub ax,ty3
sar ax,8
mov dx,ax
sal ax,8
sar dx,8
;{xor dx,dx}
idiv bx
;xor dx,dx
;div bx
mov tstep2y,ax
@tchek_out3:

;if (y1-y3)<>0 then
;tstep0x:=(tx3-tx1)  div (y3-y1);
mov ax,y3
sub ax,y1
cmp ax,0
je @tchek_out4
mov bx,ax
mov ax,tx3
sub ax,tx1
sar ax,8
mov dx,ax
sal ax,8
sar dx,8
;{xor dx,dx}
idiv bx
;xor dx,dx
;div bx
mov tstep0x,ax
@tchek_out4:

;if (y2-y1)<>0 then
;tstep1y:=(ty1-ty2)  div (y1-y2);
mov ax,y1
sub ax,y2
cmp ax,0
je @tchek_out5
mov bx,ax
mov ax,ty1
sub ax,ty2
sar ax,8
mov dx,ax
sal ax,8
sar dx,8
;{xor dx,dx}
idiv bx
;xor dx,dx
;div bx
mov tstep1y,ax
@tchek_out5:

;if (y2-y3)<>0 then
;tstep2x:=(tx2-tx3)  div (y2-y3);
mov ax,y2
sub ax,y3
cmp ax,0
je @tchek_out6
mov bx,ax
mov ax,tx2
sub ax,tx3
sar ax,8
mov dx,ax
sal ax,8
sar dx,8
;{xor dx,dx}
idiv bx
;xor dx,dx
;div bx
mov tstep2x,ax
@tchek_out6:



;if y1<y3 then
;tmark0y:=ty1 else tmark0:=ty3;
mov ax,ty3
mov tmark0y,ax
mov ax,y1
cmp ax,y3
jg @st_tchek1
mov ax,ty1
mov tmark0y,ax
@st_tchek1:

;if y1<y2 then
;tmark1x:=tx1 else tmark1x:=tx2;
mov ax,tx2
mov tmark1x,ax
mov ax,y1
cmp ax,y2
jg @st_tchek2
mov ax,tx1
mov tmark1x,ax
@st_tchek2:

;if y2<y3 then
;tmark2:=ty2 else tmark2:=ty3;
mov ax,ty3
mov tmark2y,ax
mov ax,y2
cmp ax,y3
jg @st_tchek3
mov ax,ty2
mov tmark2y,ax
@st_tchek3:

;if y1<y3 then
;tmark0x:=tx1 else tmark0x:=tx3;
mov ax,tx3
mov tmark0x,ax
mov ax,y1
cmp ax,y3
jg @st_tchek4
mov ax,tx1
mov tmark0x,ax
@st_tchek4:

;if y1<y2 then
;tmark1y:=ty1 else tmark1y:=ty2;
mov ax,ty2
mov tmark1y,ax
mov ax,y1
cmp ax,y2
jg @st_tchek5
mov ax,ty1
mov tmark1y,ax
@st_tchek5:

;if y2<y3 then
;tmark2x:=tx2 else tmark2x:=tx3;
mov ax,tx3
mov tmark2x,ax
mov ax,y2
cmp ax,y3
jg @st_tchek6
mov ax,tx2
mov tmark2x,ax
@st_tchek6:








mov bx,mny
dec bx
@tthis_is_hline_loop:
inc bx
     mov mnx,319             ;{to clip the screen}
     mov mxx,0               ;{to clip the screen}

     mov tmnx,255
     shl tmnx,7
     mov tmxx,0
     mov tmny,199
     shl tmny,7
     mov tmxy,0

     mov ax,y3
     cmp ax,y1
     je @ffinishedhere1
     cmp ax,bx
     jae @qquitcheck1
     mov ax,bx
     cmp y1,ax
     jnae @ffinishedhere1
     @qquitcheck1:
     cmp y3,bx
     jle @sstartthis1
     cmp y1,bx
     jg @ffinishedhere1
     @sstartthis1:
     mov ax,bx
     sub ax,y3
     imul m1
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d1
     sar ax,8
     add ax,x3
     mov x,ax

     mov ax,bx
     sub ax,y1
     imul f1
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d1
     sar ax,8
     add ax,z1
     mov z,ax

;***tmap new
mov ax,x
cmp ax,mxx
jl @looloo1
mov mxx,ax
mov ax,tmark0x
mov tmxx,ax
mov ax,tmark0y
mov tmxy,ax
mov ax,z
mov rz,ax
@looloo1:
mov ax,x
cmp ax,mnx
jg @looloo1_end
mov mnx,ax
mov ax,tmark0x
mov tmnx,ax
mov ax,tmark0y
mov tmny,ax
mov ax,z
mov lz,ax
@looloo1_end:
mov ax,tstep0x
add tmark0x,ax
mov ax,tstep0y
add tmark0y,ax
;***tmap new end

     @ffinishedhere1:

   ;{If y1<>y2 then
   ;  If ((y2>=y) and (y1<=y)) or ((y1>=y) and (y2<=y)) then  }

     mov ax,y2
     cmp y1,ax
     je @ffinishedhere2

     cmp y2,bx
     jnae @qquitcheck2
     cmp y1,bx
     jle @sstartthis2
     @qquitcheck2:

     cmp y1,bx
     jnae @ffinishedhere2
     cmp y2,bx

     jnle @ffinishedhere2

     @sstartthis2:
     mov ax,bx
     sub ax,y1
     imul m2
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d2
     sar ax,8
     add ax,x1
     mov x,ax

     mov ax,bx
     sub ax,y2
     imul f2
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d2
     sar ax,8
     add ax,z2
     mov z,ax

;***tmap new
mov ax,x
cmp ax,mxx
jl @looloo2
mov mxx,ax
mov ax,tmark1y
mov tmxy,ax
mov ax,tmark1x
mov tmxx,ax
mov ax,z
mov rz,ax
@looloo2:
mov ax,x
cmp ax,mnx
jg @looloo2_end
mov mnx,ax
mov ax,tmark1y
mov tmny,ax
mov ax,tmark1x
mov tmnx,ax
mov ax,z
mov lz,ax
@looloo2_end:
mov ax,tstep1x
add tmark1x,ax
mov ax,tstep1y
add tmark1y,ax
;***tmap new end


     @ffinishedhere2:


   ;{If y2<>y3 then
   ;  If ((y3>=y) and (y2<=y)) or ((y2>=y) and (y3<=y)) then    }

     mov ax,y3
     cmp y2,ax
     je @ffinishedhere3

     cmp y3,bx
     jnae @qquitcheck3
     cmp y2,bx
     jle @sstartthis3
     @qquitcheck3:

     cmp y2,bx
     jnae @ffinishedhere3
     cmp y3,bx
     jnle @ffinishedhere3
     @sstartthis3:
     mov ax,bx
     sub ax,y2
     imul m3
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d3
     sar ax,8
     add ax,x2
     mov x,ax

     mov ax,bx
     sub ax,y3
     imul f3
     mov  dx,ax
     sal  ax,8
     sar  dx,8
     idiv d3
     sar ax,8
     add ax,z3
     mov z,ax

;***tmap new
mov ax,x
cmp ax,mxx
jl @looloo3
mov mxx,ax
mov ax,tmark2x
mov tmxx,ax
mov ax,tmark2y
mov tmxy,ax
mov ax,z
mov rz,ax
@looloo3:
mov ax,x
cmp ax,mnx
jg @looloo3_end
mov mnx,ax
mov ax,tmark2x
mov tmnx,ax
mov ax,tmark2y
mov tmny,ax
mov ax,z
mov lz,ax
@looloo3_end:
mov ax,tstep2x
add tmark2x,ax
mov ax,tstep2y
add tmark2y,ax
;***tmap new end


     @ffinishedhere3:


   ;(*If mnx<1 then mnx:=1;
   ;If mxx>318 then mxx:=318;            ;{to clip the screen}
   ;if mnx<mxx then
   ;hline(mnx-1,mxx+1,y,col{col{col{(((x2-x1)*-(y1-y3))-((y2-y1)*-(x1-x3))) shr 5*)

     ;{do final clipping and checks before calling HLINE}
     cmp mnx,1                     ;{minx clip value}
     jae @ffinished_clip_check1
     mov mnx,1
     @ffinished_clip_check1:
     cmp mxx,318                   ;{maxx clip value}
     jle @ffinished_clip_check2
     mov mxx,318
     @ffinished_clip_check2:

     mov ax,mxx
     cmp mnx,ax
     jge @ddont_draw_it

;***new tmap add on
;   if (mnx-mxx)<>0 then
;   tdx:=(tmnx-tmxx) div (mnx-mxx);
pusha
   mov cx,mnx
   sub cx,mxx
   cmp cx,0
   je @divout
   mov bx,mnx
   sub bx,mxx
   mov ax,tmnx
   sub ax,tmxx
   sar ax,8
   mov dx,ax
   sal ax,8
   sar dx,8
   idiv bx
   mov tdx,ax
@divout:
   mov cx,mnx
   sub cx,mxx
   cmp cx,0
   je @divout2
   mov bx,mnx
   sub bx,mxx
   mov ax,tmny
   sub ax,tmxy
   sar ax,8
   mov dx,ax
   sal ax,8
   sar dx,8
   idiv bx
   mov tdy,ax
@divout2:
popa
;***new tmap add ons ends.


;MORE tmap stuff
pusha
mov y,bx
mov ax,mnx
mov loop1,ax
mov ax,tmnx
mov dx1,ax
mov ax,tmny
mov dy1,ax
@loophlinetmap:
mov ax,tdx
add dx1,ax
mov ax,tdy
add dy1,ax
;if (loop<320) and (loop>=0) and (y>=0) and (y<200) then
cmp loop1,320
jnl @notmap
cmp loop1,0
jl @notmap
cmp y,200
jnl @notmap
cmp y,0
jle @notmap

   mov bx,virtualscreen2_seg
   mov es,bx
   mov bx,dy1
   shr bx,7
   mov si,bx
   shl si,6
   shl bx,8
   add si,bx
   mov bx,dx1
   shr bx,7
   add si,bx
   mov al,es:[si]


   mov bx,virtualscreen_seg
   mov es,bx
   mov bx,y
   mov di,bx
   shl di,8
   shl bx,6
   add di,bx
   add di,loop1
mov es:[di],al
@notmap:inc di

inc loop1
mov bx,mxx
cmp loop1,bx
jnge @loophlinetmap
popa
;MORE tmap stuff END


     @ddont_draw_it:
     cmp mxy,bx
     jne @tthis_is_hline_loop
     @ttotally_exit:
ret
tmap_polygon Endp


tmaptest proc rawhed
mov ax,virtualscreen_seg
mov where,ax ;{this is where the image is outputted}
mov angle,0
mov pos,0
mov timer,0
;{start of loop to draw the next frame}
mov t,0
mov txx,0
mov tyy,0
@do_it_all_again2:
;{These three are the points that the object rotates around}
mov xrot,160
mov yrot,100
mov zrot,150
;{these three are where the object is positioned on the screen}
mov xoff,0
mov yoff,00
mov ax,angle
shl ax,4
mov zoff,ax
shr ax,0
mov xoff,ax
shr ax,1
mov yoff,ax
;{these three are the angles that the object has rotated around each axis}
mov ax,angle
shl ax,2
mov xdeg,0
mov ydeg,0
mov zdeg,0
mov xdeg,ax
mov ydeg,ax
mov zdeg,ax
;{start of loop to get and draw the polys}
mov pos,0
mov yt,4
mov tyy,0
@ytmap_loop:
mov txx,0
mov xt,8
@xtmap_loop:
;2 front faces
mov ax,txx
mov bx,tyy
mov x1,0
add x1,ax
mov y1,0
add y1,bx
mov z1,0
mov x2,40
add x2,ax
mov y2,0
add y2,bx
mov z2,0
mov x3,40
add x3,ax
mov y3,50
add y3,bx
mov z3,0
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,0
add ty2,bx
mov tx3,40
add tx3,ax
mov ty3,50
add ty3,bx
call tmap_polygon
mov ax,txx
mov bx,tyy
mov x1,0
add x1,ax
mov y1,0
add y1,bx
mov z1,0
mov x2,40
add x2,ax
mov y2,50
add y2,bx
mov z2,0
mov x3,0
add x3,ax
mov y3,50
add y3,bx
mov z3,0
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,0
add tx3,ax
mov ty3,50
add ty3,bx
call tmap_polygon
;2 back faces
mov ax,txx
mov bx,tyy
mov x1,0
add x1,ax
mov y1,0
add y1,bx
mov z1,150
mov x2,40
add x2,ax
mov y2,50
add y2,bx
mov z2,150
mov x3,40
add x3,ax
mov y3,0
add y3,bx
mov z3,150
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,40
add tx3,ax
mov ty3,0
add ty3,bx
call tmap_polygon
mov ax,txx
mov bx,tyy
mov x1,0
add x1,ax
mov y1,0
add y1,bx
mov z1,150
mov x2,40
add x2,ax
mov y2,50
add y2,bx
mov z2,150
mov x3,40
add x3,ax
mov y3,0
add y3,bx
mov z3,150
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,40
add tx3,ax
mov ty3,0
add ty3,bx
call tmap_polygon
;2 left polys
mov ax,txx
mov bx,tyy
mov x1,0
mov y1,0
add y1,bx
mov z1,0
add z1,ax
mov x2,0
mov y2,50
add y2,bx
mov z2,40
add z2,ax
mov x3,0
mov y3,0
add y3,bx
mov z3,40
add z3,ax
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,40
add tx3,ax
mov ty3,0
add ty3,bx
cmp z1,200
ja @getouty1
cmp z2,200
ja @getouty1
cmp z3,200
ja @getouty1
call tmap_polygon
@getouty1:
mov ax,txx
mov bx,tyy
mov x1,0
mov y1,0
add y1,bx
mov z1,0
add z1,ax
mov x2,0
mov y2,50
add y2,bx
mov z2,0
add z2,ax
mov x3,0
mov y3,50
add y3,bx
mov z3,40
add z3,ax
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,0
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,40
add tx3,ax
mov ty3,50
add ty3,bx
cmp z1,200
ja @getouty2
cmp z2,200
ja @getouty2
cmp z3,200
ja @getouty2
call tmap_polygon
@getouty2:
;2 right polys
mov ax,txx
mov bx,tyy
mov x1,319
mov y1,0
add y1,bx
mov z1,0
add z1,ax
mov x2,319
mov y2,0
add y2,bx
mov z2,40
add z2,ax
mov x3,319
mov y3,50
add y3,bx
mov z3,40
add z3,ax
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,0
add ty2,bx
mov tx3,40
add tx3,ax
mov ty3,50
add ty3,bx
cmp z1,200
ja @getouty3
cmp z2,200
ja @getouty3
cmp z3,200
ja @getouty3
call tmap_polygon
@getouty3:
mov ax,txx
mov bx,tyy
mov x1,319
mov y1,0
add y1,bx
mov z1,0
add z1,ax
mov x2,319
mov y2,50
add y2,bx
mov z2,40
add z2,ax
mov x3,319
mov y3,50
add y3,bx
mov z3,0
add z3,ax
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,1
add tx3,ax
mov ty3,50
add ty3,bx
cmp z1,200
ja @getouty4
cmp z2,200
ja @getouty4
cmp z3,200
ja @getouty4
call tmap_polygon
@getouty4:



;2 top faces
mov ax,txx
mov bx,tyy
mov x1,0
add x1,ax
mov y1,0
mov z1,0
add z1,bx
mov x2,0
add x2,ax
mov y2,0
mov z2,50
add z2,bx
mov x3,40
add x3,ax
mov y3,0
mov z3,0
add z3,bx
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,0
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,40
add tx3,ax
mov ty3,0
add ty3,bx
call tmap_polygon
mov ax,txx
mov bx,tyy
mov x1,40
add x1,ax
mov y1,0
mov z1,0
add z1,bx
mov x2,0
add x2,ax
mov y2,0
mov z2,50
add z2,bx
mov x3,40
add x3,ax
mov y3,0
mov z3,50
add z3,bx
mov tx1,40
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,0
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,40
add tx3,ax
mov ty3,50
add ty3,bx
call tmap_polygon
;2 bottom faces
mov ax,txx
mov bx,tyy
mov x1,0
add x1,ax
mov y1,199
mov z1,0
add z1,bx
mov x2,40
add x2,ax
mov y2,199
mov z2,0
add z2,bx
mov x3,0
add x3,ax
mov y3,199
mov z3,50
add z3,bx
mov tx1,0
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,0
add ty2,bx
mov tx3,0
add tx3,ax
mov ty3,50
add ty3,bx
call tmap_polygon
mov ax,txx
mov bx,tyy
mov x1,40
add x1,ax
mov y1,199
mov z1,0
add z1,bx
mov x2,40
add x2,ax
mov y2,199
mov z2,50
add z2,bx
mov x3,0
add x3,ax
mov y3,199
mov z3,50
add z3,bx
mov tx1,40
add tx1,ax
mov ty1,0
add ty1,bx
mov tx2,40
add tx2,ax
mov ty2,50
add ty2,bx
mov tx3,0
add tx3,ax
mov ty3,50
add ty3,bx
call tmap_polygon
add txx,40



dec xt
cmp xt,0
jne @xtmap_loop
add tyy,50
dec yt
cmp yt,0
jne @ytmap_loop

call waitretrace

call flip_and_clear

inc angle
cmp angle,90
jnge @continue2
mov angle,0
@continue2:
inc timer
cmp timer,90;190
jnae @do_it_all_again2
ret
tmaptest Endp


Cube proc near
mov ax,virtualscreen_seg
mov where,ax ;{this is where the image is outputted}
mov angle,0
mov pos,0
mov timer,0
;{start of loop to draw the next frame}
mov t,0
;{these three are where the object is positioned on the screen}
mov xoff,160
mov yoff,100
mov zoff,0
call @init_cubes
@do_it_all_again:
;{These three are the points that the object rotates around}
mov xrot,25
mov yrot,25
mov zrot,-25
;{these three are the angles that the object has rotated around each axis}
mov ax,angle
shl ax,2
mov xdeg,ax
mov ydeg,ax
mov zdeg,ax
;{start of loop to get and draw the polys}
mov pos,0
@draw_and_get_loop:
;{get the values from the array}

call @move_cubes
mov si,0
mov loop1,0
@anim_many_cubes:
mov ax,parts[si+6]
mov xoff,ax
mov ax,parts[si+8]
mov yoff,ax
mov ax,parts[si+10]
mov zoff,ax
mov ax,parts[si+12]
add si,14
pusha
mov col,al
call @draw_the_cube
popa
inc loop1
cmp loop1,15
jne @anim_many_cubes

call flip_and_clear


  ;clear the z-buffer
  mov ax,virtualscreen2_seg
  mov es,ax
  xor di,di
  mov cx,16000
  xor eax,eax
  rep stosd

inc angle
cmp angle,90
jnge @continue
mov angle,0
@continue:
call keypressed
inc timer
cmp timer,90;190
jne @do_it_all_again
ret


@draw_the_cube:
mov x1,0
mov y1,0
mov z1,-50
mov x2,50
mov y2,0
mov z2,-50
mov x3,50
mov y3,50
mov z3,-50
call draw_polygon
mov x1,0
mov y1,0
mov z1,-50
mov x2,0
mov y2,50
mov z2,-50
mov x3,50
mov y3,50
mov z3,-50
call draw_polygon
mov x1,0
mov y1,0
mov z1,0
mov x2,50
mov y2,0
mov z2,0
mov x3,50
mov y3,50
mov z3,0
call draw_polygon
mov x1,0
mov y1,0
mov z1,0
mov x2,0
mov y2,50
mov z2,0
mov x3,50
mov y3,50
mov z3,0
call draw_polygon
mov x1,0
mov y1,0
mov z1,0
mov x2,0
mov y2,0
mov z2,-50
mov x3,0
mov y3,50
mov z3,-50
call draw_polygon
mov x1,0
mov y1,0
mov z1,0
mov x2,0
mov y2,50
mov z2,0
mov x3,0
mov y3,50
mov z3,-50
call draw_polygon
mov x1,50
mov y1,0
mov z1,0
mov x2,50
mov y2,0
mov z2,-50
mov x3,50
mov y3,50
mov z3,-50
call draw_polygon
mov x1,50
mov y1,0
mov z1,0
mov x2,50
mov y2,50
mov z2,0
mov x3,50
mov y3,50
mov z3,-50
call draw_polygon
mov x1,0
mov y1,0
mov z1,0
mov x2,0
mov y2,0
mov z2,-50
mov x3,50
mov y3,0
mov z3,-50
call draw_polygon
mov x1,0
mov y1,0
mov z1,0
mov x2,50
mov y2,0
mov z2,0
mov x3,50
mov y3,0
mov z3,-50
call draw_polygon
mov x1,0
mov y1,50
mov z1,0
mov x2,0
mov y2,50
mov z2,-50
mov x3,50
mov y3,50
mov z3,-50
call draw_polygon
mov x1,0
mov y1,50
mov z1,0
mov x2,50
mov y2,50
mov z2,0
mov x3,50
mov y3,50
mov z3,-50
call draw_polygon
ret

@init_cubes:
mov randseed,1234h
mov si,0
mov loop1,0
@create_many_cubes:
  mov dx,201
  call randomi
  mov bx,rr
  mov ax,3
  cmp bx,100
  jl @serg1
  sub ax,6
  @serg1:
  mov parts[si],ax   ;xoffinc
  add si,2
  ;mov ax,3
  mov dx,201
  call randomi
  mov bx,rr
  mov ax,3
  cmp bx,100
  jl @serg2
  sub ax,6
  @serg2:
  mov parts[si],ax   ;yoffinc
  add si,2
  mov ax,3
  mov parts[si],ax   ;zoffinc
  add si,2
  mov ax,160
  mov dx,321
  call randomi
  mov ax,rr
  add ax,30
  mov parts[si],ax   ;xoff
  add si,2
  mov ax,100
  mov dx,191
  call randomi
  mov ax,rr
  mov parts[si],ax   ;yoff
  add si,2
  mov ax,0
  mov dx,49
  call randomi
  mov ax,rr
  mov parts[si],ax   ;zoff
  add si,2

  call randomy
  mov bx,tempt
  shl bx,1
  xor bh,bh
  mov al,10
  cmp bx,192
  jg @not1
  mov al,202
  @not1:
  cmp bx,128
  jg @not2
  mov al,138
  @not2:
  cmp bx,63
  jg @not3
  mov al,73
  @not3:


  mov parts[si],ax   ;col
  add si,2

inc loop1
cmp loop1,15
jne @create_many_cubes
mov xoffinc,3
mov yoffinc,3
mov zoffinc,3
ret

@move_cubes:
mov si,0
mov loop1,0
@move_many_cubes:
;**************************X MOVE
mov ax,parts[si]
mov bx,parts[si+6]
cmp ax,3
jne @xoffd
add bx,6
@xoffd:
sub bx,3

cmp bx,42
jg @no_x_chg1
mov ax,3
@no_x_chg1:
cmp bx,250
jl @no_x_chg2
mov ax,-3
@no_x_chg2:
mov parts[si],ax
mov parts[si+6],bx
add si,2

;**************************Y MOVE
mov ax,parts[si]
mov bx,parts[si+6]
cmp ax,3
jne @yoffd
add bx,6
@yoffd:
sub bx,3

cmp bx,28
jg @no_y_chg1
mov ax,3
@no_y_chg1:
cmp bx,150
jl @no_y_chg2
mov ax,-3
@no_y_chg2:
mov parts[si],ax
mov parts[si+6],bx
add si,2

;**************************Z MOVE
mov ax,parts[si]
mov bx,parts[si+6]
cmp ax,3
jne @zoffd
add bx,6
@zoffd:
sub bx,3
cmp bx,0
jg @no_z_chg1
mov ax,3
@no_z_chg1:
cmp bx,50
jl @no_z_chg2
mov ax,-3
@no_z_chg2:



mov parts[si],ax
mov parts[si+6],bx
add si,4
add si,6
inc loop1
cmp loop1,15
jne @move_many_cubes
ret

Cube Endp



perspective_pattern_precalc proc near
mov b,0
@pers_b:
mov a,0
@pers_a:
      mov ax,a
      sub ax,159
      mul ax
      mov cx,ax
      mov ax,b
      sub ax,99
      mul ax
      add cx,ax
      shr cx,5
      add cx,256     ;z value

      mov ax,a
      sub ax,320
      mov  dx,ax
      sal  ax,8
      sar  dx,8
      idiv cx
      add  ax,160
      mov  xer,ax

      mov ax,b
      sub ax,200
      mov  dx,ax
      sal  ax,8
      sar  dx,8
      idiv cx
      add  ax,100
      mov  yer,ax


mov ax,virtualscreen2_seg
mov es,ax
mov ax,b
mov di,ax
shl di,6
shl ax,8
add di,ax
add di,a
mov ax,xer
add ax,50
mov es:[di],al
mov ax,virtualscreen3_seg
mov es,ax
mov ax,yer
add ax,50
mov es:[di],al


inc a
cmp a,320
jne @pers_a
inc b
cmp b,200
jne @pers_b
ret
perspective_pattern_precalc endp

perspective_pattern_draw proc near
sub c,3
xor di,di
mov b,0
@persdraw_b:
mov a,0
@persdraw_a:
    mov ax,virtualscreen2_seg
    mov es,ax
    xor ax,ax
    mov al,es:[di]
    sub ax,50
    mov xer,ax
    mov ax,virtualscreen3_seg
    mov es,ax
    xor ax,ax
    mov al,es:[di]
    sub ax,50
    mov yer,ax

    mov ax,virtualscreen_Seg
    mov es,ax
    mov si,yer
    add si,c
    mov ax,si
    shl si,6
    shl ax,8
    add si,ax
    add si,xer
    mov al,es:[si]
    mov bx,virtualscreen4_Seg
    mov es,bx
    stosb
inc a
cmp a,320
jne @persdraw_a
inc b
cmp b,200
jne @persdraw_b
ret
perspective_pattern_draw endp

perspective_roll proc near
call perspective_pattern_precalc
mov c,110
@persloop:
call perspective_pattern_draw
mov ax,virtualscreen4_seg
mov source,ax
mov ax,0a000h
mov dest,ax
call flip
cmp c,-80
jge @persloop
ret
perspective_Roll endp

pattern1 proc near
mov temp,0
@pattern1_do:
mov ax,0a000h
mov es,ax
mov di,0
@more1:
xor dx,dx
mov bx,320
mov ax,di
div bx
mov y,ax
mov x,dx

mov ax,y
shl ax,1
sub ax,x
mul x
shr ax,8
add ax,temp
stosb
cmp di,64000
jne @more1
add temp,10
cmp temp,250
jne @pattern1_do
ret
pattern1 endp

pattern2 proc near
mov temp,0
@pattern2_do:
mov ax,0a000h
mov es,ax
mov di,0
@more2:
xor dx,dx
mov bx,320
mov ax,di
div bx
mov y,ax
mov x,dx

mov ax,x
mul x
mov bx,x
add bx,x
add bx,7520
mul bx
mov bx,ax
mov ax,y
mul y
mov dx,x
add dx,x
mul dx
add ax,bx
shr ax,6
add ax,temp
stosb

cmp di,64000
jne @more2
add temp,10
cmp temp,250
jne @pattern2_do
ret
pattern2 endp

pattern3 proc near
mov temp,0
@pattern3_do:
mov ax,0a000h
mov es,ax
mov di,0
@more3:
xor dx,dx
mov bx,320
mov ax,di
div bx
mov y,ax
mov x,dx

mov ax,x
mul ax
mov bx,y
add bx,bx
mul bx
mov bx,ax
mov ax,y
mul ax
mov dx,x
add dx,dx
mul dx
add ax,bx
shr ax,6
add ax,temp
stosb
cmp di,64000
jne @more3
add temp,10
cmp temp,250
jne @pattern3_do
ret
pattern3 endp

pattern4 proc near
mov temp,0
@pattern4_do:
mov ax,0a000h
mov es,ax
mov di,0
@more4:
xor dx,dx
mov bx,320
mov ax,di
div bx
mov y,ax
mov x,dx

mov ax,x
mul ax
mov dx,x
add dx,dx
mul dx
mov bx,ax
mov ax,y
mul ax
mov dx,x
add dx,dx
mul dx
add ax,bx
shr ax,6
add ax,temp
stosb
cmp di,64000
jne @more4
add temp,10
cmp temp,250
jne @pattern4_do
ret
pattern4 endp

pattern5 proc near
mov temp,0
@pattern5_do:
mov ax,0a000h
mov es,ax
mov di,0
@more5:
xor dx,dx
mov bx,320
mov ax,di
div bx
mov y,ax
mov x,dx

mov ax,x
mul ax
mov dx,y
add dx,x
mul dx
mov bx,ax
mov ax,y
mul ax
mov dx,y
add dx,x
mul dx
add ax,bx
shr ax,6
add ax,temp
stosb
cmp di,64000
jne @more5
add temp,10
cmp temp,250
jne @pattern5_do
ret
pattern5 endp

pattern6 proc near
mov temp,0
@pattern6_do:
mov ax,0a000h
mov es,ax
mov di,0
@more6:
xor dx,dx
mov bx,320
mov ax,di
div bx
mov y,ax
mov x,dx

mov ax,y
mul x
mov bx,x
shl bx,1
add bx,y
add ax,bx
mul x
shr ax,8
add ax,temp
stosb
cmp di,64000
jne @more6
add temp,10
cmp temp,250
jne @pattern6_do
ret
pattern6 endp

bumppal proc near
mov cx,0
   mov    dx,3c8h
   mov    al,0
   out    dx,al
   inc    dx
@pal1c:
   mov    al,0
   out    dx,al
   out    dx,al
   out    dx,al
   inc    cx
cmp cx,192
jne @pal1c
ret
bumppal endp

createmap proc near
xor di,di
mov y,1
@circley:
   mov x,1
   @circlex:
      ;col:=((x-15)*(x-15)+(y-15)*(y-15));
      mov ax,x
      sub ax,15
      mov bx,ax
      imul bx
      mov cx,ax
      mov ax,y
      sub ax,15
      mov bx,ax
      imul bx
      add ax,cx
      ;col:=col*temp;
      mov bx,temp
      imul bx
      ;col:=col shr 2;
      shr ax,2

      ;cmp pos2,100
      ;jne @normal
      ;;col:=128-col;
      ;mov bx,128
      ;sub bx,ax
      ;mov ax,bx
      ;@normal:

      ;if col>128 then col:=128;
      ;if col<0 then col:=0;
      cmp ax,128
      jle @noblock1
         mov ax,128
      @noblock1:
      cmp ax,0
      jge @noblock2
         mov ax,0
      @noblock2:
      mov bally[di],al
   inc di
   inc x
   cmp x,30
   jng @circlex
inc y
cmp y,30
jng @circley

xor di,di
mov y,0
@circle_multiply_y:
   mov x,0
   @circle_multiply_x:
      mov b,1
      mov di,0
      @draw_it_y:
         mov a,1
         @draw_it_x:
            ;if ((yoffs*30)+y)<199 then
            mov bx,30
            mov ax,y
            imul bx
            add ax,b
            cmp ax,199
            jg @nodraw_circle
            ;mem[v1:x+(xoffs*30)+((y+(yoffs*30))*320)]:=bally[x,y];
            mov bx,ax
            shl bx,8
            shl ax,6
            add ax,bx
            mov si,ax
            mov ax,x
            mov bx,30
            imul bx
            add ax,a
            cmp ax,319
            jg @nodraw_circle
            add si,ax
            mov bx,virtualscreen_seg
            mov es,bx
            mov al,bally[di]
            mov es:[si],al
            @nodraw_circle:inc di
         inc a
         cmp a,30
         jng @draw_it_x
      inc b
      cmp b,30
      jng @draw_it_y
   inc x
   cmp x,10
   jng @circle_multiply_x
inc y
cmp y,6
jng @circle_multiply_y
ret
createmap endp


bumpmap proc near
    ;lx:=round(cos(l1/13)*66+160);
    ;ly:=round(sin(l1/23)*66+100);
    mov bx,pos
    mov aa2,bx
    mov a2,bx
    call check_fake_cos_range
    mov bx,aa2
    cmp aa2,0
    jg @no123
    neg bx
    @no123:
    shl bx,1
    mov ax,word ptr lcos[bx]
    shr ax,8
    cmp aa2,0
    jg @yes123
    neg ax
    @yes123:
    add ax,160
    mov lx,ax

    mov bx,pos
    mov a1,bx
    mov aa1,bx
    call check_fake_sin_range
    mov bx,aa1
    cmp aa1,0
    jg @no456
    neg bx
    @no456:
    shl bx,1
    mov ax,word ptr lsin[bx]
    shr ax,8
    cmp aa1,0
    jg @yes456
    neg ax
    @yes456:

    add ax,100
    mov ly,ax

	  xor di,di
	  mov y,0
	  @bump_y:
	  mov x,0
	  @bump_x:
	  ;calculate the light vector}
	  mov ax,x
	  sub ax,lx
	  mov vlx,ax

	  mov ax,y
	  sub ax,ly
	  mov vly,ax
	  ;Check if area is NEAR}
	  cmp vlx,165
	  jg @no_bump_draw
	  cmp vlx,-165
	  jl @no_bump_draw
	  cmp vly,165
	  jg @no_bump_draw
	  cmp vly,-165
	  jl @no_bump_draw

	  ;Gets pixel colours to determine slopes with}
	  mov ax,virtualscreen_Seg
	  mov es,ax
	  inc di
	  mov al,es:[di]
	  sub di,2
	  mov bl,es:[di]
	  xor ah,ah
	  xor bh,bh
	  sub ax,bx
	  mov nx,ax
	  inc di

	  add di,320
	  mov al,es:[di]
	  sub di,640
	  mov bl,es:[di]
	  xor ah,ah
	  xor bh,bh
	  sub ax,bx
	  mov ny,ax
	  add di,320

	  ;calc X-BUMP value}
	  mov ax,vlx
	  shl ax,0
	  sub ax,nx
	  cmp ax,0
	  jg @no_bump_abs1
	  neg ax
	  @no_bump_abs1:
	  cmp ax,255
	  jl @no_bump_jump1
	  mov ax,255
	  @no_bump_jump1:
	  mov bx,255
	  sub bx,ax

	  ;calc Y-BUMP value}
	  mov ax,vly
	  shl ax,0
	  sub ax,ny
	  cmp ax,0
	  jg @no_bump_abs2
	  neg ax
	  @no_bump_abs2:
	  cmp ax,255
	  jl @no_bump_jump2
	  mov ax,255
	  @no_bump_jump2:
	  mov dx,255
	  sub dx,ax

	  ;draw bump}
	  add bx,dx
          shr bx,1
	  cmp bl,255
	  jg @no_bump_draw
	     ;mov ax,0a000h
	     mov ax,virtualscreen5_seg
	     mov es,ax
	     mov es:[di],bl

	  @no_bump_draw:inc di
	  inc x
	  cmp x,320
	  jne @bump_x
	  inc y
	  cmp y,200
	  jne @bump_y
ret
bumpmap endp


bump_ripple proc near
mov persbum,0
call nicepal_set
call bumppal
mov temp,2
mov tinc,1
mov pos,1
mov ax,virtualscreen5_seg
call cls
@persbump:
call createmap
mov ax,tinc
add temp,ax
cmp temp,8
jl @no_tinc1
mov tinc,-1
@no_tinc1:
cmp temp,2
jg @no_tinc2
mov tinc,1
@no_tinc2:
add pos,12
cmp pos,360
jng @no_pos
mov pos,1
@no_pos:

call bumpmap
mov ax,virtualscreen5_Seg
mov source,ax
mov ax,0a000h
mov dest,ax
call flip
mov ax,virtualscreen5_seg
call cls
inc persbum
cmp persbum,80
jne @persbump
ret
bump_ripple endp


zoomer proc near
;init yloop
mov b,0
xor dx,dx
mov ax,200
shl ax,7
mov bx,desty
idiv bx
mov bstep,ax
mov y,99
@zoom_yloop:

;init xloop
mov a,0
xor dx,dx
mov ax,320
shl ax,7
mov bx,destx
idiv bx
mov astep,ax
mov x,0
@zoom_xloop:
mov ax,virtualscreen2_seg ;***
mov es,ax
mov di,a

shr di,7
sub di,160
mov bx,b
shr bx,7
add bx,99
add bx,1
mov dx,bx
shl dx,6
shl bx,8
add bx,dx
add di,bx
mov al,es:[di]

mov bx,virtualscreen_seg
mov es,bx
mov bx,y
mov di,bx
shl di,6
shl bx,8
add di,bx
add di,x
add di,160
mov es:[di],al

;col:=mem[$a000:160-(a shr 7)+(((b shr 7)+99)*320)];
;mem[v1:160-x+((y)*320)]:=col;

mov ax,virtualscreen2_seg ;***
mov es,ax
mov di,160
mov ax,a
shr ax,7
sub di,ax
mov bx,b
shr bx,7
add bx,99
mov dx,bx
shl dx,6
shl bx,8
add bx,dx
add di,bx
mov al,es:[di]

mov bx,virtualscreen_seg
mov es,bx
mov bx,y
mov di,bx
shl di,6
shl bx,8
add di,bx
mov bx,160
sub bx,x
add di,bx
mov es:[di],al

;col:=mem[$a000:160-(a shr 7)+((99-(b shr 7))*320)];
;mem[v1:160-x+((198-y)*320)]:=col;

mov ax,virtualscreen2_seg  ;***
mov es,ax
mov di,160
mov ax,a
shr ax,7
sub di,ax
mov bx,b
shr bx,7
mov ax,99
sub ax,bx
mov dx,ax
shl dx,6
shl ax,8
add ax,dx
add di,ax
mov al,es:[di]

mov bx,virtualscreen_seg
mov es,bx
mov bx,198
sub bx,y
mov di,bx
shl di,6
shl bx,8
add di,bx
mov bx,160
sub bx,x
add di,bx
mov es:[di],al

;col:=mem[$a000:(a shr 7)-160+((99-(b shr 7)+1)*320)];
;mem[v1:160+x+((198-y)*320)]:=col;

mov ax,virtualscreen2_seg ;***
mov es,ax
mov di,a
shr di,7
sub di,160
mov bx,b
shr bx,7
mov ax,99
sub ax,bx
add ax,1
mov dx,ax
shl dx,6
shl ax,8
add ax,dx
add di,ax
mov al,es:[di]

mov bx,virtualscreen_seg
mov es,bx
mov bx,198
sub bx,y
mov di,bx
shl di,6
shl bx,8
add di,bx
add di,x
add di,160
mov es:[di],al
inc x
mov ax,astep
add a,ax
cmp x,160
jna @zoom_xloop

inc y
mov ax,bstep
add b,ax
cmp y,199
jna @zoom_yloop
ret
zoomer endp


zoomer_run proc near
mov desty,215
mov destx,345
mov timer,0
    mov ax,0a000h
    mov source,ax
    mov ax,virtualscreen2_seg
    mov dest,ax
    call flip
@zoom_more:
call zoomer
    mov ax,virtualscreen_seg         ;flipping and smoothing
    mov es,ax
    call smooth_filter

    mov ax,virtualscreen_seg
    mov source,ax
    mov ax,0a000h
    mov dest,ax
    call flip
    mov ax,virtualscreen_seg
    mov source,ax
    mov ax,virtualscreen2_seg
    mov dest,ax
    call flip
inc timer
cmp timer,40
jne @zoom_more
ret
zoomer_run endp

zoomer_pattern_run proc near
mov desty,215
mov destx,345
mov timer,0
mov seed,1234h
@zoom_pattern_more:

cmp timer,90
ja @nomoreboxy
mov ax,virtualscreen2_seg ;***
mov es,ax
mov di,90
mov bx,di
shl bx,6
shl di,8
add di,bx
add di,150
mov dx,0
@boxdrawy:

call randomy
mov ax,tempt
mov cx,20
@hloop:call randomy
mov ax,tempt
stosb
loop @hloop

sub di,20
add di,320
inc dx
cmp dx,20
jne @boxdrawy
@nomoreboxy:

    call zoomer
    mov ax,virtualscreen_seg         ;flipping and smoothing
    mov es,ax
    call smooth_filter
    mov ax,virtualscreen_seg
    mov source,ax
    mov ax,0a000h
    mov dest,ax
    call flip
    mov ax,virtualscreen_seg
    mov source,ax
    mov ax,virtualscreen2_seg
    mov dest,ax
    call flip

inc timer
cmp timer,150
jne @zoom_pattern_more
ret
zoomer_pattern_run endp


randomi proc near;
;inputs are DX, which is the range of results...
;simple random(sort of) number generator
pusha
mov     ax,[RandSeed]
mul     dx
inc     ax
mov     [RandSeed],ax
mov     rr,dx
popa
ret
randomi endp


particles proc near
mov randseed,1234h
mov si,1
@set_points:
mov dx,321
call randomi
mov ax,rr
shl si,1
mov parts[si],ax   ;x co-ord
shr si,1
mov dx,201
call randomi
mov ax,rr
add si,1200
shl si,1
mov parts[si],ax   ;y co-ord
shr si,1
sub si,1200
inc si
cmp si,1200
jna @set_points

mov loop2,1
@do_particles_anim:

mov si,2400
@set_points_direction:
mov dx,4321
call randomi
mov dx,7
call randomi
mov ax,rr
sub ax,3
mov di,si
shl di,1
mov parts[di],ax
;shr si,1
mov dx,7
call randomi
mov ax,rr
sub ax,3
add si,1200
;shl si,1
mov di,si
shl di,1
mov parts[di],ax
;shr si,1
sub si,1200
inc si
cmp si,4800
jnae @set_points_direction


mov loop1,1

@draw_particles:
mov si,loop1
shl si,1
mov ax,parts[si]
shr si,1
mov x,ax
add si,1200
shl si,1
mov ax,parts[si]
shr si,1
sub si,1200
mov y,ax

mov bx,y
mov di,bx
shl di,6
shl bx,8
add di,bx
add di,x
mov ax,virtualscreen2_seg
mov es,ax
mov dl,7
@drawpart:
mov cl,7
@horiz_draw_part:
mov al,es:[di]
cmp al,186
ja @no_draw_part
add byte ptr es:[di],6
@no_draw_part:
inc di
dec cl
cmp cl,0
jne @horiz_draw_part
add di,313
dec dl
cmp dl,0
jne @drawpart

inc loop1
cmp loop1,1200
jna @draw_particles

mov si,1
@move_parts_around:
shl si,1
mov ax,parts[si]
shr si,1
add si,2400
shl si,1
add ax,parts[si]
shr si,1
sub si,2400
shl si,1
mov parts[si],ax
shr si,1
add si,1200
shl si,1
mov ax,parts[si]
shr si,1
sub si,1200
add si,3600
shl si,1
add ax,parts[si]
shr si,1
sub si,3600
add si,1200
shl si,1
mov parts[si],ax
shr si,1
sub si,1200

;cmp parts[bx],0
;ja @edgechek1
;mov parts[bx],0
;@edgechek1:
;cmp parts[bx+1200],0
;ja @edgechek2
;mov parts[bx+1200],0
;@edgechek2:
;cmp parts[bx],319
;jle @edgechek3
;mov parts[bx],319
;@edgechek3:
;cmp parts[bx+1200],199
;jle @edgechek4
;mov parts[bx+1200],199
;@edgechek4:



inc si
cmp si,1200
jna @move_parts_around

    mov ax,virtualscreen2_seg         ;flipping and smoothing
    mov es,ax
    call smooth_filter

mov ax,virtualscreen2_seg
mov es,ax
xor di,di
mov cx,32000

@do_it_more:
  mov ax,es:[di]

  cmp al,6
  jb @end_fade1
    sub al,6
    mov es:[di],al
  @end_fade1:
  cmp ah,6
    jb @end_fade2
    sub ah,6
    inc di
    mov es:[di],ah
    dec di
  @end_fade2:
add di,2
dec cx
jnz @do_it_more

       mov ax,virtualscreen2_seg
       mov es,ax
       xor di,di
       mov cx,640
       xor ax,ax
       rep stosw
       mov di,63360
       mov cx,640
       rep stosw

    mov ax,virtualscreen2_seg
    mov source,ax
    mov ax,0a000h
    mov dest,ax
    call flip

inc loop2
cmp loop2,180
jne @do_particles_anim
ret
particles endp


rotation_patterns proc near
mov xrot,160
mov yrot,10
mov zrot,20
mov xdeg,0
mov ydeg,0
mov zdeg,0
mov loop1,1
@rot_pats_anim:
cmp pat,1
jne @notpat1
;1st pattern
add xdeg,1
add ydeg,3
add zdeg,4
@notpat1:
cmp pat,2
jne @notpat2
;2nd pattern
add xdeg,1
add ydeg,0
add zdeg,4
@notpat2:

cmp xdeg,360
jle @x_cheked
    mov ax,virtualscreen_seg
    mov es,ax
    call smooth_filter
    mov ax,virtualscreen_seg
    mov source,ax
    mov ax,0a000h
    mov dest,ax
    call flip
mov xdeg,0
@x_cheked:
cmp ydeg,360
jle @y_cheked
mov ydeg,0
@y_cheked:
cmp zdeg,360
jle @z_cheked
mov zdeg,0
@z_cheked:

mov xx1,160
mov yy1,100
mov zz1,0
call rotatepointfast
mov ax,xer
mov xx1,ax
mov ax,yer
mov yy1,ax
mov ax,zer
mov zz1,ax
call PerspectiveProject
mov xer,bx
mov yer,ax

mov ax,virtualscreen_seg
mov es,ax
mov bx,yer
sub bx,115
mov di,bx
shl di,8
shl bx,6
add di,bx
add di,xer
add di,60
mov ax,zer
sub ax,150
mov es:[di],al

inc loop1
cmp loop1,50000
jnae @rot_pats_anim

ret
rotation_patterns endp


;****************************************************************************
;FONT SECTION - fontpal, fontdraw, writer
;****************************************************************************



fontpal proc near
mov r,0
   mov    dx,3c8h
   mov    al,0
   out    dx,al
   inc    dx
@fontpal_loop:
   mov    al,0
   out    dx,al
   out    dx,al
   out    dx,al
   inc    r
cmp r,63
jne @fontpal_loop
   mov    dx,3c8h
   mov    al,7
   out    dx,al
   inc    dx
   mov    al,0
   out    dx,al
   out    dx,al
   out    dx,al
ret
fontpal endp

font_fadeup proc near
mov r,0
@f_fup1:
   call waitretrace
   call waitretrace
   mov loop1,1
   @f_fup2:
   mov    dx,3c7h
   mov    ax,loop1
   out    dx,al
   add dx,2
   in    al,dx
   mov   bl,al

   mov    dx,3c8h
   mov    ax,loop1
   out    dx,al
   inc    dx
   mov    al,bl
   xor    ah,ah
   cmp    ax,loop1
   jg @notup
   inc al
   @notup:
   out    dx,al
   out    dx,al
   out    dx,al
   inc loop1
   cmp loop1,64
   jne @f_fup2

   inc r
cmp r,64
jne @f_fup1
ret
font_fadeup endp


font_fadedown proc near
mov r,0
@f_fdown1:
   call waitretrace
   call waitretrace
   mov loop1,0
   @f_fdown2:
   mov    dx,3c7h
   mov    ax,loop1
   out    dx,al
   add dx,2
   in    al,dx
   mov   r1,al
   in    al,dx
   mov   g1,al
   in    al,dx
   mov   b1,al


   mov    dx,3c8h
   mov    ax,loop1
   out    dx,al
   inc    dx
   mov    al,r1
   cmp    al,0
   je @notdown
   dec al
   @notdown:
   out    dx,al

   mov    al,g1
   cmp    al,0
   je @notdown2
   dec al
   @notdown2:
   out    dx,al

   mov    al,b1
   cmp    al,0
   je @notdown3
   dec al
   @notdown3:
   out    dx,al

;   out    dx,al
;   out    dx,al
   inc loop1
   cmp loop1,255
   jne @f_fdown2

   inc r
cmp r,64
jne @f_fdown1
ret
font_fadedown endp




fontdraw proc near
mov dx,yoffs           ;{yoffs}
mov si,0
@text_y:
mov bx,0
@text_x:

mov ax,0a000h
mov es,ax
mov cl,es:[si]
xor ch,ch
cmp cl,0
je @nodraw
add cl,55

mov ax,virtualscreen_Seg
mov es,ax
;{mem[v1:(((x*5)+a) shr 1)+76+(((y*5)+b+75)*320)]:=mem[$a000:x+(y*320)]+55;}
mov ax,dx
mov di,ax
shl ax,6
shl di,8
add di,ax

mov ax,bx
shr ax,1
add ax,xoffs
add di,ax

mov ch,cl

mov es:[di],cx
mov es:[di+320],cx
mov es:[di+640],cx
mov es:[di+960],cx
mov es:[di+1280],cx

add di,2
mov es:[di],cl
mov es:[di+320],cl
mov es:[di+640],cl
mov es:[di+960],cl
mov es:[di+1280],cl

@nodraw:

inc si
add bx,5
cmp bx,320               ;{(64*5)}
jne @text_x
add dx,5
add si,256
cmp si,2240            ;{320*7}
jne @text_y
ret
fontdraw endp

writer proc near
;"Sensory"
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset text1
int 21h
  mov xoffs,16
  mov yoffs,60
  call fontdraw

;"Overload"
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset text2
int 21h
  mov xoffs,146
  mov yoffs,100
  call fontdraw
mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw

  mov ax,virtualscreen_seg
  mov source,ax
  mov ax,0a000h
  mov dest,ax
  call flip
call font_fadeup

   mov bx,500             ;delay 2ms **************************************!
   mov ax, 3000
   mul bx
   mov cx, dx
   mov dx, ax
   mov ah, 86h
   int 15h
mov ax,virtualscreen_seg
mov es,ax
xor di,di
mov cx,16000
mov eax,0
rep stosd
call font_fadedown

;"Presents"
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset text3
int 21h
  mov xoffs,76
  mov yoffs,76
  call fontdraw
mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw



  mov ax,virtualscreen_seg
  mov source,ax
  mov ax,0a000h
  mov dest,ax
  call flip

call font_fadeup
   mov bx,500             ;delay 2ms **************************************!
   mov ax, 3000
   mul bx
   mov cx, dx
   mov dx, ax
   mov ah, 86h
   int 15h
mov ax,virtualscreen_seg
mov es,ax
xor di,di
mov cx,16000
mov eax,0
rep stosd
call font_fadedown

;"Qing"
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset text4
int 21h
  mov xoffs,6
  mov yoffs,60
  call fontdraw

;"&"
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset text5
int 21h
  mov xoffs,56
  mov yoffs,76
  call fontdraw

;"Kween"
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset text6
int 21h
  mov xoffs,130
  mov yoffs,100
  call fontdraw

mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw

  mov ax,virtualscreen_seg
  mov source,ax
  mov ax,0a000h
  mov dest,ax
  call flip

call font_fadeup
   mov bx,500             ;delay 2ms **************************************!
   mov ax, 5000
   mul bx
   mov cx, dx
   mov dx, ax
   mov ah, 86h
   int 15h
call font_fadedown

ret
writer endp


load_photo proc near
mov x,0
mov di,3290
mov ax,virtualscreen_seg
mov es,ax
mov al,64
mov bx,5
@draw_pic_pixel:
mov cl,photo[bx]

xor ch,ch
rep stosb

cmp al,0
jne @decy_it
mov al,128
@decy_it:sub al,64

inc bx
cmp bx,4907
jne @draw_pic_pixel


ret
load_photo endp

load_photo2 proc near
mov x,0
mov di,3290
mov ax,virtualscreen_seg
mov es,ax
mov al,120
mov bx,5
@draw_pic_pixel2:
mov cl,photo[bx]

xor ch,ch
rep stosb

cmp al,0
jne @decy_it2
mov al,240
@decy_it2:sub al,120

inc bx
cmp bx,4907
jne @draw_pic_pixel2

mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
call smooth_filter
call smooth_filter


ret
load_photo2 endp


warpphoto proc near
mov ax,virtualscreen_seg
mov where,ax ;{this is where the image is outputted}
mov angle,0
mov pos,0
mov timer,0
;{start of loop to draw the next frame}
mov t,0
mov txx,0
mov tyy,0
mov pos,1
mov pos,1
@warp_more:
add pos,12
add pos2,24
cmp pos,360
jng @no_pos2
mov pos,1
@no_pos2:
cmp pos2,360
jng @no_pos3
mov pos2,1
@no_pos3:

    ;lx:=round(cos(l1/13)*66+160);
    ;ly:=round(sin(l1/23)*66+100);
    mov bx,pos
    mov aa2,bx
    mov a2,bx
    call check_fake_cos_range
    mov bx,aa2
    cmp aa2,0
    jg @noa123
    neg bx
    @noa123:
    shl bx,1
    mov ax,word ptr lcos[bx]
    shr ax,9
    cmp aa2,0
    jg @yesa123
    neg ax
    @yesa123:
    add ax,224
    mov lx,ax

    mov bx,pos2
    mov a1,bx
    mov aa1,bx
    call check_fake_sin_range
    mov bx,aa1
    cmp aa1,0
    jg @noa456
    neg bx
    @noa456:
    shl bx,1
    mov ax,word ptr lsin[bx]
    shr ax,9
    cmp aa1,0
    jg @yesa456
    neg ax
    @yesa456:
    add ax,164
    mov ly,ax


mov ax,virtualscreen_seg
mov dest,ax
mov ax,virtualscreen2_seg
mov source,ax
call flip
mov ax,3
int 33h
mov cx,lx
mov dx,ly
;{mov cx,224
;mov dx,164}
mov a,cx
mov b,dx
;{These three are the points that the object rotates around}
mov xrot,160
mov yrot,100
mov zrot,0
;{these three are where the object is positioned on the screen}
mov xoff,0
mov yoff,0
mov zoff,0
;{these three are the angles that the object has rotated around each axis}
mov ax,angle
shl ax,2
mov xdeg,0
mov ydeg,0
mov zdeg,0
;{start of loop to get and draw the polys}
mov cx,a
mov dx,b
sub cx,64   ;mousexpos
sub dx,64   ;mouseypos

mov x1,160
mov y1,10
mov z1,0
mov x2,cx
mov y2,dx
mov z2,0
mov x3,80
mov y3,100
mov z3,0
mov tx1,160
mov ty1,10
mov tx2,160
mov ty2,100
mov tx3,80
mov ty3,100
call tmap_polygon   ;top left

mov cx,a
mov dx,b
sub cx,64   ;mousexpos
sub dx,64   ;mouseypos

mov x1,240
mov y1,100
mov z1,0
mov x2,cx
mov y2,dx
mov z2,0
mov x3,160
mov y3,10
mov z3,0
mov tx1,240
mov ty1,100
mov tx2,160
mov ty2,100
mov tx3,160
mov ty3,10
call tmap_polygon   ;top right

mov cx,a
mov dx,b
sub cx,64   ;mousexpos
sub dx,64   ;mouseypos

mov x1,240
mov y1,100
mov z1,0
mov x2,160
mov y2,190
mov z2,0
mov x3,cx
mov y3,dx
mov z3,0
mov tx1,240
mov ty1,100
mov tx2,160
mov ty2,190
mov tx3,160
mov ty3,100
call tmap_polygon   ;bottom right

mov cx,a
mov dx,b
sub cx,64   ;mousexpos
sub dx,64   ;mouseypos

mov x1,cx
mov y1,dx
mov z1,0
mov x2,160
mov y2,190
mov z2,0
mov x3,80
mov y3,100
mov z3,0
mov tx1,160
mov ty1,100
mov tx2,160
mov ty2,190
mov tx3,80
mov ty3,100
call tmap_polygon   ;bottom left

call waitretrace
mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
mov ax,0a000h
mov dest,ax
mov ax,virtualscreen_seg
mov source,ax
;call flip
call flip_and_clear

inc angle
cmp angle,90
jnge @continue3
mov angle,0
@continue3:
inc timer
call keypressed
cmp timer,173
jne @warp_more
ret
warpphoto endp


bounce_text proc near
mov y,12
mov yer,1
mov loop1,0
@bounce_loop:
mov ax,yer
add y,ax
cmp y,15
jne @no_chg_dir1
mov yer,-1
@no_chg_dir1:
cmp y,11
jne @no_chg_dir2
mov yer,1
@no_chg_dir2:
                   ;the next few lines change the vertical size of chars
mov     dx,3D4h
mov     al,9
out     dx,al
inc     dx
in      al,dx
and     al,0f0h
add     ax,y
out     dx,al

call waitretrace
inc loop1
cmp loop1,200
jne @bounce_loop
ret
bounce_text endp




credits proc near
;"Coder:"
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset cred1
int 21h
  mov xoffs,-10
  mov yoffs,160
  call fontdraw

;"Raw-Hed"
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset cred2
int 21h
  mov xoffs,155
  mov yoffs,160
  call fontdraw
mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
ret
credits endp

writeit proc near
push dx
mov ax,virtualscreen_seg
call cls
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
pop dx
int 21h
  mov xoffs,86
  mov yoffs,76
  call fontdraw
mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw

  mov ax,virtualscreen_seg
  mov source,ax
  mov ax,0a000h
  mov dest,ax
  call flip
ret
writeit endp


greetz proc near
mov dx,offset greet1
call writeit
mov dx,offset greet2
call writeit
mov dx,offset greet3
call writeit
mov dx,offset greet4
call writeit
mov dx,offset greet5
call writeit
mov dx,offset greet6
call writeit
mov dx,offset greet7
call writeit
ret
greetz endp

endwriter proc near
;"THE END"
call fontpal
mov ax,virtualscreen_seg
call cls
MOV DH,1
MOV DL,1
DEC DH
DEC DL
MOV BH,0
MOV AH,2
INT 10h
mov ah,9
mov dx,offset endy1
int 21h
  mov xoffs,86
  mov yoffs,76
  call fontdraw
mov ax,virtualscreen_seg
mov es,ax
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw
call smooth_filter
xor di,di
mov cx,960
mov ax,0
rep stosw
mov di,63680
mov cx,160
rep stosw

  mov ax,virtualscreen_seg
  mov source,ax
  mov ax,0a000h
  mov dest,ax
  call flip

call font_fadeup

   mov bx,100             ;delay 2ms **************************************!
   mov ax, 5000
   mul bx
   mov cx, dx
   mov dx, ax
   mov ah, 86h
   int 15h



@look_more2:
;call greetz
cmp orderpos,22
jnae @look_more2



@look_more3:
cmp line,8
jnae @look_more3
call font_fadedown

call	ResetInt
call	EndPlayer

mov ax,virtualscreen_seg
mov es,ax
xor di,di
mov cx,16000
mov eax,0
rep stosd
ret
endwriter endp



init proc near
    call    Create_LSIN_Table_from_LCOSconst
    mov     ax,0013h
    int     10h       ; Get into 320x200x256 MCGA mode.
    call    init_points

    call    metal_rainbowpal
    mov     ax,virtualscreen_seg
    mov     es,ax
    xor     di,di
    mov     cx,32000
    mov     al,0
    mov     ah,al
    rep     stosw
    mov     ax,@DATA
    mov     ds,ax     ; Moves the segment of the data into DS.
ret
init endp


part1 proc near
call fontpal
call writer
mov ax,virtualscreen_seg
call cls
call shadebobs3d
call firepal
call redblue_pal
mov pat,1
call rotation_patterns
mov pat,2
call rotation_patterns
call redblue_pal
call nice_plasma
call firepal
;call dotface_anim
;call scissor_anim
mov ax,virtualscreen2_seg
call cls
call particles
call tmaptest
call firepal
mov ax,0a000h
mov es,ax
xor di,di
mov cx,16000
xor eax,eax
rep stosd
call firepal
call fire
call perspective_Roll
call zoomer_run
call nicepal_set
call nicepal_set
call cube

    mov     ax,0a000h
    mov     es,ax
    xor     di,di
    mov     cx,32000
    mov     ax,0
    rep     stosw

call    metal_rainbowpal
mov     c,0
mov     d,0
mov ax,0a000h
mov es,ax
@plasloop:
call drawplasma
call drawplasma2
add d,10
add c,10
cmp d,2480
jne @plasloop

call firepal
call pattern1
call pattern2
call pattern3
call pattern4
call pattern5
call pattern6
ret
part1 endp

part2 proc near
mov ax,virtualscreen_seg
call cls
call load_photo
call credits
call newpal1
mov ax,0a000h
mov dest,ax
mov ax,virtualscreen_seg
mov source,ax
call flip


   mov bx,400             ;delay 2ms **************************************!
   mov ax, 10000
   mul bx
   mov cx, dx
   mov dx, ax
   mov ah, 86h
   int 15h


call blur_off
call font_fadedown
call bump_ripple
mov ax,virtualscreen_seg
call cls
call load_photo2
mov ax,virtualscreen_seg
mov source,ax
mov ax,virtualscreen2_seg
mov dest,ax
call flip
mov ax,0a000h
call cls
call firepal
call warpphoto
mov ax,0a000h
mov source,ax
mov ax,virtualscreen2_seg
mov dest,ax
call flip
call zoomer_pattern_run
mov ax,0a000h
mov source,ax
mov ax,virtualscreen_seg
mov dest,ax
call flip
call firepal

    ;mov     ax,virtualscreen_seg
    ;mov     es,ax
    ;xor     di,di
    ;mov     cx,32000
    ;mov     ax,0
    ;rep     stosw
    ;mov     ax,0a000h
    ;mov     es,ax
    ;xor     di,di
    ;mov     cx,32000
    ;mov     ax,0
    ;rep     stosw

call complete_sf_seq
call endwriter

ret
part2 endp


START:

    pusha
    call    musstart
    popa
    mov     ax,@DATA
    mov     ds,ax     ; Moves the segment of the data into DS.

call init
call part1
call part2


    mov     ax,0003h
    int     10h       ; Get into 80x25 text mode
xor ax,ax
mov ah,09h
mov dx,offset EndText
int 21h           ;writes the end message on the screen
    call bounce_text
    mov     ax,4c00h  ; This function exits the program
    int     21h       ; and returns control to DOS.
;DEMO ENDS               ;End of code and data section
;END MAIN                 ;Terminate assembler and specify entry point



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Main.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
musStart:       push ds es
                cli
                mov	ax,cs
		mov	ds,ax

		mov	ax,Music
		mov	es,ax
		call	InitPlayer
		call	SetInt
                sti
                pop  es ds
                ret



;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Enables and starts the player interrupt.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetInt:		push	ax es

		cli
		xor	ax,ax
		mov	es,ax
		mov	ax,es:[8*4]
		mov	word ptr OldInt,ax
		mov	ax,es:2[8*4]
		mov	word ptr OldInt+2,ax
		mov	word ptr es:[8*4], offset PlayerInt
		mov	es:2[8*4],cs

		sti
		pop	es ax
		ret


@killmusic:	;stop tune
		call	ResetInt
		call	EndPlayer
		mov	ax,4c00h
		int	21h




;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Disables the player interrupt.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ResetInt:	push	ax es

		cli
		xor	ax,ax
		mov	es,ax
		mov	ax,word ptr OldInt
		mov	es:[8*4],ax
		mov	ax,word ptr OldInt+2
		mov	es:2[8*4],ax

		call	ResetTimer

		sti
		pop	es ax
		ret






;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; The player interrupt.  Called 50 times a second.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PlayerInt:	push	ax

		call	PlayMusic

	; see if we have passed 18.2/s mark
	@@lx:	mov	ax,TimerSteps		; this no. of steps per int.
		add	TimerCnt,ax
		jnc	@@ly			; don't call timer interrupt
		pop	ax
		jmp	cs:OldInt		; call old interrupt handlers

	; standard exit
	@@ly:	mov	al,20h
		out	20h,al
		pop	ax
		iret








;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Resets the interrupt timer back to 18.2/sec duty cycle.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ResetTimer:	push	ax

		mov	al,36h
		out	43h,al
		xor	al,al
		out	40h,al
		out	40h,al

		pop	ax
		ret


include		Player.Asm





OldInt		dd	?
TimerCnt	dw	?
TimerSteps	dw	?
 		ends



Music 		segment para public use16
 dd 020444152h,052207962h,0694C4145h,021215954h,0E2014210h,0F65804E2h,00CF4F5F2h,0E2020000h
 dd 0F65804E2h,00CF4F5F2h,0C1030000h,0F51808E1h,000F5F5A1h,0C1040001h,0F51808E1h,000F5F5A1h
 dd 0C1050001h,0F51808E1h,000F5F5A1h,0F2060001h,0201108F2h,000F3F410h,0F2070203h,0201108F2h
 dd 000F3F410h,0F0080203h,0F50000CFh,00E84F4F0h,030090000h,0F00008C0h,00454F4F8h,032000000h
 dd 002020100h,002020303h,002030304h,005030302h,004020205h,080060303h,080808080h,080808080h
 dd 080808080h,080808080h,080808080h,080808080h,000F28080h,004CD0298h,00BD40873h,00FA70CD4h
 dd 000000000h,000000000h,000000000h,000000000h,000000000h,000000000h,000000000h,000000000h
 dd 000000000h,000000000h,000000000h,000000000h,002000000h,03303302Ch,050370440h,086601C05h
 dd 00202000Fh,03303302Ch,050378440h,0302C0204h,084403303h,002055037h,03303302Ch,050378440h
 dd 0302C0207h,084403303h,002095037h,03303302Ch,050378440h,0302C020Bh,084403303h,0020C5037h
 dd 03303302Ch,050378440h,0302C020Eh,084403303h,002105037h,03303302Ch,050370440h,086000F05h
 dd 002117022h,03303302Ch,050378440h,0302C0212h,084403303h,002145037h,03303302Ch,050378440h
 dd 0302C0216h,084403303h,002175037h,03303302Ch,050378440h,0302C0219h,084403303h,0021B5037h
 dd 03303302Ch,050378440h,0000F861Ch,0302C021Dh,004403303h,027865038h,02C021E70h,040330330h
 dd 01F503884h,003302C02h,038844033h,02C022050h,040330330h,005503704h,00F866023h,02C022200h
 dd 040330330h,024503784h,003302C02h,037844033h,02C022550h,040330330h,027503784h,003302C02h
 dd 037844033h,02C022950h,040330330h,02B503784h,003302C02h,037844033h,02C022C50h,040330330h
 dd 02E503784h,003302C02h,037844033h,02C023050h,040330330h,031503784h,003302C02h,037844033h
 dd 02C023250h,040330330h,034503784h,003302C02h,037844033h,02C023650h,040330330h,037503784h
 dd 003302C02h,037844033h,00F053850h,070228600h,0302A0239h,084403303h,0023A5037h,03303302Ah
 dd 050378440h,0302A023Ch,084403303h,002BE5037h,03303302Ah,050378440h,0302C0200h,004403303h
 dd 01C055037h,0000F0660h,002902C88h,003302C02h,037044033h,0902C8850h,0302C0204h,004403303h
 dd 00C075037h,0902C8880h,0302C0205h,084403303h,088065037h,00207902Ch,03303302Ch,050378440h
 dd 0902C8808h,0302C0209h,084403303h,0880A5037h,0020B902Ch,03303302Ch,050378440h,0302C020Ch
 dd 004403303h,00C075037h,0902C8880h,0302C020Eh,004403303h,02C885037h,02C021090h,040330330h
 dd 005503704h,02206000Fh,0902C8870h,0302C0211h,084403303h,002125037h,03303302Ch,050370440h
 dd 014902C88h,003302C02h,037044033h,0800C0750h,016902C88h,003302C02h,037044033h,0902C8850h
 dd 0302C0217h,084403303h,088185037h,00219902Ch,03303302Ch,050378440h,0902C881Ah,0302C021Bh
 dd 084403303h,0061C5037h,00C07000Fh,0902C8880h,0302C021Dh,004403303h,027865038h,02C021E70h
 dd 040330330h,088503804h,0021F9038h,03303302Ch,050388440h,0302C0220h,004403303h,023055037h
 dd 0000F0660h,022902C88h,003302C02h,037044033h,0902C8850h,0302C0224h,004403303h,00C075037h
 dd 0902C8880h,0302C0225h,084403303h,088265037h,00227902Ch,03303302Ch,050378440h,0902C8828h
 dd 0302C0229h,084403303h,0882A5037h,0022B902Ch,03303302Ch,050378440h,0302C022Ch,004403303h
 dd 00C075037h,0902C8880h,0302C022Eh,004403303h,02C885037h,02C023090h,040330330h,088503704h
 dd 00231902Ch,03303302Ch,050378440h,0302C0232h,004403303h,02C885037h,02C023490h,040330330h
 dd 007503704h,02C88800Ch,02C023690h,040330330h,088503704h,00237902Ch,03303302Ch,050378440h
 dd 0000F0538h,088702206h,002399033h,03303302Ah,050378440h,0302A023Ah,004403303h,033885037h
 dd 033883B90h,02A023C90h,040330330h,087503704h,0073D800Ch,03388800Ch,02A023E90h,040330330h
 dd 007503704h,03388800Ch,00C87BF90h,02C000080h,0302C0210h,004403303h,01C055037h,0000F0660h
 dd 088807907h,00101902Ch,079872033h,037000280h,0302C0210h,004403303h,079075037h,0903C8880h
 dd 0203C0103h,088807907h,00004902Ch,02C02102Ch,040330330h,087503704h,00105800Ch,02C022033h
 dd 040330330h,088503704h,00006902Ch,079871037h,03C010780h,0302C0220h,004403303h,079075037h
 dd 0902C8880h,0102C0008h,088807907h,00109902Ch,02C022033h,040330330h,087503704h,0000A8079h
 dd 079071037h,0903C8880h,0203C010Bh,003302C02h,037044033h,080790750h,00C902C88h,002102C00h
 dd 03303302Ch,050370440h,00D800C87h,088203301h,0000E902Ch,02C021037h,040330330h,007503704h
 dd 02C888079h,03C010F90h,080798720h,0102C0010h,003302C02h,037044033h,0000F0550h,007702206h
 dd 02C888079h,033011190h,0302C0220h,004403303h,079075037h,0902C8880h,010370012h,003302C02h
 dd 037044033h,080798750h,0203C0113h,088807907h,00014903Ch,02C02102Ch,040330330h,007503704h
 dd 02C88800Ch,033811590h,037001620h,0302C0210h,004403303h,079075037h,0902C8880h,0203C0117h
 dd 003302C02h,037044033h,080790750h,018902C88h,087102C00h,001198079h,02C022033h,040330330h
 dd 007503704h,02C888079h,037001A90h,080790710h,01B902C88h,002203C01h,03303302Ch,050370440h
 dd 01C807987h,006103800h,00C07000Fh,090388880h,02033011Dh,003302C02h,038044033h,070270650h
 dd 01E903888h,002102C00h,03303302Ch,050380440h,088807907h,0011F9038h,02C022028h,040330330h
 dd 007503804h,038888079h,02C002090h,0302C0210h,004403303h,023055037h,0000F0660h,088807907h
 dd 00121902Ch,079872033h,037002280h,0302C0210h,004403303h,079075037h,0903C8880h,0203C0123h
 dd 088807907h,00024902Ch,02C02102Ch,040330330h,087503704h,00125800Ch,02C022033h,040330330h
 dd 088503704h,00026902Ch,079871037h,03C012780h,0302C0220h,004403303h,02C885037h,02C002890h
 dd 080790710h,029902C88h,002203301h,03303302Ch,050370440h,02A807987h,007103700h,02C888079h
 dd 03C012B90h,0302C0220h,004403303h,079075037h,0902C8880h,0102C002Ch,003302C02h,037044033h
 dd 0800C8750h,02033012Dh,02E902C88h,002103700h,03303302Ch,050370440h,02F807987h,007203C01h
 dd 02C888079h,02C003090h,0302C0210h,004403303h,079075037h,0903C8880h,020330131h,003302C02h
 dd 037044033h,080790750h,032902C88h,002103700h,03303302Ch,050370440h,088807907h,00133902Ch
 dd 07987203Ch,02C003480h,0302C0210h,004403303h,00C075037h,0902C8880h,020338135h,010370036h
 dd 003302C02h,037044033h,080790750h,037903C88h,002203C01h,03303302Ch,050370440h,038902C88h
 dd 005103300h,02206000Fh,080790770h,039903388h,002202C01h,03303302Ah,050370440h,03A807987h
 dd 002103A00h,03303302Ah,050370440h,088807907h,0013B9033h,079872043h,03C003C80h,0302A0210h
 dd 004403303h,00C075037h,090338880h,0203A013Dh,088800C07h,0003E9033h,02A021033h,040330330h
 dd 007503704h,03388800Ch,02C01BF90h,0800C0720h,000903388h,002103C00h,03303302Ch,050370440h
 dd 006601C05h,07907000Fh,0902C8880h,020430101h,002807987h,002104200h,03303302Ch,050370440h
 dd 088807907h,08703902Ch,001048079h,02C02203Ch,040330330h,007503704h,03C88800Ch,02C020590h
 dd 040330330h,088503704h,08706902Ch,002078079h,03303302Ch,050370440h,088807907h,00008902Ch
 dd 079871047h,043010980h,0302C0220h,004403303h,079075037h,0902C8880h,0103C000Ah,00B807987h
 dd 003302C02h,037044033h,080790750h,00C902C88h,002204701h,03303302Ch,050370440h,088800C07h
 dd 0880D903Ch,0020E902Ch,03303302Ch,050370440h,00F807987h,088807907h,00010902Ch,02C02103Ch
 dd 040330330h,005503804h,02306000Fh,080790770h,011903888h,087204201h,000128079h,02C021043h
 dd 040330330h,007503804h,038888079h,045011390h,080798720h,010430014h,003302C02h,038044033h
 dd 0800C0750h,015903888h,002204501h,03303302Ch,050380440h,016903888h,087104700h,001178079h
 dd 02C022048h,040330330h,007503804h,038888079h,047001890h,060220510h,087000F06h,001198079h
 dd 02C022048h,040330330h,007503804h,038888079h,04A001A90h,080798710h,0204C011Bh,003302C02h
 dd 038044033h,080790750h,01C903888h,002104C00h,03303302Ch,050380440h,088800C07h,0811D9038h
 dd 0001E204Ah,02C021048h,040330330h,007503804h,038888079h,047011F90h,080798720h,0103C0020h
 dd 003303302h,03A044037h,0000F0550h,007702706h,033888079h,042012190h,080798720h,010430022h
 dd 003303302h,03A044037h,080790750h,023903388h,024807987h,002203C01h,037033033h,0503A0440h
 dd 088800C07h,002259043h,037033033h,0503A0440h,026903388h,027807987h,003303302h,03A044037h
 dd 090338850h,0103C0028h,029807987h,002204701h,037033033h,0503A0440h,088807907h,0002A9033h
 dd 079871045h,033022B80h,040370330h,007503A04h,033888079h,047012C90h,030330220h,004403703h
 dd 00C07503Ah,090438880h,09033882Dh,03033022Eh,004403703h,07987503Ah,079872F80h,03C003080h
 dd 030350210h,004403803h,07907503Ch,090358880h,020450131h,032807987h,002104800h,038033035h
 dd 0503C0440h,088807907h,001339035h,07987204Ch,03C003480h,030350210h,004403803h,00C07503Ch
 dd 090458880h,020450135h,003303502h,03C044038h,090358850h,010480036h,037807987h,002204C01h
 dd 03A033037h,050420440h,038903788h,005104200h,00F066032h,080790700h,039903788h,002204701h
 dd 03A033037h,050420440h,03A807987h,007104A00h,037888079h,052013B90h,030370220h,004403A03h
 dd 079875042h,04A003C80h,030370210h,004403A03h,00C075042h,090478880h,02047013Dh,003303702h
 dd 04204403Ah,0800C0750h,03E903788h,002104200h,03A033037h,050420440h,007000F05h,03788800Ch
 dd 03701BF90h,030370220h,004403A03h,00C075042h,090378880h,0106C0000h,002000F01h,03303302Ch
 dd 050370440h,006601C05h,00F07000Fh,0000F8800h,0106C0008h,003302C02h,037844033h,02C021050h
 dd 040330330h,086503704h,080127027h,08517106Ch,00018000Fh,02C02106Ch,040330330h,085503704h
 dd 0861F6023h,00220000Fh,03303302Ch,050370440h,022702C86h,025106C80h,028000F85h,002106C00h
 dd 03303302Ch,050370440h,02E602385h,030000F86h,003302C02h,037044033h,070278650h,0106C0034h
 dd 003302C02h,037844033h,01C003850h,0302C0210h,004403303h,02C075037h,0902C8880h,020228139h
 dd 01023003Ah,003302C02h,037844033h,025013B50h,0802C0720h,03C902C88h,002102300h,03303302Ch
 dd 050370440h,006000F05h,02C07000Fh,0902C8880h,02025813Dh,01027003Eh,003302C02h,037044033h
 dd 0802C0750h,0BF902C88h,002202C01h,03303302Ch,050378440h,0103C0000h,006601C05h,07907000Fh
 dd 0000F8880h,020420101h,002807987h,087104300h,001038079h,079872048h,047000480h,0800C8710h
 dd 0204C0106h,003303C02h,047044043h,080790750h,007902C88h,002104C00h,04303303Ch,050470440h
 dd 088807907h,08708902Ch,001098079h,03C02204Ch,040430330h,007504704h,02C888079h,04C000A90h
 dd 0303C0210h,004404303h,079075047h,0902C8880h,08079870Bh,0204A010Ch,003303A02h,045044042h
 dd 0800C0750h,00E902A88h,002104C00h,04303303Ch,050470440h,088807907h,0870F902Ch,000108079h
 dd 00F05103Ch,070230600h,088807907h,00111000Fh,079872042h,043001280h,080798710h,020480113h
 dd 014807987h,087104700h,00016800Ch,03C02104Ch,040430330h,007504704h,02C888079h,04C011790h
 dd 0303C0220h,004404303h,079075047h,0902C8880h,080798718h,0104C0019h,003303C02h,047044043h
 dd 080790750h,01A902C88h,002204C01h,04303303Ch,050470440h,088807907h,0871B902Ch,0001C8079h
 dd 03C021045h,040450330h,007504904h,03588800Ch,04C011E90h,0303C0220h,004404303h,079075047h
 dd 0902C8880h,08079071Fh,020000F88h,005103C00h,00F066027h,080798700h,020420121h,022807987h
 dd 087104300h,001238079h,079872048h,047002480h,0800C8710h,0104C0026h,003303C02h,047044043h
 dd 080790750h,027902C88h,002204C01h,04303303Ch,050470440h,028902C88h,029807987h,002104C00h
 dd 04303303Ch,050470440h,088807907h,0012A902Ch,03C02204Ch,040430330h,007504704h,02C888079h
 dd 079872B90h,04A002C80h,0303A0210h,004404203h,00C075045h,0902A8880h,0204C012Eh,003303C02h
 dd 047044043h,080790750h,02F902C88h,088807907h,00030000Fh,00F05103Ch,0702C0600h,031807987h
 dd 087204201h,000328079h,079871043h,048013380h,080798720h,010470034h,036800C87h,002204801h
 dd 04303303Ch,050480440h,088807907h,000379038h,03B021047h,040420330h,088504704h,001389037h
 dd 03C022048h,040430330h,007504804h,038888079h,047003990h,0303B0210h,004404203h,079075047h
 dd 090378880h,02048013Ah,003303C02h,048044043h,080790750h,03B903888h,002104700h,04203303Bh
 dd 050470440h,088807907h,0013C9037h,038022045h,0403C0330h,007504504h,03588800Ch,043003D90h
 dd 030370210h,004403A03h,00C075043h,090338880h,0203A013Eh,003303502h,04204403Ah,0800C0750h
 dd 0BF902A88h,000800C87h,001101C00h,03C022027h,040430330h,005504704h,02706601Ch,0806C0770h
 dd 001902C88h,001101C00h,03C022027h,040430330h,007504704h,02C88806Ch,01C000290h,020270110h
 dd 003303C02h,047044043h,0806C0750h,003902C88h,001101C00h,03C022027h,040430330h,007504704h
 dd 02C88806Ch,01C000490h,020270110h,003303C02h,047044043h,0800C0750h,085902C88h,001000F00h
 dd 00F02000Fh,0000F0300h,005000F04h,00F06000Fh,0000F8800h
ends


Stack16		segment para public use16 stack
		dw	100h dup (?)
		ends




;ret
END START


