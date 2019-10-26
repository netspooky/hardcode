/*
 * SC2 Data Importer (c) 2004 Gautier Portet
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
#include <string.h>
#include "SDL.h"

char* files[13]= {
        "coquet",
        "gargamel",
        "grand",
        "knights",
        "smurfette",
        "font",
        "grognon",
        "title",
        NULL
};



/* The screen surface */
SDL_Surface *screen = NULL;


/* output one pixel */
void EncodePixel(FILE* f, Uint8 color)
{
        fprintf(f,"%d, ", color);
}

/* output one row of pixel with the same color */
void EncodeSpan(FILE * f, Uint8 color, int lenght)
{
        fprintf(f,"%d,", color | 0x80);
        fprintf(f,"%d, ", lenght);
}

/* handle one line */
void EncodeScanline( FILE *f, Uint8* p, int width)
{
        int x;
        int current, old;
        int lenght=0;

        old = 0;

        for(x=0; x<width; x++) {
                current = *p++;
                if ( (current==old)  ) {
                        /* same color, increment counter */
                        lenght++;
                        if (lenght>=255) {
                                /* overflow */
                                EncodeSpan(f, old, lenght);
                                lenght=0;
                        }
                } else {
                        /* different pixel */
                        if (lenght>1) {
                                /* was a span */
                                EncodeSpan(f, old, lenght);
                        } else {
                                /* was a pixel */
				if (x>0)
                                	EncodePixel(f, old);
                        }
                        lenght=1;
                }
                old = current;
        }
        /* residual pixels */
        if (lenght>1) {
                EncodeSpan(f, old, lenght);
        } else {
                EncodePixel(f, old);
        }
}

void SaveBitmap(char* filename)
{
        int x,y;
        int nbColors=0;
        int i;
        int histo[256];
        FILE *f;
        char str[1024];
        int green=0;

        printf("Processing Bitmap: %s\n",filename);

        /* loading */
        SDL_Surface *bmp;
        sprintf(str,"%s.bmp",filename);
        bmp = SDL_LoadBMP(str);
        if (bmp == NULL)
        {
                char msg[1024];
                sprintf (msg, "Cannot Load %s: %s\n", filename, SDL_GetError ());
                exit (2);
        }

        /* count colors */
        for(i=0;i<256;i++) {
                histo[i]=0;
        }
        for(y=0;y<bmp->h;y++) {
                Uint8 *p = ((Uint8*)bmp->pixels)+bmp->pitch*y;
                for(x=0;x<bmp->w;x++) {
                        Uint8 c;
                        c = *p++;
                        histo[c]++;
                }
        }
        for(i=0;i<256;i++) {
                if (histo[i]) {
                        nbColors++;
                }
        }
        printf("  %d unique colors\n",nbColors);    

        /* find and handle the colorkey */
        for(i=1; i<255; i++) {
                int r,g,b;
                r = bmp->format->palette->colors[i].r;
                g = bmp->format->palette->colors[i].g;
                b = bmp->format->palette->colors[i].b;
                if ( (r==0) && (g==255) && (b==0) ) {
                        green = i;
                }
        }
        if (green) { 
		/* force the green to be color 0 */
                printf("**** GREENing %s ****\n",str);
                bmp->format->palette->colors[green].r = bmp->format->palette->colors[0].r;
                bmp->format->palette->colors[green].g = bmp->format->palette->colors[0].g;
                bmp->format->palette->colors[green].b = bmp->format->palette->colors[0].b;
                bmp->format->palette->colors[0].r = 0;
                bmp->format->palette->colors[0].g = 255;
                bmp->format->palette->colors[0].b = 0;

                for(y=0;y<bmp->h;y++) {
                        Uint8 *p = ((Uint8*)bmp->pixels)+bmp->pitch*y;
                        for(x=0;x<bmp->w;x++) {
                                Uint8 c;
                                c = *p;
                                if (c==green) {
                                        *p=0;
                                } 	
                                if (c==0) {
                                        *p=green;
                                } 	
                                p++;
                        }
                }
                SDL_SaveBMP(bmp,str);
        }


        /* output the file */    
        sprintf(str,"../bmp_%s.c",filename);
        f = fopen(str,"w");

        fprintf(f,	"/* Generated by SC2 Data Importer */\n");
        fprintf(f,	"#include \"bitmap.h\"\n");

        fprintf(f,	"SCPalette pal_%s[] = {\n",filename);
        fprintf(f,"		 %d,%d,%d	\n"
                        ,bmp->format->palette->colors[0].b
                        ,bmp->format->palette->colors[0].g
                        ,bmp->format->palette->colors[0].r);
        y=1;
        for(i=1;i<nbColors;i++) {
                /*if (histo[y])*/ {
                        fprintf(f,"		,%d,%d,%d	\n",	bmp->format->palette->colors[y].b,
                                        bmp->format->palette->colors[y].g,
                                        bmp->format->palette->colors[y].r);   
                }
                y++;
        }
        fprintf(f,"	};\n");


        fprintf(f,	"SCPixel pix_%s[] = {\n",filename);
        for(y=0;y<bmp->h;y++) {
                Uint8 *p = ((Uint8*)bmp->pixels)+bmp->pitch*y;

                EncodeScanline(f,p,bmp->w);

                fprintf(f,"\n");
        }
        fprintf(f,"0};\n");

        fprintf(f,	"struct RLEBitmap bmp_%s = {\n"
                        "	%d,%d, 	/* widht, height */\n"
                        "	%d,		/* unique colors */\n"
                        "	pal_%s,		\n"
                        "	pix_%s		\n"
                        "};\n"
                        ,filename,bmp->w,bmp->h,nbColors,filename,filename);

        fclose(f);
}

int main (int argc, char *argv[])
{
        char msg[1024];
        FILE *f;
        FILE *m;
        unsigned char *buffer;
        int lenght;
        int i;
        char **p;

        /* Initialize SDL */
        if (SDL_Init(SDL_INIT_VIDEO) < 0)
        {
                sprintf(msg, "Couldn't initialize SDL: %s\n", SDL_GetError ());
                exit(1);
        }
        atexit(SDL_Quit);

        for(p = files; *p!=NULL; p++) {
                SaveBitmap(*p);
        }

        f = fopen("../music.c","w");
        fprintf(f,	"/* Generated by SC2-Tools */\n");
        m = fopen("benji.xm","rb");

        fseek(m,0,SEEK_END);
        lenght=ftell(m);
	buffer = (unsigned char*) malloc(lenght);
	
        fseek(m,0,SEEK_SET);
        printf("module size: %d\n",lenght);

        fread(buffer,1,lenght,m);

        fprintf(f,"unsigned char data_module[%d]= {\n",lenght);

        fprintf(f,"%d",buffer[0]);
        for(i=1;i<lenght;i++) {
                fprintf(f,",%d",buffer[i]);
                if ((i&15)==0) 
                        fprintf(f,"\n");
        }

        for(i=0;i<70;i++)
                printf("%c",buffer[i]);
	
	free(buffer);
	
        fprintf(f,"};\n");
        fclose(f);
        fclose(m);
	
	
        f = fopen("../../data.h","w");
        fprintf(f,	"/* Generated by SC2-Tools */\n");
        fprintf(f,	"#include \"bitmap.h\"\n");

        for(p = files; *p; p++) {
                fprintf(f,	"extern struct RLEBitmap bmp_%s;\n",*p);
        }

        fprintf(f,	"extern unsigned char data_module[%d];\n",lenght);

        fclose(f);

        return 0;
}
