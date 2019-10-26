#ifndef __math3d_h
#define __math3d_h

extern const float M_PI;
extern const float M_PI2;

float fmod (float a, float b);
#pragma aux fmod = "fprem"       \
                   "fxch st(1)"  \
                   "fstp st"     \
                   parm[8087][8087] value[8087] modify [8087];

float sin (float f);
#pragma aux sin = "fsin" parm[8087] value[8087] modify [8087];

float cos (float f);
#pragma aux cos = "fcos" parm[8087] value[8087] modify [8087];

float fabs (float f);
#pragma aux fabs = "fabs" parm[8087] value[8087] modify [8087];

float fsqrt (float f);
#pragma aux fsqrt = "fsqrt" parm[8087] value[8087] modify [8087];

float DotProduct (tvector *a, tvector *b);
#pragma aux DotProduct =  \
"      fldz                     " \
"      fld    dword [eax]       " \
"      fmul   dword [edx]       " \
"      fld    dword [eax + 4]   " \
"      fmul   dword [edx + 4]   " \
"      fxch   st(1)             " \
"      faddp  st(2), st         " \
"      fld    dword [eax + 8]   " \
"      fmul   dword [edx + 8]   " \
"      fxch   st(1)             " \
"      faddp  st(2), st         " \
"      faddp  st(1), st         " \
parm[eax][edx] value[8087] modify exact [8087];


void addvector (tvector * dest, tvector *src);
#pragma aux addvector = \
"      fld    dword [eax]             "\
"      fld    dword [eax+4]           "\
"      fld    dword [eax+8]           "\
"      fadd   dword [edx+8]           "\
"      fxch   st(1)                   "\
"      fadd   dword [edx+4]           "\
"      fxch   st(2)                   "\
"      fadd   dword [edx]             "\
"      fxch   st(1)                   "\
"      fstp   dword [eax+8]           "\
"      fstp   dword [eax]             "\
"      fstp   dword [eax+4]           "\
parm[eax][edx] modify exact [];

void vsub (tvector *u, const tvector *a, const tvector *b);
#pragma aux vsub =              \
"      fld    dword [eax]    "  \
"      fld    dword [eax+4]  "  \
"      fld    dword [eax+8]  "  \
"      fsub   dword [edx+8]  "  \
"      fxch   st(1)          "  \
"      fsub   dword [edx+4]  "  \
"      fxch   st(2)          "  \
"      fsub   dword [edx]    "  \
"      fxch   st(1)          "  \
"      fstp   dword [edi+8]  "  \
"      fstp   dword [edi]    "  \
"      fstp   dword [edi+4]  "  \
parm[edi][eax][edx] modify exact [];


void addscale (tvector * dest, tvector *src, float f);
#pragma aux addscale =          \
"      fld    dword [eax]    "  \
"      fld    dword [eax+4]  "  \
"      fld    dword [eax+8]  "  \
"      fmul   st, st(3)      "  \
"      fxch   st(1)          "  \
"      fmul   st, st(3)      "  \
"      fxch   st(2)          "  \
"      fmulp  st(3), st      "  \
"      fadd   dword [edx+8]  "  \
"      fxch   st(1)          "  \
"      fadd   dword [edx+4]  "  \
"      fxch   st(2)          "  \
"      fadd   dword [edx]    "  \
"      fxch   st(2)          "  \
"      fstp   dword [edx+4]  "  \
"      fstp   dword [edx+8]  "  \
"      fstp   dword [edx]    "  \
parm[edx][eax][8087] modify exact [8087];


void fvecspin(tvector *d,  tvector *v1,  tvector *v2, float a);
#pragma aux fvecspin =          \
"      fsincos               "  \
"      fld    st(0)          "  \
"      fmul   dword  [esi+0] "  \
"      fld    st(2)          "  \
"      fmul   dword  [ebx+0] "  \
"      faddp  st(1),st       "  \
"      fstp   dword  [edi+0] "  \
"      fld    st(0)          "  \
"      fmul   dword  [esi+4] "  \
"      fld    st(2)          "  \
"      fmul   dword  [ebx+4] "  \
"      faddp  st(1),st       "  \
"      fstp   dword  [edi+4] "  \
"      fmul   dword  [esi+8] "  \
"      fxch   st(1)          "  \
"      fmul   dword  [ebx+8] "  \
"      faddp  st(1),st       "  \
"      fstp   dword  [edi+8] "  \
parm[edi][esi][ebx][8087] modify exact [8087];


void NormCross (tvector *dest, tvector *a, tvector *b);
#pragma aux NormCross =           \
"      fld    dword [ebx+4]    "  \
"      fmul   dword [ecx+8]    "  \
"      fld    dword [ebx+8]    "  \
"      fmul   dword [ecx+0]    "  \
"      fld    dword [ebx+0]    "  \
"      fmul   dword [ecx+4]    "  \
"      fld    dword [ebx+8]    "  \
"      fmul   dword [ecx+4]    "  \
"      fld    dword [ebx+0]    "  \
"      fmul   dword [ecx+8]    "  \
"      fld    dword [ebx+4]    "  \
"      fmul   dword [ecx+0]    "  \
"      fxch   st(2)            "  \
"      fsubrp st(5), st(0)     "  \
"      fsubrp st(3), st(0)     "  \
"      fsubrp st(1), st(0)     "  \
"      fxch   st(2)            "  \
"      fstp   dword [eax+0]    "  \
"      fstp   dword [eax+4]    "  \
"      fstp   dword [eax+8]    "  \
"      fld    dword [eax+0]    "  \
"      fld    st(0)            "  \
"      fmul   st(0), st(0)     "  \
"      fld    dword [eax+4]    "  \
"      fld    st(0)            "  \
"      fmul   st(0), st(0)     "  \
"      fld    dword [eax+8]    "  \
"      fld    st(0)            "  \
"      fmul   st(0), st(0)     "  \
"      faddp  st(2), st(0)     "  \
"      fxch   st(1)            "  \
"      faddp  st(3), st(0)     "  \
"      fxch   st(2)            "  \
"      fsqrt                   "  \
"      fld1                    "  \
"      fdivrp st(1), st        "  \
"      fmul   st(1), st(0)     "  \
"      fmul   st(2), st(0)     "  \
"      fmulp  st(3), st(0)     "  \
"      fstp   dword [eax+4]    "  \
"      fstp   dword [eax+8]    "  \
"      fstp   dword [eax+0]    "  \
parm [eax][ebx][ecx] modify exact [8087];

void NormVector (tvector *dest);
#pragma aux NormVector = \
"      fld    dword [eax+0]    "\
"      fld    st(0)            "\
"      fmul   st(0), st(0)     "\
"      fld    dword [eax+4]    "\
"      fld    st(0)            "\
"      fmul   st(0), st(0)     "\
"      fld    dword [eax+8]    "\
"      fld    st(0)            "\
"      fmul   st(0), st(0)     "\
"      faddp  st(2), st(0)     "\
"      fxch   st(1)            "\
"      faddp  st(3), st(0)     "\
"      fxch   st(2)            "\
"      fsqrt                   "\
"      fld1                    "\
"      fdivrp st(1), st        "\
"      fmul   st(1), st(0)     "\
"      fmul   st(2), st(0)     "\
"      fmulp  st(3), st(0)     "\
"      fstp   dword [eax+4]    "\
"      fstp   dword [eax+8]    "\
"      fstp   dword [eax+0]    "\
parm[eax] modify exact[8087];

#endif
