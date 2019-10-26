#ifndef helpers_hpp
#define helpers_hpp

#ifdef _DEBUG
	inline void MessageBoxLastError(LPTSTR lpszFunction) 
	{ 
		// Retrieve the system error message for the last-error code

		LPVOID lpMsgBuf;
		LPVOID lpDisplayBuf;
		DWORD dw = GetLastError(); 

		FormatMessage(
			FORMAT_MESSAGE_ALLOCATE_BUFFER | 
			FORMAT_MESSAGE_FROM_SYSTEM |
			FORMAT_MESSAGE_IGNORE_INSERTS,
			NULL,
			dw,
			MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
			(LPTSTR) &lpMsgBuf,
			0, NULL );

		// Display the error message and exit the process

		lpDisplayBuf = (LPVOID)LocalAlloc(LMEM_ZEROINIT, 
			(lstrlen((LPCTSTR)lpMsgBuf)+lstrlen((LPCTSTR)lpszFunction)+40)*sizeof(TCHAR)); 
		sprintf((LPTSTR)lpDisplayBuf, 
			//LocalSize(lpDisplayBuf) / sizeof(TCHAR),
			TEXT("%s failed with error %d: %s"), 
			lpszFunction, dw, lpMsgBuf); 
		MessageBox(NULL, (LPCTSTR)lpDisplayBuf, TEXT("Error"), MB_OK); 

		LocalFree(lpMsgBuf);
		LocalFree(lpDisplayBuf);
		ExitProcess(dw); 
	}

	#define D3D_VERIFY(func, msg) if (D3D_OK != func) MessageBox(NULL, msg, "Error", MB_OK);
	#define WINAPI_VERIFY(func) if (!(func)) MessageBoxLastError("")
#else
	#define D3D_VERIFY(func, msg) func;
	#define WINAPI_VERIFY(func) func;
#endif

// macro to create a D3DCOLOR from its color components
#define MAKE_RGBA(redval, greenval, blueval, alphaval) (((alphaval) << 24) | ((redval) << 16) | ((greenval) << 8) | (blueval))

// macro to determine the number of elements of an array
#define GET_ARRAY_SIZE(_array) (sizeof(_array) / sizeof(_array[0]))

// well... we need PI all the time
#define PI 3.1415926535897932384626433832795f

// since D3DXVECTOR2 has a constructor we use this data compatible struct
// whenever we do not want the call to the constructor
struct Vector2
{
	float x;
	float y;
};

int F2IRound (float _float);
int F2IFloor(float _float);
__forceinline float  SqrtF(float _value);
__forceinline float  SinF(float _phase);
__forceinline float  CosF(float _phase);
float SawF(float _phase);
float  ModF(float _x, float _y);
float  AtanF(float _x, float _y);
float AbsF(float _value);
void  MemClear(void* _pDest, const SIZE_T _size);
void  MemCopy(void* _pDest, const void* _source, const SIZE_T _size);
unsigned GetRandomInt16();
float GetRandomFloat();

void ApproxLinear(float* _pSourceValue, const float _destValue, const float _maxDeltaPerUnit, const float _fraction);
#define GetAngle(_x, _y) (AtanF(-(_y), (_x)))
float GetDiffOfAngles(const float _from, const float _to);

extern DWORD g_randSeed;

//////////////////////////////////////////////////////////////////////////
__forceinline float SqrtF(float _value)
{
	__asm
	{
		fld	_value
		fsqrt
	}
}

__forceinline float SinF(float _phase)
{
	__asm
	{
		fld	_phase
		fsin
	}
}

__forceinline float  CosF(float _phase)
{
	__asm
	{
		fld	_phase
		fcos
	}
}

//////////////////////////////////////////////////////////////////////////

#endif // #ifndef helpers_hpp
