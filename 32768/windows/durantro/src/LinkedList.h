//----------------------------------------------------------------------------
//  Nombre:    LinkedList.h
//
//  Contenido: Template de lista enlazada
//----------------------------------------------------------------------------


#ifndef _LINKED_LIST_H_
#define _LINKED_LIST_H_

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
template<class T> struct TLinkedListNode
{
  TLinkedListNode  *pNext, *pPrev;
  T                 t;

  TLinkedListNode(const T &_t): t(_t) { }

  const T &GetData() const  { return t; }
        T &GetData()        { return t; }
};

// --------------------------------------------------------------------------
// --------------------------------------------------------------------------
template<class T> class CLinkedList
{
  public:

    CLinkedList   (): m_pHead(NULL), m_pTail(NULL), m_nNodes(0) { }
    ~CLinkedList  ()                                            { End(); }

    void    Init  ()                                  { End(); }
    void    End   ();

    unsigned  GetCount  () const                      { return m_nNodes; }
    bool      IsEmpty   () const                      { return m_nNodes == 0; }

    TLinkedListNode<T>  *GetHead () const             { return m_pHead; }
    TLinkedListNode<T>  *GetTail () const             { return m_pTail; }

    void    AddFirst  (const T& t);
    void    AddEnd    (const T& t);
    void    Add       (const T& t)                    { AddFirst(t); }
    bool    Remove    (const T& t);
    void    Remove    (TLinkedListNode<T> *pNode);
    void    RemoveAll ()                              { End(); }
    void    DeleteAll ();                                               // T must be a dynamically allocated pointer.

    bool                IsIn      (const T& t) const  { return FindNode(t) != NULL; }
    TLinkedListNode<T>  *FindNode (const T& t) const;

  private:

    // Prohibo usarlo.
    CLinkedList<T> &operator = (const CLinkedList<T> &) { }

    TLinkedListNode<T>  *m_pHead;
    TLinkedListNode<T>  *m_pTail;
    unsigned            m_nNodes;
};

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
template<class T> void CLinkedList<T>::End()
{
  TLinkedListNode<T> *pNode = m_pHead;
  while (pNode != NULL)
  {
    TLinkedListNode<T> *pNext = pNode->pNext;
    delete pNode;
    pNode = pNext;
  }
  m_pHead = NULL;
  m_pTail = NULL;
  m_nNodes = 0;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
template<class T> void CLinkedList<T>::AddFirst(const T& t)
{
  TLinkedListNode<T> *pNode = NEW(TLinkedListNode<T>(t));

  if (m_pHead == NULL)
  {
    m_pHead = m_pTail = pNode;
    pNode->pNext = NULL;
  }
  else
  {
    pNode->pNext = m_pHead;
    m_pHead->pPrev = pNode;
    m_pHead = pNode;
  }
  pNode->pPrev = NULL;
  m_nNodes++;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
template<class T> void CLinkedList<T>::AddEnd(const T& t)
{
  TLinkedListNode<T> *pNode = NEW(TLinkedListNode<T>(t));

  if (m_pTail == NULL)
  {
    m_pHead = m_pTail = pNode;
    pNode->pPrev = NULL;
  }
  else
  {
    pNode->pPrev = m_pTail;
    m_pTail->pNext = pNode;
    m_pTail = pNode;
  }
  pNode->pNext = NULL;
  m_nNodes++;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
template<class T> bool CLinkedList<T>::Remove(const T& t)
{
  TLinkedListNode<T> *pNode = FindNode(t);
  if (pNode != NULL)
    Remove(pNode);
  return pNode != NULL;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
template<class T> void CLinkedList<T>::Remove(TLinkedListNode<T> *pNode)
{
  if (pNode->pPrev == NULL)     m_pHead = pNode->pNext;
  else                          pNode->pPrev->pNext = pNode->pNext;
  if (pNode->pNext == NULL)     m_pTail = pNode->pPrev;
  else                          pNode->pNext->pPrev = pNode->pPrev;
  delete pNode;
  m_nNodes--;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
template<class T> void CLinkedList<T>::DeleteAll()
{
  TLinkedListNode<T> *pNode = m_pHead;
  while (pNode != NULL)
  {
    TLinkedListNode<T> *pNext = pNode->pNext;
    delete pNode->t;
    delete pNode;
    pNode = pNext;
  }
  m_pHead = NULL;
  m_pTail = NULL;
  m_nNodes = 0;
}

// --------------------------------------------------------------------------
// Function:      
// Purpose:       
// Parameters:    
// --------------------------------------------------------------------------
template<class T> TLinkedListNode<T> *CLinkedList<T>::FindNode(const T& t) const
{
  TLinkedListNode<T> *pNode = m_pHead;
  while (pNode != NULL && pNode->t != t)
  {
    pNode = pNode->pNext;
  }
  return pNode;
}

#endif // _LINKED_LIST_H_
