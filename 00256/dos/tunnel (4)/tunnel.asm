;+------------------------+
;| TUNNEL source for nasm |
;|   -by Nexinarus of MMS |
;|        (pure integers) |
;+------------------------+

;init
[bits 16]          ;tells nasm about the structure I want for my program
[org 256]          ;
[section .text]    

mov ax, 13h        ;set 320x200x8bpp mode
int 10h            ;

push 0A000h        ;set video segment
pop es             ;

mov dx, 968        ;sets the interesting palette
xor al, al         ;
out dx, al         ;start palette writing
mov ah, 32         ;
inc dl             ;
pal:               ;begining of pal loop
 out dx, al        ;write red
 ror ax, 8         ;
 out dx, al        ;write green
 xor al, ah        ;
 ror ax, 8         ;
 out dx, al        ;write  blue
inc al             ;
cmp al, 0          ;
jne pal            ;loop over all colors

;main
main_loop:         ;main loop
 mov ax, 5400      ;huge fixed point texture coordinate
 mov [z3dS], ax    ;
 mov di, 320*100   ;meh =)
 mov si, 320*99    ;    =)
 xor cl, cl        ;
 mov [z3da], cl    ;texture coordinate "acceleration" used as a curve effect aka tunnel
 yloop:            ;begining y loop
  inc byte [z3da]  ;"accelerate"
  mov bx, [z3da]   ;
  sub [z3dS], bx   ;increase scaled texture coordinate (fixed point)
  mov bx, [z3dS]   ;scale it down
  shr bx, 5        ;
  mov [z3d], bx    ;store it in normal texture coordinate
  mov ax, -160     ;ajust the tunnel to the center of the screen (horizontally)
  xor dx, dx       ;calculate X texture coordinate steps
  mul bx           ;
  mov [x3dS], ax   ;
  xor dx, dx       ;
  xloop:           ;begining x loop

   mov bx, [x3dS]  ;convert x texture coordinate to integer from fixed point
   ror bx, 8       ;(ie, divide by 256(2^8) by rotating bits 8 to the right)
   add bl, [px]    ;add player X movement
   mov al, cl      ;the pattern for top
   add al, [py+1]  ;add player Y movement
   xor al, bl      ;
   mov [es:si], al ;
   inc si          ;store on top half of screen

   mov al, cl      ;the pattern for the bottom
   sub al, [py+1]  ;re-add player Y movement (no need for X, its done already)
   neg al          ;mirror
   xor al, bl      ;
   stosb           ;store on bottom half of screen

   mov bx, [z3d]   ;add x texture position along by the step
   add [x3dS], bx  ;

  inc dx           ;increase X loop
  cmp dx, 320      ;check bounds
  jne xloop        ;loop back if needed
 sub si, 640       ;used for top half drawing mirror of bottom
 inc cl            ;increase Y loop
 cmp cl, 100       ;check bounds
 jne yloop         ;loop back if needed
 mov ah, 1         ;check for keypress
 int 16h           ;
 jnz skip          ;skip main loop if keypress
inc byte [px]      ;add player X movement
add word [py], 64  ;add player Y movement
jmp main_loop      ;jump to top of main loop

;close
skip:              ;go here if a keypress
mov ax, 3h         ;return to text mode 80x25
int 10h            ;
mov ah, 9          ;print huge space wasting text hehe =)
mov dx, msg        ;
int 21h            ;
mov ax, 4c00h      ;return to DOS
int 21h            ;

;variables
[section .data]
z3d  dw 0
z3dS dw 0
z3da dw 0
x3dS dw 0
px   db 0
py   dw 0
msg  db '[TUNNEL] by Nexinarus of MMS @ http://www.hybd.net/~mms/', '$'
