#include "Ptrlist.h"
#include "Error.h"

void Ptrlist::deinit()
{
  if(pointers) delete [] pointers;
}

void Ptrlist::init()
{
  pointers=0;
  total=0;
  max=0;
}

void Ptrlist::add(void *p)
{
  if(total>=max)
  {
    void **old=pointers;
	  pointers=new void *[max+16];
    if(!pointers) error("Can't allocate memory :(");
    for(int i=0;i<total;i++) pointers[i]=old[i];
	  if(old) delete [] old;
    max+=16;
  }
	pointers[total++]=p;
}

int Ptrlist::fastRemove(int i)
{
  if(i>=total || i<0) return 0;
  pointers[i] = pointers[total-1];
  total--;
  return 1;
}

/*
int Ptrlist::remove(int i)
{
  if(i>=total || i<0) return 0;
  for(int j=i; j<total-1; j++) pointers[j] = pointers[j+1];
  total--;
  return 1;
}
*/

int Ptrlist::search(void *p)
{
  for(int i=0; i<total; i++) if(pointers[i]==p) return i;
  return -1;
}
