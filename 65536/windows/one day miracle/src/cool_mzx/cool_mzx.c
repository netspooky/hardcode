
/****************************************************************
 cool_mzx.c

 19980523
 19980630 (Linux)
 jotain (SDL)
 2.9.2002 (SDL)
 ****************************************************************/


#include "cool_mzx.h"
#include "sd_main.h"
#include "pt.h"
#include <SDL/SDL.h>

extern int        pt_curperiod[32],    // kanavan nykyinen periodi
                  pt_curnote[32],      // kanavan nykyinen s‰vel
                  pt_curvol[32],       // kanavan nykyinen voimakkuus
                  pt_cursample[32],    // kanavan nykyinen sample
                  pt_tporta[32],       // tone portamenton nopeus
                  pt_curtarget[32],    // tone portamenton kohdeperiodi
                  pt_vibs[32],         // vibraton nopeus
                  pt_vibd[32],         // vibraton amplitudi ("depth")
                  pt_vibc[32],         // vibraton laskuri (0..63)
                  pt_trms[32],         // tremolon nopeus
                  pt_trmd[32],         // tremolon amplitudi
                  pt_trmc[32],         // tremolon laskuri (0..63)
                  pt_curfine[32],      // kanavan nyk. finetune
                  pt_glissando[32],    // onko glissando?
                  pt_notedelay[32],    // delayn pituus (ec, e9, ed)
                  pt_pattdelay[32],    // montako rivi‰ t‰ytyy odotella
                  pt_pattloop[32],     // montako looppia on tekem‰tt‰
                  pt_pattloopstart[32],// ja mille riville loopataan
                  pt_pan[32];          // kanavan panorointi

extern unsigned int   pt_songpos,          // miss‰ ollaan orderissa
		  pt_repstart,	       // mist‰ aletaan, kun orderi wrappaa
		  pt_firstline,        // milt‰ rivilt‰ seuraava patt. alkaa
		  pt_vbcount,	       // lasketaan tickej‰ (0..vbtempo-1)
		  pt_curpattern,       // nykyisen patternin numero
//                  pt_bpmtempo,         // tempo, (bpmtempo = 2.5 * ticks/sec)
		  pt_vbtempo,	       // montako ticki‰ per rivi
                  pt_rowcount;         // mill‰ rivill‰ ollaan

extern unsigned char *pt_lineptr;        // osoitin riville

extern   unsigned pt_channels;       // kanavien lukum‰‰r‰
extern    unsigned pt_slen[32],       // samplen pituus
                  pt_loops[32],      // loopin alkukohta
                  pt_loope[32],      // loopin pituus (<=2, jos ei ole)
                  pt_svol[32];       // volume
extern    unsigned char  pt_finetune[32],   // finetune
                  pt_songlen,        // pituus orderissa
                  pt_lastpattern,    // korkein patternin numero
                  pt_order[128];     // "song order"
extern    unsigned char *pt_patterns[128];  // patternidata


#define KAUAN 999999

    // (yzi) aika tickein‰ siihen, kun edellisen kerran pistettiin
    // sample numero [se_ja_se] soimaan
    volatile int
        aikaa_siita_kun_viimeksi_tavattu[32] =
        {KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,
         KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,
         KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,KAUAN,
         KAUAN,KAUAN,KAUAN,KAUAN,KAUAN};

volatile Uint32	tix=0;

//extern void vbiproc1();

volatile MZX_CALLBACKREC *callbacks[MAXCALLBACKS];
volatile int cbhandles[MAXCALLBACKS];
volatile int callbackcount=0, curhandle=1;

volatile unsigned int ticksfromstart = 0;

static int	laite=0,piippu[2],jacaja,screenHz;

static unsigned char	audio[40000];

void mix_newhand(void *udata, Uint8 *stream, int len);

/* palauttaa toden, jos i on annetulla v‰lill‰ tai "m‰‰rittelem‰tˆn" */
int inrange(int i, MZX_RANGE range)
{                         
        return (range.max < 0) ||
               ((i >= range.min) && (i <= range.max));
}

int ehto_toteutuu(MZX_CONDITION *cond)
{
        int toteutuneita, c;

        toteutuneita = 0;

        for (c=0; (c<pt_channels) && (!toteutuneita); c++)
        {
                toteutuneita =
                        (inrange(c, cond->channel))
                        && (inrange(pt_cursample[c], cond->instrument))
                        && (inrange(pt_lineptr[c*4+2] & 15, cond->command))
                        && (inrange(pt_lineptr[c*4+3], cond->parameter))
                        && (inrange(pt_songpos, cond->songpos))
                        && (inrange(pt_rowcount % cond->rowmod, cond->rowmodeq))
                        && (inrange(pt_vbcount, cond->tick));
        }

        return toteutuneita; /* jos v‰hint‰‰n yksi toteutui */

} /* ehto_toteutuu */

static void update_sample_trig_times()
{
        static int i, sanbale;

            if (!pt_vbcount) // ollaanko rivin alussa
            for (i=0; i<pt_channels; i++)
            {
                sanbale = pt_lineptr[i*4]; // samplen numero

                if ((pt_lineptr[i*4+1]) && // nuotti mukana
                    (pt_lineptr[i*4+2] != 3) && // ei tone portamento
                    (pt_lineptr[i*4+2] != 5) // eik‰ tone portamento + volslide
                   )
                aikaa_siita_kun_viimeksi_tavattu[sanbale] = -1;
            }

            for (sanbale=0;sanbale<32;sanbale++)
                aikaa_siita_kun_viimeksi_tavattu[sanbale]++;
}

Uint32 timeri(Uint32 interval)
{
    static int i, sanbale;

	if(!laite)
	{
		pt_play();

                update_sample_trig_times();
	}
	return(interval);
}

/*      Alustaa musiikkisysteemin, kyselee laitteet yms.        */
int mzx_init(void)
{
	char	pag[100];

	puts("Select your sound device:");
	puts("0 - None");
	puts("1 - 8-bit 22kHz");
	puts("2 - 16-bit 44kHz");
	scanf("%s",pag);
		
	switch(pag[0])
	{
		case '0': laite=0;
			  sd_ns_init(0,0,0);
			  break;
		case '1':
			laite=1;
			if(sd_dsp16_init(22050,0,0)==SD_ERR)
			return(0); 
			  break;
		case '2': laite=2;
			  if(sd_dsp16_init(44100,0,0)==SD_ERR)
				return(0); 
			  break;
		default: return(0);
	}

        callbackcount = 0;
        sd_init();
	sd_setmainvolume(64); 
	sd_start();

        return 1;
} /* mzx_init */

/*      Ottaa biisin muistista  */
int mzx_get(void *data)
{
	pt_songpos=pt_rowcount=0;
        if (!pt_takemod((unsigned char *)data))
        { /* maailmanloppu */
                return 0;
        }
        pt_init();
        return 1;
} /* mzx_get */

/*      Aloittaa soiton ja k‰ynnist‰‰ timerin taajuudella freq 	*/
void mzx_start(int freq)
{
	int	tavut,n,pois=0;

        tix = SDL_GetTicks();
        //vbiInit(&vbiproc0, &vbiproc1, &vbiproc2);

	screenHz=freq;
	jacaja=1000/freq;
	if(!laite)
	{
		SDL_Init(SDL_INIT_TIMER);
		SDL_SetTimer(jacaja, timeri);
		return;
	}
	SDL_PauseAudio(0);
} /* mzx_start */

/*	SIGCHLD-handleri	*/
void mix_newhand(void *udata, Uint8 *stream, int len)
{
	static int	ny=0,luku=0,off;

	short	*oso=stream;

	if(laite==1)
	{
		off=0;
		if(luku)
		{
			sd_mix_mono(stream,luku,0);
			off+=luku;
		}

		while(off+22050/screenHz<=len)
		{
			pt_play();
                        update_sample_trig_times();
			sd_mix_mono(&stream[off],22050/screenHz,0);
			off+=22050/screenHz;
		}

		if(off==len+22050/screenHz)
			luku=0;
		else
		{
			luku=len-off;
			pt_play();
                        update_sample_trig_times();
			sd_mix_mono(&stream[off],luku,0);
			luku=off+22050/screenHz-len;
		}
	}
	if(laite==2)
	{	
		len/=2;
		off=0;
		if(luku)
		{
			sd_mix_mono(stream,luku,1);
			off+=luku;
		}

		while(off+44100/screenHz<=len)
		{
			pt_play();
                        update_sample_trig_times();
			sd_mix_mono(&oso[off],44100/screenHz,1);
			off+=44100/screenHz;
		}

		if(off==len+44100/screenHz)
			luku=0;
		else
		{
			luku=len-off;
			pt_play();
                        update_sample_trig_times();
			sd_mix_mono(&oso[off],luku,1);
			luku=off+44100/screenHz-len;
		}
	}
}

/*      Lopettaa soiton ja sulkee laitteen      */
void mzx_close(void)
{
	if(!laite)
	{
		SDL_SetTimer(0,NULL);
		return;
	}

//        pt_stop();
        sd_stop();
        sd_shutdown();
} /* mzx_close */

/*      Palauttaa musiikin soitosta alkaen kuluneet tikit */
unsigned int mzx_time(void)
{
	return((SDL_GetTicks()-tix)/jacaja);
} /* mzx_time */

/* yzi  Asettaa master volumen (feidej‰ varten) */
void mzx_set_mastervolume(double vol)
{
        sd_setmainvolume(vol * 63);
} /* mzx_set_mastervolume */

/* yzi  Palauttaa modinsoiton vaiheen, eli 100*songcount + rowcount. */
unsigned int mzx_position()
{
        return ((pt_songpos * 100) + pt_rowcount);
} /* mzx_position */

/* yzi  Kaikkien callbackien ‰iti. callbackrecin muistia ei saa vapauttaa! */
int mzx_set_callback(MZX_CALLBACKREC *callbackrec)
{
        if (callbackcount >= MAXCALLBACKS) { return 0; }
        callbacks[callbackcount] = callbackrec;
        cbhandles[callbackcount] = curhandle;
        callbackcount++;
        return curhandle++;
} /* mzx_set_callback */
