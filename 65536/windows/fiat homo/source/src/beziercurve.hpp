#ifndef _BEZIERCURVE_HPP_
#define _BEZIERCURVE_HPP_

#include "vector.hpp"

	class QuadraticBezierCurve
	{
	public:
		QuadraticBezierCurve();
		QuadraticBezierCurve(Vector &point1, Vector &point2, Vector &point3);
		~QuadraticBezierCurve();

		void set(Vector &point1, Vector &point2, Vector &point3);

		Vector getValue(float t);
		Vector getDerivative(float t);

	private:

		Vector P1, P2, P3;

		inline float bezierValue(float p1, float p2, float p3, float t);
		inline float derivativeValue(float p1, float p2, float p3, float t);
	};

	class CubicBezierCurve
	{
	public:
		CubicBezierCurve();
		CubicBezierCurve(Vector &point1, Vector &point2, Vector &point3, Vector &point4);
		~CubicBezierCurve();

		void set(Vector &point1, Vector &point2, Vector &point3, Vector &point4);

		Vector getValue(float t);
		Vector getDerivative(float t);

	private:

		Vector P1, P2, P3, P4;

		inline float bezierValue(float p1, float p2, float p3, float p4, float t);
		inline float derivativeValue(float p1, float p2, float p3, float p4, float t);
	};

#endif
