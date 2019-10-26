#include "evoluutio.hpp"
#include "dna.hpp"

const int evogridx = 40;
const int evogridy = 40;
Vector *evogrid;
float *evogridalpha;

const int tuulicount = 20000;
Tuuliparticle *tuuli;

const int marjacount = 2000;
const int marjacluster = 6;
Vector *marjapos;
Vector *marjacol;
float *marjaalpha;

void evoluutio(float aika)
{
	int i;
	int x, y;
	const float alpha = calcSaturate(aika, 0,1, 10);
	glLoadIdentity();

	Vector campos = Vector(-0.6f-aika*2.0f, 0.4f+aika*0.3f, -5.0f+aika*4);
//	Vector campos = Vector((float)sin(aika*18)*5, 0.7f+0.5f*(float)sin(aika*23), (float)cos(aika*18)*5);

	Vector loppurotate = Vector((float)sin(aika*3), (float)sin(aika*2)*0.1f, (float)cos(aika*3))*50*(float)pow(aika, 245);
	Vector camtarget = Vector(0.4f, 0.2f+aika*0.5f, 0) - loppurotate;

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0-aika*0.2f);

	const float ruohoalpha = calcPosFloat(aika, 0.5f, 0.75f);
	const float monoliittialpha = calcPosFloat(aika, 0.38f, 0.40f);
	const float tuulialpha = 1-calcPosFloat(aika, 0.0f, 0.8f);
	const float marja_alpha = calcPosFloat(aika, 0.7f, 0.9f);

	//lattia
	glDisable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);
	glLineWidth(1.5f);

	glBegin(GL_LINE_STRIP);
	for (y=0;y<evogridy;y++)
	{
		for (x=0;x<evogridx;x++)
		{
			Vector earthcolor = Vector(0.2f, 0.1f, 0.05f);
			Vector p1 = evogrid[x+y*evogridx];
			Vector p2 = evogrid[((x+1)%evogridx)+y*evogridx];
			Vector p3 = evogrid[x+((y+1)%evogridy)*evogridx];
			float a1 = evogridalpha[x+y*evogridx]*alpha;
			float a2 = evogridalpha[((x+1)%evogridx)+y*evogridx]*alpha;
			float a3 = evogridalpha[x+((y+1)%evogridy)*evogridx]*alpha;

			glColor4f(earthcolor.x,earthcolor.y,earthcolor.z,a1);
			glVertex3fv((float *)&p1);
			glColor4f(earthcolor.x,earthcolor.y,earthcolor.z,a2);
			glVertex3fv((float *)&p2);
			glColor4f(earthcolor.x,earthcolor.y,earthcolor.z,a1);
			glVertex3fv((float *)&p1);
			glColor4f(earthcolor.x,earthcolor.y,earthcolor.z,a3);
			glVertex3fv((float *)&p3);
		}
	}
	glEnd();
	if (ruohoalpha > 0.0f)
	{
		glBegin(GL_QUADS);
		for (y=0;y<evogridy;y++)
		{
			for (x=0;x<evogridx;x++)
			{
				Vector ruohocolor = Vector(0.1f, 0.3f, 0.07f);
				const float ruohoheight = 0.005f;
				Vector p1 = evogrid[x+y*evogridx] - Vector(0, ruohoheight, 0);
				Vector p2 = evogrid[((x+1)%evogridx)+y*evogridx] - Vector(0, ruohoheight, 0);
				Vector p3 = evogrid[x+((y+1)%evogridy)*evogridx] - Vector(0, ruohoheight, 0);
				Vector p4 = evogrid[((x+1)%evogridx)+((y+1)%evogridy)*evogridx] - Vector(0, ruohoheight, 0);
				float a1 = evogridalpha[x+y*evogridx]*alpha*ruohoalpha;
				float a2 = evogridalpha[((x+1)%evogridx)+y*evogridx]*alpha*ruohoalpha;
				float a3 = evogridalpha[x+((y+1)%evogridy)*evogridx]*alpha*ruohoalpha;
				float a4 = evogridalpha[((x+1)%evogridx)+((y+1)%evogridy)*evogridx]*alpha*ruohoalpha;

				glColor4f(ruohocolor.x,ruohocolor.y,ruohocolor.z,a1);
				glVertex3fv((float *)&p1);
				glColor4f(ruohocolor.x,ruohocolor.y,ruohocolor.z,a2);
				glVertex3fv((float *)&p2);
				glColor4f(ruohocolor.x,ruohocolor.y,ruohocolor.z,a4);
				glVertex3fv((float *)&p4);
				glColor4f(ruohocolor.x,ruohocolor.y,ruohocolor.z,a3);
				glVertex3fv((float *)&p3);
			}
		}
		glEnd();
	}

	if (monoliittialpha > 0)
	{
		//monoliitit
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDepthMask(1);
		glEnable(GL_DEPTH_TEST);

		monoliitti(Vector(0, -0.007f, 0), alpha*monoliittialpha, 1);
	}

	//tuuli

	if (tuulialpha > 0)
	{
		glLineWidth(1.0f);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glDisable(GL_DEPTH_TEST);
		glBegin(GL_LINES);
		for (i=0;i<tuulicount;i++)
		{
			const float loopkohta = i / (float)tuulicount;
			const float tuulispeed = 16;
			const float maxtuulialpha = 0.8f;
			float kohta = aika*tuulispeed - (int)(aika*tuulispeed) + loopkohta;
			if (kohta > 1)
				kohta -= 1;

			const float kohtaalpha = (float)sin(kohta*3.141592f)*alpha*tuulialpha;

			Vector pos = lerpVector(tuuli[i].startpos, tuuli[i].endpos, kohta);
			Vector pos2 = pos + tuulifunktio(pos, aika*6)*0.01f;
			glColor4f(tuuli[i].color.x, tuuli[i].color.y, tuuli[i].color.z, kohtaalpha*tuuli[i].alpha*maxtuulialpha);
			glVertex3fv((float *)&pos);
			glVertex3fv((float *)&pos2);//(pos+Vector(0, 0, 0.04f)));
		}
		glEnd();
	}
	if (marja_alpha > 0)
	{
		glLineWidth(1.0f);
		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
		glEnable(GL_DEPTH_TEST);
		glPointSize(3);
		glBegin(GL_POINTS);

		const int asti = (int)(marja_alpha * marjacount*marjacluster);

		for (i=0;i<asti;i++)
		{
			const float loopkohta = i / (float)(marjacount*marjacluster);
			const float maxmarjaalpha = 0.6f;

			glColor4f(marjacol[i].x, marjacol[i].y, marjacol[i].z,marja_alpha*marjaalpha[i]*maxmarjaalpha*alpha);
			glVertex3fv((float *)&marjapos[i]);
		}
		glEnd();
	}
}

Vector tuulifunktio(Vector pos, float aika)
{
	const float scale = 1.0f;
	const float density = 0.7f;
	const float speed = 4.2f;
	const float x = pos.x * scale;
	const float y = pos.y * scale;
	const float z = pos.z * scale;

	return Vector((float)(sin((x*8)*density+aika*speed*6)+cos((x*5+y*7)*density+aika*speed*5)), 
				  (float)(sin((y*4+z*5.5f)*density+aika*speed*4)+cos((y*5+x*7+z*y*0.4f)*density+aika*speed*3)),
				  (float)(sin((z*11+y*12)*density+aika*speed*5)+cos((y*7+x*6)*density+aika*speed*3)));

}

void evoluutio_init()
{
	int i, j;
	int x, y;
	evogrid = new Vector[evogridx*evogridy];
	evogridalpha = new float[evogridx*evogridy];
	marjapos = new Vector[marjacount*marjacluster];
	marjacol = new Vector[marjacount*marjacluster];
	marjaalpha = new float[marjacount*marjacluster];

	tuuli = new Tuuliparticle[tuulicount];

	setSeed(115);
	const float scale = 0.3f;

	for (y=0;y<evogridy;y++)
	{
		for (x=0;x<evogridx;x++)
		{
			Vector pos = Vector(x-evogridx*0.5f, randFloat()*0.1f, y-evogridy*0.5f);
			evogrid[x+y*evogridx] = pos*scale;

			const float maxlength = Vector(evogridx*0.5f, 0, 0).length();
			const float length = pos.length();
			if (length > maxlength)
				evogridalpha[x+y*evogridx] = 0;
			else
				evogridalpha[x+y*evogridx] = (float)pow(1-(length/maxlength), 2)*(0.5f+0.7f*randFloat());
		}
	}

	for (i=0;i<tuulicount;i++)
	{
		float xrange;
		float yrange;
		float z;

		const int proportion = 999999999;
		if (i%proportion)
		{
			xrange = 7.0f;
			yrange = 3.5f;
			z = 3.0f;
		}
		else
		{
			xrange = 0.4f;
			yrange = 0.5f;
		}

		float xpos = (randFloat() - 0.5f) * xrange;
		float ypos = (randFloat() - 0.5f) * yrange;
		if (ypos < 0)
			ypos = -ypos;

		float alpha;
		const float maxdist = Vector(xrange*0.5f, 0, 0).length();
		float dist = Vector(xpos, ypos, 0).length();
		if (dist > maxdist)
			alpha = 0;
		else
			alpha = (float)pow(1-(dist/maxdist), 2);

		tuuli[i].alpha = (float)pow(alpha, 0.3f) * (0.7f+0.5f*randFloat());
		if (i%proportion)
		{
			tuuli[i].startpos = Vector(xpos, ypos, z);
			tuuli[i].endpos = Vector(xpos, ypos, -z);
			tuuli[i].color = Vector(0.2f, 0.2f, 0.2f);
		}
		else
		{
			const float height = 0.4f;
			tuuli[i].startpos = Vector(xpos, ypos+height, -3);
			tuuli[i].endpos = Vector(xpos, ypos+height, 0);
			tuuli[i].color = Vector(0.2f, 0.2f, 0.2f);
		}
	}

	int offset = 0;
	for (i=0;i<marjacount;i++)
	{
		const float marjakohta = i / (float)marjacount;
		const float maxradius = evogridx*0.5f*scale;
		const float minradius = 0.0f;

		const float clustermaxradius = 0.03f;

		const float radius = minradius + marjakohta * (maxradius-minradius);//(float)pow(randFloat()*(maxradius-minradius), 2);
		const float kulma = randFloat()*2*3.141592f;

		const float a = 1-(radius/maxradius);
		Vector kohta = Vector((float)sin(kulma), 0, (float)cos(kulma))*radius;

		for (j=0;j<marjacluster;j++)
		{
			const float k2 = (j/(float)marjacluster)*2*3.141592f;//randFloat()*2*3.141592f;
			marjapos[offset] = kohta + Vector((float)sin(k2), 0, (float)cos(k2))*randFloat()*clustermaxradius;
			const float vaihtelu = 0.1f;
			switch(RAND_INT(0, 2))
			{
				case 0: marjacol[offset] = Vector(0.9f+randFloat()*vaihtelu, 0.15f+randFloat()*vaihtelu, 0.07f+randFloat()*vaihtelu); break;
				case 1: marjacol[offset] = Vector(0.9f+randFloat()*vaihtelu, 0.8f+randFloat()*vaihtelu, 0.15f+randFloat()*vaihtelu); break;
				case 2: marjacol[offset] = Vector(0.9f+randFloat()*vaihtelu, 0.9f+randFloat()*vaihtelu, 0.9f+randFloat()*vaihtelu); break;
			}
			marjaalpha[offset++] = a;
		}
	}
}


void evoluutio_free()
{
	delete [] evogrid;
	delete [] evogridalpha;
	delete [] marjapos;
	delete [] marjacol;
	delete [] marjaalpha;
	delete [] tuuli;
}
