#include "stuff.hpp"
#include "tausta.hpp"


void taustahori(float raja, float alpha)
{
	if (alpha > 0)
	{
		glDepthMask(0);
		perspective2D(1,1);
		glLoadIdentity();

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glBegin(GL_QUADS);
		//yläpuoli
		glColor4f(0, 0, 0, alpha);
		glVertex2f(0, 0);
		glVertex2f(1, 0);
		glColor4f(0, 0, 0, 0);
		glVertex2f(1, raja);
		glVertex2f(0, raja);

		//alapuolo
		glColor4f(0, 0, 0, alpha);
		glVertex2f(0, 1);
		glVertex2f(1, 1);
		glColor4f(0, 0, 0, 0);
		glVertex2f(1, 1-raja);
		glVertex2f(0, 1-raja);

		glEnd();
		perspective3D();
		glLoadIdentity();
		glDepthMask(1);
	}
}

void taustasky(float raja, float alpha)
{
	if (alpha > 0)
	{
		glDepthMask(0);
		perspective2D(1,1);
		glLoadIdentity();

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glBegin(GL_QUADS);
		//yläpuoli
		glColor4f(0, 0, 0, alpha);
		glVertex2f(0, 0);
		glVertex2f(1, 0);
		glColor4f(0, 0, 0, 0);
		glVertex2f(1, raja);
		glVertex2f(0, raja);

		glEnd();
		perspective3D();
		glLoadIdentity();
		glDepthMask(1);
	}
}

void taustaground(float raja, float alpha)
{
	if (alpha > 0)
	{
		glDepthMask(0);
		perspective2D(1,1);
		glLoadIdentity();

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		glBegin(GL_QUADS);
		glColor4f(0, 0, 0, alpha);
		glVertex2f(0, 1);
		glVertex2f(1, 1);
		glColor4f(0, 0, 0, 0);
		glVertex2f(1, 1-raja);
		glVertex2f(0, 1-raja);

		glEnd();
		perspective3D();
		glLoadIdentity();
		glDepthMask(1);
	}

} 
