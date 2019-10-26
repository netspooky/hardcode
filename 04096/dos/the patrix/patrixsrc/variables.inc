;***
;* Variables
;***

;rotozoom.inc


modo_act dd 1
tiempo dd 1
init_tiempo dd 1
dec_init_tiempo dd 1
zoominc real4 0.01

PROPr   real4 0.50 ;240.0/320.0

r60   real4 60.0
r80   real4 80.0
r86   real4 86.0
rm160  real4 -160.0
rm120  real4 -120.0
r100   real4 100.0
r200   real4 200.0
ZooM  real4 0.05
r256   real4 256.0
r4     real4 4.0
r5     real4 5.0
XCenter dd -68
YCenter dd -(200-(153))

f04  real4 0.4
f004 real4 0.04
f003 real4 0.03

fincrement real4 0.001
zi2 real4 1.0

fi  dd 0

m      real4 0.0

zcam dd 0

_t_x dd 0
_t_y dd 0
ti dd 0

tmpint dd 0
tmpint2 dd 0
tmpx0  dd 0
tmpx1  dd 0
tmpy0  dd 0

efecto dd 0
q_bocadillo dd 0
textura_efecto dd 0
degradado dd 0




temp0 dq 0
temp1 dq 0
temp2 dq 0
temp3 dq 0
MapX   dd 0
MapY   dd 0
Vx     dd 0
Vy     dd 0
frame  dd 0
ttt    dd 0


;intro.inc
num_reservas EQU (offset finreservas - offset reservas)/4
reservas LABEL DWORD

Sphere1 dd 0
cartman_head dd 0
cartman_body dd 0
kenny   dd 0
kenny_copy dd 0
scratch_text dd 0
scratch_text2 dd 0
bocadillo dd 0
Video_Kenny   dd 0
Video_Cartman dd 0
VBuffADDR2 dd 0
VBuffADDR dd 0

finreservas LABEL DWORD

;textures2.inc

;interpol.inc
x dd 0
y dd 0
_u dd 64*45 dup (0)
_v dd 64*45 dup (0)
u dd 0
v dd 0
u_ar dd 0
u_ab dd 0
v_ar dd 0
v_ab dd 0
d_u_ar dd 0
d_u_ab dd 0
d_v_ar dd 0
d_v_ab dd 0
d_u_aa dd 0
d_v_aa dd 0
intx    dd 0
inty    dd 0
xoffset dd 0
yoffset dd 0
yoff dd 0
xoff dd 0


;
      fangle real4 0.0
;intro.asm

      yt      dd 0
      xt      dd 0
      tamt dd 0
      dat  dd 0
      dat2 dd 0
      prop dd 0
      a    dd 0
      b    dd 0

;tunnel.inc
;parametros
cosAA real4 0.0
cosAB real4 0.0
cosAC real4 0.0
sinAA real4 0.0
sinAB real4 0.0
sinAC real4 0.0
t_x   dd    0
t_y   dd    0
xorig real4 0.0
yorig real4 0.0
zorig real4 0.0

__u dd 0  ;salida  24bits integer | 8 bits decimal
__v dd 0   
__z dd 0

;
;variables internas

xd       real4 0.0
yd       real4 0.0
xdir     real4 0.0
ydir     real4 0.0
zdir     real4 0.0
_a        real4 0.0
_b        real4 0.0
_c        real4 0.0
delta    real4 0.0
t        real4 0.0
t1       real4 0.0
t2       real4 0.0
_intx     real4 0.0
_inty     real4 0.0
_intz     real4 0.0
zd       real4 128.0
zd0     real4 128.0
Radio    real4 1000.0


_temp1    real4 0.2;

t200    dd 200
t160    dd 160
t100    dd 100
t256    dd 256

f256_entre_pi real4 162.975   ;2*256/PI
t4      dd 4
t5      dd 5
_t2      dd 2


;intro.asm


      fanginc real4 0.2
      fballinc real4 2.0944 ;2*pi/3  
      fdist real4 10.0                
      fdist_ real4 10.0
      fdist_ang real4 0.1333
