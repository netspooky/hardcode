{$A-,B-,D-,E-,F-,G+,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X-,Y-}

            (*≤€€ ≤€‹     ﬁ€                                       ≤€‹‹
              €≤€ €±€     €›                  ±                    €≤€
          ‹‹‹‹≤€€ ≤‹€    ﬁ€   ‹‹‹‹‹‹‹ ∞‹‹    ≤ﬂ€    ‹‹‹‹‹‹‹    ‹‹‹‹≤€€    .
        ‹≤€ﬂ d‹ﬂ€ €€≤   s€› ‹≤€ﬂ  €€≤ €ﬂ€    €€≤s.‹≤€ﬂ  ≤€≤  ‹≤€ﬂ  €€≤
    .s˝ﬁ€€›s..€±≤ €€±.s˝ﬁ€^ﬁ€€›   €€± €€≤   .€€± ﬁ€€›a. €€±sﬁ€€›   €€±   :
    $  ≤€≤  `s€≤€ ≤€≤   €› ≤€€.s˝^≤€≤s≤€€.s˝'≤€≤ ≤€€  `s≤€≤ ≤€€s˝^s≤€≤  $'
   :   ‹ ﬂ    ﬂ ‹ ‹lﬂ  ﬁ€  ﬂq‹    ‹‹  ﬂ ‹    ‹uﬂ ‹ ﬂ    ﬂ ‹ ‹‹±    ‹ ﬂs˝'
  ∞ ∞∞∞ﬁ≤€› ∞ ∞€€ €€€  €›∞∞ﬁ≤€›∞∞ €€€ ﬁ€€›∞∞ €€€ ﬁ€€›∞∞ €€€ ﬁ€€›∞∞ €€€ ∞∞ ∞
<====== ﬂ€€‹  €≤€ €≤€ ﬁ€ == ﬂ€€‹  €≤€ =ﬂ€€‹  €≤€ =ﬂ€€‹  €≤€ =ﬂ€€‹ d€≤€ =====>
          ﬂﬂﬂﬂﬂﬂﬂ ﬂﬂﬂ €›      ﬂﬂﬂﬂ≤€€    ﬂﬂﬂﬂﬂﬂﬂ    ﬂﬂﬂﬂﬂﬂﬂ    ﬂﬂﬂﬂﬂﬂﬂ
                                  ±€≤
             d e a d l i n e      ‹€€       // deadline@quad98.net *)


type  TextureType=Array[0..65534] of Byte;
      blabank = array[0..639] of byte;
      Virtual = Array [1..64000] of byte;
      VirtPtr = ^Virtual;

var   Fseg,Fofs : word;
      Virscr : VirtPtr;
      Vaddr  : word;
      effect  : integer;
      SinLook,Coslook : array[0..1023] of integer;
      map,texture : ^texturetype;
      oldbank,newbank : blabank;
      i,j : integer;
      koeleur:byte;
      tempcounter,tc2:word;

const effects : array[0..7] of byte = (8,8,1,10,8,1,6,1);
      tot=107;
      lengte=100;
      aantal=12
      ConstM31 = Longint(-31);
      Factor: Word = $8405;

function NextRand: Longint; assembler;
asm
  MOV  AX,RandSeed.Word[0]
  MOV  BX,RandSeed.Word[2]
  MOV  CX,AX
  MUL  Factor.Word[0]     { New = Old.w0 * 8405H }
  SHL  CX,1               { New.w2 += Old.w0 * 808H }
  SHL  CX,1
  SHL  CX,1
  ADD  CH,CL
  ADD  DX,CX
  ADD  DX,BX              { New.w2 += Old.w2 * 8405H }
  SHL  BX,1
  SHL  BX,1
  ADD  DX,BX
  ADD  DH,BL
  MOV  CL,5
  SHL  BX,CL
  ADD  DH,BL
  ADD  AX,1      { New += 1 }
  ADC  DX,0
  MOV  RandSeed.Word[0],AX
  MOV  RandSeed.Word[2],DX
end;

function Random(Max: word): word; assembler;
asm
  CALL  NextRand
  XOR   AX,AX
  MOV   BX,Max.Word[0]
  OR    BX,BX
  JE    @@1
  XCHG  AX,DX
  DIV   BX
  XCHG  AX,DX
 @@1:
end;

const sintab : array[0..255] of byte =
(0,1,2,2,3,4,5,5,6,7,8,9,9,10,11,12,13,
13,14,15,16,16,17,18,19,20,20,21,22,23,23,24,25,
26,27,27,28,29,30,30,31,32,33,33,34,35,36,36,37,
38,39,39,40,41,42,42,43,44,45,45,46,47,48,48,49,
50,50,51,52,53,53,54,55,55,56,57,58,58,59,60,60,
61,62,62,63,64,64,65,66,66,67,68,68,69,70,70,71,
72,72,73,74,74,75,76,76,77,78,78,79,79,80,81,81,
82,82,83,84,84,85,85,86,87,87,88,88,89,89,90,91,
91,92,92,93,93,94,94,95,95,96,96,97,97,98,98,99,
99,100,100,101,101,102,102,103,103,104,104,105,105,106,106,106,
107,107,108,108,109,109,109,110,110,111,111,111,112,112,113,113,
113,114,114,114,115,115,115,116,116,116,117,117,117,118,118,118,
119,119,119,119,120,120,120,121,121,121,121,122,122,122,122,122,
123,123,123,123,124,124,124,124,124,125,125,125,125,125,125,126,
126,126,126,126,126,126,126,127,127,127,127,127,127,127,127,127,
127,128,128,128,128,128,128,128,128,128,128,128,128,128,128);

procedure adjust(xa,ya,x,y,xb,yb: integer);
var d,g : integer;
begin
     if texture^[Y shl 8+x]<>0 then exit;
     d:=Abs(xa-xb)+Abs(ya-yb);
     g:=(50 * (texture^[ya shl 8+xa] + texture^[yb shl 8+xb]));
     g:=g+(random(100*d)-40*d);
     asm mov  ax,g
         mov  bx,100

         idiv bx
         cmp  ax,1
         jge  @1
         mov  ax,1
     @1:
         cmp  ax,32
         jl   @2
         mov  ax,31
     @2:
         mov  g,ax

         les  di,texture
         mov  di,y
         shl  di,8
         add  di,x
         mov  ax,g
         mov  [es:di],al
     end;
end;

procedure subDivide(x1,y1,x2,y2: integer);
var
  x,y: integer;
begin
     if (x2-x1<2) and (y2-y1<2) then exit;
     asm mov  ax,x1
         add  ax,x2
         sar  ax,1
         mov  x,ax
         mov  ax,y1
         add  ax,y2
         sar  ax,1
         mov  y,ax
     end;
     adjust(x1,y1,x,y1,x2,y1);
     adjust(x2,y1,x2,y,x2,y2);
     adjust(x1,y2,x,y2,x2,y2);
     adjust(x1,y1,x1,y,x1,y2);
     asm les  di,texture
         xor  bx,bx

         mov  di,y
         shl  di,8
         add  di,x
         mov  al,[es:di]
         cmp  al,0
         jne  @blaat

         mov  di,y1
         shl  di,8
         add  di,x1
         xor  ax,ax
         mov  al,[es:di]
         add  bx,ax

         mov  di,y2
         shl  di,8
         add  di,x1
         xor  ax,ax
         mov  al,[es:di]
         add  bx,ax

         mov  di,y1
         shl  di,8
         add  di,x2
         xor  ax,ax
         mov  al,[es:di]
         add  bx,ax

         mov  di,y2
         shl  di,8
         add  di,x2
         xor  ax,ax
         mov  al,[es:di]
         add  bx,ax

         sar  bx,2

         mov  di,y
         shl  di,8
         add  di,x
         mov  [es:di],bl
     @blaat:
     end;
     subDivide(x1,y1,x,y);
     subDivide(x,y1,x2,y);
     subDivide(x1,y,x,y2);
     subDivide(x,y,x2,y2);
end;

procedure writestring;
const s : string = 'vingerplant 2';
var x,y,ox,oy,pos,l : integer;
    ypos : word;
    blurk  :word;
    curchar : byte;
    splut : word;
begin
     l:=13;
     asm mov ax,160
         mov bx,l
         shl bx,3
         sub ax,bx
         mov ox,ax
     end;
     for pos := 1 to l do begin
         curchar := ord(s[pos]);
         asm mov ax,56680
             mov ypos,ax
         end;
         for y := 0 to 7 do begin
             for x := 0 to 7 do begin
                 asm
                    xor ax,ax
                    mov al,curchar
                    shl ax,3
                    add ax,fofs
                    add ax,y
                    mov splut,ax
                 end;
                 if ((mem[Fseg:splut] shl x) and 128) <> 0 then
                 begin
                      asm
                         mov ax,vaddr
                         mov es,ax
                         mov di,ypos
                         add di,x
                         add di,x
                         add di,ox
                         mov al,63
                         mov [es:di],al
                         inc di
                         mov [es:di],al
                         add di,319
                         mov [es:di],al
                         inc di
                         mov [es:di],al
                      end;
                 end;
                 end;
         asm add ypos,640 end;
         end;
         asm add ox,16; end;
     end;
end;

var x,y : integer;
    realx,realy : integer;
    tempx,tempy,tempz : integer;
    lastx : integer;
    lastcolor: byte;
    lastypos : byte;
    k: integer;
    temp1,temp2:integer;
    loop:integer;
    rx,ry : integer;
    deg : integer;
    wurt : word;
    xpos,ypos : byte;
    loop1: integer;
    cd,sd : integer;
    nb :byte;

var progress : byte;
    tempr,tempg,tempb : byte;
    w : word;
    counter:word;
begin
     counter:=0;
     getmem(texture,65535);
     getmem(map,65535);
     getmem (virscr,64000);

     asm mov  ax,1130h
         mov  bh,1
         int  10h
         mov  Fseg,es
         mov  Fofs,bp

         les  di,texture
         xor  ax,ax
         push ax
         push ax
         db   66h
         pop  ax
         mov  cx,32768
         db   066h
         rep  stosw
     end;

     texture^[0] := 1+Random(31);
     texture^[0] := 1+Random(31);
     texture^[255*255] := 1+Random(31);
     texture^[0] := 1+Random(31);
     subDivide(0,0,255,255);

     for i := 0 to 127 do
         for j := 0 to 127 do texture^[i*256+(255-j)]:=texture^[i*256+j];
     for i := 0 to 127 do
         for j := 0 to 255 do texture^[(255-i)*256+j]:=texture^[i*256+j];

     for x:=0 to 255 do begin
         sinlook[x]:=sintab[x];
         sinlook[x+256]:=sintab[255-x];
         sinlook[x+512]:=-sintab[x];
         sinlook[x+512+256]:=-sintab[255-x];
     end;
     for x:=0 to 1023 do begin
         coslook[x]:=sinlook[(1024+256-x) and 1023];
     end;

     asm les  di,virscr
         mov  vaddr,es
         mov  ax,13h
         int  10h
         mov  deg,0

         { interpolatepal }

         mov  cl,0
     @blaat:
         mov  al,cl
         mov  progress,al

         mov  al,82
         mov  bl,progress
         mul  bl
         mov  bl,tot
         div  bl
         push ax
         xor  al,al
         mov  bl,tot
         sub  bl,progress
         mul  bl
         mov  bl,tot
         div  bl
         mov  dl,al
         pop  ax
         add  al,dl
         mov  tempr,al

         mov  al,64
         mov  bl,progress
         mul  bl
         mov  bl,tot
         div  bl
         push ax
         mov  al,20
         mov  bl,tot
         sub  bl,progress
         mul  bl
         mov  bl,tot
         div  bl
         mov  dl,al
         pop  ax
         add  al,dl
         mov  tempg,al

         mov  al,48
         mov  bl,progress
         mul  bl
         mov  bl,tot
         div  bl
         push ax
         mov  al,30
         mov  bl,tot
         sub  bl,progress
         mul  bl
         mov  bl,tot
         div  bl
         mov  dl,al
         pop  ax
         add  al,dl
         mov  tempb,al

         mov  dx,$3c8
         mov  al,cl
         out  dx,al
         mov  dx,$3c9
         mov  al,tempr
         out  dx,al
         mov  dx,$3c9
         mov  al,tempg
         out  dx,al
         mov  dx,$3c9
         mov  al,tempb
         out  dx,al

         inc  cl
         cmp  cl,tot
         jne  @blaat
     end;

     for y:=0 to 255 do
         for x:=0 to 255 do
             if y shl 8+x<>65535 then
                map^[y shl 8+x]:=32+(coslook[(x shl 3) and 1023]+
                                     coslook[(y shl 5) and 1023]+
                                     sinlook[(x shl 4) and 1023]-
                                     sinlook[((y+x) shl 4) and 1023]) div 25;
     loop:=128;

     repeat
           inc(counter);

           effect:=effects[(counter div lengte) and 7];

           asm
               sub  ypos,2
               add  deg,4
               inc  xpos
               and  deg,1023

               push es
               mov  cx,32000;
               mov  es,vaddr
               xor  di,di
               xor  al,al
               mov  ah,al
               rep  stosw
               pop  es
           end;

           if effect and 1 = 1 then begin {voxel}
              for i:=0 to 639 do oldbank[i]:=0;
              for y:=159+67 downto 129+7 do begin
                  asm mov  ax,y
                      sub  ax,128
                      mov  tempz,ax
                      mov  bx,-160
                      mul  bx
                      mov  temp1,ax
                      xor  bx,bx
                      sub  bx,ax
                      mov  temp2,bx

                      xor  ax,ax
                      mov  lastx,ax
                      mov  lastypos,al

                      mov  ax,temp1
                      sar  ax,7
                      add  ax,128
                      cmp  temp1,10
                      jle  @bagger
                      mov  temp1,10
                  @bagger:
                      mov  temp1,ax

                      mov  ax,temp2
                      sar  ax,7
                      add  ax,128
                      cmp  ax,250
                      jge  @bagger2
                      mov  ax,250
                  @bagger2:
                      mov  temp2,ax
                  end;

                  for x:=temp1 to temp2 do begin
                      asm mov  ax,x
                          sub  ax,128
                          mov  tempx,ax
                      end;
                      cd:=coslook[deg];
                      sd:=sinlook[deg];
                      rx:=((cd*(x-xpos-128))-(sd*(y-ypos)));
                      ry:=((sd*(x-xpos-128))+(cd*(y-ypos)));
                      asm sar  rx,7
                          sar  ry,7

                          mov  ax,rx
                          add  ax,128

                          mov  bx,ry
                          mov  ah,bl
                          mov  wurt,ax

                          les  di,map
                          mov  di,wurt

                          xor  ah,ah
                          mov  al,[es:di]
                          mov  tempy,ax

                          mov  ax,tempx
                          shl  ax,7
                          mov  bx,tempz
                          cwd
                          idiv bx
                          mov  realx,ax
                          mov  ax,tempy
                          shl  ax,6
                          mov  bx,tempz
                          cwd
                          idiv bx
                          mov  realy,ax

                          les  di,texture
                          mov  di,wurt
                          mov  al,[es:di]
                          mov  bx,100
                          sub  bx,tempz
                          mul  bx
                          mov  bx,40
                          div  bx
                          mov  koeleur,al
                          mov  ax,100
                          add  ax,realy
                          mov  j,ax
                      end;
                      if j<229 then begin
                         asm mov  ax,realx
                             add  ax,160
                             mov  i,ax
                         end;
                         if i>0 then
                            if i<319 then begin
                               for k:=lastx to i-1 do begin
                                   if j>199 then lastypos:=199;
                                   newbank[k]:=lastypos;
                                   newbank[k+320]:=lastcolor;
                               end;
                               lastcolor:=koeleur;
                               lastypos:=100+realy;
                               lastx:=i;
                            end;
                      end;
                  end;

                  for i:=10 to 309 do begin
                      if (oldbank[i+320]<>0) then
                         if (oldbank[i]<>0) then begin
                            tempcounter:=oldbank[i]*320+i;
                            for k:=oldbank[i] to newbank[i]-1 do begin
                                nb:=newbank[i+320];
                                asm mov  es,vaddr
                                    mov  di,tempcounter
                                    mov  al,nb
                                    mov  [es:di],al
                                    add  tempcounter,320
                                end;
                            end;
                         end;
                  end;
                  oldbank:=newbank;
              end;
           end; {voxel}

           if effect and 2 = 2 then begin
              w:=0;
              for y:=0 to 199 do begin
                  for x:=0 to 319 do begin
                      cd:=coslook[deg];
                      sd:=sinlook[deg];
                      rx:=((cd*(x-260))-(sd*(y-140))); asm sar rx,7; end;
                      ry:=((sd*(x-260))+(cd*(y-00))); asm sar ry,7; end;
                      inc(mem[vaddr:w],texture^[((ry and 255) shl 8)+rx and 255]);
                      if effect and 4 = 4 then begin
                         rx:=((cd*(x-60))-(sd*(y-100))); asm sar rx,7; end;
                         ry:=((sd*(x-60))+(cd*(y-100))); asm sar ry,7; end;
                         inc(mem[vaddr:w],texture^[((ry and 255) shl 8)+rx and 255]);
                      end;
                      inc(w);
                  end;
              end;
           end;

           if effect and 8 = 8 then begin
              w:=0;
              for y:=0 to 199 do begin
                  for x:=0 to 319 do begin
                      cd:=coslook[x];
                      sd:=sinlook[deg];
                      rx:=((cd*(counter))-(sd*(y-140))); asm sar rx,7; end;
                      ry:=((sd*(x-260))+(cd*(y-00))); asm sar ry,7; end;
                      inc(mem[vaddr:w],texture^[((ry and 255) shl 8)+rx and 255]);
                      inc(w);
                  end;
              end;
           end;

           writestring;

           asm push ds
               mov  ax, $a000
               mov  es, ax
               mov  ax, vaddr
               mov  ds, ax
               xor  si, si
               xor  di, di
               mov  cx, 32000
               rep  movsw
               pop  ds
           end;

     until (port[$60]=1) or (counter>=aantal*lengte);

     asm mov  ax,03h
         int  10h
     end;

     freemem(virscr,64000);
     freemem(map,65535);
     freemem(texture,65535);
end.