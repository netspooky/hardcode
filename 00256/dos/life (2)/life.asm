;
;  LIFE - a 256b intro
;  made by -SP- ^ lce
;  released in May 2012
;
;  Graphical implementation of The Game Of Life 
;  by John Horton Conway, 1970
;
;  Short description: each pixel represent a cell, and each cell can have two states: alive or dead.
;  Dead pixels are black, alive pixels are colored. Color intensity corresponds to the cell's lifetime.
;  During each iteration, the following rules are applied:
;  1) Living cells with fewer than two live neighbours die
;  2) Living cells with two or three live neighbours live on
;  3) Living cells with more than three live neighbours die
;  4) Dead cells with exactly three live neighbours become alive
;
;  The state map of cells are stored at FS:[0-64000] with values 1 (alive) or 0 (dead)
;  After each iteration, video memory at ES is updated based on the values in FS
;
;  This is a modified version of the algorithm. It allows newly born and died cells to affect it's neightbors in the same iteration.
;  This is to avoid stabilization of the given world and the effect could run forever.
;

org 100h                  ; so here we go

mov ax, 13h               ; 320x200x8
int 10h                   ; video mode

push 0a000h               ; video memory in ES
pop es
push 09000h               ; cell state segment in FS
pop fs

mov cx, 64000             ; clear the whole cell state block, set each cell to dead state
clear:
mov di, cx
mov [fs:di], bx           ; bx shall be 0 here
loop clear

mov cx, 32                ; initial configuration: a 32x32 square block of alive cells in the center of the screen
init:                     ; (probably useless waste of space, I guess it can be done faster and in much less code)
mov dx, cx
push cx
mov cx, 32
init2:
mov ax, dx                ; computing pixel position
imul ax, 320
add ax, cx
mov di, ax        
add di, 27020             ; after some cheap centering
in al, 40h                ; with not-perfectly random seeding of the initial configuration
shr al, 7                 ; we put 1 or 0
mov [fs:di], al           ; into the cell state
loop init2
pop cx
loop init

pal:	                    ; palette tampering to achieve the reddish color
mov	dx, 0x3c8
mov	al, cl
out	dx, al
inc	dx
and al, 0xff
out	dx, al
and al, 0x00
out	dx, al
out	dx, al
loop	pal

main_loop:

mov dx,03DAh              ; vertical sync
vsync:
in al,dx
test al,8
jz vsync  
    
mov cx, 64000             ; okay, fun begins here
evolution:                
mov di, cx                ; DI -> pixel (cell) position
mov al, [fs:di]           ; fetch the current cell
xor bl, bl

add bl, [fs:di+1]         ; -
add bl, [fs:di-1]         ;  \ 
add bl, [fs:di+320]       ;   -- yeah, this is pretty horrible. eats up space and damn slow, gotta find a way to optimize.
add bl, [fs:di-320]       ;   -- anyway, for each cell we check the 8 adjacent cells in FS
add bl, [fs:di+321]       ;   -- and sum their values (if the adjacent cell is alive, BL will be incremented by one, otherwise no change)
add bl, [fs:di-321]       ;   -- later we check the value of BL to decide what to do with the cell
add bl, [fs:di+319]       ;  /
add bl, [fs:di-319]       ; -

cmp al, 0                 ; now, if the current cell state is zero, it's dead
jnz living                ; otherwise it's alive

dead:                     ; when the cell is DEAD
cmp bl, 3                 ; check if the adjacent living cells' count equals to 3
jnz next                  ; if not, skip the whole thing, cell remains dead
lives:                    ; if yes, the cell becomes alive
mov byte [es:di], 1       ; set the pixel color to 1
mov byte [fs:di], 1       ; set cell state to 1
jp next                   ; and move on to the next cell in the iteration

living:                   ; when the cell is ALIVE
cmp bl, 2                 ; check if the adjacent living cells' count equals to 2
jz grows                  ; 
cmp bl, 3                 ; or equals to 3
jz grows                  ;
dies:                     ; if not, the cell dies
mov byte [es:di], 0       ; set pixel to black
mov byte [fs:di], 0       ; set state to 0
jp next                   ; next iteration
grows:                    ; if the cell is alive, and has 2 or 3, then it's "aging"
mov dl, [es:di]           ; fetch current "age", which is represented by it's color value in ES
inc dl                    ; increment the age
cmp dl, 64                ; but set a maximum to avoid overflow (actually not necessary, it won't reach the upper limit)
jnz grow                  ;
mov dl, 63                ; 
grow:                     ;
mov [es:di], dl           ; update pixel color with the new value
next:                     ;
loop evolution            ; and on to the next iteration

in al, 60h                ; ESC test
dec al                    ; to exit program
jnz main_loop

mov ax, 03h               ; back to textmode
int 10h

ret                       ; yay.

