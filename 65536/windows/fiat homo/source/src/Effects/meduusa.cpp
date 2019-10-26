#include "../stuff.hpp"
#include "meduusa.hpp"

const int reunastrips = 70; //96
const int palasia = 30; //40
Vector **meduusaverteksit;

const int lonkeroita = 11;
const int lonkeropaloja = 30;
Vector **lonkerot;

const float kelluvaradius = 5
;
const int kelluvia = 500;
Vector *kelluvat;
Vector *kelluvat2;

const int tikkucount = 200;
Vector *tikut;
Vector *tikkurotations;

Sync *meduusasync1;
Sync *meduusasync2;
Sync *meduusasync3;
Sync *meduusasync4;
Sync *meduusasync5;
Sync *meduusasync6;
Sync *meduusasync7;
Sync *meduusasync8;
Sync *meduusasync9;

void meduusa(float aika)
{
	float alpha = calcSaturate(aika, 0, 1, 5);
	glLoadIdentity();
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	const float zoomout = (float)pow(sin(calcPosFloat(aika, 0.86f, 1.0f)*3.141592f*0.5f),15);
	const float zoomalpha = 1-zoomout*zoomout;
	glTranslatef(0, 0, -6.0f-zoomout*1000);
	glRotatef(180, 0, 0, 1);

	Vector m1pos = Vector(-aika*1.0f, -aika*1.6f, -aika*2.4f);
	Vector m2pos = Vector(-aika*0.5f-1, -aika*0.9f+1.5f, -aika*1.2f+1);
	Vector m3pos = Vector(-aika*0.1f+2, -aika*0.6f+0.7f, -aika*1.0f+2);

	const float maxsync = 0.8f;

	float syncmodifier1 = 1-maxsync*(float)(sin(meduusasync1->getVal(originalaika)*3.141592f) + 
								  sin(meduusasync4->getVal(originalaika)*3.141592f) + 
								  sin(meduusasync7->getVal(originalaika)*3.141592f)); 

	float syncmodifier2 = 1-maxsync*(float)(sin(meduusasync2->getVal(originalaika)*3.141592f) + 
								  sin(meduusasync5->getVal(originalaika)*3.141592f) + 
								  sin(meduusasync8->getVal(originalaika)*3.141592f)); 

	float syncmodifier3 = 1-maxsync*(float)(sin(meduusasync3->getVal(originalaika)*3.141592f) + 
								  sin(meduusasync6->getVal(originalaika)*3.141592f) + 
								  sin(meduusasync9->getVal(originalaika)*3.141592f)); 

	glPushMatrix();
	glTranslatef(m1pos.x, m1pos.y, m1pos.z);
	glRotatef(aika*40, 0.89f, 0.5f, -1);

	//täytyy olla nolla luvuilla 0 ja 1, eli sin(i*3.141592f)
	//ykkönen luvulla 0.5f

	drawmeduusa(Vector(0, 0, 0), Vector(0.5f, 0.2f, 0.6f), aika, alpha*zoomalpha*syncmodifier1);
	glPopMatrix();

	glPushMatrix();
	glTranslatef(m2pos.x, m2pos.y, m2pos.z);
	glRotatef(aika*40, 0.59f, 0.25f, -0.7f);
	drawmeduusa(Vector(0, 0, 0), Vector(0.6f, 0.3f, 0.4f), aika*0.6f-0.1f, alpha*zoomalpha*syncmodifier2);
	glPopMatrix();

	glPushMatrix();
	glTranslatef(m3pos.x, m3pos.y, m3pos.z);
	glRotatef(10+aika*40, 0.19f, 0.25f, -0.7f);
	drawmeduusa(Vector(0, 0, 0), Vector(0.8f, 0.3f, 0.8f), aika*0.8f-0.4f, alpha*zoomalpha*syncmodifier3);
	glPopMatrix();

	glEnable(GL_DEPTH_TEST);
	glDepthMask(1);

	int i;
	glEnable(GL_BLEND);
	glEnable(GL_POINT_SMOOTH);
	glHint(GL_POINT_SMOOTH_HINT, GL_NICEST);

	const float kellualpha = 1-calcPosFloat(aika, 0.8f, 0.94f);
	glPushMatrix();
	glRotatef(aika*30, 1, 1, 1);

	glTranslatef(0, aika, 0);
	glPointSize(3.0f);	
	glBegin(GL_POINTS);
	for (i=0;i<kelluvia;i++)
	{
		glColor4f(0, 0, 0, alpha*0.3f*kellualpha);
		glVertex3fv((float *)&kelluvat[i]);
	}
	glEnd();
	glPopMatrix();
	glPushMatrix();
	glRotatef(-aika*20, 0.4f, -0.7f, 0.6f);
	glTranslatef(0, aika*0.8f, 0);
	glPointSize(2.0f);	
	glBegin(GL_POINTS);
	for (i=0;i<kelluvia;i++)
	{
		glColor4f(0, 0, 0, alpha*0.3f*kellualpha);
		glVertex3fv((float *)&kelluvat2[i]);
	}
	glEnd();
	glPopMatrix();
	glPushMatrix();
	glRotatef(-aika*20, 0.4f, -0.7f, 0.6f);
	glTranslatef(0, aika*0.8f, 0);
	glLineWidth(1.0f);
	glBegin(GL_LINES);
	for (i=0;i<tikkucount;i++)
	{
		const float tikkulength = 0.025f;
		glColor4f(0, 0, 0, alpha*0.45f*kellualpha);
		Matrix rotate;
		Vector rotvec = tikkurotations[i]*(0.1f+aika);
		rotate.makeRotation(rotvec.x, rotvec.y, rotvec.z);
		Vector v1 = tikut[i] + Vector(0, tikkulength, 0)*rotate;
		Vector v2 = tikut[i] - Vector(0, tikkulength, 0)*rotate;
		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&v2);
	}
	glEnd();
	glPopMatrix();
}

void drawmeduusa(Vector pos, Vector color, float aika, float alpha)
{
	int i;
	int j;
	const float height = 1.0f;
	const Vector keskipiste(0, -height*0.5f, 0);

	//meduusa pyörähtää y-akselin ympäri

	for (i=0;i<reunastrips;i++)
	{
		//y kasvaa, x muovautuu, z = 0
		const float kohta = (i / (float)reunastrips);
		const float mul = 0.8f+(float)(0.2*sin(kohta*3.141592f*1.2f)+0.01*cos(kohta*3.141592f*3+aika*65));

		//puoliympyrä
		const float ypos = kohta*height;
		const float xpos = (float)pow(kohta*(float)(0.8f+0.1f*sin(aika*37)),0.4f+0.1f*(float)sin(aika*17))*(1.0f+0.2f*(float)cos(aika*24));
		const float zpos = 0;

		meduusaverteksit[0][i] = Vector(xpos*mul, ypos, zpos) + keskipiste;
	}

	Matrix rot;
	for (i=0;i<palasia;i++)
	{
		//pyöräytetään y-akselin ympäri
		const float pos = i / (float)palasia;
		const float step = 1.0f / (float)palasia;
		rot.makeRotation(0, pos*2*3.141592f, 0);
		for (j=0;j<reunastrips;j++)
		{
			meduusaverteksit[i][j] = meduusaverteksit[0][j]*rot;
		}
	}


	for (i=0;i<lonkeroita;i++)
	{
		//lähtöpiste
		const float pos = i / (float)lonkeroita;
		const float step = 1.0f / (float)lonkeroita;

		Vector lonkerostart = Vector(0.1f + 0.05f*(float)sin(pos*57), 0, 0);
		rot.makeRotation(0, pos*2*3.141592f, 0);

		Vector lpos = lonkerostart;
		const float pituus = 0.7f;
		const float leveys = 0.5f;
		for (j=0;j<lonkeropaloja;j++)
		{
			const float kohta = j / (float)lonkeropaloja;
			lonkerot[i][j] = lpos*rot;
			const float lonkerospeed = 1.3f;
			Vector ladd = Vector((float)(sin(kohta*12+aika*15*lonkerospeed)+0.7f*cos(kohta*8+aika*4*lonkerospeed)), 
								 0, 
								 (float)(cos(kohta*15.3f+aika*17*lonkerospeed)+0.5f*sin(kohta*3.5f+aika*5.2*lonkerospeed)))*0.06f*(0.7f+2*kohta);

			lpos += Vector(0, step*2, 0)*pituus;
			lpos += ladd*leveys;
		}
	}


	//meduusa itse.. 
	glDepthMask(1);
	glDisable(GL_DEPTH_TEST);

	for (i=0;i<palasia;i++)
	{
		for (j=0;j<reunastrips;j++)
		{
			const float ikohta = i / (float)palasia;
			const float jkohta = j / (float)reunastrips;
			const float morph = 0.95f + 0.13f*(float)(sin(aika*17) + 
													 sin(jkohta*2*3.141592f*2+aika*57)*0.2f + 
													 sin(ikohta*2*3.141592f*4+aika*48)*0.25f);
			meduusaverteksit[i%palasia][j%reunastrips] *= morph;
		}
	}

	const int kuoria = 10;
	for (int k=0;k<kuoria;k++)
	{
		const float kkohta = k / (float)(kuoria-1);
		const float koko = kkohta;
		const float vari = 0.7f + 0.3f*(float)sin(aika*36);
		glColor4f(color.x, color.y, color.z,alpha*vari*0.3f*(1-kkohta*0.5f));
		glPushMatrix();
		glScalef(kkohta, kkohta, kkohta);

		glBegin(GL_QUADS);
		for (i=0;i<palasia;i++)
		{
			for (j=0;j<reunastrips-1;j++)
			{
				glVertex3fv((float *)&(meduusaverteksit[(i)%palasia][(j)%reunastrips]));
				glVertex3fv((float *)&(meduusaverteksit[(i+1)%palasia][(j)%reunastrips]));
				glVertex3fv((float *)&(meduusaverteksit[(i+1)%palasia][(j+1)%reunastrips]));
				glVertex3fv((float *)&(meduusaverteksit[(i)%palasia][(j+1)%reunastrips]));
			}
		}
		glEnd();
		glPopMatrix();
	}
	glDepthMask(0);
	glEnable(GL_DEPTH_TEST);
	glColor4f(0,0,0,alpha*0.4f);

	//kehikko
	glPushMatrix();
	const float scaleval = 1.03f;
	glScalef(scaleval, scaleval, scaleval);
	for (i=0;i<palasia;i++)
	{
		glBegin(GL_LINES);
		for (j=0;j<reunastrips-1;j++)
		{
			//alas
			glVertex3fv((float *)&meduusaverteksit[(i)%palasia][(j)%reunastrips]);
			glVertex3fv((float *)&meduusaverteksit[(i)%palasia][(j+1)%reunastrips]);
			//sivulle
			if (!((j+2)%7))
			{
				glVertex3fv((float *)&meduusaverteksit[(i)%palasia][(j)%reunastrips]);
				glVertex3fv((float *)&meduusaverteksit[(i+1)%palasia][(j)%reunastrips]);
			}
		}
		glEnd();
	}
	glPopMatrix();

	//lonkerot
	for (i=0;i<lonkeroita;i++)
	{
		glBegin(GL_LINE_STRIP);
		for (j=0;j<lonkeropaloja;j++)
		{
			const float kohta = j / (float)lonkeropaloja;
			glColor4f(0, 0,0, alpha*0.4f*((float)sin(kohta*3.141592f)));
			glVertex3fv((float *)&lonkerot[i][j]);
		}
		glEnd();
	}
	glDepthMask(1);
}

void meduusa_init()
{
	int i;
	meduusaverteksit = new Vector*[palasia];
	lonkerot = new Vector*[lonkeroita];
	kelluvat = new Vector[kelluvia];
	kelluvat2 = new Vector[kelluvia];
	tikut = new Vector[tikkucount];
	tikkurotations = new Vector[tikkucount];

	//m1 = keskellä
	//m2 = vasen
	//m3 = oikea

	meduusasync3 = new Sync(167800, 168300);
	meduusasync1 = new Sync(168050, 168350);
	meduusasync2 = new Sync(168300, 168600);

	meduusasync5 = new Sync(176500, 176800);
	meduusasync6 = new Sync(176750, 177050);
	meduusasync4 = new Sync(177000, 177300);

	meduusasync9 = new Sync(185300, 185600);
	meduusasync8 = new Sync(185550, 185850);
	meduusasync7 = new Sync(185800, 186100);

	for (i=0;i<palasia;i++)
	{
		meduusaverteksit[i] = new Vector[reunastrips];
	}
	for (i=0;i<lonkeroita;i++)
	{
		lonkerot[i] = new Vector[lonkeropaloja];
	}

	for (i=0;i<kelluvia;i++)
	{
		const float radius = (1-randFloat()*randFloat())*kelluvaradius;
		const float a1 = randFloat()*3.141592f;
		const float a2 = randFloat()*3.141592f*2;

		const float radius2 = (1-randFloat()*randFloat())*kelluvaradius;
		const float a3 = randFloat()*3.141592f;
		const float a4 = randFloat()*3.141592f*2;

		kelluvat[i] = sphereCoord(radius, a1, a2);
		kelluvat2[i] = sphereCoord(radius2, a3, a4);
	}

	for (i=0;i<tikkucount;i++)
	{
		const float radius = (1-randFloat()*randFloat())*kelluvaradius;
		const float a1 = randFloat()*3.141592f;
		const float a2 = randFloat()*3.141592f*2;

		const float tikkulength = 0.04f+0.02f*randFloat();
		Vector rot = Vector(randFloat(), randFloat(), randFloat())*2*3.141592f;
		Vector pos = sphereCoord(radius, a1, a2);
		tikut[i] = pos;
		tikkurotations[i] = rot;
	}
}

void meduusa_free()
{
	int i;
	for (i=0;i<palasia;i++)
		delete [] meduusaverteksit[i];
	delete [] meduusaverteksit;
	for (i=0;i<lonkeroita;i++)
		delete [] lonkerot[i];
	delete [] lonkerot;
	delete [] kelluvat;
	delete [] kelluvat2;

	delete [] tikut;
	delete [] tikkurotations;
	
	delete meduusasync1;
	delete meduusasync2;
	delete meduusasync3;
	delete meduusasync4;
	delete meduusasync5;
	delete meduusasync6;
	delete meduusasync7;
	delete meduusasync8;
	delete meduusasync9;

}
