#ifndef __SEQUENCER_H__
#define __SEQUENCER_H__

#include "syn_types.h"
#include "notes.h"

// Sequencer

// Inputs:
// Outputs:
// 0 - frequency 
// 1 - gate 
// [2 - fx out 1]
// ...

float freqtable[] = { // A_5 == 440
  0.0f,       // sailöns
    8.1757989f, // C
    8.6619572f, // C#
    9.1770240f, // D
    9.7227182f, // D#
    10.300861f, // E
    10.913382f, // F
    11.562326f, // F#
    12.249857f, // G
    12.978271f, // G#
    13.750000f, // A
    14.567618f, // A#
    15.433853f  // H
};

float pows[] = {
    1.0f,
    2.0f,
    4.0f,
    8.0f,
    16.0f,
    32.0f,
    64.0f,
    128.0f
};

typedef struct {
    output_signal out;
    input_signal in;

    unsigned char *patterns;
    unsigned char *order;
    int p_pos; // pattern row
    int o_pos; // current pos. in orderlist
    int sub;   // n. of samples from the beginning of the current tick
    int row_ticks; // how many ticks is a single row
    int n_tracks; // number of tracks
    int n_fx; // number of effect channels
} Sequencer;

Sequencer *sequencers[10];
int n_sequencers = 0;

Sequencer *new_sequencer(int n_tracks, int n_fx, int rt,
			 unsigned char *patterns,
			 unsigned char *order)
{
  Sequencer *seq = malloc(sizeof(Sequencer));
  make_conns(seq, 0, n_tracks * 2 + n_fx);

    seq->sub = 0;
    seq->p_pos = 0;
    seq->o_pos = 0;
    seq->n_tracks = n_tracks;
    seq->n_fx = n_fx;
    seq->row_ticks = rt;
    seq->patterns = patterns;
    seq->order = order;

    sequencers[n_sequencers++] = seq;
    return seq;
}

void process_sequencer(Sequencer *seq)
{
    if ((seq->sub % (TICKLEN * seq->row_ticks)) == 0){
	int i;
	int pa_pos = (PATTERN_LEN *
		      (seq->order[seq->o_pos]) +
		      seq->p_pos) * (seq->n_tracks + seq->n_fx);

	// tracks
	for (i=0; i<seq->n_tracks; i++){
	    unsigned char row = seq->patterns[pa_pos++];
	    char note = row & 0x0f;
	    float oct = pows[row >> 4];

	    if (note == 0){
		OUT(seq, i*2 + 1) = 0.0f;
	    } else{
		OUT(seq, i*2 + 0) = freqtable[(int)note] * oct;
		OUT(seq, i*2 + 1) = 1.0f;
	    }
	}
	
	// effects
	for (i=0; i<seq->n_fx; i++){
	    OUT(seq, 2*seq->n_tracks + i) =
		(float)(seq->patterns[pa_pos++] / 128.0f);
	}

	// order
	seq->p_pos++;
	if (seq->p_pos >= PATTERN_LEN){
	    seq->p_pos = 0;
	    if (seq->order[++(seq->o_pos)] == END){
		seq->o_pos = 0;
	    }
	}
	seq->sub = 0;
    }
    seq->sub++;
}

#endif
