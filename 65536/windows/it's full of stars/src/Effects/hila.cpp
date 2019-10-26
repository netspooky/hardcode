#include "hila.hpp"

void hila(float aika)
{
	int i;
	int x, y, z;

	//0xd, 0x53

	static bool hit = false;
	static float previousframe = 0.0f;
	float dt = aika - previousframe;
	previousframe = aika;

	static float valoarvo = 0.0f;

//	if (aika > 0.4f)
	if (sound.getOrder() == 0xD && sound.getRow()==0x51)
	{
		hit = true;
	}
	if (hit)
	{
		if (valoarvo < 1.0f)
			valoarvo += dt*4;
	}
//	valoarvo = 1;

	float alpha = calcSaturate(aika, 0, 1, 2);

	if (aika > 0.5f)
		alpha = 1;
	glLoadIdentity();

	float kohta = aika*5 + (float)pow(aika, 20)*25;
	Vector campos = Vector(0.1f, 0.17f, -5+kohta);
	Vector camtarget = Vector(0, 0, kohta);


	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(21-aika*16, 0, 0, 0.2f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	float fogcol[] = {0,0,0,1};
	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 8);
	glFogf(GL_FOG_END, 12);
	glEnable(GL_FOG);

	const int xres = 20;
	const int yres = 10;
	const int zres = 20;

	Matrix scale;
	const float s = 1.0f;
	scale.makeScale(s, s*0.1f, s);

	int flarecount = 0;
	Vector *flares = new Vector[xres*yres*zres];

	glLineWidth(3);
	glBegin(GL_LINES);
	glColor4f(0.4f,0.5f,0.9f,alpha*0.26f*(1-0.5f*calcPosFloat(aika, 0.55f, 0.75f)));
	for (z=0;z<zres;z++)
	{
		if (campos.z > (z+1-zres*0.5f))
			continue;

		for (y=0;y<yres;y++)
		{
			for (x=0;x<xres;x++)
			{
				Vector p1 = Vector(x-xres*0.5f, y-yres*0.5f, z-zres*0.5f)*scale;

				if ((p1-campos).length() < 12)
				{
					flares[flarecount++] = p1;
					Vector p2 = Vector(x+1-xres*0.5f, y-yres*0.5f, z-zres*0.5f)*scale;
					Vector p3 = Vector(x-xres*0.5f, y+1-yres*0.5f, z-zres*0.5f)*scale;
					Vector p4 = Vector(x-xres*0.5f, y-yres*0.5f, z+1-zres*0.5f)*scale;

					Vector c2 = (p1+p2)*0.5f;
					Vector c3 = (p1+p3)*0.5f;
					Vector c4 = (p1+p4)*0.5f;

					const float brightness = 0.4f;

					glVertex3fv((float *)&p1);
					glVertex3fv((float *)&p2);
					if (y != yres-1)
					{
						glVertex3fv((float *)&p1);
						glVertex3fv((float *)&p3);
					}
					glVertex3fv((float *)&p1);
					glVertex3fv((float *)&p4);
				}
			}
		}
	}
	glEnd();

	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, flare2->ID);

	Vector xr, yr, zr;
	antiRotate(&xr, &yr, &zr);

	glBegin(GL_QUADS);
	glColor4f(1,1,1, alpha*valoarvo);
	for (i=0;i<flarecount;i++)
	{
			const float size = 0.14f;

			Vector p = flares[i];

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
	glEnd();
	glDisable(GL_FOG);

	delete [] flares;

}

void hila_init()
{
}

void hila_free()
{
} 
 
