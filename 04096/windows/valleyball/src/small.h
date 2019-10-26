#pragma once

#pragma code_seg("sm0")

DWORD x_Ftol(float af_Value)
{
	DWORD ldw_RetVal;
	__asm fld af_Value
	__asm fistp ldw_RetVal
	return ldw_RetVal;
}

#pragma code_seg("sm1")

__forceinline float x_Frac(float af_Value)
{
	return af_Value - x_Ftol(af_Value);
}

#pragma code_seg("sm2")

__forceinline float x_Abs(float af_Value)
{
	__asm fld	af_Value
	__asm fabs
}

#pragma code_seg("sm3")

float x_Sin(float af_Value)
{
	__asm fld	af_Value
	__asm fsin
}

#pragma code_seg("sm4")

float x_Sign(float af_Value)
{
	if (af_Value != 0)
		return af_Value / x_Abs(af_Value);

	return 1.0f;
}

#pragma code_seg("sm5")

float x_Sqrt(float af_Value)
{
	__asm fld af_Value
	__asm fsqrt
}

#pragma code_seg("sm7")

__forceinline void x_MemCopy(void* av_Dest_, const void* av_Src_, size_t ai_Size)
{
	__asm mov esi, av_Src_
	__asm mov edi, av_Dest_
	__asm mov ecx, ai_Size
	__asm rep movsb
}

#pragma code_seg("sm8")

float x_Fmod(float x, float y)
{
	__asm fld	y
	__asm fld	x
	__asm fprem
	__asm fxch
	__asm fstp	x
}

#pragma data_seg("smA")

static unsigned long seed=0x12345678;

#pragma code_seg("sm9")

__forceinline void x_Randomize(unsigned long x)
{
	seed = x;
}

#pragma code_seg("smB")

float x_Rand()
{
	seed = seed * 0x76364873 + 1234567;
	return (float)(seed & 0x7FFFFFFF) * (const float)(2.0f / (float)0x7FFFFFFF) - 1.0f;
}

#pragma code_seg("smS")

__forceinline size_t x_Strlen(const char* as_String)
{
	size_t li_Length = 0;
	while (*as_String++) ++li_Length;
	return li_Length;
}

#pragma code_seg("smP")

float x_Pow(float x, float y){
	float r;
	__asm{
		fld y
		fld x
		fyl2x
		fld1
		fld st(1)
		fprem
		f2xm1
		faddp st(1),st
		fscale
		fxch st(1)
		fstp st(0)
		fstp r
	}
	return r;
}

extern "C" 
{
	int _fltused = 1;
}