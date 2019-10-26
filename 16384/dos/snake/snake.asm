.model large
.386
        vel equ 2
.data
        tics dd 0
        token db ?
        leng db ?
        l_real db ?
        px db 256 dup (?)
        py db 256 dup (?)
        rel_ant dd ?
        tec_ant dd ?
        final db 0
        direc db ?
        pret db 0
        tipus db ?
        frozen db 0
        temp db ?
        nivell db ?
        pant db 1200 dup (?)
        filename db 'pant00.res'
        buffer db 150 dup (?)
        colors db 1,12,13,14,15
        vides db ?
        longs db 3,6,12,21,33,48,66,87,111,138
        paused db 0
        text_pausa db 'PAUSED'
        text_error db 'File "pant00.res" not found in the main directory!$'
        text_sortir db 'You have exited! I will be waiting for you.$'
        text_pasat db 'Good work! You',39,'ve passed all levels.$'
        text_mort db 'You have been killed! Please retry.$'
        text_hello db 10,13,10,13,'Programmed by:',10,13
                db 4 dup(32),'Gerard Monells',10,13
                db 4 dup(32),'Chico_GMB@hotmail.com',10,13,'$'
.stack 100h
.code
proc truerand
        push bp
        mov bp,sp
        pusha

        mov ecx,100
        cli
bucle_rnd:
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
        loop bucle_rnd

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

pinta proc
        push ebp
        mov ebp,esp

        push ax es dx esi edi bx

        mov ax,0A000h
        mov es,ax

        mov ax,12[ebp]
        mov bh,al

        movzx esi,word ptr 10[ebp]
        shl esi,4
        mov edi,esi
        shl edi,2
        add esi,edi
        shl esi,4
        movzx edi,word ptr 8[ebp]
        shl edi,1
        add esi,edi

        mov edi,esi
        add edi,16*80
for01:
        mov ah,15
        mov dx,3c4h
        mov al,2
        out dx,ax
        mov es:[esi],byte ptr 0
        mov es:1[esi],byte ptr 0

        mov ah,bh
        mov dx,3c4h
        mov al,2
        out dx,ax
        mov es:[esi],byte ptr 0FFh
        mov es:1[esi],byte ptr 0FFh

        add esi,80
        cmp esi,edi
        jne for01

        pop bx edi esi dx es ax

        pop ebp
        ret 6
pinta endp

teclat proc
        push eax ebx
        mov ax,@data
        mov ds,ax

        in al,60h

        mov bl,frozen
        cmp bl,-1
        je sino
        cmp paused,-1
        je pausa

        bt ax,7
        jc sino
        cmp al,1
        jne a1
        mov final,byte ptr -1
        mov tipus,byte ptr 1
        jmp sino
a1:
        cmp al,72
        jne a2
        mov temp,byte ptr 1
        jmp sino
a2:
        cmp al,77
        jne a3
        mov temp,byte ptr 2
        jmp sino
a3:
        cmp al,75
        jne a4
        mov temp,byte ptr 3
        jmp sino
a4:
        cmp al,80
        jne pausa
        mov temp,byte ptr 4
        jmp sino
pausa:
        cmp al,57
        jne sino
        not paused

        push esi ecx edx
        mov esi,0
for_pausa1:
        mov ah,2
        mov bh,0
        mov dx,si
        add dx,37
        mov dh,29
        int 10h
        mov ah,9
        mov al,219
        mov bh,0
        mov bl,colors[1]
        mov cx,1
        int 10h
        cmp paused,-1
        jne none1
        mov ah,9
        mov al,text_pausa[esi]
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
none1:
        inc esi
        cmp esi,6
        jne for_pausa1
        pop edx ecx esi

sino:

        mov al,temp
        mov ah,direc
        add ah,al
        cmp ah,5
        je a5
        mov pret,al

a5:
        mov al,20h
        out 20h,al
        pop ebx eax
        iret
teclat endp

rellotje proc
        push eax
        mov ax,@data
        mov ds,ax

        push esi edi ebx ecx
        cmp frozen,byte ptr -1
        je ret_rell
        cmp paused,-1
        je ret_rell
        inc tics
        cmp tics,vel
        jne ret_rell
        mov tics,0

        mov al,pret
        mov direc,al
        movzx esi,byte ptr px[0]
        movzx edi,byte ptr py[0]

        cmp direc,byte ptr 1
        je up_
        cmp direc,byte ptr 4
        je down_
        cmp direc,byte ptr 2
        je right_
        cmp direc,byte ptr 3
        je left_
        jmp fi_select
left_:
        dec esi
        jmp fi_select
right_:
        inc esi
        jmp fi_select
down_:
        inc edi
        jmp fi_select
up_:
        dec edi
        jmp fi_select
fi_select:

        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi
        mov bl,byte ptr pant[eax]
        cmp bl,0
        je else_kk
        cmp bl,2
        je else_kk
si_kk:

        dec vides
        cmp vides,byte ptr 0
        jne else_m
if_m:
        mov final,-1
        mov tipus,2
        jmp fsi_m
else_m:
        mov frozen,byte ptr -1

        mov esi,0
        mov ecx,0
bu01:
        mov bl,buffer[esi]
        mov edi,0
bu02:
        mov bh,0
        rcl bl,1
        rcl bh,1
        mov pant[ecx],bh
       
        inc ecx
        inc edi
        cmp edi,8
        jne bu02

        inc esi
        cmp esi,150
        jne bu01

        mov direc,byte ptr 2
        mov pret,byte ptr 2
        mov temp,byte ptr 2
        mov eax,0
        mov (40*15+18)[pant],byte ptr 3
        mov (40*15+19)[pant],byte ptr 3
        mov (40*15+20)[pant],byte ptr 3
        mov leng,byte ptr 3
        mov l_real,byte ptr 3
        mov px[0],byte ptr 20
        mov px[1],byte ptr 19
        mov px[2],byte ptr 18
        mov py[0],byte ptr 15
        mov py[1],byte ptr 15
        mov py[2],byte ptr 15

        mov edi,0
bl01:
        mov esi,0
bl02:
        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi
        movzx eax,byte ptr pant[eax]
        movzx ax,colors[eax]

        push ax
        push di
        push si
        call pinta
        inc si
        cmp si,40
        jne bl02
        inc di
        cmp di,30
        jne bl01
        
ini03:
        push word ptr 40
        call truerand
        movzx esi,ax
        push word ptr 30
        call truerand
        movzx edi,ax
        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi
        mov bl,byte ptr pant[eax]
        cmp bl,0
        jne ini03
        mov pant[eax],byte ptr 2
        movzx ax,byte ptr colors[2]
        push ax
        push di
        push si
        call pinta

        mov nivell,byte ptr 0
        mov token,byte ptr 0
        mov frozen,byte ptr 0

        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,0
        int 10h
        mov ah,9
        mov al,'V'
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,2
        int 10h
        mov ah,9
        mov al,vides
        add al,2Fh
        int 10h

        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,77
        int 10h
        mov ah,9
        mov al,'M'
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,79
        int 10h
        mov ah,9
        mov al,token
        add al,30h
        int 10h


        mov paused,-1

        push esi ecx edx
        mov esi,0
for_pausa4:
        mov ah,2
        mov bh,0
        mov dx,si
        add dx,37
        mov dh,29
        int 10h
        mov ah,9
        mov al,219
        mov bh,0
        mov bl,colors[1]
        mov cx,1
        int 10h
        cmp paused,-1
        jne none4
        mov ah,9
        mov al,text_pausa[esi]
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
none4:
        inc esi
        cmp esi,6
        jne for_pausa4
        pop edx ecx esi


fsi_m:
        jmp fsi_kk
else_kk:

        mov pant[eax],byte ptr 3
        movzx ax,byte ptr colors[3]
        push ax
        push di
        push si
        call pinta
        movzx ecx,byte ptr leng
e01:
        mov al,px-1[ecx]
        mov ah,py-1[ecx]
        mov px[ecx],al
        mov py[ecx],ah
        dec ecx
        cmp cl,0
        jne e01
        mov ax,si
        mov px[0],al
        mov ax,di
        mov py[0],al

        inc leng
        mov al,leng
        dec al
        cmp al,l_real
        jne e02
        dec leng
        movzx eax,byte ptr leng
        movzx si,byte ptr px[eax]
        movzx di,byte ptr py[eax]
        mov ax,0
        mov al,byte ptr colors[0]
        push ax
        push di
        push si
        call pinta

        and esi,0000FFFFh
        and edi,0000FFFFh
        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi

        mov pant[eax],byte ptr 0
e02:
        cmp bl,2
        jne fsi_kk

        inc token
        cmp token,10
        jne sino_token
si_token:
        mov final,-1
        mov tipus,3
        jmp fsi_token
sino_token:
        
ini01:
        push word ptr 40
        call truerand
        movzx esi,ax
        push word ptr 30
        call truerand
        movzx edi,ax
        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi
        mov bl,byte ptr pant[eax]
        cmp bl,0
        jne ini01
        mov pant[eax],byte ptr 2
        movzx ax,byte ptr colors[2]
        push ax
        push di
        push si
        call pinta

        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,77
        int 10h
        mov ah,9
        mov al,219
        mov bh,0
        mov bl,colors[1]
        mov cx,1
        int 10h
        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,79
        int 10h
        mov ah,9
        mov al,219
        int 10h

        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,77
        int 10h
        mov ah,9
        mov al,'M'
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,79
        int 10h
        mov ah,9
        mov al,token
        add al,30h
        int 10h
        
        movzx eax,byte ptr token
        mov al,longs[eax]
        mov l_real,al
fsi_token:

fsi_kk:

ret_rell:
        pop ecx ebx edi esi

        mov al,20h
        out 20h,al
        pop eax
        iret
rellotje endp
        
.startup

        mov frozen,byte ptr -1

        mov ax,0
        mov es,ax
        mov eax,es:[8*4]
        mov rel_ant,eax
        mov eax,es:[9*4]
        mov tec_ant,eax

        lea ax,rellotje
        cli
        mov es:[8*4],ax
        mov es:[8*4+2],cs
        sti
        lea ax,teclat
        cli
        mov es:[9*4],ax
        mov es:[9*4+2],cs
        sti

        mov ah,0
        mov al,12h
        int 10h

        mov ah,3Dh
        mov al,0
        lea dx,filename
        int 21h
        jc error
        mov bx,ax

        mov ah,3Fh
        lea dx,buffer
        mov cx,150
        int 21h
        jc error

        mov ah,3Eh
        int 21h

        mov esi,0
        mov ecx,0
buc01:
        mov bl,buffer[esi]
        mov edi,0
buc02:
        mov bh,0
        rcl bl,1
        rcl bh,1
        mov pant[ecx],bh
       
        inc ecx
        inc edi
        cmp edi,8
        jne buc02

        inc esi
        cmp esi,150
        jne buc01

        mov direc,byte ptr 2
        mov pret,byte ptr 2
        mov temp,byte ptr 2
        mov eax,0
        mov (40*15+18)[pant],byte ptr 3
        mov (40*15+19)[pant],byte ptr 3
        mov (40*15+20)[pant],byte ptr 3
        mov leng,byte ptr 3
        mov l_real,byte ptr 3
        mov px[0],byte ptr 20
        mov px[1],byte ptr 19
        mov px[2],byte ptr 18
        mov py[0],byte ptr 15
        mov py[1],byte ptr 15
        mov py[2],byte ptr 15

        mov edi,0
b01:
        mov esi,0
b02:
        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi
        movzx eax,byte ptr pant[eax]
        movzx ax,colors[eax]

        push ax
        push di
        push si
        call pinta
        inc si
        cmp si,40
        jne b02
        inc di
        cmp di,30
        jne b01

ini02:
        push word ptr 40
        call truerand
        movzx esi,ax
        push word ptr 30
        call truerand
        movzx edi,ax
        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi
        mov bl,byte ptr pant[eax]
        cmp bl,0
        jne ini02
        mov pant[eax],byte ptr 2
        movzx ax,byte ptr colors[2]
        push ax
        push di
        push si
        call pinta

        mov nivell,byte ptr 0
        mov token,byte ptr 0
        mov vides,byte ptr 3
        mov frozen,byte ptr 0

        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,0
        int 10h
        mov ah,9
        mov al,'V'
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,2
        int 10h
        mov ah,9
        mov al,vides
        add al,2Fh
        int 10h

        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,77
        int 10h
        mov ah,9
        mov al,'M'
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,79
        int 10h
        mov ah,9
        mov al,token
        add al,30h
        int 10h


        mov paused,-1

        push esi ecx edx
        mov esi,0
for_pausa3:
        mov ah,2
        mov bh,0
        mov dx,si
        add dx,37
        mov dh,29
        int 10h
        mov ah,9
        mov al,219
        mov bh,0
        mov bl,colors[1]
        mov cx,1
        int 10h
        cmp paused,-1
        jne none3
        mov ah,9
        mov al,text_pausa[esi]
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
none3:
        inc esi
        cmp esi,6
        jne for_pausa3
        pop edx ecx esi


bucle_bo:
        cmp final,-1
        jne bucle_bo

        mov frozen,byte ptr -1
        cmp tipus,byte ptr 1
        je surt
        cmp tipus,byte ptr 2
        je mort
        mov al,nivell
        inc al
        mov nivell,al

        mov ebx,5
        mov al,filename[ebx]
        inc al
        cmp al,10+48
        jne else_bo
        sub al,10
        mov filename[ebx],al
        mov ebx,4
        mov al,filename[ebx]
        inc al
        mov filename[ebx],al
        jmp fi_bo
else_bo:
        mov filename[ebx],al
fi_bo:

        mov ah,3Dh
        mov al,0
        lea dx,filename
        int 21h
        jc pasat
        mov bx,ax

        mov ah,3Fh
        lea dx,buffer
        mov cx,150
        int 21h
        jc pasat

        mov ah,3Eh
        int 21h

        mov esi,0
        mov ecx,0
buc001:
        mov bl,buffer[esi]
        mov edi,0
buc002:
        mov bh,0
        rcl bl,1
        rcl bh,1
        mov pant[ecx],bh
       
        inc ecx
        inc edi
        cmp edi,8
        jne buc002

        inc esi
        cmp esi,150
        jne buc001

        mov direc,byte ptr 2
        mov pret,byte ptr 2
        mov temp,byte ptr 2
        mov eax,0
        mov (40*15+18)[pant],byte ptr 3
        mov (40*15+19)[pant],byte ptr 3
        mov (40*15+20)[pant],byte ptr 3
        mov leng,byte ptr 3
        mov l_real,byte ptr 3
        mov px[0],byte ptr 20
        mov px[1],byte ptr 19
        mov px[2],byte ptr 18
        mov py[0],byte ptr 15
        mov py[1],byte ptr 15
        mov py[2],byte ptr 15

        mov edi,0
c01:
        mov esi,0
c02:
        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi
        movzx eax,byte ptr pant[eax]
        movzx ax,colors[eax]

        push ax
        push di
        push si
        call pinta
        inc si
        cmp si,40
        jne c02
        inc di
        cmp di,30
        jne c01

ini04:
        push word ptr 40
        call truerand
        movzx esi,ax
        push word ptr 30
        call truerand
        movzx edi,ax
        mov eax,edi
        shl eax,2
        add eax,edi
        shl eax,3
        add eax,esi
        mov bl,byte ptr pant[eax]
        cmp bl,0
        jne ini04
        mov pant[eax],byte ptr 2
        movzx ax,byte ptr colors[2]
        push ax
        push di
        push si
        call pinta

        mov vides,byte ptr 3
        mov frozen,byte ptr 0
        mov final,byte ptr 0
        mov token,byte ptr 0

        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,0
        int 10h
        mov ah,9
        mov al,'V'
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,2
        int 10h
        mov ah,9
        mov al,vides
        add al,2Fh
        int 10h

        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,77
        int 10h
        mov ah,9
        mov al,'M'
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
        mov ah,2
        mov bh,0
        mov dh,0
        mov dl,79
        int 10h
        mov ah,9
        mov al,token
        add al,30h
        int 10h


        mov paused,-1

        push esi ecx edx
        mov esi,0
for_pausa2:
        mov ah,2
        mov bh,0
        mov dx,si
        add dx,37
        mov dh,29
        int 10h
        mov ah,9
        mov al,219
        mov bh,0
        mov bl,colors[1]
        mov cx,1
        int 10h
        cmp paused,-1
        jne none2
        mov ah,9
        mov al,text_pausa[esi]
        mov bh,0
        mov bl,colors[4]
        xor bl,colors[1]
        add bl,80h
        mov cx,1
        int 10h
none2:
        inc esi
        cmp esi,6
        jne for_pausa2
        pop edx ecx esi


        jmp bucle_bo
pasat:
        lea dx,text_pasat
        jmp hello
surt:
        lea dx,text_sortir
        jmp hello
error:
        lea dx,text_error
        jmp hello
mort:
        lea dx,text_mort
        jmp hello
hello:
        push dx
        mov ah,0
        mov al,3
        int 10h
        pop dx

        mov ah,9
        int 21h

        lea dx,text_hello
        mov ah,9
        int 21h

        jmp restaura

restaura:
        mov ax,0
        mov es,ax
        mov eax,rel_ant
        mov es:[8*4],eax
        mov eax,tec_ant
        mov es:[9*4],eax
.exit
end
