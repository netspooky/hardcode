#ifndef RASTER_PROJECTION_S
#define RASTER_PROJECTION_S

const mat4 projection =
mat4
(
	ZNEAR/(PROJ_W), 0.0,				0.0,							0.0,
	0.0,	ZNEAR/(HEIGHT/WIDTH*PROJ_W),0.0,							0.0,
	0.0,	0.0,						-(ZFAR+ZNEAR)/(ZFAR-ZNEAR),	   -1.0,
	0.0,	0.0,						-2.0*ZFAR*ZNEAR/(ZFAR-ZNEAR),	0.0
);

#endif
