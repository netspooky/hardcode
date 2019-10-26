//----------------------------------------------------------------------------
//  Nombre:    Base.h
//
//  Contenido: Definición de los tipos de datos basicos
//----------------------------------------------------------------------------

#ifndef _BASE_H_
#define _BASE_H_

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

//----------------------------------------------------------------------------
// Tipos destinados a trabajo lógico
//----------------------------------------------------------------------------
typedef unsigned char  uchar;
typedef unsigned int   uint;
typedef unsigned short ushort;
typedef unsigned long  ulong;

//----------------------------------------------------------------------------
// Tipos destinados a uso como almacenamiento de memoria
//----------------------------------------------------------------------------
typedef unsigned char  byte;
typedef unsigned int   dword;
typedef unsigned short word;

//----------------------------------------------------------------------------
// PI
//----------------------------------------------------------------------------
#define PI 3.1415926535897932384626433832795f

//----------------------------------------------------------------------------
// NULL
//----------------------------------------------------------------------------
#ifndef NULL
#define NULL 0
#endif

//----------------------------------------------------------------------------
// Constantes para la gestión de errores
//----------------------------------------------------------------------------
enum
{
  RET_OK = 0,
  RET_FAIL,
  ERR_START
};

typedef int TError;

#define RET_SIMPLIFY(errcode) ((errcode) == RET_OK ? RET_OK : RET_FAIL)

//----------------------------------------------------------------------------
// LOG
//----------------------------------------------------------------------------
#ifdef VERSIONFINAL
  #define GLOG(a)     ((void)0)
#else
  void BaseLog(const char *fmt, ...);
  #define GLOG(a)     (BaseLog a)
#endif // VERSIONFINAL

// Messagebox simplote
void  BaseAlert (const char *pszText);
void  BaseAlertf(const char *fmt, ...);

//----------------------------------------------------------------------------
// Assert
//----------------------------------------------------------------------------
#ifdef VERSIONFINAL
  #define ASSERT(exp)       ((void)0)
  #define ASSERTM(exp,msg)  ((void)0)
#else
  void  NotifyAssertFailure(const char *sText, const char *sFile, unsigned Line);
  void  NotifyAssertFailure(const char *sText,const char *sMensaje,const char *sFile, unsigned Line);
  #define ASSERT(exp)       (void)( (exp) || (NotifyAssertFailure(#exp, __FILE__, __LINE__), 0) )
  #define ASSERTM(exp,msg)  (void)( (exp) || (NotifyAssertFailure(#exp,msg, __FILE__, __LINE__), 0) )
#endif  // VERSIONFINAL

//----------------------------------------------------------------------------
// Macros para manejo de punteros
//----------------------------------------------------------------------------

  // Memoria dinamica:
#define NEW(a)          (new a)
#define NEW_ARRAY(a,b)  (new a[b])
#define NUKE_PTR(p)             (delete (p), (p) = NULL)
#define NUKE_ARRAY_PTR(p)       (delete[] (p), (p) = NULL)
#define DISPOSE(p)           (delete (p), (p) = NULL)
#define DISPOSE_ARRAY(p)     (delete[] (p), (p) = NULL)

  // Incrementar un puntero (al tipo que sea) en un numero de bytes dado.
#define POINTER_ADD_T(t,p,a)    ( (t*) (((unsigned)(p)) + (a)) )
#define POINTER_ADD(p,a)        POINTER_ADD_T(void, p, a)

//----------------------------------------------------------------------------
// Macros para manejo de arrays
//----------------------------------------------------------------------------

// Averiguar el numero de elementos en un array (OJO: tiene que ser un array, no puede ser un puntero).
#define SIZE_ARRAY(a)           (sizeof(a)/sizeof(*(a)))
#define ARRAY_LEN(a)            (sizeof(a)/sizeof(*(a)))

//----------------------------------------------------------------------------
// Inlines para gestion numerica
//----------------------------------------------------------------------------

  // ---------
template<class T>
inline void Swap  (T &a, T &b)
//          ----
{
  T t = a; a = b; b = t;
}

  // ---------
template<class T>
inline T Max  (T a, T b)
//       ---
{
  if (a >= b)
    return a;
  return b;
}

  // ---------
template<class T>
inline T Min  (T a, T b)
//       ---
{
  if (a >= b)
    return b;
  return a;
}

  // ---------
template<class T>
inline T Clamp  (T v, T a, T b)
//       -----
{
  if (v < a)
    return a;
  if (v > b)
    return b;
  return v;
}

  // ---------
template<class T>
inline T Pow2 (T c)
//       ----
{
  return c*c;
}

  // ---------
template<class T>
inline T Lerp (T a, T b, float t)
//       ----
{
  return a + t*(b-a);
}

//----------------------------------------------------------------------------
// Vectores, ángulos, color
//----------------------------------------------------------------------------


//----------------------------------------------------------------------------
// Memoria
//----------------------------------------------------------------------------

inline void CopyMem( void* _destino, void const* _fuente, unsigned _bytes )
  { memcpy(_destino,_fuente,_bytes); }
  // falla si destino y fuente solapados

inline void MoveMem( void* _destino, void const* _fuente, unsigned _bytes )
  { memmove(_destino,_fuente,_bytes); }
  // funciona si destino y fuente solapados

inline void ZeroMem( void* _destino, unsigned _bytes )
  { memset(_destino,0,_bytes); }

#endif  //_BASE_H_
