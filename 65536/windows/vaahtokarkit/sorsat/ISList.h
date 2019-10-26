/* Intersection List */

#ifndef _ISList_h_
#define _ISList_h_

typedef struct
{
  float t;
  class Primitive *obj;
} IS;

typedef struct
{
  IS is1,is2;
  int used;
} ISPair;

class ISList
{
public:
  void init();
  void addISPair(float t1,class Primitive *o1,float t2,class Primitive *o2);
  void csgTest(ISList *csg,int csgtype);
  IS *getNearest();

  int total,max;
  ISPair *is;
};

#endif