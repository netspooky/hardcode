;############################################################################
;
; FOUR PAST MIDNIGHT MULTI INTRO...
;
; Code, Design and Graphics: Chc from Reset-Tvc
; Muzak: who knows??
; Adlib FM code: JCH from Vibrants
;
; Sant Joan Desp¡, Barcelona, 29 de Gener de 1994
;
; Greets goes to: Gvyt,darkmind,De-Pha$$ed,dyonisos,FxSoft,King Graham,Slump
;                 Elfo,Skatur,Fiber,Spiral,Red Devil,Ked...and all the guys
;                 I forgot...
;
; Source code compiled with TASM 3.2 (I think if will work correctly with
; TASM 2.x ...)
;
; NOTES: this code waz done in only three days before a Maths examination,
;        it is not very nice, but it runs at full speed...
;        For ANY comment, sugestion, or something like this, yo can
;        contact me in Four Past Midnight BBS:
;
;               Handle: Chechu
;
;        Or writing to:
;
;               Jorge Cabezas Garcia/Chc
;               C/ Valencia 1
;               San Juan Despi
;               Barcelona
;               SPAIN
;
;############################################################################

        jumps

;el segmento de pila...

pila     SEGMENT para stack 'STACK'
	 DB      64 DUP(0)
pila     ENDS

;el segmento de datos...

data   SEGMENT    para public 'DATA'

        include driver.inc                      ; driver include file
        MusicOffset = $-data                    ; Offset for the music
        include song.inc                        ; the music!
        include plasma.inc                      ; gr fico del plasma
        include tile.inc                        ; tile n£mero 1...
        include tile2.inc                       ; tile n£mero 2...
        include logo.inc
SINUS LABEL BYTE
        include seno.inc                        ; la tabla de seno...
        include seno.inc
        numstars dw 150
        speedx   dw 0
        speedy   dw 0
        speedz   dw 0
        distanciareal dw 200
        include stars.inc
        error    db 'Sorry...but this intro needs at least a 386 to run... $'

        ;mensaje final...
        mensaje  db 'Four Past MidNight Intro .... CALL IT NOW! Phone Numba: +34-3-FINDIT!',10,13,10,13
                 db 'þ Code and graphics: Chc from Reset-Tvc',10,13
                 db 'þ Design: Chc and Tranx',10,13
                 db 'þ Adlib code: JCH from Vibrants',10,13
                 db 'þ Greets goes to: Tranx (cool sysop!),Dyonisos,Darkmind,Skatur,',10,13
                 db '                  De-Phassed,FxSoft,King Graham,Slump,Ked,Spiral,',10,13
                 db '                  Elfo,Fiber,Red Devil and all the others!!! ',10,13,'$'

        ;mensaje del scroll de texto...Tranx!
        texto    db 'YAH, U GOT IT! AGAIN! NOW FROM FOUR PAST MIDNIGHT, AND HERE I AM TO TELL '
                 db 'YOU TO CALL MY SUPER-MEGA-BOARD 4PM OR R U SCARED WITH THE FEDS? '
                 db 'I WON',34,'T TELL U THE NUMBA SINCE I SUPPOSE YAR SO ELITE TO FIND IT '
                 db 'YARSELF , IF NOT THEN FUCK U AND KEEP CALLING THE SAME BOARDS YAR '
                 db 'GRANDPA USED TO CALL TO...ENJOY IT! LIVE IT! SPURTING 0-1 DAY WAREZ '
                 db 'LIKE A CUMMING ELEPHANT COCK USING TWO USR DS.LOTS OF THANX TO CHC '
                 db 'FOR THIS KEWL AND AWESOME LITE INTRO MADE IN SOME HOURS. '
                 db 'OH I ALMOST FORGET...NO LAMERS, LEECHERS, FIDOLAMERS OR ANY OTHER '
                 db 'KIND OF NON-WANTED-ANYWHERE PEOPLE ARE ALLOWED! CALL ONLY IF YOU '
                 db 'HAVE SOMETHING IMPORTANT TO OFFER US AND DON',34,'T GIVE THE NUMBA TO '
                 db 'LAME PEOPLE COS THEY MAKE THE BOARD BUSY THE WHOLE TIME...OK '
                 db 'THAT',34,'S ALL JUST REMIND THIS: CALL TO 4PM, CALL TO 4PM, CALL TO 4PM '
                 db '....AND.....UPLOAD....UPLOAD....UPLOAD....HEHEHE..... '
                 db 'WHAT ARE YOU DOING STILL HERE?? U SHOULD BE GONE RITE NOW! '
                 db '                       ',0

                 ;para el scroll de texto utilizo un doble buffer de intermedio,
                 ;que me quita algo de memoria pero es MUY r pido...

        buffer   db 320*8*2 dup(0)
                 db 320 dup(0)

                 ;fuente a utilizar en el scroll de texto

                 include font.inc
data ends

;y nuestro segmento de c¢digo...

code    segment byte public 'code'
        assume cs:code,ds:data

        P386

IMR     db 0    ;m scara del PIC
Escape  db 0    ;estado de la tecla escape
cicle   dw 0    ;ciclo de la paleta actual

;estos dos bytes sirven para la sincronizaci¢n de algunos movimientos...

sincro  db 0
sincro2 db 0

;constantes de las estrellas

;amplitud del campo estelar en X,Y y Z

MaxXpos     EQU 400
MinXpos     EQU -400
MaxYpos     EQU 400
MinYpos     EQU -400
MaxZpos     EQU 4095
MinZpos     EQU 100

;centro del campo estelar

CentroX     EQU 240
CentroY     EQU 152

;color inicial de las estrellas

Color       EQU 1


;******************************************************************************
; Este es el scroll de texto...
;******************************************************************************

;aqui utilizo una tabla para buscar la letra correspondiente

letras  db 'ABCDEFGHIJKLMNOPQRSTUVWXYZ.,!-',34,':014? ',0
bufpos  dw 0                    ;posici¢n del buffer visualizada actualmente
textpos dw OFFSET texto         ;posici¢n en el texto
contpos dw 1                    ;contador de anchura de una letra...
actlet  dw 0                    ;letra actual que se est  dibujando...

scroll  proc

        mov ax,0a000h           ;segmento de video
        mov es,ax

        dec byte ptr cs:[contpos]
        jnz no_new_letter       ;mira si es necesaria una nueva letra

        inc word ptr cs:[textpos]

        mov bx,cs:[textpos]
        mov al,[bx]             ;si se necesita una nueva letra b£scala, excepto
        test al,0ffh            ;si es un 0...que indica que es el final del
        jnz no_restart          ;scroll...

        mov bx,OFFSET texto     ;restaura en ese caso la posici¢n del scroll
        mov cs:[textpos],bx
        mov al,[bx]

no_restart:
        xor bx,bx
        mov di,OFFSET letras
siu:    cmp al,cs:[di]          ;buscas la letra en la tabla para saber su
        je acaba                ;posici¢n real en la fuente...
        inc di
        inc bx
        jmp siu

acaba:  shl bx,3                ;*8
        add bx,OFFSET font
        mov cs:[actlet],bx      ;en BX est  la posici¢n real de la letra en la
                                ;fuente
        mov byte ptr cs:[contpos],8

no_new_letter:
        mov bx,cs:[actlet]      ;ahora coge la posici¢n de la letra
        inc word ptr cs:[actlet]

        mov di,cs:[bufpos]      ;y ahora dibuja la linea vertical correspondiente
        add di,OFFSET buffer    ;a esa posici¢n en el buffer de video...
        mov al,[bx]
        mov [di],al
        mov [di+320],al
        mov al,[bx+320]
        mov [di+640],al
        mov [di+640+320],al
        mov al,[bx+320*2]
        mov [di+640*2],al
        mov [di+640*2+320],al
        mov al,[bx+320*3]
        mov [di+640*3],al
        mov [di+640*3+320],al
        mov al,[bx+320*4]
        mov [di+640*4],al
        mov [di+640*4+320],al
        mov al,[bx+320*5]
        mov [di+640*5],al
        mov [di+640*5+320],al

        inc word ptr cs:[bufpos]        ;incremento la posici¢n del buffer
        cmp word ptr cs:[bufpos],320    ;intermedio...teniendo en cuenta que
        jne siu2                        ;es un buffer CIRCULAR...
        mov word ptr cs:[bufpos],0

siu2:   mov si,OFFSET buffer            ;ahora pasa el buffer intermedio a la
        mov di,32000-320*3              ;memoria de video...
        add si,cs:[bufpos]
        cld
        mov cx,320
        rep movsb                       ;una linea...
        add si,320
        mov cx,320
        rep movsb                       ;siguiente linea...
        add si,320
        mov cx,320
        rep movsb                       ;etc...
        add si,320
        mov cx,320
        rep movsb
        mov cx,320
        add si,320
        rep movsb
        add si,320
        mov cx,320
        rep movsb

        ret

scroll  endp

;******************************************************************************
; Ahora viene la parte de las estrellas 3D...
;******************************************************************************

;el macro move realiza el movimiento cada coordenada de una estrella y
;la trunca si es necesario...

move        macro despl1,despl2,maximo,minimo
            LOCAL no_mayor,no_menor
            mov ax,[di+despl1]
            add ax,[despl2]
            cmp ax,maximo
            jnge no_mayor
            sub ax,maximo-minimo
no_mayor:   cmp ax,minimo
            jnl no_menor
            add ax,maximo-minimo
no_menor:   mov [di+despl1],ax
            ENDM

;el movimiento de la z es un caso muy especial, aunque ahora est  un poco
;reducido respecto a la original rutina de estrellas que ordenaba por Z...
;aunque aquella era en Tweaked... 8)

move2       macro despl1,despl2,maximo,minimo
            LOCAL no_mayor,no_menor,no_inicial,no_inicial2
            mov ax,[di+despl1]
            add ax,[despl2]
            cmp ax,maximo
            jnge no_mayor
            sub ax,maximo-minimo
no_mayor:   cmp ax,minimo
            jnl no_menor
            add ax,maximo-minimo
no_menor:   mov [di+despl1],ax
            ENDM

;trunca las coordenadas reales de la pantalla en este caso...

trunca      macro centro
            LOCAL no_trunca,no_trunca_2
            cmp ax,centro+80-1
            jle no_trunca
            mov si,[di+6]
            mov byte ptr es:[si],0
            xor bx,bx
            jmp Erase0
no_trunca:
            cmp ax,centro-80
            jnle no_trunca_2
            mov si,[di+6]
            mov byte ptr es:[si],0
            xor bx,bx
            jmp Erase0
no_trunca_2:
            ENDM

;trunca la coordenada Y....

trunca2     macro centro
            LOCAL no_trunca,no_trunca_2
            cmp ax,centro+48-1
            jle no_trunca
            xor bx,bx
            mov si,[di+6]
            mov byte ptr es:[si],0
            jmp Erase0
no_trunca:
            cmp ax,centro-48
            jnle no_trunca_2
            xor bx,bx
            mov si,[di+6]
            mov byte ptr es:[si],0
            jmp Erase0
no_trunca_2:
            ENDM

;programa principal de las estrellas...

estrellas   proc

            ;segmento de video

            mov ax,0a000h
            mov es,ax

            mov di,OFFSET stars
            mov cx,[numstars]

            ;aqu¡ se produce el desplazamiento tridimensional de las estrellas
            ;en el campo definido en las constantes...

stars10:    Move 0,speedx,maxXpos,minXpos
            Move 2,speedy,maxYpos,minYpos
            Move2 4,speedz,maxZpos,minZpos
            add di,8
            loop stars10

            ;ahora, una vez desplazadas las estrellas, nos dispones a proyectarlas
            ;en la pantalla...

            mov di,OFFSET stars
            mov cx,[numstars]
stars11:    push cx

            ;lo primero que hacemos para la transformaci¢n es dividir por la
            ;Z...
            mov cx,[di+4]            ;la coordenada z en cx
            mov ax,[di]
            movsx dx,ah              ;ESTA es la instruccion que me ha obligado
                                     ;a usar c¢digo para 386...
            shl ax,8
            idiv cx                  ;en ax tenemos la X real
            add ax,CentroX
            Trunca CentroX
            mov bx,ax                ;ahora la x est  en bx
            mov ax,[di+2]
            movsx dx,ah
            shl ax,8
            idiv cx                  ;divide por la Z
            add ax,CentroY           ;s£male el centro
            Trunca2 CentroY          ;trunca por el clipping
            xchg bx,ax               ;BX=Y  AX=X
            shr cx,9                 ;ahora averigua el color...
            mov ch,cl
            add ch,Color
            push ax
            mov ax,320               ;cada fila -> 320 bytes...
            mul bx
            pop bx
            add bx,ax                ;posici¢n a donde poner la estrella
            mov si,[di+6]
            mov byte ptr es:[si],0   ;borra antes la estrella anterior
            mov es:[bx],ch           ;pon la nueva estrella
erase0:     mov [di+6],bx            ;guarda la estrella que se borrar  en el
            add di,8                 ;siguiente retrazo...
            pop cx
            loop stars11             ;y as¡ todas las estrellas...
            ret

estrellas   endp

;**************************************************************************
; Pon un tile en la posici¢n requerida...
;
; NOTA: ES exactamente lo que parece: o sea, una animaci¢n por COLORES...
;
;**************************************************************************

tileput proc

        mov     cx,8            ;8 lineas...
        mov     dx,3c8h         ;puerto de direcciones del DAC para escritura
        out     dx,al           ;color de inicio
        inc     dx              ;ahora el puerto de datos
next_row:
        push    cx
        mov     cx,8*3          ;n£mero de colores a escribir, 8 cada vez...
next_pixel:
        mov     al,[si]
        out     dx,al           ;escribe el dato...
        inc     si              ;busca siguiente dato
        loop    next_pixel
        pop     cx
        add     si,8*3          ;siguiente posici¢n en el tile...
        loop    next_row
        ret

tileput endp

;**************************************************************************
; Un Vsync de lo m s normal...
;**************************************************************************

;no merece comentarios...

Vsync   proc

        mov     dx,03dah
esp1:   in      al,dx
        test    al,8
        jnz     esp1
esp2:   in      al,dx
        test    al,8
        jz      esp2
        ret

Vsync   endp

;**************************************************************************
; Rellena el trozo deseado con el tile oportuno...
;**************************************************************************

;dibuja una sola linea de tiles....

do      proc

shut1:  push cx
        push di
        push si
        mov bx,si               ;inicio del ciclo
        mov cx,dx
shut2:  push cx
        mov es:[di],bl          ;pon uno por uno todos los0
        inc bl                  ;colores...
        mov es:[di+1],bl
        inc bl
        mov es:[di+2],bl
        inc bl
        mov es:[di+3],bl
        inc bl
        mov es:[di+4],bl
        inc bl
        mov es:[di+5],bl
        inc bl
        mov es:[di+6],bl
        inc bl
        mov es:[di+7],bl
        inc bl
        add di,320              ;siguiente linea
        pop cx
        loop shut2
        pop si
        pop di
        pop cx
        add di,8                ;siguiente tile en la linea
        dec cx
        jnz shut1
        ret

do      endp


;ahora vas poniendo un tile, a partir del color indicado en SI, en la posici¢n
;requerida...

rellena proc

        ;es:di es el destino...
        ;el ciclo comienza con si...

        mov ax,0a000h
        mov es,ax               ;buffer de video
shut0:  push cx
        push di
        push si
        mov cx,20               ;20 tiles por linea
        mov dx,8                ;8 lineas por tile
        call do                 ;dibuja un tile
        pop si
        pop di
        pop cx
        add di,2560             ;siguiente linea0
        dec cx                  ;ya queda una linea menos...
        jnz shut0
        ret

rellena endp

;*****************************************************************************
; Esta es la interrupci¢n del teclado...
;*****************************************************************************

int09   proc

        push    ax bx

        in al,60h       ; lee la tecla

        ;haz un strobe del teclado...

        mov bh,al
        in al,61h
        mov ah,al       ;el strobe consiste en poner a uno y despu‚s a zero
        or al,80h       ;el bit de m s peso del registro de control del
        out 61h,al      ;controlador del teclado
        xchg ah,al
        out 61h,al

        ;comprueba si es un escape...

        dec     bh
        jnz     skip    ;si no hay escape no hagas nada...

        mov     byte ptr cs:[Escape],1  ;si hay escape ind¡calo...
skip:

        ;EOI

        mov     al,20h
        out     20h,al

        pop     bx ax

        iret          ;vuelve a donde estaba...

        oldint09        dd      0

int09   endp

;*****************************************************************************
; Esta es la interrupci¢n 08 del timer 0...
;*****************************************************************************

int08   proc

        push    ax


        mov     al,20h  ;la verdad es que es una interrupci¢n bastante
        out     20h,al  ;complicada... 8)

        pop     ax

        iret

        oldint08        dd      0

int08   endp

;*****************************************************************************
; Esta es la llamada al driver de m£sica...
;*****************************************************************************

MusicDriver     proc

MusicPatch      label
        nop
        call    dword ptr cs:[Player]   ;llama al driver de m£sica...
        ret

Player  DW      0,0

MusicDriver     endp

;*****************************************************************************
; C¢digo principal!
;*****************************************************************************

;esta es la rutina principal del programa...

main    proc far

        mov ax,data
        mov ds,ax                       ;el segmento de datos


        ;esta es la rutina de detecci¢n del micro 386...

        pushf
        xor ah,ah
        push ax
        popf
        pushf
        pop ax
        and ah,0f0h
        cmp ah,0f0h
        je detectno386
        popf
        jmp si_386
detectno386:

        ;no se ha detectado un 386...
        popf
        mov dx,OFFSET error             ;pon el mensaje de error
        mov ah,9
        int 21h
        mov ah,04ch                     ;vuelve al DOS...
        int 21h
si_386:

        mov     ax, data                ;segmento del driver de m£sica...
        mov     cs:Player[2], ax

        push    ds

        push    cs
        pop     ds

        mov     ah, 6                   ;inicializa el driver de m£sica...
        call    MusicDriver

        jnc     InitializedOk           ;se ha encontrado la tarjeta de sonido

        ;si no se inicializ¢ bien la m£sica pon un RET para que las pr¢ximas
        ;llamadas al driver vuelvan sin hacer nada...

        mov     byte ptr cs:[MusicPatch], 0C3h

InitializedOk:
        ;Inicializa la m£sica...
        mov     ah, 0                           ;funci¢n 0: inicializa m£sica
        mov     bx, data                        ;segmento de la m£sica
        mov     cx, MusicOffset                 ;offset de la m£sica
        call    MusicDriver

        mov     ah, 2
        mov     bx, 0                           ;esto sirve para algo...
        call    MusicDriver                     ;pero no s‚ para que...

        pop     ds

;*****************************************************************************
; Pon la velocidad apropiada...
;*****************************************************************************

        cli

        ;Salva la anterior interrupci¢n...

        xor     ax,ax
        mov     es,ax
        mov     di,8*4                  ;cambia los vectores de interrupci¢n
        mov     bx,es:[di]              ;de la IRQ 0 y la IRQ 1, salv ndolos
        mov     si,es:[di+2]            ;previamente en variables de apoyo...0
        mov     word ptr cs:[oldint08],bx
        mov     word ptr cs:[oldint08+2],si
        mov     bx,es:[di+4]
        mov     si,es:[di+6]
        mov     word ptr cs:[oldint09],bx
        mov     word ptr cs:[oldint09+2],si

        ;pon la nueva interrupci¢n...

        mov     di,8*4
        mov     word ptr es:[di],OFFSET int08   ;pon las nuevas rutinas de
        mov     word ptr es:[di+2],SEG int08    ;interrupci¢n en los
        mov     word ptr es:[di+4],OFFSET int09 ;vectores...
        mov     word ptr es:[di+6],SEG int09

        in      al,21h
        mov     cs:[IMR],al                     ;deja s¢lo activadas las
        or      al,011111111b                   ;lineas de la IRQ0 y la
        and     al,011111100b                   ;IRQ 1....
        out     21h,al

        sti

        ;pon las imagenes en pantalla...


        mov     ax,013h                         ;pon el modo gr fico 320x200
        int     10h                             ;x256 colores normal...

        mov     dx,3c8h
        xor     al,al
        out     dx,al
        inc     dx
        mov     cx,768                          ;borra los 768 colores del
next:   out     dx,al                           ;DAC mientras escribimos en
        loop    next                            ;la pantalla...

        mov     ax,0a000h                       ;segmento de video
        mov     es,ax
        mov     di,160
        mov     si,OFFSET PLASMA+768            ;dibujo del plasma
        mov     cx,48                           ;son 48 lineas...
siguiente:
        push    cx
        mov     cx,160                          ;160 bytes por linea...
        cld
        rep     movsb                           ;coloca una linea
        sub     si,160                          ;duplica la siguiente linea
        mov     cx,160
        add     di,160                          ;siguiente posici¢n en el buffer
        rep     movsb                           ;y coloca otra linea igual...
        pop     cx
        add     di,160                          ;siguiente posici¢n en el buffer
        loop    siguiente

        mov     di,320*41+195                   ;posici¢n centrada del logo...
        mov     si,OFFSET logo                  ;ahora pon el logo en pantalla
        mov     cx,16                           ;son 16 lineas de logo
ll1:    push    cx
        push    di
        mov     cx,90
ll2:    mov     al,[si]
        test    al,0ffh                         ;solo se escriben aquello bytes
        jz      skip_logo                       ;que son diferentes de 0, o sea
        mov     es:[di],al                      ;que no son de fondo...
skip_logo:
        inc     di
        inc     si
        loop    ll2                             ;siguiente pixel0
        pop     di
        pop     cx
        add     di,320                          ;siguiente linea
        loop    ll1

        ;pon los patrones para los tiles...

        mov     di,32000+320*4
        mov     si,16
        mov     cx,12                   ;pon el dibujo necesario para que el
        call    rellena                 ;primer tile sea f cil de mover...

        xor     di,di
        mov     si,256-64
        mov     cx,12                   ;pon el dibujo necesario para que el
        call    rellena                 ;segundo tile sea f cil de mover...

        mov     si,OFFSET TILE2
        add     al,256-64               ;pon la paleta del segundo tile...
        call    tileput

        mov     si,OFFSET TILE1
        mov     al,16                   ;pon la paleta del primer tile...
        call    tileput

        ;Bucle principal...

        mov     dx,3c8h                 ;coloca la paleta de colores en
        xor     al,al                   ;los registros del DAC de video...
        out     dx,al
        inc     dx
        mov     si,OFFSET PLASMA
        mov     cx,768                  ;son 256 colores *3
paleta: mov     al,[si]
        inc     si
        out     dx,al                   ;escr¡belos...
        loop    paleta

keywait:
        ;espera el retrazo vertical...

        call    Vsync           ;espera el retrazo vertical...


        ;movimiento del primer tile...

        mov     bl,cs:[sincro]
        and     bx,0ffh
        mov     al,[bx+OFFSET SINUS]
        mov     cl,[bx+OFFSET SINUS+64]
        and     ax,0111b
        mov     bx,8*2*3
        mul     bx
        mov     si,OFFSET TILE2
        add     si,ax
        and     cx,0111b
        mov     ax,3
        mul     cx
        add     si,ax
        mov     al,256-64
        call    tileput

        call    scroll                  ;scroll de texto...

        ;movimiento del segundo tile...

        mov     bl,cs:[sincro]
        and     bx,07fh
        mov     al,[bx+OFFSET SINUS]
        and     ax,0111b
        mov     bx,8*2*3
        mul     bx
        mov     si,OFFSET TILE1
        add     si,ax
        mov     al,16
        call    tileput

        ;c culo de las velocidades relativas de las estrellas...

        mov     bl,cs:[sincro2]
        and     bx,0ffh
        mov     al,[bx+OFFSET SINUS]
        cbw
        sar     ax,2
        mov     [speedx],ax
        mov     al,[bx+OFFSET SINUS+64]
        cbw
        sar     ax,2
        mov     [speedy],ax
        mov     al,[bx+OFFSET SINUS+128]
        cbw
        sar     ax,2
        mov     [speedz],ax


        inc     byte ptr cs:[sincro]
        mov     al,cs:[sincro]
        and     al,01h                  ;esto nos sirve para calcular la
        jz      par                     ;frecuencia de llamada del ciclo de
                                        ;paleta...

        ;ciclo de colores 1...

        cmp     word ptr cs:[cicle],108*3
        jne     no_restaura
        mov     word ptr cs:[cicle],0
no_restaura:
        mov     dx,3c8h
        mov     al,84                   ;esta parte se encarga del ciclo de
        out     dx,al                   ;colores del plasma...
        inc     dx
        mov     si,OFFSET PLASMA+84*3
        add     si,cs:[cicle]
        mov     cx,107*3
otra_vez:
        cmp     si,OFFSET PLASMA+192*3
        jne     siga
        mov     si,OFFSET PLASMA+84*3
siga:   mov     al,[si]
        inc     si
        out     dx,al
        loop    otra_vez

        add     word ptr cs:[cicle],3   ;mueve la paleta...

par:
        mov     al,cs:[sincro]
        and     al,0111b
        jnz     sigue                   ;calcula la velocidad de los tiles...

        inc     byte ptr cs:[sincro2]   ;para la sincronizaci¢n de los tiles...

sigue:
        ;actualiza la m£sica...

        mov     ah, 3
        call    MusicDriver             ;llama a la rutina de m£sica...

        call    estrellas               ;llama a la rutina de estrellas...

        ;mira si se ha pulsado escape...

        test    byte ptr cs:[Escape],0ffh
        jz      keywait

        ;Restaura la interrupci¢n anterior...

        cli                             ;fuera interrupciones...
        xor     ax,ax
        mov     es,ax
        mov     di,8*4                  ;posici¢n de la IRQ 0
        mov     si,OFFSET oldint08
        mov     ax,cs:[si]              ;lee el vector original...
        mov     es:[di],ax
        mov     ax,cs:[si+2]
        mov     es:[di+2],ax            ;coloca el vector original...
        mov     si,OFFSET oldint09
        mov     ax,cs:[si]              ;ahora igual para la IRQ 1
        mov     es:[di+4],ax
        mov     ax,cs:[si+2]
        mov     es:[di+6],ax

        mov     al,cs:[IMR]             ;restaura la m scara del PIC i8259
        out     21h,al

        sti                             ;permite interrupciones otra vez...

        ;apaga la m£sica...

        mov     ah, 2
        mov     bx, 0
        call    MusicDriver             ;apaga la m£sica...

        ;vuelve al DOS...

        mov     ax,03h
        int     10h                     ;vuelve al modo de texto...

        mov     ah,9                    ;escribe el mensaje final con los
        mov     dx,OFFSET mensaje       ;greetings y los creditos...
        int     21h

        mov     ax,04c00h               ;vuelve al DOS
        int     21h
main    endp


code ends
end main


