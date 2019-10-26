#include "maailma.hpp"
#include "../linestrip.hpp"

LineStrip *strips;
int stripcount;
int maailmagridx, maailmagridy;
Vector *maailmagrid;
Sync *maailmasync;

void maailma(float aika)
{
	int i;
	int j;
	int x, y;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

//	Vector campos = Vector(10, 7, -30.0f+aika*50);
//	Vector camtarget = Vector(0, 0, 0);

	Vector kohta = Vector(0, 0, -7+aika*15);
	Vector campos = Vector((float)sin(aika*5)*2, 5+aika*5, 0)+kohta;
	Vector camtarget = kohta + Vector(0, 0, (1-aika)*7);

	float fadealpha = (float)pow(aika, 20);
	campos.y += (float)(fadealpha*3);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 0, 1);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	glLineWidth(1.0f);
	glColor4f(0.8f, 0.5f, 0.2f, alpha*0.3f);

	glBegin(GL_LINES);
	for (y=0;y<maailmagridy;y++)
	{
		for (x=0;x<maailmagridx;x++)
		{
			glVertex3fv((float *)&maailmagrid[x+y*maailmagridx]);
			glVertex3fv((float *)&maailmagrid[((x+1)%maailmagridx)+y*maailmagridx]);
			glVertex3fv((float *)&maailmagrid[x+y*maailmagridx]);
			glVertex3fv((float *)&maailmagrid[x+((y+1)%maailmagridy)*maailmagridx]);
		}
	}
	glEnd();

	glLineWidth(3.0f);
	glColor4f(0.8f, 0.5f, 0.2f, alpha*0.7f*(1-fadealpha));
	for (i=0;i<stripcount;i++)
	{
		if (fabs(strips[i].vertices[0].z-kohta.z) < 25)
		{
			glBegin(GL_LINE_STRIP);
			for (j=0;j<strips[i].count;j++)
			{
				glVertex3fv((float *)&strips[i].vertices[j]);
			}
			glEnd();
		}
	}

	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, flare->ID);

	Vector xr, yr, zr;
	antiRotate(&xr, &yr, &zr);
/*
	static bool osuma = false;
	static float aaltoalpha = 0.0f;
	if (sound.getOrder() == 0xC && sound.getOrder() == 0x6)
	{
		osuma = true;
	}

	static float prevaika;
	float dt = aika - prevaika;
	prevaika = aika;

	if (osuma)
	{
		if (aaltoalpha < 1.0f)
			aaltoalpha += dt*2.5f;
	}
*/
 
    float addi = maailmasync->getValue();

	glBegin(GL_QUADS);
	for (i=0;i<stripcount;i++)
	{
		float d = (float)fabs(strips[i].vertices[0].z-kohta.z);
		if (d < 25)
		{
			float a = 0.8f+0.4f*(float)sin(d);
            Vector color1 = Vector(0.9f, 0.4f, 0.3f);
            Vector color2 = Vector(0.3f, 0.4f, 0.9f);
            Vector c = lerpVector(color1, color2, addi);
			glColor4f(c.x, c.y, c.z, a*alpha*(1-fadealpha));
			const float size = 0.2f*a;

			for (j=0;j<strips[i].count2;j++)
			{
				Vector p = strips[i].vertices2[j];

				Vector v1 = p - xr*size - yr*size;
				Vector v2 = p + xr*size - yr*size;
				Vector v3 = p + xr*size + yr*size;
				Vector v4 = p - xr*size + yr*size;

				glTexCoord2f(0, 0);
				glVertex3fv((float *)&v1);
				glTexCoord2f(1, 0);
				glVertex3fv((float *)&v2);
				glTexCoord2f(1, 1);
				glVertex3fv((float *)&v3);
				glTexCoord2f(0, 1);
				glVertex3fv((float *)&v4);

			}
		}
	}
	glEnd();

	
}

void maailma_init()
{
	int i;
	int x, y;
	stripcount = 1000;
	strips = new LineStrip[stripcount];

	Matrix scale;
	scale.makeScale(10, 1, 70);

	maailmagridx = 40;
	maailmagridy = 40;

	maailmagrid = new Vector[maailmagridx*maailmagridy];

	srand(1010469);

	for (y=0;y<maailmagridy;y++)
	{
		for (x=0;x<maailmagridx;x++)
		{
			maailmagrid[x+y*maailmagridx] = Vector((x-maailmagridx/2.0f)/maailmagridx, 
												   0, 
												   (y-maailmagridy/2.0f)/maailmagridy)*30;

		}
	}

	for (i=0;i<stripcount;i++)
	{
		strips[i].count = 6+rand()%8;
		strips[i].vertices = new Vector[strips[i].count];

/*		const int xoff = (rand()%maailmagridx);//-maailmagridx/2;
		const int yoff = (rand()%maailmagridy);//-maailmagridy/2;

		Vector p = Vector((xoff-maailmagridx/2.0f)/maailmagridx, 
						  0,
						  (yoff-maailmagridy/2.0f)/maailmagridy)*scale;
*/
		const float radius = randFloat();
		const float angle = randFloat()*2*3.141592f;

		Vector p = Vector((float)sin(angle), 0, (float)cos(angle))*radius;
		p *= scale;

		strips[i].count2 = 0;
		strips[i].vertices2 = new Vector[strips[i].count]; //vähän turhaa, ei haitanne

		const float step = 0.2f;
		for (int j=0;j<strips[i].count;j++)
		{
			lsystem:
			float dx = 0;
			float dy = 0;
			float dz = 0;

			switch(rand()%8)
			{
				case 0: dx += step; break;
				case 1: dx -= step; break;
				case 2: dy += step; break;
				case 3: dy -= step; break;
				case 4: dz += step; break;
				case 5: dz -= step; break;

				case 6: dy += step; break;
				case 7: dy += step; break;

			}
			Vector np = p + Vector(dx, dy*1.2f, dz);
			if (np.y < 0.0f)
				goto lsystem;

			p = np;
			strips[i].vertices[j] = p;
			
			if (!(rand()%3))
			{
				strips[i].vertices2[strips[i].count2++] = p;
			}
		}
	}

    maailmasync = new Sync(1);
    maailmasync->add(0x7, 0x0, 3000);
}

void maailma_free()
{
	int i;
	for (i=0;i<stripcount;i++)
	{
		delete [] strips[i].vertices;
	}
	delete [] strips;
	delete [] maailmagrid;
    delete maailmasync;
} 
