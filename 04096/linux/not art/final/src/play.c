#include "SDL.h"
#include "dl_init.h"
#include "synth.h"
#include "play.h"

extern float flash;
extern float fade;
//#define OUTFILE "output.raw"

#ifdef OUTFILE
#include <stdio.h>
FILE *fout;
#endif

#define NUM_VOICES 32

Voice voices[NUM_VOICES];
float mix_buf[BUFFER_SIZE];

#include "song.h"

int cur_pos, cur_row=-1;
float current_time;

static void play(Song *s, Uint8 *stream, int len)
{
	static int rows_played;

	Pattern *cur_ptn;
	Track *cur_trk;

	int i, j;
	unsigned int trans;
        unsigned int num_samples=len>>1;
	float tmp;
        Sint16 *buf=(Sint16 *)stream;

	current_time += num_samples/SAMPLE_RATE;
	flash -= 0.1f;

	//__builtin_memset(mix_buf, 0, BUFFER_SIZE*sizeof(float));
	
	__asm__("rep; stosl;"::"a"(0), "c"(BUFFER_SIZE), "D"(mix_buf));

        if ((current_time - rows_played * s->row_duration) > s->row_duration)
        {
                ++rows_played;
                ++cur_row;

                if (cur_row == TRACK_LENGTH) // end of track
                {
                        cur_row=0;
                        ++cur_pos;
                }

		if (s->playlist[cur_pos]==255) cur_pos=0;
		
		cur_ptn=&s->ptns[s->playlist[cur_pos]];
		for (i=0; i<NUM_CHANNELS; ++i)
		{
			Uint8 chanval=cur_ptn->channels[i];
			Uint8 channum=chanval & 0x0F;
			cur_trk = &s->tracks[channum];
			trans = (chanval) >> 4;

			Uint8 note = cur_trk->notes[cur_row];
			
			if (note)
			{
				if (channum==1){
					//__builtin_printf("pum "); fflush(stdout);
					flash=1.0f;
				}
				

				note+=trans;
				for (j=0; j<NUM_VOICES; ++j)
				{
					if (!voices[j].active)
						break;
				}
				
				voices[j].pitch = 440.0f*fn.powf(2.0f,(note-45.0f)/12.0f);
				voices[j].pos = 0.0f;
				voices[j].ins = &s->insts[cur_trk->instrument];
				voices[j].vol = 0.3f;
				voices[j].active = 1;
			}
		}


	}

        for (i=0; i<NUM_VOICES; ++i)
        {
                if (voices[i].active)
                {
                        voices[i].active=synth(&voices[i], num_samples, mix_buf);
                }
        }

        // conversion to Sint16
        for (i=0; i<num_samples; ++i)
        {
                tmp = mix_buf[i];
		//if (tmp>1.0f) tmp=1.0f;
		//else if(tmp<-1.0f) tmp=-1.0f;
		//mix_buf[i]=tmp;
                buf[i]=(Sint16)(tmp*32767.0f);
        }

	#ifdef OUTFILE
        fwrite(buf, sizeof(Sint16), num_samples, fout);
	#endif

}

SDL_AudioSpec desired={44100,
			AUDIO_S16SYS,
			1,
			0,
			BUFFER_SIZE,
			0,
			0,
			(void (*)(void *, Uint8 *, int)) play,
			&song};
