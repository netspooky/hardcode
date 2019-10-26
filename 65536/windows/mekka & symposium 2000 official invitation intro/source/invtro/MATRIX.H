#ifndef __matrix_h
#define __matrix_h

#include "ficken3d.h"

#ifdef __cplusplus
extern "C" {
#endif

void MakeRotationMatrix  (float *matrix, const tvector *vector);
#pragma aux MakeRotationMatrix "*" parm[edx][ebx] modify exact [];

void MakeScaleMatrix     (float *matrix, const tvector *vector);
#pragma aux MakeScaleMatrix "*" parm[edx][ebx] modify exact [];

void MakeMoveMatrix      (float *matrix, const tvector *vector);
#pragma aux MakeMoveMatrix "*" parm[edx][ebx] modify exact [];

void MatrixMul           (float *destmatrix, const float *sourcea, const float *sourceb);
#pragma aux MatrixMul "*" parm[ebx][esi][edi] modify exact [];

void InverseMatrix       (float *destmatrix, const float *sourcematrix);
#pragma aux InverseMatrix "*" parm[edx][ebx] modify exact [];

void TransposeMatrix     (float *destmatrix, const float *sourcematrix);
#pragma aux TransposeMatrix "*" parm[edi][esi] modify exact [];

void VTransform          ( tvector *destvector, float *matrix,  tvector *sourcevector);
#pragma aux VTransform "*" parm[ebx][edi][esi] modify exact [];

void VNormal             ( tvector *destvector);
#pragma aux VNormal    "*" parm[eax] modify exact [];

//void MakeDirectionMatrix (camera3d *cam);
// #pragma aux MakeDirectionMatrix "*" parm[esi] modify exact [];

void VCrossProduct       (tvector *destvector, const tvector *a, const tvector *b);
#pragma aux VCrossProduct "*" parm[ebx][esi][edi] modify exact [];

void VCrossProduct2      (tvector *destvector, const tvector *a, const tvector *b);
#pragma aux VCrossProduct2 "*" parm[ebx][esi][edi] modify exact [];

#ifdef __cplusplus
}
#endif



#endif
