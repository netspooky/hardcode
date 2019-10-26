#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "synth.h"
#include "play.h"

#define NUM_VOICES 32

Voice voices[NUM_VOICES];
float mix_buf[BUFFER_SIZE];

#include "song.h"

int cur_pos, cur_row=-1;
float current_time=0;
int frase_trans;
int rows_played;
float global_vol=1.0f;


static void play (void *stream, long len)
{

	int cur_ptn;
	Track *cur_trk;

	int i, j;
	int trans;
        unsigned int num_samples=len>>1;
	float tmp;
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
					cur_pos=(cur_pos+1)%12;
					if (cur_pos%4==0)
					{
						frase_trans=rand_4k()%12-6;
					}
                }
		
		cur_ptn=song.playlist[cur_pos];
		
		// Hihat constante en cada row
		/*
		for (j=0; j<NUM_VOICES; ++j)
		{
			if (!voices[j].active)
				break;
		}
		*/
		voices[0].pitch = 308000000.0f;//440.0f*fn.powf(2.0f,(song.rhythm_notes[0]-45.0f)/12.0f);
		voices[0].pos = 0;
		voices[0].ins = &song.insts[0];
		voices[0].vol = 0.03f+0.07f*whitenoise();
		voices[0].active = 1;
				
		for (i=0; i<NUM_CHANNELS; ++i)
		{
			Uint8 chanval=song.chans[i].pat[cur_ptn];
			Uint8 channum=chanval & 0x0F;
			cur_trk = &song.tracks[channum];
			trans = ((chanval) >> 4)+frase_trans;

			Uint8 note = (cur_trk->notes[cur_row] & 0x3F);
			float vol = (6 - ((cur_trk->notes[cur_row])>>6)) * 0.166f;
			
			if (note)
			{
				note+=trans;
				for (j=1; j<NUM_VOICES; ++j)
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
                tmp = mix_buf[i]*global_vol;
		
		#ifndef SYNTH_NOCLAMP
		if (tmp>1.0f) tmp=1.0f;
		else if(tmp<-1.0f) tmp=-1.0f;
		#endif
		
		mix_buf[i]=tmp;
                buf[i]=(Sint16)(tmp*32767.0f);
        }

	#ifdef OUTFILE
        fwrite(buf, sizeof(Sint16), num_samples, fout);
	#endif

}