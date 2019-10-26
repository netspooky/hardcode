/* Just a delire */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#include "wav.h"

int main(void)
{
  int fd;
  int nb_bytes=0;
  sample sample;
  char outbuf[64000];
  char *out=&outbuf[0];
  int i;

  memset(outbuf, 0, 64000);

  if (!load_wav(&sample, "frapading.wav")) {
    fprintf(stderr, "error loading wav\n");
    return 0;
  }

  for (i=0; i<sample.sample_length;) {
    int j;
    for (j=0; j<8; j++) {
      int d=sample.sample_data[i]>128?1:0;
      d<<=j;
      *out |=d;
      i++;
    }
    nb_bytes++;
    out++;
  }

  if ((fd=open("frapading.1b", O_CREAT|O_TRUNC|O_WRONLY, 0644))==-1) {
    perror("open");
    return -1;
  }

  if (write(fd, outbuf, nb_bytes)!=nb_bytes) {
    perror("write");
    return -1;
  }
  if (close(fd)==-1) {
    perror("close");
    return -1;
  }
  return 0;
}
