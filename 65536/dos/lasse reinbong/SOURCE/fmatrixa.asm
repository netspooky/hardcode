;// (c) 1995-1997 Niklas Beisert / pascal
;// lasse reinboeng source
;// this header must stay on top of this file
;// free for non-commercial use of any kind as long as proper credits are given.

.386
.387
.model flat,prolog
locals

.code

;//***************************************************************************
;//single vector functions

;//float fvecmul(const fvector &v1, const fvector &v2);
;//#pragma aux fvecmul parm [esi] [ebx] value [8087] modify [8087]
public fvecmul_
fvecmul_ proc
  fld dword ptr [esi+0]
  fmul dword ptr [ebx+0]
  fld dword ptr [esi+4]
  fmul dword ptr [ebx+4]
  faddp st(1),st
  fld dword ptr [esi+8]
  fmul dword ptr [ebx+8]
  faddp st(1),st
  ret
endp

;//float fvecsqr(const fvector &v1);
;//#pragma aux fvecsqr parm [esi] value [8087] modify [8087]
public fvecsqr_
fvecsqr_ proc
  fld dword ptr [esi+0]
  fmul dword ptr [esi+0]
  fld dword ptr [esi+4]
  fmul dword ptr [esi+4]
  faddp st(1),st
  fld dword ptr [esi+8]
  fmul dword ptr [esi+8]
  faddp st(1),st
  ret
endp

;//fvector &fvecadd(fvector &d, const fvector &v1, const fvector &v2);
;//#pragma aux fvecadd parm [edi] [esi] [ebx] value [edi] modify [8087]
public fvecadd_
fvecadd_ proc
  fld dword ptr [esi+0]
  fadd dword ptr [ebx+0]
  fld dword ptr [esi+4]
  fadd dword ptr [ebx+4]
  fld dword ptr [esi+8]
  fadd dword ptr [ebx+8]
  fstp dword ptr [edi+8]
  fstp dword ptr [edi+4]
  fstp dword ptr [edi+0]
  ret
endp

;//fvector &fvecsub(fvector &d, const fvector &v1, const fvector &v2);
;//#pragma aux fvecsub parm [edi] [esi] [ebx] value [edi] modify [8087]
public fvecsub_
fvecsub_ proc
  fld dword ptr [esi+0]
  fsub dword ptr [ebx+0]
  fld dword ptr [esi+4]
  fsub dword ptr [ebx+4]
  fld dword ptr [esi+8]
  fsub dword ptr [ebx+8]
  fstp dword ptr [edi+8]
  fstp dword ptr [edi+4]
  fstp dword ptr [edi+0]
  ret
endp

;//fvector &fvecscl(fvector &d, const fvector &s, float x);
;//#pragma aux fvecscl parm [edi] [esi] [8087] value [edi] modify [8087]
public fvecscl_
fvecscl_ proc
  fld st(0)
  fld st(0)
  fmul dword ptr [esi+0]
  fstp dword ptr [edi+0]
  fmul dword ptr [esi+4]
  fstp dword ptr [edi+4]
  fmul dword ptr [esi+8]
  fstp dword ptr [edi+8]
  ret
endp

;//fvector &fvecxmul(fvector &d, const fvector &v1, const fvector &v2);
;//#pragma aux fvecxmul parm [edi] [esi] [ebx] value [edi] modify [8087]
public fvecxmul_
fvecxmul_ proc
  fld dword ptr [esi+0]
  fmul dword ptr [ebx+4]
  fld dword ptr [esi+4]
  fmul dword ptr [ebx+0]
  fsubp st(1),st
  fld dword ptr [esi+8]
  fmul dword ptr [ebx+0]
  fld dword ptr [esi+0]
  fmul dword ptr [ebx+8]
  fsubp st(1),st
  fld dword ptr [esi+4]
  fmul dword ptr [ebx+8]
  fld dword ptr [esi+8]
  fmul dword ptr [ebx+4]
  fsubp st(1),st
  fstp dword ptr [edi+0]
  fstp dword ptr [edi+4]
  fstp dword ptr [edi+8]
  ret
endp

;//fvector &fvecspin(fvector &d, const fvector &v1, const fvector &v2, float a);
;//#pragma aux fvecspin parm [edi] [esi] [ebx] [8087] value [edi] modify [8087]
public fvecspin_
fvecspin_ proc
  fsincos
  fld st(0)
  fmul dword ptr [esi+0]
  fld st(2)
  fmul dword ptr [ebx+0]
  faddp st(1),st
  fstp dword ptr [edi+0]
  fld st(0)
  fmul dword ptr [esi+4]
  fld st(2)
  fmul dword ptr [ebx+4]
  faddp st(1),st
  fstp dword ptr [edi+4]
  fmul dword ptr [esi+8]
  fxch st(1)
  fmul dword ptr [ebx+8]
  faddp st(1),st
  fstp dword ptr [edi+8]
  ret
endp

;//fvector &fvecnorm(fvector &vd, const fvector &vs);
;//#pragma aux fvecnorm parm [edi] [esi] value [edi] modify [8087]
public fvecnorm_
fvecnorm_ proc
  call fvecsqr_
  fsqrt
  fld1
  fdivrp st(1),st
  fld st
  fld st
  fmul dword ptr [esi+0]
  fstp dword ptr [edi+0]
  fmul dword ptr [esi+4]
  fstp dword ptr [edi+4]
  fmul dword ptr [esi+8]
  fstp dword ptr [edi+8]
  ret
endp

;//fvector &fvecdet(const fvector &v1, const fvector &v2, const fvector &v3);
;//#pragma aux fvecdet parm [esi] [ebx] [edi] value [8087] modify [8087]
public fvecdet_
fvecdet_ proc
  fld dword ptr [esi+4]
  fmul dword ptr [ebx+8]
  fld dword ptr [esi+8]
  fmul dword ptr [ebx+4]
  fsubp st(1),st
  fmul dword ptr [edi+0]

  fld dword ptr [esi+8]
  fmul dword ptr [ebx+0]
  fld dword ptr [esi+0]
  fmul dword ptr [ebx+8]
  fsubp st(1),st
  fmul dword ptr [edi+4]
  faddp st(1),st

  fld dword ptr [esi+0]
  fmul dword ptr [ebx+4]
  fld dword ptr [esi+4]
  fmul dword ptr [ebx+0]
  fsubp st(1),st
  fmul dword ptr [edi+8]
  faddp st(1),st

  ret
endp



;//***************************************************************************
;//vector array functions

;//fvector *fvectransformv(fvector *vr, const fmatrix &m, const fvector *v, int n);
;//#pragma aux fvectransformv parm [edi] [ebx] [esi] [ecx] value [eax] modify [8087]
public fvectransformv_
fvectransformv_ proc
  mov eax,edi
  cmp ecx,0
  je @@done
@@lp:
    fld dword ptr [esi+8]
    fld dword ptr [esi+4]
    fld dword ptr [esi+0]

    fld st(0)
    fmul dword ptr [ebx+00h]
    fld st(2)
    fmul dword ptr [ebx+04h]
    faddp st(1),st
    fld st(3)
    fmul dword ptr [ebx+08h]
    faddp st(1),st
    fadd dword ptr [ebx+0Ch]
    fstp dword ptr [edi+0]

    fld st(0)
    fmul dword ptr [ebx+10h]
    fld st(2)
    fmul dword ptr [ebx+14h]
    faddp st(1),st
    fld st(3)
    fmul dword ptr [ebx+18h]
    faddp st(1),st
    fadd dword ptr [ebx+1Ch]
    fstp dword ptr [edi+4]

    fmul dword ptr [ebx+20h]
    fxch st(1)
    fmul dword ptr [ebx+24h]
    faddp st(1),st
    fxch st(1)
    fmul dword ptr [ebx+28h]
    faddp st(1),st
    fadd dword ptr [ebx+2Ch]
    fstp dword ptr [edi+8]
    add esi,12
    add edi,12
  dec ecx
  jnz @@lp
@@done:
  ret
endp

;//fvector *fvectransformn(fvector *vr, const fmatrix &m, const fvector *v, int n);
;//#pragma aux fvectransformn parm [edi] [ebx] [esi] [ecx] value [eax] modify [8087]
public fvectransformn_
fvectransformn_ proc
  mov eax,edi
  cmp ecx,0
  je @@done
@@lp:
    fld dword ptr [esi+8]
    fld dword ptr [esi+4]
    fld dword ptr [esi+0]

    fld st(0)
    fmul dword ptr [ebx+00h]
    fld st(2)
    fmul dword ptr [ebx+04h]
    faddp st(1),st
    fld st(3)
    fmul dword ptr [ebx+08h]
    faddp st(1),st
    fstp dword ptr [edi+0]

    fld st(0)
    fmul dword ptr [ebx+10h]
    fld st(2)
    fmul dword ptr [ebx+14h]
    faddp st(1),st
    fld st(3)
    fmul dword ptr [ebx+18h]
    faddp st(1),st
    fstp dword ptr [edi+4]

    fmul dword ptr [ebx+20h]
    fxch st(1)
    fmul dword ptr [ebx+24h]
    faddp st(1),st
    fxch st(1)
    fmul dword ptr [ebx+28h]
    faddp st(1),st
    fstp dword ptr [edi+8]
    add esi,12
    add edi,12
  dec ecx
  jnz @@lp
@@done:
  ret
endp

;//fvector *fvecintermediate(fvector *vr, const fvector *v1, const fvector *v2, int n, float deg);
;//#pragma aux fvecintermediate parm [edi] [esi] [ebx] [ecx] [8087] value [eax] modify [8087]
public fvecintermediate_
fvecintermediate_ proc
  fld1
  fsub st,st(1)
  mov eax,edi
  cmp ecx,0
  je @@done
@@lp:
    fld dword ptr [esi+0]
    fmul st,st(2)
    fld dword ptr [ebx+0]
    fmul st,st(2)
    faddp st(1),st
    fstp dword ptr [edi+0]

    fld dword ptr [esi+4]
    fmul st,st(2)
    fld dword ptr [ebx+4]
    fmul st,st(2)
    faddp st(1),st
    fstp dword ptr [edi+4]

    fld dword ptr [esi+8]
    fmul st,st(2)
    fld dword ptr [ebx+8]
    fmul st,st(2)
    faddp st(1),st
    fstp dword ptr [edi+8]

    add esi,12
    add ebx,12
    add edi,12
  dec ecx
  jnz @@lp
@@done:
  fcompp
  ret
endp


;//***************************************************************************
;//matrix generation functions

;//fmatrix &fmatmakenorm(fmatrix &m);
;//#pragma aux fmatmakenorm parm [edi] value [edi] modify [eax ecx]
public fmatmakenorm_
fmatmakenorm_ proc
  xor eax,eax
  mov ecx,12
  rep stosd
  sub edi,48
  mov eax,3F800000h
  mov [edi+00h],eax
  mov [edi+14h],eax
  mov [edi+28h],eax
  ret
endp

;//fmatrix &fmatmakemove(fmatrix &m, const fvector &v);
;//pragma aux fmatmakemove parm [edi] [esi] value [edi] modify [eax ecx]
public fmatmakemove_
fmatmakemove_ proc
  call fmatmakenorm_
  mov eax,[esi+0]
  mov ecx,[esi+4]
  mov esi,[esi+8]
  mov [edi+0Ch],eax
  mov [edi+1Ch],ecx
  mov [edi+2Ch],esi
  ret
endp

;//fmatrix &fmatmakerot(fmatrix &m, const fvector &ax, float a);
;//#pragma aux fmatmakerot parm [edi] [esi] [8087] value [edi] modify [eax 8087]
public fmatmakerot_
fmatmakerot_ proc
  fsincos                  ;//cos,sin
  xor eax,eax
  mov dword ptr [edi+0Ch],eax
  mov dword ptr [edi+1Ch],eax
  mov dword ptr [edi+2Ch],eax
  fld1                     ;//1
  fsub st,st(1)            ;//1-cos

  fld st(0)                ;//1-cos
  fmul dword ptr [esi+0]   ;//x(1-cos)
  fld st(0)                ;//x(1-cos)
  fmul dword ptr [esi+0]   ;//xx(1-cos)
  fadd st,st(3)            ;//xx(1-cos)+cos
  fstp dword ptr [edi+00h]

  fld st(0)                ;//x(1-cos)
  fmul dword ptr [esi+4]   ;//xy(1-cos)
  fld st(4)                ;//sin
  fmul dword ptr [esi+8]   ;//zsin
  fsubp st(1),st           ;//yx(1-cos)-zsin
  fstp dword ptr [edi+04h]

  fmul dword ptr [esi+8]   ;//xz(1-cos)
  fld st(3)                ;//sin
  fmul dword ptr [esi+4]   ;//ysin
  faddp st(1),st           ;//zx(1-cos)+ysin
  fstp dword ptr [edi+08h]

  fld st(0)                ;//(1-cos)
  fmul dword ptr [esi+4]   ;//y(1-cos)
  fld st(0)                ;//y(1-cos)
  fmul dword ptr [esi+0]   ;//xy(1-cos)
  fld st(4)                ;//sin
  fmul dword ptr [esi+8]   ;//zsin
  faddp st(1),st           ;//xy(1-cos)+zsin
  fstp dword ptr [edi+10h]

  fld st(0)                ;//y(1-cos)
  fmul dword ptr [esi+4]   ;//yy(1-cos)
  fadd st,st(3)            ;//yy(1-cos)+cos
  fstp dword ptr [edi+14h]

  fmul dword ptr [esi+8]   ;//zy(1-cos)
  fld st(3)                ;//sin
  fmul dword ptr [esi+0]   ;//xsin
  fsubp st(1),st           ;//zy(1-cos)-xsin
  fstp dword ptr [edi+18h]

  fmul dword ptr [esi+8]   ;//z(1-cos)
  fld st(0)                ;//z(1-cos)
  fmul dword ptr [esi+0]   ;//xz(1-cos)
  fld st(3)                ;//sin
  fmul dword ptr [esi+4]   ;//ysin
  fsubp st(1),st           ;//xz(1-cos)-ysin
  fstp dword ptr [edi+20h]

  fld st(0)                ;//z(1-cos)
  fmul dword ptr [esi+4]   ;//yz(1-cos)
  fld st(3)                ;//sin
  fmul dword ptr [esi+0]   ;//xsin
  faddp st(1),st           ;//yz(1-cos)+xsin
  fstp dword ptr [edi+24h]

  fmul dword ptr [esi+8]   ;//zz(1-cos)
  faddp st(1),st           ;//zz(1-cos)+cos
  fstp dword ptr [edi+28h]
  fstp st(0)

  ret
endp



;//***************************************************************************
;//matrix manipulation functions

;//fmatrix &fmatmove(fmatrix &m, const fvector &v);
;//pragma aux fmatmove parm [edi] [esi] value [edi] modify [8087]
public fmatmove_
fmatmove_ proc
  fld dword ptr [edi+0Ch]
  fadd dword ptr [esi+0]
  fstp dword ptr [edi+0Ch]
  fld dword ptr [edi+1Ch]
  fadd dword ptr [esi+4]
  fstp dword ptr [edi+1Ch]
  fld dword ptr [edi+2Ch]
  fadd dword ptr [esi+8]
  fstp dword ptr [edi+2Ch]
  ret
endp

;//fmatrix &fmatmul(fmatrix &mr, const fmatrix &m1, const fmatrix &m2);
;//#pragma aux fmatmul parm [edi] [esi] [ebx] value [edi] modify [ecx edx eax 8087]
public fmatmul_
fmatmul_ proc
local m:dword:12
  lea eax,m

  mov edx,3
@@lp1:
    mov ecx,4
  @@lp2:
      fld dword ptr [esi+00h]
      fmul dword ptr [ebx+00h]
      fld dword ptr [esi+04h]
      fmul dword ptr [ebx+10h]
      faddp st(1),st
      fld dword ptr [esi+08h]
      fmul dword ptr [ebx+20h]
      faddp st(1),st
      cmp ecx,1
      jne @@noadd
        fadd dword ptr [esi+0Ch]
    @@noadd:
      fstp dword ptr [eax]
      add ebx,4
      add eax,4
    dec ecx
    jnz @@lp2
    sub ebx,16
    add esi,16
  dec edx
  jnz @@lp1

  lea esi,m
  mov ecx,12
  rep movsd
  sub edi,48
  ret
endp

end
