// Verkleinerungsmassnahmen
#pragma comment(linker,"/ENTRY:main /SUBSYSTEM:WINDOWS" )
#pragma comment(linker,"/MERGE:.rdata=.text /MERGE:.data=.text" )
#pragma comment(linker,"/SECTION:.text,EWR" )

// Includes
#include <windows.h>
#include "noise.h"
#include "color.h"
#include "helper.h"

#define POINTS_NR 62

extern "C"
{
	int _fltused = 1;
}

color image[6][1024][768];
float points[POINTS_NR][2] = { 
	{ 646, 16 },
	{ 544, 59 },
	{ 504, 154 },
	{ 473, 209 },
	{ 421, 257 },
	{ 360, 338 },
	{ 317, 373 },
	{ 270, 383 },
	{ 255, 408 },
	{ 272, 431 },
	{ 289, 446 },
	{ 294, 472 },
	{ 318, 511 },
	{ 358, 567 },
	{ 369, 564 },
	{ 339, 502 },
	{ 315, 460 },
	{ 302, 439 },
	{ 326, 414 },
	{ 359, 385 },
	{ 399, 349 },
	{ 471, 293 },
	{ 539, 198 },
	{ 566, 164 },
	{ 577, 190 },
	{ 576, 238 },
	{ 576, 271 },
	{ 579, 312 },
	{ 563, 390 },
	{ 563, 527 },
	{ 559, 597 },
	{ 568, 663 },
	{ 569, 743 },
	{ 693, 740 },
	{ 691, 581 },
	{ 713, 528 },
	{ 726, 596 },
	{ 740, 653 },
	{ 774, 715 },
	{ 852, 678 },
	{ 840, 517 },
	{ 839, 464 },
	{ 834, 427 },
	{ 832, 403 },
	{ 831, 351 },
	{ 816, 325 },
	{ 817, 300 },
	{ 812, 277 },
	{ 818, 256 },
	{ 810, 240 },
	{ 817, 227 },
	{ 814, 206 },
	{ 844, 218 },
	{ 866, 278 },
	{ 916, 350 },
	{ 949, 379 },
	{ 953, 273 },
	{ 902, 241 },
	{ 872, 178 },
	{ 856, 95 },
	{ 836, 58 },
	{ 794, 27 }
};

float CubicInterpolation(float A, float B, float C, float D, float t)
{
	float Y1 = D - C - A + B;
	float Y2 = A - B - Y1;
	float Y3 = C - A;
	return Y1 * t * t * t + Y2 * t * t + Y3 * t + B;
}

void Fill(int x, int y)
{
	if(image[3][x][y].p[0] == 1 || x < 0 || x > 1023 || y < 0 || y > 767)
		return;
	image[3][x][y].p[0] = 1;
	Fill(x + 1, y);
	Fill(x, y + 1);
	Fill(x - 1, y);
	Fill(x, y - 1);
}

void Blur(int src, int dest, int Radius, float m, float a)
{
	float sin = mysinf(a);
	float cos = mycosf(a);

	for(int x = 0; x < 1024; x++)
	{
		for(int y = 0; y < 768; y++)
		{
			color total = create(0, 0, 0);

			for(int r = -Radius; r <= Radius; r++) 
			{
				int xN = r * cos;
				int yN = r * sin;
				total = add(total, image[src][x + xN][y + yN]);
			}
						
			image[dest][x][y] = mul(mul(total, 1.0 / (Radius * 2 + 1)), m);
		}
	}
}

void BlurV(int src, int dest, int Radius, float m)
{
	for(int x = 0; x < 1024; x++)
	{
		color total = create(0, 0, 0);
		
		for(int ky = -Radius; ky <= Radius; ky++)
			total = add(total, image[src][x][ky + Radius]);

		image[dest][x][Radius] = mul(total, 1.0 / (Radius * 2 + 1));

		for(int y = Radius + 1; y < 768 - Radius; y++) 
		{
			total = sub(total, image[src][x][y - Radius - 1]);
			total = add(total, image[src][x][y + Radius]);
			image[dest][x][y] = mul(mul(total, 1.0 / (Radius * 2 + 1)), m);
		}
	}
}

void BlurH(int src, int dest, int Radius, float m)
{
	for(int y = 0; y < 768; y++)
	{
		color total = create(0, 0, 0);
		
		for(int kx = -Radius; kx <= Radius; kx++)
			total = add(total, image[src][kx + Radius][y]);

		image[dest][Radius][y] = mul(total, 1.0 / (Radius * 2 + 1));

		for(int x = Radius + 1; x < 1024 - Radius; x++) 
		{
			total = sub(total, image[src][x - Radius - 1][y]);
			total = add(total, image[src][x + Radius][y]);
			image[dest][x][y] = mul(mul(total, 1.0 / (Radius * 2 + 1)), m);
		}
	}
}

void draw(HDC hDC)
{
	for(int x = 0; x < 1024; x++)
	{
		for(int y = 0; y < 768; y++)
		{
			image[0][x][y] = create(0,0,0);
			image[1][x][y] = create(0,0,0);
			if(x > 105 && x < 879 && y > 90 && y < 512)
			{
				image[1][x][y] = create(0.45,0.3,0.1);
			}
			for(int i = 0; i < 3; i++)
			{
				for(int j = 0; j < 2; j++)
				{
					if(x > 115 + i * 252 && x < 115 + i * 252 + 250 && y > 100 + j * 202  && y < 100 + j * 202 + 200)
					{
						image[0][x][y] = create(1,1,1);
						image[1][x][y] = create(1,1,1);
					}
				}
			}
			image[3][x][y] = create(0,0,0);
			float noise = PNoise(x, y, 0);
			image[4][x][y] = create(noise * 0.235f, noise * 0.313f, noise * 0.196f);
			image[5][x][y] = create(0,0,0);
		}
	}

	for(int i = 0; i < 5000; i++)
	{
		int x = (Noise2d(i, 0, 0, 0) + 1) * 0.5f * 1023;
		int y = (Noise2d(0, i, 0, 0) + 1) * 0.5f * 768;
		float c = (Noise2d(i, i, 0, 0) + 1) * 0.5f;
		image[5][x][y] = create(c, c, c);
	}

	for(int i = 0; i < 3; i++)
	{
		BlurV(5, 2, 5, 1.5f);
		BlurH(2, 5, 5, 1.5f);
	}
	Blur(5, 2, 7, 1.5f, -1);
	Blur(2, 5, 7, 1.5f, -1);

	BlurV(1, 2, 30, 1);
	BlurH(2, 1, 30, 1);
	BlurV(1, 2, 30, 1);
	BlurH(2, 1, 30, 1);

	for(int i = 0; i < POINTS_NR; i++)
	{
		int i0 = i - 1;
		if(i0 < 0)
			i0 = POINTS_NR - 1;
		int i2 = (i + 1) % POINTS_NR;
		int i3 = (i + 2) % POINTS_NR;
		
		for(float t = 0; t <= 1; t += 0.00001)
		{
			float x = CubicInterpolation(points[i0][0], points[i][0], points[i2][0], points[i3][0], t);
			float y = CubicInterpolation(points[i0][1], points[i][1], points[i2][1], points[i3][1], t);
			image[3][(int)x][(int)y] = create(1,1,1);
		}
	}

	Fill(700, 200);

	BlurH(3, 2, 5, 1);
	BlurV(2, 3, 5, 1);
	
	for(int x = 0; x < 1024; x++)
	{
		for(int y = 0; y < 768; y++)
		{
			if(y < 60 || y > 708)
			{
				image[0][x][y] = create(0,0,0);
				continue;
			}

			image[5][x][y] = add(image[4][x][y], image[5][x][y]);
			image[4][x][y] = mul(mul(image[5][x][y], max(0, PNoise(1023 - x, 767 - y, 5) - 0.33f)), 3.5f);
			image[1][x][y] = clamp(add(add(image[0][x][y], add(mul(image[1][x][y], image[5][x][y]), mul(image[1][x][y], 0.5f))), image[4][x][y]));

			if(image[3][x][y].p[0] > 0)
			{
				image[0][x][y] = image[5][x][y];
					
				if(y < 400 && y > 300)
				{
					image[0][x][y] = add(mul(create(0,0,0), (float)(y - 300) / 100.0f), mul(image[5][x][y], 1.0f - (float)(y - 300) / 100.0f));
				}
				else if(y <= 300)
				{
					image[0][x][y] = image[5][x][y];
				}
				else if(y > 600)
				{
					image[0][x][y] = add(mul(image[4][x][y], (float)(y - 600) / 100.0f), mul(create(0,0,0), 1.0f - (float)(y - 600) / 100.0f));
				}
				else
				{
					image[0][x][y] = create(0,0,0);
				}

				if(x > 880)
				{
					image[0][x][y] = add(mul(image[4][x][y], min(1, (float)(x - 880) / 50.0f)), mul(image[5][x][y], max(0, 1.0f - (float)(x - 880) / 50.0f)));
				}
			}
			image[0][x][y] = sepia(mul(add(mul(image[1][x][y], 1 - image[3][x][y].p[0]), mul(image[0][x][y], image[3][x][y].p[0])), 1 + Noise2d(x, y, 0, 100) * 0.1f));
		}
	}

	for(int x = 0; x < 1024; x++)
	{
		for(int y = 0; y < 768; y++)
		{
			SetPixel(hDC, x, y, RGB(min(image[0][x][y].p[0] * 255, 255), min(image[0][x][y].p[1] * 255, 255), min(image[0][x][y].p[2] * 255, 255)));
		}
	}
}

void main()
{
	HDC hDC;
	HWND hWnd;

	DEVMODE dmScreenSettings;

	dmScreenSettings.dmSize = sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth = 1024;
	dmScreenSettings.dmPelsHeight = 768;
	dmScreenSettings.dmBitsPerPel = 32;
	dmScreenSettings.dmFields = DM_BITSPERPEL | DM_PELSWIDTH | DM_PELSHEIGHT;
	ChangeDisplaySettings(&dmScreenSettings, CDS_FULLSCREEN);

	hWnd = CreateWindowExA(0, "edit", NULL, WS_POPUP | WS_VISIBLE | WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, NULL);
	hDC = GetDC(hWnd);
	ShowCursor(FALSE);

	draw(hDC);

	MSG msg;
	/*
	while(GetAsyncKeyState(VK_ESCAPE) == 0)
	{
		
		if(PeekMessageA(&msg, NULL, 0, 0, PM_REMOVE))
		{


			switch(msg.message)
			{
			case WM_KEYDOWN:
				//go = 0;
				break;

			case WM_PAINT:

				break;
			}
		}
	}*/
	
	while(!GetAsyncKeyState(VK_ESCAPE)) { }
}