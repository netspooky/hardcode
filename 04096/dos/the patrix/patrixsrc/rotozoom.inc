ang180 dd 180

RotoZoom PROC ;frame - angulo , 

        finit


;        fild small frame
;        fdiv small r200
;        fsin
;        fmul rm160
;        fadd rm160
;        fistp XCenter


;        fild small frame
;        fdiv small r200
;        fcos
;        fmul rm120
;        fadd rm120
;        fistp small YCenter


        ;ZooM=fabs(cos(float(frame)/80.0)*4.0);

;        fild small frame
;        fdiv small r80
;        fcos
;        fmul small r4
;        fabs
;        fstp small ZooM


         FLDPI       ;push PI
         FILD frame ;push angtmp
         FIDIV ang180
         FMULP

       

      ;Vx=sin(float(frame)/60.0+sin(float(frame)/80.0)*5.0)*256.0*ZooM;

        fld st

        fsin
        fmul small r256
        fmul small ZooM

        fistp Vx


        ;Vy=cos(float(frame)/86.0+sin(float(frame)/80.0)*5.0)*256.0*ZooM;

        fld st

        fcos
        fmul small r256
        fmul small ZooM

        fistp small Vy

        fstp st



       ; MapX=XCenter*Vx-YCenter*Vy +185*256;

        fild small XCenter
        fimul small Vx
        fild small YCenter
        fimul small Vy
        fsub
        fistp small MapX
        add small MapX,128*256


       ; MapY=XCenter*Vy+YCenter*Vx +230*256;

        fild small XCenter
        fimul small Vy
        fild small YCenter
        fimul small Vx
        fadd
        fistp small MapY
        add small MapY,128*256

;;;;;;;;;;;;;;; WHERE IS THE BUUUUUUUUUUUUUUUUUUUUUUGGGGGGGGG!!!!!!??????;;;

        ;temp0_l =(MapY & 0xffff)<<16;
        ;temp0_l|= MapX & 0xffff;

        mov eax,MapY
        mov ebx,MapX

        push eax ebx

        shl eax,16

        mov ax,bx

        mov small dword ptr temp0,eax

        ;temp0_h =((MapY+Vy) & 0xffff)<<16;
        ;temp0_h|=((MapX+Vx) & 0xffff);


        pop ebx eax
        add eax,Vy
        add ebx,Vx
        push eax ebx
        shl eax,16
        mov ax,bx

        mov small dword ptr temp0+4,eax

        ;temp1_l =((MapY+Vy*2) & 0xffff)<<16;
        ;temp1_l|=((MapX+Vx*2) & 0xffff);


        pop ebx eax
        add eax,Vy
        add ebx,Vx
        push eax ebx
        shl eax,16
        mov ax,bx
        mov small dword ptr temp1,eax


        ;temp1_h =((MapY+Vy*3) & 0xffff)<<16;
        ;temp1_h|=((MapX+Vx*3) & 0xffff);

        pop ebx eax

        add eax,Vy
        add ebx,Vx
        shl eax,16
        mov ax,bx
        mov small dword ptr temp1+4,eax


        ;temp2_l =((Vy*4) & 0xffff)<<16;
        ;temp2_l|=((Vx*4) & 0xffff);

         mov eax,Vy
         mov ebx,Vx
         shl eax,2+16
         shl ebx,2
         mov ax,bx

         mov small dword ptr temp2,eax

        ;temp2_h =((Vy*4) & 0xffff)<<16;
        ;temp2_h|=((Vx*4) & 0xffff);

        mov small dword ptr temp2+4,eax

        ;temp3_l =(int(float(Vx)*PROP) & 0xffff)<<16;
        ;temp3_l|=int(-float(Vy)*PROP) & 0xffff;

         fild small Vx
         fmul small PROPr
         fistp small ttt

         mov eax,small ttt
         shl eax,16

         fldz
         fisub Vy    ;0-Vy

         fmul PROPr
         fistp ttt
         mov ebx,ttt
         mov ax,bx

         mov small dword ptr temp3,eax


        ;temp3_h =(int(float(Vx)*PROP) & 0xffff)<<16;
        ;temp3_h|=int(-float(Vy)*PROP) & 0xffff;

         mov small dword ptr temp3+4,eax



           ;MOV ESI,Textura256x256
           ;MOV EDI,RBuffer

           MOVQ mm0,temp0
           MOVQ mm1,temp1
           MOVQ mm2,mm0
           MOVQ mm3,mm1
           MOVQ mm4,temp2
           MOVQ mm5,temp3

         MOV ECX,240
@@RZLoopY: PUSH ECX       

         MOVQ mm0,mm2      ;las posiciones de comienzo del scanline
         MOVQ mm1,mm3
                  

         MOV ECX,80 ;320/4
@@RZLoopX:
         PADDW mm0,mm4
         PADDW mm1,mm4

         MOVQ mm6,mm0
         MOVQ mm7,mm1

         PSRLW mm6,8
         PSRLW mm7,8

         PACKUSWB mm6,mm7

         MOVD EBX,mm6
         MOV EDX,EBX

         AND EBX,0FFFFh
         SHR EDX,16


         MOV EAX,[ESI+EBX*4]
         STOSD
         MOV EAX,[ESI+EDX*4]
         STOSD

         PSRLQ mm6,32

         MOVD EBX,mm6

         MOV EDX,EBX
         AND EBX,0FFFFh
         SHR EDX,16


         MOV EAX,[ESI+EBX*4]
         STOSD
         MOV EAX,[ESI+EDX*4]
         STOSD

         dec ecx
         jnz @@RZLoopX

         PADDW mm2,mm5   ;cambiamos el inicio del scanline
         PADDW mm3,mm5
         PADDW mm2,mm5   ;cambiamos el inicio del scanline
         PADDW mm3,mm5




         POP ECX
         dec ecx
         jnz @@RZLoopY

         EMMS
         ret
RotoZoom ENDP
