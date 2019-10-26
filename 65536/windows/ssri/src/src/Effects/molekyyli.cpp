#include "molekyyli.hpp"
#include "../molekyylidata.hpp"

Aine *fluvoksamiini;
Aine *fluoksetiini;
Aine *sitalopraami;
Aine *serotoniini;

void Aine::init(int count, Vector *vert)
{
	int i;
	vertices = new Vector[count];
	vertexcount = count;

	for (i=0;i<count;i++)
	{
		vertices[i] = vert[i];
	}
}

void Aine::draw(Vector color, float kohta, float alpha)
{
	int i;

	const float maxalpha1 = 0.6f;
	const float maxalpha2 = 1.0f;

//	glDisable(GL_DEPTH_TEST);
	glDepthMask(0);
	glEnable(GL_DEPTH_TEST);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glLineWidth(6);
	glColor4f(color.x, color.y, color.z, alpha*maxalpha1);

	if (kohta > 1.0f)
		kohta = 1.0f;

	int asti = (int)(kohta*vertexcount);
	if (asti > vertexcount)
		asti = vertexcount;

	const float frac = kohta*vertexcount - (asti-1);
	glBegin(GL_LINES);
	for (i=0;i<asti;i++)
	{
		if (i==asti-1)
		{
			glColor4f(color.x, color.y, color.z, alpha*maxalpha1*frac);
		}
		else
		{
			glColor4f(color.x, color.y, color.z, alpha*maxalpha1);
		}
		glVertex3fv((float *)&vertices[i]);
	}
	glEnd();
//	glDisable(GL_DEPTH_TEST);
	glEnable(GL_DEPTH_TEST);
	glDepthMask(1);
	glLineWidth(1);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glColor4f(1,1,1,alpha*1.8f*maxalpha2);
	glBegin(GL_LINES);
	for (i=0;i<asti;i++)
	{
		glVertex3fv((float *)&vertices[i]);
	}
	glEnd();
}

void nitrogen(Vector pos, float alpha)
{
	Vector color = Vector(0.1f, 0.1f, 0.8f);
	glColor4f(color.x, color.y, color.z, alpha);
	square(pos, alpha);
}
void oxygen(Vector pos, float alpha)
{
	Vector color = Vector(0.8f, 0.1f, 0.1f);
	glColor4f(color.x, color.y, color.z, alpha);
	square(pos, alpha);
}
void fluorine(Vector pos, float alpha)
{
	Vector color = Vector(0.5f, 0.3f, 0.65f);
	glColor4f(color.x, color.y, color.z, alpha);
	square(pos, alpha);
}
void hydrogen(Vector pos, float alpha)
{
	Vector color = Vector(0.2f, 0.6f, 0.2f);
	glColor4f(color.x, color.y, color.z, alpha);
	square(pos, alpha);
}
void carbon(Vector pos, float alpha)
{
	Vector color = Vector(0.2f, 0.2f, 0.2f);
	glColor4f(color.x, color.y, color.z, alpha);
	square(pos, alpha);
}

void square(Vector pos, float alpha)
{
	const float size = 0.15f;
	Vector v1 = pos + Vector(-size, -size, 0);
	Vector v2 = pos + Vector(size, -size, 0);
	Vector v3 = pos + Vector(size, size, 0);
	Vector v4 = pos + Vector(-size, size, 0);

	glDepthMask(0);
	glLineWidth(4);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();

	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glLineWidth(1);
	glDepthMask(1);
	glEnable(GL_DEPTH_TEST);
	glColor4f(1,1,1,alpha*0.6f);
	glBegin(GL_LINE_LOOP);
	glVertex3fv((float *)&v1);
	glVertex3fv((float *)&v2);
	glVertex3fv((float *)&v3);
	glVertex3fv((float *)&v4);
	glEnd();
}


void fluvoxamine(float alpha, float kohta)
{
	fluvoksamiini->draw(sininen, kohta*1.1f, alpha);

	const float ainealpha = alpha*kohta;
	nitrogen(Vector(3, -3.5f, 0), ainealpha);
	nitrogen(Vector(1, -0.5f, 0), ainealpha);
	oxygen(Vector(1, -1.5f, 0), ainealpha);
	oxygen(Vector(-3, -3.5f, 0), ainealpha);

	fluorine(Vector(0, 5.0f, 0), ainealpha);
	fluorine(Vector(-1, 4.0f, 0), ainealpha);
	fluorine(Vector(1, 4.0f, 0), ainealpha);

	hydrogen(Vector(3.3f, -3.2f, 0), ainealpha);
	hydrogen(Vector(3.0f, -3.89f, 0), ainealpha);
}

void serotonin(float alpha, float kohta)
{
	serotoniini->draw(punainen, kohta*1.1f, alpha);
	const float ainealpha = alpha*kohta;

	oxygen(Vector(0, 4.0f, 0), ainealpha); //happi
	nitrogen(Vector(-4.9f, 1.5f, 0), ainealpha); //typpi
	nitrogen(Vector(-0.5f, -0.3f, 0), ainealpha); //typpi


}

void fluoxetine(float alpha, float kohta)
{
	fluoksetiini->draw(oranssi, kohta*1.1f, alpha);
	const float ainealpha = alpha*kohta;
	oxygen(Vector(-1, 0.5f, 0), ainealpha);
	nitrogen(Vector( 3, 0.5f, 0), ainealpha);
	fluorine(Vector(-1, 5.5f, 0), ainealpha);
	fluorine(Vector(-2, 4.5f, 0), ainealpha);
	fluorine(Vector(-0, 4.5f, 0), ainealpha);

	hydrogen(Vector(3.3f, 0.2f, 0), ainealpha);
}

void citalopram(float alpha, float kohta)
{
	sitalopraami->draw(violetti, kohta*1.1f, alpha);
	const float ainealpha = alpha*kohta;
	carbon(Vector(0, -4, 0), ainealpha);
	nitrogen(Vector(0, -5, 0), ainealpha);
	oxygen(Vector(-1, 0.2f, 0), ainealpha);
	fluorine(Vector(0, 4, 0), ainealpha);
	nitrogen(Vector(4, 0.0f, 0), ainealpha);
}


void molekyyli_init()
{
	fluvoksamiini = new Aine();
	fluoksetiini = new Aine();
	sitalopraami = new Aine();
	serotoniini = new Aine();
	fluvoksamiini->init(fluvoksamiininverteksit, fluvoksamiinindata);
	fluoksetiini->init(fluoksetiininverteksit, fluoksetiinindata);
	sitalopraami->init(sitalopraaminverteksit, sitalopraamindata);
	serotoniini->init(serotoniininverteksit, serotoniinindata);
}

void molekyyli_free()
{
	delete fluvoksamiini;
	delete fluoksetiini;
	delete sitalopraami;
	delete serotoniini;
}
