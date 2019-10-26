#ifndef __OSCILLATOR_H__
#define __OSCILLATOR_H__

// Oscillator

// Inputs:
// 0 - Frequency modulation
// 1 - Amplitude modulation

// Outputs:
// 0 - Osc out

enum {OSC_MOD_FREQ, OSC_MOD_AMP};
enum {OSC_OUT_SIGNAL};

enum {SAW, SQUARE, TRIANGLE, NOISE};

typedef struct {
    output_signal out;
    input_signal in;
    
    float frequency;
    float amplitude;

    int mod_counter;
    int shape;
} Oscillator;

Oscillator *oscillators[40];
int n_oscillators = 0;

Oscillator *new_oscillator(char shape, float freq, float amp)
{
    Oscillator *osc = malloc(sizeof(Oscillator));
    make_conns(osc, 2, 1);
    
    osc->shape = shape;
    osc->frequency = freq;
    osc->amplitude = amp;
    osc->mod_counter = 0;

    oscillators[n_oscillators++] = osc;
    return osc;
}

void process_oscillator(Oscillator *osc)
{
  
    int add = (int)(10 * osc->frequency * IN(osc, 0));
    osc->mod_counter = (osc->mod_counter + add) % (SRATE * 10);
    
    switch(osc->shape){
    case SAW:
	OUT(osc, 0) = (((((float)(osc->mod_counter)) / SRATE) - 5.0f) / 5.0f);
	break;
	
    case SQUARE:
	if (osc->mod_counter < (SRATE * 5)){
	    OUT(osc, 0) = 1.0f;
	} else{
	    OUT(osc, 0) = -1.0f;
	}
	break;
	
    case TRIANGLE:
	if (osc->mod_counter < (SRATE * 5)){
	    OUT(osc, 0) = ((float)osc->mod_counter) / (SRATE * 5);
	} else{
	    OUT(osc, 0) = 2.0f - (((float)osc->mod_counter) / (SRATE * 5));
	}    
	break;
	
    case NOISE:
	// FIXME: tähän randomgenu
    {
	int r = random() % 256;
	OUT(osc, 0) = (float)r / (float)256.0;
    }
	break;
	
    default:
	OUT(osc, 0) = 0.0f;
    }

    OUT(osc, 0) *= osc->amplitude * IN(osc, 1);
}

#endif
