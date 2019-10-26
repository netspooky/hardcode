#include <dos.h>
#include "tools.h"

char *s_msg = 
"Hello to Pittsburgh from Baltimore! "
"I hope you're enjoying Demosplash 2014! "
"I made you some fluffy clouds!  orbitaldecay";

char far *buffer;
int buf_seg;
int s_pos;
int frame;

#define ticks_elapsed() (ticks() - g_start_tick)
#define XRES 320
#define YRES 200
#define FWIDTH 8
#define FHEIGHT 8
#define SEED 9

void scroller()
{
    int x, dy, i;
    char *msg;
    
    x = XRES - s_pos;
    i = 0;
    msg = s_msg;
    do {
        if ((x >= -FWIDTH) && (x <= XRES)) {
            dy = ((YRES - FHEIGHT) / 2) - 16;
            dy += ((sin(i * 30 + s_pos * 10) * 32) / 100);
            putchar(x, dy, *msg, buf_seg);
            if ((msg[1] == '\0') && (x == -FWIDTH))
                s_pos = 0;
                
        }
        x += FWIDTH;
        msg++;
        i++;
    } while (*msg);
}

int rand(int x, int y)
{
    int v;
    v = 31337 * ((x + 1) * y * SEED) + 3917;
    return v;
}

int interp(int x1, int x2, int t, int scale)
{
    return x1 + (t*(x2 - x1))/scale;
}

void init_vga(int scale)
{
    int x, y, ix, iy, tx, ty, nx1, nx0, v;
    int c00, c01, c10, c11;
    for (y = 0; y < YRES; y++) {
        for (x = 0; x < XRES; x++) {
            ix = x / scale;
            iy = y / scale;
            tx = x & (scale - 1);
            ty = y & (scale - 1);
            c00 = rand(ix, iy) & (scale - 1);
            c01 = rand(ix, iy + 1) & (scale - 1);
            c10 = rand(ix + 1, iy) & (scale - 1);
            c11 = rand(ix + 1, iy + 1) & (scale - 1);
            nx1 = interp(c01, c11, tx, scale);
            nx0 = interp(c00, c10, tx, scale);
            v = interp(nx0, nx1, ty, scale);
            buffer[x + y * XRES] += v;
        }
    }
    scale >>= 1;
    if (scale)
        init_vga(scale);
}

void update_palette()
{
    int i, s;
    for (i = 0; i < 128; i++) {
        s = (sin(frame * 3 + i * 10) * 40) / 100;
        set_palette(i, s + 23, s + 23, 63);
    }
}



void demo_start(int bs)
{
    unsigned int t, s, i;
    unsigned int g_start_tick;
    
    g_start_tick = ticks();
    buf_seg = bs;
    buffer = MK_FP(buf_seg, 0x0000); /* Address of buffer */
    frame = 0;
    s_pos = 0;
    t = 0;
    for (i = 128; i < 256; i++) {
        set_palette(i, 10, 0, 43);
    }
    init_vga(64);

    while (1) {
        scroller();
        vsync();
        update_palette();
        flip();
        frame++;
        scroller();
        s_pos++;
        
        do {
            if (getkey() == 1) goto quit;
        } while ((s = ticks_elapsed()) == t);
        t = s;
    }
    quit:
    return;
}
