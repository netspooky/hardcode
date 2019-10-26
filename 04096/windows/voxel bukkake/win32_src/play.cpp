#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "synth.h"
#include "play.h"

//#define OUTFILE "salida.raw"

#ifdef OUTFILE
#include <stdio.h>
FILE *fout;
#endif
#define NUM_VOICES 32

Voice voices[NUM_VOICES];
float mix_buf[BUFFER_SIZE];

#include "song.h"

int cur_pos, cur_row=-1;
float current_time=0;

extern int cube_size;
extern int current_effect;
extern Uint8 negativo;
//extern Uint8 end;
extern float fade;

static void play (void *stream, long len)
{
	static int rows_played;

	int cur_ptn;
	Track *cur_trk;

	unsigned int i, j;
	unsigned int trans;
	unsigned int num_samples=len>>1;
	//float tmp;
    Sint16 *buf=(Sint16 *)stream;

	current_time += num_samples/SAMPLE_RATE;

	memset(mix_buf, 0, BUFFER_SIZE*sizeof(float));
	
	//__asm__("rep; stosl;"::"a"(0), "c"(BUFFER_SIZE), "D"(mix_buf));

	if ((current_time - rows_played * song.row_duration) > song.row_duration)
	{
		++rows_played;
		++cur_row;

		if (cur_row == TRACK_LENGTH) // fin de pista
		{
			cur_row=0;
			++cur_pos;
			current_effect = (current_effect + (rand_4k()%2+1))%3;
		}


		if (song.playlist[cur_pos]==255) {
			ExitProcess (0);
		}

		cur_ptn=song.playlist[cur_pos];

		if (cur_ptn==20)
		{
			fade=1.0f-((15-cur_row)/15.0f);
		}

		for (i=0; i<NUM_RHYTHM_CHANNELS; ++i)
		{
			Uint16 steps = song.rhythms[i].pat[cur_ptn];
			if (steps & (1<<(15-cur_row)))
			{
				//** SYNCHRO GOES HERE **
				if (i==0){
					cube_size=16;
					negativo=1;
				}
				else {
					cube_size=5;
					negativo=0;
				}

				for (j=0; j<NUM_VOICES; ++j)
				{
					if (!voices[j].active)
						break;
				}
				voices[j].pitch = 440.0f*pow_4k(2.0f,(song.rhythm_notes[i]-45.0f)/12.0f);
				voices[j].pos = 0;
				voices[j].ins = &song.insts[song.rhythm_insts[i]];
				voices[j].vol = 0.4f;
				voices[j].active = 1;
			}
		}

		for (i=0; i<NUM_CHANNELS; ++i)
		{
			Uint8 chanval=song.chans[i].pat[cur_ptn];
			Uint8 channum=chanval & 0x0F;
			cur_trk = &song.tracks[channum];
			trans = (chanval) >> 4;

			Uint8 note = (cur_trk->notes[cur_row] & 0x3F);
			float vol = (4 - ((cur_trk->notes[cur_row])>>6)) * 0.25f;

			if (note)
			{
				note+=trans;
				for (j=0; j<NUM_VOICES; ++j)
				{
					if (!voices[j].active)
						break;
				}

				voices[j].pitch = 440.0f*pow_4k(2.0f,(note-45.0f)/12.0f);
				voices[j].pos = 0;
				voices[j].ins = &song.insts[cur_trk->instrument];
				voices[j].vol = 0.1f*vol;
				voices[j].active = 1;
			}
		}
	}

	// Ahora vamos sintetizando las voces
	for (i=0; i<NUM_VOICES; ++i)
	{
		if (voices[i].active)
		{
			voices[i].active=synth(&voices[i], num_samples, mix_buf);
		}
	}

	// convertimos a Sint16
	for (i=0; i<num_samples; ++i)
	{
		float tmp = mix_buf[i];
		if (tmp>1.0f) tmp=1.0f;
		else if(tmp<-1.0f) tmp=-1.0f;
		//mix_buf[i]=tmp;
		buf[i]=(Sint16)(tmp*32767.0f);
	}

#ifdef OUTFILE
	fwrite(buf, sizeof(Sint16), num_samples, fout);
#endif
}
/*
SDL_AudioSpec desired={44100,
			AUDIO_S16SYS,
			1,
			0,
			BUFFER_SIZE,
			0,
			0,
			(void (*)(void *, Uint8 *, int)) play,
			&song};
*/