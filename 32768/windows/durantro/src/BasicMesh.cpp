// -------------------------------------------------------------------------------------
// File:        BasicMesh.cpp
//
// Purpose:     
// -------------------------------------------------------------------------------------

#include "Base.h"
#include "BasicMesh.h"
#include "DisplayDevice.h"
#include <d3d8.h>

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------

// --------------------------------------------------------------------------
// Function:      Init
// Purpose:       Initialize the object
// Parameters:    
// --------------------------------------------------------------------------
TError CBasicMesh::Init  (CDisplayDevice *pDev, unsigned fvf, int nVerts, int nIdx, int stride)
{
  End();

  m_pIBuffer = NULL;
  m_pVBuffer = NULL;
  
  HRESULT hr;
  hr = pDev->GetDirect3DDevice()->CreateVertexBuffer(nVerts*stride, D3DUSAGE_WRITEONLY, fvf, D3DPOOL_MANAGED, &m_pVBuffer);
  if (!FAILED(hr))
    hr = pDev->GetDirect3DDevice()->CreateIndexBuffer(nIdx*sizeof(word), D3DUSAGE_WRITEONLY, D3DFMT_INDEX16, D3DPOOL_MANAGED, &m_pIBuffer);

  if (FAILED(hr))
  {
    End();
    return RET_FAIL;
  }
  m_nVerts = nVerts;
  m_nIdx = nIdx;
  m_stride = stride;
  m_fvf = fvf;

  return RET_OK;
}

// --------------------------------------------------------------------------
// Function:      End
// Purpose:       Release all resources and deinitialize the object
// Parameters:    
// --------------------------------------------------------------------------
void CBasicMesh::End  ()
{
  if (IsOk())
  {
    if (m_pVBuffer) m_pVBuffer->Release();
    if (m_pIBuffer) m_pIBuffer->Release();
    m_pVBuffer = NULL;
  }
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void *CBasicMesh::LockVB      (int start, int len)
{
  if (IsOk())
  {
    void *pv;
    if (!FAILED(m_pVBuffer->Lock(start*m_stride, (len > 0)? len*m_stride : 0, (BYTE**)&pv, 0)))//D3DLOCK_DISCARD)))
      return pv;
  }
  return NULL;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CBasicMesh::UnlockVB    ()
{
  if (IsOk())
    m_pVBuffer->Unlock();
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
word *CBasicMesh::LockIB      (int start, int len)
{
  if (IsOk())
  {
    word *pi;
    if (!FAILED(m_pIBuffer->Lock(start*sizeof(*pi), (len > 0)? len*sizeof(*pi) : 0, (BYTE**)&pi, 0)))//D3DLOCK_DISCARD)))
      return pi;
  }
  return NULL;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void CBasicMesh::UnlockIB    ()
{
  if (IsOk())
    m_pIBuffer->Unlock();
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
void  CBasicMesh::SetDraw     (CDisplayDevice *pDev, int starti) const
{
  if (IsOk())
  {
    pDev->SetFVFShader(m_fvf);
    pDev->GetDirect3DDevice()->SetStreamSource(0, m_pVBuffer, m_stride);
    pDev->GetDirect3DDevice()->SetIndices(m_pIBuffer, starti);
  }
}
