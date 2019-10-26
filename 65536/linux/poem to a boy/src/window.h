#ifndef WINDOW_H
#define WINDOW_H

class window {
	int windowid;
	int height;
	int width;

	float clear[4];

public:
	window();

	~window();

	void resize(int x, int y);

	void predraw();

	void draw();

	void postdraw();

	void setclearcolor(float r, float g, float b, float a);

	void setclearcolor(float r, float g, float b);
};
#endif
