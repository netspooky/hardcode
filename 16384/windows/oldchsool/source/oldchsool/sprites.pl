#!/usr/bin/perl
##!/opt/bin/perl5

#   color=>grayscale palettes:
#
#   0x00,0x08,0x80,0x88,0x87,0x78,0x77,0x7f,0xf7,0xff

###########################

$spritz="sprite*allbmps[]={";

$wrct=0;
sub wr
{
   printf("0x%x,",$_[0]);
   $wrct+=5;
   if($wrct>=70){printf("\n");$wrct=0;}
}

sub wrrle
{
   my ($ch,$cnt)=($_[0],$_[1]);

   if($cnt==0){return;}
   
   $z=-1;
   for($i=0;$i<7;$i++){if($cpal[$i] eq $ch){$z=$i;}}

   if($z==-1)
   {
      $cpal[$cpalidx]=$ch;
      $cpalidx++;
      if($cpalidx==7){$cpalidx=0;}
      wr((7<<5)|$cnt);
      if($pal{ord($ch)} eq '') { print "/* ERROR - $ch */"; }
      print $pal{ord($ch)}.",";
      $sz+=3;
   }
    else
   {
      wr(($z<<5)|$cnt);
      $sz++;
   }
}

sub bitmap
{
   $bmpname=$_[0];
   $sz=0;

   @colors=split('/',$_[1]);
   foreach(@colors)
   {
      ($ch,$col,$msk)=split(':',$_);
      $pal{ord($ch)}="0x".$col.",0x".$msk;
   }

   @lines=split("\n",$_[2]);
   $xdim=0;$ydim=0;

   foreach(@lines)
   {
      if(length($_)>$xdim) { $xdim=length($_); }
   }

   print "u8*".$bmpname."_pict,".$bmpname."_mask;\n";
   print "u8 ".$bmpname."_cmpr[]={\n";
   $ydim=0;

   @cpal=('å','å','å','å','å','å','å');$cpalidx=0;
   $repch="å";$repcnt=0;
   foreach(@lines)
   {
      for($x=0;$x<$xdim;$x++)
      {
         $ch=substr($_,$x,1);
         if($ch eq "") { $ch=" "; }

         if($ch eq $repch)
         {
            $repcnt++;
            if($repcnt==31){$repcnt=0;wrrle($repch,31);}
         }
          else
         {
            wrrle($repch,$repcnt);
            $repch=$ch;$repcnt=1;
         }
      }
      $ydim++;
   }
   wrrle($repch,$repcnt);
   print "};\n";
   print "sprite $bmpname ={ $xdim,$ydim,(char*)$sz,$bmpname"."_cmpr};\n\n";

   $spritz .= '&'.$bmpname.',';
}

&bitmap('oldsk',' :00:ff/o:88:00/;:67:00/b:78:00/x:ff:00',<<EOD);
        ;;;;;;
      bbb;;;;;;
     bbbb;;;;;;b;
 ;  b;;;;;;;;;bbb;  ;
;;;;;xxxxxx;;;;;;;;;;;;
;;;;;x;;;;x;xxxxxx;;;;
;;;; x;xx;x;x;;;;x;;;
 ;;  x;;;;x;x;xx;x;;
     xxxxxx;x;;;;x
       ;;;;;xxxxxx
      ;;;;;;;;;;
     bbb;o;o;;bbb
     bbbbbbbbbbbbb
      bbbbbbbbbb
       bbbbbbbbb
       bbbbbbbb
        bb bbbb
        bb bbb
           bb
           b
EOD
# ppppppppppppp  ppppp         ppppp  pppppppppppppp
# ppppppppppppp  ppppp         ppppp  pppppppppppppp
# ppppp   ppppp  ppppp         ppppp  ppppp    ppppp
# ppppp   ppppp  ppppp         ppppp  ppppp    ppppp
# ppppppppppppp  ppppp   ppp   ppppp  pppppppppppppp
# ppppppppppppp  ppppp   ppp   ppppp  pppppppppppppp
# ppppp          ppppp   ppp   ppppp  ppppp
# ppppp          ppppppppppppppppppp  ppppp
# ppppp          ppppppppppppppppppp  ppppp
#
&bitmap('bdash0',' :00:ff/b:44:00/*:77:00/b:6e:00/w:55:00',<<EOD);


      wwww
    wwwwwwww
  ww  wwwwww
  ww  wwwwww
    wwwwww
      wwww
      ****
    **wwww
      ****
    bbwwwwbbbb
  bb          ww
  bb          ww
wwww

EOD
&bitmap('bdash1',' :00:ff/b:44:00/*:77:00/b:6e:00/w:55:00',<<EOD);


    wwww
  wwwwwwww
ww  wwwwww
ww  wwwwww
  wwwwww
    wwww
    ****
  **wwww
    ****
  bbwwwwbb  
  bb    bb
  bb    bbww
wwww      ww

EOD
&bitmap('bdash2',' :00:ff/b:44:00/*:77:00/b:6e:00/w:55:00',<<EOD);



      wwww
    wwwwwwww
  ww  wwwwww
  ww  wwwwww
    wwwwww
      wwww
      ****
    **wwww
      ****
      wwww
      bbbb
      bbbbww
    wwww  ww

EOD
&bitmap('bdash3',' :00:ff/b:44:00/*:77:00/b:6e:00/w:55:00',<<EOD);



      wwww
    wwwwwwww
  ww  wwwwww
  ww  wwwwww
    wwwwww
      wwww
      ****
    **wwww
      ****
      wwww
    bbbbbbbb
    bbbbbb  ww
  wwww      ww

EOD
&bitmap('bdash4',' :00:ff/b:44:00/*:77:00/b:6e:00/w:55:00',<<EOD);


    ww    ww
    ww    ww
  ww  wwww  ww
  ww  wwww  ww
    wwwwwwww
      wwww
    wwwwwwww
  ww  ****  ww
  **  wwww  **
      ****
      wwww
    bb****bb
    bb    bb
    ww    bb
  wwww    wwww
EOD
&bitmap('brick0',' :00:00/w:93:00/*:77:00',<<EOD);
wwwwwwwwwwwwwwww
wwwwwwwwwwwwwwww
ww    wwww    ww
wwww  wwwwww  ww
ww**  wwww**  ww
wwwwwwwwwwwwwwww
wwwwwwwwwwwwwwww
wwwwwwwwwwwwwwww
wwwwwwwwwwwwwwww
wwwwwwwwwwwwwwww
wwwwwwwwwwwwwwww
ww    wwww    ww
wwww  wwwwww  ww
ww**  wwww**  ww
wwwwwwwwwwwwwwww
wwwwwwwwwwwwwwww
EOD
&bitmap('brick1',' :00:00/w:ff:00/*:77:00/x:88:00',<<EOD);
www   wwwwwwwwww
**x   ww********
*xx   ww*xxx**xx
                

wwwwwwwwww   www
*********w   ww*
xx*xx**xxx   ww*
                

wwwwww   wwwwwww
*****x   ww*****
*****x   ww*****
*xx*xx   ww*xxx*


EOD
&bitmap('pelush1',' :00:ff/r:44:00/Y:66:00/y:38:00/.:11:00/W:77:00',<<EOD);
   yyyyyyyy
      yy
  rrrrrrrrr
 rrrrrrrrrrrrrr
 YYYYYY.....
WWWWWW...WW.
WWWWWWW.....
WWWWWWWWWWWW
WWWWWWWWWWWWWW
WWWWWWWWWWWWWWWW
WWWWWW
WWWWWWWW
WWWWWWWWWWW  rr
 WWWWWWWWWWWWWW
  WWWWWWWWWW
    WWWWWW
EOD
&bitmap('pelush0',' :00:ff/r:44:00/Y:66:00/y:38:00/.:11:00/W:77:00',<<EOD);
    yyyyyy
      yy
  rrrrrrrrr
 rrrrrrrrrrrrrr
 YYYYYY.....
WWWWWW...WW.
WWWWWWW.....
WWWWWWWWWWWW
WWWWWWWWWWWWWW
WWWWWWWWWWWWWWWW
WWWWWW
WWWWWW
WWWWWWW
 WWWWWWW     rr
 WWWWWWWWWWWWWW
  WWWWWWWWWWW
EOD
&bitmap('pelush2',' :00:ff/r:44:00/Y:66:00/y:38:00/.:11:00/W:77:00',<<EOD);
    yyyy
     yy
  rrrrrrrr
 rrrrrrrrrrrrr
 YYYYYYYYYY
WWWWW......
WWWWWWWWWWW
WWWWWWWWWWW
WWWWWWWWWWWWW
WWWWWWWWWWWWWWW
WWWWW
WWWWWWWWWWWWWWW
WWWWWWWWWWWWWW
 WWWWWWWWWWW
  WWWWWWW
 
EOD
&bitmap('boulder','.:00:ff/x:33:00/y:37:00/;:88:00',<<EOD);
................
......xxxxx.....
.....xxxxxxx....
....xxxyyyyxx...
...xxxxxxxyxx...
...;xxxxxxyyyx..
..xxxxxxxxxxyx..
..xxxxxxxxxxxxx.
.xxxxxxxxxxxxxx.
.xxxxxxxxxxxxxx.
.;xxxxxxxyxyxyx.
.;xxxxxxxxyxyx..
..;xxxxxxxxyxy..
..;xxxxxxxyxy...
...;xxxxxxxyx...
....;xxxxxxx....
EOD
&bitmap('splat0',' :00:ff/b:44:00/B:4c:00',<<EOD);



          bb
  
      bbbbb
 bb   bb 
     bbbbb
   bbBBBBBbb
   bbBBBBBBbb b
    bbbbbbbb b
   bbbbbbbb
     bbbb
  bbbb

bb
EOD
&bitmap('splat1',' :00:ff/b:44:00/B:cc:00',<<EOD);
bbbb

    bbb
     bbbbbb
    bbbbbbb
   bbbbbbbbb
 bbBbbbBbbbb
  bbbbbbBbbbb
  bbbBBBBBbbbb
  bBBBBBBBBbbbb
  BbBBBBBbbbb
 bbbbBBBbbbb
 bbbbbbbbbb
  bbbbbbbb


EOD
&bitmap('splat2',' :00:ff/b:4c:00/B:ce:00/x:ee:00',<<EOD);
   bbbbbb
  bbbbbxbbb
 bbbbbbbbbbb
 bbbbbbxBBbbb
 bbbbBBxBBbbb
bbbbBBBxBbbbbb
bbbxBBxxxbbxbb
bxbxBxxxbbbxb
bbbbbBBxBBbbbb
bbbBBBBxBBBbbbb
 bBbBBBxBbbbb
 bbbbBBBbbbbb
 bbbbbbbbbbb
  bbbbbxbb
    bbbb
EOD
&bitmap('splat3',' :00:ff/b:6e:00/B:66:00/x:ee:00',<<EOD);
   bbbbbb
 bbbbbbbbbb
bbbbbbbbbbbbb
bbbbbb  BBbbbb
bbbb     b bbb
bbbb      bbbb
bbbx      bxbb
bxb       bbxb
bbbb       bbb
bbbBB    bbbbb
bbBbBBBxBbbbbb
bbbbbbbbbbbbb
 bbbbbbbbbbb
  bbbbbxbb
    bbbbb
EOD
&bitmap('splat4',' :00:ff/b:40:00/x:04:00',<<EOD);
   bbb bb
 b  bb bb 
bbb       bb
         b  
bb      b bbb
bb          bb
           bb
              
b           bb
  b       bbb
b  b  b    bb
bbbb    bb bb
      bbbb
  bbbbbxbb
    bbbbb
EOD
&bitmap('tietzka',' :00:ff/*:77:ff/B:99:ff/w:66:ff/!:ff:ff',<<EOD);


 ********
 *BBBBBB*  
 *BBBBBB* **** 
 *BBBBBB* *!!*
 ******** ****
  ******  ****
   ****   ****
wwwwwwwwwwwwwww
 wwwww  wwwww
  www    www
  www    www
EOD


&bitmap('pelu','n:44:00/-:00:ff/ :00:ff/@:87:00/.:11:82/x:44:00/Z:e6:00/o:ff:00',<<EOD);
--------------------------------
          nnnnnnnnnnn
              nn
              nn
     xxxxxxxxxxxxx
         xxxxxxxxxx
         ....ZZZZZZ
         .....@@@@@
         .o...@@@@@
         ....@@@@@@@
         @@@@@@@@@@@
       @@@@@@@@@@@@@
     @@@@@@@@@@@@@@@
              @@@@
     xx    @@@@@@@
     @@@@@@@@@@@@@
       @@@@@@@@@@@
         @@@@@@@@@
         @@@@@@@@@
           @@@@@@
            @@@@@
             @@@@
EOD

print <<JOOH;
void decompress_bitmap(u8*dpic,u8*dmask,u8*s,int count)
{
   u8 pal[7],palm[7],palidx=0;
   u8 col,msk,rep,*s1=s+count;

   while(s<s1)
   {
      u8 a=*s++;

      rep=a&31;
      col=a>>5;
      
      if(col==7){pal[palidx]=col=*s++;palm[palidx]=msk=*s++;palidx++;if(palidx==7)palidx=0;}
            else{msk=palm[col];col=pal[col];}

      if(rep)
      for(;rep;rep--){*dpic++=col;*dmask++=msk;}
   }
}
JOOH

print $spritz,"NULL };\n";

print <<JOOH2
void decompress_allbmp()
{
   u8*d,*d2;
   sprite**s=allbmps;
   while(*s)
   {
      d=malloc((*s)->width*(*s)->height*sizeof(u8));
      d2=malloc((*s)->width*(*s)->height*sizeof(u8));
      decompress_bitmap(d,d2,(*s)->mask,(int)((*s)->pict));
      (*s)->pict=d;
      (*s)->mask=d2;
      s++;
   }
}
JOOH2
