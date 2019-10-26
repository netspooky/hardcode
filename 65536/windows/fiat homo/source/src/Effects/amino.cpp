#include "../stuff.hpp"
#include "amino.hpp"

int aminocount1 = 100;
int aminovertices1 = 80;

Vector **aminodata1;
Vector *aminopositions1;
Vector *aminorotations1;
Sync *aminosync;

void amino(float aika)
{
	int i, j;
	float alpha = calcSaturate(aika, 0.0f, 1.0f, 3);
	float koko = calcSaturate(aika, 0.0f, 1.0f, 1);//(float)sin(aika*3.141592f);

	Matrix kokomul;
	kokomul.makeIdentity();
	//jos ei hyvällä niin sitten pahalla. . 
	kokomul.data[0][0] = koko;
	kokomul.data[1][1] = koko;
	kokomul.data[2][2] = koko;

	glLoadIdentity();
	glTranslatef(0, 0, -5.0f);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);
	glLineWidth(1);

	const float aminovalue = aminosync->getVal(originalaika);
	const float aminowavespeed = 3;
	const float aminoalpha = (0.8f+0.3f*(1-aminovalue)*(float)sin(aminovalue*2*3.141592f*aminowavespeed));
	
	for (i=0;i<aminocount1;i++)
	{
		glPushMatrix();

		glTranslatef(aminopositions1[i].x, aminopositions1[i].y, aminopositions1[i].z);
		glRotatef(aika*150, aminorotations1[i].x, aminorotations1[i].y, aminorotations1[i].z);

		int asti = (int)((aika+i/250.0f)*150);
		if (asti > aminovertices1)
			asti = aminovertices1;
		glColor4f(0,0,0,alpha*alpha*0.8f*aminoalpha);// * (0.8f+0.3f*(float)cos(aika*45)));
		glBegin(GL_LINE_STRIP);
		for (j=0;j<asti;j++)
		{
			glVertex3fv((float *)&(aminodata1[i][j]*kokomul));
		}	
		glEnd();
		glColor4f(0.7f, 0.3f, 0.3f, alpha*alpha*0.4f);
		glPointSize(2);
		glBegin(GL_POINTS);
		for (j=0;j<asti;j++)
		{
			glVertex3fv((float *)&(aminodata1[i][j]*kokomul));
		}
		glEnd();

		glPopMatrix();
	}
}

void amino_init()
{
	int i, j;
	aminodata1 = new Vector*[aminocount1];
	aminopositions1 = new Vector[aminocount1];
	aminorotations1 = new Vector[aminocount1];

//	const int efekti5ajat[] = {82000, 106000}; //amino
	aminosync = new Sync(83000, 84500);

	for (i=0;i<aminocount1;i++)
	{
		aminodata1[i] = new Vector[aminovertices1];
		aminopositions1[i] = sphereCoord(1.5f+1.5f*randFloat(), randFloat()*3.141592f, randFloat()*2*3.141592f);
		aminorotations1[i] = Vector(randFloat()-0.5f, randFloat()-0.5f, randFloat()-0.5f);

		Vector pos = Vector(0,0,0);

		for (j=0;j<aminovertices1;j++)
		{
			int suunta = RAND_INT(0, 6);
			const float step = 0.05f;
			switch(suunta)
			{
				case 0: pos.x += step; break;
				case 1: pos.x -= step; break;
				case 3: pos.y += step; break;
				case 4: pos.y -= step; break;
				case 5: pos.z += step; break;
				case 6: pos.z -= step; break;
			}
			aminodata1[i][j] = pos;
		}
	}
}
void amino_free()
{
	int i;

	delete aminosync;

	for (i=0;i<aminocount1;i++)
	{
		delete [] aminodata1[i];
	}
	delete [] aminodata1;
	delete [] aminopositions1;
	delete [] aminorotations1;
}
