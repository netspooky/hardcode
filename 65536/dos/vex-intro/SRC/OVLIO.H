#ifndef __OVLIO_H
#define __OVLIO_H

short oopen(const char *name);
long oread(short hnd, void *buf, unsigned short len);
long oseek(short hnd, long pos, short type);
void oclose(short hnd);

#endif
