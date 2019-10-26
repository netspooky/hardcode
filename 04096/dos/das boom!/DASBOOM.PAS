program das_boom; 

    {  a(bout a) 4kb intro (animation) by sliver / brainlez coders!
                                              -        -     -
       of coz this could be SMALLER.. a LOT smaller.. thanks to da packer,
       it crunched the .EXE from about 68kb to 4kb :) oh shiiit.. still
       63 bytes to use, or even more if the packer works like it should.
       if i were an assembler coder i would have included a backround effect
       into this lil'intro.
       
       hey, i commented this for those who are even more lame than me.
       (is there any?) 
       
       huh. this suxx. i'll have an orgasm if this gets to the screen.. 
       i'll have triple-x-orgasms if this gets to the best 5 ones..
       (yep. shure, dream on sliver..)

       and if you find any use for these sources, use then.. send me greets 
       if you are really so lame that you have to use shit like this.

       *** this is compiled with TURBO PASCAL 7.0 COMPILER. it won't make
           the executable file so small as it is now (4033 bytes) coz i
           used to edit all the shit away from it (like those (c) Borland-
           things) and pack it with DIET 1.45f.
       ***
    
                    "ascii graffat rulee" - sliver / bc! / liquid / ruma

    }

const 
       {n1,n2,n3,n4,n5,n6,n7,n8,n9,na,nb are the frames that'll be drawn}
n1:array[1..23]of string=(
'                                                    л       л',
'                                                     лл  ллл',
'                                                       лл',
'                                              лллллллллллллллл',
'                                          лллл         лл',
'                                        лл         лллл  ллл',
'                                      лл          л         л',
'                                   лллллллл',
'                                   лл    лл',
'                          лллллллллллллллллллллллллл',
'                       ллл                          ллл',
'                     лл                                лл',
'                   лл                                    лл',
'                   лл                                    лл',
'                 лл                                        лл',
'                 лл                                        лл',
'                 лл                                        лл',
'                   лл                                    лл',
'                   лл                                    лл',
'                     лл                                лл',
'                       ллл                          ллл',
'                          лллллллллллллллллллллллллл',
'');

n2:array[1..23]of string=(
'                                              л',
'                                       л    лл',
'                                        лллл',
'                                      лллллллллл',
'                                          лл',
'                                        лл  ллл',
'                                      лл',
'                                   лллллллл',
'                                   лл    лл',
'                          лллллллллллллллллллллллллл',
'                       ллл                          ллл',
'                     лл                                лл',
'                   лл                                    лл',
'                   лл                                    лл',
'                 лл                                        лл',
'                 лл                                        лл',
'                 лл                                        лл',
'                   лл                                    лл',
'                   лл                                    лл',
'                     лл                                лл',
'                       ллл                          ллл',
'                          лллллллллллллллллллллллллл',
'');

n3:array[1..23]of string=(
'',
'',
'',
'',
'',
'                                                  лл',
'                                                 л',
'                                               лл',
'                                   лл       ллл             ллллллл',
'                          ллллллллллл          ллллл    лллл',
'                       ллл                          ллл',
'                          ллллл',
'                               ллл            лл  ллллллл',
'                   ллллл л                               лл',
'                 лл                                          лллллл',
'                 лл                                        лл',
'                  лл                                     лл',
'                    лл                                  л',
'                      лллл                             л',
'                                  л                  лл',
'                л лллллллл         лл               л',
'                                     ллллллллллллллл',
'');

n4:array[1..23]of string=(
'',
'',
'',
'',
'',
'',
'                         лллл                 лллл',
'                         лллл                 лллл',
'                         лллл                 лллл',
'                         лллл                 лллл',
'                         лллл                 лллл',
'                             ллллллллллллллллллллллллл',
'                                              лллл',
'                                              лллл',
'                                              лллл',
'                                              лллл',
'                                              лллл',
'                                              лллл',
'',
'',
'',
'',
'');

n5:array[1..23]of string=(
'',
'',
'',
'',
'',
'',
'',
'                       ллл            ллл',
'                          ллл            ллл',
'                          ллл            ллл',
'                          ллл            ллл',
'                          ллл            ллл',
'                          ллл      ллл   лллллллллллл',
'                          ллл   ллл      ллл         ллл',
'                          лллллл         ллл         ллл',
'                          ллл   ллл      лллллл      ллл',
'                          ллл      ллл   ллл   лллллл',
'',
'',
'',
'',
'',
'');

n6:array[1..23]of string=(
'',
'',
'',
'                                              ллллл',
'                                   лллл     лл',
'                         ллллл         лл     лллл',
'                         лл   лл   лллллл         лл',
'                         лл   лл лл    лл    лл   лл',
'                         ллллл     лллл  лл    ллл',
'',
'             лл              ллллллл                               лл',
'             лл            лл       лл    ллллллл                  лл',
'             лл            лл       лл  лл       лл  лл  лл  лл    лл',
'             лллллллллл    лл       лл  лл       лл  лллл  лл  лл  лл',
'             лл        лл  лл       лл  лл       лл  лл    лл  лл',
'             лл        лл  лл       лл  лл       лл  лл    лл  лл  лл',
'             лл        лл    ллллллл    лл       лл  лл    лл  лл',
'             лллллллллл                   ллллллл    лл        лл',
'',
'',
'',
'',
'');

n7:array[1..23]of string=(
'',
'',
'',
'                         ллллл                лл',
'                         лл   лл   лллл     лл',
'                         лл   лл       лл     лллл',
'                         ллллл     лллллл         лл',
'                                 лллллллллл    ллл',
'',
'',
'          лл',
'          лл                                 ллллллл',
'                                                    лл  лл  лл  лл    лл',
'          лллллллллл           лл          лл       лл  лл    лл  лл  лл',
'                    лл       ллллллл       лл       лл  лл    лл  лл  лл',
'          лл        лл     лл       лл     лл       лл  лл        лл  лл',
'          лл        лл     лл       лл     лл           лл    лл  лл',
'          лллллллллл       лл       лл       ллллллл    лл        лл  лл',
'                           лл       лл',
'                           лл       лл',
'                             ллллллл',
'',
'');

n8:array[1..23]of string=(
'',
'',
'',
'                                ллллл  лл',
'                                лл   лл     л',
'                                лл     лллллл',
'                                ллллллллллллллл',
'                                        ллл',
'',
'',
'',
'                                                     ллллл',
'                                лл                      ллл лл лл',
'    лл                         лл                  лл  ллл ллл лл',
'    лл                       ллллллл               лл  ллл ллл лл',
'             лл            лл       лл             лл   лл ллл лл',
'   лллл     ллл            лл       лл             лл  ллл лл',
'   лл        лл            лл       лл               лллллллл  лл',
'        л  лл              лл       лл',
'                           лл       лл',
'                             ллллллл',
'',
'');

n9:array[1..23]of string=(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'',
'                                  л',
'                              лл   лл',
'                                ллл',
'                               лл',
'                             ллллллл',
'                           лл       лл',
'                          лл         лл',
'                         лл           лл',
'                          лл         лл',
'                           лл       лл',
'                             ллллллл',
'',
'');

na:array[1..23]of string=(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'                                                           ллллллллл',
'                                            л             л         л',
'                               л    л    л               л           л',
'                                    лл   л  л   ллллллл  л           л',
'        ллл             ллллл  л    л л  л  л      л      л          л',
'                        л      лл   л  л л  лл     л       лллллл   л',
'                        ллл         л   лл                       ллл',
'                        л           л    л',
'',
'',
'',
'',
'',
'');

nb:array[1..23]of string=(
'',
'',
'',
'',
'',
'',
'',
'',
'',
'                                                           ллллллллл',
'                                            л             л         л',
'             л                 л    л    л               л           л',
'             лл                     лл   л  л   ллллллл  л           л',
'         лллллллллл     ллллл  л    л л  л  л      л      л          л',
'             лл         л      лл   л  л л  лл     л       лллллл   л',
'              л         ллл         л   лл                       ллл',
'                        л           л    л',
'',
'',
'',
'',
'',
'');


var i,x,y:byte;

procedure drawscreen(dataz:array of string); {draws a frame (asciipic)}
begin                                        {with some blur and error-stuff}
  for y:=1 to 23 do for x:=1 to 79 do        {and all the shit...}
  for i:=1 to 10 do
    if ord(dataz[y,x])=219 then
      mem[$a000:(40+y*5+i)*160+x]:=(50+mem[$a000:(40+y*5+i)*160+x]+random(15)) shr 1
        else mem[$a000:(40+y*5+i)*160+x]:=(0+mem[$a000:(40+y*5+i)*160+x]+random(15)) shr 1;
  for i:=1 to 5 do
    asm
      hlt                                    {this is used for the delay}
    end;
  for y:=1 to 23 do for x:=1 to 79 do
  for i:=1 to 10 do
    if ord(dataz[y,x])=219 then
      mem[$a000:(40+y*5+i)*160+x-1]:=(50+mem[$a000:(40+y*5+i)*160+x-1]+random(15)) shr 1
        else mem[$a000:(40+y*5+i)*160+x+1]:=(0+mem[$a000:(40+y*5+i)*160+x+1]+random(15)) shr 1;
  for i:=1 to 5 do
    asm
       hlt
    end;
end;

begin
  asm                           {setting up my 80x400 mode goes like this..}
    mov ax,13h
    int 10h
    mov dx,03c4h
    mov ax,0604h
    out dx,ax
    mov dx,03d4h
    mov ax,09h
    out dx,ax
    mov ax,014h
    out dx,ax
    mov ax,0e317h
    out dx,ax
    mov ax,0a000h
    mov es,ax
    xor di,di
    xor ax,ax
    mov cx,32000
    rep stosw
  end;
  for y:=0 to 63 do     {setting up palette}
  begin
    port[$3c8]:=y;      
    port[$3c9]:=0;
    port[$3c9]:=y;
    port[$3c9]:=y div 2;
  end;
  drawscreen(n1);       {just draw the frames}
  drawscreen(n2);       
  drawscreen(n3);      
  drawscreen(n4);
  drawscreen(n5);
  drawscreen(n6);
  drawscreen(n7);
  drawscreen(n8);
  drawscreen(n9);
  drawscreen(n2);
  drawscreen(n3);
  drawscreen(n7);
  drawscreen(n6);
  drawscreen(n7);
  drawscreen(n6);
  drawscreen(na);
  drawscreen(nb);
  drawscreen(na);
  drawscreen(nb);
  drawscreen(na);
  asm                   {textmode (3h) on again}
    mov ax,03h
    int 10h
  end;
end.
