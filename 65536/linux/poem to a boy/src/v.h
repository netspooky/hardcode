#ifndef V_H
#define V_H

#include <math.h>

float v_dot(const vector&, const vector&);

inline void v_cross(vector* ut, const vector &a, const vector &b) {
	(*ut)[X] = a[Y]*b[Z] - a[Z]*b[Y];
	(*ut)[Y] = a[Z]*b[X] - a[X]*b[Z];
	(*ut)[Z] = a[X]*b[Y] - a[Y]*b[X];
}

inline void v_sum(vector* ut, const vector &a, const vector &b) {
	(*ut)[0] = a[0] + b[0];
	(*ut)[1] = a[1] + b[1];
	(*ut)[2] = a[2] + b[2];
}

inline void v_sub(vector* ut, const vector &a, const vector &b) {
	(*ut)[0] = a[0] - b[0];
	(*ut)[1] = a[1] - b[1];
	(*ut)[2] = a[2] - b[2];
}

inline void v_norm(vector *v) {
	float f = 0.0;
	for(int i = 0; i < 3; i++) {
		if(fabsf(*v[i]) > f) f = fabsf(*v[i]);
	}
	if( f == 0.0) return;
	for(int i = 0; i < 3; i++) {
		*v[i] /= f;
	}
}

inline bool v_equals(const vector &a, const vector &b) {
	if(a[0] != b[0]) return false;
	if(a[1] != b[1]) return false;
	if(a[2] != b[2]) return false;
	return true;
}

inline void v_add(vector *a, const vector &b) {
	*a[0] += b[0];
	*a[1] += b[1];
	*a[2] += b[2];
}

#endif
