#define _WIN32_WINNT 0x0500 
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <gl/gl.h>
#include <gl/glu.h>
#include "TinySynth.h"

// Global scene parameters
const int TERR_X = 80;
const int TERR_Y = 80;
float g_terrainVert[TERR_Y][TERR_X][3];
float g_terrainNorm[TERR_Y][TERR_X][3];
float g_time;
const int N_FLOWER = 200;
const int TEX_SIZE = 16;
unsigned char g_grassTex[TEX_SIZE][TEX_SIZE];
	
// Global keys
struct FloatKey { float time; float value; };
const FloatKey g_camX[] = { { 0, 0 }, { 26, 0.1f }, { 28, 0.5f } };
const FloatKey g_camY[] = { { 0, 8 }, { 5.5f, 1 }, { 12.9f, 0.5f }, { 26, 0.5f }, { 38, 2 }, { 70, 2 }, { 75, 1 }, { 86, 7 } };
const FloatKey g_camZ[] = { { 0, -8 }, { 5.5f, 3 }, { 12.9f, 8 }, { 25.8f, -5 }, { 36, 5 }, { 40, -4 }, { 43, 1 }, { 58, 5 },
						{ 70, -5 }, { 75, 1 } };
const FloatKey g_camXAt[] = { { 0, 0 }, { 5.5f, 0 }, { 5.5f, -5 }, { 26, -5 }, { 38, 3 }, { 40, 0 }, { 43, 1 }, { 58, 1 }, 
						{ 60, -1 } };
const FloatKey g_camYAt[] = { { 0, 0 }, { 5.5f, 0 }, { 5.5f, 15 }, { 9.2f, 5 }, { 12.9f, 3 }, { 26, 3 }, { 30, 1 } };
const FloatKey g_camZAt[] = { { 0, -7 }, { 5.5f, 4 }, { 5.5f, 0 } };
const FloatKey g_fadeCoef[] = { { 0, 0 }, { 1, 1 }, { 5, 1 }, { 5.5f, 0 }, { 6, 1 }, { 12.5f, 1 }, 
							{ 12.9f, 0.5f }, { 13.3f, 1 }, { 24, 1 }, { 26, 0.5f }, { 27, 1 }, { 42, 1 }, { 42.5f, 0 }, { 43, 1 },
							{ 58, 1 }, { 59, 0 }, { 60, 1 }, { 82, 1 }, { 85, 0 } };
const FloatKey g_terrYScaleCoef[] = { { 0, 0 }, { 9.2f, 0 }, { 9.2f, 0.2f },  { 25.8f, 1 } };
const FloatKey g_sceneNo[] = { { 0, 1 }, { 42.5f, 1 }, { 42.5f, 2 }, { 59, 2 }, { 59, 1 } };
const FloatKey g_frameTimeDiff[] = { { 0, 0.2f }, { 26, 0.2f }, { 27, 0.05f }, { 42.5f, 0.05f }, { 43, 2 }, { 58, 2 },
							{ 59, 0.05f } };
const float g_sunLightPos[] = { 0.5f, 1, 0, 0 };

// ==================================================================
// Gets linear float key
float GetKeyFloatLinear ( const FloatKey* arr, int cnt, float time ) {
	for ( int i = 0; i < cnt - 1; i++ )
		if ( arr[i].time <= time && arr[i+1].time >= time ) {
			// Hard moving
			return arr[i].value + (time-arr[i].time)/(arr[i+1].time-arr[i].time)*(arr[i+1].value-arr[i].value);
			// Easy in/easy out
			/*float timeCoeff = (time-arr[i].time)/(arr[i+1].time-arr[i].time);
			float tcM = timeCoeff - 0.5f;
			timeCoeff = (timeCoeff-4.0f/3.0f*tcM*tcM*tcM)*1.5f-0.25f;
			return arr[i].value + timeCoeff*(arr[i+1].value-arr[i].value);*/
		}
	return arr[cnt-1].value;
} // GetKeyFloatLinear


// ==================================================================
// Returns terrain height at given point
float TerrainFunc ( float x, float z ) {
	float r = sqrtf ( x*x + z*z );
	float y = powf ( 3.0f / (1+powf(5-r,4)), 0.5f );
	y += sinf ( z*2.2f + x*1.2f ) * cosf ( x*1.3f ) * 0.2f + sinf(z*1.3f+x*1.2f)*0.3f + 0.3f;
	float rc = powf ( z*0.14f, 4 );
	y *= 1.0f - powf ( 2, -2*(x-rc)*(x-rc) );
	return y;
} // TerrainFunc


// ==================================================================
// Render procedure
void Render ( ) {
	glClear ( GL_ACCUM_BUFFER_BIT );
	
	// Determine which scene (or combination of scenes) to render
	int sceneNo = GetKeyFloatLinear ( g_sceneNo, sizeof(g_sceneNo)/sizeof(FloatKey), g_time );
	bool renderTerrain = sceneNo & 1;
	bool renderFlower = sceneNo & 2;
	for ( int rendPass = 0; rendPass < 2; rendPass++ ) {
		// Setup render states
		if ( renderTerrain )
			glClearColor ( 0.7f, 1, 1, 1 );
		else
			glClearColor ( 0, 0, 0, 0 );
		glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT );
		float tim = g_time + GetKeyFloatLinear ( g_frameTimeDiff, sizeof(g_frameTimeDiff)/sizeof(FloatKey), g_time ) * rendPass;
		glMatrixMode ( GL_MODELVIEW );
		glEnable ( GL_COLOR_MATERIAL );
		glEnable ( GL_LIGHTING );
		glEnable ( GL_LIGHT0 );
		glEnable ( GL_CULL_FACE );
		glEnable ( GL_DEPTH_TEST );
		glLoadIdentity ( );

		// Render terrain
		if ( renderTerrain ) {
			gluLookAt ( GetKeyFloatLinear ( g_camX, sizeof(g_camX)/sizeof(FloatKey), tim ), 
						GetKeyFloatLinear ( g_camY, sizeof(g_camY)/sizeof(FloatKey), tim ), 
						GetKeyFloatLinear ( g_camZ, sizeof(g_camZ)/sizeof(FloatKey), tim ), 
						GetKeyFloatLinear ( g_camXAt, sizeof(g_camXAt)/sizeof(FloatKey), tim ), 
						GetKeyFloatLinear ( g_camYAt, sizeof(g_camYAt)/sizeof(FloatKey), tim ), 
						GetKeyFloatLinear ( g_camZAt, sizeof(g_camZAt)/sizeof(FloatKey), tim ), 
						0, 1, 0 );
			glLightfv ( GL_LIGHT0, GL_POSITION, g_sunLightPos );
			glPushMatrix ( );

			// Render terrain
			// Texturing
			glEnable ( GL_TEXTURE_2D );
			glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
			glTexImage2D ( GL_TEXTURE_2D, 0, 3, TEX_SIZE, TEX_SIZE, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, g_grassTex );
			// Draw
			glColor3f ( 0.1f, 0.8f, 0.2f );
			glScalef ( 1, GetKeyFloatLinear ( g_terrYScaleCoef, sizeof(g_terrYScaleCoef)/sizeof(FloatKey), tim ), 1 );
			glBegin ( GL_QUADS );
				for ( int x = 0; x < TERR_X - 1; x++ )
					for ( int y = 0; y < TERR_Y - 1; y++ ) {
						float xt = 0.12f*((x*y+y*y)%5), yt = 0.7f*((x*x+y)%5);
						glTexCoord2f ( xt, yt );
						glNormal3fv ( g_terrainNorm[y][x] );
						glVertex3fv ( g_terrainVert[y][x] );
						glTexCoord2f ( xt + 0.8f, yt );
						glNormal3fv ( g_terrainNorm[y+1][x] );
						glVertex3fv ( g_terrainVert[y+1][x] );
						glTexCoord2f ( xt + 0.8f, yt + 0.8f );
						glNormal3fv ( g_terrainNorm[y+1][x+1] );	
						glVertex3fv ( g_terrainVert[y+1][x+1] );
						glTexCoord2f ( xt, yt + 0.8f );
						glNormal3fv ( g_terrainNorm[y][x+1] );
						glVertex3fv ( g_terrainVert[y][x+1] );
					}
			glEnd ( );
			glPopMatrix ( );
			glPushMatrix ( );
	
			// Render river
			glEnable ( GL_TEXTURE_GEN_S );
			glEnable ( GL_TEXTURE_GEN_T );
			glTexGeni ( GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP );
			glTexGeni ( GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP );
			glDisable ( GL_LIGHTING );
			glColor3f ( 0.4f, 0.7f, 0.9f );
			glBegin ( GL_QUADS );
				glVertex3f ( 3, 0.25f, 10 );
				glVertex3f ( 3, 0.25f, -10 );
				glVertex3f ( -2, 0.25f, -10 );
				glVertex3f ( -2, 0.25f, 10 );
			glEnd ( );
			glDisable ( GL_TEXTURE_GEN_S );
			glDisable ( GL_TEXTURE_GEN_T );
			glDisable ( GL_TEXTURE_2D );

			// Render sun
			glEnable ( GL_BLEND );
			glBlendFunc ( GL_SRC_ALPHA, GL_SRC_ALPHA );
			glColor4f ( 0.7f, 0.7f, 0.5f, 0.6f );
			GLUquadricObj* quadObj;
			quadObj = gluNewQuadric ( ); 
			gluQuadricDrawStyle ( quadObj, GLU_FILL );
			glPopMatrix ( );
			glPushMatrix ( );
			glTranslatef ( -8, 8, 0 );
			for ( float r = 0.5f; r <= 1.0f; r += 0.1f )
				gluSphere ( quadObj, r, 12, 12 );

			// Render flowers
			glColor4f ( 0.8f, 0.4f, 0.2f, 0.8f );
			if ( g_time > 50 ) {
				for ( int i = 0; i < N_FLOWER; i++ ) {
					glPopMatrix ( );
					glPushMatrix ( );
					float xx = -2.8f - sinf ( i );
					float zz = 3.5f * cosf ( i * i );
					float yy = TerrainFunc ( xx, zz ) + 0.02f;
					glTranslatef ( xx, yy, zz );
					for ( float r = 0.015f; r <= 0.02f; r += 0.005f )
						gluSphere ( quadObj, r, 3, 3 );
				}
			}
			glDisable ( GL_BLEND );

			// Render birds
			glEnable ( GL_LIGHTING );
			if ( g_time > 25.8f ) {
				for ( int b = 0; b < 10; b++ ) {
					glColor3f ( 0.3f, 0.3f, 0.4f );
					glPopMatrix ( );
					glPushMatrix ( );
					float bz = Sawtooth ( g_time*(1.0f+b*0.1f) + b ) * 10.0f;
					glTranslatef ( powf ( bz*0.14f, 4 ) + sinf ( b*2 ) * 0.4f, 1.5f + sinf ( b ) * 0.4f, bz );
					glPushMatrix ( );
					gluSphere ( quadObj, 0.02f, 8, 8 );				// Head
					gluCylinder ( quadObj, 0.02f, 0, 0.04f, 4, 4 );	// Beak
					glPopMatrix ( );
					glPushMatrix ( );
					glTranslatef ( 0, 0, -0.04f );
					glScalef ( 1, 1, 2 );
					gluSphere ( quadObj, 0.015f, 8, 8 );			// Body
					glPopMatrix ( );
					glPushMatrix ( ); 
					glTranslatef ( 0, 0, -0.10f );
					glScalef ( 1, 0.1f, 1 );
					gluCylinder ( quadObj, 0.02f, 0, 0.04f, 4, 2 );	// Tail
					for ( int i = -1; i <= 1; i += 2 ) {
						glPopMatrix ( );
						glPushMatrix ( );
						glTranslatef ( i*0.015f, 0, -0.03f );
						glRotatef ( i*90, 0, 1, 0 );
						glRotatef ( sinf ( g_time * 20 ) * 30.0f, 1, 0, 0 );
						glScalef ( 1, 0.1f, 1.5f );
						gluCylinder ( quadObj, 0.02f, 0, 0.04f, 4, 2 );	// Wing
					}
					glPopMatrix ( );
				}
			}
			gluDeleteQuadric ( quadObj );
			glPopMatrix ( );
		}

		// Render flower field
		if ( renderFlower ) {
			glPointSize ( 3 );
			glDisable ( GL_DEPTH_TEST );
			glLoadIdentity ( );
			gluLookAt ( cosf ( tim*0.1f )*3.0f, 0, sinf ( tim*0.1f )*3.0f, 0, 1.5f, 0, 0, 1, 0 );
			// Render flower
			glDisable ( GL_LIGHTING );
			glPushMatrix ( );
			for ( int k = 0; k < 40; k++ ) {
				glColor4f ( 0.5f + (k%5)/10.0f, 0.5f + (k%10)/20.0f, 0.5f + (k%7)/14.0f, 1 );
				float tfl = 0.5f - 0.5f * cosf ( tim*0.15f + k*0.01f );
				glPopMatrix ( );
				glPushMatrix ( );
				glTranslatef ( sinf ( k ) * 2, 0, cosf ( k * 1.3f ) * 2 );
				glRotatef ( k*50, 0, 1, 0 );
				// Stem
				float r = 0.01f; 
				for ( float a = 0; a < 1.0f; a += 0.05f ) {
					glTranslatef ( 0, 0.05f, 0 );
					glRotatef ( 10*(1-tfl)*(0.5f+a*5), 0, 0, 1 );
					glBegin ( GL_POINTS );
					for ( float b = 0; b < 2*PI; b += PI/2 )
						glVertex3f ( cosf ( b ) * r, 0, sinf ( b ) * r );
					r *= 0.9f;
					glEnd ( );
				}
				// Bud
				for ( int ang = 0; ang < 8; ang++ ) {
					glRotatef ( 45, 0, 1, 0 );
					glBegin ( GL_POINTS );
					for ( float t = 0; t < PI; t += PI/8 ) {
						float sf = sinf ( t ) * tfl * 0.1f;
						glVertex3f ( sinf ( 2*t ) * 0.03f, sf * tfl, sf * 2 );
					}
					glEnd ( );
				}
			}
			glPopMatrix ( );
		}

		// Store in accumulator
		glAccum ( GL_ACCUM, 1.2f/(rendPass+2) );
	}
	// Display accumulated data
	glAccum ( GL_RETURN, GetKeyFloatLinear ( g_fadeCoef, sizeof(g_fadeCoef)/sizeof(FloatKey), g_time ) );
	SwapBuffers ( wglGetCurrentDC ( ) );
} // Render


// ==================================================================
// Main function
int APIENTRY WinMain (	HINSTANCE hInstance,
						HINSTANCE hPrevInstance,
						LPSTR     lpCmdLine,
						int       nCmdShow ) {
	// Create window and make some OpenGL initialization
	HWND hWnd = CreateWindow ( "EDIT", NULL, WS_POPUP | WS_VISIBLE, 0, 0, 0, 0, NULL, NULL, hInstance, NULL );
	ShowWindow ( hWnd, SW_SHOWMAXIMIZED );
	ShowCursor ( FALSE );
	HDC hdc = GetDC ( hWnd );
	PIXELFORMATDESCRIPTOR pfd = { sizeof(PIXELFORMATDESCRIPTOR), 1, PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER,
		PFD_TYPE_RGBA, 32, 0, 0, 0, 0, 0, 0, 0, 0, 32, 0, 0, 0, 0, 32, 0, 0, PFD_MAIN_PLANE, 0, 0, 0, 0 };
	SetPixelFormat ( hdc, ChoosePixelFormat ( hdc, &pfd ), &pfd ); 
	wglMakeCurrent ( hdc, wglCreateContext ( hdc ) );
	RECT r;
	GetClientRect ( hWnd, &r );

	// Initialize demo
	CreateAndPlaySynth ( );
	glMatrixMode ( GL_PROJECTION );
	glLoadIdentity ( );
	gluPerspective ( 45, (GLdouble)r.right/r.bottom, 0.1f, 50 );
	glReadBuffer ( GL_BACK );

	// Generate terrain (maybe use glEnableClientState? or GL_QUAD_STRIP?)
	for ( int x = 0; x < TERR_X; x++ )
		for ( int y = 0; y < TERR_Y; y++ ) {
			float *p = g_terrainVert[y][x];
			float *n = g_terrainNorm[y][x];
			float xx, yy, zz;
			xx = (x - TERR_X/2)/(float)TERR_X * 10.0f;
			zz = (y - TERR_Y/2)/(float)TERR_Y * 20.0f;
			yy = TerrainFunc ( xx, zz );
			*(p++) = xx;
			*(p++) = yy;
			*(p++) = zz;
			*(n++) = ( TerrainFunc ( xx + 0.1f, zz ) - yy ) / 0.1f;
			*(n++) = 1;
			*(n++) = ( TerrainFunc ( xx, zz + 0.1f ) - yy ) / 0.1f;
		}
	// Create texture
	for ( int x = 0; x < TEX_SIZE*TEX_SIZE; x++ )
		*((unsigned char*)g_grassTex + x) = 180 + rand ( ) % 76;

	// Main message loop
	SetThreadPriority ( GetCurrentThread ( ), THREAD_PRIORITY_ABOVE_NORMAL );
	HANDLE hTimer = CreateWaitableTimer ( 0, TRUE, NULL );
	LARGE_INTEGER due = { -200000, -1 };
	MMTIME mt = { TIME_BYTES };
	while ( !GetAsyncKeyState ( VK_ESCAPE ) ) {
		SetWaitableTimer ( hTimer, &due, 0, NULL, NULL, FALSE );
		waveOutGetPosition ( g_wo, &mt, sizeof(mt) );
		g_time = (float)mt.u.cb / (SAMPLE_FREQUENCY*sizeof(short)) + TIME_OFFSET;
		Render ( );
		if ( g_time > PLAY_TIME - 0.5f )
			break;
		WaitForSingleObject ( hTimer, INFINITE );
	}
	ExitProcess ( 0 );
} // WinMain