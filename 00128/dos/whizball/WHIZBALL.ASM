; EFNet @ #asm 128byte compo entry ( compo3 , asmcompo.cjb.net )
; by whizzter of woorlic&deluxe ( whizzter@enjoy.joint.net )
; (this entry was made in about 2 hours just before the deadline =)

; get nasm ( www.cryogen.com/nasm ) to compile this entry.
; (oh, and nasm rulz =)

; c:\yeah\whatever\asm> nasm -o whizball.com whizball.asm


; thanks for fredrik ocklind for giving me the idea to make a metaball
; for this compo(eventho that was a joke? =)

; metaball math: pixel=sum of all balls[ (radius^2) / (distance from pixel^2)]
; for true stuff the inside is if pixel is above 1, tho this looks nicer
; and is smaller :)

; woorlic homepage : http://woorlic.hostname.nu/
;                    update comming anytime soon.
;                   dreamless and homeless available for both win32 and linux

; personal homepage: http://woorlic.hostname.nu/jonaslund/
;                    (note: not really finished,mabbe i'll finish it tonight?)
; (yes, emailing whizzter@woorlic.hostname.nu could work, but i prefer the
;   enjoy.joint.net email)

; sane texts after the code, scroll down please \/\/\/\/\/\/\/\/\/
; --------------------- cut'n'paste here ------------------------------------

bits 16
balls equ 64600

mov al,13h
int 10h


push word 0a000h
pop es


finit
mainloop:
 add byte[balls+2],1
 add byte[balls+10],3
 mov ch,0f0h
 xor di,di
 ll:
  mov si,balls+2
  mov bp,3
  mov word [balls],0
  stosb
  kekk:
   mov ax,di
   xor dx,dx
   mov bx,320
   div bx
   mov bx,[si]
   xor bh,bh
   sub ax,bx
   sub dx,160
   imul ax,ax
   imul dx,dx
   mov bx,ax
   add bx,dx
   inc bx
   inc bx
   xor ax,ax
   mov dx,1
   div bx
   add si,4
   add [balls],ax
  dec bp
  jnz kekk
  mov ax,[balls]
 loop ll
 mov ch,3
 mov dx,03c8h
 xor al,al
 out dx,al
 inc dx
 paletteloop:
  out dx,al
  inc al
 loop paletteloop

 in al,60h
 dec al
 jnz mainloop

mov ax,3
int 10h
ret

; -------------------------- cut'n'paste ------------------------------------

; did you try to rip? do it the riprap style? yes. riprap is one of the most
; ripping is a lifestyle, ripping makes you great, oh yees ripping, fuxx that

; riprap, the defenite antiripdemo? i love it, i think more people should se it
; it oughta be online at www.hornet.org or whatever
