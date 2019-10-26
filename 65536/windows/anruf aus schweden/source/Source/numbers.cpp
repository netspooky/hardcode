
#include "numbers.h"

float const				PI					= 3.14159265f;
float const				EPSILON				= 0.0001f;

unsigned int const		HEADER_CHUNK		= 0x2222;
unsigned int const		MESH_CHUNK			= 0x3333;
unsigned int const		CAMERA_CHUNK		= 0x4444;
unsigned int const		LIGHT_CHUNK			= 0x5555;
unsigned int const		MATERIAL_CHUNK		= 0x6666;
unsigned int const		END_DELIMITER		= 0xFFFF;
unsigned char const		PLANE_OBJ			= 1;
unsigned char const		BOX_OBJ				= 2;
unsigned char const		SPHERE_OBJ			= 3;
unsigned char const		CYLINDER_OBJ		= 4;
unsigned char const		CONE_OBJ			= 5;
unsigned char const		TUBE_OBJ			= 6;
