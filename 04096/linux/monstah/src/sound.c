#include <stdio.h>
#include <unistd.h>
#include <math.h>
#include <string.h>

#include <SDL/SDL.h>

#ifdef WIN32
#include <windows.h>
#endif

#define ftoi(f) ((int) (f))

static int TEMPO = 8000 / 2;

#include "synth_orig.c"

#define ERR(s) \
  fprintf(stderr, "%s: rivi %d: " s "\n", argv[1], line);

static SDL_AudioSpec desired, obtained;

enum parse_state { s_definition, s_pattern, s_playlist };

int main(int argc, char *argv[]) {
  FILE *fp;
  enum parse_state state = s_definition;
  int line = 0;
  int size;
  int pattern;
  int cur_pattern_size;
  unsigned int i, j, k;

  if(argc != 2) {
    fprintf(stderr,
        "Tarvitaan yksi parametri, ladattava musiikkitiedosto, kiitos.\n");
    return 1;
  }

  fp = fopen(argv[1], "r");
  if(fp == NULL)
    return 1;

  while(!feof(fp)) {
    char buf[256], s[256];

    if(fgets(buf, 255, fp) == NULL)
      break;
    line++;

    if(strchr(buf, '/') != NULL)
      *strchr(buf, '/') = '\0';

    s[0] = '\0';
    sscanf(buf, "%s", s);

    if(s[0] == '\0')
      continue;

    if(state == s_definition) {
      if(strcasecmp(s, "tempo") == 0) {
        sscanf(buf, "%*s %d", &TEMPO);
        TEMPO *= 8;
      }

      if(strcasecmp(s, "pattern") == 0) {
        sscanf(buf, "%*s %d", &pattern);
        if(pattern < 0 || pattern >= PATTERNS) {
          ERR("patternin numero on liian iso");
          return 1;
        }

        state = s_pattern;

        cur_pattern_size = 0;

        continue;
      }

      if(strcasecmp(s, "playlist") == 0) {
        state = s_playlist;
        continue;
      }
    }

    if(state == s_pattern) {
      int n = 0;
      char note[20];
      char *p;

      if(strcasecmp(s, "end") == 0) {
        /* Check that pattern size matches */
        if(pattern_size) {
          if(cur_pattern_size != pattern_size)
            ERR("pattern has different size than previous patterns");
        }
        else
          pattern_size = cur_pattern_size;

        state = s_definition;
        continue;
      }
      else if(strcasecmp(s, "mo") == 0 || strcasecmp(s, "e") == 0)
        tab[pattern][cur_pattern_size].type = 0;
      else if(strcasecmp(s, "no") == 0 || strcasecmp(s, "n") == 0)
        tab[pattern][cur_pattern_size].type = 1;
      else if(strcasecmp(s, "sq") == 0 || strcasecmp(s, "g") == 0)
        tab[pattern][cur_pattern_size].type = 2;
      else if(strcasecmp(s, "si") == 0 || strcasecmp(s, "s") == 0)
        tab[pattern][cur_pattern_size].type = 3;
      else
        ERR("bad instrument");

      sscanf(buf, "%*s %s %d", &note,
          &tab[pattern][cur_pattern_size].arg2);

      p = note;
      switch(toupper(*p++)) {
      case 'C': n = 0; break;
      case 'D': n = 2; break;
      case 'E': n = 4; break;
      case 'F': n = 5; break;
      case 'G': n = 7; break;
      case 'A': n = 9; break;
      case 'B': n = 11; break;
      default: ERR("bad note");
      }

      if(*p == '#') {
        n++;
        p++;
      }

      if(*p == '-') p++;

      if(isdigit(*p)) {
        n += (*p - '0') * 12;
        p++;
      }
      else {
        ERR("bad octave in note");
      }

      tab[pattern][cur_pattern_size].arg1 = n;

      cur_pattern_size++;
    }

    if(state == s_playlist) {
      if(strcasecmp(s, "end") == 0)
        state = s_definition;
      else {
        sscanf(buf, "%d %d %d", &playlist[playlist_count][0],
            &playlist[playlist_count][1],
            &playlist[playlist_count][2]);
        playlist_count++;
      }
    }
  }

  FILE *outf = fopen("song.h", "w");

  int used_patterns[PATTERNS];
  int pattern_map[PATTERNS];
  int pats = 0;

  for(i=0; i<PATTERNS; i++)
    pattern_map[i] = -1;

  /* Get pattern mapping */
  for(i=0; i<playlist_count; i++) {
    if(pattern_map[playlist[i][0]] == -1)
      pattern_map[playlist[i][0]] = pats++;

    if(pattern_map[playlist[i][1]] == -1)
      pattern_map[playlist[i][1]] = pats++;

    if(pattern_map[playlist[i][2]] == -1)
      pattern_map[playlist[i][2]] = pats++;
  }

  int n = 0;

  fprintf(outf, "#define playlist_count %d\n", playlist_count);
  fprintf(outf, "#define pattern_size   %d\n", pattern_size);
  fprintf(outf, "#define pattern_count  %d\n", pats);

  for(j=0; j<3; j++) {
    for(i=0; i<playlist_count; i++) {
      fprintf(outf, "%3d,",
        pattern_map[playlist[i][j]]);
      n++;
    }
    fprintf(outf, "\n");
  }

  for(k=0; k<pats; k++) {
    for(i=0; i<PATTERNS; i++) {
      if(pattern_map[i] == k) {
        fprintf(outf, "/* pattern %d */\n", i);

#if 0
        for(j=0; j<pattern_size; j++) {
          fprintf(outf, "%3d, %3d, %3d,\n",
              tab[i][j].type, tab[i][j].arg1, tab[i][j].arg2);
          n += 3;
        }
#else
        for(j=0; j<pattern_size; j++)
          fprintf(outf, "%3d, ", tab[i][j].type);
        n += pattern_size;
        fprintf(outf, "\n");

        for(j=0; j<pattern_size; j++)
          fprintf(outf, "%3d, ", tab[i][j].arg1);
        n += pattern_size;
        fprintf(outf, "\n");

        for(j=0; j<pattern_size; j++)
          fprintf(outf, "%3d, ", tab[i][j].arg2);
        n += pattern_size;
        fprintf(outf, "\n");
#endif
      }
    }
  }

  fprintf(outf, "/* size is %d bytes */\n", n);

  fclose(outf);

  fprintf(stderr, "Biisukkaliini vie %d tavua\n", n);

  fprintf(stderr, "Soitetaan...\n");

  desired.freq = 8000;
  desired.format = AUDIO_U8;
  desired.channels = 1;
  desired.samples = 1024*2;
  desired.callback = music_fill;

  if(SDL_OpenAudio(&desired, &obtained) < 0) {
    fprintf(stderr, "Couldn't open audio: %s\n", SDL_GetError());
    return 1;
  }

  music_prepare();

  SDL_PauseAudio(0);

#ifdef WIN32
  while(!music_not_playing && !kbhit()) {
    SDL_Delay(100);
  }
#else
  while(!music_not_playing)
    SDL_Delay(100);
#endif

  return 0;
}
