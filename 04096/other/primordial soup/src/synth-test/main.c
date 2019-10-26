#include <stdio.h>
#include <sndfile.h>
#include "synth.h"

#define SAMPLERATE 44100
#define TIME_S 20
#define OVERSAMPLE_RATIO 1

uint8_t g_buffer[63439928];

float outbuf[SAMPLERATE * TIME_S * 2 * TIME_S] = {0};

int main(int argc, char *argv[]) {

    if (argc != 2) {
	fprintf(stderr, "%s <outfile>\n", argv[0]);
	return 1;
    }

    synth(outbuf, SAMPLERATE * OVERSAMPLE_RATIO * 2 * TIME_S);

    SF_INFO info;
    info.samplerate = SAMPLERATE;
    info.channels = 2;
    info.format = SF_FORMAT_WAV | SF_FORMAT_FLOAT;
    SNDFILE *outfile = sf_open(argv[1], SFM_WRITE, &info);
    sf_writef_float(outfile, outbuf, SAMPLERATE * TIME_S);
    sf_close(outfile);

    for (size_t i = 0; i < 32; ++i) {
	printf("%f\n", outbuf[i]);
    }
    
    return 0;
}
