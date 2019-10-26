//compiled with MSVC 2008
//compiler options:
// /O2 /Ob1 /Oi /Os /GF /FD /MD /Zp1 /GS- /Gy /fp:fast /W3 /WX /nologo /c /Gr /TP
//linker options:
// /NODEFAULTLIB /ENTRY:"entrypoint" /CRINKLER /HASHSIZE:100 /HASHTRIES:100 /RANGE:opengl32

#include "windows.h"
#include "math.h"
#include "gl/gl.h"

extern "C" int _fltused = 0;

#define FINAL 1

#define SCREENX 1280
#define SCREENY 1024
#define TEXRES 1024

#define TEX_PETAL 0
#define TEX_LEAF 1
#define TEX_LEAF2 2
#define TEX_SKY 3
#define TEX_CENTER 4
#define TEX_SCENE 5

#define NLEAVES 6
#define NLEAVES2 6
#define NFLOWERS 4

static float buf3_1[TEXRES][TEXRES][3];
static float buf3_2[TEXRES][TEXRES][3];
static float buf_screen_1[SCREENY][SCREENX][3];
static float buf_screen_2[SCREENY][SCREENX][3];
static unsigned int tex[8];

static PIXELFORMATDESCRIPTOR pfd =
    {0, 0, PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0};
static DEVMODE dmScrSet =
	{{0}, 0, 0, sizeof(dmScrSet), 0, DM_PELSWIDTH | DM_PELSHEIGHT,
	{0}, 0, 0, 0, 0, 0, {0}, 0, 32, SCREENX, SCREENY, {0}, 0, 0, 0, 0, 0, 0, 0, 0};

static float Light1Col[] = {0.8, 0.8, 1.0, 1.0};
static float Light1Pos[] = {8.0, 4.0, 8.0, 1.0};
static float Light2Col[] = {0.8, 0.8, 1.0, 1.0};
static float Light2Pos[] = {-8.0, 4.0, 8.0, 1.0};
static float Light3Col[] = {0.2, 0.1, 0.3, 1.0};
static float Light3Pos[] = {0.0, 1.0, -6.0, 1.0};
static float LightAmb[] = {1.0, 1.0, 1.0, 1.0};

static const float LeafPar[][4] =
	{{5.5f, 0.0f, 1.0f, 4.0f},
	{-6.25f, -2.f, 1.0f, 8.0f},
	{-7.0f, -11.75f, 1.0f, 7.0f},
	{-1.f, -7.5f, 0.75f, 6.0f},
	{3.f, -18.f, 1.0f, 14.0f},
	{7.f, -9.f, 1.0f, 10.0f}};
static const float Leaf2Par[][3] =
	{{-7.f, 0.5f, 14.0f},
	{-8.0f, -7.0f, 13.0f},
	{-2.25f, -11.0f, 12.0f},
	{8.0f, -6.0f, 4.0f},
	{5.f, -13.0f, 1.0f},
	{-2.0f, -15.f, 8.0f}};
static const float FlowerPar[][3] =
	{{-0.5f, -1.75f, 1.0f},
	{4.f, -6.5f, 0.85f},
	{-5.0f, -8.f, 0.7f},
	{1.f, -13.f, 0.95f}};

static int noise2di(int x, int y)
    {
    x += y * 101;
    return (x * (x + 107) * (x * x + x * 317 + 733)) & 65535;
    }
static float noise2d(int x, int y)
    {
    return (float)(noise2di(x, y)) / 65536.f;
    }
static float Perlin(float x, float y)
    {
    float _x = (float)((int)(x - 0.5f));
    float _y = (float)((int)(y - 0.5f));
    x -= _x;
    y -= _y;
    //x = x * x * x * (x * (x * 6.f - 15.f) + 10.f);
    //y = y * y * y * (y * (y * 6.f - 15.f) + 10.f);
    float a = noise2d((int)_x, (int)_y);
    float b = noise2d((int)_x + 1, (int)_y);
    float c = noise2d((int)_x, (int)_y + 1);
    float d = noise2d((int)_x + 1, (int)_y + 1);
    return a + (b - a) * x + (c - a) * y + (a - b - c + d) * x * y;
    }
static float PerlinS(float x, float y)
    {
    float sum = 0.0;
    int k;
    for (k = 4; k < 256; k *= 2)
        sum += Perlin(k * x, k * y) / (sqrt((float)k));
    return sum;
    }
static void blur(int begin, int w, int h, float * a)
    {
    int i, j, k;
    float sum;
    for (i = begin+1; i < h-1; ++i)
    for (j = 1; j < w-1; ++j)
	for (k = 0; k < 3; ++k)
        {
        sum = *(a + i * w * 3 + j * 3 + k);
        sum += *(a + i * w * 3 + (j + 1) * 3 + k);
        sum += *(a + (i + 1) * w * 3 + j * 3 + k);
        sum += *(a + (i - 1) * w * 3 + (j) * 3 + k);
		sum += *(a + (i) * w * 3 + (j - 1) * 3 + k);
        sum /= 5.f;
        *(a + i * w * 3 + j * 3 + k) = sum;
        }
    }

static void (* F)(float x, float y, float n, float * a);
//x [-1..1]
//y [0..2]
static void petal(float x, float y, float n, float * a)
    {
    float r = 3.0f;
    y = y - 1.0f;
    *(a) = x * (1.f - y * y) * 0.5f * r;
    *(a + 1) = (y + 1.0f) * 0.8f * r;
    *(a + 2) = (1 - x * x) * (1 - y * y) * 0.2f * r * n;
    *(a + 3) = x;
    *(a + 4) = y;
    *(a + 5) = 1.0;
    }
static void leaf(float x, float y, float n, float * a)
    {
    float r = 2.0f * sqrt(1.05f - x * x * x * x * x * x);
    x *= 3.1416f;
    *(a) = sin(x) * y * r;
    *(a + 1) = PerlinS(x, y) * 0.1f;
    *(a + 2) = sin(x + 1.5708f) * y * r;
    *(a + 3) = 0.0f;
    *(a + 4) = 1.0f;
    *(a + 5) = 0.0f;
    }
static void leaf2(float x, float y, float n, float * a)
    {
    *(a) = x * (4.f - y * y) * 0.15f;
    *(a + 1) = y * 4.0f;
    *(a + 2) = y * y * (0.25f + 0.25f * n) - x * x * 0.25f;
    *(a + 3) = 0.0f;
    *(a + 4) = 0.0f;
    *(a + 5) = y;
    }
static void center(float x, float y, float n, float * a)
    {
	y -= 1.f;
    *(a) = x * 0.6f;
    *(a + 1) = 1.5f + (2.f - x * x - y * y) * 0.4f + 0.3f * (sin(x * 16.f) * sin(y * 16.f));
    *(a + 2) = y * 0.6f;
    *(a + 3) = x;
    *(a + 4) = (2.f - x * x - y * y);
    *(a + 5) = y;
    }
static void sky(float x, float y, float n, float * a)
    {
    float r = 24.f;
	y -= 1.f;
    *(a) = x * r;
	*(a + 1) = 0.0f;
    *(a + 2) = -y * r;
    *(a + 3) = 0.0f;
    *(a + 4) = 0.0f;
    *(a + 5) = 1.0f;
    }
static void SetLight()
	{
	glLightfv(GL_LIGHT1, GL_DIFFUSE, Light1Col);
    glLightfv(GL_LIGHT1, GL_POSITION, Light1Pos);
    glLightfv(GL_LIGHT2, GL_DIFFUSE, Light2Col);
    glLightfv(GL_LIGHT2, GL_POSITION, Light2Pos);
    glLightfv(GL_LIGHT3, GL_DIFFUSE, Light3Col);
    glLightfv(GL_LIGHT3, GL_POSITION, Light3Pos);
	}
static void plot(float n)
    {
    float d = 0.026f;
    float i, j;
    for (i = -1.f; i < 1.f; i += d)
    for (j = 0.f; j < 2.f; j += d)
        {
        float P[8];
        float texx = 0.5;
        float texy = 0.5;
        float dtexy = 0;//- (float)n * 0.02;
        glBegin(GL_QUADS);
        //1
        glTexCoord2f(i * texx + 0.5f + n, j * texy + dtexy);
        F(i, j, n, P);
        glNormal3fv(P + 3);
        glVertex3fv(P);
        //2
        glTexCoord2f(i * texx + 0.5f + n, (j + d) * texy + dtexy);
        F(i, j + d, n, P);
        glNormal3fv(P + 3);
        glVertex3fv(P);
        //3
        glTexCoord2f((i + d) * texx + 0.5f + n, (j + d) * texy + dtexy);
        F(i + d, j + d, n, P);
        glNormal3fv(P + 3);
        glVertex3fv(P);
        //4
        glTexCoord2f((i + d) * texx + 0.5f + n, j * texy + dtexy);
        F(i + d, j, n, P);
        glNormal3fv(P + 3);
        glVertex3fv(P);
        glEnd();
        }
    }
static void paste()
    {
    glBegin(GL_QUADS);
    glTexCoord2i(0, 0);
    glVertex2i(-1, -1);
    glTexCoord2i(0, 1);
    glVertex2i(-1, 1);
    glTexCoord2i(1, 1);
    glVertex2i(1, 1);
    glTexCoord2i(1, 0);
    glVertex2i(1, -1);
    glEnd();
    }

void entrypoint()
    {
    ChangeDisplaySettings(&dmScrSet, CDS_FULLSCREEN);
    HDC hDC = GetDC(CreateWindow("edit", 0, WS_POPUP | WS_VISIBLE | WS_MAXIMIZE, 0, 0, 0, 0, 0, 0, 0, 0));
    SetPixelFormat(hDC, ChoosePixelFormat(hDC, &pfd), &pfd);
    wglMakeCurrent(hDC, wglCreateContext(hDC));
    ShowCursor(FALSE);

    int i, j;
    float fx, fy, fc;

	glGenTextures(8, tex);
	for (i = 0; i < 8; ++i)
		{
		glBindTexture(GL_TEXTURE_2D, tex[i]);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE);
		}

	//petal texture
    for (i = 0; i < TEXRES; ++i)
    for (j = 0; j < TEXRES; ++j)
        {
        fc = 0.125f * Perlin((float)j * 0.25f, 34.f);
        fc += 0.871f;
        buf3_1[i][j][0] = fc;
        buf3_1[i][j][1] = fc;
        buf3_1[i][j][2] = fc * (float)i / TEXRES;
        }
	glBindTexture(GL_TEXTURE_2D, tex[TEX_PETAL]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, TEXRES, TEXRES, 0, GL_RGB, GL_FLOAT, buf3_1);
    
	//leaf texture
    for (i = 0; i < TEXRES; ++i)
    for (j = 0; j < TEXRES; ++j)
        {
        fx = (float)j / (float)TEXRES;
        fy = (float)i / (float)TEXRES;
		float t = 0.0f;
		if (((j >> 2) & 15) == 0)
			t = 0.2f;
		float t2 = (float)((j & 63) - 32) / 32.0f;
		//t2 = 0.4f * (t2 * t2 * t2 * t2) + 0.6f;
		t2 = 0.5f * fy * (t2 * t2 * t2 * t2 - 1.0f) + 1.0f;
		buf3_1[i][j][0] = 0.08f * PerlinS(fx * 20.0f, 0.0f);
		buf3_1[i][j][1] = 0.15f * ( 0.5f + PerlinS(fx * 8.0f, fy)) * t2;
		buf3_1[i][j][2] = 0.0f;
		buf3_2[i][j][0] = 0.1f * PerlinS(fx * 20.0f, fy * 10.0f);
		buf3_2[i][j][1] = (0.025f * ( 0.5f + PerlinS(fx * 8.0f, fy)) + 0.15f * PerlinS(fx * 20.0f, fy * 20.0f)) * t2;
		buf3_2[i][j][2] = 0.05f;
        }
	for (i = 0; i < 10; ++i)
		blur(0, TEXRES, TEXRES, (float *)buf3_1);
    glBindTexture(GL_TEXTURE_2D, tex[TEX_LEAF]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, TEXRES, TEXRES, 0, GL_RGB, GL_FLOAT, buf3_1);
	for (i = 0; i < 10; ++i)
		blur(0, TEXRES, TEXRES, (float *)buf3_2);
    glBindTexture(GL_TEXTURE_2D, tex[TEX_LEAF2]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, TEXRES, TEXRES, 0, GL_RGB, GL_FLOAT, buf3_2);

	//sky and flower center texture
    for (i = 0; i < TEXRES; ++i)
    for (j = 0; j < TEXRES; ++j)
        {
        fx = (float)j / (float)TEXRES;
        fy = (float)i / (float)TEXRES;
        fc = PerlinS(fx * 4.f, fy * 8.f);
        buf3_1[i][j][0] = 0.16f * fc;
        buf3_1[i][j][1] = 0.2f * fc;
        buf3_1[i][j][2] = 0.35f * fc * fc;
		buf3_2[i][j][0] = 1.0f;
        buf3_2[i][j][1] = 1.0f;
        buf3_2[i][j][2] = 0.0f;
        }
	for (i = 0; i < 20; ++i)
		blur(0, TEXRES, TEXRES, (float *)buf3_1);
    glBindTexture(GL_TEXTURE_2D, tex[TEX_SKY]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, TEXRES, TEXRES, 0, GL_RGB, GL_FLOAT, buf3_1);
	glBindTexture(GL_TEXTURE_2D, tex[TEX_CENTER]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, TEXRES, TEXRES, 0, GL_RGB, GL_FLOAT, buf3_2);

    
	glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
	glClearStencil(0);
	glEnable(GL_DEPTH_TEST);
    glEnable(GL_TEXTURE_2D);
	glEnable(GL_LIGHTING);
    glViewport(0, 0, SCREENX, SCREENY);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glFrustum(-1.f, 1.f, -1.f, 1.f, 1.8f, 50.f);
    glMatrixMode(GL_MODELVIEW);
	glEnable(GL_STENCIL_TEST);
    glLoadIdentity();
	glScalef(0.75f, 1.0f, 1.0f);
    glTranslatef(0.0f, -4.0f, -16.0f);
    glRotatef(60.0f, 1.0f, 0.0f, 0.0f);
	glLightModelfv(GL_LIGHT_MODEL_AMBIENT, LightAmb);
    glEnable(GL_LIGHT1);
    glEnable(GL_LIGHT2);
    glEnable(GL_LIGHT3);
    glEnable(GL_NORMALIZE);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);

	glStencilFunc(GL_ALWAYS, 1, 0);
	glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
	//leaves
	glBindTexture(GL_TEXTURE_2D, tex[TEX_LEAF]);
	F = leaf;
	for (i = 0; i < NLEAVES; ++i)
		{
		glPushMatrix();
		glTranslatef(LeafPar[i][0], 0.0f, LeafPar[i][1]);
		glRotatef(20.0f * LeafPar[i][3], 0.f, 1.f, 0.f);
		glScalef(LeafPar[i][2], LeafPar[i][2], LeafPar[i][2]);
		SetLight();
		plot((float)i * 0.1f);
		glPopMatrix();
		}

	//long leaves
	glBindTexture(GL_TEXTURE_2D, tex[TEX_LEAF2]);
	F = leaf2;
	for (i = 0; i < NLEAVES2; ++i)
		{
		glPushMatrix();
		glTranslatef(Leaf2Par[i][0], 0.0f, Leaf2Par[i][1]);
		glRotatef(20.0f * Leaf2Par[i][2], 0.f, 1.f, 0.f);
		SetLight();
		plot((float)i);
		glPopMatrix();
		}

	//flowers
	for (i = 0; i < NFLOWERS; ++i)
		{
		glPushMatrix();
		glTranslatef(FlowerPar[i][0], 0.0f, FlowerPar[i][1]);
		SetLight();
		glRotatef(1000.0f * FlowerPar[i][2], 0.0f, 1.0f, 0.0f);
		for (j = 0; j < 30; ++j)
			{
			glPushMatrix();
			glRotatef(137.f * (float)j, 0.0, 1.0, 0.0);
			glRotatef((10.0f + 2.0f * (float)j) * FlowerPar[i][2] * FlowerPar[i][2] * FlowerPar[i][2], 1.0, 0.0, 0.0);
			float scale = (0.6f + (float)j * 0.01f);
			glScalef(scale * FlowerPar[i][2], scale, scale * FlowerPar[i][2]);
			F = petal;
			glBindTexture(GL_TEXTURE_2D, tex[TEX_PETAL]);
			plot(1.5f - (float)j * 0.05f * FlowerPar[i][2] * FlowerPar[i][2]);
			glPopMatrix();
			}
		F = center;
		glBindTexture(GL_TEXTURE_2D, tex[TEX_CENTER]);
		plot(0);
		glPopMatrix();
		}
	glReadPixels(0, 0, SCREENX, SCREENY, GL_RGB, GL_FLOAT, buf_screen_1);
	glClear(GL_COLOR_BUFFER_BIT);
	//mirrored flowers
	glStencilFunc(GL_ALWAYS, 3, 0);
	glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);
	for (i = 0; i < NFLOWERS; ++i)
		{
		glPushMatrix();
		glTranslatef(FlowerPar[i][0], 0.0f, FlowerPar[i][1]);
		if (i == 0)
			glTranslatef(0.0f, 0.0f, 0.5f);
		glScalef(1.f, -0.25f, 1.f);
		SetLight();
		glRotatef(1000.0f * FlowerPar[i][2], 0.0f, 1.0f, 0.0f);
		for (j = 0; j < 30; ++j)
			{
			glPushMatrix();
			glRotatef(137.f * (float)j, 0.0, 1.0, 0.0);
			glRotatef((10.0f + 2.0f * (float)j) * FlowerPar[i][2] * FlowerPar[i][2] * FlowerPar[i][2], 1.0, 0.0, 0.0);
			float scale = (0.6f + (float)j * 0.01f);
			glScalef(scale * FlowerPar[i][2], scale, scale * FlowerPar[i][2]);
			F = petal;
			glBindTexture(GL_TEXTURE_2D, tex[TEX_PETAL]);
			plot(1.5f - (float)j * 0.05f * FlowerPar[i][2] * FlowerPar[i][2]);
			glPopMatrix();
			}
		glPopMatrix();
		}
	//mirrored long leaves
	glBindTexture(GL_TEXTURE_2D, tex[TEX_LEAF2]);
	F = leaf2;
	for (i = 0; i < NLEAVES2; ++i)
		{
		glPushMatrix();
		glTranslatef(Leaf2Par[i][0], 0.0f, Leaf2Par[i][1]);
		glRotatef(20.0f * Leaf2Par[i][2], 0.f, 1.f, 0.f);
		glScalef(1.f, -0.75f, 1.f);
		glPushMatrix();
		glTranslatef(0.0f, 15.0f, 0.0f);
		SetLight();
		glPopMatrix();
		plot(0.0f);
		glPopMatrix();
		}
	//sky
	glStencilFunc(GL_NOTEQUAL, 3, 3);
	glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);
	glBindTexture(GL_TEXTURE_2D, tex[TEX_SKY]);
	glPushMatrix();
	glTranslatef(0.0f, 0.0f, -10.0f);
	SetLight();
	glPopMatrix();
	F = sky;
	plot(0);

	glReadPixels(0, 0, SCREENX, SCREENY, GL_RGB, GL_FLOAT, buf_screen_2);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	glDisable(GL_LIGHTING);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
	
#ifdef FINAL
	for (i = 0; i < 20; ++i)
		blur(400 + i * 64, SCREENX, SCREENY, (float *)buf_screen_1);
#endif
	glBindTexture(GL_TEXTURE_2D, tex[TEX_SCENE]);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, SCREENX, SCREENY, 0, GL_RGB, GL_FLOAT, buf_screen_1);
	glStencilFunc(GL_EQUAL, 1, 3);
	paste();
	
	int ii, jj;
	for (i = 10; i < SCREENY; ++i)
	for (j = 10; j < SCREENX; ++j)
		{
		ii = (int)((float)(SCREENY - i) * 0.0065f * (1.0f + sin((float)(j + i) / 12.f)));
		jj = (int)((float)(SCREENY - i) * 0.0065f * (1.0f + sin((float)(j - i) / 12.f)));
		buf_screen_1[i][j][0] = buf_screen_2[i+ii][j-jj][0];
		buf_screen_1[i][j][1] = buf_screen_2[i+ii][j-jj][1];
		buf_screen_1[i][j][2] = buf_screen_2[i+ii][j-jj][2];
		}
#ifdef FINAL
	for (i = 0; i < 16; ++i)
		blur(i * 64, SCREENX, SCREENY, (float *)buf_screen_1);
#endif
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, SCREENX, SCREENY, 0, GL_RGB, GL_FLOAT, buf_screen_1);
	glStencilFunc(GL_NOTEQUAL, 1, 3);
	glTranslatef(0.0f, 0.0f, 0.1f);
	paste();

	glReadPixels(0, 0, SCREENX, SCREENY, GL_RGB, GL_FLOAT, buf_screen_1);
#ifdef FINAL
	//graining
	for (i = 0; i < SCREENY; ++i)
	for (j = 0; j < SCREENX; ++j)
        {
		fx = (float)j / 200.f;
        fy = (float)i / 160.f;
        fc = (float)((int)(PerlinS(fx, fy) * 256.0f) & 7) / 16.0f + 0.5f;
        buf_screen_2[i][j][0] = fc;
        buf_screen_2[i][j][1] = fc;
        buf_screen_2[i][j][2] = fc;
        }
	for (i = 0; i < 2; ++i)
		blur(0, SCREENX, SCREENY, (float *)buf_screen_2);
	for (i = 0; i < SCREENY; ++i)
	for (j = 0; j < SCREENX; ++j)
        {
		fx = (float)j / (float)(SCREENX / 2) - 1.0f;
        fy = (float)i / (float)(SCREENY / 2) - 1.0f;
		fc = sqrt(1.0f - fx * fx * fx * fx - fy * fy * fy * fy);
        buf_screen_1[i][j][0] *= buf_screen_2[i][j][0] * fc;
        buf_screen_1[i][j][1] *= buf_screen_2[i][j][1] * fc;
        buf_screen_1[i][j][2] *= buf_screen_2[i][j][2] * fc;
        }
#endif
	
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, SCREENX, SCREENY, 0, GL_RGB, GL_FLOAT, buf_screen_1);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT | GL_STENCIL_BUFFER_BIT);
	paste();
	
	SwapBuffers(hDC);
	do
		{
		PeekMessageA(0, 0, 0, 0, PM_REMOVE);
        }
	while (!GetAsyncKeyState(VK_ESCAPE));
    ExitProcess(0);
    }
