#ifndef __CONNECT_H__
#define __CONNECT_H__

#include "syn_types.h"
#include "constant.h"

// connect port srcport of src to input dstport of dst
void conn(void *src, int srcport, void *dst, int dstport)
{
    block *dstb = (block *)dst;
    block *srcb = (block *)src;
    dstb->in.sources[dstport] = &(srcb->out.outs[srcport]);
}

// connect a constant to dstport
void constant(float value, void *dst, int dstport)
{
    Constant *c = new_constant(value);
    conn(c, 0, dst, dstport);
}

#endif 
