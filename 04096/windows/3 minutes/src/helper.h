#ifndef HELPER_H
#define HELPER_H

int MYFLOORF(float x) 
{ 
      static int holder, setter, result; 
  
      __asm 
      { 
           fld		[x] 
           fnstcw	[holder] 
           movzx	eax, [holder] 
           and		eax, 0xfffff3ff 
           or		eax, 0x00000400 
           mov		[setter], eax 
           fldcw	[setter] 
           fistp	[result] 
           fldcw	[holder] 
      } 
  
      return result;  
}

__declspec(naked) float __fastcall mysqrtf(float x)
{
	__asm
	{
		fld		dword ptr[esp+4] 
		fsqrt
		ret		4
	}
}

__declspec(naked) float __fastcall mysinf(float x)
{
	__asm 
	{
		fld		dword ptr[esp+4] 
		fsin
		ret		4
	}
}

__declspec(naked) float __fastcall mycosf(float x)
{
	__asm 
	{
		fld		dword ptr[esp+4] 
		fcos
		ret		4
	}
}

#endif