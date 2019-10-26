/* Pointer List */

#ifndef _Ptrlist_h_
#define _Ptrlist_h_

class Ptrlist
{
public:
  void deinit();
  void init();
  void add(void *p);
  int fastRemove(int i); // Laittaa viimeisen poistettavan paikalle
  //int remove(int i); // Siirt‰‰ loppuosaa yhdell‰ alkuunp‰in
  int search(void *p);

  int total,max;
  void **pointers;
};

#endif
