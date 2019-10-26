manuscript:
nulltext:
	db 0,CMD_PALETTE
        db 16,1,0,5     ; 0..96
        db 16,0,0,2
        db 16,3,2,-7
        db 16,2,0,2
        db 16,-5,0,8
        db 16,5,2,-8
        db 24,1,2,6
        db 8,-6,-12,-16
      
        db 24,4,1,1
        db 40,2,4,2
        db 40,-2,-4,-2
        db 24,-4,-1,-1

	db 0,CMD_FADE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        db 0,CMD_FX,FX_CLRSCR+FX_IFS+FX_3D

; 0123456789abcdef
;
;    phygo has
;      risen
;
;
;  phygo

;  shall shift
;      ever on

        db 32,CMD_TEXT,-0x63,"phygo has",-0x29,"rosen",0
        db 0,CMD_RUNCODE,.k39-.k40
        .k40:
           mov byte[ifsparms+3*8],212
           mov word[player.melody],melody2
           ret
        .k39:
        db 32,CMD_TEXT,-0x25,"phygo",-0x5a,"shall xor",
        db -0x39,"ever on",0
        db 0,CMD_RUNCODE,.k41-.k42
        .k42:
           mov byte[ifsparms+3*8],128
           ret
        .k41:
        db 32,CMD_TEXT,-0x52,"no way back",0
        db 32,CMD_FX,FX_TUNNEL
        db 0,CMD_TEXT,-0x52,"going worse",0
        db 0,CMD_RUNCODE,.k1a-.k0a
        .k0a:
                mov byte[tunnel_handler.step],3
		ret
        .k1a:
        db 32,CMD_FX,FX_PERSP+FX_CLRSCR ;FX_SKY
        db 0,CMD_TEXT,-0x32,"year",-0x2c,"after year",0
        db 32,CMD_FX,FX_IFS+FX_3D+FX_CLRSCR
        db 0,CMD_TEXT,-0x52,"100% recycled",-0x25,"asm code",0
        db 32,CMD_FX,FX_TUNNEL
        db 0,CMD_TEXT,-0x72,"phygo devours",0
        db 0,CMD_RUNCODE,.k3-.k2
        .k2:
                mov word[tunnel_handler.step+1],12
                add dword[player.baseline],0x5050505
                ret
        .k3:
        db 8,CMD_FADE

        ;;;

        db 16,CMD_FADE
        db 0,CMD_FX,FX_PERSP+FX_TUNNEL
        db 0,CMD_PILLU
        db 0,CMD_TEXT,0
        db 0,CMD_RUNCODE,.k1-.k0
       .k0:
                mov byte[tunnel_handler.step],2
                ret
       .k1:
        db 8,CMD_TEXT,-0x54,"growing",0
        db 8,CMD_CURTAIN
          dw 255
        db 8,CMD_TEXT,-0x54,"multiplying",0
        db 16,CMD_TEXT,-0x54,"invading",0
        db 8,CMD_CURTAIN
          dw 0

        db 16,CMD_FX,FX_CLRSCR

        db 8,CMD_FX,FX_3D+FX_IFS+FX_CLRSCR
        db 0,CMD_TEXT,-0x32,"that is phygo",0
                           db 32,CMD_TEXT,0
        db 0,CMD_FX,FX_CLRSCR
        db 0,CMD_TEXT,-0x32,"the source of",-0x35,"all that is",0
        db 16,CMD_FX,FX_TUNNEL
        db 0,CMD_RUNCODE,.k3a-.k2a
        .k2a:
                mov word[tunnel_handler.step+1],12
                mov dword[player.baseline],0x1030401
                mov word[player.melody],melody0
                mov word[player.bass],bass1
                ret
        .k3a:
        db 8,CMD_TEXT,0
        db 8,CMD_FX,FX_CLRSCR

        db 8,CMD_TEXT,-0x54,"p h y g o",0

        db 32,CMD_TEXT,-0x34,"2598",-0x29,"uncompressed"
        db -0x29,"bytes",0

        db 32,CMD_TEXT,-0x53,"of pure",-0x2a,"crap",0
        db  8,CMD_TEXT,-0x53,"of pure",-0x2a,"design",0

        db 24,CMD_FADE,0
        db 8,99

maxvxes equ 100
maxfces equ 100


;pyrafaces:
;        dw 6
;        db 1 ,0x55,0,1,2
;        db 2 ,0x55,0,2,3
;        db 3 ,0x55,0,3,4
;        db 4 ,0x55,0,4,1
;        db 0 ,0x99,1,2,3
;        db 0 ,0x99,3,4,1

vertices:
	dw 0,0,-10000
	dw -8000,-8000, 4000
        dw -8000, 8000, 4000
;        dw  8000, 8000, 4000
;        dw  8000,-8000, 4000

sin_table:
random_table equ (sin_table + 8192)

rotated_vertices equ (random_table + ((256+256)*2))
facetemp equ (rotated_vertices + (2*4*maxvxes))
;vertices equ (facetemp+(10*maxfces))
faces equ (vertices+(6*maxvxes))

palette_temp equ (faces+(5*maxfces))
patt_temp equ (palette_temp+768*4*2)+23592
rotate_angles equ patt_temp+64*2

