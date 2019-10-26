Title 3D coord. sph‚rique pour 4k. N‚cessite copro!

;INFOS: Moteur 3D entier 615 octets
;       Rotations+ Perspective 99 octets
;       Eclairage+ normales 189 octets
;       Render Gouraud  305 octets

;     _fpu_to_ax
;     _rotate_pts
;     _lumiere_pts
;     _render_gouraud

;pts1 et faces sont pr‚ced‚s d'un mot.
_pts1 struc
  pts1_a db ?
  pts1_b db ?
  pts1_r db ?
_pts1 ends

_pts2 struc
  pts2_x    dw ?
  pts2_y    dw ?
  pts2_z    dw ?
  pts2_lum  dw ?
  pts2_norm dd 3 dup(?)
_pts2 ends

_faces struc
  faces_pt0 dw ?
  faces_pt1 dw ?
  faces_pt2 dw ?
_faces ends

;REM: Envoie de st(0) dans AX. Il faut tjs jeter les piles usag‚es!
_fpu_to_ax_63 proc near
  fimul word ptr [val_63]
_fpu_to_ax_abs:
  fabs
_fpu_to_ax:
  fistp [var_copro]
  mov ax,word ptr [var_copro]
  ret
_fpu_to_ax_63 endp

;IN : DS:SI = liste des pts1
;     ES:DI = liste des pts2
;Z =  R * cos B * sin A + tZ
;X = (R * sin B        +Tx) * 64 / Z
;Y = (R * cos B * cos A+Ty) * 64 / Z
_rotate_pts proc near
  fninit
  lodsw
  xchg ax,cx
  _rot_boucle:
    lodsw
    xor bx,bx
    inc si
    xchg bx,[si]
    fild word ptr [si-1]                       ;R
    xchg bx,[si]
    add ax,word ptr ds:[obj_rota]
    xchg ah,bl
    xchg ax,bp
    shl bx,2                                      ;B
    shl bp,2                                      ;A

    fld st(0)                                     ;R
    fmul [cosinus+bx]
    fld st(0)                                     ;R * cos(B)
    fmul [sinus+bp]
    fiadd ds:[obj_traz]
    fist word ptr es:[di+4]
    fidiv word ptr [val_63]

    fxch
    fmul [cosinus+bp]
    fiadd [obj_tray]
    fdiv st(0),st(1)
    fistp word ptr es:[di+2]
    add word ptr es:[di+2],80h

    fxch
    fmul [sinus+bx]
    fiadd [obj_trax]
    fdivrp st(1)
    call _fpu_to_ax
    add ax,80h
    stosw
  _rotate_suite1:
    add di,18
  loop _rot_boucle
  ret
_rotate_pts endp

;IN : Le vecteur dans le FPU
;OUT: Le vecteur normalis‚.
_normalise proc near
  fld st(2)
  fmul st(0),st(0)
  fld st(2)
  fmul st(0),st(0)
  faddp
  fld st(1)
  fmul st(0),st(0)
  faddp
  fsqrt
  fdiv st(3),st(0)
  fdiv st(2),st(0)
  fdivp st(1),st(0)
  ret
_normalise endp

;IN : ES:BX = pts0
;     ES:SI = adresse de pts1
;OUT: pts1-pts0 dans le FPU
_dif_pts macro
  mov dx,2
  _dif_pts_boucle:
    lodsw_es
    xchg ax,bp
    xor di,di
    _dif_pts_boucle2:
      fild word ptr es:[bx+di]
      fisub word ptr es:[bp+di]
      inc di
      inc di
      cmp di,6
    jne _dif_pts_boucle2
    dec dx
  jnz _dif_pts_boucle
endm

_charge_norme proc near
  fld es:[di.pts2_norm]
  fld es:[di.pts2_norm+4]
  fld es:[di.pts2_norm+8]
  ret
_charge_norme endp

;IN : ES:DI = liste des pts2
;     ES:SI = liste des faces
;     CX    = nombre de pts
;REM: Calcul la normale aux faces et ensuite aux points.
_lumiere_pts proc near
  push di cx
  xor ax,ax
  _lum_boucle1:
    add di,8
    stosw
    stosw
    stosw
    stosw
    stosw
    stosw
  loop _lum_boucle1

  lodsw_es
  xchg ax,cx
  _lum_face_boucle:
    fninit

    push si
    lodsw_es
    xchg ax,bx
    _dif_pts                                      ;2 Vect dans la pile

    fld st(4)
    fmul st(0),st(3)
    fld st(6)
    fmul st(0),st(3)
    fsubp
    fxch st(6)

    fmul st(0),st(1)
    fxch st(3)
    fmul st,st(4)
    fsubp st(3)

    fmulp st(4),st
    fmulp st(2),st
    fxch st(2)
    fsubp st(1),st(0)

    call _normalise
    mov dl,3
    pop si
    _lum_pts_boucle:
      lodsw_es
      xchg ax,di
      call _charge_norme
      mov bx,8
      _lum_pts_boucle3:
        fadd st(0),st(3)
        fstp es:[di.pts2_norm+bx]
        sub bl,4
      jns _lum_pts_boucle3
      dec dx
    jnz _lum_pts_boucle
  loop _lum_face_boucle

  pop cx di
  _lum_pts_boucle2:
    fninit
    call _charge_norme
    call _normalise
    fxch st(2)
    fimul word ptr ds:[val_59]
    call _fpu_to_ax_abs
    mov es:[di.pts2_lum],ax
    add di,20
  loop _lum_pts_boucle2
  ret
_lumiere_pts endp

;IN : Faces dans ES:SI
;OUT: Trie les faces en Y et envoie dans DS:[pts?_pos?] en 4bytes
;REM: On peut encore optimiser!!!
_charge_3d_mac macro

_charge_3d_debut:
  mov cx,4
  mov bx,cx
  _ch_3d_boucle:
    mov di,es:[si+bx]
    mov ax,es:[di.pts2_y]
    xor dx,dx                          ;DX=Compteur, AX=Hauteur
    mov bp,cx
    _ch_3d_boucle2:
      cmp bx,bp
      je _ch_3d_b2_passe
        mov di,es:[si+bp]
        cmp ax,es:[di.pts2_y]
        jne _ch_pas_egal
          inc es:[di.pts2_y]
          jmp _charge_3d_debut
    _ch_pas_egal:
      jl _ch_3d_b2_passe
        inc dx
    _ch_3d_b2_passe:
      dec bp
      dec bp
    jns _ch_3d_boucle2                 ;DX=PositionY, BX=points

    mov di,es:[si+bx]
    shl dx,cl
    mov bp,dx
    push cx
    _ch_3d_boucle3:
      fild word ptr es:[di]
      fstp dword ptr ds:[bp+pts0_posx]
      inc di
      inc di
      sub bp,4
    loop _ch_3d_boucle3
    pop cx

    dec bx
    dec bx
  jns _ch_3d_boucle
  add si,6
endm

;IN : DS:BX = Source1
;     DS:BP = Source2
;     DS:DI = Destination de la diff‚rence des deux sur facteurs
;     FPU   : facteur de division
_calc_dif_st0 proc near
  lea di,d0_posc
  lea bp,[bx+16]

_calc_dif_st01:
  fld dword ptr ds:[bp+8]
  fsub dword ptr ds:[bx+8]
  fld st(0)

_calc_dif:
  mov cx,4
  mov ax,cx
  _calc_dif_boucle:
    fld dword ptr ds:[bp]
    fsub dword ptr ds:[bx]
    fdiv st(0),st(1)
    fstp dword ptr ds:[di]
    add di,ax
    add bp,ax
    add bx,ax
  loop _calc_dif_boucle
  fstp st(0)
  ret
_calc_dif_st0 endp

;IN :FPU : st(2)=Haut, st(1)=DDX, st(0)=Long horz
_dessine_triangle proc near
  _gour_lig:
    xor dx,dx
    mov bx,12
    _gour_boucle11:
      fld ds:[pts0_posc+bx]
      fadd ds:[d1_posc+bx]
      fst ds:[pts0_posc_bis+bx]
      fstp ds:[pts0_posc+bx]
      sub bx,4
    jns _gour_boucle11

    fadd st(0),st(1)
    fld st(0)
    fabs
    fldl2e
    faddp
    call _fpu_to_ax
    xchg ax,cx
    _gour_col:
      mov bx,6
      _gour_boucle2:
        mov di,bx
        fld ds:[pts0_posc_bis+di+bx]
        fist ds:[pts_bisc+bx]
        fadd ds:[dd_posc+di+bx]
        fstp ds:[pts0_posc_bis+di+bx]
        dec bx
        dec bx
      jns _gour_boucle2

      mov eax,dword ptr ds:[pts_bisy]
      xchg ah,al
      rol eax,8
      or ax,ax
      jne _point_pas_visible

      bswap eax
      xchg ax,di

      mov al,byte ptr ds:[pts_bisc]
      test al,255-63
      jne _point_pas_visible
      or dx,dx
    _fil_de_fer:
      je _point_rien
    _point_rien:
      mov ah,byte ptr ds:[pts_bisz]
      cmp ah,gs:[di]
      jnb _point_pas_visible
      _point_visible:
        mov gs:[di],ah
        add al,[obj_lum]
        mov fs:[di],al
        inc dx
  _point_pas_visible:
    loop _gour_col

  _point_pas_col:
    fld1
    fsubp st(3),st(0)
    fld st(2)
    fxam
    fnstsw ax
    fstp st(0)
    test ah,64
  jz _gour_lig
  ret
_dessine_triangle endp

;IN : ES:SI = Les faces
;     FS    = l'‚cran
;     GS    = Zbuffer
_render_gouraud_zbuf:
  mov gs,[zbuffer]
_render_gouraud_ecr:
  mov fs,[ecran]
_render_gouraud proc near
  lodsw_es
  xchg ax,cx
  _render_boucle1:
    push cx
    fninit
    fldcw [mot_fpu1]

    _charge_3d_mac

    lea bx,pts0_posc
    push bx
    call _calc_dif_st0
    pop bx
    call _calc_dif_st01
    fstp st(0)

    call _counting1
    fxam
    fnstsw ax
    test ah,64
    jne _fin_face

    push di
    call _calc_dif
    fldz
    call _dessine_triangle
    fstp st(1)
    fstp st(1)

    lea bx,pts1_posc
    call _calc_dif_st0
    fxch st(1)

    pop di
    call _counting1
    fchs
    call _calc_dif
    fxch st(1)
    call _dessine_triangle

  _fin_face:
    pop cx
  loop _render_boucle1_bis
  ret

_render_boucle1_bis:
  jmp _render_boucle1
_render_gouraud endp

_counting1 proc near
  mov bx,offset d1_posc
  fld dword ptr ds:[bp+12]
  fsub dword ptr ds:[bx+12]
  fld st(0)
  fabs
  ret
_counting1 endp