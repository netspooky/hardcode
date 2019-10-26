#include "wrapper.h"

#include "fisi.h"
#include "fisiansi.h"

#ifdef TURBOC
  #define FAR far
#else
  #define FAR
#endif

extern volatile int taimeri;

extern int bgcol,txtcol,ansifrom;
extern char buffclass;

extern char fx_main;   /* p„„effu: 1=tunneli */
extern char fx_main_spex;
extern char fx_3d;
extern char fx_flare;

extern char FAR *ruutu,*txb,*abb,*vib;

extern framekey o0[];

prforhyb(char*h)
{
      int i;
      for(i=80*25;i;i--){
	    if((*h==32)||(!*h))if(!(*(h+1)&0xf0)){*h=253;*(h+1)=1;}
            h+=2;
      }
}

demoloop()
{
      char lastkey=0;
      int dt=0;
      int fader=0,fadetype=1;

      while(lastkey!=27){
	if(kbhit()){lastkey=getch();

/*	if(lastkey=='0'){o0[OY].targ=25*32;o0[OROT].targ=150;
		o0[OZOOM].targ=25000;}
	if(lastkey=='9')fx_3d=0;

	if(lastkey=='1')o0[OHGT].targ=45*256;
	if(lastkey=='2')o0[OHGT].targ=25*256;
	if(lastkey=='3')o0[OHGT].targ=5*256;*/
	}

	while(dt<taimeri){
	

/***********************************************************/

      #define b break
      #define sc strcpy

      signed int d=dt;

/*    d+=5*256;*/

	loopflush(); /* <-- muualle! */

      if(d<5*384)
      if(!(d%5))switch(d/5){
	    case(0):
                  scroller_init(0);
                  preparebuff(SINGLE);
		  fx_main=SCROLLER;
		  fx_main_spex=0;
		  b;
	    case(64):
		fader=7;fadetype=1;
		txtline(txb+80*10,"elet{{n","the`year");
		b;
	    case(66):
		txtline(txb+80*20,"vuotta","is");b;
	    case(68):
		txtline(txb+80*30,"}o}~","}o}~");b;
	    case(96):
		fader=31;fadetype=2;b;
	    case(100):
		clrline(txb+80*10);b;
	    case(116):
		clrline(txb+80*10);b;

	    case(128):
		fader=7;fadetype=1;
		memset(txb,0,80*50);
		txtline(txb+80*10,"kaaos","chaos");
		b;
	    case(132):
		txtline(txb+80*20,"on`t{ytt{nyt","has`taken");b;
	    case(134):
		txtline(txb+80*30,"maan","the`earth");b;
	    case(128+32):
		fader=31;fadetype=2;b;
	    case(128+48):
		clrline(txb+80*20);b;
	    case(128+64):
		fader=7;fadetype=1;
		memset(txb,0,80*50);
		txtline(txb+80*2,"maailman","the`great");
		b;
	    case(192+4):
		txtline(txb+80*14,"suuri","leader`of");b;
	    case(192+8):
		txtline(txb+80*26,"johtaja","the`world`has");b;
	    case(192+12):
		txtline(txb+80*38,"on`vangittu","been`captured");b;
	    case(192+32):
		fader=31;fadetype=2;b;
	    case(192+64):
		fader=7;fadetype=1;
		memset(txb,0,80*50);
		txtline(txb+80*2,"ja`vain","and");
		b;
	    case(192+70):
		txtline(txb+80*11,"yksi`mies","only");b;
	    case(192+72):
		txtline(txb+80*20,"voi","one`man");b;
	    case(192+74):
		txtline(txb+80*29,"pelastaa","can");b;
	    case(192+76):
		txtline(txb+80*38,"h{net","save`him");b;
	    case(192+96):
		fader=31;fadetype=2;b;
	    case(256+64):
		memset(txb,0,80*50);
		fader=7;fadetype=1;
		txtline(txb+80*20,"i`s`i","i`s`i");
		b;
	    case(256+64+32):
		txtline(txb+80*8,"final","final");b;
	    case(256+104):
		fader=31;fadetype=2;b;
	    case(256+112):
		memset(txb,0xff,80*50);
		fader=15;fadetype=3;b;
            case(256+118):
                  preparebuff(NONE);fx_main=NONE;
                  uncrunch(LOGO,ruutu,sizeof(LOGO));
                  b;
      }

      d-=5*(256+128+28);
      if(d>=0)if(!(d&3))switch(d>>2){
		case(0):preparebuff(SINGLE);fx_main=SCROLLER;
		scroller_init(HORIZON|NOSKRAMBLE);
		memset(txb,0,80*25*2);
		scr_txr(1);
		o0[OHGT].curr=48*256;o0[OHGT].targ=22*256;
		o0[OHGT].frac=2048;
		o0[OZOOM].curr=o0[OZOOM].targ=10;fx_3d=1;
		txtline(txb+80*8,"isi","daddy");
		txtline(txb+80*18,"ei`turhia","wont`wait");
		txtline(txb+80*28,"aikaile","too`long");fader=7;fadetype=1;
		b;
		case(32):fader=31;fadetype=2;b;
		case(64):
		memset(txb,0,80*25*2);
		txtline(txb+80*5,"isi`laittaa","daddy");
		txtline(txb+80*15,"p{{h{ns{","puts`on`his");
		txtline(txb+80*25,"virtuaalisen","virtual");
		txtline(txb+80*35,"kyp{r{n","helm");
		fader=7;fadetype=3;b;

                case(64+32):
		fader=31;fadetype=2;b;

		case(64+40):preparebuff(NONE);
                memset(ruutu,0,80*25*2);
                uncrunch(SYBER0,ruutu,sizeof(SYBER0));
                b;

		case(64+44):
                memset(ruutu,0,80*25*2);
                uncrunch(SYBER1,ruutu,sizeof(SYBER1));
                b;

		case(64+48):
                memset(ruutu,0,80*25*2);
                uncrunch(SYBER2,ruutu,sizeof(SYBER2));
                b;

		case(64+52):preparebuff(SINGLE);
		memset(txb,0xee,80*25*2);
		fader=31;fadetype=2;
		o0[OFLX].curr=o0[OFLX].targ=20*256;
		o0[OFLY].curr=o0[OFLY].targ=-15*256;fx_flare=1;
		b;

		case(64+58):fader=31;fadetype=2;fx_flare=0;b;

		case(64+64):fx_flare=1;
		memset(txb,0,80*25*2);
		txtline(txb+80*5,"ja`hetkess{","and");
		txtline(txb+80*15,"h{nest{","instantly");
                txtline(txb+80*25,"tulee","he`becomes");
		fader=7;fadetype=3;
		b;

		case(64+64+32):fx_flare=0;
                memset(txb,0,80*25*2);
		txtline(txb+80*30,"salaper{inen","the");
		txtline(txb+80*40,"","mysterious");
		b;

		case(64+64+32+16):
		fx_3d=1;eggine_load(0);
		o0[OY].curr=70*32;o0[OY].targ=25*32;
		o0[OROT].targ=800;
		o0[OZOOM].targ=31000;
		b;

		case(64+64+64):
		memset(txb,0,80*25*2);
		o0[OY].targ=25*32;
		txtline(txb+80*20,"virtuaalimies","virtual`man");
		b;

		case(64+64+64+16):
		o0[OROT].targ=760;o0[OROT].frac=512;b;

		case(64+64+64+32):
                fadetype=4;fader=1;
		fx_3d=1;eggine_load(0);
		b;

		case(64+64+64+40):
                o0[OZOOM].targ=100;o0[OZOOM].frac=4096;
		b;

		case(64+64+64+48):memset(txb,0xff,80*25*2);
		b;

      }

      d-=8*128;
      if(d>=0)if(!(d&3))switch(d>>2){
	    case(0):
		fx_3d=fx_flare=0;
		  preparebuff(HYBRID);
                  memset(abb,0x0000,80*25*2);
                  memset(txb,0x0000,80*25*2);
		  memset(vib,0,80*50);
                  fx_main=NONE;
		  uncrunch(VPELU0,abb,sizeof(VPELU0));
		  uncrunch(VPELU1,txb,sizeof(VPELU1));
                  prforhyb(abb);prforhyb(txb);
		ansifrom=2;
		atxtline(vib,"kuka`sin{","who`are",0);
		atxtline(vib+9*80,"``olet","``you",0);
		b;
	    case(64):
		memset(vib,0,80*50);
		atxtline(vib,"ja","and",0);
		atxtline(vib+9*80,"``miksi`olet","why`have`you",0);
		b;
	    case(64+16):
		memset(vib,0,80*50);
		atxtline(vib,"vanginnut","captured",0);
		atxtline(vib+9*80,"``minut","``me",0);
		b;
	    case(64+32):
		ansifrom=0;
		memset(txb,0,80*25*2);
		uncrunch(VPELU2,txb,sizeof(VPELU2));
		prforhyb(txb);
		b;
	    case(128):
		ansifrom=2;
		memset(vib,0,80*50);
		atxtline(vib,"min{`olen","i`am",1);
		b;
	    case(128+16):
		atxtline(vib+9*80,"sinun","your",1);
		b;
	    case(128+32):
		memset(vib,0,80*50);
		atxtline(vib,"pime{","dark",1);
		atxtline(vib+9*80,"puoliskosi","half",1);
		b;
	    case(128+64):
                  memset(abb,0x0000,80*25*2);
                  memset(txb,0x0000,80*25*2);
		  memset(vib,0,80*50);
		  ansifrom=2;
		  uncrunch(VMPELU0,abb,sizeof(VMPELU0));
		  uncrunch(VMPELU1,txb,sizeof(VMPELU1));
                  prforhyb(abb);prforhyb(txb);
		  atxtline(vib,"musta","the`black",0);
		  atxtline(vib+9*80,"``pelu","``pelu",0);
                  b;
      }

      d-=((128+128)*4);
      if(d>=0)if(!(d&3))switch(d>>2){
	case(0):
		memset(txb,0,80*25*2);
		preparebuff(SINGLE);
		scroller_init(HORIZON|NOSKRAMBLE);
		scr_txr(1);
		fx_main=SCROLLER;
		fx_main_spex=1;
		fx_3d=1;eggine_load(0);
		o0[OY].curr=70*32;o0[OY].targ=25*32;
		o0[OY].frac=2048;

		o0[OZOOM].curr=25000;
		o0[OZOOM].targ=100;o0[OZOOM].frac=1024;

		fader=7;fadetype=1;
		memset(txb,0,80*25*2);
		txtline(txb+9*80,"isi","daddy");
		txtline(txb+18*80,"etsii","looks`for");
		txtline(txb+27*80,"poikaansa","his`son");
		txtline(txb+36*80,"urheasti","bravely");
		b;

	case(32):fader=31;fadetype=2;b;

	case(48):o0[OHGT].targ=5*256;o0[OHGT].frac=4096;b;

	case(64):eggine_load(1);
		memset(txb,0,80*25*2);
		o0[OY].curr=70*32;o0[OY].targ=25*32;
		o0[OY].frac=2048;
		o0[OZOOM].curr=20000;o0[OZOOM].targ=27000;
		o0[OROT].targ=1000;o0[OROT].frac=4096;

		txtline(txb+2*80,"mutta","but");
		txtline(txb+11*80,"pimeyden","the`dark");
		txtline(txb+20*80,"varjostajat","shadows");
		txtline(txb+29*80,"huomaavat","notice");
		txtline(txb+38*80,"h{net","him");
		fader=7;fadetype=1;
		b;
	case(64+32):fader=31;fadetype=2;
		o0[OROT].targ=700;o0[OROT].frac=2048;
		o0[OROT].frac=1024;
	b;
	case(64+48):o0[OROT].targ=1000;b;
	case(64+56):o0[OROT].targ=200;b;
	case(64+64):o0[OZOOM].targ=100;o0[OZOOM].frac=4096;b;

/*	case(64+64):
		o0[OY].curr=70*32;o0[OY].targ=25*32;
		o0[OY].frac=4096;
		o0[OROT].targ=50;
		o0[OZOOM].curr=31000;
		o0[OZOOM].targ=100;o0[OZOOM].frac=4096;
		b;*/
	case(64+64+16):
		o0[OY].curr=70*32;o0[OY].targ=25*32;
		o0[OY].frac=4096;
		o0[OROT].targ=500;
		o0[OZOOM].curr=31000;
		o0[OZOOM].targ=100;o0[OZOOM].frac=4096;
		memset(txb,0,80*25*2);
		txtline(txb+8*80,"pimeyden","there`is");
		txtline(txb+18*80,"varjostajia","a`lot`of");
		txtline(txb+28*80,"tulee","dark");
		txtline(txb+38*80,"paljon","shadows");
		fader=7;fadetype=1;
		b;
	case(64+64+32):
		o0[OY].curr=70*32;o0[OY].targ=25*32;
		o0[OY].frac=4096;
		o0[OROT].targ=50;
		o0[OZOOM].curr=31000;
		o0[OZOOM].targ=100;o0[OZOOM].frac=4096;

		b;
	case(64+64+48):
		o0[OY].curr=70*32;o0[OY].targ=25*32;
		o0[OY].frac=4096;
		o0[OROT].targ=500;
		o0[OZOOM].curr=31000;
		o0[OZOOM].targ=100;o0[OZOOM].frac=4096;
		fader=31;fadetype=2;
		b;
	case(64+64+64):
		memset(txb,0,80*25*2);
		txtline(txb+8*80,"ja`isi","and`daddy");
		txtline(txb+18*80,"on`nyt","is`now");
		txtline(txb+28*80,"katalassa","in`quite");
		txtline(txb+38*80,"pinteess{","`a`trouble");
		fader=7;fadetype=1;
		b;
	case(64+64+64+32):fader=31;fadetype=2;b;
      }

      d-=256*4;
      if(d>=0)if(!(d&3))switch(d>>2){
        case(0):
        preparebuff(HYBRID);
        memset(txb,0,80*25*2);ansifrom=2;
	uncrunch(P_SPR,txb+11*160,sizeof(P_SPR));
	uncrunch(MP_SPR,txb+60*2+10*160,sizeof(MP_SPR));
	memset(abb,0,80*25*2);
	uncrunch(P_SPR,abb+11*160,sizeof(P_SPR));
	uncrunch(MP_SPR1,abb+60*2+10*160,sizeof(MP_SPR1));
        prforhyb(abb);prforhyb(txb);
        fx_main=0;fx_3d=0;
        memset(vib,0,80*25*2);
	atxtline(vib,"lapsena","as`children",1);
	atxtline(vib+9*80,"olimme`yksi`","we`were`one``",1);
        b;

	case(32):
	uncrunch(SINIPELU,abb+20*2+7*160,sizeof(SINIPELU));
	b;

	case(64):
	ansifrom=2;memset(abb,0,80*25*2);
	uncrunch(P_SPR,abb+11*160,sizeof(P_SPR1));
	uncrunch(MP_SPR1,abb+60*2+10*160,sizeof(MP_SPR1));
	prforhyb(abb);
        memset(vib,0,80*25*2);
	atxtline(vib,"sitten`meid{t","then`we`were",1);
	atxtline(vib+9*80,"erotettiin`","separated``",1);
        b;

	case(96):
/*	uncrunch(JINJANG,abb+20*2+7*160,sizeof(JINJANG));*/
	memset(vib,0,80*25*2);
	atxtline(vib,"sin{`olet","you`are`good",1);
	atxtline(vib+9*80,"hyv{```","i`am`evil",1);
	atxtline(vib+18*80,"min{`paha`","",1);
	b;

	case(96+16):
	memset(vib,0,80*25*2);
	atxtline(vib,"sin{`valkea","you`are`white",1);
	atxtline(vib+9*80,"min{`musta`","i`am`dark",1);
	b;

/*	case(96+24):

	b;*/

	case(128):
	ansifrom=2;memset(abb,0,80*25*2);
	uncrunch(P_SPR,abb+11*160,sizeof(P_SPR1));
	uncrunch(MP_SPR1,abb+60*2+10*160,sizeof(MP_SPR1));
	prforhyb(abb);
        memset(vib,0,80*25*2);
	atxtline(vib,"meid{n","we`should",1);
	atxtline(vib+9*80,"pit{isi`taas","unite`again",1);
	atxtline(vib+18*80,"yhdisty{``","",1);
        b;

	case(128+32):
	uncrunch(JINJANG,abb+20*2+7*160,sizeof(JINJANG));
	prforhyb(abb);
	b;

	case(128+64):
        memset(txb,0,80*25*2);ansifrom=2;
	uncrunch(P_SPR,txb+11*160,sizeof(P_SPR));
	uncrunch(MP_SPR,txb+60*2+10*160,sizeof(MP_SPR));
	memset(abb,0,80*25*2);
	uncrunch(P_SPR1,abb+11*160,sizeof(P_SPR1));
	uncrunch(MP_SPR,abb+60*2+10*160,sizeof(MP_SPR));
	prforhyb(abb);prforhyb(txb);
	memset(vib,0,80*25*2);
	atxtline(vib,"mutta","but",0);
	atxtline(vib+9*80,"mit{`siit{","what`would`it",0);
	atxtline(vib+18*80,"``seuraisi","``lead`to",0);
        b;

	case(128+64+32):
	uncrunch(MP_SPR2,abb+60*2+10*160,sizeof(MP_SPR2));ansifrom=1;
        memset(vib,0,80*25*2);
        atxtline(vib,"maailmanloppu","the`end",1);
        atxtline(vib+9*80,"","of`the`world",1);
        b;
      }

      d-=4*256;
      if(d>=0)if(!(d&3))switch(d>>2){
		case(0):preparebuff(SINGLE);fx_main=SCROLLER;
		scroller_init(HORIZON|NOSKRAMBLE);
/*		scr_txr(4);*/
		memset(txb,0,80*25*2);txtcol=0;
		o0[OHGT].curr=o0[OHGT].targ=256*25;o0[OHGT].frac=2048;
		o0[OFLX].curr=-50*256;
		o0[OFLY].curr=-30*256;
		o0[OFLX].targ=10*256;
		o0[OFLY].targ=-20*256;
		fx_3d=fx_flare=1;eggine_load(0);
		o0[OZOOM].curr=100;
		o0[OZOOM].targ=25000;
		o0[OZOOM].frac=4096;
		o0[OROT].curr=500;
		o0[OX].curr=40*32;o0[OY].curr=25*32;

		case(16):o0[OROT].targ=80;
			b;
		case(32):o0[OY].targ=70*32;o0[OZOOM].targ=15000;
			o0[OFLX].targ=-20*256;o0[OFLY].targ=-7*256;
			o0[OHGT].targ=10*256;
		b;
		case(40):eggine_load(1);
			o0[OZOOM].curr=100;o0[OZOOM].targ=31000;
			o0[OY].curr=o0[OY].targ=25*32;
			o0[OFLX].targ=0*256;
		b;
		case(48):
			o0[OZOOM].targ=25000;
		b;
		case(56):
			memset(txb,0,80*50);
			txtline(txb+9*80,"isi","daddy");
			txtline(txb+18*80,"on`nyt","is`now");
			txtline(txb+27*80,"saarrettu","trapped");
			fader=7;fadetype=1;
		b;
		case(64+16):fader=31;fadetype=2;b;
		case(64+32):
			o0[OROT].targ=400;o0[OROT].frac=4096;
			memset(txb,0xee,80*50);fader=7;fadetype=1;
			b;
		case(64+36):fader=7;fadetype=1;
			o0[OROT].targ=10;o0[OFLX].targ=10*32;
			o0[OFLY].targ=-20*32;b;
		case(64+40):fader=31;fadetype=2;
			eggine_load(0);o0[OY].curr=10*32;o0[OY].targ=30*32;
			o0[OROT].targ=600;
			fx_flare=0;
			o0[OHGT].curr=o0[OHGT].targ=40*256;
			o0[OZOOM].curr=o0[OZOOM].targ=20000;
			b;
		case(64+48):o0[OY].targ=20*32;b;
		case(64+56):o0[OZOOM].targ=30000;b;
		case(64+64):o0[OHGT].targ=25*256;o0[OY].targ=30*32;
			memset(txb,0,80*50);
			txtline(txb+4*80,"onneksi","fortunately");
			txtline(txb+14*80,"isill{`on","daddy`has");
			txtline(txb+24*80,"salainen","a`secret");
			txtline(txb+34*80,"ase","weapon");
			fader=7;fadetype=1;
			b;
		case(64+64+16):o0[OROT].targ=500;
			fx_flare=1;o0[OFLX].curr=-40*256;o0[OFLX].targ=30*256;b;
		case(64+64+24):fader=31;fadetype=2;b;
		case(64+64+32):
                        preparebuff(HYBRID);
                        memset(txb,0,80*50);
			memset(abb,0,80*50);
			uncrunch(WINNUKE0,txb,sizeof(WINNUKE0));
			uncrunch(WINNUKE1,abb,sizeof(WINNUKE1));
                        ansifrom=1;
                        fx_flare=0;eggine_load(1);
			o0[OY].targ=o0[OY].curr=15*32;
                        o0[OROT].curr=500;o0[OROT].targ=200;
			o0[OZOOM].curr=o0[OZOOM].targ=25000;
			o0[OHGT].curr=o0[OHGT].targ=40*256;
                        b;
		case(64+64+32+16):ansifrom=0;b;
		case(64+64+32+24):
			preparebuff(SINGLE);
                        o0[OZOOM].curr=o0[OZOOM].targ=25000;
			o0[OROT].curr=o0[OROT].targ=500;
			o0[OHGT].curr=o0[OHGT].targ=15*256;
                        fx_flare=1;
			b;
		case(64+64+32+32):o0[OROT].targ=200;
			o0[OHGT].targ=45*256;
			o0[OFLY].targ=-25*256;o0[OFLX].targ=-30*256;

			b;
                case(64+64+32+36):o0[OZOOM].targ=100;
                        fx_flare=1;

                        o0[OFLY].curr=(15-25)*256;
                        o0[OFLX].curr=0;

                        o0[OFLY].targ=(35-25)*256;
                        o0[OFLX].targ=(10-40)*256;
			o0[OY].targ=35*32;
                        o0[OX].targ=10*32;

                        o0[OX].frac=8192;
			o0[OY].frac=8192;
                        o0[OFLX].frac=8192;
                        o0[OFLY].frac=8192;
		b;
		case(64+64+32+48):memset(txb,0xcc,80*50);
			fader=31;fadetype=2;fx_flare=0;
			b;
		case(64+64+32+52):fx_flare=1;b;
		case(64+64+32+56):fader=31;fadetype=2;fx_flare=0;b;
      }

      d-=4*256;

      if(d>=0)if(!(d&3))switch(d>>2){
                case(0):
			eggine_load(0);
			o0[OHGT].targ=5*256;
			o0[OZOOM].targ=o0[OZOOM].curr=28000;
			o0[OROT].targ=300;
			o0[OX].curr=o0[OX].targ=40*32;
			o0[OY].curr=60*32;
			o0[OY].targ=25*32;

			b;
		case(16):o0[OZOOM].targ=100;
			memset(txb,0,80*50);
                        txtline(txb+4*80,"isi`jatkaa","daddy");
                        txtline(txb+14*80,"matkaansa","journeys`on");
                        txtline(txb+24*80,"mustan`pelun","to`black`pelu");
			txtline(txb+34*80,"linnakkeelle","fortress");
			fader=7;fadetype=1;
		b;
		case(48):fader=31;fadetype=2;b;
		case(64):preparebuff(HYBRID);fx_main=0;
                    memset(txb,0,80*25*2);ansifrom=0;
                    uncrunch(P_SPR,txb+11*160,sizeof(P_SPR));
                    uncrunch(MP_SPR2,txb+30*2+10*160,sizeof(MP_SPR2));b;
		case(64+16):
                    memset(txb,0,80*25*2);
                    memset(vib,0,80*25*2);
                    uncrunch(P_SPR,txb+11*160,sizeof(P_SPR));
		    uncrunch(MP_SPR2,txb+27*2+10*160,sizeof(MP_SPR2));
                    atxtline(vib,"isiiii","daddeeeee",0);
                    atxtline(vib+9*80,"pelasta`jo","save`meeee",0);
                    prforhyb(txb);
                    b;
		case(64+32):
		    memset(txb,0,80*25*2);
                    uncrunch(P_SPR,txb+11*160,sizeof(P_SPR));
		    uncrunch(MP_SPR2,txb+24*2+10*160,sizeof(MP_SPR2));
                    prforhyb(txb);
		    b;
		case(64+48):
		    memset(txb,0,80*25*2);
                    uncrunch(P_SPR,txb+11*160,sizeof(P_SPR));
		    uncrunch(MP_SPR2,txb+2*21+10*160,sizeof(MP_SPR2));
		    b;
		case(64+56):preparebuff(SINGLE);fx_main=SCROLLER;
			txtcol=0;memset(vib,0,80*25*2);
			o0[OHGT].targ=5*256;
                        o0[OZOOM].curr=100;o0[OZOOM].targ=28000;
			o0[OROT].curr=200;o0[OROT].targ=700;
                        o0[OFLX].curr=30*256;o0[OFLY].curr=-15*256;
                        o0[OFLX].targ=-30*256;o0[OFLY].targ=15*256;
			o0[OY].targ=40*32;
			b;
		case(128+5):
			o0[OY].targ=60*32;o0[OZOOM].targ=20000;b;
		case(128+16):
                        preparebuff(HYBRID);fx_main=0;ansifrom=0;
                        fx_3d=0;
                        memset(vib,0,80*50);
                        memset(txb,0,80*50);
			uncrunch(SAVE0,txb,sizeof(SAVE0));b;
		case(128+20):
                        memset(txb,0,80*50);
			uncrunch(SAVE1,txb,sizeof(SAVE1));b;
		case(128+24):
                        memset(txb,0,80*50);
			uncrunch(SAVE2,txb,sizeof(SAVE2));b;
		case(128+28):
                        memset(txb,0,80*50);
			uncrunch(SAVE3,txb,sizeof(SAVE3));b;
		case(128+32):
                        memset(txb,0,80*50);
			uncrunch(SAVE4,txb,sizeof(SAVE4));b;
		case(128+36):
                        memset(txb,0,80*50);
			uncrunch(SAVE5,txb,sizeof(SAVE5));b;
		case(128+48):
                        prforhyb(txb);
                        atxtline(vib,"oho","uh`oh",0);b;
		case(128+64):
                        memset(vib,0,80*50);
			atxtline(vib,"isiiii","daddeeee",1);b;
                case(128+64+16):
			uncrunch(XFOR,txb+50*160,sizeof(XFOR));
			memset(vib,0,80*50);
			atxtline(vib,"pelastit","you`saved",1);b;
                case(128+64+32):
			/*uncrunch(XFOR,txb+50*160,sizeof(XFOR));*/
			memset(vib,0,80*50);
			atxtline(vib,"minut`ja","me`and",1);b;
                case(128+64+48):
			/*uncrunch(XFOR,txb+50*160,sizeof(XFOR));*/
			memset(vib,0,80*50);
			atxtline(vib,"maailman","the`world``",1);b;
			b;
                case(256):preparebuff(SINGLE);memset(txb,0,80*50);
                          memset(abb,0,80*50);memset(vib,0,80*50);
                        txtline(txb+8*80,"mites`nyt","how`can");
                        txtline(txb+24*80,"noin`k{vi","this`happen");
                        fader=31;fadetype=1;
                        b;
                case(256+64):
                        memset(txb,0,80*50);
                        txtline(txb+6*80,"no`eip{`ole","well");
                        txtline(txb+16*80,"meid{n","thats`not");
                        txtline(txb+26*80,"ongelma","our`problem");b;
                case(256+128):
                        memset(txb,0,80*50);
                        txtline(txb+22*80,"the`end","the`end");b;
                case(256+128+64):lastkey=27;b;
      }

      if(fader){
	int f=fader;int joo[8]={
		0x0000,
		0x0808,
		0x0707,
		0x7070,
		0x7777,
		0x7f7f,
		0xf7f7,
		0xffff };
	if(fadetype==2)f=7-f/4;
	if(fadetype==3)f=f/2;
	if(fadetype==4){f&=7;fader+=2;}

	if(f>7)f=7;if(f<0)f=0;
	txtcol=joo[7-f];
	fader--;
      }

/*

^@pwp^@pwp^@final`isi^@final`isi

^@code^@code^@musax^@musax^@gfx^@gfx^@viznut^@viznut

^@t{{ll{^@t{{ll{^@on`ihan^@on`ihan^@tyhm{{^@tyhm{{^@

*/


/***********************************************************/

	  dt++;
	  }

	if (buffclass) effu(taimeri);
}}


