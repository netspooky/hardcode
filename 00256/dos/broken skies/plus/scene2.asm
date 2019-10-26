;rain (broken skies scene 2)
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;parts marked with [[[[-]]]] are different from broken skies scene 1

org 0100h

start: push 09000h
       pop ss       ;gs - 1b
       push 08000h
       pop ds
       push 0a000h
       pop es

       mov al,13h
       int 10h

        mov dx,0x3C9
        inc cx ;cl=0 ch=1
pal2:   shrd ax,cx,17
        out dx,al ;r
        out dx,al ;g
        ;mov al,63    ;[[[[-]]]]
        out dx,al ;b
        loop pal2

main:

lines:   cmp si,64000
         jb f_loop
         in al,40h
         mul al
         mov byte[ds:si], al

f_loop:  mov al,byte[ds:si]
         adc al,byte[ds:si+1]
         adc ah,0
         adc al,byte[ds:si-320]
         adc ah,0
         adc al,byte[ds:si-1]
         adc ah,0
         shr ax,2
         jz f01
         dec ax
f01:     mov byte[ds:si+323],al  ;[[[[-]]]]
         dec si
         jnz lines

;create map out of texture
;si = 0 here
;cx = 0 here
weiter:
add cl,byte[ds:si] ;somehow there can be artefacts at the beginning at bottom
;mov cl,byte[ds:si] ;get height
;inc cl
jz breaker         ;get rid of trouble

mov al,cl          ;save color
mov di,si          ;same pos
;sub di,320*76 ;adjust pos on screen ---> 2b less with adjust inside output below
weiter2:
mov byte[ss:di+320*100],al  ;[[[[-]]]]
add di,319                  ;[[[[-]]]]
loop weiter2              ;worked full height?

breaker:
inc si
cmp si,320*128 ;max scanned area
jna weiter

;flip
xor si,si ;safety first
flip:
xor ax,ax
xchg al,byte [ss:si] ;grab+clear vscreen2
;mov al,byte [ds:si]  ;fire
mov byte [es:si],al  ;drop to screen
inc si
jnz flip


         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret