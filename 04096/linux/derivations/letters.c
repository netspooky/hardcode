/*
 * Eternity
 * by zipola
 * Curiously fascinating font engine. 
 */

#include <SDL/SDL.h>
#include <SDL/SDL_opengl.h>

/*
1    left line
2    top line
4    bottom line
8    middle line
16   slash
32   C
64   V
128  vertical line
256  right bottom line
512  inverted left line
1024 inverted slash
2048 inverted C
4096 inverted V
8192 high / for P
*/

// they go like a, b, c.....x, y, z
// there is no q
int alphabet[] = { 523, 39, 32, 2049, 15, 11, 263, 521, 128, 516, 33, 5, 577, 1537, 519, 8195, 666, 35, 1030, 130, 517, 64, 4609, 1040, 8193, 22 };

void draw_leftline()
{
	glVertex2f(-0.25, -0.5);
	glVertex2f(-0.25, 0.5);
}

void draw_topline()
{
	glVertex2f(-0.25, 0.5);
	glVertex2f(0.25, 0.5);
}

void draw_bottomline()
{
	glVertex2f(-0.25, -0.5);
	glVertex2f(0.25, -0.5);
}

void draw_middleline()
{
	glVertex2f(-0.25, 0.0);
	glVertex2f(0.25, 0.0);
}

void draw_slash()
{
	glVertex2f(-0.25, -0.5);
	glVertex2f(0.25, 0.5);
}

void draw_C()
{
	glVertex2f(0.25, -0.5);
	glVertex2f(-0.25, 0.0);
	glVertex2f(-0.25, 0.0);
	glVertex2f(0.25, 0.5);
}

void draw_V()
{
	glVertex2f(-0.25, 0.5);
	glVertex2f(0.0, -0.5);
	glVertex2f(0.0, -0.5);
	glVertex2f(0.25, 0.5);
}

void draw_verticalline()
{
	glVertex2f(0.0, 0.5);
	glVertex2f(0.0, -0.5);
}

void draw_rightbottomline()
{
	glVertex2f(0.25, 0.0);
	glVertex2f(0.25, -0.5);
}

// some might call this also right line...
void draw_invertedleftline()
{
	glVertex2f(0.25, -0.5);
	glVertex2f(0.25, 0.5);
}

void draw_invertedslash()
{
	glVertex2f(-0.25, 0.5);
	glVertex2f(0.25, -0.5);
}

void draw_invertedC()
{
	glVertex2f(-0.25, 0.5);
	glVertex2f(0.25, 0.0);
	glVertex2f(0.25, 0.0);
	glVertex2f(-0.25, -0.5);
}

void draw_invertedV()
{
	glVertex2f(-0.25, -0.5);
	glVertex2f(0.0, 0.5);
	glVertex2f(0.0, 0.5);
	glVertex2f(0.25, -0.5);
}

void draw_highslash()
{
	glVertex2f(-0.25, 0.0);
	glVertex2f(0.25, 0.5);
}

void draw_letter(int c)
{
	c = c - 97;

	glBegin(GL_LINES);

	// TODO: some algorithm here
	if (alphabet[c] & 1) draw_leftline();
	if (alphabet[c] & 2) draw_topline();
	if (alphabet[c] & 4) draw_bottomline();
	if (alphabet[c] & 8) draw_middleline();
	if (alphabet[c] & 16) draw_slash();
	if (alphabet[c] & 32) draw_C();
	if (alphabet[c] & 64) draw_V();
	if (alphabet[c] & 128) draw_verticalline();
	if (alphabet[c] & 256) draw_rightbottomline();
	if (alphabet[c] & 512) draw_invertedleftline();
	if (alphabet[c] & 1024) draw_invertedslash();
	if (alphabet[c] & 2048) draw_invertedC();
	if (alphabet[c] & 4096) draw_invertedV();
	if (alphabet[c] & 8192) draw_highslash();
	
	glEnd();
}

void draw_text(char* text, int len, float x, float y, float space, float scale)
{
	int i = 0;
	for (i = 0; i < len; i++) {
		float place = (float)(i);
		glLoadIdentity();
		glTranslatef(x + place*space, y, 0.0);
		glScalef(scale, scale, scale); 
		draw_letter(text[i]);
    	}
}

