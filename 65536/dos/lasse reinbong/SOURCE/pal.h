// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

void palSetPal(const unsigned char *pal, int first, int num);
void palFadeBlack(const unsigned char *pal, int first, int num, int pos);
void palFadeWhite(const unsigned char *pal, int first, int num, int pos);
void palSetWhiteness();
void palSetBlackness();
void palInterpolCols(unsigned char *pal, int r1, int g1, int b1, int r2, int g2, int b2, int n);
void palMakeBCW(unsigned char *pal, int r, int g, int b, int c, int w);
void palFade2(const unsigned char *pal1, const unsigned char *pal2, int first, int num, int pos);
