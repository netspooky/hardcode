/*
  This file is part of fxmp, an .xm player.
  fxmp is copyright 2000 by Osman Keskin <spectre@winterland.net>
  
  this version of fxmp is tailored for 64k GNU/Linux and win32 intro
  development (as part of Jeeves64 by Kuno Woudt <warp-tmt@dds.nl>).
  
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING; if not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
*/

/* Disable conversion warning messages in Visual C++ */
#ifdef _WIN32
#pragma warning( disable: 4761 )  
#endif


/* NOTE the hardware mixing frequency is a bit off still */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#ifdef LINUX
#ifdef THREADS
#include <pthread.h>
#endif
#endif

#ifdef _WIN32
#include <memory.h>
#endif

#include "fxmp.h"

#include "drv_dsp.h"

schar verbose = 0;

chn *channel;
ushort ord = 0, pat, row, tick = 0, tord = 0, trow = 0;
panel pantable[256];
driver *drv;

/* pff */
uchar globalvolume = 64;
int tempo;

static uchar vibratotab[32]={
	0, 24, 49, 74, 97,120,141,161,
	180,197,212,224,235,244,250,253,
	255,253,250,244,235,224,212,197,
	180,161,141,120, 97, 74, 49, 24};

/*   from mikmod */
static ulong lineartab[768] =
{
	535232, 534749, 534266, 533784, 533303, 532822, 532341, 531861,
	531381, 530902, 530423, 529944, 529466, 528988, 528511, 528034,
	527558, 527082, 526607, 526131, 525657, 525183, 524709, 524236,
	523763, 523290, 522818, 522346, 521875, 521404, 520934, 520464,
	519994, 519525, 519057, 518588, 518121, 517653, 517186, 516720,
	516253, 515788, 515322, 514858, 514393, 513929, 513465, 513002,
	512539, 512077, 511615, 511154, 510692, 510232, 509771, 509312,
	508852, 508393, 507934, 507476, 507018, 506561, 506104, 505647,
	505191, 504735, 504280, 503825, 503371, 502917, 502463, 502010,
	501557, 501104, 500652, 500201, 499749, 499298, 498848, 498398,
	497948, 497499, 497050, 496602, 496154, 495706, 495259, 494812,
	494366, 493920, 493474, 493029, 492585, 492140, 491696, 491253,
	490809, 490367, 489924, 489482, 489041, 488600, 488159, 487718,
	487278, 486839, 486400, 485961, 485522, 485084, 484647, 484210,
	483773, 483336, 482900, 482465, 482029, 481595, 481160, 480726,
	480292, 479859, 479426, 478994, 478562, 478130, 477699, 477268,
	476837, 476407, 475977, 475548, 475119, 474690, 474262, 473834,
	473407, 472979, 472553, 472126, 471701, 471275, 470850, 470425,
	470001, 469577, 469153, 468730, 468307, 467884, 467462, 467041,
	466619, 466198, 465778, 465358, 464938, 464518, 464099, 463681,
	463262, 462844, 462427, 462010, 461593, 461177, 460760, 460345,
	459930, 459515, 459100, 458686, 458272, 457859, 457446, 457033,
	456621, 456209, 455797, 455386, 454975, 454565, 454155, 453745,
	453336, 452927, 452518, 452110, 451702, 451294, 450887, 450481,
	450074, 449668, 449262, 448857, 448452, 448048, 447644, 447240,
	446836, 446433, 446030, 445628, 445226, 444824, 444423, 444022,
	443622, 443221, 442821, 442422, 442023, 441624, 441226, 440828,
	440430, 440033, 439636, 439239, 438843, 438447, 438051, 437656,
	437261, 436867, 436473, 436079, 435686, 435293, 434900, 434508,
	434116, 433724, 433333, 432942, 432551, 432161, 431771, 431382,
	430992, 430604, 430215, 429827, 429439, 429052, 428665, 428278,
	427892, 427506, 427120, 426735, 426350, 425965, 425581, 425197,
	424813, 424430, 424047, 423665, 423283, 422901, 422519, 422138,
	421757, 421377, 420997, 420617, 420237, 419858, 419479, 419101,
	418723, 418345, 417968, 417591, 417214, 416838, 416462, 416086,
	415711, 415336, 414961, 414586, 414212, 413839, 413465, 413092,
	412720, 412347, 411975, 411604, 411232, 410862, 410491, 410121,
	409751, 409381, 409012, 408643, 408274, 407906, 407538, 407170,
	406803, 406436, 406069, 405703, 405337, 404971, 404606, 404241,
	403876, 403512, 403148, 402784, 402421, 402058, 401695, 401333,
	400970, 400609, 400247, 399886, 399525, 399165, 398805, 398445,
	398086, 397727, 397368, 397009, 396651, 396293, 395936, 395579,
	395222, 394865, 394509, 394153, 393798, 393442, 393087, 392733,
	392378, 392024, 391671, 391317, 390964, 390612, 390259, 389907,
	389556, 389204, 388853, 388502, 388152, 387802, 387452, 387102,
	386753, 386404, 386056, 385707, 385359, 385012, 384664, 384317,
	383971, 383624, 383278, 382932, 382587, 382242, 381897, 381552,
	381208, 380864, 380521, 380177, 379834, 379492, 379149, 378807,

	378466, 378124, 377783, 377442, 377102, 376762, 376422, 376082,
	375743, 375404, 375065, 374727, 374389, 374051, 373714, 373377,
	373040, 372703, 372367, 372031, 371695, 371360, 371025, 370690,
	370356, 370022, 369688, 369355, 369021, 368688, 368356, 368023,
	367691, 367360, 367028, 366697, 366366, 366036, 365706, 365376,
	365046, 364717, 364388, 364059, 363731, 363403, 363075, 362747,
	362420, 362093, 361766, 361440, 361114, 360788, 360463, 360137,
	359813, 359488, 359164, 358840, 358516, 358193, 357869, 357547,
	357224, 356902, 356580, 356258, 355937, 355616, 355295, 354974,
	354654, 354334, 354014, 353695, 353376, 353057, 352739, 352420,
	352103, 351785, 351468, 351150, 350834, 350517, 350201, 349885,
	349569, 349254, 348939, 348624, 348310, 347995, 347682, 347368,
	347055, 346741, 346429, 346116, 345804, 345492, 345180, 344869,
	344558, 344247, 343936, 343626, 343316, 343006, 342697, 342388,
	342079, 341770, 341462, 341154, 340846, 340539, 340231, 339924,
	339618, 339311, 339005, 338700, 338394, 338089, 337784, 337479,
	337175, 336870, 336566, 336263, 335959, 335656, 335354, 335051,
	334749, 334447, 334145, 333844, 333542, 333242, 332941, 332641,
	332341, 332041, 331741, 331442, 331143, 330844, 330546, 330247,
	329950, 329652, 329355, 329057, 328761, 328464, 328168, 327872,
	327576, 327280, 326985, 326690, 326395, 326101, 325807, 325513,
	325219, 324926, 324633, 324340, 324047, 323755, 323463, 323171,
	322879, 322588, 322297, 322006, 321716, 321426, 321136, 320846,
	320557, 320267, 319978, 319690, 319401, 319113, 318825, 318538,
	318250, 317963, 317676, 317390, 317103, 316817, 316532, 316246,
	315961, 315676, 315391, 315106, 314822, 314538, 314254, 313971,
	313688, 313405, 313122, 312839, 312557, 312275, 311994, 311712,
	311431, 311150, 310869, 310589, 310309, 310029, 309749, 309470,
	309190, 308911, 308633, 308354, 308076, 307798, 307521, 307243,
	306966, 306689, 306412, 306136, 305860, 305584, 305308, 305033,
	304758, 304483, 304208, 303934, 303659, 303385, 303112, 302838,
	302565, 302292, 302019, 301747, 301475, 301203, 300931, 300660,
	300388, 300117, 299847, 299576, 299306, 299036, 298766, 298497,
	298227, 297958, 297689, 297421, 297153, 296884, 296617, 296349,
	296082, 295815, 295548, 295281, 295015, 294749, 294483, 294217,
	293952, 293686, 293421, 293157, 292892, 292628, 292364, 292100,
	291837, 291574, 291311, 291048, 290785, 290523, 290261, 289999,
	289737, 289476, 289215, 288954, 288693, 288433, 288173, 287913,
	287653, 287393, 287134, 286875, 286616, 286358, 286099, 285841,
	285583, 285326, 285068, 284811, 284554, 284298, 284041, 283785,
	283529, 283273, 283017, 282762, 282507, 282252, 281998, 281743,
	281489, 281235, 280981, 280728, 280475, 280222, 279969, 279716,
	279464, 279212, 278960, 278708, 278457, 278206, 277955, 277704,
	277453, 277203, 276953, 276703, 276453, 276204, 275955, 275706,
	275457, 275209, 274960, 274712, 274465, 274217, 273970, 273722,
	273476, 273229, 272982, 272736, 272490, 272244, 271999, 271753,
	271508, 271263, 271018, 270774, 270530, 270286, 270042, 269798,
	269555, 269312, 269069, 268826, 268583, 268341, 268099, 267857
};

/*  static ushort periodtab[96] = */
/*  { */
/*    907, 900, 894, 887, 881, 875, 868, 862, 856, 850, 844, 838, 832, 826, 820, 814, */
/*    808, 802, 796, 791, 785, 779, 774, 768, 762, 757, 752, 746, 741, 736, 730, 725, */
/*    720, 715, 709, 704, 699, 694, 689, 684, 678, 675, 670, 665, 660, 655, 651, 646, */
/*    640, 636, 632, 628, 623, 619, 614, 610, 604, 601, 597, 592, 588, 584, 580, 575, */
/*    570, 567, 563, 559, 555, 551, 547, 543, 538, 535, 532, 528, 524, 520, 516, 513, */
/*    508, 505, 502, 498, 494, 491, 487, 484, 480, 477, 474, 470, 467, 463, 460, 457}; */


/*  ulong *lineartab; */
/*
  i'll do that later

	void precalclinear()
	{
	sshort note,fine;
	slong period,freq;
	// Period = 10*12*16*4 - Note*16*4 - FineTune/2;
	// Frequency = 8363*2^((6*12*16*4 - Period) / (12*16*4));
	//lineartab=(ulong *)calloc(1, 96*256*4);
	for (note=0; note<96; note++)
	{
	for (fine=-128; fine<127; fine++)
	{
	period=(10*12+1-note)*64-fine/2;
	freq=8363*pow(2,(double)(6*12*16*4-period)/(12*16*4));
	printf("%d\n",freq);
	}
	}
	}
*/

int
note_to_period (int note, int finetune)
{
	return (((120 - note) << 7) - finetune) >> 3;		/* Linear */
}

int
period_to_bend (int period, int note, int finetune)
{
	int b;

	b = (100 * (((120 - note) << 4) - period)) >> 4;	/* Linear */
	return b / 100 * 100;
}

void
calc_pan_table ()
{
	int i;

	for (i = 0; i < 256; i++)
		{
			pantable[i].l = 64 - (i / 4);
			pantable[i].r = i / 4;
		}
}

int
fxmp_init (driver * d, int dev)
{
	drv = d;
	drv->dev = dev;
	if (drv->init () != 0) return 1;
	calc_pan_table ();
	/*  precalclinear(); */
	ord = 0;
	printf("+ fLare XM player %s init\n",FXMP_VERSION);
	return 0;
}

void
fxmp_load_patches (xm_module * xm)
{
	if (drv->type == TYPE_HARDWARE)
		{
			drv->load_patches (xm);
		}
}

void
fxmp_deinit ()
{
	if (drv->deinit != NULL)
		drv->deinit ();
}

float
frac (float bla)
{
	return bla - (int) bla;
}

ulong
getperiod (uchar note, char finetune)
{
#ifdef AMIGAPERIODS
	return (periodtab[(note % 12) * 8 + finetune / 16] * (1 - frac ((float) finetune / 16)) +
	        periodtab[(note % 12) * 8 + finetune / 16] * (frac ((float) finetune / 16))) * 16 / pow (2, note % 12);
#else
	return 10 * 12 * 16 * 4 - note * 16 * 4 - finetune / 2;
	/*  return (10*12+1-note)*64-finetune/2; */
#endif
}

ulong
getfreq (ulong period)
{
#ifdef AMIGAPERIODS
	return 8363 * 1712 / period;
#else
	/*  return 8363*pow(2,(double)(6*12*16*4-period)/(12*16*4)); */
	return lineartab[period % 768] >> (period / 768);
#endif
}

/* int majorCount = 0; */

void
process_tick_based (xm_module * xm, chn * channel)
{
	slong temp=0;
	uchar pos;
	xm_inst *insptr;

	/* volume slide */
	if (channel->volumeslide != 0)
		{
			temp = channel->volume + channel->volumeslide;
			if (temp < 0)
				temp = 0;
			if (temp > 64)
				temp = 64;
			channel->volume = (schar) temp;
		}

	/* porta up/down */
	if (channel->portaup != 0)
		channel->period -= channel->portaup;
	if (channel->portadown != 0)
		channel->period += channel->portadown;

	/* porta to note */
	if (channel->portanotespeed != 0)
		{
			/*    printf("%d -> %d\n",channel->period,channel->portanoteperiod); */

			temp = channel->portanoteperiod - channel->period;
			if (abs (temp) < channel->portanotespeed * (tempo - 1) && temp != 0)
				{
					channel->period = channel->portanoteperiod;
				}
			else if (temp != 0)
				{
					if (temp > 0)
						channel->period += channel->portanotespeed * (tempo - 1);
					else
						channel->period -= channel->portanotespeed * (tempo - 1);
				}
		}

	/* vibrato */
	if (channel->vibratospeed!=0)
		{
			pos=channel->vibratopos & 31;
			switch (channel->vibratowave)
				{
				case 3:
				case 0:
					temp=(vibratotab[pos]*channel->vibratodepth)>>7;
					if (channel->vibratopos<0) temp=-temp;
					break;
				case 1:
					temp=pos<<3;
					if (channel->vibratopos<0) temp=255-temp;
					temp=(temp*channel->vibratodepth)>>7;
					break;
				case 2:
					temp=(channel->vibratodepth*255)>>7;
					if (channel->vibratopos<0) temp=-temp;
					break;
				}
			channel->period+=temp;
			channel->vibratopos+=channel->vibratospeed;
			if (channel->vibratopos>31) channel->vibratopos-=64;
		}

	if ((channel->portaup != 0 || channel->portadown != 0 ||
	     channel->portanotespeed != 0 || channel->vibratospeed != 0)
	    && channel->sampleinc != 0)
		{
			if (drv->type == TYPE_SOFTWARE)
				{
					channel->sampleinc = ((channel->freq << 8) / SAMPLERATE) / 2;
					if (channel->pingpong == 1)
						channel->sampleinc = -channel->sampleinc;
				}
		}

	/* tremolo */
	if (channel->tremolospeed!=0)
		{
			pos=channel->tremolopos & 31;
			switch (channel->tremolowave)
				{
				case 3:
				case 0:
					temp=(vibratotab[pos]*channel->tremolodepth)>>6;
					if (channel->tremolopos<0) temp=-temp;
					break;
				case 1:
					temp=pos<<3;
					if (channel->tremolopos<0) temp=255-temp;
					temp=(temp*channel->tremolodepth)>>7;
					break;
				case 2:
					temp=(channel->tremolodepth*255)>>7;
					if (channel->tremolopos<0) temp=-temp;
					break;
				}
			/*
			  temp=vibratotab[channel->tremolopos & 31];
				temp=(temp*channel->tremolodepth)>>6;
				if (channel->tremolopos<0) temp=-temp;
			*/
			channel->volume += (schar) temp;
			if (channel->volume>64) channel->volume=64;
			if (channel->volume<0) channel->volume=0;
			channel->tremolopos+=channel->tremolospeed;
			if (channel->tremolopos>31) channel->tremolopos-=64;
		}

	if ((channel->portaup != 0 || channel->portadown != 0 ||
	     channel->portanotespeed != 0 || channel->vibratospeed != 0)
	    && channel->sampleinc != 0)
		{
			channel->freq = getfreq (channel->period);
			if (drv->type == TYPE_SOFTWARE)
				{
					channel->sampleinc = ((channel->freq << 8) / SAMPLERATE) / 2;
					if (channel->pingpong == 1)
						channel->sampleinc = -channel->sampleinc;
				}
		}


	/* envelopes (it looks really ugly, isn't it?, surprisingly it works) */
	if (channel->inst != 0)
		{
			insptr = &(xm->inst[channel->inst - 1]);

			if (insptr->voltype & 1)
				{
					if (insptr->voltype & 2)
						{
							if ((channel->keyoff == 0 && channel->env_volpos == channel->env_volsustain) ||
							    (channel->env_volpos >= channel->env_volend && !(insptr->voltype & 4)))
								{
									channel->env_volactive = 1;
								}
							else
								{
									channel->env_volactive = 0;
									channel->keyoff = 0;
								}
						}
					if (channel->env_volactive == 0)
						{
							channel->env_volpos++;

							if (insptr->voltype & 4)	/* looping enabled */

								{
									if (channel->env_volpos >= channel->env_volloopend)
										channel->env_volpos -= channel->env_vollooplen;
								}
							else
								/* no loop */
								{
									if (channel->env_volpos >= channel->env_volend)
										{
											channel->env_volactive = 1;
										}
								}
						}
				}
			if (insptr->pantype & 1)
				{
					if (insptr->pantype & 2)
						{
							if ((channel->keyoff == 0 && channel->env_panpos == channel->env_pansustain) ||
							    (channel->env_panpos >= channel->env_panend && !(insptr->pantype & 4)))
								{
									channel->env_panactive = 1;
								}
							else
								{
									channel->env_panactive = 0;
									channel->keyoff = 0;
								}
						}
					if (channel->env_panactive == 0)
						{
							channel->env_panpos++;

							if (insptr->pantype & 4)	/* looping enabled  */

								{
									if (channel->env_panpos >= channel->env_panloopend)
										channel->env_panpos -= channel->env_panlooplen;
								}
							else
								/* no loop */
								{
									if (channel->env_panpos >= channel->env_panend)
										{
											channel->env_panactive = 1;
										}
								}
						}
				}
		}
}

/* driver, dev, and i parameters will be removed */
int
process_row_based (xm_module * xm, int ofs, chn * channel, int i)
{
	uchar note, inst, vol, fx, parm;
	xm_sample *smpptr;
	xm_inst *insptr;
	int period;

	note = xm->pattern[pat][ofs].note;
	inst = xm->pattern[pat][ofs].inst;
	vol = xm->pattern[pat][ofs].vol;
	fx = xm->pattern[pat][ofs].fx;
	parm = xm->pattern[pat][ofs].parm;

	if (note!=0 && inst==0) inst = (uchar) channel->oldinst;
	channel->oldinst = inst;

	channel->hit = 0;

	if (verbose < 0)
		printf ("%2x %2x %2x %2x %2x | ", note, inst, vol, fx, parm);

	/* reset */

	if (inst > 0)
		channel->volume = xm->inst[inst - 1].sample[xm->inst[inst - 1].samplenum[note]].volume;

	channel->volfade = 0x8000;
	channel->volumeslide = 0;
	channel->portaup = 0;
	channel->portadown = 0;
	channel->portanotespeed = 0;
	channel->vibratospeed = 0;

	/*
	  if (note != 0 && note != 97 && inst != 0)
		{
		if (xm->inst[inst - 1].voltype & 1)
		{
		channel->env_volpos = 0;
		channel->env_volactive = 0;
		}
		if (xm->inst[inst - 1].pantype & 1)
		{
		channel->env_panpos = 0;
		channel->env_panactive = 0;
		}
		}
	*/

	if (note != 0 && note != 97 && fx != 3 && fx != 5)
		{
			channel->inst = inst;
			channel->hit = 1;

			if (channel->inst != 0)
				if (xm->inst[channel->inst - 1].numsamples == 0)
					channel->inst = 0;
			if (channel->inst != 0)
				{
					channel->insptr = insptr = &(xm->inst[channel->inst - 1]);
					channel->samplenum = insptr->samplenum[note];
					channel->smpptr = smpptr = &(insptr->sample[channel->samplenum]);

					channel->finetune = smpptr->finetune;
					channel->note = note + smpptr->relnote;
					channel->keyoff = 0;
					channel->pan = smpptr->pan;

					drv->set_patch (i, smpptr->patchnr);
					drv->set_note (i, note);

					if (insptr->voltype & 1)
						{
							channel->env_volpos = 0;
							channel->env_volactive = 0;
							channel->env_volend = insptr->volenv[insptr->numvolpts - 1].pos;
							if (insptr->voltype & 2)
								channel->env_volsustain = insptr->static_volsustain;
							if (insptr->voltype & 4)
								{
									channel->env_volloopstart = insptr->static_volloopstart;
									channel->env_volloopend = insptr->static_volloopend;
									channel->env_vollooplen = channel->env_volloopend - channel->env_volloopstart;
								}
						}
					if (insptr->pantype & 1)
						{
							channel->env_panpos = 0;
							channel->env_panactive = 0;
							channel->env_panend = insptr->panenv[insptr->numpanpts - 1].pos;
							if (insptr->pantype & 2)
								channel->env_pansustain = insptr->static_pansustain;
							if (insptr->pantype & 4)
								{
									channel->env_panloopstart = insptr->static_panloopstart;
									channel->env_panloopend = insptr->static_panloopend;
									channel->env_panlooplen = channel->env_panloopend - channel->env_panloopstart;
								}
						}

					/* supposed bending calculation, which does not work yet */
					period = note_to_period (channel->note, channel->finetune);
					channel->pitchbend = period_to_bend (period, channel->note, channel->finetune);
				}
		}

	/* key off */
	if (note == 97)
		{
			channel->keyoff = 1;
		}

	/* VOLUME EFFECTS */
	if (vol >= 0x10 && vol <= 0x50)
		channel->volume = vol - 0x10;

	if (vol >= 0x80 && vol <= 0x8F)
		{
			channel->volume -= vol - 0x80;

			if (channel->volume < 0)
				channel->volume = 0;
		}
	if (vol >= 0x90 && vol <= 0x9F)
		{
			channel->volume += vol - 0x90;

			if (channel->volume > 64)
				channel->volume = 64;
		}
	if (vol >= 0xC0 && vol <= 0xCF)
		{
			channel->pan = (vol - 0xC8) * 16;
		}
	if (vol >= 0xD0 && vol <= 0xDF)
		{
			channel->pan -= (vol - 0xD0);
			if (channel->pan<0) channel->pan=0;
		}
	if (vol >= 0xE0 && vol <= 0xEF)
		{
			channel->pan += (vol - 0xE0);
			if (channel->pan>255) channel->pan=255;
		}

	/* EFFECTS */
	if (fx != 0 || parm != 0)
		switch (fx)
			{
			case 0x01:			/* porta up */
				if (verbose > 0)
					printf ("PORTUP\n");
				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;
				channel->portaup = parm;
				break;

			case 0x02:			/* porta down */
				if (verbose > 0)
					printf ("PORTDN\n");
				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;
				channel->portadown = parm;
				break;

			case 0x03:			/* porta to note */

				if (note != 0 && channel->inst != 0)
					{
						insptr = &(xm->inst[channel->inst - 1]);
						smpptr = &(insptr->sample[channel->samplenum]);

						if (verbose > 0)
							printf ("%2d PORTA TO NOTE\n",i);	/* %d -> %d\n", channel->note+11, note+11); */
						channel->portanoteperiod = getperiod (note + smpptr->relnote + 11, smpptr->finetune);
					}
				/*      if (i==14) printf ("PERIOD %d -> %d\n", channel->period, channel->portanoteperiod); */

				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;

				channel->portanotespeed = parm;
				break;

			case 0x04:			/* vibrato */
				if (verbose>0) printf("VIBRATO\n");

				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;

				channel->vibratospeed = (parm>>4) & 0xF;
				channel->vibratodepth = (parm) & 0xF;

				/*
				  channel->vibratopos = 0; 
					FIXME: wtf?
					FIXME: gotta check if it should be reset or not too
				*/
				break;

			case 0x05:			/* porta to note + volume slide */
				if (verbose > 0)
					printf ("PORTA+VOLUMESLIDE\n");
				if (note != 0 && channel->inst != 0)
					{
						insptr = &(xm->inst[channel->inst - 1]);
						smpptr = &(insptr->sample[channel->samplenum]);

						channel->portanoteperiod = getperiod (note + smpptr->relnote + 11, smpptr->finetune);
					}

				channel->portanotespeed = channel->oldparm[0x03];

				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;

				channel->volumeslide = -(parm & 0xF);
				channel->volumeslide += (parm >> 4) & 0xF;
				break;

			case 0x06:			/* vibrato + volume slide */
				if (verbose>0) printf("VIBRATO+VOLUMESLIDE\n");

				channel->vibratodepth = (channel->oldparm[0x04]>>4) & 0xF;
				channel->vibratospeed = channel->oldparm[0x04] & 0xF;

				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;

				channel->volumeslide = -(parm & 0xF);
				channel->volumeslide += (parm >> 4) & 0xF;
				break;

			case 0x07:			/* tremolo */
				if (verbose>0) printf("TREMOLO\n");

				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;

				channel->tremolospeed = (parm>>4) & 0xF;
				channel->tremolodepth = parm & 0xF;
				break;

			case 0x08:			/* set panning */
				if (verbose > 0)
					printf ("PAN\n");

				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;

				channel->pan = parm;
				break;

			case 0x09:			/* sample offset */
				if (verbose > 0)
					printf ("%2d SAMPLEOFFSET\n",i);

				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;

				channel->samplepos = parm<<16;
				if ((channel->samplepos>>8)>channel->samplelen) channel->samplepos=(channel->samplelen-1)<<8;
				break;
			case 0x0A:			/* volume slide */
				if (verbose > 0)
					printf ("VOLSLIDE\n");

				if (parm == 0)
					parm = channel->oldparm[fx];
				else
					channel->oldparm[fx]=parm;

				channel->volumeslide = -(parm & 0xF);
				channel->volumeslide += (parm >> 4) & 0xF;
				break;
			case 0x0B:			/* jump to pattern */

				tord = parm;
				if (tord > xm->songlen - 1)
					return 1;
				trow = -1;
				/*      tick = tempo - 1;
				        pat = xm->order[ord]; */
				break;
			case 0x0C:			/* set volume */

				if (verbose > 0)
					printf ("VOLSET\n");

				channel->volume = parm;
				break;
			case 0x0D:			/* pattern break */

				tord = ord + 1;
				if (tord > xm->songlen - 1)
					return 1;
				trow = parm - 1;
				break;
			case 0x0F:			/* set speed */

				if (parm <= 0x1F)
					{
						if (verbose > 0)
							printf ("TEMPO %d\n", parm);
						xm->tempo = parm;
					}
				else
					{
						if (verbose > 0)
							printf ("BPM %d\n", parm);
						xm->bpm = parm;
					}
				break;
			case 0x10:			/* set global volume */
				globalvolume = parm;
				break;

			case 0x0E:
				if (verbose > 0)
					printf ("FINEVOLSLIDE\n");
				switch ((parm >> 4) & 0xF)
					{
					case 0x4:
						if ((parm & 0xF) < 4) channel->vibratowave=parm & 0xF;
						break;
					case 0x7:
						if ((parm & 0xF) < 4) channel->tremolowave=parm & 0xF;
						break;
					case 0xA:		/* fine volume slide up */

						channel->volume += parm & 0xF;
						if (channel->volume > 64)
							channel->volume = 64;
						break;
					case 0xB:		/* fine volume slide down */

						channel->volume -= parm & 0xF;
						if (channel->volume < 0)
							channel->volume = 0;

						break;
					}
				break;
			}
	return 0;
}

int
ticker (xm_module * xm)
{
	ulong i, ofs;

	tick++;

	tempo = xm->tempo;
	if (tempo == 0)
		tempo = 1;

	if (ord != tord)
		{
			ord = tord;
			row = trow;
			tick = tempo - 1;
			pat = xm->order[ord];
		}

	/* processing tick based effects and envelopes */
	for (i = 0; i < xm->numchans; i++)
		process_tick_based (xm, &channel[i]);

	/* row based effects */
	if (tick >= tempo || xm->tempo == 0)
		{
			tick = 0;
			row++;
			if (row >= xm->patheader[pat].numrows)
				{
					row = 0;
					tick = 0;
					ord++;

					if (ord > xm->songlen - 1)
#ifndef LOOP
						return 1;
#else
						ord = xm->restartpos;
#endif
					pat = xm->order[ord];
				}
			tord = ord;
			trow = row;
			ofs = row * xm->numchans;
			for (i = 0; i < xm->numchans; i++)
				if (process_row_based (xm, ofs + i, &channel[i], i) != 0)
					return 1;
			if (verbose < 0)
				printf ("\n");
		}				/* row */

	drv->ticker (xm);

	return 0;
}

void
fxmp_set_ord (int orderNr)
{
	ord = tord = orderNr;
}

int 
fxmp_get_bytes (void)
{
	return drv->get_bytes();
}

ushort
fxmp_get_ord (void)
{
	return ord;
}

#ifdef LINUX
void *threadfunc(void *arg)
{
	while (!ticker ((xm_module *)arg));
#ifdef THREADS
	pthread_exit(0);
#endif
	return 0;
}
#endif

int
fxmp_poll (xm_module * xm)
{
	return ticker (xm);
}

void
fxmp_play (xm_module * xm)
{
#ifdef THREADS
	pthread_t pth;
	/*    pthread_attr_t pth_attr; */
#endif

	row = -1;
	tick = xm->tempo - 1;
	pat = xm->order[ord];

	memset (channel, 0, sizeof (chn) * xm->numchans);

	/*
	  if (drv->type == TYPE_HARDWARE)
		{
		seq_start_timer ();
		seq_sync ();
		}
	*/
#ifdef THREADS
#ifdef LINUX
	/*
	  pthread_attr_init(&pth_attr);
		pthread_attr_setschedpolicy(&pth_attr,-20);
	*/
	if (pthread_create(&pth,NULL,threadfunc,(void *)xm)!=0) { printf("Can't create thread!\n"); return; }
#endif
#else
	/*   while (!ticker (xm)); */
#endif
}
