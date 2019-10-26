;_calc_tun proc near
;  mov ax,[nbr_tun]
;  mov [nbr_hasard],ax
;  mov [obj_traz],40
;  mov [obj_trax],0
;  mov [obj_tray],0
;  mov es,[effet]
;  mov di,8000h
;  mov cl,_tun_long
; _tun_long_boucle:
;    mov si,offset _tunnel
;    call _rotate_pts
;    call hasard
;    and ax,63
;    or al,80h
;    mov es:[di-14],ax
;    add [obj_traz],_tun_dist
;  loop _tun_long_boucle
;
;
;  ret
;_calc_tun endp

;dl : angle de rotation
_tentacule proc near
  push es
  push ds
  pop es
  mov si,offset _tent+2+3
  mov di,offset _tent+2
  mov cl,_nbr_bras
  _tent_boucle1:
    mov ch,_long_bras-1
    _tent_boucle2:
      movsw
      lodsb
      inc ax
      stosb
      dec ch
    jne _tent_boucle2
    add es:[di],dl
    add di,3
    add si,3
  loop _tent_boucle1
  mov es,[effet]
  xor di,di
  mov si,offset _tent
  call _rotate_pts

  push es
  pop fs
  pop es
  xor si,si
  mov cx,_long_bras*_nbr_bras
  _tent_boucle3:
    mov bx,fs:[si]
    mov ax,fs:[si+2]
    xchg bh,al
    mov dl,2
    _tent_boucle4:
      mov dh,2
      _tent_boucle5:
        or byte ptr es:[bx],80h+40h
        cmp byte ptr es:[bx],249
        ja _tent_suite
          add byte ptr es:[bx],6
        _tent_suite:
        inc bx
        dec dh
      jne _tent_boucle5
      add bx,256-2
      dec dx
    jne _tent_boucle4
    add si,20
  loop _tent_boucle3
  ret
_tentacule endp

;DS:SI = adresse du blob
_transforme_blob proc near
  mov si,offset _blob
  lodsw
  xchg ax,cx
  _trans_blob_boucle:
    lodsw
    add al,ah
    xor ah,ah
    mov di,ax
    shl di,2
    fld [cosinus+di]
    add al,byte ptr [temps]
    xchg ax,bx
    shl bx,2
    fmul [sinus+bx]
    call _fpu_to_ax_63
    add al,32
    mov ds:[si],al
    inc si
  loop _trans_blob_boucle
  ret
_transforme_blob endp

;In: es:di = adresse destination
;    ds:si = source
;OUT: cx=0
_trans proc near
  xor cx,cx
  _trans_boucle:
    lodsb
    and al,es:[di]
    or al,al
    je _trans_suite
    	or al,32
    _trans_suite:
    add al,64
    stosb
  loop _trans_boucle
  ret
_trans endp

;DS:SI = adresse du satelite
_transforme_blob2 proc near
  mov si,offset _blob
  lodsw
  xchg ax,cx
  _trans_blob2_boucle:
    lodsw
    mov byte ptr ds:[si],20
    shl ah,3
    shl al,2
    or ax,ax
    jne _bl2_suite
      mov byte ptr ds:[si],60
    _bl2_suite:
    inc si
  loop _trans_blob2_boucle
  mov ax,[temps]
  mov word ptr [obj_rota],ax
  ret
_transforme_blob2 endp

_pal_vas_y_out proc near
  inc ax
  out dx,al
_pal_vas_y:
  mov cl,64
  fldz
  _pal_boucle1:
    fldpi
    fadd st(0),st(1)
    fcos
    fld1
    faddp
    call _fpu_to_ax_63
    out dx,al
    fld st(0)
    fsin
    call _fpu_to_ax_63
    out dx,al
    out dx,al
    fadd [float_sin]
  loop _pal_boucle1
  ret
_pal_vas_y_out endp

;FS:0  = L'image source 256x256
;ES:0  = La destination 256x256 ou 320x200
;Vect  = Vecteurs de d‚placement
;CX    = Nombre de ligne: 200 ou 255
;AX    = Nombre de colonne: 320 ou 255
;BX    = Position dans la source
_affiche proc near
  push 0a000h
  pop es
  mov dword ptr [vect],204
  mov dword ptr [vect+4],1470000h
  mov fs,[ecran]
  mov cx,200
  mov ax,160
_roto_zoom_bx:
  xor bx,bx
_roto_zoom:
  xor di,di
  xor dx,dx                            ;BX = ligne
  xchg dh,bl                           ;DX = colonne
  _rotozoom_lig:
    pusha
    xchg cx,ax
    _rotozoom_col:
      add dx,[vect]
      add bx,[vect+2]
      xchg bl,dh
      mov al,byte ptr fs:[bx]
      xchg bl,dh
      add dx,[vect]
      add bx,[vect+2]
      xchg bl,dh
      mov ah,byte ptr fs:[bx]
      xchg bl,dh
      stosw
    loop _rotozoom_col
    popa
    add di,ax
    add di,ax
    add dx,[vect+4]
    add bx,[vect+6]
  loop _rotozoom_lig
  ret
_affiche endp

;IN : DS = source
;     ES = destination
_copie_seg proc near
  mov cx,32768
  xor si,si
  xor di,di
  rep movsw
  push cs
  pop ds
  ret
_copie_seg endp

;IN : EX=Segment … effacer
_efface_seg proc near
  xor ax,ax
_efface_seg_x:
  pusha
  xor di,di
  mov cx,32768
  rep stosw
  popa
  ret
_efface_seg endp

;IN : FS:SI = Adresse de la fonte
;     ES:DI = Adresse de destination
;     DX    = Hauteur,Longueur de zoom de sprite
;     BX    = Hauteur/Couleur
;     DF    = Miroir horizontal On/Off
_affiche_caract proc near
  mov cx,dx
  _aff_caract_lig:
    mov ah,fs:[si]
    dec ch
    jne _avance_lig
      inc si
      mov cx,dx
  _avance_lig:
    push di
    mov cl,dl
    _aff_caract_col:
      mov al,bl
      or ah,ah
      js _caract_pas_trans
        mov al,es:[di]
    _caract_pas_trans:
        stosb
        dec cl
        jne _avance_col
          mov cl,dl
          shl ah,1
      _avance_col:
    jne _aff_caract_col
    pop di
    add di,256
    dec bh
  jnz _aff_caract_lig
  ret
_affiche_caract endp

;IN : Cl    = profondeur
;   : BX    = orientation : 0..3
;   : ES:DI = Position
_genere_fract_c proc near
  mov si,0602h
  mov cl,10
_fract_debut_bx:
  xor bx,bx
  mov byte ptr ds:[_changt_fract+1],offset _fractale-offset _changt_fract-2
_fract_debut:
    push cx
    or cl,cl
    je _fin_fract
  _changt_fract:
    jne _dragon

_fin_fract:
  and bx,3
  push bx
  dec bx
  je _fract_haut
  test bl,1
  jne _fract_pas_vert
    mov bx,-512
  _fract_haut:
    inc bh
_fract_pas_vert:
  and byte ptr es:[di],63
  or byte ptr es:[di],12
  add di,bx
  pop bx
  pop cx
  ret
_genere_fract_c endp

_dragon proc near
  js _dragon_neg
    dec cx
    call _fract_debut
    inc bx
    neg cl
    call _fract_debut
    pop cx
    ret
_dragon_neg:
    inc cx
    neg cl
    call _fract_debut
    dec bx
    neg cl
    call _fract_debut
    pop cx
    ret
_dragon endp

;IN : ES:SI = octet de l'effet 1byte long, 1byte donc chaque bit +1/-1
_fractale proc near
  dec cx
  mov dx,si
  _fract_boucle:
    push dx
    call _fract_debut
    pop dx
    shr dh,1
    jnc _fract_suite1
      dec bx
    shr dh,1
    jnc _fract_suite1
      dec bx
  _fract_suite1:
    inc bx
    dec dl
  jnz _fract_boucle
  pop cx
  ret
_fractale endp

;In : ES:DI = destination
;     DS:SI = Texte … afficher
;     Cl    = Nombre de phrases
_affiche_chaine proc near
  mov dx,0201h
  mov bx,201eh
_affiche_chaine_x:
  dec cl
  jns _aff_ch_deb
    ret
_aff_ch_deb:
  lodsb
  shl ax,4
  shl ah,4
  xchg ax,di
  lodsb
  _aff_chaine_boucle:
    pusha
    lodsb
    lfs si,dword ptr [fonte_ofs]
    xor ah,ah
    shl ax,4
    add si,ax
    call _affiche_caract
    popa
    inc si
    add di,8
    dec al
  jne _aff_chaine_boucle
  je _affiche_chaine
_affiche_chaine endp

;OUT : Un pseudo hazard dans AX
_hasard proc near
  mov ax,ds:[nbr_hasard]
  xor ax,0AA69h
  rol ax,1
  add ax,188h
  mov ds:[nbr_hasard],ax
  ret
_hasard endp

;IN : ES:1000h  = destination panoramique
;     CS:SI     = effet choisi
;_effet_16 proc near
;  mov di,2000h
;  mov cx,0c000h
;  mov si,offset _effet_16_1
;  mov bp,[effet_pos]
;  shr bp,1
;  jnc _cree_img_boucle
;    mov si,offset _effet_16_2
;  _cree_img_boucle:
;    xor dx,dx
;    mov bx,cx
;    sub bx,bp
;    xchg bh,dl
;    shl bx,2
;    fld [sinus+bx]
;    mov bx,dx
;    shl bx,2
;    fld [sinus+bx]
;    call si
;    fimul word ptr ds:[mot_fpu1]
;    call _fpu_to_ax_abs
;
;    sub ax,[temps]
;    mov al,ah
;    and al,15
;    stosb
;  loop _cree_img_boucle
;  ret
;_effet_16 endp

;_effet_16_1 proc near
;  fadd st(1),st(0)
;_effet_16_1 endp
;
;_effet_16_2 proc near
;  fmul st(0),st(0)
;  faddp
;  ret
;_effet_16_2 endp

_calc_img_rond proc near
  xor di,di
  _img_rond_boucle1:
    mov ax,di
    xor bx,bx
    xchg ah,bl
    mov cx,ax
    add cx,bx
    shr cx,2

    and al,0fh
    sub al,08h
    imul al
    xchg ax,bx

    and al,0fh
    sub al,8
    imul al
    add bx,ax

    mov al,16
    cmp bx,cx
    jna _pas_rond
      shr al,1
  _pas_rond:
    stosb
    or di,di
  jnz _img_rond_boucle1
  ret
_calc_img_rond endp

;IN : ES = segment destination
;     FPU= La position initiale
;OUT: Calcul de Lyupanov la magnifique!
_init_lyu proc near
  mov ch,11001100b
_init_lyu_si:
  mov si,offset lyu_dxy0
_init_lyu_x:
  xor bx,bx
  fld st(0)
  fld st(0)
  _lyu_col:
    or bl,bl
    jne _lyu_lig
      fstp st(0)
      fadd dword ptr ds:[si]
      fld st(1)
  _lyu_lig:
    fadd dword ptr ds:[si]
    fldlg2
    fld1
    mov cl,48                                  ;Bonne valeur: 48
    _calc_lyu:
      fld st(3)
      fabs
      rol ch,1
      setc al
      xor byte ptr ds:[_calc_lyu+1],al
      fld1
      fsub st(0),st(3)
      fmul st(0),st(1)
      fmulp st(3)
      fld st(0)
      fadd st(0),st(0)
      fmul st(0),st(3)
      fsubp
      fabs
      fmulp st(1)
      dec cl
    jne _calc_lyu
    fldlg2
    fxch st(1)
    fyl2x
    call _fpu_to_ax_abs
    add al,69
    jns _lyu_suite
      mov al,127
  _lyu_suite:
    add al,dl
    mov es:[bx],al
    fstp st(0)
    inc bx
  jne _lyu_col
  ret
_init_lyu endp

;IN : CX = Nombre de Tozoides
;     ES = Segment de Destination
_aff_toz proc near
  pusha
  push ds
  pop fs
  lea si,_tozoide
  _aff_toz_boucle:
    fild [temps]
    fimul word ptr [si+3]
    fidiv word ptr [val_63]
    fld st(0)
    call _fpu_to_ax
    xchg ax,bx
    lodsw
    sub ax,bx
    or ah,ah
    pushf

    mov ah,al
    lodsb
    xchg ax,di
    fldlg2
    fmulp
    fsin
    fldpi
    fmulp
    call _fpu_to_ax

    popf
    jne _aff_toz_fin
      add di,ax
      pusha
      mov si,offset _toz_vert
      mov dx,0101h
      mov bx,100fh
      call _affiche_caract
      popa
  _aff_toz_fin:
    inc si
    inc si
  loop _aff_toz_boucle
  popa
  ret
_aff_toz endp
