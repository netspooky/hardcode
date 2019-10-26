#ifndef _SafeAlloc_h_
#define _SafeAlloc_h_

void freeAllocatedMemory();
void *safeAlloc(int size);
void safeFree(void *ptr);

#endif