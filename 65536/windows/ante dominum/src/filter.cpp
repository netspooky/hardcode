#include "filter.hpp"

/*void glowfilter_setup();
void glowfilter_draw();
void glowfilter_end();
*/


/*

  glowfilter_setup();
  efekti(aika, whatnots);
  glowfilter_copy();


*/
void glowfilter_setup()
{
	glViewport(0, 0, 512, 512);
}

void glowfilter_draw()
{
	int i;
	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, render512_0->ID);
    glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, 512, 512, 0);
	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
    glDepthMask(0);

	perspective2D(1,1);
	glLoadIdentity();

	Texture *t1;
	Texture *t2;

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    float alpha = 0.3f;

    const int count = 5;
    for (i=0;i<count;i++)
    {
        //zoomikerroin per tekstuurin iteraatio, venytetään sitä hieman
        //sineillä että saadaan eloa efektiin
        const float zoom = i * 0.0f;//034f;// * (0.5f+0.1f*sin(aika*10)*cos(aika));

		const float kohta = 2*3.141529f * (i / (float)count);
		const float radius = 0.01f;
		const float xmove = radius*(float)sin(kohta);
		const float ymove = radius*(float)cos(kohta);

        if (!(i%2))
        {
                t1 = render512_0;
                t2 = render512_0;
        }
        else
        {
                t1 = render512_0;
                t2 = render512_0;
        }
        //piirretään render1
        
        glBindTexture(GL_TEXTURE_2D, t1->ID);
        glBegin(GL_QUADS);
        glColor4f(1,1,1,alpha);
/*        glTexCoord2f(zoom, zoom);
        glVertex2f(0, 0);
        glTexCoord2f(1-zoom, zoom);
        glVertex2f(1, 0);
        glTexCoord2f(1-zoom, 1-zoom);
        glVertex2f(1, 1);
        glTexCoord2f(zoom, 1-zoom);
        glVertex2f(0, 1);*/
        glTexCoord2f(zoom, zoom);
        glVertex2f(xmove, ymove);
        glTexCoord2f(1-zoom, zoom);
        glVertex2f(1+xmove, ymove);
        glTexCoord2f(1-zoom, 1-zoom);
        glVertex2f(1+xmove, 1+ymove);
        glTexCoord2f(zoom, 1-zoom);
        glVertex2f(xmove, 1+xmove);

  glEnd();

        //kopioidaan se render2:een
        glBindTexture(GL_TEXTURE_2D, t2->ID);
        glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, 0, 0, 512, 512, 0);
        
        //ja loopin jälkeen render1 ja render2 vaihtavat paikkaa
    }
	glViewport(0, 0, OPENGL_XRES, OPENGL_YRES);
    glDisable(GL_BLEND);
    
    //lopulta piirretään blurrauksen tulos ruudulle
    glColor3f(1,1,1);
    glBindTexture(GL_TEXTURE_2D, t2->ID);
    glBegin(GL_QUADS);
    glColor4f(1,1,1,1);
    glTexCoord2f(0, 0);
    glVertex2f(0, 0);
    glTexCoord2f(1, 0);
    glVertex2f(1, 0);
    glTexCoord2f(1, 1);
    glVertex2f(1, 1);
    glTexCoord2f(0, 1);
    glVertex2f(0, 1);
    glEnd();
    glDepthMask(1); 
	perspective3D();
	glLoadIdentity();
}

 
