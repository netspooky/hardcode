
#ifdef MAC
#include <gl.h>
#else
#include <GL/gl.h>
#endif
#include "volume.h"
#include "palikka.h"

GLfloat lclr[][3]={{-1,-1,-1},{YELLOW},{RED},{WHITE},{BLUE},{GREEN},{BLACK}};

void draw_volume(int center,int steps,char *blks,int xs,int ys,int zs)
{
    int x,y,z,off,top,bot,paint,i;

    glPushMatrix();
    if(center)
        glTranslatef(-xs+1,(ys-1)*LHEIGHT/2,zs-1);

    /* Go throuhg the table and draw bricks */
    for(z=off=0;z<zs;z++)
    {
        glPushMatrix();
        for(y=0;y<ys;y++)
        {
            glPushMatrix();
            for(x=0;x<xs;x++,off++)
            {
                if(blks[off])
                {
                    top=bot=steps;
                    paint=1;
                    /* Blocks inside constructions skipped */
                    if(x && blks[off-1] && x<xs-1 && blks[off+1] &&
                       y && blks[off-xs] && y<ys-1 && blks[off+xs] &&
                       z && blks[off-xs*ys] && z<zs-1 && blks[off+xs*ys])
                        paint=0;

                    if(paint)
                    {
                        i=blks[off];
                        /* Try to connect neighbors to 4x2 */
                        if(x<xs-1 && blks[off+1]==i)
                        {
                            if(y<ys-1 && blks[off+xs] && blks[off+xs+1])
                                bot=0;
                            if(y && blks[off-xs] && blks[off-xs+1])
                                top=0;

                            glTranslatef(1,0,0);
                            lego(4,2,1, top,bot,
                                 lclr[i][0],lclr[i][1],lclr[i][2]);
                            glTranslatef(1,0,0);

                            x++;
                            off++;
                        }
                        else /* An ordinary 2x2 brick */
                        {
                            if(y<ys-1 && blks[off+xs])
                                bot=0;
                            if(y && blks[off-xs])
                                top=0;
                            lego(2,2,1, top,bot,
                                 lclr[i][0],lclr[i][1],lclr[i][2]);
                        }
                    }
                }
                glTranslatef(2,0,0);
            }
            glPopMatrix();
            /* 0.98 to remove a little flickering rounding errors */
            glTranslatef(0,-LHEIGHT*0.98,0);
        }
        glPopMatrix();
        glTranslatef(0,0,-2);
    }

    glPopMatrix();
}
