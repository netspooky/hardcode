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

#ifndef ARRAY_HPP
#define ARRAY_HPP

template<class T> class eArray;
typedef eArray<ePtr> ePtrArray;
typedef eArray<eU8> eByteArray;

// non-templated functions used to avoid code
// bloat, caused by heavy template instantiation
void eArrayInit(ePtrArray *a, eU32 typeSize, eU32 size);
void eArrayCopy(ePtrArray *a, const ePtrArray *ta);
void eArrayClear(ePtrArray *a);
void eArrayFree(ePtrArray *a);
void eArrayReserve(ePtrArray *a, eU32 capacity);
void eArrayResize(ePtrArray *a, eU32 size);
ePtr eArrayAppend(ePtrArray *a);
void eArrayInsert(ePtrArray *a, eU32 index, const ePtr data);
void eArrayRemoveAt(ePtrArray *a, eU32 index);
void eArrayRemoveSwap(ePtrArray *a, eU32 index);
eInt eArrayFind(const ePtrArray *a, const ePtr data);
eBool eArrayEqual(const ePtrArray *a0, const ePtrArray *a1);

// performs insertion sort. not really fast,
// but already a lot faster than bubble sort
// and quite small, easy to implement and easy
// to get correct.
template<class T> void eSort(T *data, eU32 count, eBool (*predicate)(const T &a, const T &b))
{
    for (eU32 j=1; j<count; j++)
    {
        const T key = data[j]; // don't use a reference here!
        eInt i = (eInt)j-1;

        while (i >= 0 && predicate(data[i], key))
        {
            data[i+1] = data[i];
            i--;
        }

        data[i+1] = key;
    }
}

// templated dynamic array. this class is intro-safe,
// because all array functions which are duplicated
// during template instantiation are inlined, using
// non-templated functions. works for all kind of
// data types, not only pointers.
// one drawback is that object's (T) constructors
// aren't called when copying or instantiating array,
// same goes for destructors.
// all memory is for SIMD usage 16-byte aligned.
template<class T> class eArray
{
public:
    eFORCEINLINE eArray(eU32 size=0)
    {
        eArrayInit((ePtrArray *)this, sizeof(T), size);
    }

    eFORCEINLINE eArray(const eArray &a)
    {
        eArrayInit((ePtrArray *)this, sizeof(T), 0);
        eArrayCopy((ePtrArray *)this, (const ePtrArray *)&a);
    }

	eFORCEINLINE eArray(const eU8 *data, eU32 len)
	{
		eArrayInit((ePtrArray *)this, sizeof(eU8), len);
		eMemCopy(m_data, data, len);
	}

    eFORCEINLINE ~eArray()
    {
        free();
    }

    eFORCEINLINE eBool isEmpty() const
    {
        return (m_size == 0);
    }

    eFORCEINLINE void resize(eU32 size)
    {
        eArrayResize((ePtrArray *)this, size);
    }

    eFORCEINLINE void reserve(eU32 capacity)
    {
        eArrayReserve((ePtrArray *)this, capacity);
    }

    eFORCEINLINE void clear()
    {
        eArrayClear((ePtrArray *)this);
    }

    eFORCEINLINE void free()
    {
        eArrayFree((ePtrArray *)this);
    }

    eFORCEINLINE T & append(const T &data)
    {
        *(T *)eArrayAppend((ePtrArray *)this) = data;
        return last();
    }

    // only appends item if no element with
    // the same value exists in array
    eFORCEINLINE T & appendUnique(const T &data)
    {
        const eInt index = find(data);
        return (index != -1 ? m_data[index] : append(data));
    }

    eFORCEINLINE T & append()
    {
        append(T());
        return last();
    }

    eFORCEINLINE void append(const eArray &a)
    {
        for (eU32 i=0; i<a.size(); i++)
            append(a[i]);
    }

    eFORCEINLINE T & push(const T &data)
    {
        return append(data);
    }

    eFORCEINLINE T & push()
    {
        return append();
    }

    eFORCEINLINE T pop()
    {
        T data = last();
        removeLast();
        return data;
    }

    eFORCEINLINE void insert(eU32 index, const T &data)
    {
        eArrayInsert((ePtrArray *)this, index, (ePtr *)&data);
    }

    eFORCEINLINE void removeAt(eU32 index)
    {
        eArrayRemoveAt((ePtrArray *)this, index);
    }

    eFORCEINLINE void removeSwap(eU32 index)
    {
        eArrayRemoveSwap((ePtrArray *)this, index);
    }

    eFORCEINLINE void removeLast()
    {
        m_size--;
    }

    eFORCEINLINE eInt find(const T &data) const
    {
        return eArrayFind((ePtrArray *)this, (ePtr *)&data);
    }

    eFORCEINLINE eBool contains(const T &data) const
    {
        return (find(data) != -1);
    }

    eFORCEINLINE eU32 size() const
    {
        return m_size;
    }

    eFORCEINLINE eU32 capacity() const
    {
        return m_capacity;
    }

    eFORCEINLINE T & last()
    {
        eASSERT(m_size > 0);
        return m_data[m_size-1];
    }

    eFORCEINLINE const T & last() const
    {
        eASSERT(m_size > 0);
        return m_data[m_size-1];
    }

    eFORCEINLINE T & first()
    {
        eASSERT(m_size > 0);
        return m_data[0];
    }

    eFORCEINLINE const T & first() const
    {
        eASSERT(m_size > 0);
        return m_data[0];
    }

    eFORCEINLINE void sort(eBool (*predicate)(const T &a, const T &b))
    {
        eSort(m_data, m_size, predicate);
    }

    eFORCEINLINE eArray & operator = (const eArray &a)
    {
        if (this != &a)
            eArrayCopy((ePtrArray *)this, (const ePtrArray *)&a);

        return *this;
    }

    eFORCEINLINE T & operator [] (eInt index)
    {
        eASSERT(index >= 0 && (eU32)index < m_size);
        return m_data[index];
    }

    eFORCEINLINE const T & operator [] (eInt index) const
    {
        eASSERT(index >= 0 && (eU32)index < m_size);
        return m_data[index];
    }

    eFORCEINLINE eBool operator == (const eArray &a) const
    {
        return eArrayEqual((const ePtrArray *)this, (const ePtrArray *)&a);
    }

    eFORCEINLINE eBool operator != (const eArray &a) const
    {
        return !(*this == a);
    }

public:
    T *     m_data;
    eU32    m_size;
    eU32    m_capacity;
    eU32    m_typeSize;
};

#endif // ARRAY_HPP