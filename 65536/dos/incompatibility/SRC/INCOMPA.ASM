comment @

Ooooops, INCOMPATIBILITY source...
This intro won the Cache'95 party...

Only one thing made us to release it:
A VERY LAMER GUY (TSC/PhantomDezign) ripped it,
and wanted to release... Now it's here...

Hope U will find something useful in this...

Sorry, we have no time for the comments,
and the player's source isn't included,
'coz its developing is in the test phase...

Call our distroz as listed in byteam.nfo !!!

                    Last day comment by RoByMuS

[  Comment at 04-25-95, released at 04-26-95  ]

PS: Do Not Pack Or Code The Exe, The Player
    Has A Cyclic Redundancy Check Routine !

@


 
;------------------------------------------------------------------------;
;-( incompatibility intro - (c) 1994-95 byteam - presented at cache'95 )-;
;------------------------------------------------------------------------;

extrn initsoundcard:far
extrn setmodule:far
extrn startplay:far
extrn stopplay:far
extrn gettimerconst:far

.386
;------------------------------ GLOBAL CONSTANS -------------------------------

;debug = 1

kw_size equ 28
ymax_kw equ 100

xsize_z=320
ysize_z=40 

xmax_pl equ 160
ymax_Pl equ 100

maga_S = 33
height_S=33
speed_s=1
sorok_S=5

size1_pn equ 20

xmax_go equ 128
ymax_go equ 128

randomizeconst = 12345678h

starnum_vl=400 ;210
starmax_vl=200
starmin_vl=50
sugar_vl=85
kocakside_vl=115
hanyfazis_vl=256;128 ;64
hanyfazislog_vl=8;7 ;6      ; hanyfazis log 2
mainradius_vl=60
subradius_vl=25

xmax_v equ 240
ymax_v equ 200
xmax_v3 equ 320
ymax_v3 equ 200

szog_t=12      ; equ hanyszog
fazis_t=32;20;16
dist_t=32
tenyezo_t=5
tag_T=9-20

xmax_T=92
ymax_t=92

pside__m equ 100
_size_M=40
xmax_M equ 160
ymax_M equ 200
points_num_M equ 8
faces_num_M equ 6
hexa_m    equ 100000h   ; 2^h#shr
h_shr_M   equ 20

xmax_gm equ 176
ymax_gm equ 192
points_num_gm equ 8
faces_num_gm equ 6
_size_gm=44;40

side_jc=45
xmax_jc=320 ; 180
ymax_jc=200 ; 180

side_pc=45
xmax_pc=320;180
ymax_pc=200;180

;----------------------------- FIRST DATA SEGMENT -----------------------------
data1 segment para use16
assume ds:data1

calc1 db 'calculating & decrunching, please wait..$'
no386 db 'sorry, 386 required for this intro',13,10,'$'
novga db 'sorry, VGA card & color monitor required for this intro',13,10,'$'
nomem db 'not enough memory [min. 570k required]',13,10,'$'

;--------------------------- PART DATAS: endscroll ----------------------------

scrolltext_S:
include text2.inc                    ; optimized font
scrlpos_s dw offset scrolltext_S

hardpos_S dw 0
ideraksz_S dw 80*400

scrolled_S db maga_s-1

planepos_s dw offset planes_s

font_s:
include lfont.inc

pal_S:
include lfontpal.inc

planes_s dw maga_s*4*80/2 dup (?)

;----------------------- PART DATAS: gouraud objects --------------------------

black_Ct db 768 dup (0)
grey_ct db 768 dup (17)

include objects.inc

points_num_go dw ?
faces_num_go dw ?
xyz_go dw 3*max_points_num_go dup (0)
xyz2_go dw 4*max_points_num_go dup (0)
faces_go dw 4*max_faces_num_go dup (0)
sortedfaces_go dw 2*max_faces_num_go dup (0)
temp4points_go dw 0,0,0,0,0,0,0,0
temp4colors_go dw 8 dup (?) ;20,30,40,20

cux_go dw 0
cuy_go dw 0
cux2_go dd 0
cuy2_go dd 0
addx_go dd 0
addy_go dd 0
xkirak dw ?
ykirak dw ?

fromx_go dw 0
fromy_go dw 0
tox_go dw 0
toy_go dw 0
latszik_go dw 0
xradd_go dw 0
yradd_go dw 0
zradd_go dw 0
xr_go dw 354
yr_go dw 652
zr_go dw 213

side_ctadd dw 1
side_ct dw 55
xcount_ct1 dw ?
xcount_ct2 dw ?
ycount_ct1 dw ?
ycount_ct2 dw ?
eltolasx_ct dw 160
eltolasy_ct dw 100
eltolasx_ct2 dw ?
eltolasy_ct2 dw ?

perszeltoladd_go dw 0

move_ctpos dw offset move_ct
move_ct:
;include move_ct.inc
dw 2*256 dup (?)

;------------------------------ PART DATAS: vecc ------------------------------

size2_v dw 20
addpoints_v:
dw -1,-1,-1
dw +1,-1,-1
dw -1,+1,-1
dw +1,+1,-1
dw -1,-1,+1
dw +1,-1,+1
dw -1,+1,+1
dw +1,+1,+1

addpoints2_v dw 8*3 dup (?)

size_v equ 20
size1_v=size_v*2

points_num_v equ 4*8
faces_num_v equ 8*4

points_v:
dw +size_v,+size_v,+size_v
dw -size_v,+size_v,+size_v
dw +size_v,-size_v,+size_v
dw +size_v,+size_v,-size_v

faces4_v:
;dw 1,2,0,0
;dw 2,3,0,0
;dw 3,1,0,0
dw 1,2,0,1
dw 2,3,0,2
dw 3,1,0,3
dw 1,2,3,1

faces_v dw 4*4*8 dup (0)
xyz2_v dw points_Num_v*4 dup (0)
xyz3_v dw points_Num_v*4 dup (0)
sortedfaces_v dw faces_num_v*2 dup (0)

temp4points_v dw 0,0,0,0,0,0,0,0
temp4colors_v db 4 dup (0,0,0,0)

mainxr_v dw 934
mainyr_v dw 345
mainzr_v dw 123

xr0add_v label byte
db -2,+2,-2
db -2,+2,-2
db -2,+2,-2
db -2,+2,-2
db +2,-2,-2
db -2,-2,-2
db +2,-2,-2
db +2,-2,-2

xr0_v label word
dw +256,-256,+256
dw +256,-256,+512
dw +512,+000,+512
dw +512,+000,+768
dw +512,+256,+256
dw +000,+256,+512
dw +768,+768,+768
dw +768,+768,+000

xyz_okta_v2 label word
dw -size1_v,0,0
dw +size1_v,0,0
dw 0,-size1_v,0
dw 0,+size1_v,0
dw 0,0,-size1_v
dw 0,0,+size1_v

faces_okta_v2 label word
dw 0,2,4,0
dw 0,4,3,0
dw 0,3,5,0
dw 0,5,2,0
dw 1,2,4,1
dw 1,4,3,1
dw 1,3,5,1
dw 1,5,2,1

palette_v3 db 768 dup (?)          ; plg_genpal legener lja
temppal_v3 db 768 dup (3fh)
temppal2_v3 db 768 dup (?)
palofs_v3 dw 0

dipos_v dw ?
yeltol2_v3 dw 0

data1 ends
;------------------------------ 3RD DATA SEGMENT ------------------------------
data3 segment para use16
assume ds:data3

temppal_white_data3 db 768 dup (3fh)
temppal_black_data3 db 768 dup (0)

;----------------------------- PART DATAS: tunnel -----------------------------

flag_sh db 0
flag_t db 0
flag2_t db 0

movetable_t dd 256 dup (?)        ; generated in realtime

xr_T dw 0
yr_T dw 0
zr_T dw 0

addcolors_T db 0,1,2,3,2,1,0,-1,-2,-3,-2,-1

temp4points_t dw 0,0,0,0,0,0,0,0
elsofazis_T dw +(dist_t*tenyezo_t)-1                ; variable!
pointsnum_t equ szog_t*fazis_t
points_t dw szog_t*fazis_t*4 dup (0)
color_t db ?
movepos dw offset movetable_t

hanyszog_T equ 12

sokszog_t label word
dw 186,0,0
dw 161,55,0
dw 93,95,0
dw 0,110,0
dw -93,95,0
dw -161,55,0
dw -186,0,0
dw -161,-55,0
dw -93,-95,0
dw 0,-110,0
dw 93,-95,0
dw 161,-55,0

;sokszog2_t label word
;dw 242,0,0
;dw 209,71,0
;dw 121,124,0
;dw 0,143,0
;dw -121,124,0
;dw -209,71,0
;dw -242,0,0
;dw -209,-71,0
;dw -121,-124,0
;dw 0,-143,0
;dw 121,-124,0
;dw 209,-71,0

pal_SH:
include ship_pal.inc

temp1_Sh dw ?
xyz_sh dw 3*points_num_sh dup (0)
xyz2_Sh dw 4*points_num_sh dup (?)

xr_Sh dw -256;-54
yr_Sh dw 40;61
zr_SH dw -75;-45

sortedfaces_sh dd faces_num_SH dup (?)
;Z coord,Number of face...

pallen_sh dw 0
coords_sh dw 2*4 dup (?)
colors_Sh dw 0,0,0,0,0,0,0,0

perspos2_sh dw 0
perspos_sh dw offset zpersmove_sh
zpersmove_sh dw 512 dup (?)           ; generated in realtime

rotation_sh dd 256 dup (?)    ; generated in realtime
rotpos_sh dw offset rotation_sh

include ship6.inc

;-------------------------- PART DATAS: mandelkocak ---------------------------

mandelpalette_M:
db 0,0,0
;
t=1
rept 31
db t,0,0
t=t+2
endm
db 0,0,00
;
t=1
rept 31
db t,t,0
t=t+2
endm
db 0,0,00
;
t=1
rept 31
db t,0,t
t=t+2
endm
db 0,0,00
;
t=1
rept 31
db 0,0,t
t=t+2
endm
db 0,0,00
;
t=1
rept 31
db 0,t,0
t=t+2
endm
db 0,0,00
;
t=1
rept 31
db 0,t,t
t=t+2
endm
db 0,0,00
;
; big
;
t=0
rept 63
db t,t,t
t=t+1
endm
db 0,0,0

x1_M dw 0
y1_M dw 0
x2_M dw 0
y2_M dw 0
x3_M dw 0
y3_M dw 0
x4_M dw 0
y4_M dw 0              ; sorted !

bigmandelseg_M dw ?

point_cnt_M db 0

count_m   dw 0
maxiter_M dw 63

side_M    dd +280000h          ; 2.5*hexa
acorner_M dd -200000h          ; 2*hexa
bcorner_M dd -140000h          ; -1.25*hexa

gap_M     dd ?
xcount_M  dd ?
ycount_M  dd ?
zi_M      dd ?
zr_M      dd ?
tmp1_m    dd 0
tmp2_M    dd 0
tmp3_m    dd 0

pside_M dw pside__M
hozzaad_M dw 128

mandel_descriptors_M:
dd +04cccch,-159999h,+026666h
dd +02b666h,-0a0000h,-0b3333h
dd +04cccch,-0c28f5h,+0428f5h
dd +0147aeh,-0bc28fh,+04872bh
dd +040000h,-040000h,-100b85h
dd +006666h,+04fffeh,-00fffeh
;
; big mandelbrot in the background
;
dd +0051ebh,-002400h,-0d4eb8h

pluscolor_M db 1

xyz_M:
dw +_size_m,+_size_m,+_size_m
dw -_size_m,+_size_m,+_size_m
dw +_size_m,-_size_m,+_size_m
dw -_size_m,-_size_m,+_size_m
dw +_size_m,+_size_m,-_size_m
dw -_size_m,+_size_m,-_size_m
dw +_size_m,-_size_m,-_size_m
dw -_size_m,-_size_m,-_size_m

faces_m:
dw 0,1,3,2
dw 4,5,7,6
dw 0,1,5,4
dw 2,3,7,6
dw 0,2,6,4
dw 1,3,7,5

faces_xyz_sum_M:
t=0
rept faces_num_m
dw 0,0,0,t
t=t+1
endm

xyz2_m:
dw 4*points_num_M dup (?)

xr_M dw 0
yr_M dw 0
zra_M dw 0

xsum_M dw ?
ysum_M dw ?
zsum_M dw ?

texturemap_M:
dw 0,0
dw 0,pside__M-1
dw pside__M-1,pside__M-1
dw pside__M-1,0

maxcnt_M dw ?
tempcounter_M dw ?
xy4_M dw 4*2*faces_num_m dup (?)

bmpos_m dw 0,-32*2,-64*2,-96*2,-128*2,-160*2,-192*2,-224*2

;myyeltol_m dw 200

;---------------------------- PART DATAS: goumorph ----------------------------

yeltoladd_gm dw -1

xr_Gm dw 123+1-350
yr_Gm dw 456-350*2
zr_gm dw 789+2-350*2

sortedfaces_Gm dd faces_num_Gm dup (?)
;Z coord,Number of face...

coords_Gm dw 2*4 dup (?)
colors_GM db 4*4 dup (?)

tempcoord_gm dw ?,?,?

sinpos_gm:
db 0,14,5,57,17,23,8,91
db 52,26,4,42,96,125,73,33
db 37,21,59,34,52,83,111,222

pal_gm:
include pal_gm.inc
sinus_GM:
include sinus_gm.inc

xyz2_Gm:
dw 4*points_num_Gm dup (?)
xyz2_4sort_gm:
dw 4*points_num_gm dup (?)

xyz_gm:
dw +_size_gm,+_size_gm,+_size_gm
dw -_size_gm,+_size_gm,+_size_gm
dw +_size_gm,-_size_gm,+_size_gm
dw -_size_gm,-_size_gm,+_size_gm
dw +_size_gm,+_size_gm,-_size_gm
dw -_size_gm,+_size_gm,-_size_gm
dw +_size_gm,-_size_gm,-_size_gm
dw -_size_gm,-_size_gm,-_size_gm
;
faces_gm:
dw 0,1,3,2,1
dw 4,5,7,6,2
dw 0,1,5,4,3
dw 2,3,7,6,4
dw 0,2,6,4,5
dw 1,3,7,5,6

;--------------------------- PART DATAS: julimorph ----------------------------

xadd_juli dw 18-190
yadd_juli dw 33+190

colors_JC:
db 0,0,0
t=17
rept 14
db t,t/3,t/3
t=t+3
endm
db 63,63,63
;
db 0,0,0
t=17
rept 14
db t,t,t/3
t=t+3
endm
db 63,63,63
;
db 0,0,0
t=17
rept 14
db t/3,t,t/3
t=t+3
endm
db 63,63,63
;
db 0,0,0
t=17
rept 14
db t/3,t,t
t=t+3
endm
db 63,63,63
;
db 0,0,0
t=17
rept 14
db t/3,t/3,t
t=t+3
endm
db 63,63,63
;
db 0,0,0
t=17
rept 14
db t,t/3,t
t=t+3
endm
db 63,63,63

points_Jc:
dw -side_jc,-side_jc,-side_jc
dw +side_jc,-side_jc,-side_jc
dw -side_jc,+side_jc,-side_jc
dw +side_jc,+side_jc,-side_jc
dw -side_jc,-side_jc,+side_jc
dw +side_jc,-side_jc,+side_jc
dw -side_jc,+side_jc,+side_jc
dw +side_jc,+side_jc,+side_jc

faces_Jc:
dw 0,1,3,2
dw 4,5,7,6
dw 0,1,5,4
dw 2,3,7,6
dw 0,2,6,4
dw 1,3,7,5

xr_JC dw 123
yr_Jc dw 234
zr_Jc dw 345

texturemap_Jc dw 0,0,0,63,63,63,63,0
temp4points_JC dw 0,0,0,0,0,0,0,0
sortedfaces_Jc dw 2*6 dup (?)
xyz2_Jc dw 4*8 dup (?)

mem_JC db 64*32 dup (?);100*50 dup (?)

data3 ends
;---------------------------- SECOND DATA SEGMENT -----------------------------
data2 segment para use16
assume ds:data2

logopcx label byte
include logopcx.inc
logopal label byte
include logopal.inc
logo db 40*320 dup (0)
db 40h dup (0)               ; for torzoom (?)

;--------------------- PART DATAS: plasmacube & torus -------------------------

include obj_pc.inc

;points_pc:
;dw -side_pc,-side_pc,-side_pc
;dw +side_pc,-side_pc,-side_pc
;dw -side_pc,+side_pc,-side_pc
;dw +side_pc,+side_pc,-side_pc
;dw -side_pc,-side_pc,+side_pc
;dw +side_pc,-side_pc,+side_pc
;dw -side_pc,+side_pc,+side_pc
;dw +side_pc,+side_pc,+side_pc

;faces_pc:
;dw 0,1,3,2
;dw 4,5,7,6
;dw 0,1,5,4
;dw 2,3,7,6
;dw 0,2,6,4
;dw 1,3,7,5

xr_pc dw 123
yr_pc dw 234
zr_pc dw 345

texturemap_pc dw 0,0,0,99,99,99,99,0
temp4points_pc dw 0,0,0,0,0,0,0,0
sortedfaces_pc dw 2*faces_num_pc dup (?)
xyz2_pc dw 4*points_num_pc dup (?)

movepos_pc dw offset move_pc
move_pc dw 256 dup (?)

flag_pc db 0

;-------------------------- PART DATAS: kocakwriter ---------------------------
points_kw label word
dw -kw_size,-kw_size,-kw_size
dw +kw_size,-kw_size,-kw_size
dw -kw_size,+kw_size,-kw_size
dw +kw_size,+kw_size,-kw_size
dw -kw_size,-kw_size,+kw_size
dw +kw_size,-kw_size,+kw_size
dw -kw_size,+kw_size,+kw_size
dw +kw_size,+kw_size,+kw_size

faces_kw label word
dw 0,1,3,2
dw 4,5,7,6
dw 0,1,5,4
dw 2,3,7,6
dw 0,2,6,4
dw 1,3,7,5

xyz2_kw dw 4*6*3 dup (0)
sortedfaces_kw dw 2*6 dup (0)
temp4points_kw dw 0,0,0,0,0,0,0,0
temp4colors_kw dw 20+192,0,30+192,0,40+192,0,50+192,0

xr_kw dw 123
yr_kw dw 456
zr_kw dw 789

;---------------------------- PART DATAS: torzoom -----------------------------

pointx0_z dd 0
pointy0_Z dd 0
pointx1_z dd 319*10000h
pointy1_Z dd 0
pointx2_z dd 0
pointy2_Z dd 199*10000h
pointx3_z dd 319*10000h
pointy3_z dd 199*10000h

xstep1_z dd ?
ystep1_z dd ?
xstep2_z dd ?
ystep2_z dd ?

zoomrot_z dw ?
zoomfac_z dd ?

multizoom_Z db 0

spos1_1_z dw 00
spos1_2_z dw 00
spos2_1_z dw 00
spos2_2_z dw 00
spos3_1_z dw 00
spos3_2_z dw 00
spos4_1_z dw 00
spos4_2_z dw 00

xmodulo_zom_z dw 2*xsize_z dup (?)
xmodstart_zom_z dw 3*xsize_z dup (?)

ymodulo_zom_z dw 18*ysize_z dup (?)
ymodstart_zom_z dw 19*ysize_z dup (?)

;logo label byte
;db xsize_z*ysize_z dup (?)
;db 40h dup (?)

;pcx label byte
;include pcx.inc

;pcxpal label byte
;include pcxpal.inc

zoomsinz_z dd ?
zoomcosz_z dd ?

;------------------------ PART DATAS: simple plasma ---------------------------

xmax2_pl dw 160
ymax2_pl dw 100
bufferpos_pl dw offset buffer_pl
bufferseg_pl dw data2
lineadd_pl dw 0

temp_pl    db 0
tempval_PL db xmax_pl dup (?)
akarmi_PL  db 0
sin1pos_PL dw 03
sin2pos_PL dw 52
sin3pos_Pl dw 21
sin4pos_Pl dw 97
sin5pos_Pl dw 111
sin6pos_Pl dw 38
include sinus_Pl.inc

pal_PL:
include pal3x_PL.inc
tempcolor_pl db 0,0,0
temppal1_pl db 768 dup (0)

buffer_pl db xmax_pl*ymax_PL dup (?)

data2 ends

;-------------------------- VIEWLOG DATA SEGMENT ------------------------------
vldata segment use16 para
whitepal_Vl db 48 dup (3fh)
blackpal_vl db 48 dup (00h)

pal_vl label byte
db 14,08,14   ;Hatter
db 63,38,06   ;Cs - 7 (One)
db 56,34,08   ;Cs - 6
db 50,30,09   ;Cs - 5
db 43,26,11   ;Cs - 4
db 37,22,12   ;Cs - 3
db 30,18,14   ;Cs - 2
db 24,14,15   ;Cs - 1
db 60,38,60   ;Logo - 8
db 60,38,60   ;Logo - 9
db 60,38,60   ;Logo - 10
db 60,38,60   ;Logo - 11
db 60,38,60   ;Logo - 12
db 60,38,60   ;Logo - 13
db 60,38,60   ;Logo - 14
db 60,38,60   ;Logo - 15
pal_vl2 label byte
db 14,08,14   ;Hatter
db 63,38,06   ;Cs - 7 (One)
db 56,34,08   ;Cs - 6
db 50,30,09   ;Cs - 5
db 43,26,11   ;Cs - 4
db 37,22,12   ;Cs - 3
db 30,18,14   ;Cs - 2
db 24,14,15   ;Cs - 1
db 14,08,14   ;Hatter
db 63,38,06   ;Cs - 7 (One)
db 56,34,08   ;Cs - 6
db 50,30,09   ;Cs - 5
db 43,26,11   ;Cs - 4
db 37,22,12   ;Cs - 3
db 30,18,14   ;Cs - 2
db 24,14,15   ;Cs - 1

logo_vl label byte
include VL_logo.inc

externalpalette_vl label byte
db 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,0

calcstars_vl dw starnum_vl*3 dup (?)
delstars_vl dw starnum_vl*3 dup (?)

transform_vl dd starnum_vl*3 dup (?)
transform2_vl dd starnum_vl*3 dup (?)

gomb_vl dw starnum_vl*3 dup (?)
stars_vl dw starnum_vl*3 dup (?)
kocka_vl dw starnum_vl*3 dup (?)
torus_vl dw starnum_vl*3 dup (?)

xr_vl dw ?
yr_vl dw ?
zr_vl dw ?

assume ds:vldata
calcaddr_vl dw offset calcstars_vl
deladdr_vl  dw offset delstars_vl
assume ds:data1

visual_vl dw 0a000h
notvisual_vl dw 0a800h

txr_vl dw ?
tyr_vl dw ?
tzr_vl dw ?

tx1_vl dw 1
ty1_vl dw 0
tz1_vl dw 0
tx2_vl dw ?
ty2_vl dw ?
tz2_vl dw ?           ; for gomb

xadd_vl dw 0
yadd_vl dw 0          ; a sikban valo eltolashoz

sinpos_vl dw offset sintable_vl
sintable_vl label word
include sinvl.inc

vldata ends

;------------------------------- CODE SEGMENT ---------------------------------
.386
code segment use16
assume cs:code,ds:data1,es:data1,ss:verem
jumps

;
; include parts:
;  viewlog (csillagmania)  - nice high resolution
;  kocakwriter             - sz‚p effect & szep logo by Plan-B (handycap)
;  torzito zoomer          - cooooool!
;  simple plasma 160x100   - simple..
;  gouraud vectors         - elvi error in sort!
;  cd2 test -> vecc        - sort problem..
;  goumorph                - szep, de hoggy jojjon be & menjen ki ?? yol!
;  mandelkocak             - effect
;  julimorpher texture     - simple dolog (julimorph a kock n)..
;  plasmagomb              - hat jobb mint a 2nd realban a cube - coooooool!
; *filled alagut + urhajo  - yikes! - yeahh! 
;  endscroll               - cool font by Leon Sky & Blala
;
; a '*'-al jelolt partoknal meg meg kell csinalni az idozitest!
;
; all parts:
;  csillagmania
;  kocka elrepul horiz; kozbe irja ki 'incompatibility'
;  zoomer
;  plasma 160x100
;  szines gouraud vectorok a kepen ropkodnek at
;  megegy szines gouraud [cd2] kozeprol jon, szetesik, megfordul, lesz oktaeder
;  villanas, lesz vecc
;  goumorph
;  juliamorpher texture
;  mandeltexture
; +zoomtexture [fa32 or incompa-logo]
;  plasmatexture [gomb - wow! coooooool! byteam!]
; +1lap+1texture intersection (?) (??) (???)
;  filled alagut, benne szep urhajo           - YEAHH...
; +virtual reality (?) (??) (???)
;  endscroll
;
; length:
;  20k tomorgetett zenevel szamolva a '+'-szal jel”lt partoknak 
;  osszesen 6k hely van? &s3m-player!!!!
;  ‚rtsd: a '+'-szal jel”lt partok nem lesznek megirva...
;

;------------------------------ SYSTEM ROUTINES -------------------------------

random:
push ds
push cs
pop ds
assume ds:code
mov eax,rand1
mov ebx,rand2
mov ecx,rand3
add eax,ebx
sub ecx,ebx
rol ebx,4
xor ebx,eax
ror eax,4
add ecx,eax
xor ecx,eax
add eax,rand1
sub ebx,rand3
add ecx,rand2
xor eax,12345678h
sub ebx,452ebce3h
add ecx,978dec30h
mov rand1,ecx
mov rand2,eax
mov rand3,ebx
mov ax,word ptr rand1
add ax,word ptr rand1+2
add ax,word ptr rand2
add ax,word ptr rand2+2
add ax,word ptr rand3
add ax,word ptr rand3+2
pop ds
retn

randomize:
mov eax,randomizeconst
mov cs:rand1,eax
xor eax,1353acedh
mov cs:rand2,eax
add eax,242edcabh
mov cs:rand3,eax
assume ds:data1
retn

rand1 dd ?
rand2 dd ?
rand3 dd ?

;-( temporary polygon filler )-;

polygon_temp dw 0,0,0,0,0,0

polygon:
push es 
push cs
pop es
mov di,offset polygon_temp
movsd
movsd
movsd
push ax si es ds
push cs
pop ds
mov es,cs:tempseg
mov si,offset polygon_temp
call fastri
pop ds es si
sub si,12
assume es:code
mov eax,ds:[si]
mov dword ptr es:[polygon_temp],eax
mov eax,ds:[si+8]
mov dword ptr es:[polygon_temp+4],eax
mov eax,ds:[si+12]
mov dword ptr es:[polygon_temp+8],eax
assume es:data1
pop ax
push es ds cs
pop ds
mov es,cs:tempseg
mov si,offset polygon_temp
call fastri
pop ds es
pop es
retn

vsync:
push dx
ifdef debug
mov dx,3c8h
xor al,al
out dx,al
inc dx
out dx,al
out dx,al
out dx,al
endif
mov dx,3dah
w1:
in al,dx
test al,8
jnz w1
w2:
in al,dx
test al,8
jz w2
ifdef debug
mov dx,3c8h
xor al,al
out dx,al
inc dx
out dx,al
out dx,al
mov al,20h
out dx,al
endif
pop dx
retn

hsync:
push dx
mov dx,3dah
h1:
in al,dx
test al,1
jnz h1
h2:
in al,dx
test al,1
jz h2
pop dx
retn

timerdown:
mov al,34h
out 43h,al
xor al,al
out 40h,al
out 40h,al
retn

timerup:
;mov al,34h
;out 43h,al
;mov al,9bh ;37h    ; low
;out 40h,al
;mov al,2eh ;5dh    ; high
;out 40h,al
retn

hardwarecheck:
push es
;
push sp
pop ax
push ax
pop sp
cmp ax,sp
je t1_hardwarecheck
mov dx,offset no386
jmp error_hardwarecheck
t1_hardwarecheck:
;
mov ax,1a00h
int 10h
cmp bl,8
je t2_hardwarecheck
mov dx,offset novga
jmp error_hardwarecheck
t2_hardwarecheck:
;
mov ax,cs:pspseg
dec ax
mov es,ax
cmp word ptr es:[3],8e80h      ; 570k - temporary!
jae t3_hardwarecheck
mov dx,offset nomem
jmp error_hardwarecheck
t3_hardwarecheck:
pop es
retn

error_hardwarecheck:
mov ah,9
int 21h
mov ax,4cffh
int 21h

init:
push es
mov es,cs:tempseg
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
pop es
retn

setmytimer:
push es ds 
mov ax,3508h
int 21h
mov cs:old08ofs,bx
mov cs:old08seg,es
push cs
pop ds
mov dx,offset new08
mov ax,2508h
int 21h
pop ds es 
retn

tc db 1

new08:
dec cs:tc
jnz oldint
mov cs:tc,8
cmp cs:call_my_timer,0ffffh
je oldint
jmp call_my_timer
oldint:
db 0eah
old08ofs dw ?
old08seg dw ?

call_my_timer dw 0ffffh
s3mtimer db ?

set_timer_routine:     ; in: dx
;push es ds
;mov ax,3508h
;int 21h
mov cs:call_my_timer,dx
;mov cs:old08ofs,bx
;mov cs:old08seg,es
;push cs
;pop ds
;mov ax,2508h
;int 21h
;pop ds es
retn

reset_timer_routine:
;push ds 
;mov ds,cs:old08seg
;mov dx,cs:old08ofs
;mov ax,2508h
;int 21h
;pop ds
mov cs:call_my_timer,0ffffh
retn

;oldint:
;db 0eah
;old08ofs dw ?
;old08seg dw ?

timercnt1 dw ?
timercnt2 dw ?
timercnt3 dw ?
timercnt4 dw ?

;----------------------------- PLASMA GENERATOR -------------------------------

plasma_generator:
push es ds
mov ax,cs
mov ds,ax
call plg_randomize
mov es,cs:plasmaseg
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
mov byte ptr es:[0],18
mov byte ptr es:[319],63
mov byte ptr es:[63680],193
mov byte ptr es:[63999],136
push 0 0 319 199
call plg_subdivide
pop ds es
retn

plg_f db 128

plg_xa dw ?
plg_ya dw ?
plg_xb dw ?
plg_yb dw ?
plg_x  dw ?
plg_y  dw ?

plg_tmp1 dw ?

plg_adjust:
push ax bx

mov ax,plg_y
mov bx,plg_x
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
cmp byte ptr es:[bx],0
jne t1

mov ax,plg_xb
sub ax,plg_xa
add ax,plg_yb
sub ax,plg_ya      ; nem kell abs.
cmp ax,2
jb t1     
mov plg_tmp1,ax

xor dx,dx
mov ax,plg_ya
mov bx,plg_xa
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
mov dl,byte ptr es:[bx]
mov ax,plg_yb
mov bx,plg_xb
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
add dl,byte ptr es:[bx]
adc dh,0
shr dx,1
push dx

call plg_random       ; ñ0.5 [ñ128]
imul plg_f
imul plg_tmp1
pop bx
add dx,bx
cmp dx,1
jnl t2
mov dx,1
t2:
cmp dx,192
jng t3
mov dx,192
t3:

mov bx,plg_x
mov ax,plg_y
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
mov byte ptr es:[bx],dl
t1:
pop bx ax
retn

plg_x1 equ word ptr [bp+10]
plg_y1 equ word ptr [bp+8]
plg_x2 equ word ptr [bp+6]
plg_y2 equ word ptr [bp+4]

plg_x_ equ word ptr [bp-2]
plg_y_ equ word ptr [bp-4]

plg_subdivide:
push bp
mov bp,sp
sub sp,6
mov ax,plg_x2
sub ax,plg_x1
mov bx,plg_y2
sub bx,plg_y1
cmp ax,2
jae plg_mehetsz
cmp bx,2
jae plg_mehetsz
jmp plg_ve1
plg_mehetsz:

mov bx,plg_x1
add bx,plg_x2
shr bx,1
mov ax,plg_y1
add ax,plg_y2
shr ax,1

mov plg_x_,bx
mov plg_y_,ax

;
mov cx,plg_x1
mov plg_xa,cx
mov cx,plg_y1
mov plg_ya,cx
;
mov plg_x,bx
mov cx,plg_y1
mov plg_y,cx
mov cx,plg_x2
mov plg_xb,cx
mov cx,plg_y1
mov plg_yb,cx

call plg_adjust

mov cx,plg_x2
mov plg_xa,cx
mov cx,plg_y1
mov plg_ya,cx
mov cx,plg_x2
mov plg_x,cx
;
mov plg_y,ax
mov cx,plg_x2
mov plg_xb,cx
mov cx,plg_y2
mov plg_yb,cx

call plg_adjust

mov cx,plg_x1
mov plg_xa,cx
mov cx,plg_y2
mov plg_ya,cx
;
mov plg_x,bx
mov cx,plg_y2
mov plg_y,cx
mov cx,plg_x2
mov plg_xb,cx
mov cx,plg_y2
mov plg_yb,cx

call plg_adjust

mov cx,plg_x1
mov plg_xa,cx
mov cx,plg_y1
mov plg_ya,cx
mov cx,plg_x1
mov plg_x,cx
;
mov plg_y,ax
mov cx,plg_x1
mov plg_xb,cx
mov cx,plg_y2
mov plg_yb,cx

call plg_adjust

;
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
mov di,bx

xor dx,dx
;
mov ax,plg_y1
mov bx,plg_x1
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
mov dl,es:[bx]
;
mov ax,plg_y1
mov bx,plg_x2
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
add dl,es:[bx]
adc dh,0
;
mov ax,plg_y2
mov bx,plg_x2
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
add dl,es:[bx]
adc dh,0
;
mov ax,plg_y2
mov bx,plg_x1
xchg ah,al
add bx,ax
shr ax,2
add bx,ax
add dl,es:[bx]
adc dh,0
;
shr dx,2
mov es:[di],dl

;
push plg_x1 plg_y1 plg_x_ plg_y_
call plg_subdivide
push plg_x_ plg_y1 plg_x2 plg_y_
call plg_subdivide
push plg_x_ plg_y_ plg_x2 plg_y2
call plg_subdivide
push plg_x1 plg_y_ plg_x_ plg_y2
call plg_subdivide
;
plg_ve1:
mov sp,bp
pop bp
retn 8

plg_random:
.386
mov eax,plg_rand1
mov ebx,plg_rand2
mov ecx,plg_rand3
add eax,ebx
sub ecx,ebx
rol ebx,4
xor ebx,eax
ror eax,4
add ecx,eax
xor ecx,eax
add eax,plg_rand1
sub ebx,plg_rand3
add ecx,plg_rand2
xor eax,12345678h
sub ebx,452ebce3h
add ecx,978dec30h
mov plg_rand1,ecx
mov plg_rand2,eax
mov plg_rand3,ebx
mov ax,word ptr plg_rand1
add ax,word ptr plg_rand1+2
add ax,word ptr plg_rand2
add ax,word ptr plg_rand2+2
add ax,word ptr plg_rand3
add ax,word ptr plg_rand3+2
retn

plg_randomize:
mov eax,1979faceh
mov cs:plg_rand1,eax
xor eax,1353acedh
mov cs:plg_rand2,eax
add eax,242edcabh
mov cs:plg_rand3,eax
retn

plg_rand1 dd ?
plg_rand2 dd ?
plg_rand3 dd ?

plg_check192:
cmp ax,192
jb plg_t1_
mov ax,192
plg_t1_:
cmp ax,1
ja t2_
mov ax,1
t2_:
retn

plg_genpal:
xor ax,ax
stosw
stosb
;
mov cx,64
plg_cik1_setpal:
mov al,cl
dec al
stosb
mov al,64
sub al,cl
stosb
xor al,al
stosb
loop plg_cik1_setpal
;
mov cx,64
plg_cik2_setpal:
xor al,al
stosb
mov al,cl
dec al
stosb
mov al,64
sub al,cl
stosb
loop plg_cik2_setpal
;
mov cx,64
plg_cik3_setpal:
mov al,64
sub al,cl
stosb
xor al,al
stosb
mov al,cl
dec al
stosb
loop plg_cik3_setpal
retn

;------------------------------- FADE SYSTEM ----------------------------------

fade_install:
mov cs:fade_colors,cx
push es di si
mov ax,cs
mov es,ax
mov di,offset fade_buf1
mov cx,fade_colors
cik1_fade:
xor ax,ax
lodsb
sal ax,6
stosw
loop cik1_fade
pop si di es
mov bp,offset fade_buf2
mov cx,cs:fade_colors
cik2_fade:
mov al,es:[di]
sub al,ds:[si]
cbw
mov cs:[bp],ax
inc si
inc di
add bp,2
loop cik2_fade
retn

fade_step_timer:
push ds cs
pop ds
mov cx,cs:fade_colors
mov si,offset fade_buf1
mov di,offset fade_buf2
cik6_fade:
lodsw
add ax,ds:[di]
;add ax,ds:[di]         ; 32 lepes
add di,2
mov ds:[si-2],ax
loop cik6_fade
pop ds
retn

fade_step_user:
push ds
mov dx,3c8h
xor ax,ax
out dx,al
inc dx
mov cx,cs:fade_colors
push cs
pop ds
mov si,offset fade_buf1
cik7_fade:
lodsw
sar ax,6
out dx,al
loop cik7_fade
pop ds
retn

fade_step:
push ds
mov dx,3c8h
xor ax,ax
out dx,al
inc dx
mov cx,cs:fade_colors
push cs
pop ds
mov si,offset fade_buf1
mov di,offset fade_buf2
cik3_fade:
lodsw
add ax,ds:[di]
add di,2
mov ds:[si-2],ax
sar ax,6
out dx,al
loop cik3_fade
pop ds
retn

fade_colors dw ?
fade_buf1 dw 768 dup (?)
fade_buf2 dw 768 dup (?)

;--------------------------------- INCLUDES -----------------------------------

include 3d386v2.inc
;include gouraud.inc
;include texture.inc
include fastri.inc     ; temporary - amig nincs n-szog filler
;include adv_fade.inc  ; included - idozitett fade 
include polyfil2.inc   ; wow! coool! fast n-szog filler!

;--------------------------- CODE SEGMENT DATA AREA ---------------------------

pspseg dw ?
tempseg dw 9000h-400h           ; ha nincs virus etc, akkor OK
plasmaseg dw 8000h-400h
mandelseg dw 5800h-400h         ; pont nem jott ki! nem tudom, hogy fogunk elferni?

include gusport.inc
include s3mload.inc

;----------------------------- START PROGRAM CODE -----------------------------
start:
cld
;jmp nogus
;
; preview version - no music
;
;nogus:
mov cs:pspseg,ds
mov ax,data1
mov ds,ax
mov es,ax
call hardwarecheck
call init

call gusport
;
call inits3mplay
;
mov ah,9
mov dx,offset calc1
int 21h
call plasma_generator
mov ax,cs:mandelseg
mov gs,aX
call mandelbrots_m
call depacksintable
call gensintable_ct

call startplay

call setmytimer

call timerup

push ds es
mov ax,3509h
int 21h
mov cs:o9seg,es
mov cs:o9ofs,bx
mov dx,offset new09
mov ax,2509h
push cs
pop ds
int 21h
pop es ds

mov ax,13h
int 10h
mov dx,3c2h
mov al,0e3h
out dx,al
mov al,not 3
;out 21h,al

;comment #
call viewlog       ;-( viewlog alias csillagmania alias milka galaxy )-;
mov ax,13h
int 10h
mov dx,3c2h
mov al,0e3h
out dx,al
call kocakwriter   ;-( kocakwriter [nem letter!] + logo )-;
call torzoom       ;-( torzito zselee zoomer )-;
call plasma        ;-( simple plasma )-;
mov ax,13h
int 10h
mov dx,3c2h
mov al,0e3h
out dx,al
;#
call gouraudobj    ;-( gouraud objects )-;
call vecc          ;-( gouraud2vecc )-;
call goumorph      ;-( zselee gouraud )-;
call mandelkocak   ;-( mandelbrot texture )-;
call julimorph     ;-( julimorph texture )-;
call plasmacube    ;-( plasma gomb - coool! )-;
call tunnel        ;-( tunnel [flight] + spaceship )-;

waitpattstart:
call gettimerconst
test al,63
jnz waitpattstart

call endscroll     ;-( endscroll + nice font by Leon Sky & Blala )-;

kilep:
push ds
;lds dx,cs:o9ofs
mov dx,cs:o9ofs
mov ds,cs:o9seg ;?? :(
mov ax,2509h
int 21h
mov dx,cs:old08ofs
mov ds,cs:old08seg
mov ax,2508h
int 21h
pop ds

call stopplay

xor al,al
out 21h,al
mov ax,03h
int 10h
call timerdown
push cs
pop ds
mov ah,9
mov dx,offset incompaasc
int 21h
mov ax,4c00h
int 21h

include incompa.asc

depacksintable:
assume ds:code,es:code
push ds es cs cs
pop ds es
mov si,offset d_sintable+4*255
mov di,offset d_sintable+4*256
mov cx,256
depacksin1:
movsd
sub si,8
loop depacksin1
mov cx,512
mov si,offset d_sintable
depacksin2:
lodsd
neg eax
stosd
loop depacksin2
pop es ds
retn

o9ofs dw ?
o9seg dw ?

new09:
push ax
mov al,20h
out 20h,al
in al,60h
cmp al,1
je kilep
pop ax
iret

assume ds:data1,es:data1
;------------------------------ PART: kocakwriter -----------------------------
assume ds:data2,es:data2

kocakwriter:
push ds es
mov ax,data2
mov ds,ax
mov es,ax

call vsync
mov si,offset logopal
mov cx,768
mov dx,3c8h
xor al,al
out dx,al
inc dx
cik2_setpal_kw:
lodsb
shr al,2
out dx,al
loop cik2_setpal_kw
;
mov dx,3c8h
mov al,192
out dx,al
inc dx
mov cx,64
xor ax,ax
cik1_setpal_kw:
xchg ah,al
out dx,al
out dx,al
xchg ah,al
out dx,al
inc al
loop cik1_setpal_kw
 
mov si,offset logopcx+128
mov di,offset logo
loadpcx_kw:
mov cx,1
lodsb
cmp al,192
jb t1_loadpcx_kw
and al,63
mov cl,al
lodsb
t1_loadpcx_kw:
rep stosb
cmp di,320*40+offset logo
jb loadpcx_kw                 ; kifejtjuk a pcxet

mov dx,offset timer_kw
call set_timer_routine

mov cs:d_perspective,1
mov dword ptr cs:d_eyedist,220
mov cs:d_xeltol,-40
mov cs:d_yeltol,100
mov dword ptr cs:d_PersZeltol,0

mov cs:timercnt1,0
call dotimer_kw
;mov cx,((160+40)*2+15)/2     ; 100 hz-n repulunk at a kepen 
cik_main_kw:
;push cx
call calculate_kw
call erase_kw
call drawlogo_kw
call drawfaces_kw
call vsync
call kirak_kw
;call move_kw
;pop cx
;loop cik_main_kw
cmp cs:timercnt1,415
jb cik_main_kw

pop es ds
call reset_timer_routine
retn

dotimer_kw:
inc cs:timercnt1
inc cs:d_xeltol
add xr_kw,3
add yr_kw,2
add zr_kw,4
retn

timer_kw:
pusha
push ds es 
mov ax,data2
mov ds,ax
mov es,ax
call dotimer_kw
pop es ds
popa
jmp oldint

calculate_kw:
mov si,offset xr_kw
call initrotate
mov si,offset points_kw
mov di,offset xyz2_kw
mov cx,8
cik1_calc_kw:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik1_calc_kw
retn

drawfaces_kw:
mov bp,offset xyz2_kw
mov si,offset faces_kw
mov di,offset sortedfaces_kw
mov cx,6
cik1_drawfaces_kw:
push cx
mov ax,6
sub ax,cx
stosw
xor dx,dx
mov cx,4
cik2_drawfaces_kw:
lodsw
shl ax,3
add ax,bp
mov bx,ax
add dx,ds:[bx+4]
loop cik2_drawfaces_kw
mov ax,dx
sar ax,2
stosw
pop cx
loop cik1_drawfaces_kw
;
mov bp,offset sortedfaces_kw
mov cx,3
cik3_drawfaces_kw:
push cx
add cx,2                          ; default 5
mov bx,bp
add bx,4
cik4_drawfaces_kw:
mov ax,ds:[bp+2]
cmp ax,ds:[bx+2]
jge t1_drawfaces_kw
mov eax,ds:[bp]
xchg eax,ds:[bx]
mov ds:[bp],eax            ; sort - maxkival
t1_drawfaces_kw:
add bx,4
loop cik4_drawfaces_kw
pop cx
add bp,4
loop cik3_drawfaces_kw 
;
mov cx,3
mov bp,offset sortedfaces_kw+2*4
cik5_drawfaces_kw:
push cx
mov si,ds:[bp]
shl si,3
add si,offset faces_kw
mov di,offset temp4points_kw
mov cx,4
cik6_drawfaces_kw:
lodsw
push si
shl ax,3
add ax,offset xyz2_kw
mov si,ax
movsd
pop si
loop cik6_drawfaces_kw
mov si,offset temp4points_kw
mov ax,ds:[bp+2]
add ax,192+32
push si bp
mov ah,4
push es
mov es,cs:tempseg
mov bx,offset temp4colors_kw
call polyfill;call gouraud;polyfill
pop es
pop bp si cx
sub bp,4
loop cik5_drawfaces_kw
retn

kirak_kw:
push ds es
mov ds,cs:tempseg
mov ax,0a000h
mov es,ax
mov si,320*(100-ymax_kw/2)
mov di,si
mov cx,320*ymax_kw/4
rep movsd
pop es ds
retn

drawlogo_kw:
push es
mov es,cs:tempseg
mov dx,cs:d_xeltol
cmp dx,1
jl t1_drawlogo_kw
cmp dx,320
jbe t2_drawlogo_kw
mov dx,320
t2_drawlogo_kw:
mov si,offset logo
mov di,320*80
mov cx,40
cik1_drawlogo_kw:
push cx si di 
mov cx,dx
shr cx,1
jnc t3_drawlogo_kw
movsb
t3_drawlogo_kw:
rep movsw
pop di si cx
add si,320
add di,320
loop cik1_drawlogo_kw
t1_drawlogo_kw:
pop es
retn

erase_kw:
push es
mov es,cs:tempseg
mov di,320*(100-ymax_kw/2)
mov cx,320*ymax_kw/4
xor eax,eax
rep stosd
pop es
retn

move_kw:
add xr_kw,3
add yr_kw,2
add zr_kw,4
add cs:d_xeltol,1
retn

assume ds:data1,es:data1
;-------------------------------- PART: torzoom -------------------------------
assume ds:data2,es:data2

torzoom:
mov ax,data2
mov ds,ax

call genmodulo_z
;call zoompcx_z

;xor ax,ax
;int 16h
;push es
;mov si,offset logo
;mov cx,320*40/2
;mov di,320*80
;mov Ax,0a000h
;mov es,ax
;rep movsw
;pop es
;xor ax,ax
;int 16h

mov multizoom_Z,0
mov zoomrot_z,0

mov dx,offset timer_z
call set_timer_routine
mov cs:timercnt2,0

;mov ebp,-1024*2             ;zoom in...
mov cs:bp_z,600-88 ;normal -> zoom in

call dotimer_z

maincik1_zoom_Z:
call calczoom_z
call drawzoom1_Z
call vsync
call drawzoom2_Z
;
;...Timed event...
;

cmp timercnt2,0
timercik_z:
jz etimercik_z
call dotimer_z
dec timercnt2
jmp timercik_z
etimercik_z:

cmp zoomfac_z,65536/512
jne maincik1_zoom_z

maincik1_zoom_end_z:

call reset_timer_routine

retn

bp_z dw ?

timer_z:
inc cs:timercnt2
jmp oldint

dotimer_z:

cmp zoomfac_z,65536/512
je nomoretimer_z

mov bp,cs:bp_z
cmp bp,800
jb dontchange_z
mov multizoom_z,1
dontchange_z:
shl bp,2
mov eax,cs:d_sintable[bp]
add eax,10000h
;shl eax,1 ;total -> *4
add eax,65536/512
cmp multizoom_Z,1
je nincsbaj_z
cmp eax,65536/64
jae nincsbaj_Z
mov eax,65536/64
nincsbaj_Z:
mov zoomfac_Z,eax

add cs:bp_z,1
and cs:bp_z,1023

nozoomtimer_z:

add zoomrot_z,1 ;5

add spos1_1_z,4;3*2
add spos1_2_z,7;5*2
add spos2_1_z,9;6*2
add spos2_2_z,10;7*2
sub spos3_1_z,5;4*2
sub spos3_2_z,8;6*2
sub spos4_1_z,13;8*2
sub spos4_2_z,4;3*2

and spos1_1_z,1023
and spos1_2_z,1023
and spos2_1_z,1023
and spos2_2_z,1023
and spos3_1_z,1023
and spos3_2_z,1023
and spos4_1_z,1023
and spos4_2_z,1023

nomoretimer_z:

retn

genmodulo_Z:
mov ax,data2
mov es,ax
mov di,offset xmodulo_zom_Z
mov cx,5
gm1_Z:
push cx
xor ax,ax
mov cx,xsize_z
gm2_Z:
stosw
inc ax
loop gm2_Z
pop cx
loop gm1_z
mov di,offset ymodulo_zom_z
mov cx,37
gm3_Z:
push cx
mov ax,offset logo
mov cx,ysize_z
gm4_Z:
stosw
add ax,xsize_z
loop gm4_z
pop cx
loop gm3_Z
retn

setesiedi_z macro _x_Z,_y_z,_a_z,_b_Z
movzx esi,_a_Z
mov esi,cs:d_sintable[4*esi]
sar esi,16-5
add esi,_x_Z
movzx edi,_b_Z
mov edi,cs:d_sintable[4*edi]
sar edi,16-5
add edi,_y_Z
endm

calczoom_z:
;
;Rotate the 4 points...
;
setesiedi_Z -160,-100,spos1_1_Z,spos1_2_Z
mov ebp,zoomfac_Z            ;zoom factor
mov bx,zoomrot_Z             ;rot factor
call rotate2d_Z
mov pointx0_z,esi
mov pointy0_Z,edi
;
setesiedi_z  159,-100,spos2_1_Z,spos2_2_Z
mov ebp,zoomfac_z            ;zoom factor
mov bx,zoomrot_Z             ;rot factor
call rotate2d_Z
mov pointx1_Z,esi
mov pointy1_z,edi
;
setesiedi_Z -160,99,spos3_1_Z,spos3_2_Z
mov ebp,zoomfac_Z            ;zoom factor
mov bx,zoomrot_Z             ;rot factor
call rotate2d_z
mov pointx2_Z,esi
mov pointy2_Z,edi

setesiedi_Z 159,  99,spos4_1_Z,spos4_2_Z
mov ebp,zoomfac_Z            ;zoom factor
mov bx,zoomrot_Z             ;rot factor
call rotate2d_Z
mov pointx3_Z,esi
mov pointy3_Z,edi
retn

rotate2d_Z:
;
;Rotates in 2D
;In: ESI/EDI - X/Y
;    EBP zoom factor
;    BX zoom rot
;Out:ESI/EDI - X/Y
;
push bx
and bh,1024/256-1
shl bx,2
mov eax,cs:d_sintable[bx]
mov zoomsinz_Z,eax
pop bx
inc bh      ;add 256
and bh,1024/256-1
shl bx,2
mov eax,cs:d_sintable[bx]
mov zoomcosz_Z,eax
;
;XA=XC*COS(Z)-YC*SIN(Z)
;YA=XC*SIN(Z)+YC*COS(Z)
;
imul edi
imul ebp
shrd eax,edx,16
sar edx,16
mov ecx,eax       ;tempY
mov eax,zoomsinz_Z
imul esi
imul ebp
shrd eax,edx,16
sar edx,16
add ecx,eax
;
mov eax,zoomsinz_Z
imul edi
imul ebp
shrd eax,edx,16
sar edx,16
mov ebx,eax
mov eax,zoomcosz_z
imul esi
imul ebp
shrd eax,edx,16
sar edx,16
sub eax,ebx        ;X
;
mov esi,eax
mov edi,ecx
add esi,xsize_z/2*10000h+8000h
add edi,ysize_z/2*10000h+8000h
retn


drawzoom1_z:
;
;Reverse texture...
;
push es
mov ax,tempseg
mov es,ax
xor di,di
;
mov ebx,199
mov eax,pointx2_Z
sub eax,pointx0_Z
cdq
idiv ebx
mov xstep1_Z,eax
mov eax,pointy2_Z
sub eax,pointy0_Z
cdq
idiv ebx
mov ystep1_Z,eax
;
mov eax,pointx3_Z
sub eax,pointx1_z
cdq
idiv ebx
mov xstep2_Z,eax
mov eax,pointy3_Z
sub eax,pointy1_Z
cdq
idiv ebx
mov ystep2_Z,eax
;
mov cx,200
mov eax,pointx0_Z
mov ebx,pointy0_Z
mov edx,pointx1_Z
mov ebp,pointy1_Z
torzoomcik1_z:
push eax ebx edx ebp cx
cmp multizoom_z,1
je zoommultihoriz_Z
call normalhorizline_Z
jmp endehorizline_Z
zoommultihoriz_Z:
call multihorizline_Z
endehorizline_Z:
pop cx ebp edx ebx eax
add eax,xstep1_Z
add ebx,ystep1_Z
add edx,xstep2_Z
add ebp,ystep2_Z
loop torzoomcik1_Z
pop es
retn

normalhorizline_Z:
;
;draw 320 pix. wide line to ES:DI, with texture values:
;EAX,EBX - from (x/y)
;EDX,EBP - to   (x/y)
;
;No multiplication !!!
;
mov ecx,319
;
mov esi,eax
sub edx,eax
mov eax,edx
cdq
idiv ecx
xchg esi,eax       ;EAX = fromx, ESI = addx
;
sub ebp,ebx
xchg eax,ebp       ;EBX = fromy, EBP = fromx
cdq
idiv ecx
mov edx,eax        ;EDX = addy
;
;EBP - fromx, ESI - addx
;EBX - fromy, EDX - addy
;
inc cx
normalhorizlinecik_z:
xor al,al            ;default pixel color (black)
push ebp ebx
sar ebp,16
sar ebx,16
cmp bp,xsize_z
jae dontdisplay1_Z
cmp bx,ysize_z
jae dontdisplay1_z
add bx,bx
add bp,bp
mov bx,ymodstart_zom_Z[bx]
add bx,ds:xmodstart_zom_z[bp]
mov al,ds:[bx]
dontdisplay1_Z:
stosb
pop ebx ebp
add ebp,esi
add ebx,edx
loop normalhorizlinecik_Z
retn

multihorizline_z:
;
;draw 320 pix. wide line to ES:DI, with texture values:
;EAX,EBX - from (x/y)
;EDX,EBP - to   (x/y)
;
;W/ multiplication !!!
;
mov ecx,319
;
mov esi,eax
sub edx,eax
mov eax,edx
cdq
idiv ecx
xchg esi,eax       ;EAX = fromx, ESI = addx
;
sub ebp,ebx
xchg eax,ebp       ;EBX = fromy, EBP = fromx
cdq
idiv ecx
mov edx,eax        ;EDX = addy
;
;EBP - fromx, ESI - addx
;EBX - fromy, EDX - addy
;
inc cx
multihorizlinecik_z:
push ebp ebx
sar ebp,16
sar ebx,16
add bp,bp
add bx,bx
mov bx,ymodstart_zom_Z[bx]
add bx,ds:xmodstart_zom_Z[bp]
mov al,ds:[bx]
stosb
pop ebx ebp
add ebp,esi
add ebx,edx
loop multihorizlinecik_z
retn

drawzoom2_Z:
push ds es
mov ax,0a000h
mov es,ax
mov ax,tempseg
mov ds,ax
xor si,si
mov di,si
mov cx,64000/4
rep movsd
pop es ds
retn

assume ds:data1,es:data1
;---------------------------- PART: simple plasma -----------------------------
assume ds:data2,es:data2

plasma:
mov ax,data2
mov ds,ax
mov es,ax

push es
mov ax,0a000h
mov es,ax
mov al,es:[0]
pop es
xor ah,ah
mov si,ax
add si,ax
add si,ax
add si,offset logopal
mov di,offset tempcolor_pl
lodsb
shr al,2
stosb
lodsb
shr al,2
stosb
lodsb
shr al,2
stosb

mov cx,256
mov dx,3c8h
xor al,al
out dx,al
inc dx
mov di,offset temppal1_pl
cik0_setpal_pl:
mov si,offset tempcolor_pl
outsb
outsb
outsb
mov si,offset tempcolor_pl
movsw
movsb
loop cik0_setpal_pl

call setupvideo_pl

mov si,offset temppal1_pl
mov di,offset pal_pl
mov cx,768
call fade_install
;call setpal_pl

;mov bufferpos_pl,offset buffer_pl
;mov bufferseg_pl,data2
;mov xmax2_pl,160
;mov ymax2_pl,100                  ; ezek a default ‚rt‚kek

mov dx,offset timer_pl
call set_timer_routine
mov cs:timercnt1,0

cik_fadein_pl:
call plasmastep
call vsync
call fade_step_user
call view_pl
cmp cs:timercnt1,64
jb cik_fadein_pl
;
mov di,offset temppal1_pl
push di
mov cx,768/2
xor ax,ax
rep stosw
mov si,offset pal_pl
pop di
mov cx,768
call fade_install
;
cik_main_pl:
call plasmastep
call vsync
call view_pl
cmp cs:timercnt1,1100+64       ; 8 sec
jb cik_main_pl
;
cik_fadeout_pl:
call plasmastep
call vsync
call fade_step_user
call view_pl
cmp cs:timercnt1,128+1100
jb cik_fadeout_pl

call reset_timer_routine
retn

timer_pl:
pusha
push ds es
mov ax,data2
mov ds,ax
mov es,ax
;
call indexes_pl
inc cs:timercnt1
mov bp,cs:timercnt1
cmp bp,64
jae t1_tpl
call fade_step_timer
t1_tpl:
cmp bp,1100+64      ; 8 sec
jbe t2_tpl
call fade_step_timer
t2_tpl:
;
pop es ds 
popa
jmp oldint

plasmastep:
call main_pl
;call indexes_pl
retn

main_pl:
call precalc_pl
push dword ptr sin3pos_Pl
push sin6pos_Pl
mov di,bufferpos_pl      ;offset buffer_pl
push es
mov es,bufferseg_pl
mov cx,ymax2_pl
cik1_PL:
push cx
call calctemp_PL
call set_a_line_PL
call index_vert_PL
pop cx
add di,lineadd_pl
loop cik1_PL
pop es
pop sin6pos_PL
pop dword ptr sin3pos_PL
sub akarmi_PL,2
retn

indexes_Pl:
inc sin1pos_PL
add sin2pos_Pl,2
dec sin5pos_PL
cmp sin1pos_PL,sin1len_PL
jb ti1__PL
mov sin1pos_PL,0
ti1__PL:
cmp sin2pos_PL,sin2len_Pl
jb ti2__Pl
mov sin2pos_PL,0
ti2__PL:
cmp sin5pos_PL,sin5len_PL
jb ti5__PL
mov sin5pos_PL,sin5len_PL-1
ti5__PL:
;--==ðð==--
dec sin3pos_Pl
dec sin4pos_PL
sub sin6pos_Pl,2
cmp sin3pos_PL,sin3len_PL
jb ti3__Pl
mov sin3pos_PL,sin3len_PL-1
ti3__Pl:
cmp sin4pos_Pl,sin4len_Pl
jb ti4__PL
mov sin4pos_PL,sin4len_Pl-1   
ti4__pl:
cmp sin6pos_PL,sin6len_Pl
jb ti6__PL
mov sin6pos_Pl,sin6len_pl-1
ti6__pl:
;--==ðð==--
retn

index_horiz_pl:
inc sin1pos_Pl
dec sin2pos_PL
add sin5pos_PL,2
cmp sin1pos_PL,sin1len_PL
jb ti1_PL
mov sin1pos_Pl,0
ti1_PL:
cmp sin2pos_PL,sin2len_PL
jb ti2_Pl
mov sin2pos_PL,sin2len_PL-1
ti2_PL:
cmp sin5pos_PL,sin5len_PL
jb ti5_PL
mov sin5pos_PL,0
ti5_PL:
retn

index_vert_Pl:
inc sin3pos_PL
add sin4pos_Pl,2
dec sin6pos_PL
cmp sin3pos_PL,sin3len_PL
jb ti3_PL
mov sin3pos_PL,0
ti3_PL:
cmp sin4pos_Pl,sin4len_PL
jb ti4_Pl
mov sin4pos_PL,0   
ti4_PL:
cmp sin6pos_PL,sin6len_PL
jb ti6_PL
mov sin6pos_pl,sin6len_Pl-1
ti6_pl:
retn

setpal_Pl:
call vsync
mov si,offset pal_Pl
mov cx,768
mov dx,3c8h
xor al,al
out dx,al
inc dx
rep outsb
retn

setupvideo_pl:
mov ax,604h
mov dx,3c4h
out dx,ax
mov dx,3d4h
mov ax,0014h
out dx,ax
mov ax,0e317h
out dx,ax
mov ax,4005h
mov dx,3ceh
out dx,ax      ; xmode
;
mov ax,0f02h   
mov dx,3c4h    
out dx,ax      ; all planes
;
;mov dx,3c2h
;mov al,0e3h
;out dx,al

mov dx,3d4h
mov al,9
out dx,al
inc dx
in al,dx
and al,11100000b
or al,4
mov ah,9
xchg ah,al
dec dx
out dx,ax      ; set pixel height
retn

view_Pl:
push es
mov ax,0a000h
mov es,ax
mov si,offset buffer_pl
xor di,di
mov cx,100
c1_Pl:
push cx
;
push si
push di
mov ax,0302h
mov dx,3c4h
out dx,ax
mov cx,80
c5_PL:
movsb
inc si
loop c5_pl
;
pop di
pop si
mov ax,0c02h
mov dx,3c4h
out dx,ax
mov cx,80
c9_PL:
inc si
movsb
loop c9_Pl
;add di,160
pop cx
loop c1_Pl
pop es
retn

set_a_line_PL:
mov cx,xmax2_Pl
shr cx,2          ; div /4
mov si,offset tempval_PL
mov dl,temp_Pl
mov dh,dl
push dx
push dx
pop edx
cik_st1_Pl:
lodsd
add eax,edx
stosd
loop cik_st1_PL
retn

precalc_PL:
mov di,offset tempval_pl
push dword ptr sin1pos_Pl
push sin5pos_Pl

mov cx,xmax_Pl
cik_pc1_Pl:
call calculus1_Pl
stosb
call index_horiz_Pl
loop cik_pc1_Pl
pop sin5pos_Pl
pop dword ptr sin1pos_Pl
retn

calctemp_pl:
mov si,offset sinus3_PL
add si,sin3pos_PL
mov bl,ds:[si]
mov si,offset sinus4_PL
add si,sin4pos_Pl
mov al,ds:[si]
mov si,offset sinus6_Pl
add si,sin6pos_Pl
add al,ds:[si]
add al,akarmi_PL
mov temp_PL,al
retn

calculus1_Pl:
xor bx,bx
xor ax,ax
mov si,offset sinus1_Pl
add si,sin1pos_PL
mov bl,ds:[si]
mov si,offset sinus2_Pl
add si,sin2pos_PL
mov al,ds:[si]
mov si,offset sinus5_PL
add si,sin5pos_PL
add al,ds:[si]
retn

calculus_Pl:
call calculus1_Pl
add al,temp_PL
retn

assume ds:data1,es:data1
;------------------------------ PART: endscroll -------------------------------

endscroll:
mov ax,data1
mov ds,ax
mov es,ax

mov di,offset planes_s
xor ax,ax
mov cx,maga_s*80*4/2
rep stosw

mov ax,0eh
int 10h

mov dx,3d4h
mov ax,9
out dx,ax

mov dx,3c2h
mov al,0e3h
out dx,al

mov dx,3dah
in al,dx
mov dx,3c0h
xor al,al
pal01_S:
out dx,al
out dx,al
inc al
cmp al,10h
jb pal01_S

mov al,20h
out dx,al

mov si,offset pal_S
mov dx,3c8h
xor al,al
out dx,al
inc dx
mov cx,30h
rep outsb

mov al,07eh
out 21h,al

push 0a000h
pop es

maincik_S:
add planepos_S,80
inc scrolled_S
cmp scrolled_S,maga_S
jne tovcik01_S
mov scrolled_s,0
push ds
pop es
mov di,offset planes_S
mov planepos_S,di
xor ax,ax
mov cx,maga_s*80*4/2
rep stosw

push 0a000h
pop es

call writenext_S
tovcik01_S:
call copy2vidmem_S
in al,60h
cmp al,1
jne maincik_s
retn

vege_S:
pop ax
retn

writenext_S:
mov si,scrlpos_S
cmp byte ptr ds:[si],0
jne oknext_S
jmp vege_S
oknext_S:
mov cx,40
xor di,di
cmp byte ptr ds:[si],2
jne nolineskip_s
inc scrlpos_s
retn
nolineskip_s:
cmp byte ptr ds:[si],1
jne writecik_S
inc si
inc di
writecik_S:
lodsb
sub al,32

xor ah,ah
mov bx,ax
shl bx,5
add bx,ax      ;*33
shl bx,1       ;*2
;
;Convert
;
push cx
push di
mov cx,height_S
writecik2_S:
mov ax,word ptr font_S[bx]
mov planes_S[di],ax
mov ax,word ptr font_s+1 * height_s*20*sorok_S*2[bx]
mov planes_s+80*maga_s[di],ax
mov ax,word ptr font_s+2 * height_s*20*sorok_S*2[bx]
mov planes_s+160*maga_s[di],ax
mov ax,word ptr font_s+3 * height_s*20*sorok_S*2[bx]
mov planes_s+240*maga_s[di],ax
add di,80
add bx,2
loop writecik2_s
pop di
pop cx
add di,2
loop writecik_s
mov scrlpos_S,si
retn

copy2vidmem_S:
;
;Copy to vidmem.
;
mov si,planepos_s
mov di,ideraksz_S
mov dx,3c4h
mov ax,102h
out dx,ax
mov cx,80/4
rep movsd
mov si,planepos_s
add si,80*maga_s
mov di,ideraksz_S
mov dx,3c4h
mov ax,202h
out dx,ax
mov cx,80/4
rep movsd
mov si,planepos_s
add si,80*2*maga_s
mov di,ideraksz_S
mov dx,3c4h
mov ax,402h
out dx,ax
mov cx,80/4
rep movsd
mov si,planepos_s
add si,80*3*maga_s
mov di,ideraksz_S
mov dx,3c4h
mov ax,802h
out dx,ax
mov cx,80/4
rep movsd
;
;-)
;
mov bp,hardpos_s
call movescreen_S
;
;-)
;
mov si,planepos_s
mov di,bp
mov dx,3c4h
mov ax,102h
out dx,ax
mov cx,80/4
rep movsd
mov si,planepos_s
add si,80*maga_s
mov di,bp
mov dx,3c4h
mov ax,202h
out dx,ax
mov cx,80/4
rep movsd
mov si,planepos_s
add si,80*2*maga_s
mov di,bp
mov dx,3c4h
mov ax,402h
out dx,ax
mov cx,80/4
rep movsd
mov si,planepos_s
add si,80*3*maga_s
mov di,bp
mov dx,3c4h
mov ax,802h
out dx,ax
mov cx,80/4
rep movsd
retn

movescreen_S:
mov cx,speed_s
jcxz y1y1_s
x1x1_S:
call vsync
loop x1x1_S
call hsync
y1y1_s:
add hardpos_S,80
cmp hardpos_S,400*80
jbe tov01_S
mov hardpos_S,0
mov ideraksz_S,400*80
tov01_s:
add ideraksz_s,80
mov dx,3d4h
mov al,0ch
mov ah,byte ptr hardpos_S+1
out dx,ax
inc al
mov ah,byte ptr hardpos_S
out dx,ax
retn

assume ds:data1,es:data1
;--------------------------- PART: gouraud objects ----------------------------
assume ds:data1,es:data1

hany100sec_ct1 = 950+150+50     ;8.5sec - only chesstable

gensintable_ct:        ;Generates movetable for chesstable zoom-r
push es
mov ax,data1
mov es,ax
mov di,offset move_ct
xor bx,bx
xor si,si
mov cx,256
gensincik_ct:
mov eax,cs:d_sintable[bx]
cdq
mov ebp,65536/50
idiv ebp
add ax,160
stosw
mov eax,cs:d_sintable[si]
cdq
mov ebp,65536/42
idiv ebp
add ax,100
stosw
add bx,4*4
add si,8*4
and si,4095
loop gensincik_ct
pop es
retn

timer0_go:
pusha
push ds es
;
inc cs:timercnt1
mov bp,cs:timercnt1
cmp bp,64
jae t1_t0go
call fade_step_timer
t1_t0go:
;
pop es ds
popa
jmp oldint

gouraudobj:
mov ax,data1
mov ds,ax
mov es,ax

mov dx,offset timer0_go
call set_timer_routine
mov cs:timercnt1,0

mov si,offset black_ct
mov di,offset grey_ct
mov cx,768
call fade_install
cik1_bejon_a_chesstable:
call vsync
call fade_step_user
cmp cs:timercnt1,64
jb cik1_bejon_a_chesstable

mov si,offset grey_ct
mov di,offset black_ct
push di
xor ax,ax
stosw
stosb
mov cx,254*3
mov al,11h
rep stosb
mov al,0ch
stosb
stosb
stosb
pop di
mov cx,768
call fade_install

mov cs:timercnt1,0
mov cs:timercnt2,0
mov cs:timercnt3,1

cik2_bejon_a_chesstable:
mov cx,cs:timercnt1
sub cx,cs:timercnt2
jcxz nono_ct
cikn_bejon2_ct:
push cx
dec cs:timercnt3
jnz t1_bejon2_ct
call movestep_chess
mov cs:timercnt3,2
t1_bejon2_ct:
pop cx
loop cikn_bejon2_ct
nono_ct:
mov ax,cs:timercnt1
mov cs:timercnt2,ax
;
call chesstable_ct
call vsync
call fade_step_user
call kirak_go
cmp cs:timercnt1,64
jb cik2_bejon_a_chesstable

cik3_bejon_a_chesstable:
mov cx,cs:timercnt1
sub cx,cs:timercnt2
jcxz nono3_ct
cikn_bejon3_ct:
push cx
dec cs:timercnt3
jnz t1_bejon3_ct
call movestep_chess
mov cs:timercnt3,2
t1_bejon3_ct:
pop cx
loop cikn_bejon3_ct
nono3_ct:
mov ax,cs:timercnt1
mov cs:timercnt2,ax
;
call chesstable_ct
call vsync
call kirak_go
cmp cs:timercnt1,64+hany100sec_ct1
jb cik3_bejon_a_chesstable

call reset_timer_routine
mov dx,offset timer_go
call set_timer_routine
;mov cs:timercnt3,1

mov cs:d_perspective,1
mov cs:d_eyedist,220
mov cs:d_xeltol,160
mov cs:d_yeltol,100

push es
mov es,cs:tempseg
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
pop es

mov cx,objects_num_go
mov si,offset object_list_go
mov bp,offset color_list_go
cik1_go:
push cx si bp
mov si,ds:[si]            
push si
mov ax,ds:[si]
mov points_num_go,ax
mov si,ds:[si+4]
mov di,offset xyz_go
mov cx,ax
add cx,ax
add cx,ax
rep movsw
pop si
push si
mov cx,ds:[si+2]
mov faces_num_go,cx
shl cx,2
mov si,ds:[si+6]
mov di,offset faces_go
rep movsw
pop si
add si,8
mov di,offset fromx_go
movsd
movsd
movsd
movsd
;
movsd
movsw      ; btmlogohoz keene [szoegek]

mov dx,3c8h
xor ax,ax
out dx,al
inc dx
mov al,ds:[bp]      ; al - redadd  
mov bx,ds:[bp+1]    ; bl - greenadd ; bh - blueadd
xor si,si           ; red
xor di,di           ; green
xor bp,bp           ; blue
mov cx,63
cik1_setpal_go:
push ax 
add ax,si
mov si,ax
shr ax,6
out dx,al
mov ax,di
add al,bl
adc ah,0
mov di,ax
shr ax,6
out dx,al
mov ax,bp
add al,bh
adc ah,0
mov bp,ax
shr ax,6
out dx,al
pop ax
loop cik1_setpal_go

comment #
mov dx,3c8h
mov al,254
out dx,al
inc dx
mov al,12;14
out dx,al
out dx,al
out dx,al
mov al,17;20
out dx,al
out dx,al
out dx,al
#

shift_go=9 ;8
;
mov ax,tox_go
sub ax,fromx_go
cwde
mov addx_go,eax
mov ax,fromx_go
cwde
sal eax,shift_go
mov cux2_go,eax
;
mov ax,toy_go
sub ax,fromy_go
cwde
mov addy_go,eax
mov ax,fromy_go
cwde
sal eax,shift_go
mov cuy2_go,eax

;sti
mov cs:timercnt1,0
mov cs:timercnt2,0

mov cs:d_perszeltol,-256+80;??
mov perszeltoladd_go,1

call move_go
;mov cx,256
cik2_go:
;push cx
;call move_go
call calculate_go
;call erase_go
call chesstable_ct;step
call drawfaces_go
call vsync
call kirak_go
;pop cx
;loop cik2_go
mov cx,cs:timercnt1
sub cx,cs:timercnt2
jcxz t9_main_go
cik01_go:
push cx
call move_go
dec cs:timercnt3
jnz nochessmove
mov cs:timercnt3,2
call movestep_chess
nochessmove:
;
mov ax,perszeltoladd_go
cwde
add cs:d_perszeltol,eax
cmp cs:d_perszeltol,80
jl t1_x_go
neg perszeltoladd_go
t1_x_go:
;
pop cx
loop cik01_go
mov ax,cs:timercnt1
mov cs:timercnt2,ax
t9_main_go:
cmp cs:timercnt1,512 ;256
jb cik2_go

pop bp si cx
add bp,3
add si,2
loop cik1_go
call reset_timer_routine

mov dx,offset timer0_go
call set_timer_routine

mov di,offset grey_ct
mov cx,768
mov al,3fh
rep stosb
mov si,offset black_ct
mov di,offset grey_ct
mov cx,768
call fade_install

mov cs:timercnt1,0
mov cs:timercnt2,0
mov cs:timercnt3,1

cik2_kimegy_a_chesstable:
mov cx,cs:timercnt1
sub cx,cs:timercnt2
jcxz nono5_ct
cikn_kimegy2_ct:
push cx
dec cs:timercnt3
jnz t1_kimegy2_ct
call movestep_chess
mov cs:timercnt3,2
t1_kimegy2_ct:
pop cx
loop cikn_kimegy2_ct
nono5_ct:
mov ax,cs:timercnt1
mov cs:timercnt2,ax
call chesstable_ct
call vsync
call fade_step_user
call kirak_go
cmp cs:timercnt1,64
jb cik2_kimegy_a_chesstable

call reset_timer_routine
retn

;dotimer_go:
;call move_go
;retn

timer_go:
inc cs:timercnt1
jmp oldint

calculate_go:
mov ax,cux_go
mov cs:d_xeltol,ax
mov ax,cuy_go
mov cs:d_yeltol,ax
;
mov si,offset xr_go
call initrotate
mov si,offset xyz_go
mov di,offset xyz2_go
mov cx,points_num_go
cik1_calc_go:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik1_calc_go
retn

drawfaces_go:
mov bp,offset xyz2_go
mov si,offset faces_go
mov di,offset sortedfaces_go
mov cx,faces_num_go
cik1_drawfaces_go:
push cx
mov ax,faces_num_go
sub ax,cx
stosw
xor dx,dx
mov cx,4
mov ax,ds:[si]
cmp ax,ds:[si+6]
jne t1_df_go
dec cx
t1_df_go:
push cx si
cik2_drawfaces_go:
lodsw
shl ax,3
add ax,bp
mov bx,ax
add dx,ds:[bx+4]
loop cik2_drawfaces_go
pop si cx
add si,8
mov ax,dx
cwd
idiv cx
stosw
pop cx
loop cik1_drawfaces_go
;
mov bp,offset sortedfaces_go
mov cx,faces_num_go
dec cx
cik3_drawfaces_go:
push cx
mov bx,bp
add bx,4
cik4_drawfaces_go:
mov ax,ds:[bp+2]
cmp ax,ds:[bx+2]
jge t1_drawfaces_go
mov eax,ds:[bp]
xchg eax,ds:[bx]
mov ds:[bp],eax            ; sort - maxkival
t1_drawfaces_go:
add bx,4
loop cik4_drawfaces_go
pop cx
add bp,4
loop cik3_drawfaces_go 
;
mov cx,faces_num_go
mov bp,offset sortedfaces_go
mov ax,faces_num_go
dec ax
shl ax,2
add bp,ax
cik5_drawfaces_go:
push cx
mov si,ds:[bp]
shl si,3
add si,offset faces_go
mov di,offset temp4points_go
mov bx,offset temp4colors_go
mov cx,4
cik6_drawfaces_go:
lodsw
push si
shl ax,3
add ax,offset xyz2_go
mov si,ax
movsd
lodsw
sar ax,1
add ax,32
mov es:[bx],ax
add bx,4
pop si
loop cik6_drawfaces_go
mov si,offset temp4points_go
;mov ax,ds:[bp+2]
push si bp es
mov es,cs:tempseg
mov bx,offset temp4colors_go
mov ah,4
call gouraud
pop es bp si cx
sub bp,4
loop cik5_drawfaces_go
retn

kirak_go:
push ds es 9000h-400h 0a000h
pop es ds 
mov cx,16000
xor si,si
mov di,si
rep movsd
pop es ds
retn

kirak_go_old:
mov xkirak,xmax_go
mov ykirak,ymax_go
push ds
pop fs
mov si,320*(100-ymax_go/2)+160-xmax_go/2
mov ax,cuy_go
sub ax,ymax_go/2
mov bx,cux_go
sub bx,xmax_go/2

cmp ax,200
jg nokirak
cmp bx,320
jg nokirak
cmp ax,-ymax_go
jle nokirak
cmp bx,-xmax_go
jle nokirak

cmp ax,200-ymax_go
jng noproblem1_go
mov cx,200
sub cx,ax
mov ykirak,cx
noproblem1_go:
;
cmp bx,320-xmax_go
jng noproblem2_go
mov dx,bx
and dx,3
and bx,0ffffh-3
mov cx,320
sub cx,bx
mov xkirak,cx
;and si,0ffffh-3     ; ez jo elvileg..
sub si,dx
noproblem2_go:
;
cmp ax,0
jnl noproblem3_go
;mov dx,ax
push ax
neg ax
xchg ah,al
mov dx,ax
shr ax,2
add dx,ax
;sal dx,8
add si,dx
pop ax
mov cx,ymax_go
add cx,ax
mov ykirak,cx
xor ax,ax
noproblem3_go:
;
cmp bx,0
jnl noproblem4_go
sub si,bx
mov cx,xmax_go
add cx,bx
and cx,0ffffh-3
add cx,4
mov xkirak,cx
xor bx,bx
noproblem4_go:

xchg ah,al
add bx,ax
shr ax,2
add bx,ax
mov di,bx

push ds es
mov ds,cs:tempseg
mov ax,0a000h
mov es,ax

mov cx,fs:ykirak
cik1_kirak_go:
push di si cx
mov cx,fS:xkirak
shr cx,2
rep movsd
pop cx si di
add si,320
add di,320
loop cik1_kirak_go
pop es ds

nokirak:
retn

erase_go:
push es
mov es,cs:tempseg
xor di,di
mov cx,16000
xor eax,eax
rep stosd
pop es
retn

move_go:
mov ax,xradd_Go
add xr_go,ax
mov ax,yradd_go
add yr_go,ax
mov ax,zradd_go
add zr_go,ax
;
mov eax,cux2_go
add eax,addx_go
mov cux2_go,eax
sar eax,shift_go
add ax,160
mov cux_go,ax
mov eax,cuy2_go
add eax,addy_go
mov cuy2_go,eax
sar eax,shift_go
add ax,100
mov cuy_go,ax
retn

repstosb macro
local t1_ct,t2_Ct,t3_ct
shr cx,1
jnc t1_ct
stosb
t1_ct:
shr cx,1
jnc t2_ct
stosw
t2_ct:
jcxz t3_ct
rep stosd
t3_ct:
endm

csinal1sor macro
local c1_ct,c2_ct,c3_ct,noc1_ct,noc2_ct,noc3_ct
mov cx,eltolasx_ct2
move_ctaxcolor
repstosb
xor dl,1
mov cx,xcount_ct1
jcxz noc1_ct
c1_ct:
push cx
mov cx,side_ct
move_ctaxcolor
repstosb
pop cx
xor dl,1
loop c1_ct
noc1_ct:
mov cx,xcount_ct2
move_ctaxcolor
repstosb
endm

move_ctaxcolor macro
mov al,dl
mov ah,al
push ax ax
pop eax
endm

;chesstable_Step:

movestep_chess:
mov si,move_ctpos
mov di,offset eltolasx_ct
movsd
cmp si,256*4+offset move_ct
jb t2_main_ct
sub si,256*4 ;offset move_ct
t2_main_ct:
mov move_ctpos,si
;call chesstable_ct
mov ax,side_ctadd
add side_ct,ax
mov ax,side_ct
sub ax,20
cmp ax,105   ;120 - megant:)
jb t1_main_ct
neg side_ctadd
t1_main_ct:
retn

chesstable_Ct:
mov bl,255;xor bx,bx
mov ax,eltolasx_ct
mov cx,side_ct
cwd
idiv cx
mov eltolasx_ct2,dx
test al,1
jnz t02_ct
xor bl,1
t02_ct:
mov ax,eltolasy_ct
cwd
idiv cx
mov eltolasy_ct2,dx
test al,1
jnz t01_ct
xor bl,1
t01_ct:
;
mov ax,200
sub ax,eltolasy_ct2
xor dx,dx
div cx
mov ycount_ct1,ax
mov ycount_ct2,dx
mov ax,320
sub ax,eltolasx_ct2
xor dx,dx
div cx
mov xcount_ct1,ax
mov xcount_ct2,dx
;
push es 09000h-400h
pop es
xor di,di
mov dx,bx
;
mov cx,eltolasy_ct2
jcxz nocik6_ct
cik6_ct:
push cx dx
csinal1sor
pop dx cx
loop cik6_ct
nocik6_ct:
xor dl,1
;
mov cx,ycount_ct1
jcxz nocik1_ct
cik1_ct:
push cx dx
mov cx,side_ct
cik2_ct:
push cx dx
csinal1sor
pop dx cx
loop cik2_ct
pop dx cx
xor dl,1
loop cik1_ct
nocik1_ct:
;
mov cx,ycount_ct2
jcxz nocik4_ct
cik4_ct:
push cx dx
csinal1sor
pop dx cx
loop cik4_ct
nocik4_ct:
;
pop es
retn

assume ds:data1,es:data1
;--------------------- PART: viewlog alias milka galaxy -----------------------
assume ds:vldata,es:vldata

h100s_vl = 660

viewlog:
mov ax,vldata
mov ds,ax
mov es,ax

mov ax,0eh     ;640x200
int 10h
mov dx,3c2h
mov al,0e3h
out dx,al

mov dx,3d4h
mov ax,9
out dx,ax      ;640x400

mov dx,3ceh
mov ax,005h
out dx,ax

mov cs:d_perspective,0
call genobjects_vl
mov dword ptr cs:d_eyedist,350
mov cs:d_perspective,1

mov ax,1002h
mov dx,offset externalpalette_vl
int 10h                           ; !!! 16-color mode

mov dx,3c8h
xor al,al
out dx,al
inc dx
mov cx,16*3
mov al,3fh
cik1_setpal_vl:
out dx,al
loop cik1_setpal_vl      ; black palette
;
call drawlogo_vl
mov xadd_vl,0
mov yadd_vl,0

mov dx,offset timer_vl
call set_timer_routine
mov cs:timercnt1,0
;
mov si,offset whitepal_vl
mov di,offset pal_vl
mov cx,48
call fade_install
cik2_setpal_vl:
call csillagmania_vl              ; befadeol texttel egyutt
call fade_step_user               ; idozitett fade!
cmp cs:timercnt1,64;          ; double - fast fade
jb cik2_setpal_vl 
;
mov di,offset gomb_vl
call transformini_vl
;
cik_main1_vl:
call csillagmania_vl              ; csillagok vannak
cmp cs:timercnt1,64+h100s_vl      ; 4sec
jb cik_main1_vl
;
cik_main2_vl:
call csillagmania_vl              ; csillagok -> gomb
cmp cs:timercnt1,64+h100s_vl+256      ; kb 10 sor a zeneben
jb cik_main2_vl
;
mov di,offset torus_vl
call transformini_vl
;
cik_main3_vl:
call csillagmania_vl               ; gomb marad
cmp cs:timercnt1,64+256+h100s_vl*2
jb cik_main3_vl
;
cik_main4_vl:
call csillagmania_vl               ; gomb -> torus
cmp cs:timercnt1,64+256*2+h100s_vl*2
jb cik_main4_vl
;
mov di,offset kocka_vl
call transformini_vl
;
cik_main5_vl:
call csillagmania_vl              ; torus marad
cmp cs:timercnt1,64+256*2+h100s_vl*3
jb cik_main5_vl
;
cik_main6_vl:
call csillagmania_vl
cmp cs:timercnt1,64+256*3+h100s_vl*3
jb cik_main6_vl
;
mov si,offset pal_vl
mov di,offset pal_vl2
mov cx,48
call fade_install

cik_main7_vl:
call csillagmania_vl
cmp cs:timercnt1,64+256*3+h100s_vl*4
jb cik_main7_vl

cik3_setpal_vl:
call csillagmania_vl
call fade_step_user
cmp cs:timercnt1,64*2+256*3+h100s_vl*4      ;+400+256+400+256+400+256+400+64
jb cik3_setpal_vl

cik_main8_vl:
call csillagmania_vl
cmp cs:timercnt1,64*2+h100s_vl*4+256*3+150
jb cik_main8_vl

mov si,offset pal_vl2
mov di,offset blackpal_vl
mov cx,48
call fade_install
mov cx,64
cik_fade1_vl:
push cx
call vsync
call fade_step
pop cx
loop cik_fade1_vl

;vege_vl:
call reset_timer_routine
retn

;
;-( timer routine of viewlog part )-;
;
timer_vl:
pusha
push es ds
mov ax,vldata
mov ds,ax
mov es,ax
;
add xr_vl,3;5
add yr_vl,5;7
sub zr_vl,2;4
inc cs:timercnt1
mov bp,cs:timercnt1
cmp bp,64                ; double - fast fade
jae t1_tvl
push bp
call fade_step_timer
pop bp
t1_tvl:
cmp bp,h100s_vl+64
jb t2_tvl
cmp bp,h100s_vl+64+256
jae t2_tvl
push bp
call transformstep_vl
pop bp
t2_tvl:
cmp bp,h100s_vl*2+64+256
jb t3_tvl
cmp bp,h100s_vl*2+64+256*2
jae t3_tvl
push bp
call transformstep_vl
pop bp
t3_tvl:
cmp bp,h100s_vl*3+64+256*2
jb t4_tvl
cmp bp,(256+h100s_vl)*3+64 
jae t4_tvl
push bp
call transformstep_vl
pop bp
t4_tvl:
cmp bp,64+256*3+h100s_vl*4 ;64+400+256+400+256+400+256+400
jb t5_tvl
cmp bp,64*2+h100s_vl*4+256*3 
jae t5_tvl
push bp
call fade_step_timer
pop bp
t5_tvl:
cmp bp,64*2+h100s_vl*4+256*3
jb t6_tvl
cmp bp,64*2+h100s_vl*4+256*3+150
jae t6_tvl
mov si,sinpos_vl
add sinpos_vl,4
mov ax,ds:[si]
neg ax
mov xadd_vl,ax
mov ax,ds:[si+2]
mov yadd_vl,ax
t6_tvl:
;
pop ds es
popa
jmp oldint

;-( viewlog internal routines )-;

logowidth_vl equ 320

drawlogo_vl:
push es
mov dx,3c4h
mov ax,0802h
out dx,ax
push 0a000h
pop es
call kiraklog_vl
push 0a800h
pop es
call kiraklog_vl
pop es
retn
;
kiraklog_vl:
mov di,180*80+(640-logowidth_vl)/8/2
mov si,offset logo_vl
mov cx,40  ;Height
kirakcik_vl:
push cx
push di
mov cx,logowidth_vl/8
rep movsb
pop di
add di,640/8
pop cx
loop kirakcik_vl
retn

genobjects_vl:
call randomize
mov bp,0
mov cx,starnum_vl
randcik_vl:
push cx

;-)
call random
mov txr_vl,ax
call random
mov tyr_vl,ax
call random
mov tzr_vl,ax
mov tx1_vl,sugar_vl
mov ty1_vl,0
mov tz1_vl,0
mov si,offset txr_vl
call initrotate
mov si,offset tx1_vl
mov di,offset tx2_vl
call calc3d
mov ax,tx2_vl
mov ds:gomb_vl[bp],ax
mov ax,ty2_vl
mov ds:gomb_vl[bp+2],ax
mov ax,tz2_vl
mov ds:gomb_vl[bp+4],ax

;-}
call random
mov cx,(starmax_vl-starmin_vl)
xor dx,dx
div cx
add dx,starmin_vl
mov tx1_vl,dx
mov si,offset tx1_vl
mov di,offset tx2_vl
call calc3d
mov ax,tx2_vl
mov ds:stars_vl[bp],ax
mov ax,ty2_vl
mov ds:stars_vl[bp+2],ax
mov ax,tz2_vl
mov ds:stars_vl[bp+4],ax

;-]
call random
xor dx,dx
mov cx,6
div cx
mov si,dx
call random
xor dx,dx
mov cx,kocakside_vl
div cx
sub dx,kocakside_vl/2
push dx
call random
xor dx,dx
mov cx,kocakside_vl
div cx
sub dx,kocakside_vl/2
push dx
mov ax,-(kocakside_vl/2)
cmp si,3
jb tov01_vl
neg ax
sub si,3
tov01_vl:
cmp si,1
je egyik_vl
jb masodik_vl

xx_vl equ word ptr ds:kocka_vl[bp]
yy_vl equ word ptr ds:kocka_vl[bp+2]
zz_vl equ word ptr ds:kocka_vl[bp+4]

harmadik_vl:
mov xx_vl,ax
pop yy_vl
pop zz_vl
jmp negyedik_vl
masodik_vl:
mov yy_vl,ax
pop xx_vl
pop zz_vl
jmp negyedik_vl
egyik_vl:
mov zz_vl,ax
pop xx_vl
pop yy_vl
negyedik_vl:

;-{
call random
mov txr_vl,0
mov tyr_vl,ax
mov tzr_vl,0
mov tx1_vl,subradius_vl
mov ty1_vl,0
mov tz1_vl,0
mov si,offset txr_vl
call initrotate
mov si,offset tx1_vl
mov di,offset tx2_vl
call calc3d
add tx2_vl,mainradius_vl
call random
mov txr_vl,0
mov tyr_vl,0
mov tzr_vl,ax
mov si,offset txr_vl
call initrotate
mov si,offset tx2_vl
mov di,offset tx1_vl
call calc3d
mov ax,tx1_vl
mov ds:torus_vl[bp],ax
mov ax,ty1_vl
mov ds:torus_vl[bp+2],ax
mov ax,tz1_vl
mov ds:torus_vl[bp+4],ax

pop cx
add bp,6
loop randcik_vl
retn

csillagmania_vl:          ; koordinatakhoz hozzaadjuk a XADD_VL, etc..
call erase_vl
;Calc.
mov ax,vldata
mov es,ax
;-)
;add xr_vl,3
;add yr_vl,6
;sub zr_vl,3
;-)
mov si,offset xr_vl
call initrotate
mov cx,starnum_vl
mov si,offset stars_vl
mov di,calcaddr_vl
szamcik_vl:
call calc3d
mov ax,es:[di]
add ax,160
shl ax,1
add ax,xadd_vl
stosw
mov ax,es:[di]
add ax,100
shl ax,1
add ax,yadd_vl
stosw
add si,6
add di,2
loop szamcik_vl
;
;Just draw them !!!
;
call draw_vl
mov ax,vldata
mov es,ax
call swapsegs_vl
call vsync
retn

swapsegs_vl:
mov ax,calcaddr_vl
xchg ax,deladdr_vl
mov calcaddr_vl,ax
mov bx,visual_vl
xchg bx,notvisual_vl
mov visual_vl,bx
sub bx,0a000h
shl bx,4
mov dx,3d4h
mov al,0ch
mov ah,bh
out dx,ax
inc al
mov ah,bl
out dx,ax
retn

draw_vl:
mov si,calcaddr_vl
mov es,notvisual_vl
mov cx,starnum_vl
;
;Rajzoljunk egyet!
;
drawcik_vl:
push cx
mov ax,ds:[si+2]  ;Y
mov bx,ds:[si]    ;X
mov cx,ds:[si+4]  ;Z
cmp cx,0
jge dontdrawx_vl
neg cx
dontdrawx_vl:
cmp ax,399
ja dontdraw_vl
cmp bx,639
ja dontdraw_vl
push cx
push bx
shl ax,4   ;*16
shr bx,3   ;/8
add bx,ax
shl ax,2   ;*64
add bx,ax
pop cx
and cl,7
mov bp,cx
call setit_vl
mov dx,3c4h
mov ax,0702h
out dx,ax
pop cx
mov byte ptr es:[bx],0
call setcol_vl
mov cx,bp
mov ch,80h
shr ch,cl
mov byte ptr es:[bx],ch
dontdraw_vl:
pop cx
add si,6
loop drawcik_vl
retn

erase_vl:
mov si,calcaddr_vl
mov es,notvisual_vl
mov cx,starnum_vl
;
;Toroljunk egyet!
;
erasecik_vl:
push cx
mov ax,ds:[si+2]  ;Y
mov bx,ds:[si]    ;X
mov cx,ds:[si+4]  ;Z
cmp cx,0
jge dontdel2_vl
neg cx
dontdel2_vl:
cmp ax,399
ja dontdel_vl
cmp bx,639
ja dontdel_vl
shl ax,4   ;*16
shr bx,3   ;/8
add bx,ax
shl ax,2   ;*64
add bx,ax
mov dx,3c4h
mov ax,0702h
out dx,ax
;call setcol_vl
mov byte ptr es:[bx],0
dontdel_vl:
pop cx
add si,6
loop erasecik_vl
retn

setcol_vl:
shr cx,4     ; 5      ;/32
mov ah,cl
inc ah        ;It works (or not ???)
and ah,7
;-)

mov al,2
mov dx,3c4h
out dx,ax
retn

setit_vl:
;
;Enable one bit only, as dictated by CL
;
mov ax,8008h
shr ah,cl
mov al,0ffh
mov dx,3ceh
out dx,ax
retn

transformini_vl:                     ; di-ben, hogy a current az mibe
mov si,offset stars_Vl
mov cx,starnum_vl*3
xor bp,bp
cik1_transformini_vl:
lodsw
mov bx,ds:[di]
.386
cwde
movsx ebx,bx
sub ebx,eax
shl eax,hanyfazislog_vl        ; x log 2
mov ds:transform2_vl[bp],eax
mov ds:transform_vl[bp],ebx
add bp,4
add di,2
loop cik1_transformini_vl
retn

transformstep_vl:
push es
push ds
pop es
mov cx,starnum_vl*3
xor si,si
mov di,offset stars_vl
cik1_transfromstep_vl:
mov eax,ds:transform2_vl[si]
add eax,ds:transform_vl[si]
mov ds:transform2_vl[si],eax
sar eax,hanyfazislog_vl
stosw
add si,4
loop cik1_transfromstep_vl
pop es
retn

assume ds:data1,es:data1
;--------------------------------- PART: vecc ---------------------------------
assume ds:data1,es:data1

hany100sec_v0 equ 200+256     ; mer zenere jo volt, csak egyensuly :)
hany100sec_v1 equ 200

timer0_v:
pusha
push ds es
mov ax,data1
mov ds,ax
mov es,ax
;
add mainxr_v,2
add mainyr_v,3
add mainzr_v,2
inc cs:timercnt1
mov bp,cs:timercnt1
cmp bp,256
jae t1_t0v
add cs:d_perszeltol,8*3*2
jmp vege_t0v
t1_t0v:
cmp bp,256+hany100sec_v0
jb vege_t0v
cmp bp,256+hany100sec_V0+112
jae t2_t0v
dec cs:timercnt3
jnz t3_t0v
inc size2_v
mov cs:timercnt3,4
t3_t0v:
jmp vege_t0v
t2_t0v:
cmp bp,256+hany100sec_v0+112+128
jae t4_t0v
mov si,offset xr0_v
mov di,offset xr0add_v
mov cx,8*3
cik1_t0v:
movsx ax,byte ptr ds:[di]
add ds:[si],ax
inc di
inc si
inc si
loop cik1_t0v
jmp vege_t0v
t4_t0v:
cmp bp,256+hany100sec_v0+112+128+112
jae t5_t0v
dec cs:timercnt3
jnz t6_t0v
dec size2_v
mov cs:timercnt3,4
t6_t0v:
jmp vege_t0v
t5_t0v:
cmp bp,256+hany100sec_v0+112+128+112+80
jae t10_t0v
dec cs:timercnt3
jnz t7_t0v
mov cs:timercnt3,2
mov si,offset xyz_okta_v2
mov di,si
mov cx,6*3
cik2_t0v:
lodsw
cmp ax,0
je t8_t0v
jl t9_t0v
inc ax
jmp t8_t0v
t9_t0v:
dec ax
t8_t0v:
stosw
loop cik2_t0v
t7_t0v:
jmp vege_t0v
t10_t0v:
;
vege_t0v:
pop es ds
popa
jmp oldint

;----------------
timer_minus1_v:
pusha
inc cs:timercnt1
cmp cs:timercnt1,64
jae t1_tminus1v
call fade_step_timer
t1_tminus1v:
popa
jmp oldint

;-------------------------
vecc:
mov ax,data1
mov ds,ax
mov es,ax

push es
mov es,cs:tempseg
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
mov cx,0a000h
mov es,cx
xor di,di
mov cx,16000
rep stosd
pop es

mov di,offset black_ct       ; az is data1, de mar unused
mov cx,768
mov al,3fh
rep stosb
;
mov dipos_v,offset grey_ct         ; az is unused
;call vsync
;mov dx,3c8h
;xor ax,ax
;out dx,al
;inc dx
mov al,16           ; al - redadd  
mov bx,4040h        ; bl - greenadd ; bh - blueadd
xor si,si           ; red
xor di,di           ; green
xor bp,bp           ; blue
mov cx,63
cik1_setpal_v:
push ax 
add ax,si
mov si,ax
shr ax,6
;out dx,al
push di
mov di,dipos_v
stosb
inc dipos_v
pop di
mov ax,di
add al,bl
adc ah,0
mov di,ax
shr ax,6
;out dx,al
push di
mov di,dipos_v
stosb
inc dipos_v
pop di
mov ax,bp
add al,bh
adc ah,0
mov bp,ax
shr ax,6
;out dx,al
push di
mov di,dipos_v
stosb
inc dipos_v
pop di
pop ax
loop cik1_setpal_v
;
mov di,dipos_v
mov cx,64
cik2_setpal_v:
mov al,16
;out dx,al
stosb
mov al,63
;out dx,al
;out dx,al
stosb
stosb
loop cik2_setpal_v
mov cx,129*3
xor al,al
rep stosb
;cik3_setpal_v:
;out dx,al
;loop cik3_setpal_v

;mov dx,offset timer0_v
;call set_timer_routine
;mov cs:timercnt1,0
;mov cs:timercnt3,1  ;0 ezt nem'tom hogy mer igy kell, de igy kell.. mostmar ok!
mov cs:d_perspective,1
mov cs:d_eyedist,250
mov cs:d_xeltol,160
mov cs:d_yeltol,100
mov cs:d_perszeltol,-1024*8*3/2

mov si,offset black_ct
mov di,offset grey_ct
mov cx,768
call fade_install

mov dx,offset timer_minus1_v
call set_timer_routine

mov cs:timercnt1,0
cik1_fade_v:
call calculate_v
call erase_v
call drawfaces_v
call vsync
call fade_step_user
call kirak_v
cmp cs:timercnt1,64
jb cik1_fade_v
call reset_timer_routine

mov dx,offset timer0_v
call set_timer_routine
mov cs:timercnt1,0
mov cs:timercnt3,1
;
cik0_fordul_v:
call calculate_v
call erase_v
call drawfaces_v
call vsync
call kirak_v
cmp cs:timercnt1,256; 512
jb cik0_fordul_v

cik1_fordul_v:
call calculate_v
call erase_v
call drawfaces_v
call vsync
call kirak_v
cmp cs:timercnt1,hany100sec_v0+256; 512
jb cik1_fordul_v

mov cs:timercnt3,1

cik2_fordul_v:
call calculate_v
call erase_v
call drawfaces_v
call vsync
call kirak_v
cmp cs:timercnt1,hany100sec_v0+256+112
jb cik2_fordul_v

cik3_fordul_v:
call calculate_v
call erase_v
call drawfaces_v
call vsync
call kirak_v
cmp cs:timercnt1,hany100sec_v0+256+112+128
jb cik3_fordul_v
;
cik4_fordul_v:
call calculate_v
call erase_v
call drawfaces_v
call vsync
call kirak_v
cmp cs:timercnt1,hany100sec_v0+256+112+128+112
jb cik4_fordul_v

;mov cx,35
cik5_fordul_v:
;push cx
call calculate_v2
call erase_v
call drawfaces_v2
call vsync
call kirak_v
;call move5_v
;pop cx
;loop cik5_fordul_v
cmp cs:timercnt1,hany100sec_v0+256+112+128+112+80
jb cik5_fordul_v

;mov cx,128
cik6_fordul_v:
;push cx
call calculate_v2
call erase_v
call drawfaces_v2
call vsync
call kirak_v
;call move1_v
;pop cx
;loop cik6_fordul_v
cmp cs:timercnt1,hany100sec_v0+256+112+128+112+80+hany100sec_v1
jb cik6_fordul_v
;
call reset_timer_routine
jmp realvecc
retn

calculate_v:
mov si,offset addpoints_v
mov di,offset addpoints2_v
mov bx,size2_v
mov cx,3*8
cik5_calc:
lodsw
imul bx
stosw
loop cik5_calc
;
mov cs:d_perspective,0
mov cs:d_xeltol,0
mov cs:d_yeltol,0
;
mov cx,8
mov si,offset xr0_v
mov di,offset xyz2_v
cik2_calc_v:
push cx si
call initrotate
mov si,offset points_v
mov cx,4
cik1_calc_v:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik1_calc_v
pop si cx
add si,6
loop cik2_calc_v
;
mov si,offset xyz2_v
mov di,si
mov bx,offset addpoints2_v
mov cx,8
cik6_calc:
push cx
mov cx,4
cik7_calc:
lodsw
add ax,ds:[bx]
stosw
lodsw
add ax,ds:[bx+2]
stosw
lodsw
add ax,ds:[bx+4]
stosw
add si,2
add di,2
loop cik7_calc
pop cx
add bx,6
loop cik6_calc
;
mov cs:d_perspective,1
mov cs:d_xeltol,160
mov cs:d_yeltol,100
;
mov si,offset mainxr_v
call initrotate
mov si,offset xyz2_v
mov di,offset xyz3_v
mov cx,4*8
cik8_calc:
push cx
call calc3d
add si,8
add di,8
pop cx
loop cik8_calc
;
mov di,offset faces_v
xor dx,dx
mov cx,8
cik3_calc_v:
push cx
mov si,offset faces4_v
mov cx,4*4
cik4_calc_v:
lodsw
add ax,dx
stosw
loop cik4_calc_v
pop cx
add dx,4
loop cik3_calc_v
retn

drawfaces_v:
mov bp,offset xyz3_v
mov si,offset faces_v
mov di,offset sortedfaces_v
mov cx,faces_num_v
cik1_drawfaces_v:
push cx
mov ax,faces_num_v
sub ax,cx
stosw
xor dx,dx
mov cx,4
mov ax,ds:[si]
cmp ax,ds:[si+6]
jne t1_df_v
dec cx
t1_df_v:
push cx si
cik2_drawfaces_v:
lodsw
shl ax,3
add ax,bp
mov bx,ax
add dx,ds:[bx+4]
loop cik2_drawfaces_v
pop si cx
add si,8
mov ax,dx
cwd
;idiv cx
stosw
pop cx
loop cik1_drawfaces_v
;
mov bp,offset sortedfaces_v
mov cx,faces_num_v
dec cx
cik3_drawfaces_v:
push cx
mov bx,bp
add bx,4
cik4_drawfaces_v:
mov ax,ds:[bp+2]
cmp ax,ds:[bx+2]
jge t1_drawfaces_v
mov eax,ds:[bp]
xchg eax,ds:[bx]
mov ds:[bp],eax            ; sort - maxkival
t1_drawfaces_v:
add bx,4
loop cik4_drawfaces_v
pop cx
add bp,4
loop cik3_drawfaces_v 
;
mov cx,faces_num_v
mov bp,offset sortedfaces_v
mov ax,faces_num_v
dec ax
shl ax,2
add bp,ax
cik5_drawfaces_v:
push cx
mov si,ds:[bp]
shl si,3
add si,offset faces_v
mov di,offset temp4points_v
mov bx,offset temp4colors_v
mov cx,4
cik6_drawfaces_v:
lodsw
push si
shl ax,3
add ax,offset xyz3_v
mov si,ax
movsd
lodsw
sar ax,1
add ax,32
mov es:[bx],ax
add bx,4
pop si
loop cik6_drawfaces_v
mov si,offset temp4points_v
;mov ax,ds:[bp+2]
push si bp es
mov es,cs:tempseg
mov bx,offset temp4colors_v
mov ah,3
call gouraud
pop es bp si cx
sub bp,4
loop cik5_drawfaces_v
retn

kirak_v:
push ds es
mov di,320*(100-ymax_v/2)+160-xmax_v/2
mov si,di
;mov si,256*(128-ymax_v/2)+128-xmax_v/2
mov ds,cs:tempseg
push 0a000h
pop es
mov cx,ymax_v
cik1_kirak_v:
push cx si di
mov cx,xmax_v/4
rep movsd
pop di si cx
add si,320
add di,320
loop cik1_kirak_v
pop es ds
retn

erase_v:
push es
mov di,320*(100-ymax_v/2)+160-xmax_v/2
mov es,cs:tempseg
mov cx,ymax_v
xor eax,eax
cik1_ERASE_v:
push cx di
mov cx,xmax_v/4
rep stosd
pop di cx
add di,320
loop cik1_erase_v
pop es 
retn

move1_v:
add mainxr_v,3
add mainyr_v,5
add mainzr_v,4
retn
;
move3_v:
mov si,offset xr0_v
mov di,offset xr0add_v
mov cx,8
cik1_move_v:
movsx ax,byte ptr ds:[di]
add word ptr ds:[si],ax;-4;2
movsx ax,byte ptr ds:[di+1]
add word ptr ds:[si+2],ax;4;-2
movsx ax,byte ptr ds:[di+2]
add word ptr ds:[si+4],ax;-4;2
add si,6
add di,3
loop cik1_move_v
add mainxr_v,3
add mainyr_v,5
add mainzr_v,4
retn
;
move5_v:
add mainxr_v,3
add mainyr_v,5
add mainzr_v,4
mov cx,6*3
mov si,offset xyz_okta_v2
mov di,si
cik5_move_v:
lodsw
or ax,ax
je t5_move_v
cmp ax,0
jl t6_move_v
inc ax
jmp short t5_move_v
t6_move_v:
dec ax
t5_move_v:
stosw
loop cik5_move_v
retn

calculate_v2:
mov si,offset mainxr_v
call initrotate
mov si,offset xyz_okta_v2
mov di,offset xyz2_v
mov cx,6
cik1_calc_v2:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik1_calc_v2
retn

drawfaces_v2:
mov bp,offset xyz2_v
mov si,offset faces_okta_v2
mov di,offset sortedfaces_v
mov cx,8
cik1_drawfaces_v2:
push cx
mov ax,8
sub ax,cx
stosw
xor dx,dx
mov cx,4
mov ax,ds:[si]
cmp ax,ds:[si+6]
jne t1_df_v2
dec cx
t1_df_v2:
push cx si
cik2_drawfaces_v2:
lodsw
shl ax,3
add ax,bp
mov bx,ax
add dx,ds:[bx+4]
loop cik2_drawfaces_v2
pop si cx
add si,8
mov ax,dx
cwd
idiv cx
stosw
pop cx
loop cik1_drawfaces_v2
;
mov bp,offset sortedfaces_v
mov cx,8
dec cx
cik3_drawfaces_v2:
push cx
mov bx,bp
add bx,4
cik4_drawfaces_v2:
mov ax,ds:[bp+2]
cmp ax,ds:[bx+2]
jge t1_drawfaces_v2
mov eax,ds:[bp]
xchg eax,ds:[bx]
mov ds:[bp],eax            ; sort - maxkival
t1_drawfaces_v2:
add bx,4
loop cik4_drawfaces_v2
pop cx
add bp,4
loop cik3_drawfaces_v2
;
mov cx,8
mov bp,offset sortedfaces_v+7*4
cik5_drawfaces_v2:
push cx
mov si,ds:[bp]
shl si,3
add si,offset faces_okta_v2
mov di,offset temp4points_v
mov bx,offset temp4colors_v
mov cx,4
cik6_drawfaces_v2:
lodsw
push si
shl ax,3
add ax,offset xyz2_v
mov si,ax
movsd
lodsw
sar ax,1
add ax,32
mov es:[bx],ax
add bx,4
pop si
loop cik6_drawfaces_v2
mov si,offset temp4points_v
push si bp es
mov es,cs:tempseg
mov bx,offset temp4colors_v
mov ah,3
call gouraud
pop es bp si cx
sub bp,4
loop cik5_drawfaces_v2
retn

hany100sec_v3 = 350


;-(***)-;---------------;-(***)-;
timer_v3:
pusha
push es ds
mov ax,data1
mov es,ax
mov ds,ax
;
add mainxr_v,2
add mainyr_v,3
add mainzr_v,2
inc cs:timercnt1
mov bp,cs:timercnt1
cmp bp,64
jae t0_t3v
call fade_step_timer
jmp vege_t3v
t0_t3v:
cmp bp,64+hany100sec_v3
jb vege_t3v
cmp bp,64+hany100sec_v3+80
jae t1_t3v
inc mainyr_v
inc mainzr_V
add cs:d_xeltol,3
dec cs:timercnt3
jnz t2_t3v
mov cs:timercnt3,2
dec yeltol2_v3
t2_t3v:
jmp vege_t3v
t1_t3v:
cmp bp,64+hany100sec_v3+80+30
jb vege_t3v
cmp bp,64+hany100sec_v3+80+30+130
jae t4_t3v
inc mainxr_v
inc mainyr_v
inc mainzr_v
sub cs:d_xeltol,4
dec cs:timercnt3
jnz t5_t3v
inc yeltol2_v3
mov cs:timercnt3,2
t5_t3v:
t4_t3v:
;
vege_t3v:
pop ds es
popa
jmp oldint

realvecc:
mov cs:d_xeltol,160
mov cs:d_yeltol,100

mov di,offset palette_v3
call plg_genpal

push es
mov es,cs:tempseg
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
pop es
;
mov si,offset temppal_V3
mov di,offset palette_v3
mov cx,768
call fade_install

mov dx,offset timer_V3
call set_timer_routine
mov cs:timercnt1,0
mov cs:timercnt3,1

;mov cx,64
cik1_main_v3:
;push cx
call calculate_v2
call erase_v3
call drawfaces_v3
call vsync
call fade_step_user
call kirak_v3
;call move1_v
;pop cx
;loop cik1_main_v3
cmp cs:timercnt1,64
jb cik1_main_v3           ; fade

;
;mov cx,256
cik2_main_v3:
;push cx
call calculate_v2
call erase_v3
call drawfaces_v3
call vsync
call kirak_v3
;call move1_v
;pop cx
;loop cik2_main_v3
cmp cs:timercnt1,64+hany100sec_v3
jb cik2_main_v3                               ; forog a vecc
;
;mov cx,50
cik3_main_v3:
;push cx
mov ax,yeltol2_v3
sar ax,1
add ax,100
mov cs:d_yeltol,ax
;
call calculate_v2
call erase_v3
call drawfaces_v3
call vsync
call kirak_v3
;call move1_v
;sub yeltol2_v3,1
;add cs:d_xeltol,5
;mov ax,yeltol2_v3
;sar ax,1
;add ax,100
;mov cs:d_yeltol,ax
;pop cx
;add mainxr_v,2
;add mainyr_v,3
;add mainzr_v,4
;loop cik3_main_V3                             ; elmegy jobbra
cmp cs:timercnt1,64+hany100sec_v3+80
jb cik3_main_V3
;
;call reset_timer_routine

;mov cx,20
cik1_wait_v3:
;call vsync
;loop cik1_wait_v3
cmp cs:timercnt1,64+hany100sec_v3+80+30           ; var
jb cik1_wait_v3
;
;mov cx,80
cik4_main_v3:
;push cx
mov ax,yeltol2_v3
sar ax,1
add ax,100
mov cs:d_yeltol,ax
call calculate_v2
call erase_v3
call drawfaces_v3
call vsync
call kirak_v3
;call move1_v
;sub yeltol2_v3,-1
;add cs:d_xeltol,-7
;mov ax,yeltol2_v3
;sar ax,1
;add ax,100
;mov cs:d_yeltol,ax
;pop cx
;add mainxr_v,6
;add mainyr_v,5
;add mainzr_v,4
;loop cik4_main_V3
cmp cs:timercnt1,64+hany100sec_v3+80+30+130        ; elmegy balra
jb cik4_main_v3

call reset_timer_routine
retn

kirak_v3:
push ds es
mov ds,cs:tempseg
push 0a000h
pop es
mov di,320*(100-ymax_V3/2)+160-xmax_v3/2
mov si,di
mov cx,ymax_v3
cik1_kirak_v3:
push cx si di
mov cx,xmax_v3/4
rep movsd
pop di si cx
add si,320
add di,320
loop cik1_kirak_v3
pop es ds
retn

erase_v3:
push es
mov es,cs:tempseg
mov di,320*(100-ymax_V3/2)+160-xmax_v3/2
mov cx,ymax_v3
xor eax,eax
cik1_erase_v3:
push cx di
mov cx,xmax_v3/4
rep stosd
pop di cx
add di,320
loop cik1_erase_v3
pop es
retn

setpal_v3:
mov si,offset temppal2_v3
mov cx,768
mov dx,3c8h
xor al,al
out dx,al
inc dx
rep outsb
retn

rotatepalette_v3:
mov si,offset palette_v3
add si,palofs_v3
mov cx,768
sub si,palofs_v3
mov di,offset temppal2_v3
rep movsb
mov cx,palofs_v3
mov si,offset palette_v3
rep movsb
retn

drawfaces_v3:
mov bp,offset xyz2_v
mov si,offset faces_okta_v2
mov di,offset sortedfaces_v
mov cx,8
cik1_drawfaces_v3:
push cx
mov ax,8
sub ax,cx
stosw
xor dx,dx
mov cx,4
mov ax,ds:[si]
cmp ax,ds:[si+6]
jne t1_df_v3
dec cx
t1_df_v3:
push cx si
cik2_drawfaces_v3:
lodsw
shl ax,3
add ax,bp
mov bx,ax
add dx,ds:[bx+4]
loop cik2_drawfaces_v3
pop si cx
add si,8
mov ax,dx
cwd
idiv cx
stosw
pop cx
loop cik1_drawfaces_v3
;
mov bp,offset sortedfaces_v
mov cx,8
dec cx
cik3_drawfaces_v3:
push cx
mov bx,bp
add bx,4
cik4_drawfaces_v3:
mov ax,ds:[bp+2]
cmp ax,ds:[bx+2]
jge t1_drawfaces_v3
mov eax,ds:[bp]
xchg eax,ds:[bx]
mov ds:[bp],eax            ; sort - maxkival
t1_drawfaces_v3:
add bx,4
loop cik4_drawfaces_v3
pop cx
add bp,4
loop cik3_drawfaces_v3
;
mov cx,8
mov bp,offset sortedfaces_v+7*4
cik5_drawfaces_v3:
push cx
mov si,ds:[bp]
shl si,3
add si,offset faces_okta_v2
mov di,offset temp4points_v
mov cx,4
cik6_drawfaces_v3:
lodsw
push si
shl ax,3
add ax,offset xyz2_v
mov si,ax
movsd
pop si
loop cik6_drawfaces_v3
mov si,offset temp4points_v
push si bp es
mov es,cs:tempseg
mov al,44
call fastri_vecc
pop es bp si cx
sub bp,4
loop cik5_drawfaces_v3
retn

assume ds:data1,es:data1
;-------------------------------- PART: tunnel --------------------------------
assume ds:data3,es:data3

assume ds:code
gentunnelmove_t:
push ds cs
pop ds
mov di,offset movetable_t
mov bp,offset d_sintable
mov bx,bp
mov cx,256
cik1_gtm_t:
push cx
mov si,bp
lodsd
add bp,4*8
cmp bp,offset d_sintable+4096
jb t1_gtm_t
sub bp,4096
t1_gtm_T:
mov ecx,65536/70      ; radius1
cdq
idiv ecx
stosw
mov si,bx
lodsd
add bx,4*16
cmp bx,offset d_sintable+4096
jb t2_gtm_T
sub bx,4096
t2_gtm_t:
mov ecx,65536/50       ; radius2
cdq
idiv ecx
stosw
pop cx
loop cik1_gtm_t
pop ds
retn
;----------------------
genrotateship_t:
push ds cs
pop ds
mov di,offset rotation_sh
mov bp,offset d_sintable
mov bx,offset d_sintable+(345+256)*4       ; 256=cos
mov cx,256
cik1_grm_t:
push cx
mov si,bp
lodsd
add bp,4*4                       ; i/256*2ã
cmp bp,offset d_sintable+4096
jb t1_grm_t
sub bp,4096
t1_grm_T:
mov ecx,65536/100      ; radius1
cdq
idiv ecx
stosw
mov si,bx
lodsd
add bx,4*8                      ; i/256*4ã
cmp bx,offset d_sintable+4096
jb t2_grm_T
sub bx,4096
t2_grm_t:
mov ecx,65536/100       ; radius2
cdq
idiv ecx
stosw
pop cx
loop cik1_grm_t
pop ds
retn

assume ds:data3

hany100sec_t1 = 700          ; 6sec tunnel magaban
hany100sec_t2 = 3900          ; 8sec tunnel shippel - elmenessel
elmenes_t     = 700          ; 3 sec elmegy a ship

;-( timer tunnel )-;

timer_t:
pusha
push ds es
mov ax,data3
mov ds,ax
mov es,ax
;
inc cs:timercnt1
mov bp,cs:timercnt1
cmp bp,64
jae t1_t0t_
call fade_step_timer
jmp vege_t0t
t1_t0t_:
cmp bp,64+hany100sec_t1
jb vege_t0t
cmp bp,64+hany100sec_t1+64
jae t2_t0t_
call fade_step_timer
jmp vege_t0t
t2_t0t_:
cmp bp,64*2+hany100sec_t1+hany100sec_t2
jb vege_t0t
cmp bp,64*3+hany100sec_t1+hany100sec_t2
jae vege_t0t
call fade_step_timer
;
vege_t0t:
pop es ds
popa
jmp oldint

tunnel:
mov ax,data3
mov ds,ax
mov es,ax

push es
mov ax,cs:tempseg
mov es,ax
mov cx,16000
xor eax,eax
mov di,ax
rep stosd
pop es

call gentunnelmove_t
call genrotateship_t
call initship_sh

mov di,offset pal_sh+180*3
;mov dx,3c8h
;mov al,180
;out dx,al
;inc dx
xor al,al
mov cx,12*3
rep stosb
;cik2_setpal_t:
;out dx,al
;loop cik2_setpal_t
mov cx,64
xor ax,ax
cik1_setpal_t:
xchg ah,al
;out dx,al
;out dx,al
stosb
stosb
xchg ah,al
;out dx,al
stosb
inc ax    ;add al,1
loop cik1_setpal_t
;
mov si,offset temppal_white_data3
mov di,offset pal_sh
mov cx,768
call fade_install

mov dx,offset timer_T
call set_timer_routine
mov cs:timercnt1,0
mov cs:timercnt2,0
mov cs:timercnt3,31
mov cs:timercnt4,1
mov elsofazis_t,(dist_t*tenyezo_t)+tag_t-2
mov color_t,0

cik1_main_t:
mov cs:d_xeltol,160
mov cs:d_yeltol,100
mov cs:d_eyedist,200-20
mov cs:d_perspective,1
call calculate_t
call erase_t
call drawfaces_T
cmp cs:timercnt1,64+hany100sec_t1
jb t2_t1t
cmp cs:timercnt1,64*2+hany100sec_t1+hany100sec_t2
jae t2_t1t
call shipstep_sh
t2_t1t:
call vsync
cmp cs:timercnt1,64
jae t1_t1t
call fade_step_user
t1_t1t:
cmp cs:timercnt1,64+hany100sec_t1
jb t4_t1t
cmp cs:timercnt1,64+hany100sec_t1+64
jae t4_t1t
call fade_step_user
t4_t1t:
cmp cs:timercnt1,64*2+hany100sec_t1+hany100sec_t2
jb t9_t1t
call fade_step_user
t9_t1t:

call kirak_t

cmp cs:timercnt1,64
jb t3_t1t
cmp flag_t,0
jne t3_t1t
mov flag_T,1
mov si,offset temppal_white_data3
mov di,offset pal_sh
mov cx,768
call fade_install
t3_t1t:
cmp cs:timercnt1,64*2+hany100sec_t1
jb t8_t1t
cmp flag2_t,0
jne t8_t1t
mov flag2_t,1
mov di,offset temppal_black_data3
mov si,offset pal_sh
mov cx,768
call fade_install
t8_t1t:

mov cx,cs:timercnt1
sub cx,cs:timercnt2
jcxz nodotimercik_t
;
cik_dotimer_T:
push cx
inc elsofazis_T
inc color_t
add zr_t,3
add zr_sh,-5
;
cmp cs:timercnt1,64*2+hany100sec_t1+hany100sec_t2-elmenes_t
jb t5_t1t
sub perspos2_sh,13
t5_t1t:
add perspos_sh,2
cmp perspos_sh,offset zpersmove_sh+1024
jb t7_t1t
sub perspos_sh,1024
t7_t1t:

dec cs:timercnt4
jnz t2_t0t
mov cs:timercnt4,2
;add zr_t,13/2
add movepos,4
cmp movepos,offset movetable_T+256*4
jb t1_t0t
sub movepos,256*4
t1_t0t:
add rotpos_sh,4
cmp rotpos_sh,offset rotation_sh+256*4
jb t6_t0t
sub rotpos_sh,256*4
t6_t0t:
t2_t0t:
;
dec cs:timercnt3
jnz t0_dtc
mov cs:timercnt3,32
mov color_t,0
mov elsofazis_t,(dist_t*tenyezo_t)+tag_t-2
add zr_t,13;2 ;???4    ;????
add movepos,4
cmp movepos,offset movetable_t+256*4
jb t3_t0t
sub movepos,256*4
t3_t0t:
t0_dtc:

pop cx
loop cik_dotimer_t
;
nodotimercik_T:
mov ax,cs:timercnt1
mov cs:timercnt2,ax
;
cmp cs:timercnt1,(64*3+hany100sec_t1+hany100sec_t2)
jc cik1_main_t

;----------------------
comment #
mov cx,53;41
cik0_main_t:
push cx
mov bp,cx
mov elsofazis_t,+(dist_t*tenyezo_t)+tag_t-1
mov cx,16;8; dist_T/4
mov color_t,0
cik1_main_t:
mov cs:d_xeltol,160
mov cs:d_yeltol,100
mov cs:d_perspective,1
mov cs:d_eyedist,200-20
push cx zr_t bp
call calculate_t
call erase_t
call drawfaces_t
pop bp
push bp
cmp bp,6
jb t5_main_sh
cmp bp,44
ja t5_main_sh
call shipstep_sh
t5_main_sh:
call vsync
pop bp
push bp
cmp bp,4
ja t6_main_sh
;
mov dx,3c8h
mov al,192
out dx,al
inc dx
mov cx,pallen_sh
jcxz noblackpal_sh
push cx
xor al,al
cik1_black_sh:
out dx,al
out dx,al
out dx,al
loop cik1_black_sh
pop cx
noblackpal_sh:
sub cx,64
neg cx
jcxz nowhitepal_sh
xor ax,ax
cik1_white_sh:
xchg ah,al
out dx,al
out dx,al
xchg ah,al
out dx,al
inc al
loop cik1_white_sh
nowhitepal_sh:
inc pallen_sh
;
t6_main_sh:
cmp bp,53-4
jbe t7_main_sh
call fade_step
t7_main_sh:
cmp bp,53-5
jne t8_main_sh
cmp flag_sh,1
je t8_main_sh
mov si,offset temppal_white_data3
mov di,offset pal_sh
mov cx,768
call fade_install
mov flag_sh,1
t8_main_sh:
cmp bp,41
jb t9_main_Sh
cmp bp,44
ja t9_main_sh
call fade_step
t9_main_sh:
;
call kirak_t
pop bp zr_t cx
cmp bp,17
jae t4_main_sh
sub perspos2_sh,45
t4_main_sh:
add zr_t,13;12 ;-)
add elsofazis_t,2;4
inc color_t
add movepos,4
cmp movepos,offset movetable_t+128*4
jb t1_main_t
sub movepos,128*4
t1_main_t:
loop cik1_main_t
add zr_t,13;12;*16;5*8 ;-)
add movepos,4
cmp movepos,offset movetable_t+128*4
jb t2_main_t
sub movepos,128*4
t2_main_t:
pop cx
loop cik0_main_t
#

call reset_timer_routine
retn

calculate_t:
push zr_t                 ; ??? :-)
mov bp,elsofazis_t
mov di,offset points_t
mov cx,fazis_t
mov bx,movepos
cik1_calc_t:
push cx
;
mov si,offset xr_t
call initrotate
mov ax,ds:[bx]
mov cs:d_realxeltol,ax
mov ax,ds:[bx+2]
mov cs:d_realyeltol,ax
add bx,4                             ; !! ;-]
cmp bx,offset movetable_t+128*4
jb t1_calc_t
sub bx,128*4
t1_calc_t:
;
movsx ebp,bp
mov si,offset sokszog_t
mov dword ptr cs:d_perszeltol,ebp
;
mov cx,szog_t
cik2_calc_t:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik2_calc_t
pop cx
sub bp,dist_T
add zr_t,13 ;-)
loop cik1_calc_t
pop zr_T              ; ??? :-)
retn

drawfaces_t:
mov si,offset points_t+szog_t*(fazis_t-1)*8
mov cx,fazis_t-1
mov dx,0
cik1_df_t:
push cx si dx
;
mov cx,szog_t
xor bp,bp
mov bx,offset addcolors_t
cik2_Df_t:
push cx bp bx
mov di,offset temp4points_t
mov eax,ds:[bp+si]
stosd
add bp,8
cmp bp,szog_t*8
jb t1_df_t
xor bp,bp
t1_df_t:
mov eax,ds:[bp+si]
stosd
mov eax,ds:[bp+si-szog_t*8]
stosd
sub bp,8
cmp bp,0
jnl t2_df_t
mov bp,(szog_t-1)*8
t2_df_t:
mov eax,ds:[bp+si-szog_t*8]
stosd
;
push es dx bp si
mov ax,09000h-400h
mov es,ax
mov si,offset temp4points_T
mov ax,dx
shl al,1;2
mov cl,color_t
shr cl,4 ;3;1
add al,cl       ; szin
add al,192
add al,ds:[bx]
mov ah,4
call tunnelpoly     ; m sik clipper 
pop si bp dx es
;
pop bx bp cx
inc bx
add bp,8
loop cik2_df_t
;
pop dx si cx 
inc dx
sub si,szog_t*8
loop cik1_df_t
retn

kirak_t:
push es ds
mov ax,9000h-400h
mov ds,ax
mov ax,0a000h
mov es,ax
xor di,di
mov si,di
mov cx,16000
rep movsd
pop es ds
retn

erase_t:
push es
mov ax,09000h-400h
mov es,ax
mov di,320*(100-ymax_t/2)+160-xmax_T/2
xor eax,eax
mov cx,ymax_t
cik1_erase_t:
push cx
mov cx,xmax_t/4
rep stosd
add di,320-xmax_t
pop cx
loop cik1_erase_T
pop es
retn

xmax_sh equ 120
ymax_sh equ 120

initship_sh:
mov cs:d_perspective,0
mov cs:d_xeltol,0
mov cs:d_yeltol,0
mov cs:d_perszeltol,0
mov si,offset xr_sh
call initrotate
mov si,offset xyz0_sh
mov di,offset xyz_sh
mov cx,points_num_sh
cik0_calc0_sh:
push cx
call calc3d
add si,6
add di,6
pop cx
loop cik0_calc0_sh
mov xr_sh,0
;
;call setpal_sh
;
;GenSinTable
;
mov di,offset zpersmove_sh
mov si,offset d_sintable
mov cx,512
gensin_sh:
mov eax,cs:[si]
sar eax,9        ;-128 - +128
sub ax,128
mov ds:[di],ax
add di,2
add si,2*4
loop gensin_sh
retn

shipstep_sh:
mov cs:d_perspective,1
mov cs:dword ptr d_eyedist,300
;mov cs:d_xeltol,160
;mov cs:d_yeltol,100
mov bx,perspos_sh
mov ax,ds:[bx]
add ax,perspos2_sh
cwde
mov cs:d_perszeltol,eax
;add bx,8;2
;cmp bx,offset zpersmove_sh+1024
;jb t1_shipstep_sh
;mov bx,offset zpersmove_sh
;t1_shipstep_sh:
;mov perspos_sh,bx
;
xor ax,ax
xchg ax,d_realxeltol
sar ax,1
add ax,160
mov cs:d_xeltol,ax
xor ax,ax
xchg ax,d_realyeltol
sar ax,1
add ax,100
mov cs:d_yeltol,ax

mov bp,rotpos_sh ;offset rotation_sh
mov eax,ds:[bp]
mov dword ptr xr_sh,eax
;push bp
call calculate_Sh
call presort_Sh
call drawtriangles_Sh
;add zr_sh,-17
;pop bp
;add bp,4
;cmp bp,offset rotation_sh+256*4
;jb t0_main0_sh
;mov bp,offset rotation_sh
;t0_main0_sh:
;mov rotpos_sh,bp
retn

presort_sh:
;
;Sort the faces, for perspective draw !!!
;
mov si,offset faces_Sh
mov di,offset sortedfaces_sh
xor ax,ax
mov cx,faces_num_Sh
pres1_Sh:
push ax
lodsw
mov temp1_Sh,ax
shl ax,3
mov bx,ax
mov dx,word ptr xyz2_Sh[bx+4]
lodsw
shl ax,3
mov bx,ax
add dx,word ptr xyz2_SH[bx+4]
lodsw
shl ax,3
mov bx,ax
add dx,word ptr xyz2_Sh[bx+4]
lodsw
cmp ax,temp1_Sh
je temp2_Sh
shl ax,3
mov bx,ax
add dx,word ptr xyz2_Sh[bx+4]
temp2_sh:
mov ax,dx
stosw
pop ax
stosw
inc ax
;add si,2
loop pres1_sh
.386
;
;Start sorting
;
mov di,offset sortedfaces_Sh
mov cx,faces_num_SH-1
pres2_sh:
push cx
mov si,di
add si,4
mov bx,si
pres3_sh:
lodsd
cmp ax,ds:[bx-4]
jg pres4_sh
mov bx,si
pres4_SH:
loop pres3_Sh
mov eax,ds:[di]
xchg eax,ds:[bx-4]
stosd
pop cx
loop pres2_Sh
.386
retn

drawtriangles_Sh:
mov cx,faces_num_Sh
mov si,offset sortedfaces_Sh
cik1_draw_sh:
push cx
.386
lodsd
push si
shr eax,16
;
mov bx,offset facecolors_Sh
add bx,ax
mov dl,ds:[bx]
mov coloradd,dl
;
shl ax,3
mov si,ax
;shl ax,2
;add si,ax
add si,offset faces_Sh
;
mov di,offset coords_sh
mov bp,offset colors_Sh
mov cx,4
cik2_draw_Sh:
lodsw
shl ax,3          ; hehe..
mov bx,offset xyz2_sh
add bx,ax
push si
mov si,bx
.386
;lodsd
;ror eax,16
;ror eax,16
;stosd
movsd
mov ax,ds:[si]
sar ax,2
add ax,16
mov ds:[bp],ax
add bp,4
.386
pop si
loop cik2_draw_Sh
mov si,offset coords_Sh
mov bx,offset colors_SH
push es
push 9000h-400h
pop es
mov ah,4
call gouraud
pop es
pop si
pop cx
loop cik1_draw_SH
retn

calculate_sh:
mov d_perspective,1
mov si,offset xr_SH
call initrotate
mov di,offset xyz2_SH
mov si,offset xyz_Sh
mov cx,points_num_Sh
cik1_calc_Sh:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik1_calc_Sh
retn

setpal_Sh:
mov dx,3c8h
mov si,offset pal_SH
mov cx,768
xor al,al
out dx,al
inc dx
rep outsb
retn

assume ds:data1,es:data1
;----------------------------- PART: mandelkocak ------------------------------
assume ds:data3,es:data3

hany100sec_m=1200         ; hany secundum*100

mandelkocak:
mov ax,data3
mov ds,ax
mov es,ax

mov cs:texturecoloradd,0

mov ax,cs:mandelseg
mov gs,ax
;call mandelbrots_M
;
call vsync
call setmandelpalette_M
mov cs:d_perspective,1
mov dword ptr cs:d_eyedist,200
mov cs:d_xeltol,160
mov cs:d_yeltol,100

mov dx,offset timer_m
call set_timer_routine
mov cs:timercnt1,0

call kirakbigmandel2_M

mov si,offset temppal_white_data3
mov di,offset mandelpalette_m
mov cx,768
call fade_install

cik1_wait:
cmp cs:timercnt1,300
jb cik1_wait

;mov cx,63
cik1_infade_m:
;push cx
call calculate_m
call erase_m
call drawtriangles_m
call vsync
call fade_step_user
call kirak_m
cmp cs:timercnt1,300+64
jb cik1_infade_m
;
mov di,offset temppal_black_data3
mov si,offset mandelpalette_m
mov cx,768
call fade_install
;
cik_main_M:
call calculate_M
call erase_M
call drawtriangles_m
call vsync
call kirak_M
cmp cs:timercnt1,300+64+hany100sec_m ;1400     ; 14sec
jb cik_main_m
;
cik1_kimegy_m:
call calculate_m
call erase_m
call drawtriangles_m
call vsync
call kirak_m
cmp cs:timercnt1,300+64+hany100sec_m+190
jb cik1_kimegy_m
;
cik1_outfade_m:
;call calculate_m
;call erase_m
;call drawtriangles_m
call vsync
call fade_step_user
;call kirak_m
cmp cs:timercnt1,300+64+hany100sec_m+190+64 ;1400+64
jb cik1_outfade_m

call reset_timer_routine
retn

timer_m:
pusha
push es ds
mov ax,data3
mov ds,ax
mov es,ax
;
inc cs:timercnt1
add xr_m,3
add yr_m,1
add zr_m,2
mov bp,cs:timercnt1
cmp bp,300
jb t1_tm
cmp bp,364
jae t1_tm
push bp
call fade_step_timer
pop bp
t1_tm:
cmp bp,hany100sec_m+300+64+190
jb t2_tm
cmp bp,hany100sec_m+300+64+64+190
jae t2_tm
push bp
call fade_step_timer
pop bp
t2_tm:
cmp bp,hany100sec_m+300+64
jb t4_m
cmp bp,hany100sec_m+300+64+190
jae t4_m
inc cs:d_yeltol
t4_m:

;cmp bp,164
;jae t3_tm
;call dotimer_for_kbm2_m
;t3_tm:
;
pop ds es
popa
jmp oldint

full_faces_xyz_sum_M:
mov cx,faces_num_M
mov di,offset faces_xyz_sum_m+6
xor ax,ax
cik1_full_M:
stosw
inc ax
add di,6
loop cik1_full_M
retn

drawtriangles_M:
call full_faces_xyz_sum_M
mov cx,offset faces_num_M
mov si,offset faces_M
mov bp,offset xyz2_M
mov di,offset faces_xyz_sum_M
mov dx,offset xy4_M
cik1_draw_M:
push cx di
mov di,dx
mov cx,4
mov xsum_M,0
mov ysum_M,0
mov zsum_M,0
cik2_draw_M:
lodsw
shl ax,3          ; hehe..
mov bx,bp
add bx,ax
push si
mov si,bx
movsd
lodsw
add zsum_M,ax
mov ax,ds:[si-4]
add ysum_M,ax
mov ax,ds:[si-6]
add xsum_M,ax
pop si
loop cik2_draw_M
mov dx,di
pop di
mov ax,xsum_m
stosw
mov ax,ysum_m
stosw
mov ax,zsum_M
stosw
add di,2
pop cx
loop cik1_draw_M
;
mov bp,offset xy4_m
mov cx,6                            ; ennyi l tszik
mov tempcounter_m,faces_num_M       ; 
cik3_draw_M:                        ; maximum-kiv laszt s
push cx 
mov si,offset faces_xyz_sum_M
mov dx,-32000
mov cx,tempcounter_M
cik4_draw_M:
mov ax,ds:[si+4]
add si,8
cmp ax,dx
jng t1_maxkival_M
mov dx,ax
mov maxcnt_m,cx
t1_maxkival_M:
loop cik4_draw_M
mov ax,tempcounter_m
sub ax,maxcnt_M
shl ax,3
mov bx,ax
add bx,offset faces_xyz_sum_m
mov ax,tempcounter_M
dec ax
shl ax,3
mov bp,ax
add bp,offset faces_xyz_sum_M

push dword ptr ds:[bx]
push dword ptr ds:[bx+4]
push dword ptr ds:[bp+4]
push dword ptr ds:[bp]
pop dword ptr ds:[bx]
pop dword ptr ds:[bx+4]
pop dword ptr ds:[bp+4]
pop dword ptr ds:[bp]

dec tempcounter_M
pop cx
loop cik3_draw_M

mov cx,6                    ; ennyi l tszik
mov bp,offset faces_xyz_sum_M
cik5_draw_M:
push cx gs
;mov ax,word ptr ds:[bp+4]
;shr ax,2
;add al,15
mov ax,word ptr ds:[bp+6]
push ax
shl ax,10
mov bx,gs
add ax,bx
mov gs,ax
pop ax
shl ax,4
add ax,offset xy4_M
mov bx,ax

mov si,bx
mov di,offset x1_M
movsd
movsd
movsd
movsd

call texture_M
pop gs cx
add bp,8
loop cik5_draw_M
retn

calculate_m:
mov si,offset xr_M
call initrotate
mov di,offset xyz2_M
mov si,offset xyz_M
mov cx,points_num_M
cik1_calc_M:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik1_calc_M
retn

dotimer_for_kbm2_m:
push ds
mov ax,data3
mov ds,ax
mov si,offset bmpos_m
mov cx,8
cik1_dt_m:
add word ptr ds:[si],4
add si,2
loop cik1_dt_m
pop ds
retn

kirakbigmandel2_m:
mov ax,cs:timercnt1
mov cs:timercnt2,ax
;
push ds
pop fs
push ds es
mov ds,bigmandelseg_m
push 0a000h
pop es
;mov cx,(200+224*2)/8+1
cik1_kbm_m:
;push cx
call vsync
mov cx,8
mov di,60
xor si,si
mov bp,offset bmpos_m
cik2_kbm_m:
push si di cx 
mov cx,fs:[bp]
;add word ptr fs:[bp],8
add bp,2
cmp cx,0
jle t1_kbm_m
cmp cx,200
jna t5_kbm_m
mov cx,200
t5_kbm_m:
mov ax,200
sub ax,cx
mov dx,200
mul dx
add si,ax
cik3_kbm_m:
push cx
mov cx,6
rep movsd
movsb
add si,200-25
add di,320-25
pop cx
loop cik3_kbm_m
t1_kbm_m:
pop cx di si
add si,25
add di,25
loop cik2_kbm_m
;
cli                     ;???
mov cx,cs:timercnt1
sub cx,cs:timercnt2
jcxz t1_dotimer_m
cik1_dotimer_m:
push cx
call dotimer_for_kbm2_m
pop cx
loop cik1_dotimer_m
t1_dotimer_m:
mov ax,cs:timercnt1
mov cs:timercnt2,ax
sti
;
cmp cs:timercnt1,164
jb cik1_kbm_m
pop es ds
retn

erase_M:
push ds es
mov es,cs:tempseg
mov ds,bigmandelseg_M
mov di,320*(100-ymax_M/2)+160-xmax_M/2
mov si,200*(100-ymax_M/2)+100-xmax_m/2
mov cx,ymax_M
cik2_erase_M:
push cx
mov cx,xmax_M/4
rep movsd
add di,320-xmax_M
add si,200-xmax_M
pop cx
loop cik2_erase_M
pop es ds
retn

kirak_m:
push ds es
mov ds,cs:tempseg
push 0a000h
pop es
;mov si,256*(128-ymax_M/2)+128-xmax_M/2
mov di,320*(100-ymax_M/2)+160-xmax_M/2
mov si,di
mov cx,ymax_M
cik1_kirak_M:
push cx
mov cx,xmax_M/4
rep movsd
add di,320-xmax_M
;add si,256-xmax_M
add si,320-xmax_m
pop cx
loop cik1_kirak_M
pop es ds
retn

setpal_m:
mov dx,3c8h
xor ax,ax
mov cx,64
out dx,al
inc dx
cik_setpal_M:
out dx,al
out dx,al
out dx,al
inc al
loop cik_setpal_m
retn

texture_M:
pusha
push es
mov es,cs:tempseg
mov si,offset x1_M
mov bx,offset texturemap_M
mov ah,4
call mandeltexture
pop es
popa
retn

mandelbrot_m:
mov ax,pside_M
cwde
mov ebx,eax
mov eax,side_M
cdq
idiv ebx
mov gap_m,eax
mov eax,acorner_M
;-----------
mov eax,bcorner_M
mov ycount_M,eax
movzx ecx,pside_m
push es
mov es,cs:mandelseg
xor di,di
cik1_M:
push ecx
call points_M
mov eax,acorner_M
mov xcount_M,eax
movzx ecx,pside_M
cik2_M:
push ecx
mov eax,ycount_M
mov zi_M,eax
mov eax,xcount_M
mov zr_M,eax
mov count_m,0
;
cik_internal_M:
inc count_M
mov ecx,hexa_m
mov eax,zr_M
imul eax
shrd eax,edx,20
mov tmp1_m,eax
mov eax,zi_m
imul eax
shrd eax,edx,20
mov tmp2_M,eax
mov eax,zr_M
imul dword ptr zi_M
shrd eax,edx,20
mov tmp3_M,eax
;======
mov eax,tmp1_M
sub eax,tmp2_M
add eax,xcount_M
mov zr_m,eax
mov eax,tmp3_M
add eax,eax
add eax,ycount_M
mov zi_M,eax
;======
mov eax,tmp1_M
add eax,tmp2_M
cmp eax,4*hexa_m
jg end_cik_internal_M
mov ax,maxiter_M
cmp count_m,ax
jb cik_internal_M
end_cik_internal_m:
;dec count
mov ax,count_M
shr al,1
add al,pluscolor_m
stosb
;
mov eax,gap_M
add xcount_M,eax
pop ecx
loop cik2_M
mov eax,gap_M
add ycount_M,eax
pop ecx
add di,hozzaad_M
sub di,pside_M
loop cik1_M
pop es
retn

points_M:
inc point_cnt_M
cmp point_cnt_M,pside__M/5
jb t1_point_m
mov point_cnt_M,0
mov ax,0e2eh
int 10h
t1_point_m:
retn

mandelbrots_M:
push es ds
mov ax,data3
mov es,ax
mov ds,ax

push cs:mandelseg
mov cx,6
mov si,offset mandel_descriptors_M
cik1mndl_M:
push cx si
mov di,offset side_M
movsd
movsd
movsd
call mandelbrot_M
add cs:mandelseg,400h 
add pluscolor_M,32
pop si cx
add si,12
loop cik1mndl_M

add cs:mandelseg,400h
mov ax,cs:mandelseg
mov bigmandelseg_M,ax
mov pside_M,200 
mov hozzaad_M,200
mov maxiter_M,63
mov di,offset side_M
movsd
movsd
movsd
call mandelbrot_M

pop cs:mandelseg
pop ds es
retn

setmandelpalette_m:
mov dx,3c8h
xor al,al
out dx,al
mov si,offset mandelpalette_M
mov cx,768
inc dx
rep outsb
retn

assume ds:data1,es:data1
;------------------------------- PART: goumorph -------------------------------
assume ds:data3,es:data3

hany100sec_gm = 150;600-150

timer_gm:
inc cs:timercnt1
jmp oldint

goumorph:
mov ax,data3
mov ds,ax
mov es,ax

push es
mov es,cs:tempseg
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
pop es

cld 
mov cs:d_perspective,1
mov dword ptr cs:d_eyedist,300
mov cs:d_xeltol,160-230-5
mov cs:d_yeltol,100

mov dx,3c8h
xor al,al
out dx,al
inc dx
mov si,offset pal_gm
mov cx,768
rep outsb

mov dx,offset timer_gm
call set_timer_routine
mov cs:timercnt1,0
mov cs:timercnt2,0
mov cs:timercnt3,1

;mov cx,500
cik_lsource_gm:
;push cx
call calculate_gm
call presort_gm
call erase_gm
call drawtriangles_gm
call vsync
call kirak_gm
mov cx,cs:timercnt1
sub cx,cs:timercnt2
jcxz t0_lsource_gm
cik0_lsource_gm:
push cx
add xr_gm,1
add yr_gm,2
add zr_gm,2

cmp cs:timercnt1,920/2
jb t_bejon_gm
cmp cs:timercnt1,hany100sec_gm+920/2
jb t_nobejon_gm
;
t_bejon_gm:
dec cs:timercnt3
jnz t1_nogoumo
add cs:d_xeltol,1
mov cs:timercnt3,2 ;4
t1_nogoumo:
;
;t_nobejon_gm:

mov ax,cs:d_yeltol
add ax,yeltoladd_gm
mov cs:d_yeltol,ax
cmp ax,110
jae changeadd_gm
cmp ax,80
ja nochangeadd_gm
changeadd_gm:
neg yeltoladd_gm
nochangeadd_gm:
;
t_nobejon_gm:

;test cs:timercnt3,1     ;2x olyan gyors
;jz t2_nogoumo
mov cx,8*3
mov si,offset sinpos_gm
cik00_lsource_gm:
inc byte ptr ds:[si]
inc si
loop cik00_lsource_gm
;mov cs:timercnt3,4
t2_nogoumo:
;
comment #
mov ax,cs:d_yeltol
add ax,yeltoladd_gm
mov cs:d_yeltol,ax
cmp ax,115
jae changeadd_gm
cmp ax,75           ; hogy ne logjon ki
ja nochangeadd_gm
changeadd_gm:
neg yeltoladd_gm
nochangeadd_gm:
#
;
pop cx
loop cik0_lsource_gm
t0_lsource_gm:
mov ax,cs:timercnt1
mov cs:timercnt2,ax
cmp cs:timercnt1,920+hany100sec_gm ;*2
jb cik_lsource_gm

call reset_timer_routine

push es 0a000h
pop es
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
pop es
retn

presort_gm:
;
;Sort the faces, for perspective draw !!!
;
mov si,offset faces_Gm
mov di,offset sortedfaces_GM
xor ax,ax
mov cx,faces_num_Gm
pres1_Gm:
push ax
lodsw
shl ax,3
mov bx,ax
mov dx,word ptr xyz2_4sort_Gm[bx+4]
lodsw
shl ax,3
mov bx,ax
add dx,word ptr xyz2_4sort_Gm[bx+4]
lodsw
shl ax,3
mov bx,ax
add dx,word ptr xyz2_4sort_Gm[bx+4]
lodsw
shl ax,3
mov bx,ax
add dx,word ptr xyz2_4sort_Gm[bx+4]
mov ax,dx
stosw
pop ax
stosw
inc ax
add si,2
loop pres1_Gm

;
;Start sorting
;
mov di,offset sortedfaces_Gm
mov cx,faces_num_GM-1
pres2_Gm:
push cx
mov si,di
add si,4
mov bx,si
pres3_gm:
lodsd
cmp ax,ds:[bx-4]
jg pres4_gm
mov bx,si
pres4_Gm:
loop pres3_Gm
mov eax,ds:[di]
xchg eax,ds:[bx-4]
stosd
pop cx
loop pres2_GM

retn

drawtriangles_Gm:
mov cx,faces_num_Gm
mov si,offset sortedfaces_Gm
cik1_draw_Gm:
push cx

lodsd
push si
shr eax,16
shl ax,1
mov si,ax
shl ax,2
add si,ax
add si,offset faces_Gm
;
mov di,offset coords_Gm
mov bp,offset colors_GM
mov cx,4
cik2_draw_Gm:
lodsw
shl ax,3          ; hehe..
mov bx,offset xyz2_gm
add bx,ax
push si
mov si,bx

;lodsd
;add ax,128 ;X
;ror eax,16
;add ax,100 ;Y
;ror eax,16
;stosd
movsd
mov ax,ds:[si]
;sar ax,1
add ax,65
mov ds:[bp],ax
add bp,4
pop si
loop cik2_draw_gm
mov si,offset coords_Gm
mov bx,offset colors_Gm
push es
mov es,cs:tempseg
mov ah,4
call gouraud
pop es
pop si
pop cx
loop cik1_draw_Gm
retn

calculate_gm:
;mov cs:d_perspective,1
mov si,offset xr_gm
call initrotate
mov di,offset xyz2_Gm
mov si,offset xyz_gm
mov cx,points_num_Gm
mov bp,offset sinpos_gm
mov bx,offset sinus_GM
cik1_calc_gm:
push cx bx bp
mov al,ds:[bp]
;inc byte ptr ds:[bp]
xlat
cbw
add ax,ds:[si]
mov word ptr tempcoord_gm,ax
mov al,ds:[bp+1]
;inc byte ptr ds:[bp+1]
xlat
cbw
add ax,ds:[si+2]
mov word ptr tempcoord_Gm+2,ax
mov al,ds:[bp+2]
;inc byte ptr ds:[bp+2]
xlat
cbw
add ax,ds:[si+4]
mov word ptr tempcoord_Gm+4,ax
push si
mov si,offset tempcoord_Gm
call calc3d
pop si
add si,6
add di,8
pop bp bx cx
add bp,3
loop cik1_calc_Gm
;
mov di,offset xyz2_4sort_Gm
mov si,offset xyz_Gm
mov cx,points_num_Gm
cik2_calc_GM:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik2_calc_GM
retn

erase_GM:
push ds es
mov es,cs:tempseg
xor di,di
mov cx,16000
xor eax,eax
rep stosd
pop es ds
retn

kirak_GM:
push ds es
mov ds,cs:tempseg
push 0a000h
pop es
;mov di,(320-xmax_gm)/2+(100-ymax_gm/2)*320
mov ax,cs:d_yeltol
sub ax,ymax_gm/2
cmp ax,0
jge t1_kgm
xor ax,ax
t1_kgm:
cmp ax,200-ymax_gm
jb t2_kgm
mov ax,200-ymax_gm-1
t2_kgm:
xchg ah,al
mov di,ax
shr ax,2
add di,ax
mov si,di
mov cx,320/4*ymax_gm
rep movsd
pop es ds
retn

assume ds:data1,es:data1
;------------------------------ PART: julimorph -------------------------------
assume ds:data3,es:data3

timer_jc:
;pusha
;push ds es
;mov ax,data3
;mov ds,ax
;mov es,ax
;
inc cs:timercnt1
;
;pop es ds
;popa
jmp oldint

julimorph:
mov ax,data3
mov ds,ax
mov es,ax

push es 0a000h
pop es
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
pop es

mov dx,3c8h
xor al,al
out dx,al
inc dx
mov cx,16*3*6
mov si,offset colors_jc
rep outsb

mov ax,cs:mandelseg
mov gs,ax                ; unused

mov cs:d_perspective,1
mov cs:d_eyedist,200
mov cs:d_xeltol,-35;70;160     ; megant
mov cs:d_yeltol,100
mov cs:d_perszeltol,-50

mov dx,offset timer_jc
call set_timer_routine
mov cs:timercnt1,0
mov cs:timercnt2,0
mov cs:timercnt3,1

cik1_main_jc:
call julistep_jc
call calculate_Jc
call erase_Jc
call drawfaces_jc
call vsync
call kirak_jc
mov cx,cs:timercnt1
sub cx,cs:timercnt2
jcxz t1_main_jc
cik1_time_jc:
add xr_jc,1
add yr_jc,2
add zr_jc,2
dec cs:timercnt3
jnz t2_main_jc
inc xadd_juli
dec yadd_juli
inc cs:d_xeltol
mov cs:timercnt3,3
;
mov bp,cs:timercnt1
cmp bp,250
jae t1_mjc
inc cs:d_yeltol
inc cs:d_perszeltol
jmp tn_mjc
t1_mjc:
cmp bp,250+380
jae t2_mjc
dec cs:d_yeltol
dec cs:d_perszeltol
jmp tn_mjc
t2_mjc:
cmp bp,250+380+220
jae t3_mjc
inc cs:d_yeltol
inc cs:d_perszeltol
jmp tn_mjc
t3_mjc:
cmp bp,250+380+220+350 ;350
jae t4_mjc
dec cs:d_yeltol
dec cs:d_perszeltol
jmp tn_mjc
t4_mjc:
cmp bp,250+380+220+350+200  ; a 200  ma' kamu
jae t5_mjc
inc cs:d_yeltol
inc cs:d_perszeltol
jmp tn_mjc
t5_mjc:
dec cs:d_perszeltol
tn_mjc:
;
t2_main_jc:
loop cik1_time_jc
t1_main_jc:
mov ax,cs:timercnt1
mov cs:timercnt2,ax
cmp cs:timercnt1,390*3
jb cik1_main_jc

call reset_timer_routine
mov cs:texturecoloradd,0
mov cs:d_perszeltol,0
retn

drawfaces_Jc:
mov di,offset sortedfaces_Jc
mov si,offset faces_Jc
mov cx,6
cik1_df_Jc:
push cx
mov ax,6
sub ax,cx
stosw
mov cx,4
xor dx,dx
cik2_df_jc:
lodsw
shl ax,3
add ax,offset xyz2_Jc
mov bx,ax
add dx,ds:[bx+4]
loop cik2_df_jc
mov ax,dx
stosw
pop cx
loop cik1_df_jc
;
mov bp,offset sortedfaces_Jc
mov cx,5
cik3_df_jc:
push cx
mov bx,bp
add bx,4
cik4_df_jc:
mov ax,ds:[bp+2]
cmp ax,ds:[bx+2]
jle t1_df_jc
mov eax,ds:[bx]
xchg eax,ds:[bp]
mov ds:[bx],eax
t1_df_jc:
add bx,4
loop cik4_df_jc
pop cx
add bp,4
loop cik3_df_jc
;
mov cx,3
mov si,offset sortedfaces_Jc+3*4
cik5_df_jc:
push cx si
lodsw
shl ax,3
push ax
shl ax,1
mov cs:texturecoloradd,al
pop ax
add ax,offset faces_jc
mov bx,ax
mov di,offset temp4points_jc
mov cx,4
cik6_df_jc:
mov si,ds:[bx]
shl si,3
add si,offset xyz2_Jc
movsd
add bx,2
loop cik6_df_jc
mov si,offset temp4points_Jc
mov bx,offset texturemap_Jc
push es 9000h-400h
pop es
mov ah,4
call texture
pop es si cx
add si,4
loop cik5_df_jc
retn

calculate_Jc:
mov si,offset xr_Jc
call initrotate
mov si,offset points_Jc
mov cx,8
mov di,offset xyz2_JC
cik1_calc_JC:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik1_calc_Jc
retn

erase_jc:
push es 9000h-400h
pop es
mov di,160-xmax_jc/2+320*(100-ymax_jc/2)
mov cx,ymax_jc
xor eax,eax
cik1_erase_Jc:
push cx
mov cx,xmax_jc/4
rep stosd
add di,320-xmax_jc
pop cx
loop cik1_erase_Jc
pop es
retn

kirak_Jc:
push es ds 9000h-400h 0a000h
pop es ds
;mov si,128-xmax_jc/2+256*(128-ymax_jc/2)
mov di,160-xmax_jc/2+320*(100-ymax_jc/2)
mov si,di
mov cx,ymax_jc
cik1_kirak_Jc:
push cx
mov cx,xmax_jc/4
rep movsd
add di,320-xmax_jc
add si,320-xmax_jc
pop cx
loop cik1_kirak_Jc
pop ds es
retn

julistep_jc:
mov di,offset mem_Jc
mov cx,32;50;64
mov bp,-32*3;-50*2;-64*2
cik1_julia:
push cx 
mov cx,64;100;128
mov bx,-32*3;-50*2;-64*2
cik2_julia:
push cx bx bp
xor cx,cx
cik3_julia:
inc cx
mov ax,bx
imul bp
shrd ax,dx,5
add ax,yadd_juli
mov si,ax
mov ax,bx
imul ax
shrd ax,dx,6
mov bx,ax
mov ax,bp
mov bp,si
imul ax
shrd ax,dx,6
mov si,bx
add si,ax
sub bx,ax
add bx,xadd_juli
cmp si,100h
jae t2_julia
cmp cl,15
jb cik3_julia
t2_julia:
mov al,cl
stosb
pop bp bx cx
add bx,3
loop cik2_julia
pop cx
add bp,3
loop cik1_julia
call kirak_juli
;inc xadd_juli
;dec yadd_juli
retn

kirak_juli:
push es gs
pop es 
xor di,di
mov si,offset mem_JC
mov cx,32;50;64
kirak1_JC:
push cx
mov cx,16;25;32
rep movsd
pop cx
add di,128-64;100
loop kirak1_Jc
add si,2
mov cx,32;50;64
kirak2_Jc:
push cx
mov cx,32;50;64
kirak3_JC:
sub si,4
lodsw
xchg ah,al
stosw
loop kirak3_JC
pop cx
add di,128-64;100
loop kirak2_Jc
pop es
retn

assume ds:data1,es:data1
;------------------------- PART: plasmacube & torus ---------------------------
assume ds:data2,es:data2

hany100sec_pc = 1800-130-20       ; secundum*100 ; current: 11sec

assume ds:code
genmove_pc:
push ds cs
pop ds
mov di,offset move_pc
mov si,offset d_sintable
mov cx,256
cik1_genmove_pc:
lodsd
add si,4
mov ebx,65536/90
cdq
idiv ebx
mov bx,ax
mov ax,125 ; radius=75
sub ax,bx
stosw
loop cik1_genmove_pc
pop ds
retn
assume ds:data2

plasmacube:
mov ax,data2
mov ds,ax
mov es,ax

call genmove_pc

push es 0a000h
pop es
xor eax,eax
mov di,ax
mov cx,16000
rep stosd
pop es

call setpal_pl

mov ax,cs:mandelseg
mov gs,ax              ; unused

mov cs:d_perspective,1
mov cs:d_eyedist,200
mov cs:d_xeltol,320+100-5
mov cs:d_yeltol,100

mov xmax2_pl,100
mov ymax2_pl,100
mov bufferpos_pl,0
mov bufferseg_pl,gs
mov lineadd_pl,128-100

mov dx,offset timer_pc
call set_timer_routine
mov cs:timercnt1,0
mov cs:timercnt2,1

cik1_main_pc:
mov si,movepos_pc
mov ax,ds:[si]
mov cs:d_yeltol,ax
;
call plasmastep
call calculate_pc
call erase_pc
call drawfaces_pc
call vsync
call kirak_pc
cmp cs:timercnt1,hany100sec_pc
jb cik1_main_pc

call reset_timer_routine
retn

timer_pc:
pusha
push ds es
mov ax,data2
mov ds,ax
mov es,ax
;
inc cs:timercnt1
dec cs:timercnt2
jnz t1_tpc
call indexes_pl
;
dec cs:d_xeltol
cmp flag_pc,1
jne tx_pc
add cs:d_xeltol,2
tx_pc:
;
mov cs:timercnt2,2
t1_tpc:
add xr_pc,1
add yr_pc,2
add zr_pc,1
add movepos_pc,4
cmp movepos_pc,offset move_pc+256*2
jb t2x
sub movepos_pc,256*2
t2x:
;
cmp cs:timercnt1,700-10
jb t1_xx_pc
cmp flag_pc,0
jne t1_xx_pc
inc flag_pc
t1_xx_pc:
cmp cs:timercnt1,1030-10
jb t2_xx_pc
cmp flag_pc,1
jne t2_xx_pc
inc flag_pc
t2_xx_pc:
;
pop es ds
popa
jmp oldint

drawfaces_pc:
mov di,offset sortedfaces_pc
mov si,offset faces_pc
mov cx,faces_num_pc
cik1_df_pc:
push cx
mov ax,faces_num_pc
sub ax,cx
stosw
mov cx,4
mov ax,ds:[si]
cmp ax,ds:[si+6]
jne t1x
dec cx
t1x:
push cx
xor dx,dx
cik2_df_pc:
lodsw
shl ax,3
add ax,offset xyz2_pc
mov bx,ax
add dx,ds:[bx+4]
loop cik2_df_pc
mov ax,dx
pop cx
cwd
idiv cx
stosw
pop cx
loop cik1_df_pc
;
mov bp,offset sortedfaces_pc
mov cx,faces_num_pc-1
cik3_df_pc:
push cx
mov bx,bp
add bx,4
cik4_df_pc:
mov ax,ds:[bp+2]
cmp ax,ds:[bx+2]
jle t1_df_pc
mov eax,ds:[bx]
xchg eax,ds:[bp]
mov ds:[bx],eax
t1_df_pc:
add bx,4
loop cik4_df_pc
pop cx
add bp,4
loop cik3_df_pc
;
mov cx,36     ;-(*)-;
mov si,offset sortedfaces_pc+(faces_num_pc-36)*4
cik5_df_pc:
push cx si
lodsw
shl ax,3
push ax
shl ax,1
mov cs:texturecoloradd,al
pop ax
add ax,offset faces_pc
mov bx,ax
mov di,offset temp4points_pc
mov cx,4
cik6_df_pc:
mov si,ds:[bx]
shl si,3
add si,offset xyz2_pc
movsd
add bx,2
loop cik6_df_pc
mov si,offset temp4points_pc
mov bx,offset texturemap_pc
push es 9000h-400h
pop es
mov ah,4
call texture
pop es si cx
add si,4
loop cik5_df_pc
retn

calculate_pc:
mov si,offset xr_pc
call initrotate
mov si,offset points_pc
mov cx,points_num_pc
mov di,offset xyz2_pc
cik1_calc_pc:
push cx
call calc3d
add si,6
add di,8
pop cx
loop cik1_calc_pc
retn

erase_pc:
push es 9000h-400h
pop es
mov di,160-xmax_pc/2+320*(100-ymax_pc/2)
mov cx,ymax_pc
xor eax,eax
cik1_erase_pc:
push cx
mov cx,xmax_pc/4
rep stosd
add di,320-xmax_pc
pop cx
loop cik1_erase_pc
pop es
retn

kirak_pc:
push es ds 9000h-400h 0a000h
pop es ds
;mov si,128-xmax_pc/2+256*(128-ymax_pc/2)
mov di,160-xmax_pc/2+320*(100-ymax_pc/2)
mov si,di
mov cx,ymax_pc
cik1_kirak_pc:
push cx
mov cx,xmax_pc/4
rep movsd
add di,320-xmax_pc
add si,320-xmax_pc
pop cx
loop cik1_kirak_pc
pop ds es
retn

assume ds:data1,es:data1
code ends

music segment para use16
include music.inc
musend label byte
music ends

;-------------------------------- STACK SEGMENT -------------------------------
verem segment stack 'stack' use16
dw 512 dup (?)
verem ends
;------------------------------------------------------------------------------
end start
