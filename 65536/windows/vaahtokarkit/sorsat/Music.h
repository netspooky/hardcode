#ifndef _Music_h_
#define _Music_h_

void musicInit();
void musicDeinit();
void *musicLoad(char *b,int size);
void musicPlay(void *m);

#endif