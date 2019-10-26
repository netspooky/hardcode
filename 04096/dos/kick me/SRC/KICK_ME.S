; ***************************************************************************
; ***************************************************************************
; **                                                                       **
; **                               KICK ME.                                **                                
; **                      Alain BROBECKER, aka Baah.                       ** 
; **                              July 1995.                               **  
; **                                                                       **
; ***************************************************************************
; ***************************************************************************

            .386                    ; The best processor ever... (Arf...)


  include   rincbin.inc
  include   memlib.inc
  include   mode0lib.inc
  include   initmodx.inc
  include   gen_spr.inc
  include   put_pal.inc
  nb_balls=7
  gravity=2

; ***************************************************************************
; *******************************  MACROS  **********************************
; ***************************************************************************
;컴컴 Vertical synchronisation 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
; Affects al and dx.
wait_vsync              MACRO
                        LOCAL @@vsync_activated,@@vsync_desactivated
  mov       dx,03dah                ; Input status 1 port. 
@@vsync_activated:
  in        al,dx
  test      al,1000b                ; Test bit 3=vertical retrace.
  jne       @@vsync_activated       ; Wait till activated.
@@vsync_desactivated:
  in        al,dx
  test      al,1000b
  je        @@vsync_desactivated    ; And then wait till desactivated. 
                        ENDM

;컴컴 Keyboard flush 컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
flush_keyboard          MACRO  
                        LOCAL @@flush_kbd_loop
@@flush_kbd_loop:
  mov       ah,01h                  ; Read char.
  int       16h
  mov       ah,0                    ; Another char? 
  int       16h
  jZ        @@flush_kbd_loop
                        ENDM


; ***************************************************************************
; ***************************************************************************
; ********************************  CODE  ***********************************
; ***************************************************************************
; ***************************************************************************
THE_CODE                SEGMENT USE16                     
                        Assume CS:THE_CODE,SS:THE_STACK

;==== Main Program ==========================================================
beginning               PROC NEAR
  call      main_memory_release     ; A good idea to release memory.
  
;**** The textual presentation.
  call      init_mode0              ; Text mode.              
  call      hide_cursor0            ; Hide the prompt.
  mov       ax,0b800h               ; Draw 'baah.' logo.
  mov       es,ax
  call      baah_text_logo
  mov       ax,cs                   ; Print text.
  mov       ds,ax
  mov       si,offset cs:text1
  call      print_text0

;**** Allocate memory for code buffer.
  mov       bx,1000
  call      allocate_memory         
  mov       code_adress+2,ax        

;**** Generate the code for the sprite drawing.
  mov       ax,cs                   ; Make ds:si point on sprite datas.
  mov       ds,ax
  mov       si,offset cs:sprite
  mov       es,code_adress+2        ; Make es:di point on code buffer.
  xor       di,di
  call      gen_sprite_drawing

;**** Allocate memory for fractal buffer.
  mov       bx,4800                 
  call      allocate_memory         
  mov       fractal_seg,ax    
  
;**** Calculate the julia set into the fractal buffer.
  mov       ds,ax                   ; Calculate
  call      julia_set

;**** Well, fractal is calculated, wait for a key to be pressed.
  mov       ax,0b800h               ; es points on text ram.
  mov       es,ax
  mov       ax,cs                   ; Print the text.
  mov       ds,ax
  mov       si,offset cs:text2
  call      print_text0
fractal_done:
  mov       ah,01h                  ; Keyboard scan.
  int       16h
  jz        fractal_done
  flush_keyboard                    ; It has to be done...

;**** Switch to mode X, and put the palette.
  call      init_modeX
  mov       ax,cs                   ; Make ds:si point on palette.  
  mov       ds,ax
  mov       si,offset cs:palette
  call      put_palette
  
;**** Copy the fractal into the three buffers.  
  mov       ds,fractal_seg          ; Make ds:si point on fractal.
  xor       si,si
  mov       ax,0a000h               ; Make es:di point on screen bank 1.
  mov       es,ax
  xor       di,di                   
  call      copy2vram
  mov       di,240*80               ; es:di points on screen bank 2.
  call      copy2vram
  mov       di,480*80               ; es:di points on source screen. 
  call      copy2vram


;----------------------------------------------------------------------------
; The main demo....

one_frame:
  wait_vsync

;**** Swap between work banks and show banks.
  mov       bx,show_scr_ofs         ; Swap screen banks.
  mov       cx,work_scr_ofs
  mov       show_scr_ofs,cx
  mov       work_scr_ofs,bx
  mov       bx,show_spr_ofs         ; Swap sprites offsets banks. 
  mov       cx,work_spr_ofs
  mov       show_spr_ofs,cx
  mov       work_spr_ofs,bx
  
;**** Clear the sprites.
  mov       dx,03c4h                ; Sequencer index.
  mov       ax,0f02h                ; Map mask subregister.
  out       dx,ax                   ; Access all planes.
  mov       dx,03ceh                ; Graphic Controller.
  mov       al,05h                  ; GraphMode subregister.
  out       dx,al
  inc       dx
  in        al,dx                   ; al=graphmode.
  and       al,0fch
  or        al,1                    ; Set mode write 1.
  out       dx,al
 
  mov       ax,0a000h               ; Set ds:si to source screen.
  mov       ds,ax
  mov       si,480*80
  mov       es,ax                   ; Set es:di to work screen.
  mov       di,work_scr_ofs

  mov       bx,work_spr_ofs         ; The table containing sprite offsets.
  mov       cx,nb_balls
@@clear_one_spr:
  mov       ax,cs:[bx]              ; Load sprite offset.
  add       bx,2
  call      clear_spr31
  loop      @@clear_one_spr


;**** Add gravity to the velocities of balls.
  mov       di,offset cs:balls      ; cs:si points on balls parameters.
  mov       cx,nb_balls
@@add_gravity_one:
  add       word ptr cs:[di+6],gravity ; vy+=gravity. 
  add       di,8
  loop      @@add_gravity_one

;**** HERE COMES THE (almost) INTERESTING PART!!!!
; When a ball collides something (a wall, or another ball), we lock it
; for the current vbl, so it won' t move, and we change its velocity
; according to the collision. This method is a cheat, but it' s much
; easier. (I fon' t think it' s the best trick, though)
  
; First, lock the balls which are colliding the walls. 
; The other balls are put into another list. (norm_balls) 
  mov       si,offset cs:balls      ; cs:si points on balls parameters.
  mov       di,offset cs:lock_balls ; cs:di points on locked balls list.
  mov       bp,offset cs:norm_balls ; cs:bp points on normal balls list.
  mov       word ptr norm_nb,0      ; Reinit counters.
  mov       word ptr lock_nb,0
  mov       cx,nb_balls
@@wall_collision_one:
  mov       ax,cs:[si]
  add       ax,cs:[si+4]            ; ax=posx+vx.
  cmp       ax,15*64
  jLE       @@wall_collision_x
  cmp       ax,(319-14)*64
  jGE       @@wall_collision_x
  mov       ax,cs:[si+2]
  add       ax,cs:[si+6]            ; bx=posy+vy.
  cmp       ax,15*64
  jLE       @@wall_collision_y
  cmp       ax,(239-14)*64
  jGE       @@wall_collision_y
  mov       eax,cs:[si]             ; Put ball in normal balls list.
  mov       cs:[bp],eax
  mov       eax,cs:[si+4]
  mov       cs:[bp+4],eax
  inc       word ptr norm_nb        ; Add 1 to the nb of normal balls.
  add       bp,8
  add       si,8
  loop      @@wall_collision_one
  jmp       @@wall_collision_end

@@wall_collision_x:
  mov       eax,cs:[si]             ; Put ball in locked balls list.
  mov       cs:[di],eax
  mov       eax,cs:[si+4]
  mov       cs:[di+4],eax
  neg       word ptr cs:[di+4]      ; vx=-vx. 
  inc       word ptr lock_nb        ; Add 1 to the nb of locked balls.
  add       di,8
  add       si,8
  loop      @@wall_collision_one
  jmp       @@wall_collision_end

@@wall_collision_y:
  mov       eax,cs:[si]             ; Put ball in locked balls list.
  mov       cs:[di],eax
  mov       eax,cs:[si+4]
  mov       cs:[di+4],eax
  neg       word ptr cs:[di+6]      ; vy=-vy. 
  inc       word ptr lock_nb        ; Add 1 to the nb of locked balls.
  add       di,8
  add       si,8
  dec       cx
  jNZ       @@wall_collision_one

@@wall_collision_end:

; Ok, now go on with balls colliding together. You must notice that if a 
; ball collides a locked ball, I continue to process collisions with
; all other locked balls. (This is natural when you give a thought to it.)
; After I have tested an eventual collision with a locked ball, I go
; on by testing collisions with other balls. Oh, by the way, when I say
; I remove a ball from the 'normal' list, this mean in fact I copy the
; last ball of normal list at the position occupied by the ball to remove.

@@balls_collisions:
  cmp       norm_nb,0               ; No more normal balls?
  jE        @@collision_end        
  xor       dx,dx                   ; dx=position in normal balls list.

@@balls_collisions_one:
; First, test if ball nb dx will encounter a locked ball!
  mov       si,offset cs:norm_balls       
  mov       cx,dx
  shl       cx,3
  add       si,cx                   ; cs:si points on ball.
  mov       cx,lock_nb              ; cx=nb of locked balls.
  mov       di,offset cs:lock_balls ; cs:di points on locked balls list.
  xor       bx,bx                   ; bx will contain 1 if there is a collision.
@@lock_collision_one:
  dec       cx                      ; One locked ball seen.
  jL        @@lock_collision_end
  mov       ax,1                    ; Second ball (cs:di) is locked.
  call      ball_collision          ; Collision between the two balls?      
  or        bx,ax                   ; bx=1 if there was a collision.
  add       di,8                    ; Next locked ball.
  jmp       @@lock_collision_one

@@lock_collision_end:
  cmp       bx,1                    ; Ball collided with a locked ball?
  jNE       @@norm_collisions       ; No...
; Yes, so put current ball into the locked balls list, and begin anew. 
; Here we have cs:di which points just after last locked ball.
;  mov       di,offset cs:lock_balls
;  mov       ax,lock_nb 
;  shl       ax,3
;  add       di,ax
  inc       lock_nb                 ; Copy ball into locked balls list.
  mov       eax,cs:[si]             
  mov       cs:[di],eax
  mov       eax,cs:[si+4]
  mov       cs:[di+4],eax
  dec       norm_nb                 ; Remove ball from normal balls list.       
  mov       di,offset cs:norm_balls
  mov       ax,norm_nb
  shl       ax,3
  add       di,ax                   ; cs:di points on last normal ball.
  mov       eax,cs:[di]             
  mov       cs:[si],eax
  mov       eax,cs:[di+4]
  mov       cs:[si+4],eax
  jmp       @@balls_collisions

; The ball has not collided with a locked ball. Now, we must see if 
; she collides with another normal ball.
@@norm_collisions:
  cmp       norm_nb,1               ; No more than one normal ball?
  jE        @@collision_end
  xor       cx,cx                   ; cx=current normal ball.
  mov       di,offset cs:norm_balls ; cs:di points on normal balls list.
  xor       bx,bx                   ; bx will contain 1 if there is a collision.
@@norm_collision_one:
  cmp       cx,norm_nb              ; We have tested all normal balls?
  jGE       @@norm_collision_end
  cmp       dx,cx                   ; Don' t test collision with twice the
  jE        @@next_norm_collision   ; same normal ball!
  xor       ax,ax
  call      ball_collision          ; Collision between the two balls?      
  cmp       ax,1
  jNE       @@next_norm_collision   ; No, then continue with next ball.
; Yes, the two balls were colliding, so put them in locked balls list,  
; and remove them from the normal balls list.
  mov       bp,offset cs:lock_balls
  mov       ax,lock_nb 
  shl       ax,3
  add       bp,ax
  add       lock_nb,2               ; Copy balls into locked balls list.
  mov       eax,cs:[si]             
  mov       cs:[bp],eax
  mov       eax,cs:[si+4]
  mov       cs:[bp+4],eax
  mov       eax,cs:[di]             
  mov       cs:[bp+8],eax
  mov       eax,cs:[di+4]
  mov       cs:[bp+12],eax
  sub       norm_nb,2               ; Remove balls from normal balls list.       
  mov       bp,offset cs:norm_balls
  mov       ax,norm_nb
  shl       ax,3
  add       bp,ax                   ; cs:bp points on last normal ball.
; Beware!!! Here, we must replace anew TWO balls, and if one of the
; colliding ball is in the two upper balls, it will be replaced by the good
; ball, which will be out! So, make sure those two balls aren' t already
; out of the list. (i.e: at the end of the list.)
  cmp       si,bp                   
  jE        @@norm_collision_si_out1  
  jG        @@norm_collision_si_out2  
  cmp       di,bp  
  jE        @@norm_collision_di_out1
  jG        @@norm_collision_di_out2
  mov       eax,cs:[bp]             
  mov       cs:[si],eax
  mov       eax,cs:[bp+4]
  mov       cs:[si+4],eax
  mov       eax,cs:[bp+8]             
  mov       cs:[di],eax
  mov       eax,cs:[bp+12]
  mov       cs:[di+4],eax
  jmp       @@balls_collisions

; The ball pointed by cs:si is out of the list. 
@@norm_collision_si_out1:
  add       bp,8                    ; The ball just after di.
@@norm_collision_si_out2:
  mov       eax,cs:[bp]             
  mov       cs:[di],eax
  mov       eax,cs:[bp+4]
  mov       cs:[di+4],eax
  jmp       @@balls_collisions
  
; The ball pointed by cs:di is out of the list. 
@@norm_collision_di_out1:
  add       bp,8                    ; The ball just after si.
@@norm_collision_di_out2:
  mov       eax,cs:[bp]             
  mov       cs:[si],eax
  mov       eax,cs:[bp+4]
  mov       cs:[si+4],eax
  jmp       @@balls_collisions


@@next_norm_collision:
  add       di,8                    ; Next normal ball.
  inc       cx
  jmp       @@norm_collision_one

@@norm_collision_end:
  inc       dx                      ; Next normal ball.
  cmp       dx,norm_nb
  jNE       @@balls_collisions_one

@@collision_end:


;**** Merge the normal and locked balls into the same list.
  mov       si,offset cs:balls      ; cs:si points on balls parameters.
  mov       di,offset cs:lock_balls ; cs:di points on locked balls list.
  mov       cx,lock_nb
@@merge_lock:
  dec       cx
  jL        @@merge_lock_end
  mov       eax,cs:[di]             ; Copy locked balls.
  mov       cs:[si],eax
  mov       eax,cs:[di+4]             
  mov       cs:[si+4],eax
  add       si,8
  add       di,8
  jmp       @@merge_lock      
@@merge_lock_end:
  mov       di,offset cs:norm_balls ; cs:di points on normal balls list.
  mov       cx,norm_nb
@@merge_norm:
  dec       cx
  jL        @@merge_norm_end
  mov       ax,cs:[di] 
  add       ax,cs:[di+4]
  mov       cs:[si],ax
  mov       ax,cs:[di+2] 
  add       ax,cs:[di+6]
  mov       cs:[si+2],ax
  mov       eax,cs:[di+4]             
  mov       cs:[si+4],eax
  add       si,8
  add       di,8
  jmp       @@merge_norm      
@@merge_norm_end:

;**** Draw the sprites on work screen, and save their offsets.
  mov       dx,03ceh                ; Graphic Controller.
  mov       al,05h                  ; GraphMode subregister.
  out       dx,al
  inc       dx
  in        al,dx                   ; al=graphmode.
  and       al,0fch                 ; Set mode write 0.
  out       dx,al
  
  mov       ax,0a000h               ; ds points on videoram.
  mov       ds,ax
  mov       si,offset cs:balls      ; cs:si points on balls positions.
  mov       di,work_spr_ofs         ; cs:di points where to save spr offsets.
  mov       ch,nb_balls  
  mov       al,02h                  ; Map mask subregister.
@@draw_one_spr:
  mov       dx,cs:[si]              ; dx=posx. 
  shr       dx,6                    ; dx=int(posx).
  sub       dx,15                   ; Left edge of ball. 
  mov       cl,dl
  and       cl,11b                  ; cl=int(posx) mod(3)=first plane to access.
  mov       ah,1
  shl       ah,cl                   ; ah=map mask.
  mov       bx,cs:[si+2]            ; bx=posy.  
  shr       bx,6                    ; bx=int(posx).
  sub       bx,15                   ; Top edge of ball.
  mov       dx,bx
  shl       bx,2
  add       bx,dx
  shl       bx,4                    ; bx=int(posy-15)*80.
  mov       dx,cs:[si]              ; dx=posx.
  shr       dx,6                    ; dx=int(posx).
  sub       dx,15                   ; Left edge of ball. 
  shr       dx,2                    ; dx=posx/4.
  add       bx,dx                   ; bx=offset of sprite.
  mov       cs:[di],bx              ; Save the sprite offset.
  add       bx,work_scr_ofs         ; Add screen offset.
  mov       dx,03c4h                ; Sequencer index.
  call      dword ptr cs:[code_adress] ; Draw the sprite.
  add       di,2                    ; For next sprite.  
  add       si,8
  dec       ch
  jNZ       @@draw_one_spr

;**** Workscreen is drawn, tell to CRT to display it.
  mov       bx,work_scr_ofs
  mov       dx,03d4h                ; CRT Controller.
  mov       al,0ch                  ; Start adress high subregister.
  mov       ah,bh
  out       dx,ax
  mov       al,0dh                  ; Start adress high subregister.
  mov       ah,bl
  out       dx,ax

;**** Wait for a key to terminate demo.
  mov       ah,01h                  ; Keyboard scan.
  int       16h
  jz        one_frame
  flush_keyboard                    ; It has to be done...
;----------------------------------------------------------------------------

;**** Humm, seems it has come to an end. 
end_proggy:
  call      init_mode0              ; Back to text mode.
  mov       ax,0b800h               ; Draw 'baah.' logo.
  mov       es,ax
  call      baah_text_logo
  mov       ah,4ch                  ; Terminate proggy function.
  int       21h                    

beginning               ENDP

;---- Main program datas. ---------------------------------------------------

; Offsets of work screen, show screen, work sprite bank, show sprite bank.
work_scr_ofs            dw 0
show_scr_ofs            dw 240*80
work_spr_ofs            dw offset cs:balls_ofs1
show_spr_ofs            dw offset cs:balls_ofs2

; The positions and velocities of the center of the balls. (*64) 
balls       dw 120*64,20*64,0,0
            dw 160*64,20*64,0,0   
            dw 200*64,20*64,0,0
            dw 140*64,45*64,0,0
            dw 180*64,45*64,0,0
            dw 160*64,70*64,0,0 
            dw 30*64,90*64,2*64,0

; Those buffers and their related counters will contain the locked balls, 
; the normal ones, etc...
norm_balls  dw nb_balls*4 dup(0)
lock_balls  dw nb_balls*4 dup(0)
norm_nb     dw 0
lock_nb     dw 0
current_nb  dw 0

; Two banks for the positions of the balls.
balls_ofs1  dw nb_balls*2 dup (0)
balls_ofs2  dw nb_balls*2 dup (0)

; Will contain the adress of the generated sprite rout.
code_adress dw 0,0

; The sprite datas, and the palette.
sprite      label byte                  
  incbin 'ball.xxx',994
palette     label byte 
  incbin 'ball.pal',312

; The segment adress of the buffer containing the fractal.
fractal_seg dw 0

; Yeah!
text1:
text1:
  db        0,'!!!!!!!!    KICK ME    !!!!!!!!',0
  db        2,'This 4 Kb intro features:',0
  db        4,'Gravity & collisions.',0
  db        5,'A sprite code generator.',0
  db        6,'A nice ball by Niko/MJJ Prod.',0
  db        7,'Full frame rate animation on my 16Mhz 386sx.',0
  db        8,'Julia fractal, with max_iter=93 and 32 bits muls.',0
  db        10,'Coded by Alain BROBECKER. (aka baah)',0
  db        11,'Released at the GASP party, thanks to BigFoot/MJJ Prod.',0
  db        12,'(Montpellier, 11-15 august 1995)',0  
  db        14,'The sources are freely released. (normally in same archive)',0
  db        15,'Send me a nice postcard in case you liked this.',0
  db        17,3,3,3,3,3,3,'    KooKoo    ',3,3,3,3,3,3,0 
  db        19,'MafiAmiga - Positivity - Arm''s Tech - Les Heretiques - Bass',0
  db        20,'Mentasm - DNT Crew - MJJ & Patapom - HMD - Steelers',0 
  db        21,'Elf - Onyx - Biro - DaubeMan - Barti - LCA',0 
  db        23,'Please wait, calculating the Julia set.',0 
  db        24,'(approx 20 secs on my 16 Mhz 386sx)',0
  db        0
text2:
  db        23,'------------- Press a key -------------',0
  db        24,'                                   ',0
  db        0
;============================================================================



;==== Collision between 2 balls =============================================
; Parameters are..
;    cs:si=points on first ball.
;    cs:di=points on second ball. 
;    If ax=1, the second ball is considered as being locked.
; It returns..
;    ax=1 if there is a collision.
;    ax=0 else.
ball_collision          PROC NEAR
  push ebx
  push ecx
  push edx
  mov       bx,cs:[di+2]
  cmp       ax,1
  jE        @@ball_collision_lock1
  add       bx,cs:[di+6]
@@ball_collision_lock1:  
  sub       bx,cs:[si+2]            
  sub       bx,cs:[si+6]            ; bx=deltay.            
  cmp       bx,30*64
  jGE       @@no_ball_collision
  cmp       bx,-30*64
  jLE       @@no_ball_collision
  mov       ax,cs:[di]
  cmp       ax,1
  jE        @@ball_collision_lock2
  add       ax,cs:[di+4]
@@ball_collision_lock2:  
  sub       ax,cs:[si]              
  sub       ax,cs:[si+4]            ; ax=deltax.
  cmp       ax,30*64
  jGE       @@no_ball_collision
  cmp       ax,-30*64
  jLE       @@no_ball_collision
; Ok, calculate the distance between centers of ball1 and ball2.
  imul      ax                      ; dx:ax=deltax^2
  mov       cx,dx
  shl       ecx,16
  mov       cx,ax                   ; ecx=deltax^2.
  mov       ax,bx
  imul      ax                      ; dx:ax=deltay^2.
  shl       edx,16
  mov       dx,ax                   ; edx=deltay^2.
  add       edx,ecx
  cmp       edx,30*64*30*64         ; Dist>=(2*radius)^2.
  jGE       @@no_ball_collision
; There is a collision! So, change the two velocities according to it.
  
; First, we want o1o2/norm(o1o2).
  mov       ax,cs:[di]              ; Back to original coords if collision. 
  sub       ax,cs:[si]
  mov       @@deltax,ax
  mov       bx,cs:[di+2]
  sub       bx,cs:[si+2]
  mov       @@deltay,bx
; Now, we divide by norm of o1o2. 
  imul      ax                      ; dx:ax=deltax^2
  mov       cx,dx
  shl       ecx,16
  mov       cx,ax                   ; ecx=deltax^2.
  mov       ax,bx
  imul      ax                      ; dx:ax=deltay^2.
  shl       edx,16
  mov       dx,ax                   ; edx=deltay^2.
  add       edx,ecx                 ; edx=deltax^2+deltay^2.
; Extraction of the squareroot of edx.  
  mov       ebx,040000000h
  xor       ecx,ecx
  cmp       ebx,edx                 ; bitsqrt=<val?
  jLE       @@sqrt_goto1
  shr       ecx,1                   ; root >>1. 
  jmp       @@sqrt_goto2
@@sqrt_goto1:
  sub       edx,ebx                 ; val-=bitsqrt+root.
  shr       ecx,1                   ; root>>1. 
  add       ecx,ebx                 ; root+=bitsqrt             
@@sqrt_goto2:
 REPT 15
  shr       ebx,2
  mov       eax,ebx
  add       eax,ecx                 ; eax=bitsqrt+root.     
  cmp       eax,edx                 ; bitsqrt+root=<val?
  dw 0057eh                         ; 'jLE +05'.        
  shr       ecx,1                   ; root >>1. 
  dw 009ebh                         ; 'jmp +09'.
  sub       edx,eax                 ; val-=bitsqrt+root.
  shr       ecx,1                   ; root>>1. 
  add       ecx,ebx                 ; root+=bitsqrt             
 ENDM
  cmp       cx,dx                   ; Round to nearest integer. 
  jGE       @@sqrt_goto3
  inc       cx
@@sqrt_goto3:
; Here we have cx=sqrt(deltax^2+deltay^2).

; Calculate dx/norm(o1o2) and dy/norm(o1o2).
  xor       edx,edx
  mov       dx,@@deltax
  shl       edx,16
  sar       edx,6
  mov       ax,dx
  sar       edx,16                  ; dx:ax=deltax*2^(6+10)
  idiv      cx  
  shl       eax,16
  sar       eax,16                  ; ax=2^14*deltax/norm(o1o2).
  mov       @@new_deltax,eax
  mov       @@deltax,ax  
  xor       edx,edx
  mov       dx,@@deltay
  shl       edx,16
  sar       edx,6
  mov       ax,dx
  sar       edx,16                  ; dx:ax=deltay*2^(6+10)
  idiv      cx  
  mov       bx,ax
  shl       ebx,16
  sar       ebx,16                  ; bx=2^14*deltay/norm(o1o2)

; Now, calculate the following scalar products..
;    scalar1=vx1*deltax/norm(o1o2)+vy1*deltay/norm(o1o2).
;    scalar2=vx2*deltax/norm(o1o2)+vy2*deltay/norm(o1o2).
; Scalar1 is then the norm of the compound of v1 along o1o2 (v1/o1o2)
; and scalar2 is the norm of the compound of v2 along o1o2. (v2/o1o2)
  mov       ax,cs:[si+4]            ; ax=vx1.
  imul      word ptr @@deltax       ; dx:ax=deltax*vx1.
  mov       cx,dx
  shl       ecx,16
  mov       cx,ax                   ; ecx=deltax*vx1.
  mov       ax,cs:[si+6]            ; ax=vy1.
  imul      bx                      ; dx:ax=deltay*vy1.
  shl       edx,16
  mov       dx,ax                   ; edx=deltay*vy1.
  add       edx,ecx                 ; edx=deltax*vx1+deltay*vy1.
  sar       edx,6                   ; Beware the premul by 64.
  mov       @@scalar1,edx           ; Store the scalar product.
  mov       ax,cs:[di+4]            ; ax=vx2.
  imul      word ptr @@deltax       ; dx:ax=deltax*vx2.
  mov       cx,dx
  shl       ecx,16
  mov       cx,ax                   ; ecx=deltax*vx2.
  mov       ax,cs:[di+6]            ; ax=vy2.
  imul      bx                      ; dx:ax=deltay*vy2.
  shl       edx,16
  mov       dx,ax                   ; edx=deltay*vy2.
  add       edx,ecx                 ; edx=deltax*vx2+deltay*vy2.
  sar       edx,6                   ; Beware the premul by 64.
  mov       @@scalar2,edx           ; Store the scalar product.

; Now, calculate the x and y compounds of v1/o1o2 and v2/o1o2.
  mov       eax,@@new_deltax
  imul      dword ptr @@scalar1     ; edx:eax=scalar1*deltax/norm(o1o2).
  shrd      eax,edx,14              ; here we have ax=x compound of v1/o1o2.      
  sub       cs:[si+4],ax      
  add       cs:[di+4],ax
  mov       eax,@@new_deltax
  imul      dword ptr @@scalar2     ; edx:eax=scalar2*deltax/norm(o1o2).
  shrd      eax,edx,14              ; here we have ax=x compound of v2/o1o2.      
  add       cs:[si+4],ax      
  sub       cs:[di+4],ax
  mov       eax,@@scalar1
  imul      ebx                     ; edx:eax=scalar1*deltay/norm(o1o2).
  shrd      eax,edx,14              ; here we have ax=y compound of v1/o1o2.      
  sub       cs:[si+6],ax      
  add       cs:[di+6],ax
  mov       eax,@@scalar2
  imul      ebx                     ; edx:eax=scalar2*deltay/norm(o1o2).
  shrd      eax,edx,14              ; here we have ax=y compound of v2/o1o2.      
  add       cs:[si+6],ax      
  sub       cs:[di+6],ax
  mov       ax,1  
  pop edx
  pop ecx
  pop ebx
  ret

@@no_ball_collision:
  xor       ax,ax                    ; No collision.
  pop edx
  pop ecx
  pop ebx
  ret

@@deltax    dw 0
@@deltay    dw 0
@@scalar1   dd 0
@@scalar2   dd 0
@@new_deltax dd 0

ball_collision          ENDP
;============================================================================


;==== Clear a 31*31 Sprite ==================================================
; Parameters are..
;           ds:si=source screen.           
;           es:di=work screen.
;           ax=offset for this sprite.
; Please note that the sequencer must be set to write 1 mode, will all
; the planes set.
clear_spr31             PROC NEAR
  pusha
  add       si,ax
  add       di,ax
 REPT       30
  mov       cx,9
  rep movsb
  add       di,80-9
  add       si,80-9
 ENDM
  mov       cx,9
  rep movsb
  popa
  ret
clear_spr31             ENDP
;============================================================================


;==== Julia Set Calculation =================================================
; Parameters:  
;   ds=segment of fractal buffer.
  coef=28               ; Premultiplication coefficient.
  max_Iter=93           ; Maximum nb of iterations.
  cste_re=06666666h     ; Constant for julia set.
  cste_im=03333333h
  julia_re=0f6000000h   ; Position of the top left point in the complex plane. 
  julia_im=0f0000000h
  inc_re=000c0000h      ; Increment between points on screen. 
  inc_im=000c0000h

julia_set               PROC NEAR
  pusha
  xor       bp,bp                   ; bp is the offset in screen buffer.
@@one_pixie:
  mov       ebx,current_re
  mov       ecx,current_im
  xor       di,di                   ; di is the iteration counter.
 
 REPT       max_iter                ; Here is the code for one iteration.
; ebx=x*2^coef.
; ecx=y*2^coef.  
; edi=0=nb of iterations.
  mov       eax,ecx
  imul      ebx                     ; edx:eax=x*y*2^(2*coef).
  shld      edx,eax,32-coef+1       ; edx=2*x*y*2^coef.
  mov       eax,ebx
  sub       eax,ecx                 ; eax=(x-y)*2^coef.
  add       ebx,ecx                 ; ebx=(x+y)*2^coef.
  mov       ecx,edx
  add       ecx,cste_im             ; ecx=y'=2*x*y+cste_im.
  imul      ebx                     ; edx:eax=(x*x-y*y)*2^(2*coef).
  shld      edx,eax,32-coef         ; edx=(x*x-y*y)*2^coef.
  cmp       edx,20000000h
  jNS       @@divergent
  mov       ebx,edx
  add       ebx,cste_re             ; ebx=x'=x*x-y*y+cste_re.
  inc       di                      ; One iteration achieved.
 ENDM

; Here print the pixie.
@@divergent:
  mov       ax,di                   ; al=color=nb of iterations achieved.
  mov       ds:[bp],al              ; Print pixie.

; One pixel achieved. Next pixel is on the same column. 
  add       bp,80                   ; Next y. 
  add       current_im,inc_im       ; Next im corresponding to this y. 
  cmp       bp,240*80               ; 240 pixels where drawn in this column?
  jNGE      @@one_pixie

; One column was drawn, so we have to draw the next column, and this results
; in a screen buffer segment modification since the screen buffer is
; organised similarly to the video mode2.
  add       current_re,inc_re
  sub       bp,240*80               ; Offset points on beginning of column.
  mov       current_im,julia_im     ; Reinit imaginary value.
  mov       bx,ds                   ; Use bx for segment modifications.
  mov       ax,x_mod4               ; Each 4 columns, reinit buffer segment.
  dec       ax                      ; We have printed 4 columns?
  jNZ       @@next_bufferbank       ; Else go to next bank. 
; Here we go back to bufferbank 0.
  mov       ax,4  
  inc       bp                      ; Next column on bufferbank 0.
  sub       bx,80*240*4/16          ; bx will point on bank 0 after the add. 
@@next_bufferbank:
  mov       x_mod4,ax               ; Save the counter.  
  add       bx,80*240/16            ; Next bank.
  mov       ds,bx
  cmp       bp,80                   ; We have printed 80 columns in each bank?
  jNE       @@one_pixie
  
  popa
  ret
julia_set               ENDP

;---- Julia set calculation datas. ------------------------------------------
align
current_re  dd julia_re
current_im  dd julia_im
x_mod4      dw 4
;============================================================================



;==== Copy Buffer to Vram ===================================================
; ds:si=buffer adress.
; es:di=videoram adress.
copy2vram               PROC FAR
  pusha 
  push ds
  mov       dx,03c4h                ; SEQUENCE CONTROLLER port.
  mov       ax,0102h                ; Map mask subregister, plane 0. 
  mov       bx,4                    ; 4 planes to copy.
@@copy_one_plane:
  out       dx,ax                   ; Access the good plane. 
  mov       cx,4800                 ; Copy 4800 longwords.  
  rep       movsd  
  mov       cx,ds                   ; Make ds:si point on next plane.
  add       cx,80*240/16
  mov       ds,cx
  sub       si,80*240
  sub       di,80*240               ; Make es:di point on beginning.
  shl       ah,1                    ; Next plane.
  dec       bx
  jNZ       @@copy_one_plane
  pop ds
  popa
  ret
copy2vram               ENDP
;============================================================================


THE_CODE                ENDS


; ***************************************************************************
; *******************************  STACK  ***********************************
; ***************************************************************************
THE_STACK               SEGMENT STACK
  dw  512 dup (0)
THE_STACK               ENDS

            END beginning
; ***************************************************************************
