
sEnd       EQU 0
sLine      EQU 1
sVLine     EQU 2
sElipse    EQU 3
sRectangle EQU 4
sFill      EQU 5

;secuencias:
;00 - [end      ]
;01 - [line     ]  x0 y0 x1 y1
;02 - [vline    ]  y0 y1 x
;03 - [elipse   ]  xc yc a  b  
;04 - [rectangle]  x0 y0 x1 y1 
;05 - [fill     ]  color_index x0 y0       
;>=06 - [ end]

secuencia PROC  ; esi -> secuencia, edi -> textura

@cmdLoop:
        lodsb ;ins
        xor ecx,ecx
        xor ebx,ebx


@line:  cmp al,1
        jne @vline  ;line PROC  ;AL=X0, AH=Y0, BL=X1, BH=Y1, ECX=Color RGB
        lodsb ;x0
        mov dl,al
        lodsb ;y0
        mov ah,al
        lodsb ;x1
        mov bl,al
        lodsb ;y1
        mov bh,al
        mov al,dl
        call line
        jmp @cmdLoop

@vline: cmp al,2      ;vline PROC ;BL=X , BH=Y0, CH=Y1, EAX=Color RGB
        jne @elipse


        lodsb ;y0
        mov bh,al
        lodsb ;y1
        mov ch,al
        lodsb ;x
        mov bl,al

        xor eax,eax
        call vline

        jmp @cmdLoop

@elipse: cmp al,3       ;elipse PROC ;bl=XC, bh=YC, ah=A, al=B, ecx=Color
         jne @rectangle

        lodsb ;xc
        mov bl,al
        lodsb ;yc
        mov bh,al
        lodsb ;a
        mov ah,al
        lodsb ;b
        call elipse

        jmp @cmdLoop
        
@rectangle:             ;rectangle PROC  ;bl=X0, bh=y0, cl=X1, ch=Y1 EAX=color
         cmp al,4
         jne @fill

        lodsb ;x0
        mov bl,al
        lodsb ;y0
        mov bh,al
        lodsb ;x1
        mov cl,al
        lodsb ;y1
        mov ch,al

        mov eax,00ffffffh

        call rectangle

        jmp @cmdLoop


@fill:   cmp al,5       ;fill PROC   ;bl=x bh=y ecx=color edx=fondo
         jne @endSec

        lodsb
        movzx ebx,al
        lea ebx,[colortab+ebx*4]
        mov eax,[ebx]
        mov ecx,eax   ;color en ECX

        mov edx,00ffffffh

        lodsb ;x0
        mov bl,al
        lodsb ;y0
        mov bh,al

        call fill

        jmp @cmdLoop


@endSec:
        ret
secuencia ENDP

;void line(int x0, int y0, int x1, int y1, int c) {
;
line PROC  ;AL=X0, AH=Y0, BL=X1, BH=Y1, NEGRA
;        //dibuja una linea
;        //siempre debe ser x0<x1
;        register double i;
;        register double m=(double)((y1-y0))/(double)((x1-x0));

        movzx edx,ah
        mov small tmpy0,edx

        movzx edx,bh
        movzx ecx,ah
        sub edx,ecx             
        mov small tmpint,edx
        fild small tmpint

        movzx edx,bl
        movzx ecx,al

        mov small tmpx1,edx
        mov small tmpx0,ecx        
        sub edx,ecx
        mov small tmpint,edx

        fidiv small tmpint                

        fstp small m

        fild small tmpx0   ;cargamos I=X0 en ST(0)

        

;        for (i=x0;i<=x1;i=i+0.001)
@LoopLine:
        xor ebx,ebx     ;limpiamos ebx
;                plot(i,y0+(double)(m*(i-x0)),c);
         fld st(0)              ;i-x0
         fisub small tmpx0
         fmul small m           ;*m
         fiadd small tmpy0      ;+y0

         fistp small tmpint           

         mov bh,small byte ptr tmpint

         fist tmpint
         mov bl,small byte ptr tmpint  ;X=i

         lea ebx,[edi+ebx*4]

         mov dword ptr [ebx],00000000h

         fadd small fincrement

         fist small tmpint
         mov ebx,small tmpint
         cmp ebx,small tmpx1
         jbe @LoopLine

         fistp small tmpint ;Liberamos I de la pila

         ret


;}
line ENDP


;void vline(int y0, int y1, int x, int c) {
vline PROC ;BL=X , BH=Y0, CH=Y1, NEGRA
;        //dibuja una linea vertical

         movzx edx,ch   ;edx=Y1
         movzx ecx,bh   ;ecx=Y0
         sub edx,ecx    ;distancia Y1<->Y0
         shl ebx,2      ;EBX*4 <- posicion inicial
                
	xor eax,eax
@LoopVline:        
        mov [ebx+edi],eax
        add ebx,256*4
        dec edx
        jnz @LoopVline

        ret
        

vline ENDP
;}


;void elipse(int xc, int yc, int a, int b,int c) {
elipse PROC ;bl=XC, bh=YC, ah=A, al=B, NEGRA
;        //dibuja una elipse (sin rotacion, semiejes y listo)
;        //xc,yc centro
;        //a semieje x
;        //b semieje y
;        //c color
;        register float i;
;        register int temp;
tmp_a EQU tmpx1
tmp_b EQU tmpx0
tmp_prop EQU tmpy0

         fldz
         movzx edx,ah
         mov small tmp_a,edx   
         fisub small tmp_a     ;st(0)=-a
         movzx edx,al
         mov small tmp_b,edx    

        fild small tmp_b        ;st(0)=b/a
        fidiv small tmp_a
        fstp small tmp_prop     ;tmp_prop=st(0) pop
	xor eax,eax
        
@LoopElipse:
;        for (i=-a;i<a;i=i+0.001) {

;                temp=(((float)(b)/(float)(a))*sqrt(a*a-i*i));

         fild small tmp_a   ;a*a  
         fmul st(0),st(0)


         fld st(1) ;i       ;i*i
         fmul st(0),st(0)

        
         fsubp st(1),st(0)  ;s(0)=a*a-i*i
                 
         fsqrt              ;sqrt(a*a-i*i)

         fmul small tmp_prop ;*(b/a)

         fistp small tmpint ;tmpint=temp
         fist small tmpint2 ;tmpint2=i

         push ebx
         add bl,small byte ptr tmpint2
         add bh,small byte ptr tmpint
         lea ebx,[ebx*4+edi]
         mov [ebx],eax

         pop ebx
         push ebx

         add bl,small byte ptr tmpint2
         sub bh,small byte ptr tmpint
         lea ebx,[ebx*4+edi]
         mov [ebx],eax

         fadd fincrement

         fist small tmpint
         mov ebx,tmp_a
         cmp small tmpint,ebx
         pop ebx
         jle @LoopElipse

         fistp small tmpint ; vaciamos St(0)=i

        ret
;        }
elipse ENDP
;}


;void rectangle(long x0, long y0, long x1, long y1, int c) {
rectangle PROC  ;bl=X0, bh=y0, cl=X1, ch=Y1 BLANCO
;        //rellana con color c, el rectangulo
;        //x0,y0 esquina superior izq
;        //x1,y1 esquina inferior der
;        register long i,j;

        movzx ebx,bx
        mov edx,ebx

@LoopYR:

        mov bl,dl ;restauramos X
@LoopXR:
         push ebx
         lea ebx,[ebx*4+edi]
         mov [ebx],00FFFFFFh
         pop ebx

         inc bl
         cmp bl,cl
         jb @LoopXR

         inc bh
         cmp bh,ch
         jb @LoopYR

        ret
;}
rectangle ENDP

;void fill(long x, long y, int color, int fondo) {
fill PROC   ;bl=x bh=y ecx=color edx=fondo

        movzx ebx,bx
        push ebx eax

;        if (pixel(x,y) == fondo) {
        lea ebx,[ebx*4+edi]
        mov eax,[ebx]
        cmp eax,edx
        jne @no_es_fondo

        mov eax,ecx
        mov [ebx],eax ;   plot(x,y,color);

        pop eax ebx
        push eax
        mov eax,ebx ;salvo ebx

        inc bh
        call fill    ;//              fill(x,y+1,color,fondo);
        mov ebx,eax

        dec bh
        call fill    ;//              fill(x,y-1,color,fondo);
        mov ebx,eax

        dec bl
        call fill    ;//              fill(x-1,y,color,fondo);   
        mov ebx,eax

        


        inc bl
        call fill     ;//              fill(x+1,y,color,fondo);
;        mov ebx,eax


        pop eax
;
;        }
        ret
@no_es_fondo:
        pop eax ebx
       ret 
fill ENDP
;}


