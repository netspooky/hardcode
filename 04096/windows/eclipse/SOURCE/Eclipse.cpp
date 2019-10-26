// Windows
#include <windows.h>
#include <mmsystem.h>

// OpenGL
#include <gl\gl.h>
#include <gl\glu.h>

#include "global.h"


// Setting up between Perspective and Ortho
void ReSizeGLScene(bool projection)
{
	glViewport(0, 0, SCREEN_X, SCREEN_Y);

	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();

	if(projection) // Perspective
	{
		gluPerspective(45.0f, 
					   SCREEN_X / SCREEN_Y, 
					   1, 
					   65536);

	} else	// Orthogonal
	{
		glOrtho(0, 
			    SCREEN_X, 
				SCREEN_Y, 
				0, 
				0.0f, 
				65536.0f);
	}

	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
}

// some projection steps run through custum calculations
void custum(float matrix[16], vec *vtx)
{
	glVertex3f(matrix[0] * vtx->x + matrix[4] * vtx->y + matrix[8]  * vtx->z + matrix[12],
			   matrix[1] * vtx->x + matrix[5] * vtx->y + matrix[9]  * vtx->z + matrix[13],
			   matrix[2] * vtx->x + matrix[6] * vtx->y + matrix[10] * vtx->z + matrix[14]);

}


// Create a empty texture
inline GLuint EmptyTexture()
{
	unsigned int txtnumber;

	glGenTextures(1, &txtnumber);
	glBindTexture(GL_TEXTURE_2D, txtnumber);

	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	return txtnumber;						// Return The Texture ID
}

// this function produces all effects using a sphere as base
// It features some kind of Matrix Extrude and a flower effect
void SphereKewl(
bool bind,		
				
float radius, int cuts, int dots,

bool fx1,
bool fx2,

float fx_param1 = 0.0f,
float fx_param2 = 0.0f,
float fx_param3 = 0.0f,
float fx_param4 = 0.0f,
float fx_param5 = 0.0f,
float fx_param6 = 0.0f,

float fx1_mult  = 2.0f,

float offsetstart = 0,
float offsetend   = 0
)
{
	bool firstone = true;

	float matrix[2][16];

	// bv1, bv4 = saved verticle positions from last loop step
	// normal   = normal :)
	// v1, v2, 
	// v3, v4   = storage of caluculated vertices
	// first,lf	= lastfirst (temporary storage)
	// next, ln = lastnext  (temporary storage)

	vec bv4, bv1, normal, v1, v2, v3, v4, lf, ln, first, next;

	for(float cut = offsetstart; cut < cuts-offsetend; cut++)
	{
		first.z  = (float) cos(( cut       / cuts) * PI) * radius;
		next.z   = (float) cos(((cut+1.0f) / cuts) * PI) * radius;
		
		float first_radius = sqrt(pow2(radius) - pow2(first.z));
		float  next_radius = sqrt(pow2(radius) - pow2(next.z));

		for(float dot = 0; dot < dots; dot++)
		{
			glGetFloatv(GL_MODELVIEW_MATRIX, &matrix[0][0]);

			first.x = cos((dot     / dots) * PI * 2.0f);
			first.y = sin((dot     / dots) * PI * 2.0f);
			next.x  = cos(((dot+1) / dots) * PI * 2.0f);
			next.y  = sin(((dot+1) / dots) * PI * 2.0f);

			lf.x = 0;
			lf.y = 0;
			lf.z = 0;

			ln.x = 0;
			ln.y = 0;
			ln.z = 0;

			#define DEGREES 180.0f * PI / 15.0f

			if(fx1)
			{
				if(sin((cut / cuts) * DEGREES) > 0.0f)
					lf.z = first.z * fx1_mult;

				if(sin(((cut+1) / cuts) * DEGREES) > 0.0f)
					ln.z = next.z * fx1_mult;
			}

			if(fx1)
			{
				if(cos((dot / dots) * DEGREES) > 0.0f)
				{
					lf.x = first.x * fx1_mult;
					lf.y = first.y * fx1_mult;
				}

				if(cos(((dot+1) / dots) * DEGREES) > 0.0f)
				{
					ln.x = next.x * fx1_mult;
					ln.y = next.y * fx1_mult;
				}
			}

			if(fx2)
			{
				// "* fx1_mult" to each ln/lf gives a 6 byte better compression! -> wtf -> he compresses together with "* fx1_mult" in fx1?

				lf.z = first.z * sin((cut     / cuts) * 180.0f * PI / fx_param1) * fx1_mult;
				ln.z = next.z  * sin(((cut+1) / cuts) * 180.0f * PI / fx_param1) * fx1_mult;

				lf.x = first.x * sin((dot / dots)     * 180.0f * PI / fx_param2) * fx1_mult;
				lf.y = first.y * sin((dot / dots)     * 180.0f * PI / fx_param2) * fx1_mult;

				ln.x = next.x  * sin(((dot+1) / dots) * 180.0f * PI / fx_param2) * fx1_mult;
				ln.y = next.y  * sin(((dot+1) / dots) * 180.0f * PI / fx_param2) * fx1_mult;
			}
	
			v1.x = (ln.x + next.x)  * next_radius;
			v1.y = (ln.y + next.y)  * next_radius;
			v1.z = ln.z + next.z;

			v2.x = (lf.x + first.x) * next_radius;
			v2.y = (lf.y + first.y) * next_radius;
			v2.z = ln.z + next.z;

			v3.x = (lf.x + first.x) * first_radius;
			v3.y = (lf.y + first.y) * first_radius;
			v3.z = lf.z + first.z;

			v4.x = (ln.x + next.x)  * first_radius;
			v4.y = (ln.y + next.y)  * first_radius;
			v4.z = lf.z + first.z;
		
			if(fx1)
			{
				glRotatef(fx_param4, 1.0f, 0.0f, 0.0f);
				glRotatef(fx_param5, 0.0f, 1.0f, 0.0f);
				glRotatef(fx_param6, 0.0f, 0.0f, 1.0f);

				glTranslatef(fx_param1, fx_param2, fx_param3);
			}

			// Save the Matrix before we Pop back
			glGetFloatv(GL_MODELVIEW_MATRIX, &matrix[1][0]);

			glPushMatrix();

			glLoadIdentity();

			if(bind && !firstone)
			{
					glColor3f(0.0f, 0.0f, 0.0f);

				glBegin(GL_LINE_LOOP);
					custum(matrix[1], &v2);
					custum(matrix[1], &v3);
					custum(matrix[0], &bv4);
					custum(matrix[0], &bv1);
				glEnd();
			}


			// Setup for Solid Elements	
			glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
			glColor4f(1.0f, 1.0f, 1.0f, alfa); // alf 0.5f für nett, 0.9 für neu

			if(bind && !firstone)
			{
				glBegin(GL_QUADS);
					glNormal3fv(&normal.x);
					custum(matrix[1], &v2);
					custum(matrix[1], &v3);
					custum(matrix[0], &bv4);
					custum(matrix[0], &bv1);
				glEnd();
			}

			// now binding allowed
			firstone = false;
			
			// save some data for the binding functionality

			bv4.x = v4.x;
			bv4.y = v4.y;
			bv4.z = v4.z;

			bv1.x = v1.x;
			bv1.y = v1.y;
			bv1.z = v1.z;

			glPopMatrix();

			// Rape LF and LN for the crossproduct

			lf.x = v2.x - v1.x;
			lf.y = v2.y - v1.y;
			lf.z = v2.z - v1.z;
			
			ln.x = v2.x - v3.x;
			ln.y = v2.y - v3.y;
			ln.z = v2.z - v3.z;

			// calculate normal

			normal.x = lf.y * ln.z - lf.z * ln.y;
			normal.y = lf.z * ln.x - lf.x * ln.z;
			normal.z = lf.x * ln.y - lf.y * ln.x;

			glBegin(GL_QUADS);
				glNormal3fv(&normal.x);

				glVertex3fv(&v1.x);
				glVertex3fv(&v2.x);
				glVertex3fv(&v3.x);
				glVertex3fv(&v4.x);
			glEnd();

				glColor3f(0.0f, 0.0f, 0.0f);
			
				glBegin(GL_LINE_LOOP);

					glVertex3fv(&v1.x);
					glVertex3fv(&v2.x);
					glVertex3fv(&v3.x);
					glVertex3fv(&v4.x);
				glEnd();
		}
	}

}

inline void SceneSetup()
{
	glClearColor(clearcolor, clearcolor, clearcolor, clearalpha);

	// Blue
	float diffuse[]   = { 0.4f, 0.45f, 0.50f, 1.5f  };
	float ambient[]   = { 0.10f, 0.15f, 0.20f, 1.0f };
	float light_pos[] = {20, 0, 0, 0};

	if(color)
	{
		// Red
		diffuse[0] = 0.25f;
		diffuse[1] = 0.20f;
		diffuse[2] = 0.15f;
		ambient[0] = 0.20f;
		ambient[1] = 0.15f;
		ambient[2] = 0.10f;
	}

	int light;

	for(int i = 0; i < 2; i++)
	{
		if(!i)
			light = GL_LIGHT0;
		else
			light = GL_LIGHT1;

		glLightfv(light, GL_POSITION, light_pos);
		glLightfv(light, GL_DIFFUSE,  diffuse);
		glLightfv(light, GL_AMBIENT,  ambient);
		glEnable(light);
	}

	glEnable(GL_COLOR_MATERIAL);
	glEnable(GL_NORMALIZE);	
	glEnable(GL_LIGHTING);

	ReSizeGLScene(PERSPECTIVE);
}

// Draw The Blurred fade in Image Effect with the captured Image
inline void drawBLUR(int blurtype, float hardness)
{
	ReSizeGLScene(ORTHOGONAL);

	glDisable(GL_DEPTH_TEST);

	glEnable(GL_TEXTURE_2D);

// Possibilities for the combinations in glBlendFunc()
/*
    GL_ZERO, GL_ONE, GL_DST_COLOR, GL_ONE_MINUS_DST_COLOR, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, 
	GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA, GL_SRC_ALPHA_SATURATE.

    GL_ZERO, GL_ONE, GL_SRC_COLOR, GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, 
	GL_DST_ALPHA, GL_ONE_MINUS_DST_ALPHA.
*/

	// ATI LIKE
	if(blurtype == BLUR_NICE)
	{
		glBlendFunc(GL_DST_COLOR, GL_SRC_ALPHA); // nicest @ near to 0.9
 		glColor4f(1.0f, 1.0f, 1.0f, hardness);
		
		clearcolor = 0.9f;
		clearalpha = 0.9f;

		alfa = (sin(cam / 32.0f) + 2.0f) / 4.0f;

		bass = false;
	} else
	if(blurtype == BLUR_DISCO)
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_DST_ALPHA);
		glColor4f(1.3f, 1.3f, 1.3f, 1.0f);

		clearcolor = 0.5f;
		clearalpha = 0.75f;

		alfa = 0.6f;
	} else
	{
		glBlendFunc(GL_ONE_MINUS_DST_COLOR, GL_SRC_ALPHA);
		glColor4f(1.3f, 1.3f, 1.3f, 3.0f);

		clearcolor = 0.5f;
		clearalpha = 1.0f;

		alfa = 0.5f;
	}

	if(!bass)
	{
		glTranslatef(0.0f, -256.0f, 0.0f);

		glBegin(GL_QUADS);
			
			float move = 0.0175f + sin(runtime / 6.0f) / 64.0f; //15f;

			glTexCoord2f(move,	   1.0f - 0.25f - move / 1.0f);
			glVertex2i  (0,		   256);

			glTexCoord2f(move,	   move / 1.0f);
			glVertex2i  (0,		   SCREEN_X);

			glTexCoord2f(1.0f-move, move / 1.0f);
			glVertex2i  (SCREEN_X, SCREEN_X);

			glTexCoord2f(1.0f-move, 1.0f - 0.25f - move / 1.0f);
			glVertex2i  (SCREEN_X, 256);
		glEnd();
	}

	bass = false;

	glDisable(GL_TEXTURE_2D);
}


void DrawGLScene()
{
	SceneSetup();
	
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glLoadIdentity();

	runtime++;
	cam++;

	float hardness = 0.75f;

	glLineWidth(3.0f);

	bool drawblur = true;

	int blurtype = BLUR_NICE;


	if(onChange)
	{
			if(SeqPos == 21)
			{
				runtime = 0;
			}

		drawblur = false;
		onChange = false;
	}

	if(SeqPos > 20) // Tunnel
	{	
		hardness = 0.85f;

		glDisable(GL_DEPTH_TEST);

		glTranslatef(0.0f, 0.0f, -6000 + runtime*6);
 
		if(SeqPos >= 26)
		{
			hardness = 0.6f;
		}

		SphereKewl(true,
				   16.0f, 
				   8,
				   512, true, false,
				   0,
				   0,
				   3,
				   0,
				   0,
				   177,
				   4.0f);
	} else
	if(SeqPos <= 10) // Initial Flower
	{
		glEnable(GL_DEPTH_TEST);

		gluLookAt(48, 0, 32,
	 			  0,  0,  0,
				  0,  0,  1);

		glRotatef(cam, 0.0f, 0.0f, 1.0f);
			
		float distance = 6.0f + 6 * -cos(runtime / 256.0f);

		if(SeqPos > 5)
		{
			distance = 7.0f;
			blurtype = BLUR_DISCO;
		}

		SphereKewl(false,
				   distance, 
				   32,
				   128,
				   false, true,
		 		   5.25f    * 2.0f + sin(runtime / 64.0f) * 1.0f,
				   1.40625f * 8.0f,
				   0.0f,
				   0.0f,
				   0.0f,
				   0.0f,
				   1.0f, 18, 4);

	}
	else // Tentacles and Star
	{
		float value = 30;

		for(int j = 0; j < 8; j++)
		{
			if(SeqPos > 16) // Star.
			{
				glEnable(GL_DEPTH_TEST);

				blurtype = BLUR_NEW;

				if(j == 0)
				{
					glTranslatef(0.0f, 0.0f, -100);

					glRotatef(cam/2, 0.0f, 1.0f, 1.0f);
				}

				SphereKewl(false,
						   4.0f + j, 
						   4,
						   12, true, false, 0, 0, 0, 0, 0, 0, 2.0f, 1, 1);


			} else // Tentacles
			{
				value += 989;
				glPushMatrix();	
					
					glRotatef(runtime / 45.0f, 0.0f, 0.0f, 1.0f);
					glTranslatef(0, 0, -1000 + sin(runtime / 320.0f) * 400);
			
					glRotatef(value*32, 1.0f, 0.0f, 0.0f);
					glRotatef(value*77, 0.0f, 0.0f, 1.0f);

					if(SeqPos <= 12)
						blurtype = BLUR_DISCO;
					else
						blurtype = BLUR_NICE;

					SphereKewl(true,
							   64,
							   4,
							   46,
							   true,
							   false,
		 					   0.5f,
							   3.0f,
							   sin(cam / 30.0f) * 3.25f + 3.0f,
							   cos(cam / 45.0f) * 3.35f,
							   sin(cam / 30.0f) * 3.35f,
							   cos(cam / 60.0f) * 1.75f + sin(cam / 30.0f) * 0.75f,
							   1, 1, 1);

				glPopMatrix();
			}
		}
	}

	glBindTexture(GL_TEXTURE_2D, BlurTexture);

	if(drawblur)
		drawBLUR(blurtype, hardness);

	glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, 1024, 1024, 0); // Save current screencontent
}


inline void RenderSynth(int buffer) 
{
	short *fillPos = &SampleBuffer[0] + buffer * (BUFFERSIZE * 2);

	for (int i = 0; i<BUFFERSIZE; i++)
	{
		if (SongTime%TEMPO == 0)
		{
			if(SongTime != 0)
			{
				if(SongPos%PATTERNLENGTH == 0)
				{
					SeqPos++;
					onChange = true;
				}


				if(SeqPos == SONGLENGTH)
				{
					end = true;
				}

				SongPos++;
			}
		}

		int wave = 0;

		for(int c = 0; c < CHANNELS; c++)
		{
			int pattern = Sequence[c][SeqPos]-1; // Get the Pattern used by the Channel

			if (SongTime%TEMPO == TEMPO-128)
			{
				if(Patterns[pattern][(SongPos+1)%PATTERNLENGTH] != 0)
				{
					Channels[c].RapidDown = true;
				}
			}

			if (SongTime%TEMPO == 0)
			{
				if(pattern != -1)
				{
					if(Patterns[pattern][SongPos%PATTERNLENGTH] > 0)
					{
						Channels[c].RapidDown = false;
						Channels[c].Frequency = (float) Patterns[pattern][SongPos%PATTERNLENGTH];

						Channels[c].SampleTime = 0;
						Channels[c].SampleVol  = (float) Channels[c].Volume;

						bass  = true;
						color = !color;
					}
				}
			}

			int SampleTime  = Channels[c].SampleTime;
			float Frequency = Channels[c].Frequency;

			float x = (sin(SampleTime / Frequency));

			if(c == 0) // wiered wave for channel #0
			{
					x += cos(SampleTime / Frequency * 2.0f) / 2.0f;
					x += cos(SampleTime / Frequency * 3.0f) / 1.5f;
			}

			float add = 0.0f;

			float amount = Channels[c].FX1_ModA - 
						   (sin(SongTime / (32.0f * 4096.0f)) / 
						   Channels[c].FX1_ModB);

			if(amount > 0.85f) // adjusted the fake reverb a bit more in the final
				amount = 0.85f;

			float k = 2.0f * amount / (1.0f - amount);
			x = (1+k) * x / (1 + k * abs(x));
			

			if(SampleTime < Channels[c].InTime) // Fade In
			{
				Channels[c].SampleVol = Channels[c].Volume * ((float)SampleTime) / Channels[c].InTime;

				add = x * Channels[c].SampleVol;

				Channels[c].Frequency += Channels[c].ModIn;
			} else // Fade Out
			{
				Channels[c].Frequency += Channels[c].ModOut;
				Channels[c].SampleVol += Channels[c].VolumeOut;

				if(Channels[c].RapidDown) // avoid clicking works now (final)
				{
					Channels[c].SampleVol -= 200.0f;
				}

				// cut off if its not possible to hear it (negative wave..? ^^)
				if(Channels[c].SampleVol < 0)
					Channels[c].SampleVol = 0;

				 add = x * Channels[c].SampleVol;
			}

			wave += (int) add;
	
			Channels[c].SampleTime++;
		}

		// cut off if it doesnt fit in

		if(wave < -MAX_SHORT)
			wave = -MAX_SHORT;

		if(wave > MAX_SHORT)
			wave = MAX_SHORT;

		*fillPos++ = wave;
		*fillPos++ = wave;

		SongTime++;
	}

};

// this function is the reason why its opensource. 
// I forgot who spreaded this ~2 years ago, but thanks, 
// without this i would be screwed up! hope i can help some
// new ppl too.
inline void SoundThread()
{
	int lastBufferRendered = 0;
	
	while (true) // seems to work
	{
		MMTIME	mmt;
		mmt.wType = TIME_BYTES;
		waveOutGetPosition(waveOutHandle, &mmt, sizeof(MMTIME));
		int cursorPos = mmt.u.cb / 4;
		cursorPos %= (BUFFERS * BUFFERSIZE);
		int cursorBuffer = cursorPos / BUFFERSIZE;
		int prevBuffer   = cursorBuffer - 1;
		
		if (prevBuffer < 0)
			prevBuffer = BUFFERS - 1;
		
		if (lastBufferRendered != prevBuffer)
		{
			RenderSynth(prevBuffer);
			lastBufferRendered = prevBuffer;
		}
	
		Sleep(10);
	};
}

void mainCRTStartup(HINSTANCE hInstance)
{
	HDC		hDC;
	HGLRC	hRC;
	HWND	hWnd;

	GLuint		PixelFormat;
	WNDCLASS	wc;

	wc.style			= CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
	wc.lpfnWndProc		= (WNDPROC) WndProc;
	wc.cbClsExtra		= 0;
	wc.cbWndExtra		= 0;
	wc.hInstance		= hInstance;
	wc.hIcon			= LoadIcon(NULL, IDI_WINLOGO);
	wc.hCursor			= LoadCursor(NULL, IDC_ARROW);
	wc.hbrBackground	= NULL;
	wc.lpszMenuName		= NULL;
	wc.lpszClassName	= "Eclipse";

	RegisterClass(&wc);
	
	DEVMODE dmScreenSettings;
	
	dmScreenSettings.dmSize			= sizeof(dmScreenSettings);
	dmScreenSettings.dmPelsWidth	= SCREEN_X;
	dmScreenSettings.dmPelsHeight	= SCREEN_Y;
	dmScreenSettings.dmBitsPerPel	= 32;
	dmScreenSettings.dmFields		= DM_BITSPERPEL | 
									  DM_PELSWIDTH  |
									  DM_PELSHEIGHT;

	ChangeDisplaySettings(&dmScreenSettings, CDS_FULLSCREEN);

	ShowCursor(FALSE);	

	// Create The Window
	hWnd = CreateWindowEx(WS_EX_APPWINDOW,
						  "Eclipse", // Class Name
						  "Eclipse", // Window Title
						  WS_POPUP,
						  0, 0,
						  SCREEN_X,
						  SCREEN_Y,
						  NULL,
						  NULL,
						  hInstance,
						  NULL);

	static	PIXELFORMATDESCRIPTOR pfd =
	{
		sizeof(PIXELFORMATDESCRIPTOR),
		1,					 // Version
		PFD_DRAW_TO_WINDOW |
		PFD_SUPPORT_OPENGL |
		PFD_DOUBLEBUFFER,
		PFD_TYPE_RGBA,
		32,				     // Color Bits
		0, 0,				 // Ignored
		0, 0,				 // Ignored
		0, 0,			     // Ignored
		8,				 // cAlphaBits!!!!!!!!!! very important for nv/ati compability, dont forget to set here something or nv will fuck it up
		0,
		
		0,			// wtf is this cAcccumBits
		0, 0,
		0, 0,
		
		32, // Depth
		0, // Stencil
		0, // Auxiliary
		
		PFD_MAIN_PLANE,
		0, // Reserved
		0, 0, 0 // Ignored
	};
	

	hDC = GetDC(hWnd);

	PixelFormat = ChoosePixelFormat(hDC, &pfd);

	SetPixelFormat(hDC, PixelFormat, &pfd);

	hRC = wglCreateContext(hDC);

	wglMakeCurrent(hDC,hRC);

	ShowWindow(hWnd,SW_SHOW); // Show The Window (forgot some optimization.. there is a SHOW flag)

	BlurTexture = EmptyTexture();

	
	// Sound 
	WAVEFORMATEX pcmwf;

	pcmwf.wFormatTag		= WAVE_FORMAT_PCM;
	pcmwf.nChannels			= 2;
	pcmwf.wBitsPerSample	= 16;
	pcmwf.nBlockAlign		= pcmwf.nChannels * pcmwf.wBitsPerSample / 8;
	pcmwf.nSamplesPerSec	= MIXRATE;
	pcmwf.nAvgBytesPerSec	= pcmwf.nSamplesPerSec * pcmwf.nBlockAlign;
		
	waveOutOpen(&waveOutHandle, WAVE_MAPPER, &pcmwf, 0, 0, 0);

	waveHdr.dwFlags			= WHDR_BEGINLOOP | WHDR_ENDLOOP;
	waveHdr.lpData			= (LPSTR) SampleBuffer;
	waveHdr.dwBufferLength	= BUFFERSIZE * 2 * BUFFERS * 2;
	waveHdr.dwLoops			= -1;

	waveOutPrepareHeader(waveOutHandle, &waveHdr, sizeof(WAVEHDR));
	
	waveOutWrite(waveOutHandle, &waveHdr, sizeof(WAVEHDR));

	DWORD	threadId;

	CreateThread(NULL, 
				 0, 
				 (LPTHREAD_START_ROUTINE) SoundThread, 
				 0, 
				 0, 
				 &threadId);

	// Main

	glEnable(GL_BLEND);

	while(!::GetAsyncKeyState(VK_ESCAPE) && !end)
	{
		DrawGLScene();
		SwapBuffers(hDC);
	}

	DestroyWindow(hWnd);
	UnregisterClass("Eclipse", hInstance);

	ChangeDisplaySettings(NULL, 0);
	ShowCursor(TRUE);

//  winmms fault. :) closing doesnt work, the window still is there
//	waveOutClose(waveOutHandle);
}
