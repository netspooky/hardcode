/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 *
 *   This file is part of
 *       ______        _                             __ __
 *      / ____/____   (_)____ _ ____ ___   ____ _   / // /
 *     / __/  / __ \ / // __ `// __ `__ \ / __ `/  / // /_
 *    / /___ / / / // // /_/ // / / / / // /_/ /  /__  __/
 *   /_____//_/ /_//_/ \__, //_/ /_/ /_/ \__,_/     /_/.   
 *                    /____/                              
 *
 *   Copyright © 2003-2012 Brain Control, all rights reserved.
 *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

#include "system.hpp"

void eArrayInit(ePtrArray *a, eU32 typeSize, eU32 size)
{
    eASSERT(typeSize > 0);

    a->m_data = nullptr;
    a->m_size = 0;
    a->m_capacity = 0;
    a->m_typeSize = typeSize;

    if (size > 0)
        eArrayResize(a, size);
}

void eArrayCopy(ePtrArray *a, const ePtrArray *ta)
{
    a->m_typeSize = ta->m_typeSize;
    eArrayReserve(a, ta->m_capacity);
    a->m_size = ta->m_size;

    if (ta->m_size)
        eMemCopy(a->m_data, ta->m_data, ta->m_size*ta->m_typeSize);
}

void eArrayClear(ePtrArray *a)
{
    a->m_size = 0;
}

void eArrayFree(ePtrArray *a)
{
    eFreeAligned(a->m_data);
    a->m_data = nullptr;
    a->m_size = 0;
    a->m_capacity = 0;
}

void eArrayReserve(ePtrArray *a, eU32 capacity)
{
    if (!capacity)
        eArrayClear(a);
    else if (a->m_capacity < capacity)
    {
        eU8 *temp = (eU8 *)eAllocAlignedAndZero(capacity*a->m_typeSize, 16);
        eASSERT(temp != nullptr);
        eU32 newSize = 0;

        if (a->m_data)
        {
            newSize = eMin(a->m_size, capacity);
            eMemCopy(temp, a->m_data, newSize*a->m_typeSize);
            eFreeAligned(a->m_data);
            a->m_data = nullptr;
        }

        a->m_data = (ePtr *)temp;
        a->m_size = newSize;
        a->m_capacity = capacity;
    }
}

void eArrayResize(ePtrArray *a, eU32 size)
{
    if (size > a->m_capacity)
        eArrayReserve(a, size);

    a->m_size = size;
}

ePtr eArrayAppend(ePtrArray *a)
{
    if (a->m_size >= a->m_capacity)
    {
        const eU32 newCapacity = (a->m_capacity > 0 ? a->m_capacity*2 : 32);
        eArrayReserve(a, newCapacity);
    }

    ePtr res = ((eU8 *)a->m_data)+a->m_size*a->m_typeSize;  
    a->m_size++;
    return res;
}

void eArrayInsert(ePtrArray *a, eU32 index, const ePtr data)
{
    eASSERT(index <= a->m_size);

    if (a->m_size >= a->m_capacity)
    {
        const eU32 newCapacity = (a->m_capacity > 0 ? a->m_capacity*2 : 32);
        eArrayReserve(a, newCapacity);
    }

    eMemMove(((eU8 *)a->m_data)+(index+1)*a->m_typeSize,
             ((eU8 *)a->m_data)+index*a->m_typeSize,
             (a->m_size-index)*a->m_typeSize);

    eMemCopy(((eU8 *)a->m_data)+index*a->m_typeSize, data, a->m_typeSize);
    a->m_size++;
}

void eArrayRemoveAt(ePtrArray *a, eU32 index)
{
    eASSERT(index < a->m_size);

    eMemMove(((eU8 *)a->m_data)+index*a->m_typeSize,
             ((eU8 *)a->m_data)+(index+1)*a->m_typeSize,
             (a->m_size-index-1)*a->m_typeSize);

    a->m_size--;
}

void eArrayRemoveSwap(ePtrArray *a, eU32 index)
{
    eASSERT(index < a->m_size);

    if (index < a->m_size-1)
    {
        eMemCopy(((eU8 *)a->m_data)+index*a->m_typeSize,
                 ((eU8 *)a->m_data)+(a->m_size-1)*a->m_typeSize,
                 a->m_typeSize);
    }
   
    a->m_size--;
}

eInt eArrayFind(const ePtrArray *a, const ePtr data)
{
    for (eU32 i=0, index=0; i<a->size(); i++, index+=a->m_typeSize)
        if (eMemEqual(((eU8 *)a->m_data)+index, data, a->m_typeSize))
            return i;

    return -1;
}

eBool eArrayEqual(const ePtrArray *a0, const ePtrArray *a1)
{
    if (a0->size() != a1->size())
        return eFALSE;
    else if (a0->m_size == 0) // => both empty because of first condition
        return eTRUE;
    else
        return eMemEqual(a0->m_data, a1->m_data, a0->size()*a0->m_typeSize);
}
