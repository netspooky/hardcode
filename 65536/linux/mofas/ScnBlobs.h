#ifndef _SCNBLOBS_H__
#define _SCNBLOBS_H__
#include <math.h>
#include "../base/scene.h"

#define sqr(a) (float)((a)*(a))
#define MB_RES 30
#define ISO_Level 1

typedef struct{
	float x,y,z;
}vertex;

typedef struct{
	vertex	pos;
	vertex  normal;
	float	value;
}pCube;

typedef struct{
	pCube	*P[8];
}Cube;

typedef struct{
	vertex pos;
	float  mass;
}metaBall;

class ScnBlobs : public TScene
{
private:
	bool		_setup;
	pCube		(*PUNTOS)[MB_RES+1][MB_RES+1];
	Cube		(*CELDAS)[MB_RES][MB_RES];
	metaBall	metaCock[5];
public:
	ScnBlobs()
	{
		_setup			= false;
	};
	virtual int		setup(int reason);
	virtual int		run(long time);
	virtual void	free(void);
	void			iniMetaballs(void);
	void			iniGrids(void);
	void			pintaCelda(Cube *grid);
	vertex			interpolate(pCube *p1, pCube *p2,vertex *normal);
	float			evaluate(float mass, vertex a, vertex b);
	vertex			normalizarVector(vertex p);
};

#endif
