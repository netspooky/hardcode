#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "../pwplib/pwplib.h"

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

void rundemo()
{
   int quit=0;
   pwplib_startup();
   
   pwplib.videobuf.d=
     malloc(sizeof(u8)*pwplib.videobuf.width*pwplib.videobuf.height);

   initfontbuf(); 

   if(!pwplib.setup[SETUP_NOSOUND])
       initplayer();

   fprintf(stderr,"\33[2J\33[H\n"); /* kludge! fix pwplib */

   demovar.flagz=8|16;
   
   {demovar.dsgtime=0;
    demovar.endfxt=1<<30;
    demovar.metsaemode=0;
   while(!quit)
   {
     int t=pwplib_timer();

     while(demovar.dsgtime<t)
     {
        switch((int)demovar.dsgtime)
        {
            case(64*5):
               textzoomin(64*5,"@@@PWP@@@@\n"
                               "@PRESENTS@\n"
                               "@@@@IN\n"
                               "@@[\\[OO");
               break;
            case(96*5):
               textzoomout(96*5);
               break;
            case(128*5):
               textzoomin(128*5,
                               "@@@@A\n"
                               "@@VT[OO\n"
                               "COMPATIBLE\n"
                               "@@FILM");
               break;
            case(160*5):
               textzoomout(160*5);
               break;
            case(192*5):
               textzoomin(192*5,
                               "@STARRING\n"
                               "\n"
                               "@@@PELU\n"
                               "LAMURANTA");
               break;
            case(224*5):
               textzoomout(224*5);
               demovar.flagz=8|16|32;
               demovar.enctime=demovar.endfxt=320*5;
               demovar.enckode=1;
               demovar.enczoom=80;
               demovar.encspeed=32;
               break;

            case(256*5):
               textzoomin(256*5,
                               "@CODED@BY\n"
                               "\n"
                               "@@VIZNUT");
               break;
            case(288*5):
               textzoomout(288*5);
               break;

            case(320*5):
               textzoomin(320*5,
                              "@@PELUCE@@\n"
                              "@@@@IN@@@@\n"
                              "WONDERLAND\n");
               break;
            case(384*5-24):
               textoff();
               break;
            case(384*5):
               demovar.enckode=2;
               break;
            case(384*5+24):
               demovar.enckode=3;
               break;
            case(384*5+50):
               demovar.flagz=4;
               demovar.endfxt=1<<30;
               break;
               
            case(384*5+60):
               demovar.flagz=64;
               break;
            #define G 384*5+128*4

            case(G-88*4):
               justshowtext("\n@KILLALL\n]HUP@BRAIN",0xee);
               break;
            case(G-72*4):
               demovar.flagz=4;
               textoff();
               break;

            case(G-32*4):
               justshowtext("@RELOADING\n@@MIND@]]]",0xcc);

            case(G-16*4):
               justshowtext("\n\n\n@@@@ALPHA",0xcc);
               break;
            case(G-12*4):
               justshowtext("\n\n@@@BETA",0xcc);
               break;
            case(G-8*4):
               justshowtext("\n@@GAMMA",0xcc);
               break;
            case(G-4*4):
               justshowtext("@DELTA",0xcc);
               break;
            case(G):
               demovar.flagz=2;
               textoff();

               demovar.planemode=16+2;
               textzoomin(G,"@@@UUSI\n@@IHMEMAA\n@@@@ON\n@@L_YTYNYT");
               break;

            case(G+64*4):
               textzoomout(G+64*4);
               demovar.flagz=2+1;
               demovar.bouncemode=1;
               demovar.planemode=16;
               break;

            case(G+112*4):
               demovar.planemode=17;
               break;

            case(G+128*4):
               demovar.bouncemode=0;
               demovar.planemode=2;
               textzoomin(G+128*4,"@@@PELUN\n@MIELEST^\n@KAIKKI@ON\n@@IHANAA");
               break;

            case(G+192*4):
               textzoomin(G+192*4,"@EIK^@H^N\n@@@@OSAA\n@@@VAROA\n@@VAAROJA");
               demovar.bouncemode=1;
               break;

            case(G+256*4):
               demovar.enckode=4;
               demovar.enctime=demovar.endfxt=G+304*4;
               demovar.enczoom=80;
               demovar.encspeed=50;
               demovar.flagz=4|32;

               textzoomin(G+256*4,"@@SILLOIN\nPAHA@HENKI\n@@RIIVAA\n@@@PELUN");
               break;

/*            case(G+270*4):
               demovar.flagz=4|32;
               break;*/

            case(G+288*4):
               break;

            case(G+304*4):
               textoff();
               demovar.flagz=64|32;
               break;
            
            case(G+320*4):
               demovar.flagz=64;
               break;
               
            case(G+336*4):
               demovar.flagz=8|16|32;
               demovar.enckode=5;
               demovar.enctime=demovar.endfxt=G+416*4;
               demovar.enczoom=80;
               demovar.encspeed=128;
               break;

            case(G+384*4):
               textzoomin(G+384*4,"JA@H^NEST^\n@@TULEE");
               break;

            case(G+400*4):
               textzoomin(G+400*4,"\nTAHDOTON");
               break;

            case(G+416*4):
               textzoomin(G+416*4,"SAATANAN\nPALVELIJA");
               break;
            
            case(G+440*4):
               textoff();
               break;
            
            case(G+472*4):
               demovar.endfxt=1<<30;
               demovar.flagz=8|16|128;
               break;

            case(G+512*4):
               textzoomin(G+512*4,"@@@PELU\nTEURASTAA");
               break;
            case(G+544*4):
               textzoomin(G+528*4,"@@PALJON\n@IHMISI^@]");
               
               demovar.flagz=8|16|128|32;
               demovar.enckode=0;
               demovar.enctime=G+576*4+90;
               demovar.enczoom=64;
               demovar.encspeed=32;
               break;
            case(G+576*4):
               textzoomin(G+590*4,"KRISTITYT\n@@P^LLIT");
               break;
            case(G+576*4+90):
               demovar.enckode=6;
               break;
            case(G+576*4+96):
               demovar.flagz&=~32;
               break;
            case(G+608*4):
               textzoomin(G+608*4,"@UUSMEDIA]\n@@P^LLIT");
               demovar.enckode=7;
               demovar.enctime=G+608*4+90;
               demovar.flagz|=32;
               break;
            case(G+608*4+90):
               demovar.enckode=6;
               break;
            case(G+608*4+96):
               demovar.flagz&=~32;
               break;
            case(G+640*4):
               textzoomin(G+640*4,"@@TESNO]\n@@P^LLIT");
               demovar.enckode=8;
               demovar.enctime=G+640*4+90;
               demovar.flagz|=32;
               break;
            case(G+640*4+90):
               demovar.enckode=6;
               break;
            case(G+640*4+96):
               demovar.flagz&=~32;
               break;
            case(G+672*4):
               textzoomin(G+672*4,"@ARMEIJA]\n@@P^LLIT");
               demovar.enckode=9;
               demovar.enctime=G+672*4+90;
               demovar.flagz|=32;
               break;
            case(G+672*4+90):
               demovar.enckode=6;
               break;
            case(G+672*4+96):
               demovar.flagz&=~32;
               break;
            case(G+704*4):
               textzoomin(G+704*4,"@WINDOWS]\n@@P^LLIT");
               demovar.enckode=10;
               demovar.enctime=G+704*4+90;
               demovar.flagz|=32;
               break;
            case(G+704*4+90):
               demovar.enckode=6;
               break;
            case(G+704*4+96):
               demovar.flagz&=~32;
               break;
            case(G+736*4):
               textzoomin(G+736*4,"@@QUAKE]\n@@P^LLIT");
               demovar.enckode=11;
               demovar.enctime=G+736*4+90;
               demovar.flagz|=32;
               break;
            case(G+736*4+90):
               demovar.enckode=6;
               break;
            case(G+736*4+96):
               demovar.flagz&=32;
               break;
            case(G+768*4):
               demovar.flagz=4;
               textzoomin(G+768*4,"@JA@NIIN\nMAAILMASTA\n@@@TULI\n@PAREMPI");
               break;
            case(G+816*4):
               textzoomin(G+800*4,"\n@P^LLIT_N\n@@@MAA");
               break;
            case(G+848*4):
               textzoomin(G+832*4,"\n@@VAPAA\n@@@MAA");
               break;
            case(G+880*4):
               textzoomin(G+864*4,"IHMEMAA");
               break;
            case(G+924*4):
               textzoomout(G+896*4);
               break;
            case(G+988*4):
               justshowtext("\n@@GREETS\nCOMING@UP",0xff);
               break;
            case(G+996*4):
               justshowtext("\n@DRUIDS\n@@@OF\n@@DAWN",0xdd);
               break;
            case(G+1004*4):
               justshowtext("\n\n@@@ISO",0xdd);
               break;
            case(G+1012*4):
               justshowtext("\nBRAINLEZ\n@@CODERS",0xdd);
               break;
            case(G+1020*4):
               justshowtext("\n\n@HYDROGEN",0xdd);
               break;
            case(G+1028*4):
               justshowtext("\n\nPUPULAUMA",0xdd);
               break;
            case(G+1036*4):
               justshowtext("\n@]@PWP@]",0xff);
               break;
            case(G+1052*4):
               justshowtext("@WANNABE]\nASENNETTA\nVUODESTA\n@@[\\\\Y",0xff);
               break;
            case(G+1088*4):
               justshowtext("@@BYRGCNF\n@@@NVINA\nCREXRYRRA\n@@UHBAB",0xdd);
               quit++;
               break;
        }
        demovar.dsgtime++;
     }

     if(demovar.flagz&8) scroller_do(MIN(t,demovar.endfxt),pwplib.videobuf.height>>1);
     if(demovar.flagz&4) memset(pwplib.videobuf.d,0,
         pwplib.videobuf.width*pwplib.videobuf.height*sizeof(u8));
     if(demovar.flagz&2) planes_do(MIN(t,demovar.endfxt),demovar.planemode);
     if(demovar.flagz&64)
     {
        int i=pwplib.videobuf.width*pwplib.videobuf.height;
        char*d=pwplib.videobuf.d,a=rand()&255,b=rand()&255;
        for(;i;i--){*d++=(a^b)&0x99;a*=7;b=b-i+11*a;}
     }

     if(demovar.flagz&1) pelubounce(t*16/5,demovar.bouncemode);
     if(demovar.flagz&16) metsae(MIN(t,demovar.endfxt),demovar.metsaemode);

     if(demovar.flagz&32) 
        encounter(demovar.enctime-t,demovar.enckode,demovar.enczoom);
     if(demovar.flagz&128) 
        drawkiller((G+544*4)-t);

            #undef G

     textshow(t);

     pwplib.dump_rast();
     if(!quit)pwplib.loopflush();
   }
   }
}

int main(int argc,char**argv)
{
   if(!pwplib_init(&argc,argv))return 1;

   if(pwplib.setup[SETUP_HALVE])pwplib.videobuf.height<<=1;

   rundemo();

   return 0;
}
                        