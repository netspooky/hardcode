/* Schtroumpf - the intro - (c) 2004 Gautier Portet < kassoulet @ no-log . org >
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#include "introsystem.h"
#include "data.h"

/* for stopping the song, if needed */
int SONG_END = 0x2000;

extern DemoPart partLogo;
extern DemoPart partNoise;
extern DemoPart partIFS;
extern DemoPart partDejong;
extern DemoPart partHarmonics;
extern DemoPart partInterference;

DemoPart* parts[] = 
{
	&partLogo,
	&partNoise,
	&partHarmonics,
	&partIFS,
	&partInterference,
	&partDejong,
	NULL
};

GLuint texFont;
Surface *bmpFont;

void OpenParts()
{
	DemoPart **part=parts;
	char progress[32];
	int i=0;
	while(*part) {
		glClearColor( 0.1, 0.2, 0.3, 1 );
		glClear( GL_COLOR_BUFFER_BIT );
		DrawString(512, 384, "LOADING", TEXT_CENTER, texFont);
		progress[i]='.';
		progress[i+1]=0;
		i++;
		DrawString(512, 400, progress, TEXT_CENTER, texFont);
		Flip();
		
		(*part++)->Open();
	}
}

void CloseParts()
{
	DemoPart **part=parts;
	while(*part) {
		fflush(stdout);
		(*part++)->Close();
	}
}

void DrawParts(double time, double delta, int position)
{
	DemoPart **ppart=parts;	
	
	while(*ppart) {
		DemoPart *part = *ppart;
		if ( (position>=part->start) && (position<part->end) ) {
			part->Draw(time, delta, position);
		}
		ppart++;
	}
}

void InitNoise();
extern double oldTicks;

int main(int argc, char** argv)
{
        int end=0;
	
	/* Init */	
        puts("Schtroumph 2.0 (c) 2004 knights");
#ifdef USE_SDL	
	mkdir("pandora");
#endif	
        OpenSystem();
        //OpenVideo(512,384,0);
        OpenVideo(1024,768,1);

	
	InitNoise();
	
	/* Load font */
	bmpFont = LoadRLEBitmap(&bmp_font);
        texFont = CreateTexture(128,64);
	UploadTexture(texFont, bmpFont);
	
	
	DrawString(512, 384, "", TEXT_CENTER, texFont);
	Flip();

	OpenParts();
	
        OpenMusic(data_module, sizeof(data_module));

	/* Skip pattern, if needed */
	//SetMusicPosition(0x12);

	ticks=0;
	oldTicks=0;
	delta=0;
	
	while (!end) {
		
		int position;

		position = GetMusicPosition();
		
		if (CheckUserBreak()) {
			end = 1;
		}
		if (position>=SONG_END) {
			end = 1;
		}
		
		DrawParts(ticks, delta, position);
		Flip();
	}
	
	printf("%d fps\n",(int) (1000*frames/ticks));
	
        CloseMusic();

        FreeTexture(texFont);
        FreeSurface(bmpFont);

	CloseParts();
        CloseVideo();
        CloseSystem();

	
	return 0;
}

