
#include "Camera.h"
#include "Matrix.h"

Camera::Camera( float _fov, float _delta, Vector const& _up ) : fov( _fov ), delta( _delta), up( _up ), projection( fov, 16.0f / 9.0f, 1.0f, 5000.0f ) {
}

Camera::~Camera() {
	eyes.clear();
	targets.clear();
}

void Camera::addEye( Vector const& eye ) {
	eyes.push_back( eye );
}

void Camera::addTarget( Vector const& tgt ) {
	targets.push_back( tgt );
}

Matrix Camera::getCameraMatrix( float time ) const {			// workaround

	// lerp 
	float	t		= time / delta;
	float	tinv	= 1.0f - t;

	Vector	lerpEye = ( eyes[ 1 ] * t ) + ( eyes[ 0 ] * tinv );
	Vector	lerpTgt = ( targets[ 1 ] * t ) + ( targets[ 0 ] * tinv );

	// setup camera matrix
	Vector forward( lerpEye - lerpTgt );
	forward.normalize();

	Vector right( up.cross( forward ) );
	right.normalize();

	Vector newUp( forward.cross( right ) );
	newUp.normalize();

	Matrix rot;
	rot.identity();
	rot.setRow( 0, right );				// rows -> matrix mul!
	rot.setRow( 1, newUp );
	rot.setRow( 2, forward );
	
	Matrix trans;
	trans.identity();
	trans.setCol( 3, -1.0f * lerpEye );

	return rot * trans;	
}

void Camera::setProjection( float aspect, float near, float far ) {
	projection.setPerspectiveProjection( fov, aspect, near, far );
}

Matrix const& Camera::getProjectionMatrix() const {
	return projection.getProjection();
}

float Camera::getFOV() const {
	return fov;
}