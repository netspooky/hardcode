#include <stdio.h>
#include <stdlib.h>

/* no tehdään seellä sitten perkele kun ei perli osaa toimia loogisesti
*/

unsigned char tab[256][4];

sprite(unsigned const char*name,
       unsigned const char*cols,
       unsigned const char*data)
{
   int height=0,width=0;
   
   {unsigned const char*s=data;int thiswidth=0;
   while(*s)
   {
      if(*s=='\n')
      {
         if(thiswidth>width)width=thiswidth;
         height++;
         thiswidth=0;
      }
       else thiswidth++;
      s++;
   }}

   {unsigned char*s=cols;
    while(*s)
    {
       int c=s[0];
       tab[c][0]=s[1];
       tab[c][1]=s[2];
       tab[c][2]=s[3];
       tab[c][3]=s[4];
       s+=6;
    }
   }

   
   printf("u8 %s_pict[]={\n",name);
   
   {unsigned const char*s=data;int thiswidth=0;
   while(*s)
   {
      if(*s=='\n')
      {
         while(thiswidth<width)
         {
            printf("0x%c%c,",tab[32][0],tab[32][1]);
            thiswidth++;
         }
         thiswidth=0;
         printf("\n");
      }
       else
      {
         thiswidth++;
         printf("0x%c%c,",tab[*s][0],tab[*s][1]);
      }
      s++;
   }}
   
   printf("};\nu8 %s_mask[]={\n",name);

   {unsigned const char*s=data;int thiswidth=0;
   while(*s)
   {
      if(*s=='\n')
      {
         while(thiswidth<width)
         {
            printf("0x%c%c,",tab[32][2],tab[32][3]);
            thiswidth++;
         }
         thiswidth=0;
         printf("\n");
      }
       else
      {
         thiswidth++;
         printf("0x%c%c,",tab[*s][2],tab[*s][3]);
      }
      s++;
   }}

   printf("};\n");
   printf("sprite %s={\n%d,%d,%s_pict,%s_mask};\n\n",name,width,height,name,name);
}

const unsigned char*thoho[]={


"windows1"," 00ff b1900 Wff00 #7700 X77ff x6600 f1900 b0800 B0000 h6608 Wfe00","
         hhhhhh
        ########
        ########
        ########
        #bb##bb#
        #bb##bb#
        ########
       ##########
      #####  #####
      #####  #####
      #####  #####    
       ####  ####    
        ########    
          ####     
          ####    
          x##x   
      ###xxxxxx###
     ###xxxxxxxx###
    ### xWxxxxWx ###
   ###  xWxWWxWx  ###
  ###   xWWWWWWx   ###
 ###    xxxxxxxx    ###
 ###    xxxxxxxx    ###
        ffffffff
        bbbbbbbb
        ffffffff
        fff  fff
       fff    fff
       fff    fff
       fff    fff
       fff    fff
        fff  fff
        fff  fff
      BBBBB  BBBBB
     BBBBBB  BBBBBBB
",

"quake0"," 00ff n7700 x4400 .1100 off00 @7700",
"     nnnnnnnnnnn
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
      @@@@@@@
      @@@@@@@
      @@@@@@@
       @@@@@
       @@@@@
@@@@@@@@@@@@
",

"windows0"," 00ff b1900 Wff00 #7700 X77ff x6600 f1900 b0800 B0000 h6608 Wfe00","
         hhhhhh
        ########
        ########
        ########
        #bb##bb#
        #bb##bb#
        ########
       ##########
      ############
      ####    ####
###   ####    ####   ###
###    ##########    ###
 ###    ########    ###
  ###     ####     ###
   ###    ####    ###
    ###   x##x   ###
     ####xxxxxx####
      ##xxxxxxxx#
        xWxxxxWx
        xWxWWxWx
        xWWWWWWx
        xxxxxxxx
        xxxxxxxx
        ffffffff
        bbbbbbbb
        ffffffff
        fff  fff
        fff  fff
        fff  fff
        fff  fff
       fff    fff
       fff    fff
       fff    fff
     BBBBB    BBBBB
    BBBBBB    BBBBBBB
",


"army0"," 00ff h6e80 +0000 Wff00 #7700 X2200 x2200 f2b00 b8800 B0600 w8700","
         h#h#h#h
         #######
         #######
         #######
         ++####
         ++###
        ########
       ##########
      ###########
           #####
      ##########
       ########
        #######
         ##### 
          ###
         XX##x
         Xxxxx
wwwwwwwwwwwwwwwww
        xxx####ww
        xx###wwww
        xxxxxxx
        xxxxxxx
         xxxxx
         fffff
         bbbbb
         fffff
         fffff 
         ffff  
         fff 
         fff
         fff
         fff
         fff
       BBBBB
      BBBBBB
",



"tesno0"," 00ff +0000 Wff00 #7700 X77ff x6600 f1900 b0800 B0000 h6608","
         h h h h
         h h h h
         h#h#h#h
         #######
         #######
         #######
         ++####
         ++###
        ########
       ##########
      ###########
         WWWW###
            ####
       ########
        #######
         #####    ####
  ###     ###    #### 
   ###   XX##x ####
     ##  Xxxxx####
      ##xxxxxxx#
       #####xxx
        ####xxx
        xxxxxxx
        xxxxxxx
         xxxxx
         fffff
         bbbbb
         fffff
         fffff 
         ffff  
         fff 
         fff
         fff
         fff
         fff
       BBBBB
      BBBBBB
",

"tesno1"," 00ff +0000 Wff00 #7700 X77ff x6600 f1900 b0800 B0000 h6608","
        hh h h  
         h h h hh
         h#h#h#h
         #######
         #######
         #######
         ++####
         ++###
        ########
       ##########
      ###### ####
             ###
       #########
        #######
         ######
          ####   
          ### 
         XX##x 
         Xxxxx#
        xxxxxxx#
        ####xxx##
     #######xxx###
  ######xxxxxxx ###
  ###   xxxxxxx  ###
         xxxxx
         fffff
         bbbbb
         fffff
         fffff 
         ffff  
         fff 
          fff
          fff
         fff
      BBBBB
     BBBBBB
",



"uusmed0"," 00ff +0000 Wff00 #7700 X77ff x6600 f1900 b0800 B0000 h6608","
         h h h h
         h h h h
         h#h#h#h
         #######
         #######
         #######
         ++####
         ++###
        ########
       ##########
      ###########
         WWWW###
            ####
       ########
        #######
         ##### 
  ###     ###
   ###   XX##x
     ##  Xxxxx
      ##xxxxxxx
       #####xxx
        ####xxx
        xxxxxxx
        xxxxxxx
         xxxxx
         fffff
         bbbbb
         fffff
         fffff 
         ffff  
         fff 
         fff
         fff
         fff
         fff
       BBBBB
      BBBBBB
",


"uusmed1"," 00ff +0000 Wff00 #7700 X77ff x6600 f1900 b0800 B0000 h6608","
         h h h h
         h h h h
         h#h#h#h
         #######
         #######
         #######
         ++####
         ++###
        ########
       ##########
      ###########
       WWWWWW###
            ####
       WWWWW###
      #########
       ####### 
         ####
         XX##x
  ##     Xxxxx
  ####  xxxxxxx
    ########xxx
      ######xxx
        xxxxxxx
        xxxxxxx
         xxxxx
         fffff
         bbbbb
         fffff
         fffff 
         ffff  
         fff
         fff
         fff
         fff
         fff
       BBBBB
      BBBBBB
",





"ruumis"," 00ff a4400 s4c00 d4400","
          asdasd
         asdsadsad
          asdsad
           asda
        adsdsadas
      asdsdasdadas
      dasdasdasdsa
      sadasddas
       asddasdasdas
      asdasddasasd
       asdasddasdas
      asddasdas
       asddasdasdas
        sadsdadas
         adsdaads
          asds
",


"pelustna1"," 00ff n8800 x4400 Z6600 .1133 o77ff @7f00 x4408 r4400 z0888 b8c01 +6600",
"       nnnn    
        nnnn    
         nn              
         nn              
      xxxxxxxxxxxx       
      xxxxxxxxxxxxxxxxxxx
     xxxxxxxxx           
     ZZZZZ....           
    ZZZZZ.....           
    ZZZZZZ..o.           
   ZZZZZZZ....           
   ZZZZZZZ@@@@           
   ZZZZZZZ@@@@@@         
   ZZZZZZZ@@@@@@@@       
   ZZZZZ Z               
   ZZZZZ@ZZ              
  ZZ@Z@Z@@@@@@  xx       
    @@@@@@@@@@@@@@       
     @@@@@@@@@@@  bb
     @@@@@@@@@  bbbbbbb
       @@@@@    bbbbbbbb
       @@@@      b++bbbb
       @@@@      +++bbb
      @@@@@@    +++bbb
      @@@@@@@   ++ bb 
     @@@@@@@@@@@@ 
     @@@@@@@@@@@+ 
     @@@@@@@@ ++  
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
      @@@@@@
      @@@@@@    
      @@@@@@     
       @@@@      
       @@@@      
       @@@@        ",


"pelustna0"," 00ff x4400 Z6600 .1133 o77ff @7f00 x4408 r4400 z0888 b8c01 k6600 n8800",
"     nnnnnnnnnn
     nn nnnn nn
         nn              
         nn              
      xxxxxxxxxxxx       
      xxxxxxxxxxxxxxxxxxx
     xxxxxxxxx           
     ZZZZZ....           
    ZZZZZZ....           
    ZZZZZ...o.           
   ZZZZZZZ....           
   ZZZZZZZ@@@@           
   ZZZZZZZ@@@@@@         
   ZZZZZZZ@@@@@@@@       
   ZZZZZ Z               
   ZZZ@Z@Z               
    ZZ@@@@@@@@  xx       
    @Z@@@@@@@@@@@@       
     @@@@@@@@@@@   
     @@@@@@@@@    bbbb
       @@@@@    bbbbbb
       @@@@  bbbbbbbbb
       @@@@    bbkbbbb
      @@@@@@    kkbbbb
      @@@@@@@   kk
     @@@@@@@@@@@@k
     @@@@@@@@@@@kk
     @@@@@@@@   kk
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
      @@@@@@
      @@@@@@    
      @@@@@@     
       @@@@      
       @@@@      
       @@@@        ",




"pelusieni2"," 00ff n8800 x4400 Zee00 .1133 o77ff @7f00 x4408 r4400 z0888 b6601",
"     nnnnnnnnnn
     nn nnnn nn
         nn              
         nn              
      xxxxxxxxxxxx       
      xxxxxxxxxxxxxxxxxxx
     xxxxxxxxx           
     ZZZZZ....           
    @@@@......           
    @@@@....o.           
   @@@@@@@....           
   @@@@@@@@@@@           
   @@@@@@@@@@@@@         
   @@@@@@@@@@@@@@@       
    @@@@rrrrr              
    @@@@@@rorr            
    @@@@@@@@rr               
    @@@@@@@@@@@@            
     @@@@@@@@@@  
     @@@@@@@@@           
       @@@@@      @@
       @@@@      @@@@
       @@@@     @@@@
      @@@@@@  @@@@@
      @@@@@@@@@@@
     @@@@@@@@@@@
     @@@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
      @@@@@@
      @@@@@@            rrrr
      @@@@@@           rrorrr
       @@@@           rrrrrrr
       @@@@             bbb
       @@@@            bbbb",


"pelusieni1"," 00ff n8800 x4400 Zee00 .1133 o77ff @7f00 x4408 r4400 z0888 b6601",
"     nnnnnnnnnn
     nn nnnn nn
         nn              
         nn              
      xxxxxxxxxxxx       
      xxxxxxxxxxxxxxxxxxx
     xxxxxxxxx           
     ZZZZZ....           
    @@@@......           
    @@@@....o.           
   @@@@@@@....           
   @@@@@@@@@@@           
   @@@@@@@@@@@@@         
   @@@@@@@@@@@@@@@       
    @@@@           rrrrr
    @@@@@@       rrrrorrr
    @@@@@@@@    rorrroorrr
    @@@@@@@@@@ rrrrorrrorrr
     @@@@@@@@@@@@rrzbbbbr
     @@@@@@@@@      bbbb
       @@@@@        bbbb
       @@@@        @@@bb
       @@@@      @@@@bb
      @@@@@@    @@@
      @@@@@@@ @@@@
     @@@@@@@@@@@@
     @@@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
     @@@@@@@@
      @@@@@@
      @@@@@@            rrrr
      @@@@@@           rrorrr
       @@@@           rrrrrrr
       @@@@             bbb
       @@@@            bbbb",



"sieni"," 00ff r4400 0ff00 -8700",
"
        rrrrr
     rrrrrrrrrrr
   rrrrrrr00rrrrrr
  rrrrr00rrrrrrrrrrr
 rrrrrrr0rrrrr0rrrrrr
 rrrrrrr0rrrrr00rrrrr
rrr0rrrrrrrrrrrrr00rrr
rrr00r0rrrr00rrrrr0rrrr
 rrrrrrrrrrrrrrrrrrrr
 rrrrrrrrrrrrrrrrrrrr
  rrrrrrr---rrrrrrr
   rrrr ------rrrrr
        ------
        -----
        ------
        -----
         -----
         ----
",



"kuusi"," 00ff *0000 b0000 d0600 +0200 x0201 #2002","
      *
     ***
    x****
    ******
   **+****x
  x**+*****
  **++******
 *#+*#**++***
 x********** 
   ***d***+*
     bbbb
     bbbb
+   bbbbbbd",


"pelux"," 00ff n8800 x4400 Zee00 .1133 o77ff @7f00 x4408 r4400 z0888 b6601",
"     nnnnnnnnnn
     nn nnnn nn
         nn
         nn
      xxxxxxxxxxxx 
      xxxxxxxxxxxxxxxxxxx
     xxxxxxxxx 
     ZZZZZ....   
    @@@@......    
    @@@@....o.   
   @@@@@@@....   
   @@@@@@@@@@@    
   @@@@@@@@@@@@@    
   @@@@@@@@@@@@@@@       
    @@@@                 
    @@@@@@               
    @@@@@@@@@@  xx       
    @@@@@@@@@@@@@@       
     @@@@@@@@@@@         
     @@@@@@@@@           
 @@@   @@@@@  @@@
  @@@  @@@@  @@@
   @@@ @@@@ @@@
    @@@@@@@@@@
     @@@@@@@
      @@@@@
       @@@@
       @@@@
       @@@@
      @@@@@@
     @@@  @@@ 
    @@@    @@@ 
   @@@      @@@
  @@@        @@@
 @@@          @@@
@@@            @@@
",


"peluface0"," 00ff n8800 x4400 Zee00 .1133 o77ff @7f00 x4408","
   nnnnnnnnnn
   nn nnnn nn
       nn
       nn
    xxxxxxxxxxxx 
    xxxxxxxxxxxxxxxxxxx
   xxxxxxxxx 
   ZZZZZ....   
  @@@@......    
  @@@@....o.   
 @@@@@@@....   
 @@@@@@@@@@@    
 @@@@@@@@@@@@@    
 @@@@@@@@@@@@@@@       
  @@@@                 
  @@@@@@               
  @@@@@@@@@@  xx       
  @@@@@@@@@@@@@@       
   @@@@@@@@@@@         
   @@@@@@@@@           
     @@@@@             
     @@@@              
     @@@@",

"peluface1"," 00ff n8800 x4400 Zee00 .1133 o77ff @7f00 x4408","
     nnnnnn
    nnn  nnn
       nn  
       nn              
    xxxxxxxxxxxx
    xxxxxxxxxxxxxxxxxxx
   xxxxxxxxx          
   ZZZZZ....           
  @@@@......           
  @@@@....o.           
 @@@@@@@....           
 @@@@@@@@@@@           
 @@@@@@@@@@@@@         
 @@@@@@@@@@@@@@@       
  @@@                 
  @@@@@               
  @@@@@@@@   xx       
  @@@@@@@@@@@@@@       
   @@@@@@@@@@@         
   @@@@@@@@@           
     @@@@@             
     @@@@              
     @@@@",

"peluface2"," 00ff n8800 x4400 Zee00 .1133 o77ff @7f00 x4408","
      nnnn          	
      nnnn          
       nn              
       nn              
    xxxxxxxxxxxx       
    xxxxxxxxxxxxxxxxxxx
   xxxxxxxxx           
   ZZZZZZ...           
  @@@@......           
  @@@@....o.           
 @@@@@@@....           
 @@@@@@@@@@@           
 @@@@@@@@@@@@@         
 @@@@@@@@@@@@@@@       
  @@@@                 
  @@@@@@               
  @@@@@@@@@@  xx       
  @@@@@@@@@@@@@@       
   @@@@@@@@@@@         
   @@@@@@@@@           
     @@@@@             
     @@@@              
     @@@@",



"krist0"," 00ff #7700 x1900 h1300 z6e00 n8800 +0000 b6600 I4488 *e6ff","
                     ######
                    #######
                    #######
                    #######
                     I#####
                    ######
           #       ########
           #      ##########
         ###     ###########
         ###            ####
       ######            ###
           ###      ########
            ###     #######
             ###      ##### 
  nnnnnn      ####   xxxxhhh
 nnnnnnnn      #####xxxhhhhh
 nnn++nnn        ###hxx##h#x
 n++++++n           x####xxx
 nnn++nnn           ####xxxx
 nnn++nnn         #####xxxxx
 nnn++n##############xxxxxxx
 nnnnnnnn###########xxxxxxxx
 nnnnnnn####        **zzzzzz
  nnnnnn            **zzzzzz
                    xxxxxxxxx
                    xxxxxxxx
                     xxxxxxxx
                     xxxxxxxx 
                       hhh
                       hhh
                       hhh
                       hhh
                       bbb
                       bbb
                       bbb
                     bbbbb
                   bbbbbbb
                  bbbbbbbb
",

"krist1","#7700 x1900 h1300 z6e00 n8800 +0000 b6600 I4488"," 

                     ######
                    #######
                    #######
                    #######
                    II#### 
             #        #### 
             #     ########
           ###    ##########
           ###   ###########
           ###          ####
           ###           ###
            ###         ####
             ###   ########
  nnnnnn      ###   ####### 
 nnnnnnnn      ###   xxxhhh 
 nnn++nnn       ####xxxhhhhh
 n++++++n        ###hx###h#x
 nnn++nnn           #####xxx
 nnn++nnn         #####xxxxx
 nnn++n###############xxxxxx
 nnnnnnnn############xxxxxxx
 nnnnnn######       xxxxxxxx
  nnnnnn            **zzzzzzz
                    **zzzzzz
                    xxxxxxxxxx
                    xxxxxxx 
                     xxxxxxxx
                     xxxxxxxxx
                       hhh
                       hhh
                       hhh
                       hhh
                       bbb
                       bbb
                       bbb
                     bbbbb
                   bbbbbbb
                  bbbbbbbb
",


NULL,NULL,NULL
};




int main()
{
   char**s=thoho;
   
   int i=0;
   for(;i<256;i++){tab[i][0]=tab[i][1]='0';tab[i][2]=tab[i][3]='f';}
   
   while(*s!=NULL)
   {
      sprite(s[0],s[1],s[2]);s+=3;
   }
   return 0;
}



/*

"pelu0","n8800 x4400 Zee00 .1133 o77ff @7f00 x4408 X3900","
   nnnnnnnnnn          	
   nn nnnn nn          
       nn              
       nn              
    xxxxxxxxxxxx       
    xxxxxxxxxxxxxxxxxxx
   xxxxxxxxx           
   ZZZZZ....           
  @@@@......           
  @@@@....o.           
 @@@@@@@....           
 @@@@@@@@@@@           
 @@@@@@@@@@@@@         
 @@@@@@@@@@@@@@@       
  @@@@                 
  @@@@@@               
  @@@@@@@@@@  xx       
  @@@@@@@@@@@@@@       
   @@@@@@@@@@@         
   @@@@@@@@@           
     @@@@@             
     @@@@              
     @@@@
     XXXX
    XXXXXX
   XXXXXXXX
   XXXXXXXX
   XXXXXXXX
   XXXXXXXX
   XXXXXXXX
   XXXXXXXX
   XXXXXXXX
   XXXXXXXX
   XXXXXXXX
    XXXXXX
    XXXXXX
     XXXX
     XXXX
     XXXX
     XXXX
     XXXXXX
     XXXXXXXXX


!kirves h:6600 X:7800 #:7700

       hh
      hhhh  
     XhhhhXXXXX
    XXhhhhXXXXX
  XXXXXXXXXXXXX
 XXXXXhhhhXXXXX
XXXXXXXXhhXXXX 
   XXXXhhhXXXXX
 XXXXXhhhhXXXXX
XXXXXXhhhhXXXXX
      hhhh
      hhhh
      hhhh
   ########
  ##########
  #########
  ###########
     ######
      hhhh
      hhhh
      hhhh




           h
           h h h
           h h h h
           hhhhhhh
           ffffffff
          +++ffffff
          +++++++ff
          +++ffffff
         ffffffffff
        fffffffffff
           WW fffff
               ffff
          ffffffff
           ffffff
            ffff
            ffff
        

            
            
            
            



               n
              nnn
               n
               n
               n
              rrr
             rrrrr
            rrrrrrr
           rrrrrrrrr
          rrrrrrrrrrr
          rrrrrrrrrrr
          rrrrrrrrrrr
          rrrrrrrrrrr
          rrrrrrrrrrr
          rrrrrrrrrrr
          rrrrrrrrrrr
          rrrrrrrrrrr
            
            
                           
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            

*/            