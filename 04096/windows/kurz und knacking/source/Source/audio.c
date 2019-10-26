#include "audio.h"
#include "utility.h"
#include <mmsystem.h>

#ifdef AUDIO

#define KICK_TIME		0
#define HIHAT_TIME		1
#define BASS_TIME		2

#define KICK_PAT		0
#define HIHAT_PAT		1

#define LAST_TICK		0
#define PAT_TICK		1

#define PTR_1			0
#define PTR_2			1

#define MAXCOMBS 6

typedef struct {

	int		delay;
	int		ofs;
	float	damp;
	short	*buf;

} combfilter;

float kick(float t) {
	return clamp((1.0f - tan(t * PI * 0.75f)) * sin(4.5f * PI * sqrt(t * 433.0f)) * 3.0f, -1.0f, 1.0f);
}

float hihat(float t) {

	if(t >= 0.1f)
		return 0.0f;

	return (0.85f - tan(1.6f * t * PI)) * randf(-1.f, 1.f);
}

float hsqr(float a) {
	return sin(a) * 0.7f + (a > 0 ? 1 : -1) * 0.3f;
}

float bass(float t) {

	t += 8.5f;

	return hsqr(sin(4.0f * PI * t * (1.0f + (1.0f + sin(100.0f * PI * t + sin(t) * 15.0f)) / 32.0f))) * 0.8f * (0.5f + sin(t * 22.f) * 0.5f);
}

void audio_prerender(wavdata_t** wav, int duration, int samplerate) {

	int				i;
	int				j;
	int				k;
	float			out;
	float			fade;
	combfilter		c[MAXCOMBS];

	short*			ptr[2];
	float			invsamplerate;

	unsigned char   ticks[2];

	float			times[3];
	unsigned int	patterns[2];

	//*wav = (wavdata_t*)GlobalAlloc(GPTR, (sizeof(wavdata_t) - 2 + duration * samplerate * 2));
	*wav = (wavdata_t*) GlobalAlloc(GPTR, (44 + duration * samplerate * 2));
	(*wav)->riffid = 'FFIR';
	(*wav)->riffsize = duration * samplerate * 2 + 36;
	(*wav)->waveid = 'EVAW';
	(*wav)->chunkid = ' tmf';
	(*wav)->chunksize = 16;
	(*wav)->format = 1;
	(*wav)->channels = 1;
	(*wav)->samplerate = samplerate;
	(*wav)->bytespersec = samplerate * 2;
	(*wav)->blockalign = 2;
	(*wav)->bitspersample = 16;
	(*wav)->dataid = 'atad';
	(*wav)->datasize = duration * samplerate * 2;

	ptr[PTR_1] = &((*wav)->data);
	ptr[PTR_2] = ptr[PTR_1];

	patterns[KICK_PAT]	= 0x8888888A;
	patterns[HIHAT_PAT]	= 0x22222223;

	ticks[LAST_TICK]	= 0x1;
	ticks[PAT_TICK]		= 0x0;
	invsamplerate		= 1.0f / (float)samplerate;

	times[KICK_TIME]	= 999.0f;
	times[HIHAT_TIME]	= 999.0f;
	times[BASS_TIME]	= 0.0f;

	// pre-render track
	for(i=0; i<duration * samplerate; i++) {

		ticks[PAT_TICK] = (i / 4410) % 32;

		if(ticks[LAST_TICK] != ticks[PAT_TICK]) {

			if(PATISSET(patterns[KICK_PAT], ticks[PAT_TICK]))
				times[KICK_TIME] = 0.0f;

			if(PATISSET(patterns[HIHAT_PAT], ticks[PAT_TICK]))
				times[HIHAT_TIME] = 0.0f;

			ticks[LAST_TICK] = ticks[PAT_TICK];
		}

		*ptr[PTR_1] = (short)((	kick(times[KICK_TIME]) * 0.35f +
								hihat(times[HIHAT_TIME]) * 0.27f +
								bass(times[BASS_TIME]) * 0.3f	) * 32000.f);

		times[KICK_TIME]	+= invsamplerate;
		times[HIHAT_TIME]	+= invsamplerate;
		times[BASS_TIME]	+= invsamplerate;

		ptr[PTR_1]++;
	}

	// filter init
	for(i=0; i<MAXCOMBS; i++) {

		c[i].delay	= (int)randf(2000, 3000);
		//c[i].delay	= 2000;
		c[i].damp	= randf(0.2f, 0.6f);
		//c[i].damp	= 0.5f;
		c[i].ofs	= 0;
		c[i].buf	= (short*) GlobalAlloc(GPTR, c[i].delay * 2);

		for(j=0; j<c[i].delay; j++)
			c[i].buf[j] = 0;
	}

	// filter track
	fade = 1.f;
	for(i=0; i<duration * samplerate; i++) {

		out = 0;
		
		for(j=0; j<MAXCOMBS; j++)
		{
			k = c[j].ofs - c[j].delay;
			if(k < 0)
				k = c[j].delay - 1;

			out += c[j].buf[c[j].ofs++ % c[j].delay] = ((*ptr[PTR_2]) >> 1) + (short)(c[j].buf[k % c[j].delay] * c[j].damp);
		}
		
		if(i > (duration * samplerate - 44100 * 15))
			fade -= 1.f / (44100 * 15);

		out *= fade;

		*ptr[PTR_2]++ = (short)clamp(out * 0.5f, -32000.0f, 32000.0f);
	}
}

void audio_play(wavdata_t* wav) {
	PlaySound((char*)wav, 0, SND_MEMORY | SND_ASYNC/*| SND_SYNC*/);
}

#endif