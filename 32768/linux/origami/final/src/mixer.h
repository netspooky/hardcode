#ifndef __MIXER_H__
#define __MIXER_H__

// N-input stereo mixer with panning

// Inputs:
// 3n     - Input signal
// 3n + 1 - Vol
// 3n + 2 - Pan

// Outputs:
// 0 - Out left
// 1 - Out right

typedef struct {
    output_signal out;
    input_signal in;

    int n_channels;
} Mixer;

Mixer *mixers[10];
int n_mixers = 0;

Mixer *new_mixer(int channels)
{
    Mixer *mix = malloc(sizeof(Mixer));
    make_conns(mix, channels * 3, 2);
    
    mix->n_channels = channels;

    mixers[n_mixers++] = mix;
    return mix;
}

void process_mixer(Mixer *mix){
    int i;

    OUT(mix, 0) = 0.0f;
    OUT(mix, 1) = 0.0f;

    for (i=0; i<mix->n_channels; i++){
	float pan_l = 1.0f - IN(mix, i*3 + 2);
	float pan_r = 1.0f + IN(mix, i*3 + 2);
	OUT(mix, 0) += IN(mix, i*3) * IN(mix, i*3 + 1) * pan_l;
	OUT(mix, 1) += IN(mix, i*3) * IN(mix, i*3 + 1) * pan_r;
    }
}

#endif
