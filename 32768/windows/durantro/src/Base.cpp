//----------------------------------------------------------------------------
//  Nombre:    Base.cpp
//
//  Contenido: Definición de los tipos de datos basicos
//----------------------------------------------------------------------------

#include "Base.h"

#include <stdarg.h>
#include <windows.h>

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void  BaseAlert(const char *pszText)
{
#ifdef _DEBUG
  __asm
  {
    int 3;
  }
#endif
  ::OutputDebugString("ALERT:  ");
  ::OutputDebugString(pszText);
  ::MessageBox(NULL, pszText, "ALERT!", MB_OK | MB_TASKMODAL | MB_ICONSTOP | MB_SETFOREGROUND);
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void  BaseAlertf(const char *fmt, ...)
{
  char buf[3000];
  va_list va;

  va_start(va, fmt);
  vsprintf(buf, fmt, va);
  va_end(va);
  BaseAlert(buf);
}


// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
#ifndef VERSIONFINAL
// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void BaseLog(const char *fmt, ...)
{
  char buf[3000];
  va_list va;

  va_start(va, fmt);
  vsprintf(buf, fmt, va);
  va_end(va);
  ::OutputDebugString(buf);
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void  NotifyAssertFailure(const char *sText, const char *sFile, unsigned Line)
{
  ::OutputDebugString("ASSERTION FAILED:  ");
  char buf[3000];
  sprintf(buf, "%s\n  FAILED IN FILE %s, LINE %d\n", sText, sFile, Line);
  ::OutputDebugString(buf);
  ::MessageBox(NULL, buf, "ASSERTION FAILED!", MB_OK | MB_TASKMODAL | MB_ICONSTOP | MB_SETFOREGROUND);
  __asm
  {
    int 3;
  }
}
// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void  NotifyAssertFailure(const char *sText,const char *sMensaje,const char *sFile, unsigned Line)
{
  char buf[3000];
  sprintf(buf, "%s\n  (%s)", sText, sMensaje);
  NotifyAssertFailure(buf, sFile, Line);
}

#endif // VERSIONFINAL
