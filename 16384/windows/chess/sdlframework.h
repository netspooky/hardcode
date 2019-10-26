#pragma once


// Create the window and rendering surface
int envCreateWindow( char *title, int width, int height, int colourbits, int fullscreen, int anyformat );

// Destroy our window
void envDestroyWindow();

// Update all global input variables
int envUpdate();

// Return number of 'ticks' elapsed accordingly to the number of "frame per second" passed as parameter
int envTimeCount( int fps );

// Set the cursor position somewhere
void envCursorPos( int x, int y );

// Get a pointer to the rendering surface, lock it for rendering
void *envLock2D();

// Unlock the surface, once done rendering, before a envUpdate2D()
void envUnlock2D();

// Update the surface on the screen
void envUpdate2D();

// Find the colour value from the RGB components specified. This is mostly an example
//int envPixelColor2D( int red, int green, int blue );

// Update a 8 bits palette using the 768 specified RGB values, in a 0-255 range
//void envPalette2D( unsigned char *pal );

// Render an image to the surface only (doesnt update)
void envDrawImage( SDL_Surface *image, SDL_Rect *srcrect, SDL_Rect *destrect);


extern SDL_PixelFormat *env_format;
extern SDL_Surface *env_surface;
extern SDL_VideoInfo *env_videoinfo;

extern unsigned char envKey[];

extern int envKeyboardEvents;
extern int envKeyboardBuffer[];

extern int envCursorX, envCursorY;
extern int envCursorState;

extern int envCursorEvents;
extern unsigned char envCursorBuffer[];

// Number of bytes per pixel
extern int envFormatBytes;

// Number of bits per pixel
extern int envFormatBits;

// 16-24-32 bits modes ; masks for RGB components
extern int envFormatRmask, envFormatGmask, envFormatBmask;

// 16-24-32 bits modes ; shifts for RGB components
extern int envFormatRshift, envFormatGshift, envFormatBshift;

// 16-24-32 bits modes ; loss shifts for RGB components
extern int envFormatRloss, envFormatGloss, envFormatBloss;
