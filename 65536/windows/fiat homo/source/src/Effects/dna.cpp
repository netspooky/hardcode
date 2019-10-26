#include "dna.hpp"

const int dnasegments = 260;

Vector *dnapoints;
Vector *dnastrip1;
Vector *dnastrip2;

void dna(float aika)
{
	float alpha = calcSaturate(aika, 0.0f, 1.0f, 3);

	glLoadIdentity();
	glDisable(GL_TEXTURE_2D);
	glTranslatef(aika, aika*4+4, -7.0f);
	glRotatef(aika*150, 0, 1, 0.1f);

	glPushMatrix();
	glTranslatef(2.0f+aika*aika*0.6f, 0, 0);
	drawhelix(aika, alpha, Vector(0.1f, 0.1f, 0.9f));
	glPopMatrix();

	glPushMatrix();
	glTranslatef(-1.7f, -20+aika, 0);
	glRotatef(180, 0, 0, 1);
	drawhelix(aika, alpha, Vector(0.8f, 0.2f, 0.15f));
	glPopMatrix();
}

void drawhelix(float aika, float alpha, Vector col)
{
	int i;
	int offset;
	int asti = (int)(aika*1000);
	if (asti > dnasegments-1)
		asti = dnasegments-1;

	Vector x, y, z;
	antiRotate(&x, &y, &z);

	glEnable(GL_TEXTURE_2D);
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

	glColor4f(0,0,0,alpha);

	glEnable(GL_DEPTH_TEST);
	glDepthMask(1);
	
	for (i=0;i<asti*2;i++)
	{
		if (i%3)
			glBindTexture(GL_TEXTURE_2D, pallura2->ID);
		else
			glBindTexture(GL_TEXTURE_2D, pallura->ID);
		Vector pos = dnapoints[i];

		const float kusemisenpoistomul = 1.1f + 0.05f*(float)cos(15*i/(float)(dnasegments*2));
		pos.x *= kusemisenpoistomul;
		pos.z *= kusemisenpoistomul;
		const float scale = 0.1f;
		billboard(pos, x, y, z, scale);
	}
	glLineWidth(2.0f);
	glDisable(GL_TEXTURE_2D);
	glDepthMask(1);
	glBegin(GL_LINES);
	offset = 0;
	for (i=0;i<asti;i++)
	{
		//välissä oleva sidos
		Vector v1 = dnapoints[offset];
		Vector v2 = dnapoints[offset+1];
		Vector middle = (v1+v2)*0.5f;

		if (i%2)
			glColor4f(col.x, col.y, col.z,alpha);
		else
			glColor4f(0,0,0,alpha);
		glVertex3fv((float *)&v1);
		glVertex3fv((float *)&middle);
		glColor4f(0,0,0,alpha);

		if (i%2)
			glColor4f(0,0,0,alpha);
		else
			glColor4f(col.x, col.y, col.z,alpha);

		glVertex3fv((float *)&v2);
		glVertex3fv((float *)&middle);
		offset += 2;
	}
	glEnd();

	glColor4f(0,0,0,alpha);
	//nauhat
	glBegin(GL_LINES);
	offset = 0;
	for (i=0;i<asti;i++)
	{
		glVertex3fv((float *)&dnastrip1[offset]);
		glVertex3fv((float *)&dnastrip1[offset+2]);
		glVertex3fv((float *)&dnastrip1[offset+1]);
		glVertex3fv((float *)&dnastrip1[offset+3]);
		glVertex3fv((float *)&dnastrip2[offset]);
		glVertex3fv((float *)&dnastrip2[offset+2]);
		glVertex3fv((float *)&dnastrip2[offset+1]);
		glVertex3fv((float *)&dnastrip2[offset+3]);
		offset+=2;
	}
	glEnd();
	//ja niiden täytteet
	glColor4f(1,1,1,1);
	glEnable(GL_DEPTH_TEST);

	glBegin(GL_QUAD_STRIP);
	offset = 0;
	for (i=0;i<asti;i++)
	{
		glVertex3fv((float *)&dnastrip1[offset]);
		glVertex3fv((float *)&dnastrip1[offset+1]);
		offset +=2;
	}
	glEnd();
	glBegin(GL_QUAD_STRIP);
	offset = 0;
	for (i=0;i<asti;i++)
	{
		glVertex3fv((float *)&dnastrip2[offset]);
		glVertex3fv((float *)&dnastrip2[offset+1]);
		offset +=2;
	}
	glEnd();

}

void dna_init()
{
	int i;
	const float dnatwist = 0.1f; //kuinka paljon käännytään per segmentti
	const float dnaradius = 1.0f; //kierteen läpimitta
	const float yadd = 0.1f; //näin paljon liikutaan eteenpäin per segmentti

	//kappale ja vastakappale
	dnapoints = new Vector[dnasegments*2];

	//reunojen nauhat
	dnastrip1 = new Vector[dnasegments*2];
	dnastrip2 = new Vector[dnasegments*2];

	//kierre alkaa x-kohdasta 0, y ja z määräytyvät kohdan mukaan

	float kulma = 0.0f;
	float yvalue = 0.0f;
	int offset = 0;
	int offset2 = 0;

	Matrix rotate;

	for (i=0;i<dnasegments;i++)
	{
		//pyöritetään suoraa tikkua y-akselin ympäri
		rotate.makeRotation(0, kulma, 0);
		const float epsilon = 0.01f;
		Vector reunapiste =  Vector( dnaradius, 0, 0)*rotate + Vector(0, yvalue, 0);
		Vector reunapiste2 = Vector(-dnaradius, 0, 0)*rotate + Vector(0, yvalue, 0);

		const float stripwidth = 0.1f;

		Vector strippoint1 = Vector( dnaradius+epsilon, 0,  stripwidth)*rotate + Vector(0, yvalue, 0);
		Vector strippoint2 = Vector( dnaradius+epsilon, 0, -stripwidth)*rotate + Vector(0, yvalue, 0);
		Vector strippoint3 = Vector(-dnaradius-epsilon, 0,  stripwidth)*rotate + Vector(0, yvalue, 0);
		Vector strippoint4 = Vector(-dnaradius-epsilon, 0, -stripwidth)*rotate + Vector(0, yvalue, 0);

		dnapoints[offset] = reunapiste;
		dnastrip1[offset] = strippoint1;
		dnastrip2[offset++] = strippoint3;

		dnapoints[offset] = reunapiste2;
		dnastrip1[offset] = strippoint2;
		dnastrip2[offset++] = strippoint4;

		yvalue -= yadd;
		kulma -= dnatwist;
	}
}

void dna_free()
{
	delete [] dnapoints;
	delete [] dnastrip1;
	delete [] dnastrip2;
}
