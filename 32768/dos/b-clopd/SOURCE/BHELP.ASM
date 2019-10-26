.286
assume cs:code,ds:data;

public Scrp2Screen;
public PutSprHelp;
public PutBSprHelp;
public NewParticle;
public TurnSprHelp;
public DrawBackHelp;
public getVek;
public GetFix;
public ToFix;
public FillBack;
public DoubleHelp;

data segment public
  extrn WArg1;
  extrn WArg2;
  extrn WArg3;
  extrn WArg4;
  extrn WArg5;
  extrn IArg1;
  extrn IArg2;
  extrn IArg3;
  extrn IArg4;
  extrn IArg5;
  extrn LArg1:dword;
  extrn CMix:dword;
  extrn RGBTab:dword;
  extrn CSource:dword;
  extrn CDest:dword;
  extrn Palette:dataptr;
  extrn MixCol:byte;
  extrn BCol:dataptr;

  EXTRN Particle:dword;
  extrn Particles:word;
  extrn MaxParticles:word;
  extrn _tParticleSize:word;

  XX dd 0;
  YY dd 0;
  DPtr dw 0;
  V1 dw 0;
  V2 dw 0;
  extrn Btab:dataptr;
  extrn BackLayer:dword;
  extrn Scrp:dword;
  extrn WinX:word;
  extrn WinY:word;
  extrn WolX:Byte;
  extrn WolY:Byte;
data ends

code segment public
P386N

DoubleHelp proc pascal far Sou:dword,Temp:dword
  lfs si,Sou
  lgs bx,fs:[si+12]
  les di,Temp

  mov ax,fs:[si];
  shl ax,1
  mov [V1],ax
  mov ax,fs:[si+2];
  shl ax,1
  mov [V2],ax

  xor cx,cx
@DYLoop:
    push cx
    xor dx,dx
  @DXLoop:
      push dx
      push dx

      mov ax,cx
      shr ax,1
      imul ax,fs:[si]

      pop dx
      shr dx,1
      add ax,dx

      push bx
      add bx,ax
      mov al,gs:[bx]
      pop bx

      stosb

      pop dx
      inc dx
      cmp dx,V1
    jne @DXLoop


    pop cx
    inc cx
    cmp cx,V2
  jne @DYLoop

  mov eax,Temp
  mov fs:[si+12],eax
  xor eax,eax
  mov ax,fs:[si]
  mov fs:[si+4],eax
  mov ax,fs:[si+2]
  mov fs:[si+8],eax
  shl word ptr fs:[si],1
  shl word ptr fs:[si+2],1
  ret
DoubleHelp endp

FillBack proc pascal far DestP:dword,Col:word;
  push es
  mov ax,col
  shl eax,8
  mov al,ah
  shl eax,8
  mov al,ah
  shl eax,8
  mov al,ah
  les di,DestP
  mov cx,16000
  rep stosd
  pop es
  ret
FillBack endp

DrawBackHelp proc pascal far
  lfs di,BackLayer
  les di,Scrp

  mov ax,winx
  shr ax,1
  mov bl,al
  shr ax,1
  mov dl,al

  mov ax,winy
  shr ax,1
  mov bh,al
  shr ax,1
  mov dh,al

  add bl,WolX
  add bh,WolY

  mov cx,200
  @BYLoop:
    push cx
    push bx
    push dx
    mov cx,320
    @BXLoop:
      mov al,fs:[bx]
      xchg bx,dx
      add al,fs:[bx]
      shr ax,1
      stosb
      inc bl
      inc dl
    loop @BXLoop
    pop dx
    pop bx
    inc bh
    inc dh
    pop cx
  loop @BYLoop

  les di,Scrp

  xor bx,bx
  mov cx,64000
  @FBLoop:
    mov bl,es:[di]
    mov al,byte ptr [BTab+bx]
    stosb
  loop @FBLoop

  ret
DrawBackHelp endp

GetFix proc pascal far L:dword
  mov eax,L
  sar eax,8
  mov edx,eax
  sar edx,16
  ret
GetFix endp

ToFix proc pascal far L:dword
  mov eax,L
  sal eax,8
  mov edx,eax
  sar edx,16
  ret
ToFix endp

GetVek proc pascal far XX1:dword,YY1:dword,XX2:dword,YY2:dword
  mov eax,xx2
  sub eax,xx1
  sar eax,8
  imul eax,eax

  mov ebx,yy2
  sub ebx,yy1
  sar ebx,8
  imul ebx,ebx

  add eax,ebx
  mov edx,eax
  sar edx,16

  ret
GetVek endp

TurnSprHelp proc pascal far InSp:dword,OutDat:dword,Sin:dword,Cos:dword

  les di,OutDat
  lgs si,InSp

  mov  eax,16384     ;Gen
  sub  eax,Cos       ;-Co
  imul eax,gs:[si+4] ;*XMid
  mov  ebx,Sin       ;si
  imul ebx,gs:[si+8] ;*YMid
  add  eax,ebx

  mov  ecx,16384     ;Gen
  sub  ecx,Sin       ;-Si
  sub  ecx,cos       ;-co
  imul ecx,gs:[si+8] ;*YMid
  mov  edx,ecx

  lfs bx,gs:[Si+12]  ;SpriteDat
  mov [dptr],bx

; eax = OX   edx = OY

  mov  cx,gs:[si+2]  ;YSize
  @TSYLoop:
    mov [XX],eax
    mov [YY],edx
    push cx
    push eax
    push edx
    mov cx,gs:[si] ;XSize
    @TSXLoop:
      mov eax,YY
      sar eax,14
      cmp ax,0           ;YY<0 ?
      jl  @NotInRange
      cmp ax,gs:[si+2]   ;YY>=YSize ?
      jnl @NotInRange
      imul ax,gs:[si]    ;*XSize
      mov ebx,XX
      sar ebx,14
      cmp bx,0           ;XX<0 ?
      jl  @NotInRange
      cmp bx,gs:[si]     ;XX>=XSize ?
      jnl @NotInRange
      add bx,ax
      add bx,Dptr
      mov al,fs:[bx]
      jmp @SetPixel
      @NotInRange:
      xor al,al
      @SetPixel:
      stosb
      mov eax,Cos
      add XX,eax
      mov eax,Sin
      add YY,eax
    loop @TSXLoop
    pop edx
    pop eax
    sub eax,Sin
    add edx,Cos
    pop cx
  loop @TSYLoop
  ret
TurnSprHelp endp

NewParticle proc pascal far _X:dword,_Y:dword,_XSp:dword,_YSp:dword,_Live:dword,R:word,G:word,B:word

  mov ax,Particles
  cmp ax,MaxParticles
  jl @DontQuit
  ret
@DontQuit:
  inc [Particles]
  mov ax,Particles
  mul _tParticleSize

  les di,Particle
  add di,ax
  mov eax,_X
  mov es:[di],eax
  mov eax,_Y
  mov es:[di+4],eax
  mov eax,_XSp
  mov es:[di+8],eax
  mov eax,_YSp
  mov es:[di+12],eax
  mov eax,_Live
  mov es:[di+16],eax
  mov ax,R
  mov es:[di+20],ax
  mov ax,G
  mov es:[di+22],ax
  mov ax,B
  mov es:[di+24],ax

  ret
NewParticle endp

Scrp2Screen proc pascal
  push ds
  les di,CDest
  lds si,CSource
  mov cx,16000
  rep movsd
  pop ds
  ret
Scrp2Screen endp


PutSprHelp proc pascal
      push ds
      mov dx,IArg2;
      mov cx,IArg1;
      mov bx,WArg3;
      xor ah,ah

      les di,CDest
      lds si,CSource
      @YLoop:
        push si
        push di
        push cx
        @XLoop:
          cmp ds:[si],ah
          je @NoCopy;
          movsb;
          loop @XLoop;
          jmp @EndOfCopy;
          @NoCopy:
          inc si
          inc di
        loop @XLoop;
        @EndOfCopy:
        pop cx
        pop di
        pop si
        add si,bx
        add di,320

        dec dx;
      jnz @YLoop;

      pop ds

      ret
PutSprHelp endp

PutBSprHelp proc pascal
      lfs di,CMix

      push ds
      mov dx,IArg2;
      mov cx,IArg1;
      mov ax,WArg3;

      mov bx,di
      les di,CDest
      lds si,CSource
      mov es:[64000],bx
      @1YLoop:
        push si
        push di
        push cx
        @1XLoop:
          mov bh,ds:[si]
          or bh,bh
          jz @1NoCopy;
          mov bl,es:[di]
          add bx,es:[64000]
          mov bl,byte ptr fs:[bx]
          mov es:[di],bl
          @1NoCopy:
          inc si
          inc di
        loop @1XLoop;
        @1EndOfCopy:
        pop cx
        pop di
        pop si
        add si,ax
        add di,320

        dec dx;
      jnz @1YLoop;

      pop ds

      ret
PutBSprHelp endp

BlockedHelp proc pascal
      pusha

      lfs si,CSource
      add si,WArg5


      mov dx,WArg2
      sub dx,WArg1
      @CYLoop:


        dec dx
      jnz @CYLoop

      popa
      ret
BlockedHelp endp

code ends
end