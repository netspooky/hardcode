#include <stdio.h>

#define SONGLEN ((44100 * 2) * 60 * 3) // 3 min

extern void writeaudio(signed short *);

int main(int argc, char *argv[]) {
    char *output = calloc(1, SONGLEN);
    writeaudio(output);
    fwrite(output, 1, SONGLEN, stdout);
    return 0;
}
