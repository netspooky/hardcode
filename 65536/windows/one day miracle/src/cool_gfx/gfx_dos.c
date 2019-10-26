/*
    Implementation of CoolAPI DOS DJGPP (VESA/VGA) version.
    Loosely based on the Linux SVGALib-version.

    Created: 1.4.1999
    Updated: 20.5.1999

    -Marq
*/

#include <stdio.h>
#include <conio.h>
#include <go32.h>
#include "vesa.h"
#include "cool_gfx.h"
#include "gfx_dos.h"
#include "blit32.h"
#include "tweak.h"

static int  scr_rowlen, /*  Screen row length (in bytes)        */
            scr_lines,  /*  Screen buffer height                */
            scr_inc=1,  /*  Lines to jump at a time             */
            buf_rowlen, /*  User buffer row length (in pixels)  */
            buf_lines,  /*  User buffer height                  */
            raster=0,   /*  1 for raster modes                  */
            tweak=0,    /*  1 for tweaked modes                 */
            vesa=0,     /*  1 if in VESA mode                   */
            paging=0,   /*  1 if pageflipping supported         */
            page=0,     /*  Current page #                      */
            selector;   /*  Graphics memory selector for LFB    */

                        /*  Temporary buffer for blits          */
static unsigned char    blitbuf[DOS_BLITMAX];

static void dos_set_gray(void);  /*  Sets palette to grayscale      */
static void dos_set_color(void); /*  Sets palette to color          */

int gfx_init(int mode,int special)
{
    switch(mode)
    {
        case GFX_320x240x32:    return(dos_set_320x240x32(special));
        case GFX_320x200x32:    return(dos_set_320x200x32(special));
        default:                return(GFX_ERR_MODE);
    }
}

int dos_set_320x240x32(int special)
{
    int     mode;

    struct VBEinfoblock info;

    raster=tweak=vesa=paging=page=0;    /*  Set default values  */
    scr_inc=1;
    buf_rowlen=320;
    buf_lines=240;

    /*  Don't prompt the user: choose the best mode available   */
    if(special&GFX_NOASK)
    {
        if(!(special&GFX_NOVESA) && VBEinfo(&info)==VBE_FOUND)
        {
            if((selector=VBEeasymodel(320,240,32))!=-1)
            {
                blit32_init(BLIT_32);
                paging=1; vesa=1; scr_rowlen=320*4; scr_lines=240;
                return(GFX_OK);
            }

            if((selector=VBEeasymodel(320,240,24))!=-1)
            {
                blit32_init(BLIT_24);
                paging=1; vesa=1; scr_rowlen=320*3; scr_lines=240;
                return(GFX_OK);
            }

            if((selector=VBEeasymodel(320,240,16))!=-1)
            {
                blit32_init(BLIT_16);
                paging=1; vesa=1; scr_rowlen=320*2; scr_lines=240;
                return(GFX_OK);
            }

            if((selector=VBEeasymodel(320,240,15))!=-1)
            {
                blit32_init(BLIT_15);
                paging=1; vesa=1; scr_rowlen=320*2; scr_lines=240;
                return(GFX_OK);
            }
        }

        set320x240();
        dos_set_gray();
        blit32_init(BLIT_8_GRAY);
        tweak=1; scr_rowlen=320; scr_lines=240;

        return(GFX_OK);
    }
    else
    {
        puts("VGA:");
        puts("1 - 320x240x8b  (Grayscale tweak)");
        puts("2 - 320x480x8b  (Slow color tweak)");
        puts("VESA2 LFB lowres:");
        puts("3 - 320x240x15b (Good)");
        puts("4 - 320x240x16b (Good)");
        puts("5 - 320x240x24b (Perfect)");
        puts("6 - 320x240x32b (Perfect)");
        puts("VESA2 LFB hires:");
        puts("7 - 640x480x8b  (Slow)");
        puts("8 - 640x480x15b (Slow)");
        puts("9 - 640x480x16b (Slow)");
        scanf("%d",&mode);

        switch(mode)
        {
            case 1: set320x240();
                    dos_set_gray();
                    blit32_init(BLIT_8_GRAY);
                    tweak=1; scr_rowlen=320; scr_lines=240;
                    break;
            case 2: set320x480();
                    dos_set_color();
                    blit32_init(BLIT_8_RASTER);
                    tweak=1; scr_rowlen=320; scr_lines=480; raster=1; scr_inc=2;
                    break;
            case 3: if((selector=VBEeasymodel(320,240,15))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_15);
                    paging=1; vesa=1; scr_rowlen=320*2; scr_lines=240;
                    break;
            case 4: if((selector=VBEeasymodel(320,240,16))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_16);
                    paging=1; vesa=1; scr_rowlen=320*2; scr_lines=240;
                    break;
            case 5: if((selector=VBEeasymodel(320,240,24))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_24);
                    paging=1; vesa=1; scr_rowlen=320*3; scr_lines=240;
                    break;
            case 6: if((selector=VBEeasymodel(320,240,32))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_32);
                    paging=1; vesa=1; scr_rowlen=320*4; scr_lines=240;
                    break;
            case 7: if((selector=VBEeasymodel(640,480,8))==-1)
                        return(GFX_ERR_MODE);
                    dos_set_color();
                    blit32_init(BLIT_8_RASTER_DOUBLE);
                    raster=1; paging=1; vesa=1; scr_rowlen=640;
                    scr_lines=480; scr_inc=2;
                    break;
            case 8: if((selector=VBEeasymodel(640,480,15))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_15_DOUBLE);
                    vesa=1; scr_rowlen=640*2; scr_lines=480; scr_inc=2;
                    break;
            case 9: if((selector=VBEeasymodel(640,480,16))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_16_DOUBLE);
                    vesa=1; scr_rowlen=640*2; scr_lines=480; scr_inc=2;
                    break;

            default: return(GFX_ERR_MODE);
        }
    }
    return(GFX_OK);
}

int dos_set_320x200x32(int special)
{
    int     mode;

    struct VBEinfoblock info;

    raster=tweak=vesa=paging=page=0;    /*  Set default values  */
    scr_inc=1;
    buf_rowlen=320;
    buf_lines=200;

    /*  Don't prompt the user: choose the best mode available   */
    if(special&GFX_NOASK)
    {
        if(!(special&GFX_NOVESA) && VBEinfo(&info)==VBE_FOUND)
        {
            if((selector=VBEeasymodel(320,200,32))!=-1)
            {
                blit32_init(BLIT_32);
                paging=1; vesa=1; scr_rowlen=320*4; scr_lines=200;
                return(GFX_OK);
            }

            if((selector=VBEeasymodel(320,200,24))!=-1)
            {
                blit32_init(BLIT_24);
                paging=1; vesa=1; scr_rowlen=320*3; scr_lines=200;
                return(GFX_OK);
            }

            if((selector=VBEeasymodel(320,200,16))!=-1)
            {
                blit32_init(BLIT_16);
                paging=1; vesa=1; scr_rowlen=320*2; scr_lines=200;
                return(GFX_OK);
            }

            if((selector=VBEeasymodel(320,200,15))!=-1)
            {
                blit32_init(BLIT_15);
                paging=1; vesa=1; scr_rowlen=320*2; scr_lines=200;
                return(GFX_OK);
            }
        }

        go13();
        dos_set_gray();
        blit32_init(BLIT_8_GRAY);
        paging=1; scr_rowlen=320; scr_lines=200;

        return(GFX_OK);
    }
    else
    {
        puts("VGA:");
        puts("1 - 320x200x8b  (Grayscale)");
        puts("2 - 320x400x8b  (Slow color tweak)");
        puts("VESA2 LFB lowres:");
        puts("3 - 320x200x15b (Good)");
        puts("4 - 320x200x16b (Good)");
        puts("5 - 320x200x24b (Perfect)");
        puts("6 - 320x200x32b (Perfect)");
        puts("VESA2 LFB hires:");
        puts("7 - 640x400x8b  (Slow)");
        puts("8 - 640x400x15b (Slow)");
        puts("9 - 640x400x16b (Slow)");
        scanf("%d",&mode);

        switch(mode)
        {
            case 1: go13();
                    dos_set_gray();
                    blit32_init(BLIT_8_GRAY);
                    scr_rowlen=320; scr_lines=200;
                    break;
            case 2: set320x400();
                    dos_set_color();
                    blit32_init(BLIT_8_RASTER);
                    tweak=1; scr_rowlen=320; scr_lines=400; raster=1; scr_inc=2;
                    break;
            case 3: if((selector=VBEeasymodel(320,200,15))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_15);
                    paging=1; vesa=1; scr_rowlen=320*2; scr_lines=200;
                    break;
            case 4: if((selector=VBEeasymodel(320,200,16))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_16);
                    paging=1; vesa=1; scr_rowlen=320*2; scr_lines=200;
                    break;
            case 5: if((selector=VBEeasymodel(320,200,24))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_24);
                    paging=1; vesa=1; scr_rowlen=320*3; scr_lines=200;
                    break;
            case 6: if((selector=VBEeasymodel(320,200,32))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_32);
                    paging=1; vesa=1; scr_rowlen=320*4; scr_lines=200;
                    break;
            case 7: if((selector=VBEeasymodel(640,400,8))==-1)
                        return(GFX_ERR_MODE);
                    dos_set_color();
                    blit32_init(BLIT_8_RASTER_DOUBLE);
                    raster=1; paging=1; vesa=1; scr_rowlen=640;
                    scr_lines=400; scr_inc=2;
                    break;
            case 8: if((selector=VBEeasymodel(640,400,15))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_15_DOUBLE);
                    vesa=1; scr_rowlen=640*2; scr_lines=400; scr_inc=2;
                    break;
            case 9: if((selector=VBEeasymodel(640,400,16))==-1)
                        return(GFX_ERR_MODE);
                    blit32_init(BLIT_16_DOUBLE);
                    vesa=1; scr_rowlen=640*2; scr_lines=400; scr_inc=2;
                    break;

            default: return(GFX_ERR_MODE);
        }
    }
    return(GFX_OK);
}

int gfx_blit(unsigned long *buffer)
{
    int     n,m,plus=0;

    if(paging)
    {
        if(vesa)
            plus=page*scr_rowlen*scr_lines;
        if(tweak)
            plus=page*scr_rowlen*scr_lines/4;
    }

    if(tweak)
    {
        for(n=0;n<scr_lines;n+=scr_inc)
        {
            blit32_blit(blitbuf,&buffer[n*buf_rowlen/scr_inc],buf_rowlen,scr_rowlen,_my_ds());
            for(m=0;m<4;m++)
            {
                outp(0x3c4,2);
                outp(0x3c5,1<<m);
                blit32_tweak((char *)(0xa0000+plus+n*scr_rowlen/4),&blitbuf[m],buf_rowlen*scr_inc,0,_dos_ds);
            }
        }
    }
    else
    {
        if(vesa)
        {
            for(n=0;n<scr_lines;n+=scr_inc)
                blit32_blit((char *)(plus+n*scr_rowlen),&buffer[n*buf_rowlen/scr_inc],
                            buf_rowlen,scr_rowlen,selector);
        }
        else
        {
            for(n=0;n<scr_lines;n+=scr_inc)
                blit32_blit((char *)(0xa0000+n*scr_rowlen),&buffer[n*buf_rowlen/scr_inc],
                            buf_rowlen,scr_rowlen,_dos_ds);
        }
    }

    if(paging)
    {
        if(vesa)
            VBEstart(0,scr_lines*page,0);
        if(tweak)
        {
            n=page*scr_lines*scr_rowlen/4;
            outp(0x3d4,0xc);
            outp(0x3d5,n>>8);
            outp(0x3d4,0xd);
            outp(0x3d5,n&0xff);
        }
        page=1-page;
    }
}

void dos_set_gray(void) /*  Dirty! Should use a VESA call if present    */
{
    int     n;

    for(n=0;n<96;n++)   /*  Colors slide from 0 to 95 */
    {
        outp(0x3c8,n);
        outp(0x3c9,n*63/95);
        outp(0x3c9,n*63/95);
        outp(0x3c9,n*63/95);
    }
}

void dos_set_color(void) /* As dirty as above   */
{
    int     n;

    for(n=0;n<64;n++)   /*  First 64 red, 128 to 255 combined (sucks)   */
    {
        outp(0x3c8,n);
        outp(0x3c9,n);
        outp(0x3c9,0);
        outp(0x3c9,0);
    }

    for(n=0;n<128;n++)
    {
        outp(0x3c8,n+128);
        outp(0x3c9,0);
        outp(0x3c9,(n&15)*63/15);
        outp(0x3c9,(n>>4)*63/7);
    }
}

int gfx_exitevent(void)
{
    if(kbhit())
    {
        switch(getch())
        {
            case 27: return(1);
            case 0 : getch();
                     return(0);
            default: return(0);
        }
    }
}

void gfx_close(void)
{
    if(vesa)
        VBEfree(selector);
    textmode(3);
}

/*  EOS */
