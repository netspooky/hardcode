
#ifndef __CAMERA_H__
#define __CAMERA_H__

#include <vector>
#include "Vector.h"
#include "Projection.h"

class Camera {
	public:
		Camera( float _fov, float _delta, Vector const& _up );
		~Camera();

		void					addEye( Vector const& eye );
		void					addTarget( Vector const& tgt );
		Matrix					getCameraMatrix( float time ) const;

		float					getFOV() const;

		void					setProjection( float aspect, float near, float far );
		Matrix const&			getProjectionMatrix() const;


	private:
		std::vector<Vector>		eyes;
		std::vector<Vector>		targets;

		float					fov;
		float					delta;
		Vector					up;

		Projection				projection;
};

typedef std::vector<Camera>	cameraList;

#endif