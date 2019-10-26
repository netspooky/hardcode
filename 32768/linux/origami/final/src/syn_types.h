#ifndef __SYN_TYPES_H__
#define __SYN_TYPES_H__

#define TRUE -1
#define FALSE 0

#define SRATE 44100

#define TICKLEN 2800
#define PATTERN_LEN 32

//#define IN(b, n) (((block *)b)->in.sources[n] == NULL ? 0.0f : *(((block *)b)->in.sources[n]))
#define IN(b, n) (*(((block *)b)->in.sources[n]))
#define OUT(b, n) (((block *)b)->out.outs[n])

float zero_const = 0.0f;

typedef struct {
    int n_outs;
    float *outs;
} output_signal;

typedef struct {
    int n_ins;
    float **sources;
} input_signal;

typedef struct {
    output_signal out;
    input_signal in;
} block;

void make_conns(void *b, int n_ins, int n_outs)
{
    block *c = (block *)b;
    int i;
    
    c->in.n_ins = n_ins;
    c->in.sources = malloc(n_ins*sizeof(void *));
    for (i=0; i<n_ins; i++){
	c->in.sources[i] = &zero_const;
    }

    c->out.n_outs = n_outs;
    c->out.outs = malloc(n_outs*sizeof(float));
    for (i=0; i<n_outs; i++){
	c->out.outs[i] = 0.0f;
    }
}

#endif
