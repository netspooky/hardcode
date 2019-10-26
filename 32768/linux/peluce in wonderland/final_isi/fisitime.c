#include "fisimusa.h"

#ifdef MSDOS
  #include <dos.h>
#endif

#define NUMCH 3

char cord=0,cpat=0,crow=0,drmt=0xff,drms=0;

char auditype;

int plrbeep[2];
int musatempo=5;

#ifdef MSDOS

/***************** h00KiNG nEW iNTERRuPT hANDLeRs **************/

#define setadlib adlib

unsigned int taimeri;

void interrupt int_8();
void interrupt (*old_int8)();

kellovauhti(char spiidi)
{
      disable();
      outportb(0x43,0x36);
      outportb(0x40,0x00);
      outportb(0x40,spiidi);
      enable();
}

timer_on()
{   taimeri=0;

    if(auditype){initsound();
                 cpat=patord[0];}
    disable();
    old_int8=getvect(0x08);
    setvect(0x08,int_8);
    enable();
    kellovauhti(64);
}

timer_off()
{
      disable();
      setvect(0x08,old_int8);
      enable();
      kellovauhti(0);

      if(auditype)initsound();
}

void interrupt int_8()
{
      taimeri++;
      if (!(taimeri&3)) (*old_int8)(); else outport(0x20,0x20);
      if(auditype)playtick();
}

/**********************************************************/
/******************* pLAYVVERr RUTiNE ********************/

char instru[2][11]={
    0xa1,0xa1,0xff,0xff,0x0f,0x0f,0x03,0x03,0x01,0x00,0x00,  /* bass? */
    0xa2,0xa2,0xff,0xff,0x0f,0x0f,0x03,0x03,0x01,0x00,0x00,  /* ohrgan */
};

adl_ldinstr(int kanava,int i)
{
    char*ins=instru[i];
    char osotte[11] = {
    0x20,0x23,0x60,0x63,0x80,0x83,0xe0,0xe3,0xc0,0x40,0x43 };
      char *tmp=ins; char l;
      for(l=0;l<11;l++) adlib(kanava+osotte[l],*tmp++);
}

initsound()
{
      int l;

      if(auditype==1) nosound();

      if(auditype==2){
            for(l=0;l<244;l++) adlib(l,0);
            adlib(0x01,0x20);
	    adl_ldinstr(0,1);
	    adl_ldinstr(1,1);
	    adl_ldinstr(2,1);}

}
#endif

int freku[12] = {
		0x157,0x16b,0x181,0x198,0x1b0,0x1ca,
		 0x1e5,0x202,0x220,0x241,0x263,0x287
		 };
char plst=0;

/**********************
 **********************/

playtick()
{
      plst++;

      #ifdef MSDOS

      if(auditype==1){
	      if(plst==musatempo/3){
                  if (plrbeep[0]) sound(plrbeep[0]>>3);
			      else
			      if(plrbeep[0])sound(plrbeep[0]>>3);else nosound();
			      }
	    if(plst==musatempo/2){
                  if (plrbeep[1]) sound(plrbeep[1]>>3);
			      else
			      if(plrbeep[2])sound(plrbeep[2]>>3);else nosound();
			      }

			      }

      if (auditype==2){int l;for(l=0;l<NUMCH;l++)
		if (plrbeep[l]<0xf0){
			adlib(0x40+l,2);
			adlib(0x43+l,1);}}

      #endif

      if (plst==musatempo) { uusinuotti(); plst=0; }
}

/*char ison[3]={1,1,1};*/
char hvilk[3]={0xfe,0xfe,0xfe};

int lizayz=0;

uusinuotti()
{
      int l;
      unsigned char mark,mkrl;

      for(l=0;l<NUMCH;l++) {

	    mkrl=mark=trax[cpat][l][crow];

	    if(mark<0xf0)mkrl=mark+=lizayz;

	    if (auditype==2) plrbeep[l]=mark;

	    if(mark==0xfa){musatempo=8;lizayz=-16;}

	    if (mark==0xfb)if(auditype==2){
		  if(crow&1)mark=0xfe;else
			    mark=hvilk[l];
			    plrbeep[l]=mark;
			    }

	    if (mark==0xfe)
	    #ifdef MSDOS
	     {if(auditype==2){adlib(0x40+l,63);
					     adlib(0x43+l,63);}
					else plrbeep[l]=0;
			      /*ison[l]=0;*/
		}
	    #else
	        gbsound(l,0);
	    #endif

	    if (mark==0xfd) musatempo=16;
	    if (mark==0xfc) musatempo=4;

            if (mark<0xf0) {

		if(mark==mkrl)hvilk[l]=mark;
		if((mark&15)>=12)mark+=4;

            #ifdef MSDOS

            /*********  ADLiB ********/

	     if(auditype==2){

              int hum=(freku[mark&15])             /* note */
                       |(32*256)|                  /* key on */
		      (((mark&(255-15))-32) *64);  /* octave */

              adlib(0xb0+l,hum>>8);
              adlib(0xa0+l,hum&255);
	      adlib(0x40+l,12);
	      adlib(0x43+l,15);
	      }

            /******** iBM sPEAKER *****/

              if(auditype==1){

		plrbeep[l]=freku[mark&15];
		plrbeep[l]<<=((( (mark&(255-15)) >>4)&15)-2);

		/*
		if (plrbeep[0]) sound(plrbeep[0]>>3);
			   else if (plrbeep[1]) sound(plrbeep[1]>>3);
					else nosound();*/

		}

            /*********************/

            #else
              gbsound(l,(mark&15)+((mark>>4)*12));
            #endif

      }       }

     crow++;   if (crow==64) {
                crow=0;cord++;
                cpat=patord[cord];
                if (cpat==99) { cord=0; cpat=patord[cord]; }}
}
