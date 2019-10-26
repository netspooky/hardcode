
#include "Light.h"

void Light::addFrame( Vector const& pos ) {

	Matrix tm;

	tm.identity();
	tm.setCol( 3, pos );

	Transformation::addFrame( tm );
}

void Light::setColor( Vector const& _color ) {
	color = _color;
}

void Light::setIntensity( Vector::value_type _intensity ) {
	intensity = _intensity;
}

Vector const& Light::getColor() const {
	return color;
}

Vector::value_type Light::getIntensity() const {
	return intensity;
}