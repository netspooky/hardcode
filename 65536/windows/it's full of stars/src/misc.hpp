#ifndef _MISC_HPP_
#define _MISC_HPP_

// Täällä löytyy ne funktiot ja parametrit jotka pitää tehdä/asettaa itse kun default-libit
// ei ole käytössä
//
// Poista alla oleva kommentista kun haluat linkittää pois default-libit
//#define _NODEFAULTLIBS_
#ifdef _NODEFAULTLIBS_


// vaatii kernel32.lib
void* __cdecl operator new(unsigned int cb)
{
  return HeapAlloc(GetProcessHeap(),0,cb);
}

void __cdecl operator delete(void* pv)
{
  // Alkuperäinen: --> GetProcessHead?? <-- virhe?? ei löydy ainakaan MSDN-dokumentaatiosta?
  if(pv)
    HeapFree(GetProcessHeap(),0,pv);
}

extern "C" int _cdecl _purecall(void)
{
  return 0;
}

extern "C" int _fltused=1;			// floatit käyttöön
extern "C" int _ftol=1;				// float to long - tyyppi konversio
extern "C" int _ftoi=1;				// float to int - tyyppi konversio

#endif

#endif 
