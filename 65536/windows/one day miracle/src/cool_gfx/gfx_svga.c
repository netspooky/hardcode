/*
    Implementation of CoolAPI SVGALib-version.

    Created: 31.3.1999
    Updated: 20.5.1999

    -Marq
*/

#include <stdio.h>
#include <vga.h>
#include "cool_gfx.h"
#include "gfx_svga.h"
#include "blit32.h"

static int  scr_rowlen, /*  Screen row length (in bytes)        */
            scr_lines,  /*  Screen buffer height                */
            scr_inc=1,  /*  Lines to jump at a time             */
            buf_rowlen, /*  User buffer row length (in pixels)  */
            buf_lines,  /*  User buffer height                  */
            raster=0,   /*  1 for raster modes                  */
            paging=0,   /*  1 if pageflipping supported         */
            page=0;     /*  Current page #                      */

                        /*  Temporary buffer for blits          */
static unsigned char    blitbuf[SVGA_BLITMAX];

static void svga_set_gray(void);  /*  Sets palette to grayscale      */
static void svga_set_color(void); /*  Sets palette to color          */

int gfx_init(int mode,int special)
{
    switch(mode)
    {
        case GFX_320x240x32:    return(svga_set_320x240x32(special));
        case GFX_320x200x32:    return(svga_set_320x200x32(special));
        default:                return(GFX_ERR_MODE);
    }
}

int svga_set_320x240x32(int special)
{
    int     mode,n;

    raster=paging=page=0;   /*  Default values  */
    scr_inc=1;
    buf_rowlen=320;
    buf_lines=240;

    /*  Don't prompt the user. Select some crappy mode that will work.
        Should choose the best mode, but SVGALib would fail anyway...   */
    if(special&GFX_NOASK)   
    {
        if(!vga_hasmode(G320x240x256))
            return(GFX_ERR_MODE);
        vga_setmode(G320x240x256);
        blit32_init(BLIT_8_GRAY);
        svga_set_gray();
        paging=1; scr_lines=240; scr_rowlen=320;
    }
    else    /*  Prompt the user for the best mode   */
    {
        puts("1 - 320x240x8b  (Tweaked VGA grayscale)");
        puts("2 - 360x480x8b  (Tweaked VGA color)");
        puts("3 - 640x480x8b  (Raster hires)");
        puts("4 - 640x480x15b (Double hires)");
        puts("5 - 640x480x16b (Double hires)");
        puts("6 - 640x480x24b (Double hires)");
        puts("7 - 640x480x32b (Double hires)");
        scanf("%d",&mode);

        switch(mode)    /*  Actually set the modes  */
        {
            case 1:     if(!vga_hasmode(G320x240x256))
                            return(GFX_ERR_MODE);
                        vga_setmode(G320x240x256);
                        blit32_init(BLIT_8_GRAY);
                        svga_set_gray();
                        paging=1; scr_lines=240; scr_rowlen=320;
                        break;

            case 2:     if(!vga_hasmode(G360x480x256))
                            return(GFX_ERR_MODE);
                        vga_setmode(G360x480x256);
                        blit32_init(BLIT_8_RASTER);
                        svga_set_color();
                        raster=1; scr_lines=480; scr_rowlen=360; scr_inc=2;
                        break;

            case 3:     if(!vga_hasmode(G640x480x256))
                            return(GFX_ERR_MODE);
                        vga_setmode(G640x480x256);
                        blit32_init(BLIT_8_RASTER_DOUBLE);
                        svga_set_color();
                        paging=1; raster=1; scr_lines=480; scr_rowlen=640; scr_inc=2;
                        break;

            case 4:     if(!vga_hasmode(G640x480x32K))
                            return(GFX_ERR_MODE);
                        vga_setmode(G640x480x32K);
                        blit32_init(BLIT_15_DOUBLE);
                        scr_lines=480; scr_rowlen=640*2; scr_inc=2;
                        break;

            case 5:     if(!vga_hasmode(G640x480x64K))
                            return(GFX_ERR_MODE);
                        vga_setmode(G640x480x64K);
                        blit32_init(BLIT_16_DOUBLE);
                        scr_lines=480; scr_rowlen=640*2; scr_inc=2;
                        break;

            case 6:     if(!vga_hasmode(G640x480x16M))
                            return(GFX_ERR_MODE);
                        vga_setmode(G640x480x16M);
                        blit32_init(BLIT_24_DOUBLE);
                        scr_lines=480; scr_rowlen=640*3; scr_inc=2;
                        break;

            case 7:     if(!vga_hasmode(G640x480x16M32))
                            return(GFX_ERR_MODE);
                        vga_setmode(G640x480x16M32);
                        blit32_init(BLIT_32_DOUBLE);
                        scr_lines=480; scr_rowlen=640*4; scr_inc=2;

            default:    return(GFX_ERR_MODE);
        }
    }
    return(GFX_OK);
}

int svga_set_320x200x32(int special)
{
    int     mode,n;

    raster=paging=page=0;   /*  Default values  */
    scr_inc=1;
    buf_rowlen=320;
    buf_lines=200;

    /*  Don't prompt the user. Select some crappy mode that will work.
        Should choose the best mode, but SVGALib would fail anyway...   */
    if(special&GFX_NOASK)   
    {
        if(special&GFX_GRAY)
        {
            if(!vga_hasmode(G320x200x256))
                return(GFX_ERR_MODE);
            vga_setmode(G320x200x256);
            blit32_init(BLIT_8_GRAY);
            svga_set_gray();
            scr_lines=200; scr_rowlen=320;
        }
        else
        {
            if(!vga_hasmode(G320x400x256))
                return(GFX_ERR_MODE);
            vga_setmode(G320x400x256);
            blit32_init(BLIT_8_RASTER);
            svga_set_color();
            paging=1; raster=1; scr_lines=400; scr_rowlen=320; scr_inc=2;
        }
    }
    else    /*  Prompt the user for the best mode   */
    {
        puts("1 - 320x200x8b  (VGA grayscale)");
        puts("2 - 320x400x8b  (Tweaked VGA color)");
        puts("3 - 320x200x15b (Seldom works)");
        puts("4 - 320x200x16b (Seldom works)");
        puts("5 - 320x200x24b (Seldom works)");
        puts("6 - 320x200x32b (Seldom works)");
        scanf("%d",&mode);

        switch(mode)    /*  Actually set the modes  */
        {
            case 1:     if(!vga_hasmode(G320x200x256))
                            return(GFX_ERR_MODE);
                        vga_setmode(G320x200x256);
                        blit32_init(BLIT_8_GRAY);
                        svga_set_gray();
                        scr_lines=200; scr_rowlen=320;
                        break;

            case 2:     if(!vga_hasmode(G320x400x256))
                            return(GFX_ERR_MODE);
                        vga_setmode(G320x400x256);
                        blit32_init(BLIT_8_RASTER);
                        svga_set_color();
                        paging=1; raster=1; scr_lines=400; scr_rowlen=320; scr_inc=2;
                        break;

            case 3:     if(!vga_hasmode(G320x200x32K))
                            return(GFX_ERR_MODE);
                        vga_setmode(G320x200x32K);
                        blit32_init(BLIT_15);
                        scr_lines=200; scr_rowlen=320;
                        break;

            case 4:     if(!vga_hasmode(G320x200x64K))
                            return(GFX_ERR_MODE);
                        vga_setmode(G320x200x64K);
                        blit32_init(BLIT_16);
                        scr_lines=200; scr_rowlen=320;
                        break;

            case 5:     if(!vga_hasmode(G320x200x16M))
                            return(GFX_ERR_MODE);
                        vga_setmode(G320x200x16M);
                        blit32_init(BLIT_24);
                        scr_lines=200; scr_rowlen=320;
                        break;

            case 6:     if(!vga_hasmode(G320x200x16M32))
                            return(GFX_ERR_MODE);
                        vga_setmode(G320x200x16M32);
                        blit32_init(BLIT_32);
                        scr_lines=200; scr_rowlen=320;
                        break;

            default:    return(GFX_ERR_MODE);
        }
    }
    return(GFX_OK);
}

int gfx_blit(unsigned long *buffer)
{
    int     n,plus=0;

    if(paging)
        plus=page*scr_lines;

    if(raster)
    {
        for(n=0;n<scr_lines;n+=scr_inc)
        {
            blit32_blit(blitbuf,&buffer[n*buf_rowlen/scr_inc],buf_rowlen,scr_rowlen,0);
            vga_drawscanline(n+plus,blitbuf);
            vga_drawscanline(n+plus+1,&blitbuf[scr_rowlen]);
        }
    }
    else
    {
        for(n=0;n<scr_lines;n+=scr_inc)
        {
            blit32_blit(blitbuf,&buffer[n*buf_rowlen/scr_inc],buf_rowlen,scr_rowlen,0);
            vga_drawscanline(n+plus,blitbuf);
        }
    }

    if(paging)
    {
        vga_setdisplaystart(page*scr_rowlen*scr_lines);
        page=1-page;
    }
}

void svga_set_gray(void)
{
    int     n;

    for(n=0;n<96;n++)   /*  Colors slide from 0 to 95 */
        vga_setpalette(n,n*63/95,n*63/95,n*63/95);
}

void svga_set_color(void)
{
    int     n;

    for(n=0;n<64;n++)   /*  First 64 red, 128 to 255 combined (sucks)   */
        vga_setpalette(n,n,0,0);
    for(n=0;n<128;n++)
        vga_setpalette(n+128,0,(n&15)*63/15,(n>>4)*63/7);
}

int gfx_exitevent(void)
{
    if(vga_getkey()==27)
        return(1);
    else
        return(0);
}

/*  Shuts down the graphics engine  */
void gfx_close(void)
{
    vga_setmode(TEXT);
}

/*  EOS */
