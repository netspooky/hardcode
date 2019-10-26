#include "scroller.h"

#include <GL/gl.h>

#include "ktex.h"

const char ost[][60]= { "Til Steinar", "", 
"Kj\002re Steinar",  "du som alt det gode vernar", "",
"Jeg har alltid tenkt", "  p\001 deg som min kj\002re", 
"Vil du se meg hengt?", "  hvorfor kan jeg aldri l\002re?", "",
"Du har blitt s\001 stor en gutt", "hjertet mitt er helt kaputt", "",
"Din utstr\001ling varmer mer", "  enn noen sol",
"Dine gode sider", "  teller mer enn et mol", "", // 18
"Dine former er s\001 pene", "dine tanker er alltid rene", "",
"Jesus passer n\001 p\001 deg", "  kj\002rlighet som aldri d\007r",
"Din venn, s\001 snill og grei", "  ting blir aldri mer som f\007r", "", // 26
"For n\001 er du blitt voksen ", "  s\001 stor og flott",
"Du passet aldri helt i boksen", "   ost er jammen meg godt", "", // 31
"Hva enn du syns om dette dikt", "  skal du vite at p\001 sikt",
"Kan du aldri bli mer likt", "  hvis du f\001r en f\002len gikt", "", // 36
"", "", "Anyway..", "GRATULERER MED DAGEN!", "(og ikke bli tatt av sagen)" // 41
};

const int oster = 41;

Text *scroller[oster];

texture *kake;

void scroller_init() {
	for(int i = 0; i < oster; i++) {
		scroller[i] = new Text(demo::fnt, ost[i]);
	}
	kake = new texture(KTEX_DATA, KTEX_LEN, true, GL_RGB);
}	

void scroller_draw() {
	glColor3f(1.0, 1.0, 1.0);
	glPushMatrix();
	glTranslatef(0, 0, -3);
	glNormal3f(0.0, 0.0, 1.0);

	glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, kake->get_num());

	glBegin(GL_POLYGON); {
		glTexCoord2i(0, 1);
		glVertex3f(-1.8, -1.3, 0.0);
		glTexCoord2i(1, 1);
		glVertex3f(0, -1.3, 0.0);
		glTexCoord2i(1, 0);
		glVertex3f(0, 1.3, 0.0);
		glTexCoord2i(0, 0);
		glVertex3f(-1.8, 1.3, 0.0);
	} glEnd();
	glDisable(GL_TEXTURE_2D);

	glPopMatrix();
	glTranslatef(0, ((float)demo::time/85) - 10, -17);
	for(int i = 0; i < oster; i++) {
		glPushMatrix();
		glScalef(0.25, 0.3, 0.0);
		scroller[i]->draw();
		glPopMatrix();
		glTranslatef(0.0, -1, 0.0);
	}
}
