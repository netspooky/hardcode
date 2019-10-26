#include "SafeAlloc.h"
#include "Error.h"
#include "Ptrlist.h"
#include <malloc.h>
#include <string.h>
#include <stdlib.h>

static int memoryinited=0;
static Ptrlist allocatedmemory;

void freeAllocatedMemory()
{
  for(int i=0;i<allocatedmemory.total;i++)
  {
    if(allocatedmemory.pointers[i]) free(allocatedmemory.pointers[i]);
  }
  memoryinited=0;
  allocatedmemory.deinit();
}

void *safeAlloc(int size)
{
  if(!memoryinited)
  {
    allocatedmemory.init();
    memoryinited=1;
    atexit(freeAllocatedMemory);
  }

  void *a=malloc(size);
  if(!a) error("Can't allocate memory :( (%d bytes)",size);

  unsigned char *aa = (unsigned char *)a;
  for(int i=0; i<size; i++) aa[i] = 0;

  allocatedmemory.add(a);
  return a;
}

void safeFree(void *ptr)
{
  if(!ptr || !memoryinited) return;

  for(int i=0;i<allocatedmemory.total;i++)
  {
    if(allocatedmemory.pointers[i] == ptr)
    {
      free(allocatedmemory.pointers[i]);
      allocatedmemory.pointers[i] = 0;
      return;
    }
  }
}
