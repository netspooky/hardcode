static unsigned char fontdata[] = {
#include "fontdata.c"
};

static void font_render(unsigned int c) {
  unsigned int bit = c * 5*6;
  unsigned int x, y;

  glColor3f(1, 1, 0);
  glPointSize(15.0f);
  glBegin(GL_POINTS);
  for(y=0; y<5; y++) {
    for(x=0; x<5; x++) {
      float s[3] = { x / 15.0f, y / 15.0f, -1 };

      if(fontdata[bit/8] & (1 << (bit & 7)))
        glVertex3fv(s);

      bit++;
    }
  }
  glEnd();
}
