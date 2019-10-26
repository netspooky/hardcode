#include "font.hpp"
#include "fontdata.h"
#include <string.h>

GLuint fontbase;
GLuint fontbase2;
GLuint tex;

void debugprint(char *string, int line)
{
}


void font_write(float xpos, float ypos, const char *string)
{
	perspective2D(640,480);
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glPushAttrib(GL_LIST_BIT);

	//quick RasterPos hack, but if you don't like it i'll show you an elf smiley: o<:)>
	glTranslatef(320+(320*(xpos/4.0))-(strlen(string)*5),240+240*ypos,0);
	glScalef(2,2,1);

	glListBase(fontbase-32);
	glBindTexture(GL_TEXTURE_2D, tex);
	glCallLists(strlen(string), GL_UNSIGNED_BYTE, string);
	glPopAttrib();
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	perspective3D();
}

void font_write3d(const char *string)
{
	glEnable(GL_TEXTURE_2D);
	glEnable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);
	glPushAttrib(GL_LIST_BIT);

	glScalef(0.2,0.2,0.2);

	glListBase(fontbase-32);
	glBindTexture(GL_TEXTURE_2D, tex);
	glCallLists(strlen(string), GL_BYTE, string);
	glPopAttrib();
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	glDisable(GL_BLEND);
}

void font_init()
{
	glEnable(GL_TEXTURE_2D);

	glGenTextures(1, &tex);
	glBindTexture(GL_TEXTURE_2D, tex);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

	gluBuild2DMipmaps(GL_TEXTURE_2D, 4, bitstream_bold.width, bitstream_bold.height, GL_RGBA, GL_UNSIGNED_BYTE, bitstream_bold.pixel_data);

	int grid = 10;
	int spacing = 10;

	int listSize = grid*grid;
	float calcg = 1/(float)grid;

	glEnable(GL_TEXTURE_2D);
	fontbase = glGenLists(listSize);
	glBindTexture(GL_TEXTURE_2D, tex);

	for(int i=0,k=0;i<grid;i++)
	{
		float y = 1-(k/grid)/(float)grid;
		for(int j=0;j<grid;j++,k++)
		{
			float x = 1-(j*grid)/(float)(grid*grid);
			glNewList(fontbase+((listSize-1)-k),GL_COMPILE);
			glBegin(GL_QUADS);
			glTexCoord2f(x-calcg, y);
			glVertex2f(0.0f, 0.0f);
			glTexCoord2f(x, y);
			glVertex2f(grid, 0.0f);
			glTexCoord2f(x, y-calcg);
			glVertex2f(grid, grid);
			glTexCoord2f(x-calcg, y-calcg);
			glVertex2f(0.0f, grid);
			glEnd();
			glTranslatef(spacing,0.0f,0.0f);
			glEndList();
		}
	}
	glDisable(GL_TEXTURE_2D);
}

void font_free()
{
	glDeleteLists(fontbase, 100);
}
 
