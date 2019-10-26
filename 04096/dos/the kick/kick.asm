; **************************************************************************
; *                                                                        *
; *   The Kick, a 4k-intro by Torkjel Hongve aka Zarr / Anakata            *
; *                                                                        *
; *   You can do whatever you like with this piece of code,                *
; *   as long as I am given credit for the parts / ideas you use.          *
; *   I am not responsible for any harm the use of this file will          *
; *   bring to you or your computer, harware or software.                  *
; *                                                                        *
; *   This thing took me three days to code. It is not much optimized for  *
; *   speed or size, but the code is relatively easy to understand.        *
; *   (If there is anything called easy-to-understand asm-code :) )        *
; *   I didn't bother to comment it much...                                *
; *                                                                        *
; *                                         Zarr / Anakata  4.5.1999       *
; *                                         hongve@stud.ntnu.no            *
; *                                         zarr@anakata.art.pl            *
; **************************************************************************

       dosseg
       model tiny
       .486p
            
assume  cs:cseg,ds:cseg
cseg segment para USE16
     org 100h                
                             
start: 
   jmp  real_start     
   msg db 'The Kick 4k by Zarr / Anakata 1999$'
real_start:

   mov  ax,cs
   mov  ds,ax

;#############################################
;#########  SET VGA 320*200  #################
;#############################################

   mov  ax,13h  
   int  10h     

;#############################################
;#########  MEMALLOC  ########################
;#############################################

   mov  bx,4096
   mov  ax,cs   
   add  ax,bx
   mov  virseg,ax
   add  ax,bx
   mov  virseg2,ax
   add  ax,bx
   mov  backseg,ax
   add  ax,bx
   mov  backseg2,ax
   add  ax,bx
   mov  transmap,ax
   add  ax,bx
   mov  txtseg,ax
   add  ax,bx
   mov  vritab,ax

   mov  ax,virseg
   mov  cls_dst,ax
   call cls    
   mov  ax,virseg2
   mov  cls_dst,ax
   call cls    
;   mov  ax,backseg
;   mov  cls_dst,ax
;   call cls    
;   mov  ax,backseg2
;   mov  cls_dst,ax
;   call cls    
   mov  ax,transmap
   mov  cls_dst,ax
   call cls    
   mov  ax,txtseg
   mov  cls_dst,ax
   call cls    
;   mov  ax,vritab
;   mov  cls_dst,ax
;   call cls    
     
;#############################################
;#########  SET SINTAB  ######################
;#############################################

   mov  sint_frec,256
   mov  sint_amp,127
   mov  sint_length,4096
   lea  ax,stab
   mov  sint_offs,ax
   call settab

;#############################################
;#########  MAKE VRITAB  #####################
;#############################################

   mov  ax,vritab
   mov  mvt_dst,ax
   mov  mvt_div,2
   call make_vritab

;#############################################
;#########  STARTMSG #########################
;#############################################

   call reset_time

   mov  dh,0
   mov  dl,3
   lea  cx,msg
   call print

 del1:
   call timer
   cmp  time,18
   jbe  del1
  
   mov  dh,5
   mov  dl,10
   lea  cx,msg1
   call print

 del2:
   call timer
   cmp  time,18*2
   jbe  del2

   mov  dh,10
   mov  dl,17
   lea  cx,msg2
   call print

 del3:
   call timer
   cmp  time,18*3
   jbe  del3

   mov  dh,15
   mov  dl,24
   lea  cx,msg3
   call print

 del4:
   call timer
   cmp  time,18*3
   jbe  del4

;#############################################
;#########  MAKE BACKGROUND ##################
;#############################################

   mov  ax,backseg2
   mov  backg_dst,ax     
   mov  ax,backseg
   mov  backg_pdst,ax     
   mov  backg_iters,65536*10
   mov  backg_offs,0
   call make_background
                
   mov  backg_iters,65536*15
   mov  backg_offs,16*1024
   call make_background
       
   mov  backg_iters,65536*20
   mov  backg_offs,32*1024
   call make_background

   mov  backg_iters,65536*25
   mov  backg_offs,48*1024
   call make_background

;#############################################
;#########  SET PALETTE ######################
;#############################################

   xor  cx,cx
   mov  spal_r,cl
   mov  spal_b,cl
   mov  spal_g,cl
spal_loop3:
   mov  ax,cx 
   mov  spal_c,al
   shr  al,2
   mov  spal_b,al  
   mov  ax,cx 
   mul  ax 
   shr  ax,8
   mul  ax  
   shr  ax,10
   mov  spal_r,al
   mov  spal_g,al
   call setpal  
   inc  cl   
   jnz  spal_loop3

;#############################################
;#########  SET TEXT  ########################
;#############################################

   mov  ax,txtseg
   mov  st_dst,ax
   lea  ax,text
   mov  st_text,ax
   call settxt
   
;#############################################
;#########  EFFECT 1: INTRO  #################
;#############################################
   
   call reset_time
   call timer
   
mloop4:

   mov  ax,virseg
   mov  blend2_dst,ax
   mov  ax,backseg
   mov  blend2_src,ax
   mov  blend2_offs1,48*1024
   mov  blend2_offs2,0
   mov  ax,word ptr time
   shl  ax,4
   mov  blend2_factor,al
   call blend2

   jmp  mskip

mloop1:

   mov  ax,virseg
   mov  blend2_dst,ax
   mov  ax,backseg
   mov  blend2_src,ax
   mov  blend2_offs1,0
   mov  blend2_offs2,16*1024
   mov  ax,word ptr time
   shl  ax,4
   mov  blend2_factor,al
   call blend2

   jmp  mskip

mloop2:

   mov  ax,virseg
   mov  blend2_dst,ax
   mov  ax,backseg
   mov  blend2_src,ax
   mov  blend2_offs1,16*1024
   mov  blend2_offs2,32*1024
   mov  ax,word ptr time
   shl  ax,4
   mov  blend2_factor,al
   call blend2

   jmp  mskip

mloop3:

   mov  ax,virseg
   mov  blend2_dst,ax
   mov  ax,backseg
   mov  blend2_src,ax
   mov  blend2_offs1,32*1024
   mov  blend2_offs2,48*1024
   mov  ax,word ptr time
   shl  ax,4
   mov  blend2_factor,al
   call blend2

   jmp  mskip

mskip:

   mov  ax,vritab
   mov  rz_src,ax
   mov  ax,transmap
   mov  rz_dst,ax
   mov  bx,word ptr time
   xor  bh,bh
   add  bx,bx
   mov  ax,[stab+bx]
   mov  cx,ax
   add  ax,cx
   sal  ax,1
   add  ax,128
   mov  rz_x3,ax
   mov  rz_y4,ax
   mov  ax,[stab+bx+64*2]
   add  ax,cx
   sal  ax,1
   add  ax,128
   mov  rz_x4,ax
   mov  rz_y1,ax
   mov  ax,[stab+bx+128*2]
   add  ax,cx
   sal  ax,1
   add  ax,128
   mov  rz_x1,ax
   mov  rz_y2,ax
   mov  ax,[stab+bx+192*2]
   add  ax,cx
   sal  ax,1
   add  ax,128
   mov  rz_x2,ax
   mov  rz_y3,ax
;   mov  ax,[stab+bx+192*2]
;   mov  cx,ax
;   add  ax,cx
;   sal  ax,1
;   add  ax,128
;   mov  rz_y3,ax
;   mov  ax,[stab+bx+0*2]
;   add  ax,cx
;   sal  ax,1
;   add  ax,128
;   mov  rz_y4,ax
;   mov  ax,[stab+bx+64*2]
;   add  ax,cx
;   sal  ax,1
;   add  ax,128
;   mov  rz_y1,ax
;   mov  ax,[stab+bx+128*2]
;   add  ax,cx
;   sal  ax,1
;   add  ax,128
;   mov  rz_y2,ax
   call rotozoom

   mov  ax,txtseg
   mov  bx,virseg2
   mov  cx,transmap
   mov  vri_src,ax
   mov  vri_dst,bx
   mov  vri_table,cx
   mov  vri_offs,0
   call vri

   mov  bx,virseg2
   mov  ax,virseg
   mov  msnotn_src,bx
   mov  msnotn_dst,ax
   mov  msnotn_n,64
   call msnotn

   mov  fade_in,4
   mov  fade_out,256-4
   mov  fade_speed_out,6
   mov  fade_flash,0
   mov  ax,virseg
   mov  fade_seg,ax
   call fade_in_out   

   mov  ax,virseg
   mov  flip_src,ax
   mov  ax,0a000h
   mov  flip_dst,ax
   call flip

   mov  ax,600h
   mov  dl,0ffh
   int  21h
   cmp  al,27
   je   the_end

   cmp word ptr time,256
   jae next

   call timer

   mov  ax,word ptr time
   mov  bx,64
   div  bl
  
   cmp  ah,16
   jb   mloop4
   cmp  ah,32
   jb   mloop3
   cmp  ah,48
   jb   mloop2
   jmp  mloop1

;#############################################
;#########  EFFECT 2: TRANSPARENCY  ##########
;#############################################

next:
   
   mov  ax,txtseg
   mov  cls_dst,ax
   call cls    

   mov  ax,txtseg
   mov  st_dst,ax
   lea  ax,text2
   mov  st_text,ax
   call settxt

   mov  ax,txtseg
   mov  rz_src,ax
   mov  ax,virseg2
   mov  rz_dst,ax
   mov  ax,[stab+158]
   add  ax,128
   mov  rz_x3,ax
   mov  ax,[stab+158+64*2]
   add  ax,128
   mov  rz_x4,ax
   mov  ax,[stab+158+128*2]
   add  ax,128
   mov  rz_x1,ax
   mov  ax,[stab+158+192*2]
   add  ax,128
   mov  rz_x2,ax
   mov  ax,[stab+158+192*2]
   add  ax,96 
   mov  rz_y3,ax
   mov  ax,[stab+158+0*2]
   add  ax,96 
   mov  rz_y4,ax
   mov  ax,[stab+158+64*2]
   add  ax,96 
   mov  rz_y1,ax
   mov  ax,[stab+158+128*2]
   add  ax,96 
   mov  rz_y2,ax
   call rotozoom

rottrs_loop:

   mov  ax,backseg2
   mov  rz_src,ax
   mov  ax,transmap
   mov  rz_dst,ax
   mov  cx,word ptr time
   shl  cx,2
   mov  bx,word ptr time
   sal  bx,4
   and  bh,00000001b
   mov  ax,[stab+bx]
   add  ax,cx
   sar  ax,2
   mov  rz_x4,ax
   mov  rz_y3,ax
   mov  ax,[stab+bx+64*2]
   add  ax,cx
   sar  ax,2
   mov  rz_x3,ax
   mov  rz_y2,ax
   mov  ax,[stab+bx+128*2]
   add  ax,cx
   sar  ax,2
   mov  rz_x2,ax
   mov  rz_y1,ax
   mov  ax,[stab+bx+192*2]
   add  ax,cx
   sar  ax,2
   mov  rz_x1,ax
   mov  rz_y4,ax
;   mov  ax,[stab+bx+192*2]
;   add  ax,cx
;   sar  ax,2
;   mov  rz_y4,ax
;   mov  ax,[stab+bx+0*2]
;   add  ax,cx
;   sar  ax,2
;   mov  rz_y3,ax
;   mov  ax,[stab+bx+64*2]
;   add  ax,cx
;   sar  ax,2
;   mov  rz_y2,ax
;   mov  ax,[stab+bx+128*2]
;   add  ax,cx
;   sar  ax,2
;   mov  rz_y1,ax
   call rotozoom

   mov  ax,backseg2
   mov  transp_src1,ax
   mov  ax,virseg2
   mov  transp_src2,ax
   mov  ax,virseg
   mov  transp_dst,ax
   mov  ax,transmap
   mov  transp_tab,ax
   call transp
   
   mov  fade_in,256+4
   mov  fade_out,512-4
   mov  fade_speed_out,6
   mov  fade_flash,0
   mov  ax,virseg
   mov  fade_seg,ax
   call fade_in_out   
   
   mov  ax,virseg
   mov  flip_src,ax
   mov  ax,0a000h
   mov  flip_dst,ax
   call flip

   mov  ax,600h
   mov  dl,0ffh
   int  21h
   cmp  al,27
   je   the_end

   call timer

   cmp  word ptr time,512
   jb   rottrs_loop;next2
;   jmp  rottrs_loop

;#############################################
;#########  EFFECT 3: SCROLL  ################
;#############################################

next2:
   mov  ax,txtseg
   mov  st_dst,ax
   lea  ax,text3
   mov  st_text,ax
   call settxt

   lea  si,stab
   mov  bx,128
   mov  ax,[si+bx]
   add  ax,128
   mov  ms_sz,ax
   mov  bx,128
   mov  ax,[si+bx+64]
   sar  ax,1
   add  ax,200
   mov  ms_rad,ax
   mov  ms_offs,0
   mov  ax,transmap
   mov  ms_dst,ax
   call make_sphere

next2b:

   mov  cx,transmap
   mov  sph_table,cx
   mov  ax,txtseg
   mov  bx,virseg
   mov  sph_src,ax
   mov  sph_dst,bx
   mov  bx,word ptr time
   neg  bx
   shl  bx,2
   mov  sph_offs,bx
   call sph

   mov  fade_in,512+4
   mov  fade_out,512+128-8
   mov  fade_speed_out,5
   mov  fade_flash,2
   mov  ax,virseg
   mov  fade_seg,ax
   call fade_in_out   

   mov  ax,virseg
   mov  flip_src,ax
   mov  ax,0a000h
   mov  flip_dst,ax
   call flip

   mov  ax,600h
   mov  dl,0ffh
   int  21h
   cmp  al,27
   je   the_end

   cmp  word ptr time,512+128
   jae  next3_1

   call timer

   jmp  next2b

;#############################################
;#########  EFFECT 4: ROTOZOOMER #############
;#############################################


next3_1:

   mov  cx,transmap
   mov  sph_table,cx
   mov  ax,txtseg
   mov  bx,virseg2
   mov  sph_src,ax
   mov  sph_dst,bx
   mov  bx,word ptr time
   shl  bx,2
   mov  sph_offs,bx
   call sph

   mov  ax,virseg2
   mov  rz_src,ax
   mov  ax,virseg
   mov  rz_dst,ax
   mov  bx,word ptr time
   sal  bx,2
   and  bh,00000001b
   mov  cx,[stab+bx]
   add  cx,256
   mov  di,128
   mov  bx,word ptr time
   shl  bx,3
   and  bh,00000001b
   mov  ax,[stab+bx]
   imul cx
   idiv di
   add  ax,128
   mov  rz_x3,ax
   mov  rz_y4,ax
   mov  ax,[stab+bx+64*2]
   imul cx
   idiv di
   add  ax,128
   mov  rz_x4,ax
   mov  rz_y1,ax
   mov  ax,[stab+bx+128*2]
   imul cx
   idiv di
   add  ax,128
   mov  rz_x1,ax
   mov  rz_y2,ax
   mov  ax,[stab+bx+192*2]
   imul cx
   idiv di
   add  ax,128
   mov  rz_x2,ax
   mov  rz_y3,ax
;   mov  ax,[stab+bx+192*2]
;   imul cx
;   idiv di
;   add  ax,128
;   mov  rz_y3,ax
;   mov  ax,[stab+bx+0*2]
;   imul cx
;   idiv di
;   add  ax,128
;   mov  rz_y4,ax
;   mov  ax,[stab+bx+64*2]
;   imul cx
;   idiv di
;   add  ax,128
;   mov  rz_y1,ax
;   mov  ax,[stab+bx+128*2]
;   imul cx
;   idiv di
;   add  ax,128
;   mov  rz_y2,ax
   call rotozoom

   mov  fade_in,512+128+4
   mov  fade_out,768+128-4
   mov  fade_speed_out,6
   mov  fade_flash,1
   mov  ax,virseg
   mov  fade_seg,ax
   call fade_in_out   

   mov  ax,virseg
   mov  flip_src,ax
   mov  ax,0a000h
   mov  flip_dst,ax
   call flip

   mov  ax,600h
   mov  dl,0ffh
   int  21h
   cmp  al,27
   je   the_end
;   mov  ah,6
;   mov  dl,0ffh
;   int  21h
;   jnz  next3

   cmp word ptr time,768+128
   jae next3

   call timer

   jmp  next3_1


;#############################################
;#########  EFFECT 5: CREDITS  ###############
;#############################################

next3:

   mov  ax,vritab
   mov  mvt_dst,ax
   mov  mvt_div,0
   call make_vritab

   mov  ax,backseg
   mov  mvt_dst,ax
   mov  mvt_div,2
   call make_vritab

   mov  ax,txtseg
   mov  cls_dst,ax
   call cls    

   mov  ax,txtseg
   mov  st_dst,ax
   lea  ax,text4
   mov  st_text,ax
   call settxt

cred1:

   mov  ax,vritab
   mov  rz_src,ax
   mov  ax,transmap
   mov  rz_dst,ax
   mov  bx,word ptr time
   sal  bx,2
   and  bh,00000001b
   and  bl,11111110b
   mov  ax,[stab+bx]
   mov  cx,ax
   add  ax,cx
   mov  rz_x3,ax
   mov  ax,[stab+bx+64*2]
   add  ax,cx
   mov  rz_x4,ax
   mov  ax,[stab+bx+128*2]
   add  ax,cx
   mov  rz_x1,ax
   mov  ax,[stab+bx+192*2]
   add  ax,cx
   mov  rz_x2,ax
   mov  ax,[stab+bx+192*2]
   mov  cx,ax
   add  ax,cx
   mov  rz_y3,ax
   mov  ax,[stab+bx+0*2]
   add  ax,cx
   mov  rz_y4,ax
   mov  ax,[stab+bx+64*2]
   add  ax,cx
   mov  rz_y1,ax
   mov  ax,[stab+bx+128*2]
   add  ax,cx
   mov  rz_y2,ax
   call rotozoom

   mov  ax,backseg
   mov  rz_src,ax
   mov  ax,virseg2
   mov  rz_dst,ax
   mov  ax,word ptr time
   sal  ax,2
   and  ah,00000001b
   and  al,11111110b
   mov  bx,512
   sub  bx,ax
   mov  ax,[stab+bx]
   mov  cx,ax
   add  ax,cx
   mov  rz_x3,ax
   mov  ax,[stab+bx+64*2]
   add  ax,cx
   mov  rz_x4,ax
   mov  ax,[stab+bx+128*2]
   add  ax,cx
   mov  rz_x1,ax
   mov  ax,[stab+bx+192*2]
   add  ax,cx
   mov  rz_x2,ax
   mov  ax,[stab+bx+192*2]
   mov  cx,ax
   add  ax,cx
   mov  rz_y3,ax
   mov  ax,[stab+bx+0*2]
   add  ax,cx
   mov  rz_y4,ax
   mov  ax,[stab+bx+64*2]
   add  ax,cx
   mov  rz_y1,ax
   mov  ax,[stab+bx+128*2]
   add  ax,cx
   mov  rz_y2,ax
   call rotozoom

   mov  ax,backseg2
   mov  bx,virseg
   mov  cx,transmap
   mov  vri_src,ax
   mov  vri_dst,bx
   mov  vri_table,cx
   mov  vri_offs,0
   call vri

   mov  ax,txtseg
   mov  bx,transmap
   mov  cx,virseg2
   mov  vri_src,ax
   mov  vri_dst,bx
   mov  vri_table,cx
   mov  vri_offs,0;
   call vri

   mov  bx,transmap
   mov  ax,virseg
   mov  msnotn_src,bx
   mov  msnotn_dst,ax
   mov  msnotn_n,64
   call msnotn

   mov  fade_in,768+128+4
   mov  fade_out,1024+128-4
   mov  fade_speed_out,6
   mov  fade_flash,0
   mov  ax,virseg
   mov  fade_seg,ax
   call fade_in_out   

   mov  ax,virseg
   mov  flip_src,ax
   mov  ax,0a000h
   mov  flip_dst,ax
   call flip

   mov  ax,600h
   mov  dl,0ffh
   int  21h
   cmp  al,27
   je   the_end


   cmp  word ptr time,1024+128
   jae  next5

   call timer

   jmp  cred1

;#############################################
;#########  EFFECT 6: STRANGE TUNNEL  ########
;#############################################

next5:

   mov  ax,txtseg
   mov  cls_dst,ax
   call cls    

   mov  ax,txtseg
   mov  st_dst,ax
   lea  ax,text3
   mov  st_text,ax
   call settxt

   lea  si,stab
   mov  bx,64
   mov  ax,[si+bx]
   add  ax,128
   mov  ms_sz,ax
   mov  bx,64
   mov  ax,[si+bx+64]
   sar  ax,1
   add  ax,200
   mov  ms_rad,ax
   mov  ms_offs,0
   mov  ax,transmap
   mov  ms_dst,ax
   call make_sphere

next3b:

   mov  ax,backseg
   mov  blend_dst,ax
   mov  ax,backseg2
   mov  blend_src1,ax
   mov  ax,txtseg
   mov  blend_src2,ax
   mov  ax,word ptr time
   shl  ax,4
   mov  blend_factor,al
   call blend

   jmp next3d

next3c:

   mov  ax,backseg
   mov  blend_dst,ax
   mov  ax,txtseg
   mov  blend_src1,ax
   mov  ax,backseg2
   mov  blend_src2,ax
   mov  ax,word ptr time
   shl  ax,4
   mov  blend_factor,al
   call blend

next3d:

   mov  cx,transmap
   mov  sph_table,cx
   mov  ax,backseg
   mov  bx,virseg
   mov  sph_src,ax
   mov  sph_dst,bx

   mov  ax,word ptr time
   shl  ax,3
   add  ax,128
   mov  sph_offs,ax
   call sph

   mov  fade_in,1024+128+4
   mov  fade_out,1024+256+128
   mov  fade_speed_out,1
   mov  ax,virseg
   mov  fade_seg,ax
   call fade_in_out   

   mov  ax,virseg
   mov  flip_src,ax
   mov  ax,0a000h
   mov  flip_dst,ax
   call flip

   mov  ax,600h
   mov  dl,0ffh
   int  21h
   cmp  al,27
   je   the_end

   cmp  word ptr time,1024+256+128+128
   jae  next4

   call timer

   mov  ax,word ptr time
   mov  bx,32
   xor  dx,dx
   div  bx
   cmp  dx,16
   jb   next3b
   jmp  next3c

next4:

;#############################################
;#########  END  #############################
;#############################################

the_end:

   mov  ax,3h
   int  10h
   
   lea  cx,msg5
   mov  dh,3
   mov  dl,35
   call print

   lea  cx,msg6
   mov  dh,11
   mov  dl,35
   call print

   lea  cx,msg8
   mov  dh,12
   mov  dl,34
   call print

   mov  ah,2
   mov  dx,24*256
   xor  bx,bx
   int  10h

   int  20h
            
            
;#############################################
;#########  PROCS  ###########################
;#############################################


flip proc   
;inn:   flip_dst
;       flip_src
   mov  ax,flip_dst
   mov  es,ax      
   mov  ax,flip_src
   push ds    
   mov  ds,ax  
           
   xor  bx,bx
   ;xor  si,si  
   xor  di,di  
   mov  si,7168;28*256
   mov  ax,199*256
           
flip_loop:  
   mov  dl,ds:[si]
   mov  es:[di+bx+32],dl
   inc  si   
   inc  bl   
   jnz  flip_loop
   add  di,320
   dec  ah   
   jnz  flip_loop      
         
   pop  ds   
   ret      
endp     
         
cls proc
;inn:   cls_dst
   mov  ax,cls_dst
   mov  es,ax
   xor  eax,eax
   xor  di,di     
   mov  cx,65536/4
   rep  stosd     
   ret     
endp       

comment @        
movseg proc   
;inn:   moveseg_dst
;       moveseg_src
   mov  bx,movseg_dst
   mov  es,bx
   mov  ax,movseg_src
   push ds
   mov  ds,ax
   xor  di,di
   xor  si,si
   mov  cx,65536/4
   rep  movsd
   pop  ds
   ret
endp
@

msnotn proc   
;inn:   msnotn_dst
;       msnotn_src
;       msnotn_n
   mov  bx,msnotn_dst
   mov  ax,msnotn_src
   mov  es,bx
   mov  fs,ax

   xor  di,di
msnotn_loop:
   mov  al,fs:[di]
   cmp  al,msnotn_n
   jb   msnotn_skip
   mov  es:[di],al
msnotn_skip:
   dec  di
   jnz  msnotn_loop

   ret
endp

scale_col proc
;inn:   sclc_src
;       sclc_dst
;       sclc_factor
   mov  bx,sclc_src
   mov  fs,bx
   mov  ax,sclc_dst
   mov  es,ax
   xor  di,di
   mov  bl,sclc_factor
scale_loop:
   mov  al,fs:[di]
   mul  bl 
   mov  es:[di],ah
   inc  di
   jnz  scale_loop
   ret
endp

scale_col_neg proc
;inn:   sclc_src
;       sclc_dst
;       sclc_factor
   mov  bx,sclc_src
   mov  fs,bx
   mov  ax,sclc_dst
   mov  es,ax
   xor  di,di
   mov  bh,sclc_factor
   mov  bl,-1
   sub  bl,bh
scale_neg_loop:
   mov  al,fs:[di]
   mul  bl 
   add  ah,bh
   mov  es:[di],ah
   inc  di
   jnz  scale_neg_loop
   ret
endp

blend proc
;inn:   blend_src1 
;       blend_src2
;       blend_dst
;       blend_factor
   mov  ax,blend_src1
   mov  fs,ax
   mov  bx,blend_src2
   mov  gs,bx
   mov  ax,blend_dst
   mov  es,ax
   mov  bl,blend_factor
   mov  bh,-1
   sub  bh,bl
   xor  di,di

blend_loop:
   mov  al,fs:[di] 
   mul  bl 
   mov  cl,ah
   mov  al,gs:[di]
   mul  bh
   add  ah,cl
   mov  es:[di],ah
   inc  di  
   jnz  blend_loop
   ret
endp

transp proc
;inn:   transp_src1 
;       transp_src2
;       transp_dst
;       transp_tab
   mov  ax,transp_src1
   mov  fs,ax
   mov  ax,transp_src2
   mov  gs,ax
   mov  ax,transp_dst
   mov  es,ax
   mov  ax,transp_tab
   push ds
   mov  ds,ax

   xor  di,di
transp_loop:
   mov  bl,ds:[di]
   mov  bh,255
   sub  bh,bl
;   add  bh,128
;   xor  bh,bh
;   sub  bh,bl
   mov  al,fs:[di] 
   mul  bl 
   mov  cl,ah
   mov  al,gs:[di]
   mul  bh
   add  ah,cl
   mov  es:[di],ah
   inc  di  
   jnz  transp_loop

   pop  ds
   ret
endp

blend2 proc
;inn:   blend2_src
;       blend2_dst
;       blend2_factor
;       blend2_offs1
;       blend2_offs2
   mov  ax,blend2_src
   mov  fs,ax
   mov  ax,blend2_dst
   mov  es,ax
   mov  cl,blend2_factor
   mov  ch,-1
   sub  ch,cl
   mov  di,blend2_offs1
   mov  si,blend2_offs2
   xor  bx,bx
   xor  bp,bp

blend2_loop:
   mov  al,fs:[di+bx] 
   mul  cl 
   mov  dl,ah
   mov  al,fs:[si+bx]
   mul  ch
   add  ah,dl
   mov  al,ah
   mov  es:[bp],ax
   mov  es:[bp+2],ax
   inc  bx  
   add  bp,4
   jnz  blend2_loop
   ret
endp

settab proc
;inn:     sint_frec
;         sint_amp
;         sint_length
;         sint_offs
   mov   cx,sint_length
   mov   si,sint_offs
   xor   bx,bx
   finit
   fild  sint_amp
   fldpi
   fild  sint_frec
   fdivp st(1),st
sint_loop:
   mov   sint_frec,bx
   fild  sint_frec
   fmul  st,st(1)
   fsin
   fmul  st,st(2)
   fistp word ptr [si+bx]
   add   bx,2
   loop  sint_loop
   ret
endp

setpal proc                                           
;inn:   spal_c
;       spal_r
;       spal_g
;       spal_b
   mov  dx,3c8h
   mov  al,spal_c
   out  dx,al
   inc  dx
   mov  al,spal_r
   out  dx,al
   mov  al,spal_g
   out  dx,al
   mov  al,spal_b
   out  dx,al
   ret  
endp setpal                                           
                                                      
random proc ;assembler;
;inn    rnd_randseed
;       rnd_range
;       rnd_rand1
;       rnd_rand2
   mov  ax,rnd_rand1
   mov  dx,rnd_rand2
   mov  cx,ax
   mul  rnd_randseed
   shl  cx,3
   add  ch,cl
   add  dx,cx
   shl  bx,2
   add  dx,bx
   add  dh,bl
   shl  bx,5
   add  dh,bl
   add  ax,1
   adc  dx,0
   mov  rnd_rand1,ax
   mov  rnd_rand2,dx
            
   mov  cx,dx
   mul  rnd_range
   mov  ax,cx
   mov  cx,dx
   mul  rnd_range
   add  ax,cx
   adc  dx,0
   mov  ax,dx
   ret
endp        
             
antialias proc
;inn    antial_dst
   mov  ax,antial_dst
   mov  es,ax
   xor  di,di
anti_loop:          
   xor  ax,ax
   xor  cx,cx
   mov  al,es:[di+1]
   mov  cl,es:[di-1]
   add  cx,ax
   mov  al,es:[di+256]
   add  cx,ax
   mov  al,es:[di-256]
   add  cx,ax
   shr  cx,2
   mov  es:[di],cl
   inc  di
   jnz  anti_loop
   ret
endp   
         

make_background proc
;inn:   backg_dst
;       backg_iters
   mov  m,0         
mb_init_loop:      
   mov  ax,4        
   mov  rnd_range,ax
   call random      
   imul ax,64       
   add  ax,63       
                  
   mov  bx,backg_dst
   mov  es,bx
   mov  di,m 
   mov  es:[di],al
   inc  m
   cmp  m,65535
   jb   mb_init_loop
     
   mov  teller,0
mb_loop:
   mov  rnd_range,65535
   call random
   mov  di,ax
   mov  ax,backg_dst
   mov  es,ax
   mov  al,byte ptr es:[di]
   mov  bl,al
   sub  bl,64
        
   cmp  es:[di+1],bl
   jne  mb_next1
   mov  es:[di+1],al
mb_next1: 
   cmp  es:[di-1],bl
   jne  mb_next2
   mov  es:[di-1],al
mb_next2: 
   cmp  es:[di+256],bl
   jne  mb_next3   
   mov  es:[di+256],al
mb_next3:       
   cmp  es:[di-256],bl
   jne  mb_next4   
   mov  es:[di-256],al
mb_next4: 
            
   inc  teller
   mov  ecx,backg_iters
   cmp  ecx,teller
   jae  mb_loop
         

   mov  m,10
mb_ant_loop1:
   mov  ax,backg_dst
   mov  antial_dst,ax
   call antialias  
   dec  m          
   jnz  mb_ant_loop1

   mov  bx,backg_dst
   mov  es,bx
   mov  bx,backg_pdst
   mov  fs,bx
   mov  di,backg_offs
   xor  si,si
mb_pack_loop:
   mov  al,es:[si]
   mov  fs:[di],al
   inc di
   add si,4
   jnz mb_pack_loop   

   ret      
endp     

settxt proc
   mov  es,st_dst
   mov  ax,0a000h
   mov  fs,ax
   
   mov  bx,st_text
   mov  al,[bx]
   mov  st_numoftxts,al
   inc  bx

txt_loop:   

   mov  cl,[bx]
   mov  dl,[bx+1]
   mov  st_x,cl
   mov  st_y,dl
   mov  al,[bx+2]
   mov  cl,[bx+3]
   mov  dl,[bx+4]
   mov  st_size_x,al
   mov  st_size_y,cl
   mov  st_numofchars,dl

   push bx
   mov  ah,2
   xor  bx,bx
   xor  dx,dx
   int  10h
   pop  bx

   add  bx,5
   mov  dx,bx
   mov  ah,9
   int  21h

   push bx
   
   mov  al,st_x
   mov  ah,st_y
   mov  di,ax

   mov  al,st_numofchars
   dec  al
   shl  al,3
   mov  cl,st_size_x
   mul  cl
   mov  st_txtwdt,al
   mov  cl,st_size_y
   shl  cl,3
   mov  st_txthgt,cl

   mov  ch,st_txthgt
st_scaleloop_y:
   mov  cl,st_txtwdt
st_scaleloop_x:

   mov  dl,st_size_y
   mov  al,ch
   xor  ah,ah
   div  dl
   mov  bl,al
   xor  bh,bh
   imul bx,320
   mov  al,cl
   xor  ah,ah
   mov  dl,st_size_x
   div  dl
   xor  ah,ah
   add  bx,ax
   mov  al,fs:[bx]
   cmp  al,0
   je   st_skipdraw
   mov  bx,cx
   mov  byte ptr es:[di+bx],255
st_skipdraw:

   dec  cl
   jnz  st_scaleloop_x
   dec  ch
   jnz  st_scaleloop_y

   pop bx

   movzx ax,st_numofchars
   add  bx,ax

   dec  st_numoftxts
   jnz  txt_loop

   mov  ax,es
   mov  antial_dst,ax
   call antialias
   call antialias
   call antialias
   call antialias
   call antialias
   call antialias

   ret
endp
   
make_vritab proc
   xor  ebx,ebx
   mov  ax,mvt_dst
   mov  es,ax
   xor  di,di
   
   xor  dh,dh
mvt_loopy:
   mov  dl,128
mvt_loopx:
   mov  bl,dl
   add  bl,bl
   mov  si,bx
   mov  al,byte ptr [stab+bx+si]
   mov  bl,dh
   mov  si,bx
   mov  cl,byte ptr [stab+bx+si+64]
   imul cl
   mov  cl,mvt_div
   sar  ax,cl

   mov  es:[di],ah

   mov  bl,dl
   add  bl,bl
   mov  si,bx
   mov  al,byte ptr [stab+bx+si+64]
   mov  bl,dh
   mov  si,bx
   mov  cl,byte ptr [stab+bx+si]
   imul cl
   mov  cl,mvt_div
   sar  ax,cl

   mov  es:[di+1],ah

   sub  di,2

   dec  dl
   jnz  mvt_loopx
   dec  dh
   jnz  mvt_loopy   
   ret
endp


vri proc
   mov  ax,vri_table
   mov  bx,vri_dst
   mov  cx,vri_src
   mov  es,ax
   mov  fs,bx
   mov  gs,cx
   mov  dx,vri_offs
   
   xor  di,di
   
vri_loop:
   
   mov  bx,dx
   mov  bx,es:[di+bx]
   mov  al,gs:[bx+di]
   mov  ah,gs:[bx+di+1]
   mov  fs:[di],ax

   sub  di,2
   jnz  vri_loop
   
   ret
endp

sph proc
   mov  ax,sph_table
   mov  bx,sph_dst
   mov  cx,sph_src
   mov  es,ax
   mov  fs,bx
   mov  gs,cx
   mov  si,sph_offs
   and  si,1111111111111110b
   xor  di,di
   
sph_loop:
   
   mov  bx,es:[di]
   and  bx,1111111111111110b
   mov  ax,gs:[bx+si]
   mov  fs:[di],ax

   add  di,2
   jnz  sph_loop
   
   ret
endp


rotozoom proc
;inn    rz_x1
;       rz_y1
;       rz_x2
;       rz_y2
;       rz_x3
;       rz_y3
;       rz_x4
;       rz_y4
;       rx_dst
;       rz_src

   mov  ax,rz_dst
   mov  bx,rz_src
   mov  es,ax
   mov  fs,bx

   mov  di,rz_x4
   mov  bp,rz_x1 
   sub  di,bp
   lea  si,rz_vxtab
   call interp
    
   mov  di,rz_x3
   mov  bp,rz_x2
   sub  di,bp
   lea  si,rz_hxtab
   call interp

   mov  di,rz_y4
   mov  bp,rz_y1 
   sub  di,bp
   lea  si,rz_vytab
   call interp
    
   mov  di,rz_y3
   mov  bp,rz_y2
   sub  di,bp
   lea  si,rz_hytab
   call interp


   xor  di,di
   xor  ch,ch
rz_rotoloop:
   xor  cl,cl

   xor  bx,bx 
   mov  bl,ch
   add  bx,bx
   xor  ebp,ebp
   xor  edx,edx
   mov  bp,[rz_hxtab+bx]
   mov  ax,[rz_vxtab+bx]
   sub  bp,ax
   mov  rz_addx,bp
   mov  bp,[rz_hytab+bx]
   mov  si,[rz_vytab+bx]
   sub  bp,si
   mov  rz_addy,bp
   shl  si,8
   add  si,ax
   and  si,1111111111111110b
   
rz_innerloop:

   add  bp,rz_addx
   mov  ax,bp
   shl  ax,1
  
   add  dx,rz_addy
   mov  bx,dx

   mov  bl,ah
   and  bx,1111111111111110b
   
   mov  ax,fs:[bx+si]
   mov  es:[di],ax
   add  di,2

   add  cl,2
   jnz  rz_innerloop
   inc  ch
   jnz  rz_rotoloop

   ret
   
interp:
   xor  cx,cx
rz_interloop:
   mov  ax,di
   imul cx
   mov  bx,256
   idiv bx
   add  ax,bp
   mov  [si],ax
   add  si,2
   inc  cl
   jnz  rz_interloop
   ret

endp

make_sphere proc
   mov ax,ms_dst
   mov es,ax
   mov si,ms_offs
   xor di,di
   
   finit
   mov ms_y,128
ms_yloop:
   mov ms_x,128
ms_xloop:

   mov  bx,ms_x
   imul bx,bx
   mov  cx,ms_y
   imul cx,cx
   mov  ax,ms_rad
   imul ax,ax
   sub  ax,cx
   sub  ax,bx

   mov   ms_z,ax
   fild  ms_z
   fabs
   fsqrt
   fistp ms_z

   cmp  ms_z,0
   jne  ms_not0
   mov  ms_z,1  
ms_not0:

   mov  ax,ms_z
   sub  ax,ms_sz
   imul ms_x
   idiv ms_z
   mov  bl,al
  
   mov  ax,ms_z
   sub  ax,ms_sz
   imul ms_y
   idiv ms_z
   mov  bh,al

   mov  es:[di],bx

   add  di,2
   
   sub  ms_x,2
   cmp  ms_x,-128
   jne  ms_xloop

   dec  ms_y
   cmp  ms_y,-128
   jne  ms_yloop

   ret
endp

timer proc
   xor ax,ax
   int 1ah
   mov ax,cx
   shl eax,16
   mov ax,dx
   sub eax,starttime
   mov time,eax   
   ret
endp

print proc
;inn:      dh = row
;          dl = col
;          cx = offset(text)
   push cx
   mov  ah,2
   xor  bx,bx
   int  10h
   pop  cx
   mov  dx,cx
   mov  ah,9
   int  21h
   ret
endp

reset_time proc
   xor  ax,ax
   int  1ah
   mov  ax,cx
   shl  eax,16
   mov  ax,dx
   mov  starttime,eax
   ret
endp   

fade_in_out proc
;inn          fade_in
;             fade_out
;             fade_seg
   mov  ax,fade_in
   cmp  ax,word ptr time
   jbe  skip_fade_in
   mov  ax,fade_seg
   mov  sclc_src,ax
   mov  sclc_dst,ax
   mov  ax,word ptr time
   sub  ax,fade_in
   shl  ax,6
   mov  sclc_factor,al
   cmp  fade_flash,1
   jne  fade_skip_flash_in
   call scale_col_neg
   jmp  skip_fade_in
fade_skip_flash_in:
   call scale_col
skip_fade_in:

   mov  ax,fade_out
   cmp  ax,word ptr time
   jae  skip_fade_out
   mov  ax,fade_seg
   mov  sclc_src,ax
   mov  sclc_dst,ax
   mov  ax,word ptr time
   sub  ax,fade_out
   mov  cl,fade_speed_out
   shl  ax,cl
   neg  al
   mov  sclc_factor,al
   cmp  fade_flash,2
   jne  fade_skip_flash_out
   call scale_col_neg
   jmp  skip_fade_out
fade_skip_flash_out:
   call scale_col
skip_fade_out:

   ret
endp


align 2


rnd_ncols       equ 4

rnd_randseed    dw 8405h

text            db 4,36,64,3,8,9,'AN   AtA$',36,88+32,3,8,9,'ThE  IcK$',84,64,5,8,2,'A$',118,64,5,16,2,'K$'
text2           db 2,18,64,4,6,7,'IT',39,'S A$',32,112,6,6,5,'KICK$'
text3           db 1,16,128,4,32,8,'ANAKATA$'
text4           db 2,16,56,7,6,5,'code$',16,100,7,10,5,'ZARR$'
msg1            db 'Please $'
msg2            db 'don',39,'t $'
msg3            db 'reboot! $'
msg5            db 'End of Fun$'
msg6            db 'Code..Zarr$'
msg8            db 'ANAKATA 1999$'

time            dd ?   
starttime       dd ?

stab            dw 4096 dup (?)

sph_offs        dw ?
sph_table       dw ?
sph_dst         dw ?
sph_src         dw ?

fade_in         dw ?
fade_out        dw ?
fade_seg        dw ?
fade_speed_out  db ?
fade_flash      db ? ;0 = no flash, 1 = flash in, 2 = flash out

ms_offs         dw ?
ms_dst          dw ?
ms_rad          dw ?   
ms_x            dw ?   
ms_y            dw ?   
ms_z            dw ?   
ms_sz           dw ?   
ms_x1           dw ?
ms_y1           dw ?

fd_xp           dw ?
fd_yp           dw ?
fd_zp           dw ?
fd_src          dw ?
fd_dst          dw ?
fd_hgt          dw ?
fd_dist         dw ?
fd_x            dw ?
fd_y            dw ?
fd_xt           dw ?
fd_yt           dw ?
fd_zt           dw ?


rz_addx         dw ?
rz_addy         dw ?
rz_vxtab        dw 100h dup (?)
rz_hxtab        dw 100h dup (?)
rz_vytab        dw 100h dup (?)
rz_hytab        dw 100h dup (?)
rz_x1           dw ?
rz_y1           dw ?
rz_x2           dw ?
rz_y2           dw ?
rz_x3           dw ?
rz_y3           dw ?
rz_x4           dw ?
rz_y4           dw ?
rz_dst          dw ?
rz_src          dw ?

st_dst          dw ?
st_text         dw ?
st_numoftxts    db ?
st_x            db ?
st_y            db ?
st_size_x       db ?
st_size_y       db ?
st_numofchars   db ?
st_tpoint       db ?
st_txtwdt       db ?
st_txthgt       db ?

vri_table       dw ?
vri_dst         dw ?
vri_src         dw ?
vri_offs        dw ?

rnd_rand1       dw ?
rnd_rand2       dw ?
rnd_range       dw ?

sint_frec       dw ?
sint_amp        dw ?
sint_length     dw ?
sint_offs       dw ?

mvt_dst         dw ?
mvt_div         db ?

m               dw ?
teller          dd ?
virseg          dw ?
virseg2         dw ?
backseg         dw ?
backseg2        dw ?
transmap        dw ?
txtseg          dw ?
vritab          dw ?

cls_dst         dw ?

flip_dst        dw ?
flip_src        dw ?   

movseg_dst      dw ?
movseg_src      dw ?

msnotn_dst      dw ?
msnotn_src      dw ?
msnotn_n        db ?

antial_dst      dw ?

sclc_src        dw ?
sclc_dst        dw ?
sclc_factor     db ?

backg_dst       dw ?
backg_iters     dd ?
backg_pdst      dw ?
backg_offs      dw ?

blend_src1      dw ?
blend_src2      dw ?
blend_dst       dw ?
blend_factor    db ?

transp_src1     dw ?
transp_src2     dw ?
transp_dst      dw ?
transp_tab      dw ?

blend2_src      dw ?
blend2_dst      dw ?
blend2_factor   db ?
blend2_offs1    dw ?
blend2_offs2    dw ?

spal_c          db ?
spal_r          db ?
spal_g          db ?
spal_b          db ?

cseg ends
end start

;   mov  ah,35h
;   mov  al,8
;   int  21h
;   mov  oldint_ofs,bx
;   mov  ax,es
;   mov  oldint_seg,ax

;   lea  dx,int1c
;   mov  ah,25h
;   mov  al,8
;   int  21h
   
;   cli
;   mov  al,00110110b
;   out  43h,al      
;   mov  ax,2000;2e9ch
;   out  40h,al
;   xchg al,ah       
;   out  40h,al
;   sti

;   mov  dx,oldint_ofs
;   mov  ax,oldint_seg
;   mov  ds,ax
;   mov  ah,25h
;   mov  al,8
;   int  21h
