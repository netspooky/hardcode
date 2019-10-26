#ifndef STUB_H
#define STUB_H

int ticks();
void vsync();
int sin(int x);
void set_palette(int color, int r, int g, int b);
int getkey();
void putchar(int x, int y, int c, int buf_seg);
void flip();

#endif /* STUB_H */
