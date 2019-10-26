; ASM_MAN v1.0
;
; You can use this code for whatever you want, but tell me if you do so:
; Gerard Monells - Chico_GMB@hotmail.com
;
; Here's some function-conventions:
; The parameters in a function are passed by using the stack-passing method,
; pushed from right to left. When returning, this parameters are poped from
; the stack, so you don't have to do it again. The dinamic link is only made
; when there are parameters in the funcion. All the registers remains
; unchanged, EXCEPT if some result is generated (not void) the eax/ax/al
; (DWORD/WORD/BYTE) register contains this result.
;
; INT = DWORD
; SHORT = WORD
;
; Examples:
;
;       void func1(int p1, short p2)
;           - push word ptr p2
;           - push dword ptr p1
;           - void return, eax remains unchanged
;
;       short func2()
;           - nothing to push
;           - return in ax (2 bytes)

.model large
.386
    point equ 0700h+'ú'
    item equ 8F00h+'ú'
    wall equ 0900h+219
    void equ 0700h+' '
    comecoco equ 0F01h
    cocos equ 0F2Ah
    frozen_cocos equ 702Ah              ;change this to change images
    sc_esc equ 1
    sc_spc equ 57
    sc_up equ 72
    sc_down equ 80
    sc_left equ 75
    sc_right equ 77                     ;some scan_codes
    direc_null equ 0
    direc_up equ 1
    direc_down equ 4
    direc_left equ 2
    direc_right equ 3
    opposite_direc equ 5                ;the directions
    false equ 0
    true equ not false                  ;boolean expressions
    screen_seg equ 0B800h               ;screen segment
    num_levels equ 3                    ;how many levels have the game?
    keyb_id equ 9
    timer_id equ 8                      ;some IRQ identifiers
    type_exit equ 1
    type_dead equ 2
    type_passed equ 3                   ;types of final
    veloc equ 3                         ;all move every this interruptions
    console_color equ 07h               ;which attribute has the console?
    long_exit equ 47
    long_passed equ 33
    long_dead equ 34                    ;longs of some text strings
    frozen_time equ 25                  ;how many time will be cocos frozen?
.data
;level1 = C matrix, copy of the screen memory
    level1 dw 81 dup(wall),void,9 dup(point),wall,item,65 dup(point),item
        dw 2 dup(wall),10 dup(point),wall,point,3 dup(21 dup(wall),point)
        dw 11 dup(wall),2 dup(point,wall),41 dup(point),wall,21 dup(point)
        dw wall,point,2 dup(wall),12 dup(point),wall,2 dup(point,19 dup(wall))
        dw point,wall,2 dup(point,9 dup(wall)),2 dup(point,wall),wall,point
        dw 10 dup(wall),2 dup(point,wall),37 dup(point),2 dup(wall,point)
        dw 2 dup(wall,9 dup(point)),wall,point,2 dup(wall),point,wall
        dw 10 dup(point),2 dup(wall,point),35 dup(wall),point,wall
        dw 3 dup(point),wall,point,9 dup(wall),point,9 dup(wall),point
        dw 2 dup(wall),point,wall,point,8 dup(wall),point,wall,39 dup(point)
        dw 5 dup(wall),21 dup(point),2 dup(wall),12 dup(point),wall,point
        dw 37 dup(wall),7 dup(point),19 dup(wall),point,2 dup(wall),item
        dw wall,point,8 dup(wall),23 dup(point),item,15 dup(point),wall
        dw point,5 dup(wall),21 dup(point),2 dup(wall),point,wall,point
        dw 9 dup(point),wall,point,19 dup(wall),point,15 dup(wall),point
        dw wall,point,wall,3 dup(point),wall,point,19 dup(wall),item,wall
        dw wall,point,10 dup(wall),point,wall,39 dup(point),3 dup(wall,point)
        dw 20 dup(point),2 dup(wall),12 dup(point),21 dup(wall),point
        dw 19 dup(wall),2 dup(point,wall),point,19 dup(wall),point,2 dup(wall)
        dw point,10 dup(wall),43 dup(point),wall,23 dup(point),2 dup(wall)
        dw 12 dup(point),21 dup(wall),point,21 dup(wall),point,21 dup(wall)
        dw point,2 dup(wall),point,10 dup(wall),67 dup(point),2 dup(wall)
        dw 12 dup(point),21 dup(wall),point,21 dup(wall),point,21 dup(wall)
        dw point,2 dup(wall),point,32 dup(wall),point,21 dup(wall),point
        dw 21 dup(wall),point,2 dup(wall),item,76 dup(point),item
        dw 81 dup(wall)
;level2 = C matrix, copy of the screen memory
    level2 dw 81 dup(wall),item,37 dup(point),item,38 dup(point),item
        dw 2 dup(wall),point,36 dup(wall),point,39 dup(wall),point
        dw 2 dup(wall),78 dup(point),2 dup(wall),point,36 dup(wall)
        dw point,39 dup(wall),point,2 dup(wall),78 dup(point),2 dup(wall)
        dw point,36 dup(wall),point,39 dup(wall),point,2 dup(wall)
        dw 78 dup(point),16 dup(wall),point,13 dup(wall),point,9 dup(wall)
        dw point,9 dup(wall),point,13 dup(wall),point,31 dup(wall)
        dw 15 dup(point),wall,17 dup(point),wall,15 dup(point),31 dup(wall)
        dw point,13 dup(wall),item,wall,7 dup(point),void,9 dup(point),wall
        dw item,13 dup(wall),point,31 dup(wall),15 dup(point),19 dup(wall)
        dw 15 dup(point),16 dup(wall),wall,78 dup(point),2 dup(wall),point
        dw 36 dup(wall),point,39 dup(wall),point,2 dup(wall),78 dup(point)
        dw 2 dup(wall),point,36 dup(wall),point,39 dup(wall),point
        dw 2 dup(wall),78 dup(point),2 dup(wall),point,36 dup(wall),point
        dw 39 dup(wall),point,2 dup(wall),item,37 dup(point),item
        dw 38 dup(point),item,81 dup(wall)
;level3 = C matrix, copy of the screen memory
    level3 dw 81 dup(wall),item,37 dup(point),item,38 dup(point),item,wall
        dw 15 dup(wall,point),20 dup(wall),15 dup(point,wall)
        dw 15 dup(wall,point),20 dup(point),15 dup(point,wall)
        dw 15 dup(wall,point),20 dup(wall),15 dup(point,wall)
        dw 15 dup(wall,point),20 dup(point),15 dup(point,wall)
        dw 15 dup(wall,point),9 dup(wall),2 dup(point),9 dup(wall)
        dw 15 dup(point,wall),16 dup(wall,point),16 dup(point)
        dw 16 dup(point,wall),16 dup(wall,point),16 dup(point)
        dw 16 dup(point,wall),wall,77 dup(point),item,2 dup(wall),item
        dw 77 dup(point),wall,16 dup(wall,point),16 dup(point)
        dw 16 dup(point,wall),16 dup(wall,point),16 dup(point)
        dw 16 dup(point,wall),15 dup(wall,point),9 dup(wall),2 dup(point)
        dw 9 dup(wall),15 dup(point,wall),15 dup(wall,point),20 dup(point)
        dw 15 dup(point,wall),15 dup(wall,point),20 dup(wall)
        dw 15 dup(point,wall),15 dup(wall,point),20 dup(point)
        dw 15 dup(point,wall),15 dup(wall,point),20 dup(wall)
        dw 15 dup(point,wall),wall,item,37 dup(point),void,item
        dw 37 dup(point),item,81 dup(wall)

;level = array of pointers to the levels
    level dd level1,level2,level3
;some initial positions
    ini_pos_comecoco dd (80*1+1)*2,(80*10+38)*2,(80*18+39)*2
    ini_pos_cocos dd (80*1+12)*2,(80*1+1)*2,(80*7+31)*2
        dd (80*1+78)*2,(80*1+78)*2,(80*7+48)*2
        dd (80*18+1)*2,(80*18+1)*2,(80*12+31)*2
        dd (80*18+78)*2,(80*18+78)*2,(80*12+48)*2
;the control variables
    final db ?
    pant dd ?
    old_timer dd ?
    old_keyb dd ?
    end_type db ?
    life db ?
    remaining_dots dd ?
    paused db ?
    pret db ?
    direc db ?
    comecoco_coors dd ?
    cocos_coors dd 4 dup(?)
    whats_behind_cocos dw 4 dup(?)
    cocos_direc db 4 dup(?)
    is_coco_frozen db 4 dup(?)
    cocos_frozen_time db 4 dup(?)
    num_int_timer dd ?
    time_to_move db ?
;some game strings
    str_life db 'Life'
    life_bar db 3 dup(1)
    str_dots db 'Dots'
    dots_bar db 3 dup(?)
    hello1_str db 'Programmed by: Gerard Monells'
    hello2_str db 'Chico_GMB@hotmail.com'
    str_paused db 'PAUSED'
    str_notpaused db 6 dup(32)
    str_exit db 'You exited the game. I will be waiting for you.'
    str_passed db 'You passed all levels! Good work.'
    str_dead db 'You have been defeated. Try again.'
.stack 100h
.code
; void redraw_life();
; IN: nothing
; OUT: screen shows your life
redraw_life proc
    push eax

    push dword ptr (80*21+10)*2
    movzx eax,life
    push eax
    push ds
    lea ax,life_bar
    push ax
    call cs:print

    pop eax
    ret
redraw_life endp

; void erase_cocos();
; IN: nothing
; OUT: screen doesn't have any coco
erase_cocos proc
    push esi ecx edx es

    mov dx,screen_seg
    mov es,dx

    mov esi,0
for01:
    mov ecx,cocos_coors[esi*4]
    mov dx,whats_behind_cocos[esi*2]
    mov es:[ecx],dx

    inc esi
    cmp esi,4
    jne for01

    pop es edx ecx esi
    ret
erase_cocos endp

; int which_coco_is_here(int coors);
; IN: coors has a valid value for the screen matrix
; OUT: eax <- identifier of the coco with the coors given, -1 if none
which_coco_is_here proc
    push ebp
    mov ebp,esp
    push esi ebx

    mov ebx,8[ebp]
    mov eax,-1
    mov esi,0
for02:
    cmp cocos_coors[esi*4],ebx
    jne else01
    mov eax,esi
else01:
    inc esi
    cmp esi,4
    jne for02

    pop ebx esi
    pop ebp
    ret 4
which_coco_is_here endp

; void signal_all_freeze();
; IN: nothing
; OUT: all the cocos are frozen, frozen time remaining is frozen_time
signal_all_freeze proc
    push esi eax es
    mov ax,screen_seg
    mov es,ax

    mov esi,0
for03:
    mov eax,cocos_coors[esi*4]
    mov es:[eax],word ptr frozen_cocos
    mov cocos_frozen_time[esi],frozen_time
    mov is_coco_frozen[esi],true

    inc esi
    cmp esi,4
    jne for03

    pop es eax esi
    ret
signal_all_freeze endp

; void interrupt rsi_timer();
; IN: nothing
; OUT: count one time, if this time is veloc one move is done
rsi_timer proc
    push eax ebx ecx edx es esi
    mov ax,@data
    mov ds,ax

    cmp paused,true
    je end_interrupt01

    inc num_int_timer
    cmp num_int_timer,veloc
    jne end_interrupt01

    mov ax,screen_seg
    mov es,ax
    mov num_int_timer,0

    cmp pret,direc_null
    je ignore_pret

    movzx eax,byte ptr pret
    push eax
    mov eax,comecoco_coors
    push eax
    call cs:where_are_you_going

    cmp es:[eax],word ptr wall
    je ignore_pret
    mov al,pret
    mov direc,al

ignore_pret:
    movzx eax,byte ptr direc
    push eax
    mov eax,comecoco_coors
    mov es:[eax],word ptr void
    push eax
    call cs:where_are_you_going

    mov bx,es:[eax]
    cmp bx,cocos
    je collision_coco
    cmp bx,frozen_cocos
    je collision_frozen

    cmp bx,wall
    je collision_wall
    cmp bx,void
    je moving_to_void
    dec remaining_dots
    call cs:redraw_dots
    cmp bx,item
    jne moving_to_void
    call cs:signal_all_freeze
    jmp moving_to_void
collision_coco:
    mov final,true
    mov end_type,type_dead
    call cs:erase_cocos
    jmp end_switch01
collision_frozen:
    push eax
    mov esi,eax
    call cs:which_coco_is_here
    mov dx,whats_behind_cocos[eax*2]
    mov es:[esi],dx
    push eax
    call cs:regenerate_coco
    call cs:add_life
    call cs:redraw_life

    jmp ignore_pret
collision_wall:
    mov eax,comecoco_coors
moving_to_void:
    mov es:[eax],word ptr comecoco
    mov comecoco_coors,eax

end_switch01:
    cmp remaining_dots,0
    jne not_finished
    mov final,true
    mov end_type,type_passed
    jmp end_interrupt01
not_finished:

    mov al,time_to_move
    not al
    mov time_to_move,al

    mov esi,0
for04:
    cmp final,true
    je end_interrupt01

    cmp is_coco_frozen[esi],true
    je else02
    push esi
    call cs:good_behaviour
    jmp else03
else02:
    push esi
    call cs:bad_behaviour
else03:

    inc esi
    cmp esi,4
    jne for04

end_interrupt01:
    mov al,20h
    out 20h,al
    pop esi es edx ecx ebx eax
    iret
rsi_timer endp

; void regenerate_coco(int id);
; IN: id is a valid coco identifier
; OUT: coco number id has been put in his initial position for this level
regenerate_coco proc
    push ebp
    mov ebp,esp
    push es esi eax ecx edx

    mov esi,8[ebp]
    mov ax,screen_seg
    mov es,ax

    mov dx,num_levels
    mov ax,si
    mul dx
    rol edx,16
    mov dx,ax
    mov eax,pant
    shl eax,2
    mov eax,ini_pos_cocos[eax+edx*4]
    mov cocos_coors[esi*4],eax
    mov cx,es:[eax]
    mov whats_behind_cocos[esi*2],cx
    mov is_coco_frozen[esi],false
    mov es:[eax],word ptr cocos
    mov cocos_direc[esi],direc_null

    pop edx ecx eax esi es
    pop ebp
    ret 4
regenerate_coco endp

; void move_to_direction(int id);
; IN: id is a valid coco identifier
; OUT: coco id has moved to his direction, collisions has been detected
move_to_direction proc
    push ebp
    mov ebp,esp
    push eax ebx ecx esi es

    mov esi,8[ebp]
    mov ax,screen_seg
    mov es,ax
    mov eax,cocos_coors[esi*4]
    mov bx,whats_behind_cocos[esi*2]
    mov es:[eax],bx

    movzx eax,cocos_direc[esi]
    push eax
    mov eax,cocos_coors[esi*4]
    push eax
    call cs:where_are_you_going
    mov bx,es:[eax]

    mov cx,cocos
    cmp is_coco_frozen[esi],true
    jne else04
    mov cx,frozen_cocos
else04:

    cmp bx,cocos
    je there_is_a_coco
    cmp bx,frozen_cocos
    je there_is_a_frozen_coco
    cmp bx,comecoco
    je there_is_a_comecoco

    mov whats_behind_cocos[esi*2],bx
    mov cocos_coors[esi*4],eax
    mov es:[eax],cx
    jmp end_of_move

there_is_a_coco:
there_is_a_frozen_coco:
    mov eax,cocos_coors[esi*4]
    mov es:[eax],cx
    mov cocos_direc[esi],direc_null
    jmp end_of_move

there_is_a_comecoco:
    cmp is_coco_frozen[esi],true
    je else05

    mov ecx,comecoco_coors
    mov es:[ecx],word ptr void
    call cs:erase_cocos

    mov final,true
    mov end_type,type_dead
    jmp end_of_move

else05:
    push esi
    call cs:regenerate_coco
    call cs:add_life
    call cs:redraw_life
end_of_move:
    pop es esi ecx ebx eax
    pop ebp
    ret 4
move_to_direction endp

; void add_life();
; IN: nothing (information is taken from the global variables)
; OUT: you gain one life, limited to 3
add_life proc
    inc life
    cmp life,3
    jbe end_add_life
    mov life,3
end_add_life:
    ret
add_life endp

; short truerand(short max);
; IN: max > 0
; OUT: ax <- random number (0..max-1)
; COMMENTS: I don't know how it works. I copied the code from elsewhere
proc truerand
        push bp
        mov bp,sp
        pusha

        mov ecx,100
        cli
for05:
        mov al,06h
        out 43h,al
        jmp $+2
        in al,40h
        xor dl,al
        jmp $+2
        in al,40h
        xor dl,al

        mov bx,dx
        mov di,si
        shl dx,11
        shl si,11
        shr bx,5
        shr di,5
        or dx,di
        or si,bx
        loop for05

        sti
        xchg ax,dx
        xor dx,dx
        mov bx,6[ebp]
        div bx

        mov [ebp-2],dx
        popa
        pop bp
        ret 2
truerand endp

; void choose_direction(int id);
; IN: id must be a valid coco identifier
; OUT: coco number id has a new direction following this rules:
;    -direction after and before can't be opposite
;    -there isn't a wall to the new direction (yo can move there)
choose_direction proc
    push ebp
    mov ebp,esp
    push es esi edi eax

    mov esi,8[ebp]
    mov ax,screen_seg
    mov es,ax
    mov eax,0
while01:
    push word ptr 4
    call truerand
    inc ax
    mov edi,esi
    movzx edi,cocos_direc[edi]
    add edi,eax
    cmp di,opposite_direc
    je while01

    push eax
    mov edi,eax
    mov eax,cocos_coors[esi*4]
    push eax
    call cs:where_are_you_going
    cmp es:[eax],word ptr wall
    je while01
    mov eax,edi
    mov cocos_direc[esi],al
    
    pop eax edi esi es
    pop ebp
    ret 4
choose_direction endp

; void good_behaviour(int id);
; IN: id is a valid coco identifier
; OUT: id coco has moved in an intelligent manner
good_behaviour proc
    push ebp
    mov ebp,esp
    push dword ptr 8[ebp]
    call choose_direction
    push dword ptr 8[ebp]
    call move_to_direction
    pop ebp
    ret 4
good_behaviour endp

; void bad_behaviour(int id);
; IN: id is a valid coco identifier
; OUT: id coco has moved in a non-intelligent manner, moving every two times
bad_behaviour proc
    push ebp
    mov ebp,esp
    push esi eax es

    cmp time_to_move,true
    jne else06

    mov esi,8[ebp]
    push esi
    call choose_direction
    push esi
    call move_to_direction
    mov al,cocos_frozen_time[esi]
    dec al
    jnz else07
    mov is_coco_frozen[esi],false
    mov ax,screen_seg
    mov es,ax
    mov eax,cocos_coors[esi*4]
    mov es:[eax],word ptr cocos
else07:
    mov cocos_frozen_time[esi],al
else06:
    pop es eax esi
    pop ebp
    ret 4
bad_behaviour endp

; void interrupt rsi_keyb();
; IN: nothing
; OUT: a keyboard event has been served, direc and final can be modified
rsi_keyb proc
    push eax
    mov ax,@data
    mov ds,ax

    in al,60h
    bt ax,7
    jc end_interrupt02
    cmp al,sc_spc
    jne else08
    mov ah,paused
    not ah
    mov paused,ah
    call cs:redraw_paused

    jmp end_interrupt02
else08:
    cmp paused,true
    je end_interrupt02
    cmp al,sc_esc
    jne else09
    mov final,true
    mov end_type,type_exit
    jmp end_interrupt02
else09:
    cmp al,sc_up
    jne else10
    mov pret,direc_up
    jmp end_interrupt02
else10:
    cmp al,sc_down
    jne else11
    mov pret,direc_down
    jmp end_interrupt02
else11:
    cmp al,sc_left
    jne else12
    mov pret,direc_left
    jmp end_interrupt02
else12:
    cmp al,sc_right
    jne end_interrupt02
    mov pret,direc_right

end_interrupt02:
    mov al,20h
    out 20h,al
    pop eax
    iret
rsi_keyb endp

; void prepare_screen();
; IN: taken from global variables
; OUT: screen filled with the level(pant), eax <- num(point)+num(item)
prepare_screen proc
    push esi gs ebx ecx es

    mov eax,pant
    mov bx,word ptr level+2[eax*4]
    mov es,bx
    movzx ebx,word ptr level[eax*4]

    mov esi,0
    mov ax,screen_seg
    mov gs,ax
    mov eax,0
for06:
    mov cx,es:[ebx+esi*2]
    cmp cx,point
    jne else13
    inc eax
else13:
    cmp cx,item
    jne else14
    inc eax
else14:
    mov gs:[esi*2],cx
    inc esi
    cmp esi,80*20
    jne for06

    pop es ecx ebx gs esi
    ret
prepare_screen endp

; void good_behaviour();
; IN: nothing
; OUT: screen cleared
clear proc
    push eax es

    mov ax,screen_seg
    mov es,ax
    mov eax,0
for07:
    mov es:[eax*2],word ptr 0720h
    inc eax
    cmp eax,80*25
    jne for07

    pop es eax
    ret
clear endp

; void prepare_console();
; IN: nothing
; OUT: screen's down-region has been filled with the console
prepare_console proc
    push eax es

    mov ax,screen_seg
    mov es,ax
    mov eax,80*20
for08:
    mov es:[eax*2],word ptr 0720h
    inc eax
    cmp eax,80*25
    jne for08

    push dword ptr (80*21+5)*2
    push dword ptr 4
    push ds
    lea ax,str_life
    push ax
    call cs:print
    call cs:redraw_life
    push dword ptr (80*21+67)*2
    push dword ptr 4
    push ds
    lea ax,str_dots
    push ax
    call cs:print
    call cs:redraw_dots
    call cs:redraw_paused
    push dword ptr (80*23+22)*2
    push dword ptr 29
    push ds
    lea ax,hello1_str
    push ax
    call cs:print
    push dword ptr (80*24+27)*2
    push dword ptr 21
    push ds
    lea ax,hello2_str
    push ax
    call cs:print

    pop es eax
    ret
prepare_console endp

; int modif_VI(int id, int pointer);
; IN: id is a valid IRQ identifier, pointer points to the new RSI
; OUT: interruption array has been modified, eax <- old pointer
modif_VI proc
    push ebp
    mov ebp,esp
    push es ebx ecx

    mov ecx,8[ebp]
    mov ebx,12[ebp]
    mov ax,0
    mov es,ax
    mov eax,es:[ecx*4]
    mov es:[ecx*4],ebx

    pop ecx ebx es
    pop ebp
    ret 4
modif_VI endp

; void init_cocos();
; IN: taken from global variables
; OUT: all the cocos (including comecoco) are in their initial positions
init_cocos proc
    push eax ebx ecx esi edi es

    mov direc,direc_null
    mov pret,direc_null
    mov ax,screen_seg
    mov es,ax
    mov ebx,pant
    mov eax,ini_pos_comecoco[ebx*4]
    mov comecoco_coors,eax
    mov es:[eax],word ptr comecoco

    mov esi,0
    mov edi,0
    shl ebx,2
    mov time_to_move,byte ptr true
for09:
    mov eax,ini_pos_cocos[ebx+edi*4]
    mov cocos_coors[esi*4],eax
    mov cx,es:[eax]
    mov whats_behind_cocos[esi*2],cx
    mov is_coco_frozen[esi],false

    mov es:[eax],word ptr cocos

    mov cocos_direc[esi],direc_null

    inc esi
    add edi,num_levels
    cmp esi,4
    jne for09

    pop es edi esi ecx ebx eax
    ret
init_cocos endp

; int where_are_you_going(int pos, int direc);
; IN: pos is aa valid screen position, direc is a correct direction
; OUT: eax <- where will you be if you are in pos and move to dir
where_are_you_going proc
    push ebp
    mov ebp,esp

    push ebx

    mov eax,8[ebp]
    mov ebx,12[ebp]
    cmp bl,direc_up
    jne else15
    sub eax,80*2
else15:
    cmp bl,direc_down
    jne else16
    add eax,80*2
else16:
    cmp bl,direc_left
    jne else17
    sub eax,1*2
else17:
    cmp bl,direc_right
    jne else18
    add eax,1*2
else18:

    pop ebx
    pop ebp
    ret 8
where_are_you_going endp

; void print(int pointer, int pos, int num_chars);
; IN: num_chars > 0, pointer points to string, pos is a valid screen address
; OUT: num_chars characters taken from the buffer [pointer] are written
;    consecutively in the screen begining from the pos position
print proc
    push ebp
    mov ebp,esp
    push eax ebx ecx esi edi es gs

    mov ax,screen_seg
    mov es,ax
    mov gs,10[ebp]
    movzx eax,word ptr 8[ebp]
    mov ebx,12[ebp]
    mov esi,16[ebp]
    mov edi,0
    mov ch,console_color
for10:
    mov cl,gs:[eax]
    mov es:[esi],cx
    add esi,2
    inc eax

    inc edi
    cmp edi,ebx
    jne for10

    pop gs es edi esi ecx ebx eax
    pop ebp
    ret 12
print endp

; void redraw_paused();
; IN: taken from global variables
; OUT: if paused, printed in the console
;    if not, erased from the screen
redraw_paused proc
    push ax
    cmp paused,false
    je not_paused
    lea ax,str_paused
    jmp paused_done
not_paused:
    lea ax,str_notpaused
paused_done:
    push dword ptr (80*21+34)*2
    push dword ptr 6
    push ds
    push ax
    call cs:print
    pop ax
    ret
redraw_paused endp

; void redraw_dots();
; IN: taken from global variables
; OUT: screen (console) shows the number of dots remaining
redraw_dots proc
    push ax
    call cs:dots2str
    push dword ptr (80*21+72)*2
    push dword ptr 3
    push ds
    lea ax,dots_bar
    push ax
    call cs:print
    pop ax
    ret
redraw_dots endp

; void dots2str();
; IN: taken from global variables
; OUT: global string dots_bar contains the conversion into a string
;    of the variable remaining_dots
dots2str proc
    push eax ebx esi
    mov eax,remaining_dots
    mov esi,3
    mov bl,10
for11:
    div bl
    add ah,48
    mov dots_bar-1[esi],ah
    mov ah,0
    dec esi
    jnz for11
    pop esi ebx eax
    ret
dots2str endp

.startup
    mov pant,0
main_loop:                              ;for (pant=0;pant<num_levels;pant++)
    call prepare_screen
    mov remaining_dots,eax              ;prepare the screen and count dots

    mov life,3
    mov final,false
    mov num_int_timer,0
    mov paused,true                     ;some game variables

    call prepare_console                ;prepare console
    call init_cocos                     ;init the cocos

    push cs
    lea ax,rsi_timer
    push ax
    push dword ptr timer_id
    call modif_VI
    mov old_timer,eax                   ;change the timer RSI

    push cs
    lea ax,rsi_keyb
    push ax
    push dword ptr keyb_id
    call modif_VI
    mov old_keyb,eax                    ;change the keyboard RSI

wait_loop:
    cmp final,true
    jne wait_loop                       ;while (!final) {}

    mov eax,old_timer
    push eax
    push dword ptr timer_id
    call modif_VI                       ;restore the timer RSI

    mov eax,old_keyb
    push eax
    push dword ptr keyb_id
    call modif_VI                       ;restore the keyboard RSI

    cmp end_type,type_exit              ;why have we finished?
    jne else19
    jmp you_have_exited
else19:
    cmp end_type,type_dead
    jne else20
    dec life                            ;we are dead, life-- and if remaining
    jz you_are_dead                     
    mov final,false
    mov paused,true
    call init_cocos                     
    call prepare_console                ;init cocos and prepare console

    push cs
    lea ax,rsi_timer
    push ax
    push dword ptr timer_id
    call modif_VI
    mov old_timer,eax                   ;change the timer RSI

    push cs
    lea ax,rsi_keyb
    push ax
    push dword ptr keyb_id
    call modif_VI
    mov old_keyb,eax                    ;change the keyboard RSI

    jmp wait_loop                       ;and back to the game
else20:
    inc pant                            ;we passed the level, if not finished

    cmp pant,num_levels
    jne main_loop                       ;return to the for statement
passed_all_levels:
    lea ax,str_passed
    mov ebx,long_passed                 ;passed all levels, prepare message
    jmp send_message
you_are_dead:
    lea ax,str_dead
    mov ebx,long_dead                   ;you are dead, prepare message
    jmp send_message
you_have_exited:
    lea ax,str_exit
    mov ebx,long_exit                   ;you have exited, prepare message
send_message:

    call clear                          ;clear the screen
    push dword ptr (80*15+0)*2
    push ebx
    push ds
    push ax
    call print                          ;send your message
    push dword ptr (80*17+0)*2
    push dword ptr 29
    push ds
    lea ax,hello1_str
    push ax
    call print                          ;send MY first message
    push dword ptr (80*18+0)*2
    push dword ptr 21
    push ds
    lea ax,hello2_str
    push ax
    call print                          ;send MY second message
.exit
end                                     ;back to DOS
