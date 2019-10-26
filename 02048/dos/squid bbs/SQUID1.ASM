
;----------------------------------------------------------------------------;
;                                                                            ;
;  Notes to foreign readers:                                                 ;
;                                                                            ;
;                                                                            ;
;  []  This code is highly optimized for size - and that means some strange  ;
;      register operations and other unusual techniques.  It's the price of  ;
;      extraordinary compact code.                                           ;
;                                                                            ;
;  []  The comments in the source below are in Portuguese. Sorry about this  ;
;      -  It was primarily intended to distribute this file only in Brazil.  ;
;      If you have questions, send e-mail to cld%12.1241.1@rbt.anrs.br. The  ;
;      basics are: VGA internal 8x16 font is copied into 256 byte/char bufr  ;
;      (two bytes per pixel (char/attr)), then some characters ('A' to 'Z')  ;
;      are reprogrammed, and the set is smoothed.  The screen background is  ;
;      always color 0, but the pallete is reprogrammed for  each horizontal  ;
;      scan line. Scroller updates the rightmost column of screen and  uses  ;
;      standard 'rep movsw' data transfer to scroll.                         ;
;                                                                            ;
;  []  The Adlib programming info was obtained from "Programming the AdLib/  ;
;      Sound Blaster FM Music Chips", Version 2.0 (24 Feb 1992)  by Jeffrey  ;
;      S. Lee (jlee@smylex.uucp).                                            ;
;                                                                            ;
;  []  You need a fast machine to run this - results on slow machines like   ;
;      a 25MHz 386SX are unpredictable. This code was developed on a 40MHz   ;
;      486DX with Stealth 24 VLB, and runs perfectly on a 40MHz 386DX with   ;
;      Trident 8900CL.                                                       ;
;                                                                            ;
;  []  This code is freeware, and you are free to use it as you want - but   ;
;      DO NOT make another small addy just changing the text and few bytes   ;
;      of code! If you use any portion of this code in your programs (e.g.   ;
;      the Adlib mini-player)  remember  to give the proper credits to the   ;
;      authors. Greets will be appreciated.                                  ;
;                                                                            ;
;  []  Life is nice! Don't be a lamer! :-)                                   ;
;                                                                            ;
;                                                                            ;
;                                  cld.DOC                                   ;
;                                                                            ;
;----------------------------------------------------------------------------;


;----------------------------------------------------------------------------;
;                                                                            ;
;  SQUID1.ASM  by cld & The Doctor                              31-Jan-1994  ;
;                                                                            ;
;----------------------------------------------------------------------------;
;                                                                            ;
;  Este ‚ o fonte comentado do SQUID1.COM para que que voce tenha uma id‚ia  ;
;  de como foi feito. No programa h  um conjunto de 26 caracteres 8x16 e um  ;
;  pequeno tocador para musicas em Adlib. Voce pode remove-los e us -los em  ;
;  seus programas - mas nao se esque‡a de creditar os autores. *Usar c¢digo  ;
;  alheio como se fosse seu pode ser f cil e c“modo, mas acaba trazendo  m   ;
;  fama para quem se arriscar. Lembre-se disso!*                             ;
;                                                                            ;
;  Pedimos tamb‚m que voce N A O fa‡a outro an£ncio de BBS ou pequeno intro  ;
;  apenas trocando o texto e alguns poucos bytes. Use sua imaginacao e crie  ;
;  algo diferente.                                                           ;
;                                                                            ;
;  O c¢digo foi escrito e testado em 486DX 40MHz com placa de video Diamond  ;
;  Stealth 24 VLB, usando TASM.  Maquinas muito lentas terao problemas para  ;
;  rod -lo, devido ao sincronismo com o retra‡o de v¡deo.  Algumas t‚cnicas  ;
;  pouco usuais sao empregadas para otimiza‡ao em tamanho. Eu considero que  ;
;  um 386DX 33MHz e uma placa de video Trident devam ser suficientes. Um SX  ;
;  33 MHz ‚ insuficiente para a tarefa. VGAs lentas causam flicker.          ;
;                                                                            ;
;  Para assemblar/linkar, use:    tasm squid1 /m5     tlink squid1 /t        ;
;                                                                            ;
;  O .COM resultante deve ter 1899 bytes - nada mal para um addy com fontes  ;
;  redefinidos, gr ficos VGA, scrollers, sinusbars e m£sica, hein? :-))      ;
;                                                                            ;
;  Agradecimentos a Jeffrey S. Lee (jlee@smylex.uucp) por informa‡oes sobre  ;
;  a programa‡ao de Adlib e a Ed Vicious pela rotina de detec‡ao de 386.     ;
;                                                                            ;
;----------------------------------------------------------------------------;


TRACKS  EQU     7                       ; numero de trilhas para musica


code    SEGMENT PARA PUBLIC 'code'
        ASSUME cs:code, ds:code, es:code, ss:code
        LOCALS
        .8086

        ORG     100h                    ; Queremos um .COM, o menor possivel

start:  cld                             ; Sou eu!
        cli
        mov     ax,3                    ; Modo de video 3 (texto 80x25)
        int     10h

;----------------------------------------------------------------------------;
;  Verifica presen‡a de VGA e 386, reseta Adlib                              ;
;----------------------------------------------------------------------------;

        mov     ax,1a00h                ; Verifica VGA
        int     10h
        cmp     al,1ah                  ; Retorna 1ah se suportada
        jne     giveup                  ; Funcao nao suportada
        cmp     bl,7                    ; Codigo do display ativo
        jb      giveup                  ; MDA, CGA, EGA, PGA, etc.

        xor     ax,ax                   ; Testa pra saber se ‚ 386
        push    ax                      ; -- C¢digo fornecido por Ed Vicious
        popf                            ;
        pushf                           ; Faz uma embrulhada com os
        pop     ax                      ; flags...
        and     ax,0f000h               ;
        cmp     ax,0f000h               ;
        je      giveup                  ; 8086 detectado, cai fora
        mov     ah,0f0h                 ;
        push    ax                      ; Outra salada com pushes e pops...
        popf                            ;
        pushf                           ;
        pop     ax                      ;
        and     ax,0f000h               ; (zera al)
        jne     _386                    ;
giveup: jmp     _286                    ; 286 nao serve

_386:
        .386                            ; Se passou pelos testes, ‚ 386


;----------------------------------------------------------------------------;
;  Inicializa‡oes                                                            ;
;----------------------------------------------------------------------------;

        mov     di,OFFSET finetune+2    ; Inicializa vari veis e tabelas
        mov     cx,6*TRACKS+2*19636     ; em zero
        repz    stosb                   ; sai com ax==cx==0

        call    reset                   ; Reseta Adlib, sai com cx==0;

        mov     fs,cx                   ; fs aponta pra tabela de vetores
        mov     ax,1124h                ; Seta int 43h para fonte 8x16
        int     10h

        mov     si,OFFSET base          ; Inicializa‡ao das trilhas
        mov     di,OFFSET track
        mov     cx,TRACKS
        repz    movsw                   ; Sai com ax==cx==0

        push    ds
        mov     di,10ch                 ; Offset para int 43h
        lds     si,DWORD PTR fs:[di]    ; ds:si aponta para o fonte 8x16

        mov     ch,4                    ; Copia fonte 8x16 pro buffer
        mov     di,OFFSET fontbuffer    ; (cl vale zero)
        push    di
        repz    movsw                   ; cx vale zero na saida

        pop     di                      ; di cont‚m offset de fontbuffer
        pop     ds                      ; ds cont‚m segmento dos dados
        push    di
        push    di                      ; Reserva para setar o fonte da VGA
        add     di,'A'*16               ; Copia a tabela de caracteres
        mov     si,OFFSET fonte
        mov     cl,23                   ; 23 caracteres redefinidos
copy:   push    cx
        xor     ax,ax                   ; Preenche os dois zeros iniciais
        stosw                           ; e o zero final da tabela de
        mov     cl,13                   ; caracteres.
        repz    movsb
        stosb
        pop     cx
        loop    copy                    ; Proximo caracter


; --- Reprograma os caracteres para suavizamento

setchar PROC    NEAR
        mov     di,OFFSET fontbuffer+0c0h*16
        mov     bp,di
        inc     ax                      ; Prepara as quatro "rampas"
        mov     bx,8000h                ; Bitmasks ax=00000001 bx=10000000
        mov     cl,32
        mov     dx,cx
@@doit: or      [di],ah                 ; Os endere‡os estao previamente
        or      [di+64],al              ; zerados. O preenchimento ‚
        or      [di+32],bh              ; feito por colunas.
        or      [di+96],bl
        inc     di
        loop    @@doit                  ; Proxima linha
        shl     ax,1                    ; Atualiza bitmasks e ponteiros
        shr     bx,1
        inc     bp
        mov     di,bp
        dec     dx
        dec     dx
        mov     cl,dl
        or      cl,cl
        jnz     @@doit                  ; Proxima coluna

        dec     ax                      ; Faz as "bandeirinhas"
        mov     cl,8
        mov     di,OFFSET fontbuffer + 0c8h*16
        mov     si,OFFSET fontbuffer + 0c8h*16+15
@@r5:   stosb
        mov     [si],al
        dec     si
        shr     al,1
        loop    @@r5

        dec     ax
        mov     cl,8
        mov     di,OFFSET fontbuffer + 0c9h*16
        mov     si,OFFSET fontbuffer + 0c9h*16+15
@@r6:   stosb
        mov     [si],al
        dec     si
        shl     al,1
        loop    @@r6                    ; sai com cx==0 e al==0
setchar ENDP

        mov     ah,11h                  ; Reprograma fonte (al==0)
        mov     bx,1000h                ; 16 bytes/caracter - bloco 0
        mov     cl,0cfh                 ; # de caracteres a reprogramar
        xor     dx,dx                   ; comecando do 0
        pop     bp                      ; Tabela do novo fonte
        int     10h

xtend   PROC    NEAR
        pop     si                      ; si cont‚m offset de fontbuffer
        mov     di,OFFSET extended
        mov     cl,127                  ; 127 caracteres
@@xt:   push    cx
        mov     bl,80h
        mov     cl,8                    ; 8 colunas por caracter
@@each: push    cx                      ; Loop para cada caracter
        mov     cl,16                   ; 16 linhas por caracter
@@col:  lodsb                           ; Loop para cada coluna
        test    al,bl
        jz      @@blank
        mov     WORD PTR [di],0110h     ; Bloco e atributo **
@@blank:inc     di                      ;
        inc     di
        loop    @@col                   ; Proxima linha
        sub     si,16                   ; Retorna ao in¡cio do caracter
        shr     bl,1                    ; Incrementa coluna
        pop     cx
        loop    @@each                  ; Proxima coluna
        add     si,16                   ; Avan‡a um caracter
        pop     cx
        loop    @@xt
xtend   ENDP


smooth  PROC    NEAR
        mov     si,OFFSET extended+ '/'*16*16
        mov     cx,16*8*('z'-'/'+1)
@@each: cmp     BYTE PTR [si],10h       ; Uma rotina de AI que d  um
        jne     @@next                  ; tratamento especial nos
        xor     ax,ax                   ; caracteres ampliados.
        mov     bx,0ffdeh               ; Funciona muito bem, e sua
        mov     dx,0ffc0h               ; demonstra‡ao ‚ not vel -
        mov     bp,0004h                ; mas esta margem ‚ pequena
@@getx: mov     al,[si+bx]              ; demais para conte-la!
        add     al,0f0h
        rcl     ah,1                    ; Obs: tentar entender como
        xor     bx,dx                   ; isto funciona pode ser
        xor     dx,0fffch               ; perigoso para sua sa£de :-))
        dec     bp
        jnz     @@getx
        mov     bx,20h                  ;
        mov     al,0f9h                 ;            XXXXXX
@@again:                                ;           XX    XX
        mov     dx,ax                   ;           XX
        xor     dh,dl                   ;            XXXXXX
        mov     dl,dh                   ;                 XX
        and     dl,0ah                  ;           XX    XX
        shr     dl,1                    ;            XXXXXX
        and     dl,dh                   ;
                                        ;
        jz      @@skip                  ;             vira
        cmp     BYTE PTR [si+bx],010h   ;
        je      @@skip                  ;           /XXXXXX\
                                        ;           XX/  \XX
        mov     dh,dl                   ;           XX\
        and     dh,04h                  ;           \XXXXXX\
        and     dl,01h                  ;                \XX
        cmp     al,10h                  ;           XX\  /XX
        rcl     dl,1                    ;           \XXXXXX/
        or      dl,dh                   ;
        add     [si+bx],dl              ;      Tricky code, eh? :-)
        mov     BYTE PTR [si+bx+1],1
@@skip: cmp     al,06h
        jz      @@next                  ; Obs: O codigo ao lado pode ser
        not     al                      ; dif¡cil de entender, mas foi
        neg     bx                      ; uma grande sacada do Doctor.
        jmp     SHORT @@again           ; Meus aplausos a ele - excelente
@@next: inc     si                      ; efeito!
        inc     si
        loop    @@each
smooth  ENDP


;  Patches para '1' e '4' - suavizamento acima nao os reconhece :-((
;  Espero que todas as VGAs tenham o mesmo formato para os dois caracteres.

        mov     ax,0103h
        mov     WORD PTR [extended+'4'*32*8+16*4+6],ax
        mov     WORD PTR [extended+'4'*32*8+16*4+36],ax
        mov     WORD PTR [extended+'1'*32*8+16*2+6],ax
        mov     WORD PTR [extended+'1'*32*8+16*2+36],ax

; --- Inicializa‡ao da Adlib

        mov     ax,0120h                ; Habilita bit 5 do reg 1 da Adlib
        call    addata                  ; (Waveforms)

        mov     cl,6                    ; 6 instrumentos a programar
        xor     bx,bx                   ; iniciando no canal 1
        mov     si,OFFSET instruments   ; a partir do 1o instrumento
        call    set_instr

        inc     cx                      ; Chorus para o canal 4
        mov     si,OFFSET brass
        call    set_instr

; --- Inicializa‡ao de tela

        push    0b800h                  ; es contem o segmento de video,
        pop     es                      ; modo texto

        xor     di,di                   ; Esconde o cursor
        mov     ax,di                   ; Este m‚todo economiza bytes
        stosw                           ; se comparado a desabilit -lo

        mov     bp,OFFSET scroller+49   ; bp aponta pra texto do scroller

        mov     si,OFFSET scroller      ; Coloca mensagem
        mov     di,20*160+34            ; Coordenadas em y*160+x
        mov     bh,11                   ; Cor: light cyan
        call    write
        mov     si,OFFSET credits
        mov     di,21*160+30
        mov     bh,3                    ; Cor: cyan
        call    write

;----------------------------------------------------------------------------;
;  Loop Principal                                                            ;
;----------------------------------------------------------------------------;

mainloop:

vwait   PROC    NEAR
        mov     dx,3dah                 ; Espera o retra‡o vertical
@@vw1:  in      al,dx                   ; (o timing ‚ realizado atrav‚s da
        and     al,08h                  ; espera de retraco. Se o micro
        jnz     @@vw1                   ; for suficientemente lento para
@@vw2:  in      al,dx                   ; nao poder fazer os calculos entre
        and     al,08h                  ; dois retra‡os, haver  perda de
        jz      @@vw2                   ; sincronismo)
vwait   ENDP

        mov     si,OFFSET pal_table
        mov     cx,290                  ; Contador de linhas

doscreen:                               ; Loop realizado para as primeiras
                                        ; 290 linhas da tela
hwait   PROC    NEAR
        mov     dl,0dah                 ; Espera retra‡o horizontal
@@hw1:  in      al,dx                   ; (a palette ‚ setada para cada
        and     al,01                   ; linha da tela)
        jnz     @@hw1
@@hw2:  in      al,dx
        and     al,01
        jz      @@hw2
hwait   ENDP

        mov     dl,0c8h                 ; Reprograma a palette, cor 0
        outsw                           ; (dh==3)
        inc     dx
        outsb
        outsb
        dec     dx                      ; Reprograma a palette, cor 1
        outsw
        inc     dx
        outsb
        outsb

        loop    doscreen                ; Sai com cx==0 e dh==3

; --- Desloca 16 linhas da tela um caracter para a esquerda

scroll  PROC    NEAR
        mov     cl,13                   ; Scrollar 14 linhas (ch==0)
        mov     si,484                  ; Offset da fonte
        mov     di,482                  ; Offset do destino
        push    ds
        push    es
        pop     ds                      ; Faz ds apontar pra tela
@@doit: push    cx
        mov     cl,77                   ; Deslocar 77 colunas
        repz    movsw
        add     si,6
        add     di,6
        pop     cx
        loop    @@doit                  ; Proxima linha
        pop     ds
scroll  ENDP

; --- Atualiza scroller

updscr  PROC    NEAR
        xor     dx,dx
@@next: mov     bx,[scroll_index]       ; Coluna da vez
        inc     [scroll_index]          ; Proxima coluna

        test    bl,10h
        jz      @@cont
                                        ; Proxima letra
        test    BYTE PTR [bp],80h       ; Teste de 7bit coloque um espaco
        js      @@goin

        test    bl,01h                  ; Repete o ultimo pixel...
        jz      @@goin

        mov     [scroll_index],dx
@@goin: mov     al,' '                  ; Espa‡o entre caracteres
        jmp     SHORT @@cont2
@@cont: mov     cl,bl
        and     cl,0fh
        jnz     @@skip
        inc     bp                      ; Proximo caracter
@@skip: shr     cl,1
        mov     si,bp                   ; bp cont‚m o ponteiro para a msg
        lodsb
        and     al,7fh
        cmp     al,07fh                 ; Ve se acabou a string
        jne     @@cont2
        mov     bp,OFFSET scroller-1    ; Reseta pointer
        mov     [scroll_index],dx       ; Zera ¡ndice
        jmp     SHORT @@next
@@cont2:mov     si,OFFSET extended
        shl     ax,8                    ; 16X16 caracter+atributo
        mov     dl,cl
        shl     dx,5
        add     ax,dx
        add     si,ax                   ; Offset na tabela
        mov     di,316                  ; Offset de v¡deo
        mov     cx,15
        mov     dl,bl
        mov     bx,OFFSET sm_table-2
@@main: lodsw                           ; Coloca caracter na tela
        test    dl,1
        jz      @@else
        add     al,8
@@else: xlat
        stosw
        add     di,158                  ; Proxima linha
        loop    @@main                  ; (Sai com cx==0)
updscr  ENDP

; --- Tabela de palette para cores 0 e 1

initr   PROC    NEAR
        mov     si,OFFSET pal_table
        mov     cx,290                  ; Numero de linhas

@@fill: xor     dx,dx
        mov     ax,cx                   ; ax cont‚m a cor
        shr     ax,3
        mov     ah,al
        mov     WORD PTR [si],dx        ; Cor 0 (degradee cyan -> preto), R
        mov     [si+2],ax               ; G,B
_init_  LABEL   WORD                    ; inc dx -> jmp SHORT @@go
        inc     dx
        not     ax
        mov     WORD PTR [si+4],dx      ; Cor 1 (degradee preto -> cyan), R
        mov     [si+6],ax               ; G,B

@@go:   add     si,8
        loop    @@fill
        mov     [_init_],07ebh          ; patch de inicializa‡ao ;-)
initr   ENDP

; --- Monta as sinusbars

sinbar  PROC    NEAR
        mov     cl,4                    ; Numero de barras (ch==0)
@@go:   mov     bx,cx
        push    cx
        shl     bx,3
        mov     al,[angle]              ; Coleta angulo atual
        sub     al,bl

; --- Coleta seno do angulo

        xor     dl,dl                   ; Inicializa dl
        mov     bx,OFFSET sintable
        test    al,80h                  ; Verifica se quadrante 3 ou 4
        jz      q12
        dec     dx                      ; 3 ou 4, faz dl=0ffh
        and     al,7fh                  ; Reduz para 1 ou 2
q12:    cmp     al,40h                  ; Verifica se quadrante 1 ou 2
        jbe     q1
        neg     ax                      ; Redu‡ao ao 1o quadrante
        and     al,3fh
q1:     xlat                            ; Coleta seno do angulo
        xor     al,dl                   ; not ax se dl==0ffh

; --- Seno coletado em al

        cbw
        add     ax,137                  ; Varia‡ao: 10 a 264
        shl     ax,3                    ; Cada entrada tem 8 bytes
        mov     si,OFFSET pal_table
        add     si,ax
        mov     cl,24                   ; Espessura da barra
        mov     al,48                   ; Cor para barras
@@bar:  mov     [si+1],al               ; R
        mov     [si+2],al               ; G
        mov     [si+3],al               ; B
        add     si,8                    ; Proxima entrada
        sub     al,2                    ; Cor para degradee
        loop    @@bar
        pop     cx
        loop    @@go                    ; Proxima barra
        inc     [angle]                 ; Incrementa angulo
sinbar  ENDP

; --- Mini-player para Adlib

play    PROC    NEAR
        xor     bx,bx                   ; bx indica o canal atual
        mov     cx,TRACKS
@@next: mov     ax,timer[bx]            ; Coleta o timer para o canal
        or      ax,ax                   ; Verifica se expirou
        jnz     @@next_timer

        xor     dx,dx                   ; Zera transposi‡ao
        or      bx,bx                   ; O canal 1 (bx=0) ‚ reservado
        jnz     @@no_arp3               ; para o arpejador

        mov     si,[a_ptr]              ; dl cont‚m a quantia para
        mov     dl,[si]                 ; transposi‡ao
@@no_arp3:
        push    cx
@@reset_tr:
        mov     si,track[bx]
@@new_val:
        lodsb                           ; Coleta evento da trilha
        or      al,al                   ; Verifica se ‚ nota
        jns     @@volume

        mov     ch,al                   ; Processa nota
        and     ax,000fh
        add     ax,dx                   ; Transposi‡ao do arpejador
        cmp     al,12                   ; Verifica overflow de oitava
        jb      @@skip
        sub     al,12                   ; Ajusta overflow de oitava
        add     ch,10h
@@skip: and     cx,0f000h               ; M scara para envio de valor
        shr     ch,2                    ; para Adlib
        shl     ax,1
        add     ax,OFFSET note2freq     ; Coleta frequencia da tabela
        mov     di,ax
        or      cx,[di]
        add     cl,finetune[bx]         ; Soma afina‡ao (para chorus)
@@pause_t1:
        mov     ax,notelen[bx]          ; Coleta dura‡ao da nota
@@pause_tx:
        mov     timer[bx],ax            ; Atualiza ponteiros
        mov     track[bx],si

        mov     ah,bl
        shr     ah,1
        add     ah,0a0h
        mov     al,cl
        call    addata
        add     ah,10h
        xor     al,al
        call    addata
        mov     al,ch
        call    addata

        pop     cx
@@next_timer:
        dec     timer[bx]               ; Decrementa timer do canal atual
        inc     bx                      ; Incrementa canal
        inc     bx
        loop    @@next                  ; Proximo canal
        jmp     @@end                   ; Encerra (em condi‡oes normais
                                        ; seria um ret)
@@volume:
        jnz     @@no_pause
        xor     cx,cx
        jmp     SHORT @@pause_t1
@@no_pause:
        test    al,40h                  ; Flag que indica se um ctrl.
        jnz     @@ctrl
        mov     di,bx
        shr     di,1
        mov     ah,reg_index[di]
        add     ah,40h                  ; Operador & voz correto
                                        ; Coleta em ah o novo volume
        dec     ax
        call    addata                  ; ah= valor, al= porta
        add     ah,03h                  ; Idem para o operador 2
        lodsb
        dec     ax
        call    addata                  ; ah= valor, al= porta...
        jmp     SHORT @@new_val         ; Coleta novo valor da trilha
@@ctrl:
        and     al,3fh                  ; Processamento de controle
        jnz     @@no_40h
        mov     ax,base[bx]
        mov     track[bx],ax            ; Verifica terminador de trilha

        or      bx,bx                   ; Arpejador na trilha 0
        jnz     @@no_arp

        inc     WORD PTR [a_ptr]        ; Incrementa ptr p/ transposi‡ao
        mov     bx,[a_ptr]              ; Coleta ptr p/ transposi‡ao
@@new_arp:
        mov     dl,[bx]                 ; Transposi‡ao em dl
        cmp     dl,040h                 ; Verifica final de trilha
        jne     @@no_arp2
        mov     bx,OFFSET arpegiator    ; Reseta ponteiro de transposi‡ao **
        mov     [a_ptr],bx
        jmp     SHORT @@new_arp
@@no_arp2:
        xor     bx,bx
@@no_arp:
        jmp     @@reset_tr              ; Coleta novo valor da trilha
@@no_40h:
;       dec     al
;       jnz     @@no_41h                ; Pausa longa (nao utilizado)
;       lodsw
;       xor     cx,cx
;       jmp     @@pause_tx
;@@no_41h:                              ; Livre para uso...
;       dec     al
;       jnz     @@no_42h
;       jmp     @@new_val
@@no_42h:
        sub     al,0fh                  ; CUIDADO COM ESTE VALOR
        shl     al,2                    ;
        mov     BYTE PTR notelen[bx],al ; dh= 10h - numero de efeitos
        jmp     @@new_val               ; ja processados...
@@end:
play    ENDP

; --- Verifica tecla pressionada

        in      al,60h                  ; Coleta scancode
        cmp     al,1                    ; 1 == <ESC>
        jne     mainloop


; --- Retorno ao DOS

getout: mov     ax,3                    ; Modo de v¡deo 3 (limpa a tela)
        int     10h
        call    reset                   ; Reseta Adlib -- sai com ax==0
bye:    sti                             ; Habilita interrup‡oes
        mov     ah,4ch                  ; Retorna ao DOS
        int     21h

; --- Terminador para falhas no teste de VGA/386

_8086:
_286:
novga:  push    0b800h
        pop     es
        mov     si,OFFSET endmsg        ; Coloca mensagem
        xor     di,di                   ; In¡cio da tela
        mov     bh,11                   ; Cor: light cyan
        call    write
        jmp     SHORT bye

;----------------------------------------------------------------------------;
;  Escrita na porta de registrador e dados da Adlib                          ;
;----------------------------------------------------------------------------;

addata  PROC    NEAR                    ; Envia dado (ah) p/ porta Adlib (al)
        pusha
        xchg    al,ah
        mov     dx,388h                 ; Porta de registrador da Adlib
        out     dx,al
        mov     cx,3
@@wait: in      al,dx
        loop    @@wait                  ; Delay para registrador

        inc     dx                      ; Porta de dados da Adlib
        mov     al,ah
        out     dx,al
        mov     cl,16
        dec     dx
@@wait1:in      al,dx                   ; Delay para dados
        loop    @@wait1
        popa
        ret
addata  ENDP

;----------------------------------------------------------------------------;
;  Escreve string na tela. Recebe ponteiro da string em ds:si e o atributo   ;
;  em bh. O offset de v¡deo ‚ recebido em di.                                ;
;----------------------------------------------------------------------------;

write   PROC    NEAR
@@go:   lodsb                           ; Carrega caracter da string
        or      al,al                   ; Verifica se terminou
        jz      @@end
        mov     ah,bh
        test    al,80h                  ; Verifica bit 7
        jz      @@putc                  ; Caracter normal
        and     al,7fh                  ; Desliga bit 7
        stosw                           ; Caracter com espa‡o
        mov     al,' '
@@putc: stosw                           ; Atributo-caracter em ax
        jmp     SHORT @@go
@@end:  ret
write   ENDP


;----------------------------------------------------------------------------;
;  Programa instrumento na Adlib (si= offset, bx= canal)                     ;
;----------------------------------------------------------------------------;

set_instr  PROC
@@letsgo:
        push    cx
        push    bx
        mov     ah,reg_index[bx]
        mov     dl,02
@@again:mov     cx,0004
@@loop1:add     ah,20h
        lodsb
        call    addata
        loop    @@loop1

        add     ah,60h
        lodsb
        call    addata
        sub     ah,0ddh
        dec     dl
        jnz     @@again

        add     bl,0c0h
        mov     ah,bl
        lodsb
        call    addata

        pop     bx
        pop     cx
        inc     bx
        loop    @@letsgo

        ret
set_instr  ENDP

;----------------------------------------------------------------------------;
;  Reseta Adlib                                                              ;
;----------------------------------------------------------------------------;

reset   PROC    NEAR
        mov     cl,0f5h                 ; Reseta Adlib
        xor     ax,ax
@@reset:
        mov     ah,cl
        call    addata
        loop    @@reset                 ; !!IMPORTANTE!! sai com cx==0
        ret
reset   ENDP


; --- String posicionada aqui para aproveitar o 0 da tabela de caracteres

credits         db      'CLD',128+'E',128+'&','KRVA',128+'I'
                db      'B',128+'W','cl',128+'d',128+'-'
                db      'ADJH',128+'B','MJAWE',128+'O','B',128+'W'
                db      'QG',128+'E','DLCQLO'

;----------------------------------------------------------------------------;
;  Caracteres 8x16 (somente 13 bytes sao definidos, para poupar espa‡o)      ;
;  Alguns caracteres sofreram simplifica‡ao devido … rotina de suavizamento  ;
;  de angulos. Os caracteres G, J e X (que nao foram usados no texto) estao  ;
;  em coment rio. O caracter 0 foi redefinido devido a varia‡ao da forma do  ;
;  caracter entre diferentes placas de video. Caracteres como M e W ainda    ;
;  ficaram meio esquisitos.                                                  ;
;----------------------------------------------------------------------------;

fonte LABEL BYTE

 db 000h,07fh,0c0h,0c6h,0c6h,0ffh,0c6h,0c6h,0c6h,0c6h,0c0h,0c0h,080h ; A  A
 db 000h,0fch,046h,066h,066h,07eh,063h,063h,063h,06eh,040h,000h,000h ; B  B
 db 000h,000h,07eh,0c3h,0c3h,0c0h,0c0h,0c0h,0c0h,0ffh,000h,000h,000h ; C  C
 db 000h,0feh,043h,063h,063h,063h,063h,063h,063h,06eh,040h,000h,000h ; D  D
 db 000h,0feh,043h,061h,060h,07ch,060h,060h,060h,07fh,000h,000h,000h ; E  E
 db 000h,0feh,043h,061h,060h,07ch,060h,060h,060h,060h,060h,060h,040h ; F  F
;db 000h,07eh,0c3h,0c3h,0c0h,0c0h,0cfh,0c3h,063h,03fh,003h,003h,001h ; G
 db 0e0h,063h,063h,063h,063h,07fh,063h,063h,063h,063h,003h,003h,001h ; H  G
 db 000h,03ch,018h,018h,018h,018h,018h,018h,018h,03ch,000h,000h,000h ; I  H
;db 000h,07ch,010h,018h,018h,018h,018h,018h,018h,018h,018h,030h,020h ; J
 db 003h,0e3h,063h,063h,066h,07eh,063h,063h,063h,063h,003h,003h,001h ; K  I
 db 000h,0f0h,040h,060h,060h,060h,060h,061h,063h,0ffh,000h,000h,000h ; L  J
 db 001h,0e3h,077h,07fh,06bh,063h,063h,063h,063h,063h,060h,060h,040h ; M  K
;db 080h,0c3h,0e3h,0f3h,0fbh,0dfh,0cfh,0c7h,0c3h,0c1h,080h,000h,000h ; N
 db 000h,000h,07eh,0c3h,0c3h,0c3h,0c3h,0c3h,0c3h,07eh,000h,000h,000h ; O  L
 db 000h,0feh,003h,063h,063h,063h,063h,0feh,060h,060h,060h,040h,000h ; P  M
 db 000h,07fh,0c0h,0c6h,0c6h,0c6h,0c6h,0c6h,0c6h,07fh,006h,006h,002h ; Q  N
 db 000h,0feh,003h,063h,063h,07eh,063h,063h,063h,063h,003h,003h,001h ; R  O
 db 000h,07fh,0c0h,060h,030h,018h,00ch,006h,003h,0feh,000h,000h,000h ; S  P
 db 000h,0ffh,090h,018h,018h,018h,018h,018h,018h,018h,010h,000h,000h ; T  Q
 db 000h,0e3h,063h,063h,063h,063h,063h,063h,063h,03fh,000h,000h,000h ; U  R
 db 0e0h,063h,063h,063h,063h,063h,063h,033h,01bh,00fh,000h,000h,000h ; V  S
 db 0e0h,063h,063h,063h,063h,063h,06bh,07fh,077h,0e3h,001h,000h,000h ; W  T
;db 000h,0c1h,0c3h,066h,03ch,018h,03ch,066h,0c3h,083h,000h,000h,000h ; X
 db 07ch,0c6h,0c6h,0c6h,0d6h,0d6h,0c6h,0c6h,0c6h,07ch,000h,000h,000h ; 0  U
 db 000h,0ffh,0c3h,086h,00ch,018h,030h,060h,0c1h,0c3h,0ffh,000h,000h ; Z  V
 db 0c3h,0c3h,0c3h,0c3h,0c3h,07eh,018h,018h,018h,018h,018h,018h,000h ; Y  W


;----------------------------------------------------------------------------;
;  Textos - As strings para write sao terminadas em 0 e as do scroller em    ;
;  0ffh. O bit 7 ligado ‚ interpretado como caracter seguido de um espa‡o.   ;
;  O texto parece criptografado - mas na realidade ‚ apenas a compensa‡ao    ;
;  para os caracteres que nao sao utilizados.                                ;
;----------------------------------------------------------------------------;

scroller        db      'PNRH',128+'D','BBP',160,'+55-41-264-849U'
                db      160,'24h',160,'S32bis',160,'OHM',00h,'PRMMLOQE',128+'D'
                db      160,'DEKL',128+'P',160,'PLROCE',128+'P',160,'PGAOETAO'
                db      128+'E',160,'OB',128+'Q','12:1241/',128+'1',160,'FHD'
                db      128+'L','4:8U4/',128+'2',160,'CROHQHB',128+'A',128+'-'
                db      'BOAVH',128+'J',160,0ffh


; --- Texto para saida se falhou o teste VGA/386

endmsg          db      'Squi',128+'d','BB',128+'S',160,'+55-41-264-8490'

                        ;  ^-- a string aproveita o 0 da tabela de senos :-))


;----------------------------------------------------------------------------;
;  Tabela de senos de -127 a 127, 64 angulos do primeiro quadrante           ;
;  Tabela de conversao das notas para frequencias da Adlib                   ;
;  Tabela de conversao de trilha para registradores                          ;
;----------------------------------------------------------------------------;

sintable LABEL BYTE

 db     0,   3,   6,   9,  12,  16,  19,  22,  25,  28,  31,  34,  37,  40
 db    43,  46,  49,  51,  54,  57,  60,  63,  65,  68,  71,  73,  76,  78
 db    81,  83,  85,  88,  90,  92,  94,  96,  98, 100, 102, 104, 106, 107
 db   109, 111, 112, 113, 115, 116, 117, 118, 120, 121, 122, 122, 123, 124
 db   125, 125, 126, 126, 126, 127, 127, 127, 127


note2freq       dw      16bh, 181h, 198h, 1b0h, 1cah, 1e5h
                dw      202h, 220h, 241h, 263h, 287h, 2aeh

                ;  ^--- Obs: afinamos a Adlib em C#. Nenhum motivo especial.


reg_index       db      00h, 01h, 02h, 08h, 09h, 0ah, 10h, 11h, 12h


;----------------------------------------------------------------------------;
;  Trilhas e instrumentos                                                    ;
;                                                                            ;
;  O mini-player ‚ organizado por trilhas c¡clicas que podem ser designadas  ;
;  para qualquer dos 9 canais da Adlib. O "arpejador" ‚ uma trilha especial  ;
;  em que cada nota ‚ transposta segundo valores pr‚-definidos.  Os c¢digos  ;
;  v lidos para os dados em uma trilha sao:                                  ;
;                                                                            ;
;  50h : 1/32 compasso  (note length)                                        ;
;  51h : 1/16 compasso                                                       ;
;  53h : 1/8  compasso                                                       ;
;  57h : 1/4  compasso                                                       ;
;  5fh : 1/2  compasso                                                       ;
;  6fh : 1    compasso                                                       ;
;  80h a ffh: nota (oitava no nibble superior e nota no inferior, 0==d¢)     ;
;  00h a 3fh: volume, seguido por dois bytes de volume para os operadores    ;
;  40h : Encerrador de trilha                                                ;
;                                                                            ;
;----------------------------------------------------------------------------;


arpegiator      db  0,0,5,5,10,10,5,5,40h


;               Base: C C F F Bb Bb F F  --  Pequena e repetitiva
;                                            musica de elevador
;
;                 Padrao do arpejador:
;
;                 pitch  ^
;                        |
;                  2  -  | x x         x   x x         x
;                     -  |         x                 x
;                  1  -  x     x     x   x     x   x
;                     -  |       x               x
;                  0  - -+-------+-------+-------+--------> tempo
;                        1 . . . 2 . . . 3 . . . 4 . . .
;
;
;  A musiquinha abaixo foi escrita "em hexa", e a principal preocupa‡ao
;  foi a economia de bytes - as notas sao longas, o loop ‚ curto e o
;  t¡tulo ‚ bem sugestivo :-)))


;  Muzak: "Cycle: loop cycle"
;  (just a boring Casiotone-style muzak - no room for
;   something better in this 1899 byte addy!)

arp_pattern LABEL BYTE
db  051h,0a0h,0b0h,0b0h,0a0h,097h,0a7h,0a0h,0b0h
db  0a0h,0b0h,0b0h,0a0h,097h,0a0h,0a7h,0b0h,040h

arp2 LABEL BYTE
db  053h,0d0h,0c7h,0c5h,0c0h,0b7h,0b5h,0b0h,0a7h
db  0d0h,0c7h,0c5h,0c0h,0b7h,0b5h,0b0h,0a7h,13h,13h,040h

basso LABEL BYTE
db  07fh,0a0h,057h,09ah,0a0h                    ; C
db  07fh,095h,057h,000h,090h                    ; F
db  07fh,09ah,057h,000h,0a0h                    ; Bb
db  07fh,095h,057h,004h,008h,0a5h,0a7h,040h     ; F

solo LABEL BYTE
db  06fh,0a0h,000h,0a5h,000h,0aah,057h
db  0aah,0a9h,0a5h,0a2h,06fh,0a0h,000h
db  06bh,0b5h,063h,0b4h,057h,0aah,0b0h
db  07fh,0b5h,057h,0bah,0b9h,06fh,0b5h
db  07fh,000h,000h;,000h
db  06bh,0b5h,063h,0b4h,057h,0b4h,0b5h
db  06bh,0bah,06bh,0b9h,057h,0b0h
db  067h,0b4h,053h,0b5h
db  06bh,0b2h,053h,0b4h,0b5h
db  06fh,0bah,0b9h,06fh,000h,000h
db  000h,0a9h,0b2h,0b5h,0b9h,0a9h,040h


; Measure  1___.___|___.___2___.___|___.___
;  Sdrum   ....x..x....x.......x.......x.xx
;  Bdrum   x...x...x...x...x...x...x...x...

bassdrum LABEL BYTE
db  057h,080h,040h

snaredrum LABEL BYTE
db  057h,000h,051h,090h,000h,000h,090h
db  057h,000h,05fh,090h,090h
db  051h,006h,006h,090h,000h,090h,090h,40h


; --- Programa‡ao dos instrumentos

instruments LABEL BYTE
;
;  Estes instrumentos sao simplifica‡oes de alguns que eu programei num
;  Yamaha DX-100. Infelizmente, o FM nao permite (de modo simples) obter
;  instrumentos de percussao decentes - um bom snaredrum faz falta :-((
;  Controles para modula‡ao de amplitude e pitch nao estao incluidos
;  nesta versao.
;
;
;          Waveform -------------------------+
;   Sustain/Release -------------------+     |
;      Attack/Decay -------------+     |     |
; Scale Lev/Tot Lev -------+     |     |     |     +--- Feedback/Algorithm
; AMD/PMD/EG/KSR/MF -+     |     |     |     |     |
;                    |     |     |     |     |     |
;                                                  |
arpeg           db  00h,  05h, 086h, 0c1h,  02h       ; <-- op 1 (modulator)
                db  00h,  05h, 0d6h, 0c1h,  03h,  03h ; <-- op 2 (carrier)

brass           db  02h,  08h, 0f2h, 0c1h,  01h
                db  01h,  4ah, 082h, 0c1h,  03h,  03h

synth           db  00h, 03fh, 0f6h,  05h,  02h
                db  01h, 03fh, 0f6h,  05h,  03h,  03h

laserharp       db  01h,  3fh, 071h,  02h,  01h
                db  01h,  3fh, 071h,  02h,  02h,  02h

bdrum           db  00h,  03h, 0a7h, 0ffh,  00h
                db  00h,  02h, 0e7h, 0ffh,  00h,  00h

sdrum           db  05h,  3fh, 0f8h, 0ffh,  01h
                db  06h,  3fh, 0f8h, 0ffh,  02h,  0eh


;----------------------------------------------------------------------------;
;  Dados. Os valores nao-inicializados das tabelas nao contam no tamanho     ;
;  do .COM resultante, e por isso sao deixadas no final. Isso evita o uso    ;
;  de utilit rios que removem os dados nao-inicializados.                    ;
;----------------------------------------------------------------------------;

a_ptr           dw      OFFSET arpegiator

sm_table        db      0c2h,0c0h,0c3h,0c1h,0dbh,0c8h,037h,0c3h
                db      0c6h,0c4h,0c7h,0c5h,0c9h,0dbh,0dbh,0c5h
                db      000h,000h,000h,000h,000h,000h,0dbh

base            LABEL   WORD                    ; offset base de cada trilha
canal1          dw      OFFSET arp_pattern
canal2          dw      OFFSET solo
canal3          dw      OFFSET arp2
canal4          dw      OFFSET basso
canal5          dw      OFFSET bassdrum
canal6          dw      OFFSET snaredrum
canal7          dw      OFFSET solo             ; chorus para o solo

finetune        LABEL   BYTE                    ; afina‡ao (usada p/ chorus)
                db      0
                db      4
                db      ?
                db      ?
                db      ?
                db      ?
                db      ?

track           LABEL   WORD                    ; offset atual da trilha
                dw      TRACKS dup (?)

notelen         LABEL   WORD                    ; dura‡ao de nota atual
                dw      TRACKS dup (?)

timer           LABEL   WORD                    ; timer para cada trilha
                dw      TRACKS dup (?)

scroll_index    dw      ?                       ; conta cada coluna
angle           db      ?                       ; angulo para sinusbars
fontbuffer      db      16*256 dup (?)          ; espa‡o pro fonte 8x16
pal_table       db      8 *300 dup (?)          ; palette
extended        db      16*128*16 dup (?)       ; tabela estendida

code    ENDS

;----------------------------------------------------------------------------;
;  Fim do programa. Simples, nao?                                            ;
;----------------------------------------------------------------------------;

END     start

