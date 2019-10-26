
#include "Material.h"

Material::Material() {
}

Material::Material(	Vector const& _ambient, Vector const& _diffuse, Vector const& _specular, Vector::value_type _shininess, Vector const& _emissive ):
	ambient( _ambient ), diffuse( _diffuse ), specular( _specular ), shininess( _shininess ), emissive( _emissive ) {
}
