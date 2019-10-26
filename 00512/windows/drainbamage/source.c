#include <Windows.h>

#define WIDTH		640
#define HEIGHT		400
#define SIZE		WIDTH * HEIGHT
#define SCR_WIDTH	GetSystemMetrics(SM_CXSCREEN)
#define SCR_HEIGHT	GetSystemMetrics(SM_CYSCREEN)

static const BITMAPINFO bmi = {{sizeof(BITMAPINFOHEADER), WIDTH, -HEIGHT, 1, 32, BI_RGB, SIZE, 0, 0, 0, 0},{0, 0, 0, 0}};
static DWORD pixel[SIZE];

void WinMainCRTStartup()
{
	HDC hDC = GetWindowDC(0);
	loop:
		DWORD i=SIZE;
		while(--i) pixel[i]+=i;
		StretchDIBits(hDC, 0, 0, SCR_WIDTH, SCR_HEIGHT, 0, 0, WIDTH, HEIGHT, (unsigned int *)pixel, &bmi, DIB_RGB_COLORS, SRCCOPY);
	goto loop;
}