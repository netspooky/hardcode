#include "incs.h"

SDL_Surface* LoadTransparentBitmap(Uint8 r, Uint8 g, Uint8 b, char *filename)
{
   SDL_Surface *image;
   
   image = SDL_LoadBMP(filename);
   if (image>0) {
      if (SDL_SetColorKey(image, SDL_SRCCOLORKEY, SDL_MapRGB(image->format, r, g, b))==0) {
            return image;
      } else {
            return (SDL_Surface*)NULL;
      }
   } else {
           return (SDL_Surface*)NULL;
   }
}

int DrawString(SDL_Surface *screen, int x, int y, char *message)
{
   const int spaceing = 8;
   
   int i = 0;
   int newx = x;
   int newy = y;	
   
   /* Load transparent bitmap. (set black as transparent color) */
   SDL_Surface *my_font = LoadTransparentBitmap(0,0,0,FONT_STD_BITMAP);
   if (my_font==0) {
      return 1;
   }
   
   /* Loop through the whole string and print each char to screen */
   for (i = 0;i < strlen(message);i++) {		
      char c = message[i];
      
      if (c=='\n') {
         newy = newy + 16;
         newx = x - spaceing;
      }		
      /* Set Rect for character in bitmap. (ascii table. char boxes 16x16 */
      SDL_Rect srcRect = {(int)(floor(c%16)*16), (int)(floor(c/16)*16), 16, 16}; 
                  
      /* Set Rect for character on screen */
      SDL_Rect destRect = {newx,newy,16,16};
      
      /* Blit the character to screen. */
      SDL_BlitSurface(my_font, &srcRect, screen, &destRect);
      
      /* Add spaceing to current x position */
      newx = newx + spaceing;
   }
   /* Free my_font surface from memory. */
   SDL_FreeSurface(my_font);
      
   return 0;			
}
