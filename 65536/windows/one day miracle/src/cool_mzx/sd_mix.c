/*  SD_MIX.C

by yzi/fit 1997

versio 0.11


changes: 11.05.1997
	 0.11 - mixing functions in assembler (SD_AMIX.ASM)
	      - C versions also available (#ifndef MIX_ASM)

	 08.05.1997
	 0.10 - now this finally works

	 29.04.1997
	 0.01 - everything is new


Kaikille miksaaville laitteille yhteiset rutiinit.
SD_MIX on tavallaan kuin GF1, ja muut moduulit
antavat sille p‰‰syn ulkomaailmaan. (esim. SD_SB16)

"Sample" koostuu muutamasta asiasta:
	- pointeri dataan, koko
	- looppitiedot
	- 16bit juu/ei


Kanavatietoja on kahdet: todelliset ja tyˆn alla olevat
kanavat. Kun miksaus alkaa, kopioidaan todellisiin kanaviin
uudet arvot. (Jos muutellaan arvoja kesken miksauksen niin
ei mene sekaisin...)

(HUOM! Edell‰ mainittu p‰tee vain 2-keskeytysj‰rjestelmiin,
joissa tosiaan musiikinsoittorutiini voi kutsua mix-rutiineja
koska vain. Jos homma tehd‰‰n vuoron per‰‰n miksaus/soitto,
ei ongelmia tietenk‰‰n synny.

*/

#define PURE_C

#ifndef PURE_C
#define MIX_ASM
#endif

#include <math.h>
#ifdef MIX_ASM
#include "sd_amix.h"
#endif
#include "sd_main.h"
#include "sd_mix.h"

typedef struct SAMPLEINFOBLOCK {
	signed char *data;
	unsigned int
	    size,
	    loopstart,
	    loopend,
	    looptype,
	    sample16bit;
};

typedef struct CHANNELINFOBLOCK {
	signed char *sampledata;
	unsigned int
	    sample,
	    volume,
            offsetlo, /* offset samplen alusta */
	    offsethi,
	    deltalo,
	    deltahi,
	    loopstart,
	    loopend,
	    looptype,
	    samplesize,
	    panning,
	    sample16bit,
	    newdelta, /* Jos 1, asetetaan ko. arvo. h‰m‰r‰‰, mutta toimii */
	    newoffset; /* Jos 1, asetetaan ko. arvo. h‰m‰r‰‰ mutta toimii */
};

int sd_mix_interpolation=0;
int sd_mix_rate=44100;

struct SAMPLEINFOBLOCK mix_samples[SD_MAXSAMPLES];

static int	mix_curchannel=0,
		mix_mainvolume=SD_MAXMAINVOLUME,
		mix_activechannels=4,
		mix_buffer32[MIX_LARGESTBLOCK*2];

static struct CHANNELINFOBLOCK	mix_channels[SD_MAXCHANNELS],
				mix_realchannels[SD_MAXCHANNELS],
				*curchan;

int mix_getsample (int snum, char *src, int len,
		    int loopstart, int loopend, int looptype)
/* "Ottaa" samplen. Muistia ei varata t‰ss‰, joten olis ihan kiva,
   ett‰ se tila pysyisi varattuna. */
{
	mix_samples[snum].data = src;
	mix_samples[snum].size = len;
	mix_samples[snum].loopstart = loopstart;
	mix_samples[snum].loopend = loopend;
	mix_samples[snum].looptype = looptype;
	return SD_OK;
} /* mix_getsample */

void mix_selectchannel (int cnum)
{
	mix_curchannel = cnum;
	curchan = &(mix_channels[mix_curchannel]);
} /* mix_selectchannel */

void mix_setsample (int snum)
{
	curchan->sample = snum;
	curchan->sampledata = mix_samples[snum].data;
	curchan->loopstart = mix_samples[snum].loopstart;
	curchan->loopend = mix_samples[snum].loopend;
	curchan->looptype = mix_samples[snum].looptype;
	curchan->samplesize = mix_samples[snum].size;
} /* mix_setsample */

void mix_setamigaperiod (int period)
{
	double d, h, l;
	if(period!=0)
		d = ((double)AMIGA_MASTERCLOCK) / ((double)period * sd_mix_rate);
	else
		d = 0.0;

	l = modf(d, &h);

        //curchan->deltahi = (d-l);
	if(period!=0)
		curchan->deltahi=AMIGA_MASTERCLOCK/period/sd_mix_rate;
	else
		curchan->deltahi=0;

	curchan->deltalo = (int)(l * (65536.0*256)) << 8;

	curchan->newdelta = 1;

} /* mix_setamigaperiod */

void mix_setvolume (int volume)
{
	curchan->volume = volume;
} /* mix_setvolume */

void mix_setpanning (int panning)
{
	curchan->panning = panning;
} /* mix_setpanning */

void mix_setoffset (int offset)
{
	if (offset > curchan->loopend)
	{ /* Loopin ulkopuolella - kytket‰‰n kanavan looppi pois. */
		curchan->looptype = LOOP_OFF;
	}
	if (offset < curchan->samplesize)
	{
		curchan->offsethi = offset;
		curchan->offsetlo = 0;
		curchan->newoffset = 1;
	}
	/* Jos on j‰rjetˆn arvo niin ei tehd‰ mit‰‰n. */
} /* mix_setoffset */

void mix_setmainvolume (int volume)
{
	if (volume > SD_MAXMAINVOLUME*4) volume = SD_MAXMAINVOLUME*4;
	mix_mainvolume = volume;
} /* mix_setmainvolume */

void mix_setactivechannels (int activechannels)
{
	mix_activechannels = activechannels;
} /* mix_setactivechannels */

void sd_mix_setfunctions ()
{
	/* Asetetaan sd-funktiot */
	sd_getsample = mix_getsample;
	sd_selectchannel = mix_selectchannel;
	sd_setsample = mix_setsample;
	sd_setamigaperiod = mix_setamigaperiod;
	sd_setvolume = mix_setvolume;
	sd_setpanning = mix_setpanning;
	sd_setoffset = mix_setoffset;
	sd_setmainvolume = mix_setmainvolume;
	sd_setactivechannels = mix_setactivechannels;
} /* sd_mix_setfunctions */


void sd_mix_initchannel (struct CHANNELINFOBLOCK *c)
{
	c->volume = 0;
	c->offsetlo = 0;
	c->offsethi = 0;
	c->deltahi = 0;
	c->deltalo = 0;
	c->loopstart = 0;
	c->loopend = 0;
	c->looptype = LOOP_OFF;
	c->panning = PAN_MIDDLE;
	c->sampledata = (char *)0; /* NULL */
	c->sample = 0;
	c->sample16bit = 0;
	c->newoffset = 1;
	c->newdelta = 1;
} /* sd_mix_initchannel */

void sd_mix_initsample (struct SAMPLEINFOBLOCK *s)
{
	s->loopstart = 0;
	s->loopend = 0;
	s->looptype = LOOP_OFF;
	s->data = (char *)0; /* NULL */
} /* sd_mix_initchannel */

void sd_mix_init (int rate)
{
	int	i,n,m;

	sd_mix_rate = rate;
	for (i=0; i<SD_MAXCHANNELS; i++)
	{
		sd_mix_initchannel(&mix_channels[i]);
		sd_mix_initchannel(&mix_realchannels[i]);
	}
	for (i=0; i<SD_MAXSAMPLES; i++)
	{
		sd_mix_initsample (&mix_samples[i]);
	}

/*	for(m=0;m<256;m++)
	{
		for(n=0;n<128;n++)
			sd_volotab[m*256+n]=m*n;
		for(n=128;n<256;n++)
			sd_volotab[m*256+n]=m*(n-256);
	}*/
} /* sd_mix_init */


/* ---------------------- VARSINAINEN MIKSAUS -------------------- */

void long_addition (unsigned int *h,
                    unsigned int *l,
                    unsigned int *dh,
                    unsigned int *dl);

/* lis‰‰ yhteen [esi].[edi] += [ebx].[edx] */

#ifdef PURE_C

void long_addition (unsigned int *h,
                    unsigned int *l,
                    unsigned int *dh,
                    unsigned int *dl)
{
        static unsigned int i;

        (*h) += (*dh);
        i = (*l);
        if (((*l)+=(*dl))<i) (*h)++;
} /* long_addition */

#else

#pragma aux long_addition = \
	"mov    eax, [esi]"\
	"mov    ecx, [edi]"\
	"add    ecx, [edx]"\
	"adc    eax, [ebx]"\
	"mov    [esi], eax"\
	"mov    [edi], ecx"\
	parm [esi] [edi] [ebx] [edx] modify [eax ecx];

#endif

void mix_copychannel(struct CHANNELINFOBLOCK *dest,
		     struct CHANNELINFOBLOCK *src)
/* Kopioi kanavan muut tiedot paitsi offsetin. */
{
	unsigned int saveofshi, saveofslo,
		     savedeltahi, savedeltalo;

	saveofshi = dest->offsethi;
	saveofslo = dest->offsetlo;
	savedeltahi = dest->deltahi;
	savedeltalo = dest->deltalo;


	/* T‰ss‰ on hyvin riskialtis paikka... voi menn‰ v‰‰rin. Ihan tosi. */

	*dest = *src; /* kopioidaan kanavat */
	if (!(src->newoffset))
	{ /* Ei laitettukaan sit‰ offsetia */
		dest->offsethi = saveofshi;
		dest->offsetlo = saveofslo;
//                src->newoffset = 0; /* NewOffset-lippu alas. */
	}
	else src->newoffset = 0; /* NewDelta-lippu alas. */
	if (!(src->newdelta))
	{ /* Ei laitettukaan sit‰ offsetia */
		dest->deltahi = savedeltahi;
		dest->deltalo = savedeltalo;
	}
	else src->newdelta = 0; /* New-lippu alas. */
} /* mix_copychannel */


#ifndef MIX_ASM

/* Interpoloiva monomiksaaja */
void sd_c_imixmono (struct CHANNELINFOBLOCK *chan, int *dst32, int length, int lvol)
{
        static int i, left;
	
        if (chan->looptype)
        for (i=0; i<length; i++)
        {

                long_addition (&(chan->offsethi), &(chan->offsetlo),
                               &(chan->deltahi), &(chan->deltalo));

                if (chan->offsethi > chan->loopend)
                {
                        chan->offsethi = chan->loopstart+1;
                }

                left = (((int)(chan->sampledata[(chan->offsethi)+1])
                                * lvol
                       ))*(signed)((chan->offsetlo>>26))>>6;
                left += (((int)(chan->sampledata[chan->offsethi])
                                * lvol
                       ))*(signed)(63-(chan->offsetlo>>26))>>6;

                *(dst32++) += left;
        } /* for i */
        else
        for (i=0; i<length; i++)
        {

                long_addition (&(chan->offsethi), &(chan->offsetlo),
                               &(chan->deltahi), &(chan->deltalo));

                if (chan->offsethi >= chan->samplesize)
                {
                        chan->offsethi = chan->samplesize;
                        chan->deltahi = 0;
                        chan->deltalo = 0;
                        chan->volume = 0;
                }

                left = (((int)(chan->sampledata[(chan->offsethi)+1])
                                * lvol
                       ))*(signed)((chan->offsetlo>>26))>>6;
                left += (((int)(chan->sampledata[chan->offsethi])
                                * lvol
                       ))*(signed)(63-(chan->offsetlo>>26))>>6;

                *(dst32++) += left;
        } /* for i */

} /* sd_c_imixmono */

/* Ei-interpoloiva monomiksaaja. */
void sd_c_mixmono (struct CHANNELINFOBLOCK *chan, int *dst32, int length, int lvol)
{
        static int i, left;

/*	if(chan->looptype)
		sd_mono_loop(&chan->offsethi,&chan->offsetlo,
				  chan->deltahi,chan->deltalo,
				  chan->loopend,chan->loopstart,
				  lvol,dst32,length,chan->sampledata);
	else
	{
		sd_mono_noloop(&chan->offsethi,&chan->offsetlo,
				   chan->deltahi,chan->deltalo,
				   chan->samplesize,&chan->volume,
				   lvol,dst32,length,chan->sampledata);
		if(!chan->offsethi && !chan->offsetlo)
		{
                        chan->deltahi = 0;
                        chan->deltalo = 0;
			chan->volume = 0;
		}
	}*/

        if (chan->looptype)
        for (i=0; i<length; i++)
        {

                long_addition (&(chan->offsethi), &(chan->offsetlo),
                               &(chan->deltahi), &(chan->deltalo));

                if (chan->offsethi > chan->loopend)
                {
                        chan->offsethi = chan->loopstart+1;
                }

                left = (((int)(chan->sampledata[chan->offsethi])
                                * lvol
                       ));

                *(dst32++) += left;
        } 
        else
        for (i=0; i<length; i++)
        {

                long_addition (&(chan->offsethi), &(chan->offsetlo),
                               &(chan->deltahi), &(chan->deltalo));

                if (chan->offsethi >= chan->samplesize)
                {
                        chan->offsethi = 0; //chan->samplesize;
                        chan->deltahi = 0;
                        chan->deltalo = 0;
                        chan->volume = 0;
                }

                left = (((int)(chan->sampledata[chan->offsethi])
                                * lvol
                       ));

                *(dst32++) += left;
        }

} /* sd_c_mixmono */

/* Interpoloiva stereomiksaaja */
void sd_c_imixstereo (struct CHANNELINFOBLOCK *chan, int *dst32, int length, int lvol, int rvol)
{
        static int i, left, right;

        if (chan->looptype)
        for (i=0; i<length; i++)
        {

                long_addition (&(chan->offsethi), &(chan->offsetlo),
                               &(chan->deltahi), &(chan->deltalo));

                if (chan->offsethi > chan->loopend)
                {
                        chan->offsethi = chan->loopstart+1;
                }

                left = (((int)(chan->sampledata[(chan->offsethi)+1])
                                * lvol
                       ))*(signed)((chan->offsetlo>>26))>>6;
                left += (((int)(chan->sampledata[chan->offsethi])
                                * lvol
                       ))*(signed)(63-(chan->offsetlo>>26))>>6;
                right = (((int)(chan->sampledata[(chan->offsethi)+1])
                                * rvol
                       ))*(signed)((chan->offsetlo>>26))>>6;
                right += (((int)(chan->sampledata[chan->offsethi])
                                * rvol
                       ))*(signed)(63-(chan->offsetlo>>26))>>6;

                *(dst32++) += left;
                *(dst32++) += right;
        } /* for i */
        else
        for (i=0; i<length; i++)
        {

                long_addition (&(chan->offsethi), &(chan->offsetlo),
                               &(chan->deltahi), &(chan->deltalo));

                if (chan->offsethi >= chan->samplesize)
                {
                        chan->offsethi = 0; //chan->samplesize;
                        chan->deltahi = 0;
                        chan->deltalo = 0;
                        chan->volume = 0;
                }

                left = (((int)(chan->sampledata[(chan->offsethi)+1])
                                * lvol
                       ))*(signed)((chan->offsetlo>>26))>>6;
                left += (((int)(chan->sampledata[chan->offsethi])
                                * lvol
                       ))*(signed)(63-(chan->offsetlo>>26))>>6;
                right = (((int)(chan->sampledata[(chan->offsethi)+1])
                                * rvol
                       ))*(signed)((chan->offsetlo>>26))>>6;
                right += (((int)(chan->sampledata[chan->offsethi])
                                * rvol
                       ))*(signed)(63-(chan->offsetlo>>26))>>6;

                *(dst32++) += left;
                *(dst32++) += right;
        } /* for i */
} /* sd_c_imixstereo */

/* Ei-interpoloiva stereomiksaaja */
void sd_c_mixstereo (struct CHANNELINFOBLOCK *chan, int *dst32, int length, int lvol, int rvol)
{
        static int i, left, right;

/*	if(chan->looptype)
		sd_stereo_loop(&chan->offsethi,&chan->offsetlo,
				  chan->deltahi,chan->deltalo,
				  chan->loopend,chan->loopstart,
				  lvol,dst32,length,chan->sampledata,rvol);
	else
	{
		sd_stereo_noloop(&chan->offsethi,&chan->offsetlo,
				   chan->deltahi,chan->deltalo,
				   chan->samplesize,&chan->volume,
				   lvol,dst32,length,chan->sampledata,rvol);
		if(!chan->offsethi && !chan->offsetlo)
		{
                        chan->deltahi = 0;
                        chan->deltalo = 0;
			chan->volume = 0;
		}
	} */

        if (chan->looptype)
        for (i=0; i<length; i++)
        {

                long_addition (&(chan->offsethi), &(chan->offsetlo),
                               &(chan->deltahi), &(chan->deltalo));

                if (chan->offsethi > chan->loopend)
                {
                        chan->offsethi = chan->loopstart+1;
                }

                left = (((int)(chan->sampledata[chan->offsethi])
                               * lvol
                       ));
                right = (((int)(chan->sampledata[chan->offsethi])
                                * rvol
                       ));

                *(dst32++) += left;
                *(dst32++) += right;
        }
        else
        for (i=0; i<length; i++)
        {

                long_addition (&(chan->offsethi), &(chan->offsetlo),
                               &(chan->deltahi), &(chan->deltalo));

                if (chan->offsethi >= chan->samplesize)
                {
                        chan->offsethi = chan->samplesize;
                        chan->deltahi = 0;
                        chan->deltalo = 0;
                        chan->volume = 0;
                }

                left = (((int)(chan->sampledata[chan->offsethi])
                               * lvol
                       ));
                right = (((int)(chan->sampledata[chan->offsethi])
                                * rvol
                       ));

                *(dst32++) += left;
                *(dst32++) += right;
        }
} /* sd_c_mixstereo */

/* Konvertointirutiinit. Konvertoidaan sis‰inen 32-bittinen
   ‰‰nen esitysmuoto toiseen muotoon (8/16bit, stereo/mono, signed/unsigned) */

void sd_c_stereo32tos16i (signed int *dst32, signed short *dst, int length)
{
        static int i, left, right;

        for (i=0; i<length; i++)
	{
                left = *(dst32++);
                right = *(dst32++);

		if (left < -32768) left = -32768;
		else
		if (left > 32767) left = 32767;
		if (right < -32768) right = -32768;
		else
		if (right > 32767) right = 32767;

		*(dst++) = (signed short)left;
		*(dst++) = (signed short)right;
	} /* for i, klippaus */
} /* sd_c_stereo32tos16i */

void sd_c_mono32tom16i (signed int *dst32, signed short *dst, int length)
{
        static int i, left;

        for (i=0; i<length; i++)
	{
                left = *(dst32++);

		if (left < -32768) left = -32768;
		else
		if (left > 32767) left = 32767;

		*(dst++) = (signed short)left;
	} /* for i, klippaus */
} /* sd_c_stereo32tom16i */

void sd_c_stereo32tos8u (signed int *dst32, unsigned char *dst, int length)
{
        static int i, left, right;

        for (i=0; i<length; i++)
	{
                left = *(dst32++) >> 9;
                right = *(dst32++) >> 9;

                if (left < -128) left = -128;
		else
                if (left > 127) left = 127;
                if (right < -128) right = -128;
		else
                if (right > 127) right = 127;

                *(dst++) = (unsigned char)left + 128;
                *(dst++) = (unsigned char)right + 128;
	} /* for i, klippaus */
} /* sd_c_stereo32tos8u */

void sd_c_mono32tom8u (signed int *dst32, unsigned char *dst, int length)
{
        static int i, left;

        for (i=0; i<length; i++)
	{
		left = *(dst32++) >> 9;

		if (left < -128) left = -128;
		else
		if (left > 127) left = 127;

		*(dst++) = (unsigned char)(left)+128;
	} /* for i, klippaus */
} /* sd_c_mono32tom8u */

#endif
/* not MIX_ASM */

void sd_mix_stereo (signed short *dest, int length, int to16bit)
{
	signed int *dst32;
	signed int i, c, lvol, rvol;
	signed int left, right;
	signed short *dst;
	signed char *sample;
	struct CHANNELINFOBLOCK *chan;

	/* Kopioidaan kanavat */
	for (i=0; i<mix_activechannels; i++)
		mix_copychannel(&mix_realchannels[i],
				&mix_channels[i]);

	/* Tyhjennet‰‰n kirjoitettava alue. */
	memset (mix_buffer32, 0, sizeof(signed int)*2*length);

	for (c=0; c<mix_activechannels; c++)
	{
		chan = &mix_realchannels[c];
		sample = chan->sampledata;
		dst32 = mix_buffer32;

		lvol = (chan->volume*(255-chan->panning)*mix_mainvolume)/(128*SD_MAXMAINVOLUME);
		rvol = (chan->volume*(chan->panning)*mix_mainvolume)/(128*SD_MAXMAINVOLUME);
		if ((chan->samplesize>0) && (chan->volume>0))
#ifdef MIX_ASM
                if (sd_mix_interpolation)
                        sd_asm_imixstereo(chan, dst32, length, lvol, rvol);
                else
                        sd_asm_mixstereo(chan, dst32, length, lvol, rvol);
#else
                if (sd_mix_interpolation)
                        sd_c_imixstereo(chan, dst32, length, lvol, rvol);
                else
                        sd_c_mixstereo(chan, dst32, length, lvol, rvol);
#endif

	} /* for channel */

	dst32 = mix_buffer32;
	dst = dest;

#ifdef MIX_ASM
        if (to16bit)
                sd_asm_stereo32tos16i(dst32, dst, length);
        else
                sd_asm_stereo32tos8u(dst32, (unsigned char *)dst, length);
#else
        if (to16bit)
                sd_c_stereo32tos16i(dst32, dst, length);
        else
                sd_c_stereo32tos8u(dst32, (unsigned char *)dst, length);
#endif

} /* sd_mix_stereo */

/* K‰‰nt‰j‰ antaa warningeja, kun samalla rutiinilla tehd‰‰n sek‰
16- ett‰ 8-bittist‰ tavaraa, eli *dest-pointeri ei tietenk‰‰n
voi olla oikein... */
void sd_mix_mono (unsigned char *dest, int length, int to16bit)
{
	signed int *dst32;
	signed int i, c, lvol, rvol;
	signed int left, right;
	unsigned char *dst;
	signed char *sample;
	struct CHANNELINFOBLOCK *chan;

	/* Kopioidaan kanavat */
	for (i=0; i<mix_activechannels; i++)
		mix_copychannel(&mix_realchannels[i],
				&mix_channels[i]);

	/* Tyhjennet‰‰n kirjoitettava alue. */
	memset (mix_buffer32, 0, sizeof(signed int)*length);

	for (c=0; c<mix_activechannels; c++)
	{
		chan = &mix_realchannels[c];
		sample = chan->sampledata;
		dst32 = mix_buffer32;

		lvol = (chan->volume*255*mix_mainvolume)/(128*SD_MAXMAINVOLUME);
		if ((chan->samplesize>0) && (chan->volume>0))
#ifdef MIX_ASM
                if (sd_mix_interpolation)
                        sd_asm_imixmono(chan, dst32, length, lvol);
                else
                        sd_asm_mixmono(chan, dst32, length, lvol);
#else
                if (sd_mix_interpolation)
                        sd_c_imixmono(chan, dst32, length, lvol);
                else
                        sd_c_mixmono(chan, dst32, length, lvol);
#endif

	} /* for channel */


	dst32 = mix_buffer32;
	dst = dest;

#ifdef MIX_ASM
        if (to16bit)
                sd_asm_mono32tom16i(dst32, dst, length);
        else
                sd_asm_mono32tom8u(dst32, (unsigned char *)dst, length);
#else
        if (to16bit)
                sd_c_mono32tom16i(dst32, dst, length);
        else
                sd_c_mono32tom8u(dst32, (unsigned char *)dst, length);
#endif

} /* sd_mix_mono */


