/*
 * This file is part of xsoundtrack - a sound tracker for Linux.
 * Sed - july august september 1998.
 * This is total free software.
 *-------------------------------------
 * The file contains a wav-loader and a wav-saver (and a raw-loader)
 */

#include "wav.h"

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>

/* very small wav loader. There must be only 1 wav and it must not be stereo and it must be 8b or 16b */
int load_wav(sample *samp, char *name)
{
  char buf[50], *data=(char *)0;
  int len;
  int fd=open(name, O_RDONLY);
  short type;

  if (fd==-1) {
    perror("wav.load_wav 1");
    return 0;
  }

  /* wav format 1 only */
  /* first 4 bytes are "RIFF" */
  if (read(fd, buf, 4)!=4 || memcmp(buf, "RIFF", 4))
    goto error;
  /* then, a length (what length ??) */
  if (read(fd, &len, 4)!=4)
    goto error;
  /* then we have to read "WAVE" */
  if (read(fd, buf, 4)!=4 || memcmp(buf, "WAVE", 4))
    goto error;
  /* then, mikmod and sox have this while(1) that i simply copy-paste (modifying function-calls and adding the tests) */
  while(1) {
    if (read(fd, buf, 4)!=4)
      goto error;
    if (read(fd, &len, 4)!=4)
      goto error;
    if(!memcmp(buf, "fmt ", 4))
      break;
    if (lseek(fd, len, SEEK_CUR)==-1)
      goto error;
  }
  /* ok, now we read the type of wav. 1 is good, rest is not good. */
  if (read(fd, &type, 2)!=2 || type!=1)
    goto error;
  /* then we've got the nb of channels. Must be 1, otherwise it is stereo or worse, we don't handle it. */
  if (read(fd, &type, 2)!=2 || type!=1)
    goto error;
  /* then, there is : rate, average bytes/sec, block align, not used in sox, so we won't use it too */
  if (lseek(fd, 10, SEEK_CUR)==-1)
    goto error;
  /* then "FormatSpecific" says mikmod and sox uses this to know the type of sample (8, 16, 32b) */
  if (read(fd, &type, 2)!=2 || (type!=8 && type!=16))
    goto error;
  /* ok, now mikmod and sox skip len-16 bytes, so i do it too */
  if (lseek(fd, len-16, SEEK_CUR)==-1)
    goto error;
  /* now i must read "data" */
  if (read(fd, buf, 4)!=4 || memcmp(buf, "data", 4))
    goto error;
  /* now the length of the sample (if length==0, then fuck you) */
  if (read(fd, &len, 4)!=4 || len==0)
    goto error;
  /* done, now malloc, read and convert 8b samples (16b are signed ok, 8b are unsigned) */
  if (!(data=malloc(len)))
    goto error;
  if (read(fd, data, len)!=len)
    goto error1;
  if (type==8) {
    int i;
    for (i=0; i<len; i++)
      data[i]+=128;
  }
  /* now, put what has to be put in the sample structure */
  samp->sample_data=data;
  samp->sample_length=len;
  samp->sample_loop_start=0;
  samp->sample_loop_length=0;
  samp->sample_volume=0x40;
  samp->sample_fine_tune=0;
  samp->sample_relative_note_number=0;
  samp->sample_type=type==8?0:16;
  {
    int s=strlen(name);
    strcpy(samp->sample_name, &name[s-22>0?s-22:0]);
  }
  if (type==16)
    len>>=1;
  /* ok, let's return (best comment i ever wrote) */
  return 1;

error1:
  free(data);
error:
  close(fd);
  return 0;
}
