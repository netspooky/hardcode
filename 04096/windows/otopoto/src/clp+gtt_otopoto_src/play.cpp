/*
	This file is part of "otopoto / Collapse & Gatitos".

    "otopoto / Collapse & Gatitos" is free software: you can redistribute
	it and/or modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation, either version 3 of the
	License, or (at your option) any later version.

    "otopoto / Collapse & Gatitos" is distributed in the hope that it will
	be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
	of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with "otopoto / Collapse & Gatitos".  If not, see 
	<http://www.gnu.org/licenses/>.
*/

#include "defines.h"
#include "sizedtypes.h"
#include "play.h"
#include "synth.h"
#include "song.h"
#include "thesong.h"
#include <stdio.h>

#pragma bss_seg ("data_zero")
Voice voices[NUM_CHANNELS];
float mix_buf[BUFFER_SIZE], current_time=0.0f;
uint8  last_voice_used=0;
uint32 rows_played=0; // total of rows played
#pragma bss_seg ()

#pragma data_seg ("data_song")
float row_duration=0.17578125f; // denominator == RPM
uint8  cur_pos= 255;    // current position in the pattern playlist
uint8  cur_row=TRACK_LENGTH-1;    // current row in the current pattern
#pragma data_seg ()

//extern float drawbuf[BUFFER_SIZE];

#ifdef OUTFILE
extern FILE *fout;
#endif

#pragma code_seg ("code_play")
#ifdef WINDOWS_32
	void play (void *stream, int len)
#elif defined(LINUX)
	void play(Song *s, Uint8 *stream, int len)
#endif
{
    int num_samples=len>>1;
    int16 *buf=(int16 *)stream;
    current_time += num_samples/SAMPLE_RATE;

    memset(mix_buf, 0, BUFFER_SIZE*sizeof(float));

    float time_since_last_row_played = current_time - rows_played * row_duration;
    if (time_since_last_row_played > row_duration ) {
        ++rows_played;
		++cur_row;
		if (cur_row == TRACK_LENGTH)
		{
			cur_row=0;
			++cur_pos;
		}

        int buf_start = ((time_since_last_row_played+row_duration)*SAMPLE_RATE)-num_samples;

		/*	
        if (thesong.playlist[cur_pos]==255) { // loop at end of song
            cur_pos=0;
        }
		*/
	

        uint8 cur_ptn=thesong.playlist[cur_pos];
		//printf("rows_played=%d, cur_pos=%d, cur_ptn=%d, cur_row=%d\n", rows_played, cur_pos, cur_ptn, cur_row);

        for (uint8 i=0; i<NUM_CHANNELS; ++i) {
            unsigned int trknum=thesong.patterns[cur_ptn][i];

			Track *cur_trk = &thesong.tracks[trknum];
			int8 trans = thesong.transpose[cur_ptn][i];

			uint8 cell=cur_trk->notes[cur_row];
			if (cell) {
				float vol = (cell>>4) * 0.1f;
				unsigned int note = cell & 0x0F;
				note+=trans;

				memset(&voices[i], 0, sizeof(Voice));
				voices[i].pitch = detune(440.0f,note-21,0);
				voices[i].pos = buf_start;
				voices[i].ins = &thesong.instrument_data[cur_trk->instrument];
				voices[i].vol = vol;
			}
        }
    }

    // Ahora vamos sintetizando las voces
    for (int i=0; i < NUM_CHANNELS; ++i)
    {
		synth(&voices[i], num_samples, mix_buf);
    }

    // convertimos a Sint16
    for (int i=0; i<num_samples; ++i)
    {
        float tmp = mix_buf[i];
        //if (tmp>1.0f) tmp=1.0f;
        //else if(tmp<-1.0f) tmp=-1.0f;
        buf[i]=(int16)(tmp*30720.0f);
    }
}

