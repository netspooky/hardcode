;128b intro
;'Bleeding asm v2'

;by zZz //[KCN] research group
;Makeevka/Ukraine
;8.05.2000

;121b w/o string

.model tiny
.386
.code
org 100h

COUNT equ 100 ;number of drips up to 255

Startx:

       mov      ax,13h
       int      10h


       push     0a000h
       pop      ds

       xor      ecx,ecx
       xor      edi,edi
lp1:
       mov      dx,3c8h
       mov      al,cl
       out      dx,al
       inc      dx
       out      dx,al
       xor      al,al
       out      dx,al
       out      dx,al
       dec      cl
       jnz      short lp1
lp5:
       mov      di,64001    ;fader
lp4:
       dec      di
       mov      al,[di]
       test     al,al
       jz       short jp2
       dec      al
       mov      [di],al
jp2:
       test     di,di
       jnz      short lp4

       mov      cl,COUNT    ;drip move
lp6:
       lea      edx,[ecx*4+data2]
       mov      di,word ptr cs:[edx]
       add      di,si

       and      di,1111111111111010b

       or      dword ptr [di],01f3f1f0fh
       or      byte ptr [di+4],0fh
       or      dword ptr [di+321],00f1f0fh

jp8:
       in       al,40h
       test     al,11b
       jnz      short jp7
       sub      word ptr cs:[edx],320
jp7:
       loop     lp6
       sub      si,cx
       add      si,320

       in       al,60h
       test     al,1
       jz       short lp5

       mov      ax,03h
       int      10h

       retn
data   db 'zZz/KCN'
data2:
end startx