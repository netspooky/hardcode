
#ifndef __MATERIAL_H__
#define __MATERIAL_H__

#include <vector>
#include "Vector.h"

struct Material {

	Material();
	Material( Vector const& _ambient, Vector const& _diffuse, Vector const& _specular, Vector::value_type _shininess, Vector const& _emissive );

	Vector					ambient;
	Vector					diffuse;
	Vector					specular;
	Vector::value_type		shininess;
	Vector					emissive;
};

typedef std::vector<Material>	materialList;

#endif