#ifndef _METABALLS_H
#define _METABALLS_H

#ifdef __cplusplus
extern "C" {
#endif
/*
void	init_metalib(int Nshl,int MaxPoints,int MaxFaces);
void	meta_object(float **Tp,int **Tf,int *Nf,int *Np, float ( *f)(float,float,float),float iso);
void	init_metalibRGB(int Nshl,int MaxPoints,int MaxFaces);
void	meta_objectRGB(float **Tp,int **Tf,float **Tcol,int *Nf,int *Np, float ( *fr)(float,float,float),float ( *fg)(float,float,float),float ( *fb)(float,float,float),float iso);
void	init_metalibNO(int Nshl,int MaxPoints,int MaxFaces);
void	meta_objectNO(float **Tp,int **Tf,float **NO,int *Nf,int *Np, float ( *f)(float,float,float),float iso);
*/

void  init_metalib(int Nshl,int MaxPoints,int MaxFaces);
void  init_metalibNEG(int Nshl,int MaxPoints,int MaxFaces,int Env1,int Env2);
void  meta_object(float **Tp,int **Tf,int *Nf,int *Np, float ( *f)(float,float,float),float iso);
void  meta_objectNEG(float **Tp,int **Tf,int *Nf,char **Neg,int *Np, void ( *f)(float **,int),float iso);
void init_metalibRGB(int Nshl,int MaxPoints,int MaxFaces);
void meta_objectRGB(float **Tp,int **Tf,float **Tcol,int *Nf,int *Np, float ( *fr)(float,float,float),float ( *fg)(float,float,float),float ( *fb)(float,float,float),float iso);
void  init_metalibNO(int Nshl,int MaxPoints,int MaxFaces);
void  meta_objectNO(float **Tp,int **Tf,float **NO,int *Nf,int *Np, float ( *f)(float,float,float),float iso);

#ifdef __cplusplus
};
#endif

#endif
