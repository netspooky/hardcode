Title The 4k.Adlib.Player, PNK.
.486
.487
.model tiny
assume cs:code,ds:code
code segment use16
org 100h
start:

nbr_ecrans   equ 7
tune_speed   equ 4
_69_nbr_pts  equ 21
_bl_nbr_pts  equ 17*33
_69_ofs_pts  equ 0
_69_ofs_face equ _69_nbr_pts*20
_bl_ofs_pts  equ _69_ofs_face+(_69_nbr_pts-2)*6+2
_bl_ofs_face equ _bl_ofs_pts+20*_bl_nbr_pts
_te_ofs_pts  equ _bl_ofs_face+2+6*_bl_nbr_pts*2

_nbr_toz     equ 127
_nbr_bras    equ 35
_long_bras   equ 73
_tun_long    equ 10
_tun_circ    equ 8
_tun_dist    equ 15

include _macros.inc

  _init
  _prep_69
;  _calc_tun_rond
  _palette
  xor dx,dx
  fldln2
  mov es,[lyu1]
  call _init_lyu
  fldpi
  fchs
  mov es,[lyu2]
  lea si,float_sin
  mov ch,255
  call _init_lyu_x
  fldln2
  mov es,[lyu3]
  mov ch,69
  mov dl,128
  call _init_lyu_si
  _genere_blob
  _init_zik

  _grande_boucle:
    _teste_touche

    mov es,[ecran]
    call _efface_seg

    mov si,[zik_pat]
    shl si,1
    mov si,ds:[si+offset ecr_effets]
    or si,si
    je _fin
;      mov ax,4c00h
;      int 21h
  _gb_pas_fin:
    cmp [anc_ecran],si
    je _gd_boucle_suite
      mov [anc_ecran],si
      mov di,9
      _pt_boucle:
        mov byte ptr ds:[di+offset temps],cl
        mov [obj_rotb],cl
        dec di
      jns _pt_boucle
      mov [dec_tmp],2300
  _gd_boucle_suite:
    call si
    call _affiche_chaine

    cmp byte ptr [effet_note],0
    je _ecran_pas_blanc
      mov ax,0f0fh
      call _efface_seg_x
  _ecran_pas_blanc:
     call _affiche
  _ecran_blanc:
jmp _grande_boucle

;***** Proc‚dures **************

include _adlib.inc
include _3d.inc
include _effet.inc
include _ecran.inc

;***** Segment des donn‚es *****

_txt_effet2 dw offset e2t1, offset e2t1, offset e2t2, offset e2t3
            dw offset e2t4, offset e2t5, offset e2t6, offset e2t7, offset e2t8
e2t1	db 017h,4,   "Udev"
e2t2	db 016h,8, "presents"
e2t3	db 017h,3,   "sex"
e2t4	db 016h,7, "because"
e2t5	db 016h,7, "we know"
e2t6	db 017h,4,   "what"
e2t7	db 018h,2,    "we"
e2t8	db 017h,4,   "code"

txt1    db 66h,16,'ool people think'
        db 0a4h,18,'ex all six minutes'
txt2    db 23h,3,'ode'
        db 25h,5,'Pinky'
        db 0eah,4,'usic'
        db 0edh,3,'Wis'
txt_xst db 03dh,2,'st'
txt_sat db 0dch,4,'atan'
txt_rem db 0b9h,11,'Little R‚my'
txt_fin db 56h,19,'aiting for the next'
        db 0a6h,10,'ix minutes'

_toz_vert db 24,60,60,24,4,8,16,32,16,8,4,8,16,16,8,4


effet_note_tmp db 7,63

Zik      db "PPatch zik.pnk",0
         dd 1
         dw 2509
         db 2509-($-offset zik) dup(?)

;**** Constantes ***************

ecr_effets  dw offset _effet1,offset _effet1,offset _effet2, offset _effet3
            dw offset _effet4,offset _effet4,offset _effet5, offset _effet6
            dw offset _effet6,offset _effet6,offset _effet6
            dw offset _effet8,offset _effet10,offset _effet10,offset _effet11
	    dw offset _effet11, offset _effet9, 0

mot_fpu1    dw 047fh
val_63      dw 63
val_59      db 59
val_512     dw 512
val_n128    dw -128
val_32      dw 32
val_8192    dw 8192
float_sin   dd 0.02454361
lyu_dxy0    dd 0.0112969
obj_traz    dw 128 ; 58
obj_lum     db 128

_blob_info  dw _bl_ofs_pts, offset _blob, _bl_nbr_pts, _bl_ofs_face
_69_info    dw _69_ofs_pts, offset _69_pts1, _69_nbr_pts, _69_ofs_face

_69         db 141,57
            db 140,45
            db 160,55
            db 160,45
            db 180,50
            db 180,40
            db 200,47
            db 210,40
            db 220,50
            db 225,40                  ;10
            db 230,52
            db 234,41
            db 244,50
            db 240,30
            db 249,35
            db 230,15
            db 255,15
            db 190,20
            db 190,10
            db 188,32
            db 175,35

_test dw 32,0
      dw 8 dup(50)
      dw 8,120

;*** Variables nulles **********

anc_1c     dd ?

deb_zero label byte

zik_pos    db ?
zik_pat    dw ?
tmp_play   db ?
zik_ofs    dw ?

temps      dw ?
note       db 8 dup(?)
effet_note db 8 dup(?)
dec_tmp1   db ?

dec_tmp    dw ?                                   ;2700
anc_effet  db ?
anc_ecran  dw ?

obj_rota   db ?
obj_rotb   db ?
obj_trax   dw ?
obj_tray   dw ?

effet_pos  dw ?
vect       dw 4 dup (?)

ecran      dw ?
effet      dw ?
zbuffer    dw ?
obj_3d     dw ?
lyu1       dw ?
lyu2       dw ?
lyu3       dw ?

nbr_tun    dw ?
nbr_hasard dw ?
fonte_ofs  dw ?
fonte_seg  dw ?

;***** Variables pour render gouraud *****
pts0_posc_bis dd ?
pts0_posz_bis dd ?
pts0_posy_bis dd ?
pts0_posx_bis dd ?
pts_bisc    dw ?
pts_bisz    dw ?
pts_bisy    dw ?
pts_bisx    dw ?
pts0_posc   dd ?
pts0_posz   dd ?
pts0_posy   dd ?
pts0_posx   dd ?
pts1_posc   dd ?
pts1_posz   dd ?
pts1_posy   dd ?
pts1_posx   dd ?
pts2_posc   dd ?
pts2_posz   dd ?
pts2_posy   dd ?
pts2_posx   dd ?
d0_posc     dd ?
d0_posz     dd ?
d0_posy     dd ?
d0_posx     dd ?
d1_posc     dd ?
d1_posz     dd ?
d1_posy     dd ?
d1_posx     dd ?
dd_posc     dd ?
dd_posz     dd ?
dd_posy     dd ?
dd_posx     dd ?

var_copro  dw ?
sinus      dd 64 dup(?)
cosinus    dd 256 dup (?)

_69_pts1   db 2+3*_69_nbr_pts dup(?)

_tozoide   db 5 dup (?)
fin_zero label byte
           db _nbr_toz*10 dup (?)
_blob      db 2+3*_bl_nbr_pts dup(?)
_tent      db 2+3*_long_bras*_nbr_bras dup(?)
_tunnel    db 2+3*_tun_circ dup (?)


code ends
end start
