;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Trisasm
;;  Whizart, 01 November 2013
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org 100h

;------------------------------------------------------------------------------
; constants

lower_edge_line         equ     200
les_ofs                 equ     15          ; do not change
end_of_pieces_marker    equ     13h         ; do not change
state_rotate_mask       equ     1
state_ok                equ     128
surroundings_width      equ     16
surroundings_set_match  equ     11

mov bp, 320             ; used instead of literal, -3B

;------------------------------------------------------------------------------
; init

;; piece array
mov di, piece_info_ofs
;; assume cx = 00ffh = 3 * 85 -> prepare array for 85 pieces
rep stosw
mov al, end_of_pieces_marker
stosb

;; video
int 10h                 ; al = 13h from above
les ax, [bx]            ; es ~ a000h

;------------------------------------------------------------------------------
; main loop

main:

mov si, piece_info_ofs
  
iterate_over_pieces:

;; load piece information
lodsw
cmp al, end_of_pieces_marker
je main
xchg ax, di             ;; di = piece
lodsw                   ;; ax = position
xchg ax, di             ;; ax = piece, di = position
test ax, ax             ;; check whether we have a piece at this place of array
jnz have_piece

;; if no piece in slot, create a new piece
create_piece:
    rdtsc               ;; fill ax with sufficient noisy information (cpu ticks)
    and ax, 63          ;; not instantly create new piece -> distribution in y
    jnz advance_to_next_piece
    in al, 40h          ;; another pseudo-random number
    mov di, ax
    in al, 40h
    add di, ax          ;; di = 0 .. 510
    aam 7               ;; al %= 7
    cbw                 ;; ah = 0
    mov [si], ax        ;; store color and initial state
    mov bx, pieces
    xlatb               ;; al = pieces+al -> get piece shape to al
    mov [si-4], ax      ;; store piece (shape) 

have_piece:

;; remove piece
xor bx, bx
call draw_piece

inc si      ;; [si] often used

;; shift, rotate, or already ok?
test byte [si], state_ok

jnz lookahead

test byte [si], state_rotate_mask
jz shift_right

;; rotate piece
mov cl, 16
mov dx, 0eeeeh
lp00:
    rol ax, 4
    rcl dx, 1
    jc lp01
    ror ax, 1
lp01:
    loop lp00

xchg ax, dx

dec di      ; -1B, spares jump

shift_right:
    inc di

after_state:

mov [si-5], ax
xor byte [si], state_rotate_mask

lookahead:

push di

;; virtually drop down until collision
drop_until_collision:
    add di, bp
    call collision_detection
    je drop_until_collision

;; check whether collision count matches width of the piece
evaluate_set_collision_count:
    mov cl, 4
    mov dx, 1111h
evaL:
    test ax, dx
    jz evaL0
    dec bx
evaL0:
    shl dx, 1
    loop evaL
    and byte [si], 127      ; remove state ok flag -> check over and over again
    cmp bl, 1
    jne prejoin

match:

;; apply heuristics to fill holes rather then building mountains
mov cl, surroundings_width

eval_surroundings:
    inc di
    push cx
    call collision_detection
    setne bl            ;; each collision just counts 1
    add bh, bl
    pop cx
    loop eval_surroundings

cmp bh, surroundings_set_match
jb prejoin
mov byte [si], state_ok

prejoin:
pop di

stable_state:

;; piece down
dec si

add di, bp

;; prepare color
mov bh, [si]
shl bh, 1
or bh, 32

;; check whether to drop piece
call collision_detection
je actually_draw_piece

;; collision -> change color
sub di, bp

xor word [si-4], ax
xor bh, 48
or bh, 8
  
actually_draw_piece:

xor bl, bl
call draw_piece

mov [si-2], di

advance_to_next_piece:

lodsw     ; si += 2

;; ESC check
in al, 60h
dec ax
jnz iterate_over_pieces

;; clean up and exit (falls through collision check)
mov al, 3
int 10h

;------------------------------------------------------------------------------
; draws/removes piece & collision check
; input:
;    ax: piece shape
;    bl != 0 -> do collision check (call collision_detection to set bl)
;    bh = color of piece (0 to remove)
;    di = poisition (upper left corner)
; changes: bx, cx, dx
; output (relevant for collision check)
;    zero flag: 1 if no collision, 0 if any collision
;    bl = collisions + 1

collision_detection:
    mov bl, 1
draw_piece:
    push di
    mov cl, 16
dp0:
    mov dl, 0eeh
dp1:
    ror ax, 1
    jnc dp2             ;; pixel not in shape    
    test bl, bl
    jz draw             ;; no collision check -> just draw pixel    
    cmp di, 320*lower_edge_line+les_ofs
    ja col              ;; bottom line reached -> mark as "collision"
    test byte [es:di], 16
    jz dp2              ;; actual collision with another piece
col:
    inc bx              ;; count collisions
    jmp dp2             ;; skip drawing
draw:
    mov byte [es:di], bh      
dp2:
    inc di
    rol dl, 1
    jc dp3
    add di, 316         ;; every 4th pixel -> cr to next line
dp3:
    loop dp1
    pop di
    cmp bl, 1           ;; needed out there... 
    ret

;------------------------------------------------------------------------------
; the encoded pieces:

pieces          db      072h, 036h, 063h, 0f0h, 033h, 017h, 071h

;; information about pieces in field:
piece_info_ofs  equ     $
