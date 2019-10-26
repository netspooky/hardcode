/*
	DEMOText.h
*/

struct text
{
	float start;
	float duration;
	float x, y;
	float xspd, yspd;
	float xscl, yscl;
	const char *msg;
};

text demotext[] =
{
	/*
	 BEG  DUR  X    Y   XSP  YSP XSX YSX     TXT 
	*/	

	// End scroller
	{2, 10, 20,   300,   0,  00,  0,  0, "mudlord shamefully presents this"},
	{2, 10, 20,   280,   0,  00,  0,  0, "craptacular prod at flashback 2012   "},
	{2, 10, 20,   260,   0,  00,  0,  0, "my bad for complete crappiness :("},
	{13, 10, 20,   300,   0,  00,  0,  0, "this was done in less than a"},
	{13, 10, 20,   280,   0,  00,  0,  0, "hour and was rewritten twice actually."},
	{13, 10, 20,   260,   0,  00,  0,  0, "first ver had motion blur, "},
	{13, 10, 20,   240,   0,  00,  0,  0, "but I thought meh for this ver :("},
	{25, 10, 20,   300,   0,  00,  0,  0, "consider this a compofiller, as"},
	{25, 10, 20,   280,   0,  00,  0,  0, "i have creative block as i type this"},
	{27, 10, 20,   240,   0,  00,  0,  0, "but what the fuck, will do this anyway"},
	{40, 5, 20,   300,   0,  00,  0,  0, "if anyone cares, music by 4mat"},
	{40, 5, 20,   280,   0,  00,  0,  0, "rest of shit by me.. :("},
	{47, 5, 20,   300,   0,  00,  0,  0, "text loops from here...DDDD:"}
	
	

	
};

const int numtext = sizeof(demotext)/sizeof(text);