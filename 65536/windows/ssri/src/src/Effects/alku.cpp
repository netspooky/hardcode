#include "alku.hpp"
#include "molekyyli.hpp"
#include "kellu.hpp"

const int alkulinecount = 40;
Vector *alkulines;
Vector *alkulines2;

int alkupalacount = 500;
Palanen *alkupalaset;




void alku(float aika)
{
	int i;
	float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	const float xpos = 1.5f-aika*1;
	Vector campos = Vector(xpos, 0, -2.0f);
	Vector camtarget = Vector(xpos, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glEnable(GL_BLEND);

	for (i=0;i<alkulinecount;i++)
	{
		const float height = 0.4f;
		const int strips = 15;
		Vector v1 = alkulines[i];
		Vector v2 = v1 + Vector(0, -height, 0);
		Vector v3 = alkulines2[i];
		Vector v4 = v3 + Vector(-height, 0, 0);

		const float ikohta = i / (float)alkulinecount;
		float asti =  calcPosFloat(aika, 0.05f, 0.10f);
		if (asti > 1)
			asti = 1;

		///////////////////////////VAAAAAAAAAAARA////////////////////////////////

		alpha *= asti;

		//////////////////////////LOPPUU///////////////////////////

/*		glLineWidth(3.0f);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha);
		glBegin(GL_LINES);
		for (t=0;t<asti;t+=1.0f/strips)
		{
 			glVertex3fv((float *)&lerpVector(v1, v2, t)); 
		}
		glEnd();

		glLineWidth(1.0f);
		glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*1.0f);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glDisable(GL_DEPTH_TEST);
		glBegin(GL_LINES);
		for (t=0;t<asti;t+=1.0f/strips)
		{
			glVertex3fv((float *)&lerpVector(v1, v2, t)); 
		}
		glEnd();

		glLineWidth(3.0f);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha);
		glBegin(GL_LINES);
		for (t=0;t<asti;t+=1.0f/strips)
		{
 			glVertex3fv((float *)&lerpVector(v3, v4, t)); 
		}
		glEnd();

		glLineWidth(1.0f);
		glColor4f(oranssi.x, oranssi.y, oranssi.z, alpha*1.0f);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE);
		glDisable(GL_DEPTH_TEST);
		glBegin(GL_LINES);
		for (t=0;t<asti;t+=1.0f/strips)
		{
			glVertex3fv((float *)&lerpVector(v3, v4, t)); 
		}
		glEnd();

*/
	}
	glEnd();
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	const float tractionalpha = alpha*(float)sin(calcPosFloat(aika, 0.1f, 0.2f)*3.141592f);
	const float ssrialpha = alpha*(float)sin(calcPosFloat(aika, 0.3f, 0.5f)*3.141592f);
	const float preacheralpha = alpha*(float)sin(calcPosFloat(aika, 0.5f, 0.7f)*3.141592f);
	const float gripalpha = alpha*(float)sin(calcPosFloat(aika, 0.7f, 0.9f)*3.141592f);

	glPushMatrix();
	glTranslatef(1.25f, 0, 0);
	glScalef(0.05f, 0.05f, 0.05f);
 	serotonin(alpha, tractionalpha); 
	glPopMatrix();


	if (tractionalpha > 0)
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_DEPTH_TEST);
		glColor4f(tractionalpha,tractionalpha,tractionalpha, tractionalpha);
		font_write(1.0f, 0, "traction");
	}

	glPushMatrix();
	glTranslatef(1.25f, 0.25f, 0);
	glScalef(0.05f, 0.05f, 0.05f);
 	citalopram(alpha, ssrialpha); 
	glPopMatrix();

	if (ssrialpha > 0)
	{
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_DEPTH_TEST);
		glColor4f(1,1,1,ssrialpha);
		font_write(1.15f, 0.2f, "SSRI");
	}

	glPushMatrix();
	glTranslatef(1.4f, -0.3f, 0);
	glScalef(0.05f, 0.05f, 0.05f);
	fluoxetine(alpha, preacheralpha);
	glPopMatrix();

	if (preacheralpha > 0)
	{
		glColor4f(1,1,1,preacheralpha);
		glDisable(GL_DEPTH_TEST);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		font_write(1.6f, -0.3f, "fluoxetine: preacher");
	}

	glPushMatrix();
	glTranslatef(1.2f, 0.3f, 0);
	glScalef(0.05f, 0.05f, 0.05f);
	fluvoxamine(alpha, gripalpha);
	glPopMatrix();

	if (gripalpha > 0)
	{
		glColor4f(1,1,1,gripalpha);
		glDisable(GL_DEPTH_TEST);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		font_write(1.5f, 0.25f, "fluvoxamine: grip");
	}


	glDisable(GL_DEPTH_TEST);
	const float palaalpha = calcSaturate(aika, 0, 1, 1)*0.9f;

	if (palaalpha > 0)
	{

		for (i=0;i<alkupalacount;i++)
		{
			float temp = alkupalaset[i].phase + alkupalaset[i].speed*aika;
			float tilpet = temp - (int)temp;

			const float tilpealpha = palaalpha*calcSaturate(tilpet, 0, 1, 3)*alpha*calcPosFloat(tilpet, 0, 1);

			Vector pos = lerpVector(alkupalaset[i].pos, alkupalaset[i].pos2, tilpet);
			Vector rot = lerpVector(alkupalaset[i].startrot, alkupalaset[i].endrot, tilpet);

			if (i%23)
				lightquad2(pos, rot, 0.03f, 0.03f, alkupalaset[i].color, tilpealpha*0.5f, tilpealpha*0.8f, tilpealpha);
			else
			{
				glPushMatrix();
				glTranslatef(pos.x, pos.y, pos.z);
				const float s = 0.03f;
				glScalef(s, s, s);
				const float r = 1.0f;
				glRotatef(90*r*rot.x, 1, 0, 0);
				glRotatef(90*r*rot.y, 0, 1, 0);
				glRotatef(90*r*rot.z, 0, 0, 1);
				serotonin(alpha*tilpealpha, 1*(1-calcPosFloat(aika, 0.6f, 0.8f)));
				glPopMatrix();
			}
			/*
			glPushMatrix();
			const float scale = 0.52f;
			glTranslatef(pos.x, pos.y, pos.z);
			glScalef(scale, scale, scale);
			glRotatef(360*aika, rot.x, rot.y, rot.z);

			glColor4f(violetti.x, violetti.y, violetti.z,alpha);
	//		font_write3d("");

	//		serotonin(tilpealpha*0.6f, 1);
			glPopMatrix();
	*/
		}
	}

	
}

void alku_init()
{
	int i;

	alkulines = new Vector[alkulinecount];
	alkulines2 = new Vector[alkulinecount];
	alkupalaset = new Palanen[alkupalacount];
	Matrix scale;

	scale.makeScale(2, 1, 1);

	setSeed(111519);
	for (i=0;i<alkulinecount;i++)
	{
		alkulines[i] = Vector(randFloat()-0.5f, randFloat()-0.5f, (randFloat()-0.5f)*0.1f)*scale;
		alkulines2[i] = Vector(randFloat()-0.5f, randFloat()-0.5f, (randFloat()-0.5f)*0.1f)*scale;
	}

	for (i=0;i<alkupalacount;i++)
	{
		Vector kohta = Vector(0, randFloat()-0.5f, randFloat()-0.5f);
		alkupalaset[i].pos2 = kohta + Vector(-1, 0, 0);
		alkupalaset[i].pos = kohta + Vector(2, 0, 0);
		alkupalaset[i].startrot = Vector(randFloat(), randFloat(), randFloat())*2*3.141592f;
		alkupalaset[i].endrot = Vector(randFloat(), randFloat(), randFloat())*2*3.141592f;
		alkupalaset[i].speed = 1;
		alkupalaset[i].phase = randFloat();

		switch(i%3)
		{
			case 0: alkupalaset[i].color = punainen; break;
			case 1: alkupalaset[i].color = sininen; break;
			case 2: alkupalaset[i].color = oranssi; break;
		}
	}
}

void alku_free()
{
	delete [] alkulines;
	delete [] alkulines2;
	delete [] alkupalaset;
}
