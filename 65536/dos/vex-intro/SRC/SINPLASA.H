#ifndef __SINPLASA_H
#define __SINPLASA_H

extern "C" void makesintab(char *plsintab, short cmax);
extern "C" void plasmaline(const char *plsintab, char *buf, short len, long p, long f);

#endif
