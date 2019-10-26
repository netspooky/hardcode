#ifndef FROMPLANE2COLOR_VIEW_HPP
#define FROMPLANE2COLOR_VIEW_HPP

#ifndef WIDTH
#	define WIDTH	1024
#	define HEIGHT	768
#endif

#define VIEW_ASPECT_H(w)	(w*32/57)
#define VIEW_ASPECT_W(h)	(h*57/32)

#define VIEW_WIDTH			WIDTH
#define VIEW_HEIGHT			VIEW_ASPECT_H(WIDTH)

#if VIEW_HEIGHT > HEIGHT
#	undef VIEW_HEIGHT
#	undef VIEW_WIDTH
#	define VIEW_HEIGHT	HEIGHT
#	define VIEW_WIDTH	VIEW_ASPECT_W(HEIGHT)
#endif

#if (VIEW_WIDTH % 4) != 0
#	error
#endif

#if VIEW_WIDTH < VIEW_HEIGHT
#	define MIN_VIEW_LEN VIEW_WIDTH
#else
#	define MIN_VIEW_LEN VIEW_HEIGHT
#endif

#define DFXDVX (1.0f/MIN_VIEW_LEN)

#define NORM_WIDTH	(float(VIEW_WIDTH)/VIEW_HEIGHT)
#define NORM_HEIGHT	(1.0f)

static tofu::uvec4	buffer[(WIDTH/4)*HEIGHT];
static tofu::uvec4*	pClrBuf = buffer + (WIDTH/4)*((HEIGHT-VIEW_HEIGHT)/2);

static const BITMAPINFO bmi =
{
	{
		sizeof(BITMAPINFOHEADER),
		WIDTH,-HEIGHT,1,32,BI_RGB,0,0,0,0,0
	},
	{0,0,0,0}
};

static DEVMODE screenSettings = { {0},
    #if _MSC_VER < 1400
    0,0,148,0,0x001c0000,{0},0,0,0,0,0,0,0,0,0,{0},0,32,WIDTH,HEIGHT,0,0,      // Visual C++ 6.0, 2003
    #else
    0,0,156,0,0x001c0000,{0},0,0,0,0,0,{0},0,32,WIDTH,HEIGHT,{0}, 0,           // Visuatl Studio 2005
    #endif
    #if(WINVER >= 0x0400)
    0,0,0,0,0,0,
    #if (WINVER >= 0x0500) || (_WIN32_WINNT >= 0x0400)
    0,0
    #endif
    #endif
    };

#endif
