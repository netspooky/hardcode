#ifndef M_H
#define M_H

#include <cstring>

// Matriseoperasjoner

typedef float matrix[16];

inline void m_mul(matrix &mat, const float &tall) {
	for(int i = 0; i < 16; i++) {
		mat[i] *= tall;
	}
}

inline void m_mul(matrix &mat, const matrix &matb) {
	matrix mata;
	memcpy(mata, mat, sizeof(matrix));
	for(int i = 0; i < 4; i++) {
		for (int j = 0; j < 4; j++) {
			mat[i*4+j] = mata[i*4+0]*matb[0+j] + mata[i*4+1]*matb[1+j] + mata[i*4+2]*matb[2*j] + mata[i*4+3]*matb[3+j];
		}
	}
}

#endif
