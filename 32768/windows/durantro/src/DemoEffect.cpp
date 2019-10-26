// -------------------------------------------------------------------------------------
// File:        DemoEffect.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include "DemoEffect.h"

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      Init
// Purpose:       Initialize the object
// Parameters:    
// --------------------------------------------------------------------------
TError CDemoEffect::Init  (CDisplayDevice *pDev)
{
  End();

  m_curTime = 0;
  m_pDev = pDev;
  m_bActive = false;
  return RET_OK;
}


// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
bool CDemoEffect::Run         (int time)
{
  m_delta = time - m_curTime;
  if (m_delta < 0)
    m_delta = time;
  // Advance our timer
  m_curTime += m_delta;

  return false;
}
