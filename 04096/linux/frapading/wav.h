/*
 * This file is part of xsoundtrack - a sound tracker for Linux.
 * Sed - july august september 1998.
 * This is total free software.
 *-------------------------------------
 * The file contains definitions of functions for a wav-loader and a wav-saver (and a raw-loader)
 */

#ifndef _LOAD_WAV_H_
#define _LOAD_WAV_H_

typedef struct {
  /* data found in the file */
/*  0 */  unsigned int sample_length;		/* those three values are bytes length */
/*  4 */  unsigned int sample_loop_start;
/*  8 */  unsigned int sample_loop_length; /* i don't like it. sample_loop_end would have been much better */
/* 12 */  unsigned char *sample_data;
/* 16 */  char sample_type;
  char sample_volume;
  char sample_fine_tune;
  unsigned char sample_panning;
  char sample_relative_note_number;
  char sample_name[23];
} sample __attribute__ ((packed));

int load_wav(sample *, char *);
int save_wav(sample *, char *, int);

int load_raw(sample *, char *);

#endif /* _LOAD_WAV_H_ */

