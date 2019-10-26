lodsw_es equ dw 0ad26h

_totoz struc
  lig     dw ?
  col     db ?
  toz_vit dw ?
_totoz ends

_calc_tun_rond macro
  mov di,offset _tunnel
  mov ax,8
  stosw
  xor ax,ax
  _tun_circ_boucle:
    push ax
    stosw
    mov al,100
    stosb
    pop ax
    sub ah,32
  jne _tun_circ_boucle
endm

_init_toz macro
  mov ch,1
  mov dword ptr [di-5],283c0359h
  _init_toz_boucle:
    call _hasard
    mov ah,1
    stosw
    call _hasard
    stosb
    shr ax,10
    add al,39
    stosw
  loop _init_toz_boucle
endm

_palette macro
  mov dx,3c8h
  mov al,64
  out dx,al
  inc dx
  call _pal_vas_y
  call _pal_vas_y_out
  call _pal_vas_y_out
endm

;IN : Que dale!
_prep_69 macro
  lea si,_69
  lea di,_69_pts1
  push ds
  pop es
  mov ax,_69_nbr_pts
  stosw
  xchg cx,ax
  _prep_69_boucle:
    inc di
    movsw
  loop _prep_69_boucle
  mov es,[obj_3d]
  mov di,_69_ofs_face
  mov ax,_69_nbr_pts-2
  stosw
  xchg cx,ax
  xor ax,ax
  _prep_69_boucle2:
    stosw
    add ax,20
    push ax
  _prep_changt1:
    add ax,0
    stosw
  _prep_changt2:
    add ax,20
    stosw
    xor word ptr [_prep_changt1+1],20
    neg word ptr [_prep_changt2+1]
    pop ax
  loop _prep_69_boucle2
endm

;Genere la table des sinus, 256+64 r‚els.
_calc_sin macro
  fldz
  mov bx,04fch
  _calc_sin_boucle:
    fld st(0)
    fcos
    fstp dword ptr ds:[offset sinus+bx]
    fsub [float_sin]
    sub bx,4
  jns _calc_sin_boucle
  fninit
endm

;Reset FM de la carte
_init_carte macro
  mov ax,0f400h
  _init_zik_boucle:
    call _out_sb
    dec ah
  jne _init_zik_boucle
endm

;Initialise et d‚tourne le timer
_init_zik macro
  _init_carte
  mov al,36h
  out 43h,al
  out 40h,al
  out 40h,al                           ;Acc‚lŠre timer

  mov si,offset zik+1
  mov ah,020h
  mov dh,5
  _envoie_voix2:
    mov cx,0610h
    _envoie_voix:
      call _out_sb_lodsb
      cmp cl,3
      jnz _envoie_voix_suite
        inc ah
      _envoie_voix_suite:
      dec ch
      jnz _envoie_voix_suite3
        mov ch,6
        add ah,2
      _envoie_voix_suite3:
      inc ah
      dec cl
    jne _envoie_voix
    add ah,11
    cmp dh,2
    jnz _envoie_voix_suite2
      add ah,0e0h-0a0h
    _envoie_voix_suite2:
    dec dh
  jnz _envoie_voix2
  mov ah,0c0h
  _envoie_voix3:
    call _out_sb_lodsb
    inc ah
    cmp ah,0c8h
  jne _envoie_voix3

  mov ax,351ch
  int 21h
  mov word ptr [anc_1c+2],es
  mov word ptr [anc_1c],bx
  mov ah,25h
  lea dx,_new_int1c
  int 21h
endm

_desinit_zik macro
;  push ds
  mov al,036h
  out 43h,al
  mov al,0ffh
  out 40h,al
  out 40h,al
  mov ax,251ch
  lds dx,anc_1c
  int 21h
;  pop ds
endm

_init macro
  mov cx,offset fin_zero-offset deb_zero
  lea di,deb_zero
  rep stosb

  _init_toz

  mov ah,4ah
  mov bh,10h
  int 21h
  lea di,ecran
  mov cl,nbr_ecrans
  _intro_memoire_alloue:
    mov ah,48h
    int 21h
    mov ds:[di],ax
    inc di
    inc di
    mov es,ax
    call _efface_seg
  loop _intro_memoire_alloue
  mov ax,13h
  int 10h
  mov ax,1130h
  mov bh,06h
  int 10h                              ;Charge adresse Fonte 8x16
  mov [fonte_ofs],bp
  mov [fonte_seg],es
  _calc_sin
endm

_teste_touche macro
  mov ax,0100h
  int 16h
  jz _pas_fin
  _fin:
    mov ax,3
    int 10h
    _desinit_zik
  mov ax,0f400h
  _init_zikend_boucle:
    call _out_sb
    dec ah
  jne _init_zikend_boucle
    mov ah,4ch
    int 21h

  _pas_fin:
    xor ax,ax
    mov al,[effet_note+1]
    or ax,ax
    je _effet_pas_tsss
      xchg ah,al
      mov dx,3c8h
      out dx,al
      inc dx
      xchg ah,al
      out dx,al
      out dx,al
      out dx,al
  _effet_pas_tsss:
endm

;G‚nŠre les blobs et une tentacule
_genere_blob macro
  lea di,_blob
  mov ax,_bl_nbr_pts
  push ds
  pop es
  stosw
  mov ch,16
  _blob_gen_pt_boucle1:
    mov cl,32
    _blob_gen_pt_boucle2:
      mov ax,cx
      sub ah,8
      shl ax,3
      stosw
      inc di
      dec cl
    jns _blob_gen_pt_boucle2
    dec ch
  jns _blob_gen_pt_boucle1

  mov ax,_long_bras*_nbr_bras
  stosw
  mov cl,_nbr_bras
  _init_tent_boucle1:
    mov ch,_long_bras
    call _hasard
    _init_tent_boucle2:
      stosw
      mov byte ptr es:[di],30
      inc di
      dec ch
    jne _init_tent_boucle2
  loop _init_tent_boucle1

  mov es,[obj_3d]
  mov ax,_bl_ofs_pts
  mov di,_bl_ofs_face+2                ;Cr‚ation des faces
  mov word ptr es:[di-2],32*16*2
  mov cl,16
  _blob_gen_fc_boucle1:
    mov ch,32
    _blob_gen_fc_boucle2:
      stosw
      add ax,20
      stosw
      mov bx,ax
      add ax,20*32
      stosw
      stosw
      xchg bx,ax
      stosw
      add bx,20
      xchg bx,ax
      stosw
      xchg bx,ax
      dec ch
    jne _blob_gen_fc_boucle2
    add ax,20
  loop _blob_gen_fc_boucle1
endm
