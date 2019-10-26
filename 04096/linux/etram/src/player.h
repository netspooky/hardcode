/*
---------------------
This is the source of etram/Collapse, a 4k intro released at breakpoint'05
Copyright (C) 2005 by Bernat Muñoz García (aka shash/Collapse)
Linux port (C) 2005 by Jorge Gorbe Moya (aka slack/Necrostudios)

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; version 2
of the License.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
---------------------
*/
#define NUMSAMPLES 44100*8
#define SAMPLESIZE NUMSAMPLES*2
#define	PLAYFREQ   44100
#define NUMLOOPS   12
/*
// Standard .wav header
typedef struct {
	char			riff_head[4];
	unsigned int	riff_size;
	char			wave_head[4];
	char			fmt_head[4];
	unsigned int	fmt_size;
	unsigned short	format;
	unsigned short	chans;
	unsigned int	samplerate;
	unsigned int	bytespersec;
	unsigned short	bytespersamp;
	unsigned short	bitspersamp;
	char			data_head[4];
	unsigned int	data_size;
} PLAYERWAVE;
*/
// Wave header
/*
PLAYERWAVE mywave={'R','I','F','F',
					sizeof(PLAYERWAVE)+NUMSAMPLES*NUMLOOPS*2,
					'W','A','V','E','f','m','t',' ',
					0x10,1,1,
					PLAYFREQ,
					PLAYFREQ*2,
					2,16,'d','a','t','a',
					SAMPLESIZE*NUMLOOPS};
*/
// Worst hack ever to get better compression
short			datawave[NUMSAMPLES*NUMLOOPS*2];

// Wraping to get some nice sounding distortion
float Wrap (float val, float limit)
{
	if (val > limit)	
	{	
		return Wrap (limit-val+limit, limit);
	}
	else if (val < -limit)	
	{	
		return Wrap (-limit-val-limit, limit);	
	}

	return val;
}

// Init Sound, and play
__attribute__((always_inline))
static inline void initPlayer (void)
{
	float	*bombo  = (float*) fn.malloc (44100*4), 
			*sinte1 = (float*) fn.malloc (88200*4), 
			*sinte2 = (float*) fn.malloc (88200*4),
			bomboFreq=2.0f,  sinte1Freq=2.0f, sinte2Freq=2.0f;

	u32 sintePtr = 0;

	// Drum alike sample
	for (int i = 0; i < 44100; ++i)
	{
		float env = (1.0f-(i/22050.0f));

		if (env < 0.0f) { env = 0.0f; }

		bombo[i] = sinf((i/44100.0f)*360.0f*bomboFreq)*env;

		bomboFreq -= 0.0001f;
	}

	// Synth alike samples
	for (int i = 0; i < 88200; ++i)
	{
		float env = sinf(i/88200.0f);

		if (env < 0.0f) { env = 0.0f; }

		sinte1[i] = Wrap (sinf((i/88200.0f)*360.0f*sinte1Freq)*env, 0.2f);
		sinte1Freq = fabsf(cosf(i/88200.0f)*sinf(i/40000.0f))+1.5f;

		sinte2[i] = Wrap(sinf((i/88200.0f)*360.0f*sinte2Freq)*env, 0.5f);
		sinte2Freq = fabsf(cosf(i/88200.0f))+1.5f;
	}

	for (int i = 0; i < NUMSAMPLES*NUMLOOPS; ++i)
	{
		// Base sound
		float currSample = sinte1[sintePtr/3];

		if (sintePtr > 74000*3)	{	sintePtr = 35000*3;	}
		
		sintePtr ++;

		// Create the sound mixing in a rather ugly manner the 3 samples
		if (i > 44100*10 && i < 44100*30)
		{
			currSample = (currSample+sinte1[((int)(i*(1.0f + (i-44100*10)/(4400.0f)))+40000)%88200])/2.0f;
			currSample = (currSample+bombo[(i>>1)%22100])/2.0f;
		}
		else if (i > 44100*30 && i < 44100*68)
		{
			currSample = (currSample+bombo[(int)(i/(2.0f - (i-44100*30)/(44100.0f*30)))%22100])/2.0f;
			currSample = (currSample+sinte2[(int)(i*(1.0f + (i-44100*30)/(4400.0f)))%88200])/2.0f;
			currSample = (currSample+sinte2[((int)(i*(1.0f + (i-44100*30)/(4400.0f)))+40000)%88200])/2.0f;
		}
		// Noise for the end part mixed with the drum
		else if (i > 44100*68 && i < 44100*75)
		{
			currSample = (currSample+0.7f*bombo[(int)(i/(2.0f - (i-44100*30)/(44100.0f*30)))%22100])/2.0f;
			currSample = (currSample+((fn.rand()%256)/(1024.0f-(i/4410.0f))))/2.0f;
		}
		// Some noise for the end part
		else if (i > 44100*75)
		{
			currSample = (currSample+((fn.rand()%256)/(1024.0f-(i/6000.0f))))/2.0f;
		}

		// If the mix fucked up
		if (currSample > 1.0f) { currSample = 1.0f; }

		// Transform to signed shot the sample
		datawave[i] = (signed short)(currSample*32768.0f);
	}

	// Some filtering to get better sounding wave
	for (int x = 0; x < 10; x++)
	for (int i = 1; i < NUMSAMPLES*NUMLOOPS; ++i)	
	{
		datawave[i] = (datawave[i-1] + datawave[i]) >> 1;
	}

    // Play the entire wave with PlaySound, rather ugly but minimal sized
//	PlaySound((char*)&mywave,NULL,SND_ASYNC|SND_LOOP|SND_MEMORY);

	return;
}
