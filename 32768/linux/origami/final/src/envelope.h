#ifndef __ENVELOPE_H__
#define __ENVELOPE_H__

// ADSR Envelope

// Inputs:
// 0 - Trigger
// 1 - Amplitude
// Outputs:
// 0 - Envelope out

enum {ENV_IN_TRIG, ENV_IN_AMP};
enum {ENV_OUT_SIGNAL};

typedef struct {
    output_signal out;
    input_signal in;

    float A, D, S, R;
    float value;
    float startlevel;
    int trigger, oldtrig;
    int time;
    enum {A, D, S, R} phase;
} Envelope;

Envelope *envelopes[35];
int n_envelopes = 0;

Envelope *new_envelope(float attack, float decay,
		       float sustain, float release)
{
    Envelope *env = malloc(sizeof(Envelope));
    make_conns(env, 2, 1);

    env->A = attack;
    env->D = decay;
    env->S = sustain;
    env->R = release;

    env->oldtrig = 0;
    env->trigger = 0;
    env->value = 0.0f;
    env->startlevel = 0.0f;
    env->time = 0;
    env->phase = R;

    envelopes[n_envelopes++] = env;
    return env;
}

void process_envelope(Envelope *env)
{
    env->trigger = (IN(env, 0) < 0.1f ? 0 : 1);

    if (env->oldtrig != env->trigger){
	if (env->trigger){
	    env->phase = A;
	} else{
	    env->phase = R;
	}
	env->time = 0;
	env->startlevel = env->value;
    }
    env->oldtrig = env->trigger;

    switch (env->phase){

    case A:
	if (env->A == 0.0f){
	    env->startlevel = 1.0f;
	    env->phase = D;
	    env->time = 0;
	    break;
	}
	env->value = env->startlevel + (1.0f - env->startlevel) *
	    ((float)env->time / (env->A * SRATE));
	if (env->time > (env->A * SRATE)){
	    env->time = 0;
	    env->phase = D;
	    env->startlevel = 1.0f;
	}
	break;

    case D:
	env->value = env->startlevel + (env->S - env->startlevel) *
	    ((float)env->time / (env->D * SRATE));
	if (env->time > (env->D * SRATE)){
	    env->time = 0;
	    env->phase = S;
	}
	break;

    case S:
	env->value = env->S;
	break;

    case R:
	env->value = (env->time < (env->R * SRATE)) ?
	    env->startlevel - env->startlevel *
	    (env->time / (env->R * SRATE)) : 0.0f;
	break;
    }

    env->time++;
    OUT(env, 0) = env->value * IN(env, 1);
}

#endif
