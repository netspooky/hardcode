#ifndef __intro_h
#define __intro_h

int Init (void);
void DoFrame(char * data, int pitch);
void Quit (void);

void mouseHandler(int typ, int cx, int cy);
void keyHandler(int key);

extern char   background[307200]; 
extern char  *bData;
extern long   bPitch;

#endif
