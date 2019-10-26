;by zZz //[KCN] research group
;Makeevka/Ukraine
.model tiny
.586
.code
org 100h

Startx:;)

       mov      ax,13h
       int      10h

       push     0a000h
       pop      ds
lp1:
       mov      dx,3c8h
       mov      al,cl
       out      dx,al
       inc      dx
       shr      al,2
       out      dx,al
       xor      al,al
       out      dx,al
       mov      al,cl
       shr      al,1
       out      dx,al
       loop     short lp1

       ;di=0,si=0
;---------------------------------------------loop
lp2:
       lea      bp,data
       mov      di,28600
lp4:
       mov      al,[bp]
       mov      word ptr [di],09f9fh
       test     al,al
       jz       short lp3
       add      di,ax
       inc      bp
       jmp      short lp4
lp3:
       mov      al,[si]
       test     al,11111100b
       jz       short jp1
       dec      al
       mov      [si-320],al
       dec      al
       mov      [si-1],al
       mov      [si+1],al
       mov      [si],al
       dec      al
       mov      [si+320],al
jp1:
       sub      si,dx
       in       al,61h
       xor      al,10b
       out      61h,al
       dec      dx
       jnz      short lp3

       in       al,60h
       test     al,1
       jz       short lp2

       mov      ax,03h
       int      10h

       retn
data db 20,20,1,1,1,1,20,20,236
     db 19,19,1,1,4,1,1,18,1,19,236
     db 18,19,10,17,2,18,236
     db 17,19,12,16,3,17,236
     db 16,19,14,15,4,16,236
     db 15,19,30,5,15,236
     db 14,20,30,6,14,236
     db 13,20,31,7,13,236
     db 12,21,31,8,12,236
     db 11,22,31,9,11,236

     db 10 dup (1),22,32,10,10,236
     db 10 dup (1),22,32,11,9,236

     db 11,22,31,12,8,236
     db 12,21,31,13,7,236
     db 13,20,31,14,6,236
     db 14,20,30,15,5,236
     db 15,19,30,16,4,236
     db 16,19,14,15,17,3,236
     db 17,19,12,16,18,2,236
     db 18,19,10,17,19,1,236
     db 19,19,1,1,4,1,1,18,20,236
     db 20,20,1,1,1,1,20,20,236
     db 0
end startx