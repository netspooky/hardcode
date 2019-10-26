;*****************************************************
;*** Gestionnaire des musiques adlibs PNK et timer ***
;*****************************************************

;*** Datas ***

freq_ls    db 86,91,96,102,108,115,121,129,136,144,153,162

;IN :Al = registre
;    Ah = valeur
_out_sb_lodsb proc near
  lodsb
_out_sb:
  pusha
  mov dx,388h
_out_ici:
  xchg al,ah
  out dx,al
  mov cx,dx
_init_env_reg:
  loop _init_env_reg
  inc dx
  cmp dl,89h
  je _out_ici
  popa
  ret
_out_sb_lodsb endp

;L'interruption 1Ch du timer d‚tourn‚e
_new_int1c proc far
  cli
  pusha
  push ds cs
  pop ds

  inc [temps]
  dec [dec_tmp]
  dec [dec_tmp]
  jns _zik_suite
    inc [dec_tmp]
    inc [dec_tmp]
_zik_suite:
  mov si,[zik_ofs]

  mov bx,8
  _zik_dec_boucle:
    dec byte ptr ds:[effet_note+bx]
    jns _zik_dec_suite
;      mov ds:[effet_note+bx],4
      mov ds:[effet_note+bx],bh
  _zik_dec_suite:
    dec bx
  jns _zik_dec_boucle

  dec [tmp_play]
  jns _new_int_fin
    mov [tmp_play],tune_speed
    xor dx,dx
    dec [zik_pos]
    jns _zik_pas_pat
      mov bx,[zik_pat]
      inc bx
      cmp bl,byte ptr ds:[zik]
      jb _zik_suite4
_saut_debut:
        xor bx,bx
      _zik_suite4:
      mov [zik_pat],bx
      shl bx,1
      mov si,ds:[bx+offset zik+89]
      add si,offset zik-1
      mov [zik_pos],63

  _zik_pas_pat:
    lodsb
    mov ah,al
  _zik_boucle:
    shl ah,1
    jnc _zik_fin_boucle
      push ax
      lodsb                            ;Joue l'instrument DL note AL

      or al,al
      jns _zik_pas_effet
        xor bx,bx
        mov bl,dl
        inc byte ptr ds:[bx+offset note]
        mov dh,ds:[bx+offset effet_note_tmp]
        mov [effet_note+bx],dh
    _zik_pas_effet:

      mov dh,al
      shr dh,2
      and dh,011100b

      and ax,15
      lea bx,freq_ls
      xlatb
      shl ax,2
      add dh,ah

      mov ah,0a0h
      add ah,dl
      call _out_sb

      xchg al,dh
      add ah,010h
      call _out_sb
      or al,020h
      call _out_sb
      pop ax
  _zik_fin_boucle:
    inc dl
    or ah,ah
    jne _zik_boucle
_new_int_fin:
  mov [zik_ofs],si

  pop ds
  popa
  sti                                  ;On peut peut-ˆtre enlever?
  jmp dword ptr cs:[anc_1c]
_new_int1c endp
