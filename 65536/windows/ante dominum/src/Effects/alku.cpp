#include "alku.hpp"

//21, 2133, 19521, 176661, 129127041
//301, 16513, 60110701, 1977225901
//happy numbers
//fibonacci
const int seqlen = 32;

char seq1_1[seqlen] = "Traction                      \0";
char seq1_2[seqlen] = "70 836 4030 5830 7192 7912    \0";
char seq2_1[seqlen] = "presents a 64k intro          \0";
char seq2_2[seqlen] = "159 105 69 103 5996 1919 6905 \0";
char seq3_1[seqlen] = "for your enjoyment            \0";
char seq3_2[seqlen] = "10 50 41 86 225 69 109 56901 1\0";
char seq4_1[seqlen] = "at Breakpoint'06              \0";
char seq4_2[seqlen] = "223 6588 149 5896 1337 4096 11\0";
char seq5_1[seqlen] = "Ante Dominum                  \0";
char seq5_2[seqlen] = "14159 26535 89793 23846 2643  \0";
char seq6_1[seqlen] = "(Before God)                  \0";
char seq6_2[seqlen] = "2718 281 82845 90452 353      \0";
char seq7_1[seqlen] = "[740e-9, 380e-9] :  Preacher  \0";
char seq7_2[seqlen] = "21 2133 19521 176661 129127041\0";
char seq8_1[seqlen] = "[20, 20000] : Grip            \0";
char seq8_2[seqlen] = "301 16513 60110701 1977225901 \0";


void writer(Vector kohta, Vector color, float scale, float aika, float starttime, float endtime, 
			float alpha, char *teksti, char *teksti2)
{
	int i;

	const float a = alpha * calcSaturate(aika, starttime, endtime, 1);
	if (a <= 0.001f)
		return;

	scale = 0.5f;
	float t = calcPosFloat(aika, starttime,endtime);

	const float l1 = 0.3f;
	const float l2 = 0.85f;
	if (t < l1)
		t = 0;
	if (t >= l1 && t <= l2)
	{
		t -= l1;
		t *= 1.0f/(l2-l1);
	}
	if (t > l2)
		t = 1.0f;

	glPushMatrix();
	glTranslatef(kohta.x, kohta.y, kohta.z);
	glScalef(scale, scale, scale);
	glRotatef(180, 0, 1, 0);

	glPushMatrix();
	glColor4f(color.x, color.y, color.z, a);
	int tekstinkohta = (int)(t*seqlen);
	char *text = new char[seqlen+1];

	for (i=0;i<seqlen;i++)
	{
		if (i < tekstinkohta)
			text[i] = teksti[i];
		else
			text[i] = teksti2[i];
	}
	font_write3d(text);

	glPopMatrix();
	glPopMatrix();

	delete [] text;

}



void alku(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector camadd = Vector(0, 0, 1)*(float)pow(aika+0.056f, 140)*10000;
	Vector campos = Vector(0, 0, -30.0f+2*(float)sin(aika*4)) + camadd;
	Vector camtarget = Vector(0, 0, 0) + camadd;
	Vector camrot = Vector(0, 1, 0);

	Matrix rot;
	rot.makeRotation(0, 0, 0.02f*(float)sin(aika*7));

	camrot *= rot;

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, camrot.x, camrot.y, camrot.z);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

//void writer(Vector &kohta, Vector &color, float scale, 
//			float aika, float starttime, float endtime, float alpha, char *teksti, char *teksti2)
	writer(Vector(9, 2, 0), Vector(0, 0, 0), 2, aika, 0.1f, 0.2f, alpha, seq1_1, seq1_2);
	writer(Vector(11, -0.5, 0), Vector(0, 0, 0), 2, aika, 0.2f, 0.3f, alpha, seq2_1, seq2_2);
	writer(Vector(15, 3.2f, 0), Vector(0, 0, 0), 2, aika, 0.3f, 0.4f, alpha, seq3_1, seq3_2);
	writer(Vector(13, -1.2f, 0), Vector(0, 0, 0), 2, aika, 0.4f, 0.5f, alpha, seq4_1, seq4_2);
	writer(Vector(6, -1.2f, 0), Vector(0, 0, 0), 2, aika, 0.5f, 0.6f, alpha, seq5_1, seq5_2);
	writer(Vector(6, -1.2f, 0), Vector(0, 0, 0), 2, aika, 0.6f, 0.7f, alpha, seq6_1, seq6_2);
	writer(Vector(11, 1.5f, 0), Vector(0, 0, 0), 2, aika, 0.7f, 0.8f, alpha, seq7_1, seq7_2);
	writer(Vector(12, 0.2f, 0), Vector(0, 0, 0), 2, aika, 0.8f, 0.9f, alpha, seq8_1, seq8_2);
}

void alku_init()
{
}

void alku_free()
{
} 
