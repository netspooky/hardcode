
#ifndef __LIGHT_H__
#define __LIGHT_H__

#include <vector>
#include "Transformation.h"

class Light : public Transformation {
	public:
		void					addFrame( Vector const& pos );
		void					setColor( Vector const& _color );
		void					setIntensity( Vector::value_type _intensity );
		
		Vector const&			getColor() const;
		Vector::value_type		getIntensity() const;

	private:
		Vector					color;
		Vector::value_type		intensity;	
};

typedef std::vector<Light> lightList;

#endif