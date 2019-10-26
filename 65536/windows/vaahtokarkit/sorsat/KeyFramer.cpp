#include "KeyFramer.h"
#include "SafeAlloc.h"

void KeyFramer::init()
{
  keys.init();
}

Key *KeyFramer::addKey(float t,float v)
{
  Key *k = (Key *) safeAlloc(sizeof(Key));
  k->t = t;
  k->v = v;
  keys.add(k);
  return k;
}
/*
void KeyFramer::addKeys(KeyFramer *kf)
{
  for(int i=0; i<kf->keys.total; i++)
  {
    addKey(((Key *)kf->keys.pointers[i])->t,((Key *)kf->keys.pointers[i])->v);
  }
  sortKeys();
}
*/

#define SAFEGETKEY(k,i) \
if((i)<0) k = (Key *) keys.pointers[0]; \
else if((i)>=keys.total) k = (Key *) keys.pointers[keys.total-1]; \
else k = (Key *) keys.pointers[(i)];

float KeyFramer::getValue(float time)
{
  if(keys.total <= 0) return 0;
  if(keys.total == 1) return ((Key *)keys.pointers[0])->v;

  int i = 0;

  for(i=1; i<keys.total; i++)
  {
    if(((Key *)keys.pointers[i])->t > time) break;
  }

  if(i==0) return ((Key *)keys.pointers[0])->v;
  //if(i==keys.total) return ((Key *)keys.pointers[keys.total-1])->v;

  Key *v1,*v2,*v3,*v4;
  SAFEGETKEY(v1,i-2);
  SAFEGETKEY(v2,i-1);
  SAFEGETKEY(v3,i);
  SAFEGETKEY(v4,i+1);

  float l;
  if(v2->t-v3->t == 0) l = v2->v;
  else l = (v2->v-v3->v) / (v2->t-v3->t) * (time-v2->t) + v2->v;

  float t;
  if((v3->t-v2->t)==0) t = 0;
  else t = (time - v2->t) / (v3->t - v2->t);

  float t2 = t * t;
  float t3 = t2 * t;
  float k1 = 1 - 3 * t + 3 * t2 - t3;
  float k2 = 4 - 6 * t2 + 3 * t3;
  float k3 = 1 + 3 * t + 3 * t2 - 3 * t3;
  float s = (k1*v1->v + k2*v2->v + k3*v3->v + t3*v4->v) / 6.0f;

  return l*(1-spline) + s*spline;
}

// Pitäskö laittaa qsort =)
/*
void KeyFramer::sortKeys()
{
  for(int i=0; i<keys.total; i++)
  {
    for(int j=0; j<keys.total; j++)
    {
      if(((Key *)keys.pointers[i])->t < ((Key *)keys.pointers[j])->t)
      {
        void *t = keys.pointers[i];
        keys.pointers[i] = keys.pointers[j];
        keys.pointers[j] = t;
      }
    }
  }
}
*/