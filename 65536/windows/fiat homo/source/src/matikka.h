#ifndef _MATIKKA_H_
#define _MATIKKA_H_

#include "vector.hpp"

//satunnaisluvut.. 
float randFloat();
int randInt();
void setSeed(int seed);

#define RAND_INT(l,h) (((int)(randFloat() * ((float)(h)-(l)+1))) + (l))


//kaivetaan projektiomatriisista tavarat, että voidaan piirtää billboardit
void antiRotate(Vector *x, Vector *y, Vector *z);

float catmullromValue(float t, float p1, float p2, float p3, float p4);

//vektorin lineaarinen interpolaatio, t=0 palauttaa v1, t=1 palauttaa v2
Vector lerpVector(Vector v1, Vector v2, float t);

//pallokoordinaatistomuunnos
//radius = [0..ääretön], phi = [0..pii], theta = [0..2*pii]
Vector sphereCoord(float radius, float phi, float theta);


#endif
