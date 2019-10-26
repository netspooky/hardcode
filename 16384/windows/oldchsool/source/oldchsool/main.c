#if 0
# include <stdio.h>
# include <stdlib.h>
# include <string.h>
# include <unistd.h>
#endif

#include "pwplib.h"

#define MAX(a,b) ((a)<(b)?(b):(a))
#define MIN(a,b) ((a)>(b)?(b):(a))

struct
{
   int dsgtime;

   int flagz;
   int planemode;
   
   int enctime,enckode,enczoom,encspeed;

   int endfxt;
   
   int metsaemode;
   int bouncemode;
}demovar;

#define Z 128
#define z 128
#define K 19

u8 pwplogofield[16*16] = {
3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
3,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,
3,3,3,3,11,3,z,0,z,3,3,11,11,11,3,3,
z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,
2,2,2,2,z,2,z,z,z,2,z,2,2,11,2,z,
2,z,z,2,z,2,z,2,z,2,z,2,z,z,2,z,
2,z,z,2,z,2,z,2,z,2,z,2,z,z,2,z,
2,2,2,2,z,2,z,2,z,2,z,2,2,2,2,z,
2,z,z,z,11,2,0,2,0,2,z,2,z,z,z,z,
2,z,z,z,z,2,2,2,2,2,z,2,z,z,z,z,
z,1,z,z,1,z,1,z,z,z,1,z,z,1,1,z,
3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,
3,z,z,z,z,z,z,z,z,z,z,z,z,z,z,3,
3,z,z,z,z,z,3,1,3,1,z,1,1,z,z,3,
3,z,1,z,z,z,3,1,3,z,z,z,z,z,z,3,
3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
};

u8 pwpendfield[16*16] = {
z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,
z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,
z,z,z,z,z,3,z,z,z,3,z,z,z,z,z,z,
z,z,z,z,1,3,z,z,z,3,z,z,z,z,z,z,
z,z,z,z,z,3,z,z,z,3,z,z,z,z,z,z,
z,3,3,3,z,3,z,3,z,3,z,3,3,3,z,z,
z,3,z,3,z,3,z,3,1,3,z,3,z,3,z,z,
z,3,3,3,z,3,1,3,z,3,1,3,3,3,z,z,
z,3,z,z,1,3,3,3,3,3,z,3,z,z,z,z,
z,3,z,z,z,z,z,z,z,z,1,3,z,z,z,z,
z,3,1,z,z,z,z,z,z,z,z,3,z,z,z,z,
z,3,z,z,z,z,z,z,z,z,z,3,z,z,z,z,
z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,
z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,
z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,
z,z,z,z,z,z,z,z,z,z,z,z,z,z,z,z
};

u8 bartyblasefield[16*16] = {
3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,z,
3,1,1,z,z,z,z,z,z,z,z,z,z,z,z,3,
3,z,z,1,z,z,z,z,z,z,z,z,z,z,z,3,
3,z,z,z,z,z,z,1,z,1,z,1,z,1,z,3,
3,1,K,z,K,z,K,z,K,z,K,z,K,z,z,3,
3,z,2,1,2,z,2,z,2,z,2,z,2,1,z,3,
3,z,2,z,2,z,2,1,2,1,2,1,2,z,z,3,
3,1,K,z,K,z,K,z,K,z,K,z,K,z,z,3,
3,z,2,z,2,z,2,1,2,z,2,z,2,z,z,z,
3,1,2,1,2,z,2,z,2,1,2,z,2,z,z,3,
3,z,K,1,K,z,K,z,K,z,K,1,K,1,z,3,
3,z,2,z,2,z,2,1,2,z,2,z,2,1,z,3,
3,z,2,1,2,z,2,z,2,1,2,z,2,z,z,3,
3,z,K,z,K,z,K,z,K,z,K,z,K,1,z,3,
3,z,1,1,z,1,z,z,1,z,1,z,z,z,z,3,
3,3,3,3,3,3,3,3,3,3,3,3,3,z,3,3,
};


u8 bdashfield[16*16];

/*
u8 bdashfield[16*16] = {
2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
2,Z,Z,Z,2,Z,Z,1,Z,Z,Z,2,Z,Z,Z,2,
2,Z,Z,Z,2,Z,Z,1,Z,Z,Z,2,Z,Z,Z,2,
2,Z,Z,Z,2,Z,Z,1,Z,Z,Z,2,Z,Z,Z,2,
2,Z,Z,Z,2,2,2,2,2,2,2,2,Z,Z,Z,2,
2,Z,Z,Z,Z,Z,3,Z,3,Z,Z,Z,Z,Z,Z,2,
2,Z,Z,Z,Z,Z,3,Z,3,Z,Z,Z,Z,Z,Z,2,
2,Z,Z,Z,Z,Z,0,Z,3,Z,Z,Z,Z,Z,Z,2,
2,Z,Z,Z,Z,Z,3,Z,3,Z,Z,Z,Z,Z,Z,2,
2,Z,Z,Z,Z,Z,3,Z,3,Z,Z,Z,Z,Z,Z,2,
2,Z,Z,Z,2,2,2,2,2,2,2,2,Z,Z,Z,2,
2,Z,Z,Z,2,Z,Z,1,Z,Z,Z,2,Z,Z,Z,2,
2,Z,Z,Z,2,Z,Z,1,Z,Z,Z,2,Z,Z,Z,2,
2,Z,Z,Z,2,Z,Z,1,Z,Z,Z,2,Z,Z,Z,2,
2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
};
*/
#undef Z

void rundemo()
{
   int quit=0,clrfx=0,fx=0,subfx=0;

   pwplib_startup();
   
   decompress_allbmp();
   bwpals();

   pwplib_buf=
     malloc(sizeof(u8)*pwplib_bufw*pwplib_bufh);

   if(!pwplib_setup(NOSOUND))
   initplayer();

   pwplib_prep_attr();

   demovar.flagz=8|16;
   
   {demovar.dsgtime=0;
    demovar.endfxt=1<<30;
    demovar.metsaemode=0;
   while(!quit)
   {
     int t=pwplib_timer();
    
     while(demovar.dsgtime<=t)
     {
        if(0==(demovar.dsgtime&15))
        { simulate_bdash(bdashfield); }

        switch((int)demovar.dsgtime)
        {
           case(0): fx=8; subfx=0; memcpy(bdashfield,pwplogofield,256*sizeof(u8)); break;

           case(384): newtext(384,"OLDCHSOOL",0xff); break;

	   case(256): fx=8; break;

           case(512-64): clrfx=1; subfx=fx=0; break;
           case(512-48): subfx++; break;
           case(512-16): subfx++; break;
           case(512-8): subfx++; break;

           case(512): fx=0;clrfx=5;subfx=0+16;
           newtext(512,"OLDCHSOOL\nTARKOTTAA",0xff);break;

           case(512+128):
            newtext(512+128,"SEMMOSTA\n TYYPPII\nJOKA OLI",0xff);break;

           case(512+256):newtext(512+256,"EKALLA\nASSENPLY\nMESSULLA",0xff);break;

           case(512+384): newtext(512+384,"JO ENNEN\n  VUOTTA\n   ZOOO",0xff); break;
           
           case(512+512):newtext(512+512,"OLDCHSOOL\n HEMMOT\n   ON",0xff); break;
           
           case(1024+128): newtext(1024+128," HIRVE[N\nISOJA JA\n RUMIA",0xff); fx|=2; break;
           
           case(1024+256): newtext(1024+256,"NIILL[ ON\n  TYTT\\\n YST[V[",0xff); break;
           
         /*  case(1024+384-8): fadeoldsk(1024+384-32); break;
         */ 
           case(1024+384): 
                           newtext(1024+384,"JA NE ON\n AMATTI\n KOLUSSA",0xff); break;
                  
	   case(1024+512): fx=2; subfx=17; clrfx=0; break;

	   case(1024+512+128+64): fx=8|2;subfx=1;
             memcpy(bdashfield,bartyblasefield,256*sizeof(u8));
           break;

	   case(1024+512+256+64): fx=4|8;break;

           case(2048-128): fx=5; break;

           case(2048): newtext(2048,"OLDCHSOOL\nHEMMOILLA\n   ON",0xff);break;
           
           case(2048+128): newtext(2048+128,"GOMONDORE\n NIMINEN\n TIETSKA",0xff);break;

           case(2048+256): newtext(2048+256,"SILL[ EI\nVOI EES\n PELATA",0xff);break;
           
           case(2048+384): newtext(2048+384,"MUUTA KU\n CUAKE\nYKK\\ST[",0xff);break;

           case(2048+512): newtext(2048+512,"OLDCHSOOL\nHEMMOILLE\n   ON",0xff);fx=1;break;

           case(2048+512+128):
             newtext (2048+512+128, "ASEMPLY\nMESSUILLA\nOMA ALUE", 0xff);
             break;
           
           case(2048+512+256): newtext(2048+512+256,"JOSSA NE\nPIIKITT[[\nCANABISTA",0xff);fx=0;break;
          
           case(2048+512+384-16): fadeoldsk(2048+512+384-16); break;
 
           case(2048+512+384): newtext(2048+512+384,"JA PELAA\n  CUACE\n YKK\\ST[",0xff);break;
           
           case(2048+1024): fx=8;subfx=2; break;

           case(2048+1024+139):
           case(2048+1024+128):
           case(2048+1024+80):
           case(2048+1024+109):
           case(2048+1024+137):
           case(2048+1024+112):
           case(2048+1024+99):
           case(2048+1024+140):
           case(2048+1024+200):
           case(2048+1024+220):
           case(2048+1024+190):
              bdashfield[16+11]=11; 
                                bdashfield[16+5]=11; 
              bdashfield[16+9]=11;
              bdashfield[16+7]=11; 
              bdashfield[64+11]=11; 
                                bdashfield[32+5]=11; 
              bdashfield[96+9]=11;
              bdashfield[64+7]=11; break;

           case(2048+1024+512-64): fx=10; break;

           case(2048+1024+512):
              fx=2;
              newtext(2048+1024+512,"M[ HALUUN\n  OLLA\nOLDCHSOOL",0xff);
           break;
/*
           case(2048+1024+512+128):
              newtext(2048+1024+512+128,"MUN [ITIKI\nHALUU JA\n KOIRA",0xff);
              break;
*/
           case(2048+1024+512+256):
              newtext(2048+1024+512+256,"OLDCHSOOL\nON SUURI\nPELASTUS",0xff);
              break;

           case(2048+1024+512+384):
              newtext(2048+1024+512+384,"JA AVAIN\nIKUISEEN\nEL[M[[N",0xff);break;

           case(2048+2048):fx=0;break;

           case(2048+2048+128):memcpy(bdashfield,pwpendfield,sizeof(u8)*256);
              fx=8;subfx=3;break;

           case(2048+2048+256):
              newtext(2048+2048+256,"  PWP\n STILL\nOVERRULES",0xff);break;
           case(2048+2048+512):
              newtext(2048+2048+512," DESIGN\nCODE ETC\nBY VIZNUT",0xff);break;
           case(2048+2048+768):
              newtext(2048+2048+768,"GREETZ TO\nALL THE\nELITEZ",0xff);break;
           case(2048+2048+1024):
              newtext(2048+2048+1024,"   PWP\nPRODUCTION\n  ZOOI",0xff);break;

           case(2048+2048+1024-64):
              {int i=80;for(;i;i--){bdashfield[rand()&255]=11;
               bdashfield[rand()&255]=1;}}break;


           case(2048+2048+1024+256):quit=1;fx=0;break;
/*

    -----

   OLDCHSOOL
   HEMMOILLA
      ON

   GOMONDORE
   NIMINEN
   TIETSKA

   SILLÄ EI
   VOI EES
    PELATA
    
   MUUTA KU
    CUAKE
   YKKÖSTÄ
  
      --

   OLDCHSOOL
   HEMMOILLE
      ON
      
   ASSEMPLY
   MESSUILLA
   OMA ALUE
   
   JOSSA NE
   PIIKITTÄÄ
   CANABISTA
   
   JA PELAA
     CUAKE
    YKKÖSTÄ

    ------

     KAIKKI
    OLDCHSOOL
     TYYPIT

     KUULUU
    RIKOLLIS
     JENGIIN

    JOSSA NE
      SYÖ
    VAUVOJA

      JA 
    PIIKITTÄÄ
    CANABISTA

      --
      
     MINÄKIN
     HALUAN
     ISONA
     
     KOVAX
    OLDCHSOOL
     JÄBÄX


      

      ...
     
    ------

                   
  
*/

        }
        demovar.dsgtime++;
     }

     /* clrscr */
     
     if(clrfx==1)
     {
        int fg=0x11,bord=0x99;

        int y0=pwplib_bufh/8,y1=pwplib_bufh-y0,
            xmar=pwplib_bufw/8;
        
        if(subfx>0) bord=rand()&255;

        if(subfx>1) fg=bord;
        
        if(subfx>2) fg=bord=0x77;
            
        memset(pwplib_buf,bord,pwplib_bufw*pwplib_bufh*sizeof(u8));

        for(;y0<y1;y0++)
           memset(pwplib_buf+pwplib_bufw*y0+xmar,fg,sizeof(u8)*pwplib_bufw-xmar*2);
     }
     else

      if(clrfx==5) planes_do(t,subfx);
     else
     memset(pwplib_buf,0,pwplib_bufw*pwplib_bufh*sizeof(u8));

#            undef G

    

/*
   OLCHSOOL
    HEMMOT
      ON
      
    HIRVEÄN
   ISOJA JA
   VANHOJA
 
    NIILLON
   TYTTÖ
    YSTÄVÄ
    
   JA NE ON
   AMATTI
    KOLUSSA
   
----   

     ENNEN
     VUOTTA
     ZOOO

   OLI EKOIL
   ASSENPL
    MESSUIL
    
   OLDCHSOOL
   TARKOTTAA
   SEMMOSTA
    TYYPPII
     JOKA
   
*/

    /********/

   if(fx&1) scroller_do(t,pwplib.videobuf.height/2);
  if(fx&8)
   {
   /*   bdashfield[rand()&255]=0;
*/
      if(subfx==0)
            bdash_do(bdashfield,8*256,8*256,(128+abs(1024-((t<<4)&2047)))*2/3,t>>4);
            else
      if(subfx==1)
            bdash_do(bdashfield,8*256,8*256,384,t>>4);
            else
      if(subfx==2)        
            bdash_do(bdashfield,8*256,8*256,640,t>>4);
            else
            bdash_do(bdashfield,abs(8*256-((16*256-1)&(t<<4)))+102*8,8*256,640,t>>4);
   }

/* 768 */

   if(fx&4) pelubounce0(t); 
   if(fx&2) oldskzooms(t);

   zoomer_do(t);

     /* addtext(64+((t>>1)&63)); */ /* +(t&127)); */

   /***********************/

     pwplib_dump_rast();
     if(!quit)pwplib_loopflush();
   }
   }
   
   pwplib_shutdown();
}

int main(int argc,char**argv)
{
   if(!pwplib_init(argc,argv))return 1;

   initzoomers();

   rundemo();

   pwplib_shutdown();

   return 0;
}
