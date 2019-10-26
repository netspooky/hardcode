_trans_txt proc near
  call _affiche_chaine
  push ds
  mov ds,[lyu1]
  xor di,di
  xor si,si
  call _trans
  pop ds
  xor cx,cx
  ret
_trans_txt endp

_effet1 proc near
  mov byte ptr ds:[_changt_fract+1],offset _dragon-offset _changt_fract-2
  mov di,0a41bh
  mov cl,11
  inc bx
  call _fract_debut
  mov di,6064h
  call _genere_fract_c
  mov si,offset txt1
  mov cl,2
  call _trans_txt
  ret
_effet1 endp

_effet2 proc near
;  call _effet_16
;  shr [note],1
;  jnc _effet2_suite
;    call _hasard
;    mov [effet_pos],ax
;_effet2_suite:
  

  mov dx,2
  add dl,[note]
  add dl,[note]
  xchg dx,si
  mov si,ds:[_txt_effet2+si]
  mov cx,1
  call _trans_txt

  mov si,0e03h
 mov cl,8
;  call _fract_debut_bx
  call _transforme_blob2
  call _calc_mvt_blob2
  call _envoie_3d

  xor cx,cx
  ret
_effet2 endp

;IN : DS:SI = Ofs Pts2, Ofs Pts1, Nbr pts, Ofs Faces
_envoie_3d_69 proc near
  call _envoie_3d_69_2
_envoie_3d_69_2:
  mov si,offset _69_info
  add [obj_rotb],128
_envoie_3d:
  mov ax,0ffffh
_envoie_3d_x:
  mov es,[zbuffer]
  call _efface_seg_x
  mov es,[obj_3d]

  lodsw
  xchg ax,di
  push di
  lodsw
  push si
  xchg ax,si
  call _rotate_pts
  pop si

  lodsw
  xchg ax,cx
  pop di
  lodsw
  xchg ax,si
  push si
  call _lumiere_pts
  pop si
  call _render_gouraud_zbuf
  push fs
  pop es
  ret
_envoie_3d_69 endp

_effet7 proc near
  mov es,[ecran]
  call _efface_seg
  mov dword ptr [obj_trax],0
  mov byte ptr [obj_rota],0
  call _envoie_3d_69

  mov dx,[temps]
  shr dx,4
  mov [obj_rotb],dl
  mov cx,1

  ret
_effet7 endp

_effet3 proc near
  mov dword ptr [obj_trax],0
  mov byte ptr [obj_rota],0
  call _calc_img_rond
  call _envoie_3d_69

  mov al,[effet_note+1]
  sub al,31
  js _effet3_suite
    mul al
    shr ax,3
    mov [obj_rotb],al

_effet3_suite:
  mov cl,byte ptr [note]
  push cx
  dec cl
  js _pas_code
  dec cl
  jng _only_code

  mov si,0003h
  mov di,0f690h
  mov cl,7
  call _fract_debut_bx
_only_code:
  mov di,1e2dh
  call _genere_fract_c
_pas_code:
  mov si,offset txt2
  pop cx
  ret
_effet3 endp

;OUT: BX = temps, CX = 0?
_calc_mvt_blob proc near
  call _transforme_blob
_calc_mvt_blob2:
  mov bx,[temps]
  push bx
  and bx,1020
  fld [sinus+bx]
  fimul word ptr [val_63]
  fist [obj_trax]
  fld [cosinus+bx]
  fimul word ptr [val_63]
  faddp
  fist [obj_tray]
  fabs
  fldpi
  fdivp st(1)
  call _fpu_to_ax
  add al,80
  mov [obj_traz],ax
  pop bx
  mov si,offset _blob_info
  ret
_calc_mvt_blob endp

_effet4 proc near
;  mov word ptr [_calc_mvt_blob+1],offset _transforme_blob
  mov ds,[lyu1]
  call _copie_seg
  add word ptr [temps],256
  call _calc_mvt_blob
  sub word ptr [temps],256
  sub bh,3
  jns _effet4_suite
    neg bx
    add [obj_tray],bx
_effet4_suite:
  mov al,[note]
  and al,1
  dec ax
  js _effet4_suite2
    mov byte ptr ds:[_fil_de_fer+1],offset _point_visible-offset _fil_de_fer-2
_effet4_suite2:
  call _envoie_3d_x
  mov byte ptr ds:[_fil_de_fer+1],offset _point_rien-offset _fil_de_fer-2
  ret
_effet4 endp

;IN : BX    = L'angle
;     ES:DI = Destination
;OUT: Le sinus dans la destination
_cherche_angle proc near
  push bx
  xor bh,bh
  shl bx,2
  fld [sinus+bx]
  fld [cosinus+bx]
  fldl2e
  faddp
  fadd st(0),st(0)
  faddp
  call _fpu_to_ax_63
  stosw
  pop bx
  add bl,64
  ret
_cherche_angle endp

_effet5 proc near
  push es
  mov di,offset vect
  push ds
  pop es
  mov bx,[temps]
  shr bx,1
  call _cherche_angle
  call _cherche_angle
  stosw
  call _cherche_angle

  mov fs,[lyu2]
  pop es
  mov ax,128
  mov cx,256
  call _roto_zoom

  mov byte ptr [_fract_pas_vert+7],193
  mov si,1e03h
  mov di,07028h
  mov cl,11
  call _fract_debut_bx

;  or [note],0
;  je _effet5_suite
;    mov byte ptr [_fract_pas_vert+7],235
;    mov di,8080h
;    mov si,2704h
;    mov cl,7
;    call _fract_debut_bx
;  _effet5_suite:

  xor cx,cx
  ret
_effet5 endp

;IN : ES:DI = destination
;     CX    = dimensions
_rect proc near
  _rect_lig:
    push bx
    _rect_col:
      mov al,128
      sub al,es:[di+bx]
      mov es:[di+bx],al
      dec bl
    jne _rect_col
    pop bx
    dec bh
  jne _rect_lig
  ret
_rect endp

_croix macro
  mov byte ptr [_fract_pas_vert+7],123
  mov di,8f3ah
  mov bx,7010h
  call _rect

  fild [temps]
  fimul word ptr [val_63]
  fild [val_512]
  fiadd [dec_tmp]
  fdivp
  fcos
  fild [dec_tmp]
  fiadd [val_512]
  fmulp
  call _fpu_to_ax
  shl ax,3
  xor al,al

  xor cx,cx
  cmp ah,-28
  jnl _pas_dessus
    mov cl,4
    mov si,5e05h
    mov di,1de0h
    call _fract_debut_bx
    add di,04600h
    inc bx
    inc bx
    call _fract_debut
    mov si,offset txt_xst
    mov cl,1
    mov ah,-28
_pas_dessus:

  cmp ah,28
  jl _pas_dessous
    mov byte ptr ds:[_changt_fract+1],offset _dragon-offset _changt_fract-2
    mov di,0d3a0h
    mov cl,11
    inc bx
    call _fract_debut
    mov cl,1
    mov si,offset txt_sat
    mov ah,28
_pas_dessous:

  cmp [temps],1150
  jna _pas_remy
    inc cx
    call _aff_toz
    mov si,offset txt_rem
_pas_remy:

  xchg ax,di
  add di,0bd27h
  mov bx,1513h
  call _rect
  add di,23h
  mov bh,15h
  call _rect
endm

_effet6 proc near
  mov ds,[lyu3]
  call _copie_seg
  _croix
  ret
_effet6 endp

;_effet7 proc near
;  call _effet8
;  mov dword ptr [vect],0ff0000h
;  mov dword ptr [vect+4],0b0h
;  mov ax,128
;  xor bx,bx

_envoie_zoom:
  push es
  push es
  pop fs
  mov es,[zbuffer]
  push es
  call _roto_zoom
  pop ds
  pop es
  call _copie_seg
  ret
;_effet7 endp


_effet8 proc near
  call _calc_img_rond
;  call _calc_mvt_blob
;  sub bh,2
;  sub [obj_tray],bx
;  sub byte ptr [temps+1],1
;  jns _effet8_suite
;    call _envoie_3d

_effet8_suite:
  mov es,[ecran]
  mov cl,255
  call _aff_toz
;  add byte ptr [temps+1],1
  ret
_effet8 endp

_effet9 proc near
  mov byte ptr ds:[_changt_fract+1],offset _dragon-offset _changt_fract-2
  mov di,0a737h
  mov cl,11
  inc bx
  call _fract_debut

  mov cl,4
  mov si,5e05h
  mov di,4077h
  call _fract_debut_bx
  add di,48
  call _fract_debut

  mov cl,2
  mov si,offset txt_fin
  call _trans_txt
  ret
_effet9 endp

_blur macro
  mov fs,[zbuffer]
  _effet10_blur:
    mov al,fs:[di-1]
    add al,fs:[di+1]
    add al,fs:[di-256]
    add al,fs:[di+256]
    shr al,2
    or al,40h
    stosb
  loop _effet10_blur
endm

_effet10 proc near
  _blur
  call _calc_mvt_blob
  call _envoie_3d

  mov dword ptr [vect],01000e0h
  mov dword ptr [vect+4],0e0fff0h
  mov ax,128
  mov cl,0e8h
  mov bx,0a17h
  call _envoie_zoom
  mov di,0e800h
  mov cx,3000h
  rep stosb
  ret
_effet10 endp

_vit_tent db -1,1,-1,0

_effet11 proc near
  mov al,byte ptr [note+1]
  and al,3
  mov bx,offset _vit_tent
  xlatb
  xchg ax,dx
  call _tentacule
  call _calc_mvt_blob2
  add [obj_traz],45
  xor cx,cx
  ret
_effet11 endp
