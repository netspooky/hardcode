// -------------------------------------------------------------------------------------
// File:        DETextWriter.h
//
// Purpose:     
// -------------------------------------------------------------------------------------

#ifndef _DETEXTWRITER_H_
#define _DETEXTWRITER_H_

#include "LinkedList.h"
#include "DemoEffect.h"

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

class CDETextWriter: public CDemoEffect
{
    typedef CDemoEffect inherited;
  public:
    CDETextWriter     ()                  { }
    ~CDETextWriter    ()                  { End(); }

    TError      Init        (CDisplayDevice *pDev);
    void        End         ();

    bool        Run         (int time);
    void        Draw        (CRenderContext &rc) const;

    struct  TPhrase;

  private:

    CLinkedList<TPhrase*>  m_Lista;
    int m_elapsed;
    int m_iFrase;
};

#endif // _DETEXTWRITER_H_
