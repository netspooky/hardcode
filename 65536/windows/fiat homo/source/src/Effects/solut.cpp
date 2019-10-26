#include "../stuff.hpp"
#include "solut.hpp"

extern int aminocount1; 
extern Vector *aminopositions1; //solut ilmaantuvat aminohappojen paikkoihin

const int solucount = aminocount1;
//solukalvo
float *soluradii;
float *soluradii2;

//tuman osaset
Vector *tumapos;
float *aspects;

//pienet jutut
const int juttucount = 3;
Vector **solujutut;

const int solustrips = 64;
float *soluoutline;

void solut(float aika)
{
	int i, j; 
	float alpha = calcSaturate(aika, 0.0f, 1.0f, 9);
	float liike = (float)cos(calcPosFloat(aika, 0.0f, 1.0f)*0.5f*3.141592f);

	liike = 0.7f+0.3f*liike;
	glLoadIdentity();
	glTranslatef(0, 0, -5.0f);

	glColor4f(0,0,0,alpha*alpha*0.8f);// * (0.8f+0.3f*(float)cos(aika*45)));
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glDepthMask(1);
	glLineWidth(1);
	glDisable(GL_TEXTURE_2D);

	for (i=0;i<solucount;i++)
	{
		float kulma = 0.0f;
		const float ikohta = i / (float)(solucount-1);
		const float rotation = aika*(float)sin(ikohta*17)*7;

		for (j=0;j<solustrips;j++)
		{
			//lasketaan outline.. .
			const float kohta = j / (float)(solustrips-1);
//			const float ikohta = i / (float)(solucount-1);

			//sisustan täytyy olla 2*pi jaollinen...
			const float anglevalue = 2*kohta + 6*ikohta;
//			const float rotation = aika*(float)sin(ikohta*17)*7;
			soluoutline[j] = 1.0f + 0.3f*(float)sin(anglevalue*2*3.141592f + rotation);
		}

		glPushMatrix();
		glTranslatef(liike*aminopositions1[i].x, liike*aminopositions1[i].y, liike*aminopositions1[i].z);
		glColor4f(1,1,1,alpha);
		glBegin(GL_TRIANGLE_FAN);
		for (j=0;j<solustrips;j++)
		{
			Vector p = Vector((float)sin(kulma), (float)cos(kulma), 0)*soluradii[i]*soluoutline[j];
			glVertex3fv((float *)&p);
			kulma += 2*3.141592f/(solustrips-1);
		}
		glEnd();

		glColor4f(0,0,0,alpha*alpha*0.8f);// * (0.8f+0.3f*(float)cos(aika*45)));

		glBegin(GL_LINE_STRIP);
		for (j=0;j<solustrips;j++)
		{
			Vector p = Vector((float)sin(kulma), (float)cos(kulma), 0)*soluradii[i]*soluoutline[j];
			glVertex3fv((float *)&p);
			kulma += 2*3.141592f/(solustrips-1);
		}
		glEnd();
		glBegin(GL_LINE_STRIP);
		for (j=0;j<solustrips;j++)
		{
			Vector p = Vector((float)sin(kulma), (float)cos(kulma), 0)*soluradii2[i]*soluoutline[j];
			glVertex3fv((float *)&p);
			kulma += 2*3.141592f/(solustrips-1);
		}
		glEnd();

		//tuma
		glPushMatrix();
		glRotatef(rotation*40, 0, 0, 1);
		glColor4f(0.2f,0.7f, 0.2f,alpha*alpha*0.1f);// * (0.8f+0.3f*(float)cos(aika*45)));
		glBegin(GL_TRIANGLE_FAN);
		for (j=0;j<32;j++)
		{
			const float k = (j/32.0f)*2*3.141592f;
			const float radius = 0.02f;
			Vector p = tumapos[i] + Vector((float)sin(k)*aspects[i], (float)cos(k), 0)*radius;
			glVertex3fv((float *)&p);
		}
		glEnd();
		glColor4f(0.15f,0.3f, 0.1f,alpha*alpha*0.7f);// * (0.8f+0.3f*(float)cos(aika*45)));
		glBegin(GL_LINE_LOOP);
		for (j=0;j<32;j++)
		{
			const float k = (j/32.0f)*2*3.141592f;
			const float radius = 0.02f;
			Vector p = tumapos[i] + Vector((float)sin(k)*aspects[i], (float)cos(k), 0)*radius;
			glVertex3fv((float *)&p);
		}
		glEnd();

		for (j=0;j<juttucount;j++)
		{
			const int jut = 7;
			glBegin(GL_LINE_LOOP);
			for (int k=0;k<jut;k++)
			{
				const float r = 0.005f;
				const float kohta = k / 7.0f;
				glVertex3fv((float *)&(solujutut[i][j] + Vector((float)sin(kohta*2*3.141592f), (float)cos(kohta*2*3.141592f), 0)*r));
			}
			glEnd();
		}
		glPopMatrix();


		glPopMatrix();

	}
}

void solut_init()
{
	int i;
	int j;
	soluradii = new float[solucount];
	soluradii2 = new float[solucount];
	soluoutline = new float [solustrips];
	tumapos = new Vector[solucount];
	aspects = new float[solucount];

	solujutut = new Vector*[solucount];

	const float radius = 0.07f;
	for (i=0;i<solucount;i++)
	{
		const float outer = 0.09f;
		const float inner = 0.07f;

		soluradii[i] = outer;
		soluradii2[i] = inner;

		tumapos[i] = Vector(randFloat()-0.5f, randFloat()-0.5f, 0)*radius;
		const float maxaspect = 0.8f;
		const float minaspect = 0.4f;
		aspects[i] = minaspect + randFloat()*(maxaspect-minaspect);

		solujutut[i] = new Vector[juttucount];
		for (j=0;j<juttucount;j++)
		{
			const float a = randFloat()*2*3.141592f;
			const float r = randFloat()*radius*0.8f;
			solujutut[i][j] = Vector((float)sin(a), (float)cos(a), 0)*r;
		}
	}
}

void solut_free()
{
	int i;
	delete [] soluradii;
	delete [] soluradii2;
	delete [] soluoutline;
	delete [] tumapos;
	delete [] aspects;

	for (i=0;i<solucount;i++)
	{
		delete [] solujutut[i];
	}
	delete [] solujutut;
}
