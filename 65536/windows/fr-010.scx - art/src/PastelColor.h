#pragma once

class Vector;

class PastelColor
{
public:
	PastelColor(Vector v);
	~PastelColor(void);
	unsigned int *colormap;
};
