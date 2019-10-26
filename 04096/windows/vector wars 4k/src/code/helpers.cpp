#include "stableheaders.hpp"

#include "helpers.hpp"

//////////////////////////////////////////////////////////////////////////
// BSS
//////////////////////////////////////////////////////////////////////////
#pragma  bss_seg(".bss_helpers")

DWORD	g_randSeed;	// the current random seed

//////////////////////////////////////////////////////////////////////////
// DATA
//////////////////////////////////////////////////////////////////////////
#pragma  data_seg(".data_helpers")

static const float round_toward_m_i = -0.5f; // needed for the F2IFloor() function

//////////////////////////////////////////////////////////////////////////
// CODE
//////////////////////////////////////////////////////////////////////////
#pragma code_seg(".code_helpers")

////////////////////////////////////////////////////////////////////////////////
//
//	F2IRound()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Convert a float to int using rounding.

*/
int F2IRound(float _float)
{	
	int result;
	
	__asm
	{
		fld		_float
		fistp	result
	}
	
	return result;
}

////////////////////////////////////////////////////////////////////////////////
//
//	F2IFloor()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Converts a float to int while cutting off the fractional part.

*/
int F2IFloor(float _float)
{
   int result;
   
   __asm
    {
      fld      _float
      fadd     st, st (0)
      fadd     round_toward_m_i
      fistp    result
      sar      result, 1
   }

   return result;
}

////////////////////////////////////////////////////////////////////////////////
//
//	SawF()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Returns a sawtooth signal for the given phase.

	\param _phase

		The phase. [0..2 * PI]

	\return

		The sawtooth signal. [-1..1]

*/
float SawF(float _phase)
{
	return ModF(_phase / PI, 2.0f) - 1.0f;
}

////////////////////////////////////////////////////////////////////////////////
//
//	ModF()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Returns _x modulo _y.
*/
float ModF(float _x, float _y)
{
	__asm
	{
		fld	_y
		fld	_x
		fprem
		fxch
		fstp	_x
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	AtanF()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Returns the arc tangent of _x / _y.

*/
float  AtanF(float _x, float _y)
{
	__asm
	{
		fld	_y
		fld	_x
		fpatan
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	AbsF()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Returns the absolute value of _value.
*/
float AbsF(float _value)
{
	__asm
	{
		fld	_value
		fabs
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	MemClear()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Clears memory with zeros.

	\param _pDest

		The pointer to the memory block to clear.

	\param _size

		The number of bytes to clear.
*/
void MemClear(void* _pDest, const SIZE_T _size) 
{
	__asm
	{
		mov edi, _pDest
		xor eax, eax
		mov ecx, _size
		rep stosb
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	MemCopy()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Copied memory from one point to another.

	\param _pDest

		Pointer to the destination memory block.

	\param _pSource

		Pointer to the source memory block.

	\param _size

		The number of bytes to copy.

	\remarks

		Make sure the memory blocks do not overlap.

*/
void MemCopy(void* _pDest, const void* _pSource, const SIZE_T _size) 
{
	__asm
	{
		mov esi, _pSource
		mov edi, _pDest
		mov ecx, _size
		rep movsb
	}
}

////////////////////////////////////////////////////////////////////////////////
//
//	GetRandomInt16()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Returns a random integer. [0..32767]

*/
unsigned GetRandomInt16()
{
	// K+R
	g_randSeed = g_randSeed * 1103515245 + 12345; 
	return (unsigned)(g_randSeed >> 16) & 32767;
}

////////////////////////////////////////////////////////////////////////////////
//
//	GetRandomFloat()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Returns a random float value. [0..1]

*/
float GetRandomFloat()
{
	return ((float) GetRandomInt16()) / 32767.0f;
}

////////////////////////////////////////////////////////////////////////////////
//
//	ApproxLinear()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Blend between source and destination value.

	\param _pSourceValue

		The source value.

	\param _destValue

		The destination value to reach.

	\param _maxDeltaPerUnit

		The maximum delta step per 1.0 units passed via _fraction.

	\param _fraction

		The number of units

	\remarks

		Explaining the parameters is somewhat cumbersome but an example makes things
		clear.
		
		ApproxLinear(0.0, 10.0, 5.0, 0.5) will blend 5.0 * 0.5 units (2.5)
		between 0.0 and 10.0. So the result will be 2.5.
		
		It is mostly useful for situations like this:
		
		ApproxLinear(MinSpeed, MaxSpeed, Acceleration, TimePassed)

*/
void ApproxLinear(float*  _pSourceValue, const float _destValue, const float _maxDeltaPerUnit, const float _fraction)
{
	if (_destValue > *_pSourceValue)
	{
		*_pSourceValue = min(*_pSourceValue + _maxDeltaPerUnit * _fraction, _destValue);
	}
	else
	{
		*_pSourceValue = max(*_pSourceValue - _maxDeltaPerUnit * _fraction, _destValue);
	}
}

/*
	
*/
////////////////////////////////////////////////////////////////////////////////
//
//	GetDiffOfAngles()
//
////////////////////////////////////////////////////////////////////////////////
/**
	\brief

		Returns the shortest difference between two angles.

	\remarks

		Input angles must not differ by more than 2 * PI.

*/
float GetDiffOfAngles(const float _from, const float _to)
{
	float tempTo;
	
	tempTo = _to;
	
	if (tempTo - _from < -PI)
		tempTo += 2.0f * PI;

	if (tempTo - _from > PI)
		tempTo -= 2.0f * PI;

	return tempTo - _from;	
}
