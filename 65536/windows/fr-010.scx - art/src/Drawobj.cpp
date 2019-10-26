#include "DrawObj.h"

#ifndef mySwapX 
#define mySwap(_x, _y, _temp) _temp = _x; _x = _y; _y = _temp
#endif


void FaceList::clear()
{
	count=0;
    scratchCount=0;
}

void LineList::clear()
{
	count=0;
    scratchCount=0;
}

void LineList::draw(CDrawing* pD)
{
  int i;
  for (i=0;i<count;i++)
  {
    if (dl[i]->visible)
  	  pD->DrawLine(Vector(dl[i]->x1,dl[i]->y1,dl[i]->z1), Vector(dl[i]->x2,dl[i]->y2,dl[i]->z2));
  }
}

void FaceList::draw(CDrawing* pD)
{
  int i;
  for (i=0;i<count;i++)
  {
    //pD->col=i*311;
    if (dl[i]->visible)
      pD->drawFace(dl[i]);
  }


}


DrawLineObjPtr LineList::add(Vector *v1,Vector *v2)
{
  DrawLineObjPtr l;
  l=&(scratchLines[scratchCount++]);
  l->visible=TRUE;
  l->x1=v1->x;
  l->y1=v1->y;
  l->z1=v1->z;
  l->x2=v2->x;
  l->y2=v2->y;
  l->z2=v2->z;
  dl[count++]=l;  
  return l;
}

void FaceList::add(Vertex* pVert,Face *face)
{

  DrawFaceObjPtr f;
  f=&(scratchFaces[scratchCount]);
  f->visible=TRUE;
  f->x1=pVert[face->pIndex[0]].ws.x;
  f->y1=pVert[face->pIndex[0]].ws.y;
  f->z1=pVert[face->pIndex[0]].ws.z;
  f->x2=pVert[face->pIndex[1]].ws.x;
  f->y2=pVert[face->pIndex[1]].ws.y;
  f->z2=pVert[face->pIndex[1]].ws.z;
  f->x3=pVert[face->pIndex[2]].ws.x;
  f->y3=pVert[face->pIndex[2]].ws.y;
  f->z3=pVert[face->pIndex[2]].ws.z;
  f->u1=(float)face->tc[0].u;
  f->v1=(float)face->tc[0].v;
  f->u2=(float)face->tc[1].u;
  f->v2=(float)face->tc[1].v;
  f->u3=(float)face->tc[2].u;
  f->v3=(float)face->tc[2].v;
  f->col = face->col;
  f->texnum = (face->texnum+::texnum) & 63;

  f->lcount=0;
  scratchCount++;
  dl[count++]=f;
  face->theDrawFace=f;  

}



void LineList::doClip(FaceList *fl) {
  //now do the z_clipping
  DrawLineObjPtr l,l1;
  double x1,x2,y1,y2,z1,z2;
  double fakt,neu,skal,tmp;
  int t,faceCount,c,d_last,d_akt,d_anf,s,i;
  char visible;
  
  if (count<1) return;

  s=0;
  faceCount=count;
  d_last=count;
  //clip Z
  d_anf=0;
  d_akt=d_anf;
  
  l=dl[d_akt];
  
  for (t=faceCount;t>0;t--)
  {
    if (faceCount>1) l=dl[d_akt];
    if (l->visible==TRUE)
    {
      if (l->z1 < NEAR_Z)
      {
        if (l->z2< NEAR_Z)
        {
          //all points are outside!!
          l->visible=FALSE;
        }
        else
        {
          //point 0 is outside            
          fakt=(NEAR_Z - l->z1)/(l->z1- l->z2);
          l->x1+=(l->x1- l->x2)*fakt;
          l->y1+=(l->y1- l->y2)*fakt;
          l->z1=NEAR_Z;                     
        }
      }
      else
      {
        if (l->z2 < NEAR_Z)
        {
          // points 1 is outside
          fakt=(NEAR_Z - l->z2)/(l->z2- l->z1);
          l->x2+=(l->x2- l->x1)*fakt;
          l->y2+=(l->y2- l->y1)*fakt;
          l->z2=NEAR_Z;
        }         
        else
        {
          //all points are inside
          //nothing to do :)
        }
      }
    }
    d_akt++;
  }
  d_akt=d_anf;
  for (t=faceCount;t>0;t--)
  {
    if (faceCount>1) l=dl[d_akt];
    if (l->visible==TRUE)
    {
      if (l->z1 > FAR_Z)
      {
        if (l->z2 > FAR_Z)
        {
          //all points are outside!!
          l->visible=FALSE;
        }
        else
        {
          //points 0 is outside
          fakt=(FAR_Z - l->z1)/(l->z1- l->z2);
          l->x1+=(l->x1- l->x2)*fakt;
          l->y1+=(l->y1- l->y2)*fakt;
          l->z1=FAR_Z;
        }
      }
      else
      {
        if (l->z2 > FAR_Z)
        {
          //point 1 is outside
          fakt=(FAR_Z - l->z2)/(l->z2- l->z1);
          l->x2+=(l->x2- l->x1)*fakt;
          l->y2+=(l->y2- l->y1)*fakt;
          l->z2=FAR_Z;
        }
        else
        {
          //all points are inside
          //nothing to do :)
        }
      }
    }
    d_akt++;
  }
   
  //clip X
  d_akt=d_anf;
  for (t=faceCount;t>0;t--)
  {
    if (faceCount>1) l=dl[d_akt];
    if (l->visible==TRUE)
    {
      if (l->x1 < -l->z1)
      {
        if (l->x2 < -l->z2)
        {
          //all points are outside!!
          l->visible=FALSE;
        }
        else
        {
          //point 0 is outside
          fakt=(l->z2 - l->z1);
          skal=(-l->z1-l->x1)/(l->x2-l->x1+fakt);
          neu=skal*fakt;
          l->y1+=(l->y2- l->y1)*skal;
          l->z1+=neu;
          l->x1=-l->z1;
        }
      }
      else
      {
        if (l->x2 < -l->z2)
        {
          // point 1 is outside
          fakt=(l->z1 - l->z2);
          skal=(-l->z2-l->x2)/(l->x1-l->x2+fakt);
          neu=skal*fakt;
          l->y2+=(l->y1- l->y2)*skal;
          l->z2+=neu;
          l->x2=-l->z2;
        }
        else
        {
          //all points are inside
          //nothing to do :)
        }
      }
    }
    d_akt++;
  }
  d_akt=d_anf;
  for (t=faceCount;t>0;t--)
  {
    if (faceCount>1) l=dl[d_akt];
    if (l->visible==TRUE)
    {
      if (l->x1 > l->z1)
      {
        if (l->x2 > l->z2)
        {
          //all points are outside!!
          l->visible=FALSE;
        }
        else
        {
          //points 0 is outside
          fakt=(l->z2 - l->z1);
          skal=(l->z1-l->x1)/(l->x2-l->x1-fakt);
          neu=skal*fakt;
          l->y1+=(l->y2- l->y1)*skal;
          l->z1+=neu;
          l->x1=l->z1;
        }
      }
      else
      {
        if (l->x2 > l->z2)
        {
          // points 1 is outside
          fakt=(l->z1 - l->z2);
          skal=(l->z2-l->x2)/(l->x1-l->x2-fakt);
          neu=skal*fakt;
          l->y2+=(l->y1- l->y2)*skal;
          l->z2+=neu;
          l->x2=l->z2;
        }
        else
        {
          //all points are inside
          //nothing to do :)
        }
      }
    }
    d_akt++;
  }
  
  //clip Y
  d_akt=d_anf;
  for (t=faceCount;t>0;t--)
  {
    if (faceCount>1) l=dl[d_akt];
    if (l->visible==TRUE)
    {
      if (l->y1 < -l->z1)
      {
        if (l->y2 < -l->z2)
        {
          //all points are outside!!
          l->visible=FALSE;
        }
        else
        {
          //points 0 is outside
          fakt=(l->z2 - l->z1);
          skal=(-l->z1-l->y1)/(l->y2-l->y1+fakt);
          neu=fakt*skal;
          l->x1+=(l->x2- l->x1)*skal;
          l->z1+=neu;
          l->y1=-l->z1;
        }
      }
      else
      {
        if (l->y2 < -l->z2)
        {
          // points 1 is outside
          fakt=(l->z1 - l->z2);
          skal=(-l->z2-l->y2)/(l->y1-l->y2+fakt);
          neu=fakt*skal;
          l->x2+=(l->x1- l->x2)*skal;
          l->z2+=neu;
          l->y2=-l->z2;
        }
        else
        {
          //all points are inside
          //nothing to do :)
        }
      }
    }
    d_akt++;
  }
  d_akt=d_anf;
  for (t=faceCount;t>0;t--)
  {
    if (faceCount>1) l=dl[d_akt];
    if (l->visible==TRUE)
    {
      if (l->y1 > l->z1)
      {
        if (l->y2 > l->z2)
        {
          //all points are outside!!
          l->visible=FALSE;
        }
        else
        {
          //points 0 is outside
          fakt=(l->z2 - l->z1);
          skal=(l->z1-l->y1)/(l->y2-l->y1-fakt);
          neu=fakt*skal;
          l->x1+=(l->x2- l->x1)*skal;
          l->z1+=neu;
          l->y1=l->z1;
        }
      }
      else
      {
        if (l->y2 > l->z2)
        {
          // points 1 is outside
          fakt=(l->z1 - l->z2);
          skal=(l->z2-l->y2)/(l->y1-l->y2-fakt);
          neu=fakt*skal;
          l->x2+=(l->x1- l->x2)*skal;
          l->z2+=neu;
          l->y2=l->z2;
        }
        else
        {
          //all points are inside
          //nothing to do :)
        }
      }
    }
    d_akt++;
  }
	
  //last remove all not visible
  visible=TRUE;
  d_akt=d_anf;
  c=0;
  
  for (t=0;t<count;t++)
  {
    if (count>1) l=dl[d_akt];
    if (l->visible==TRUE)
    {
      
      if (l->z1>l->z2)
      {
        l->maxZ=l->z1;
        l->minZ=l->z2;
      } else {
        l->maxZ=l->z2;
        l->minZ=l->z1;
      }
      z1 = 1 / l->z1;
      z2 = 1 / l->z2;
      x1 = ((l->x1)*z1);
      y1 = ((l->y1)*z1);
      x2 = ((l->x2)*z2);
      y2 = ((l->y2)*z2);
      
      l->x1=(320.0+319.0*x1);
      l->y1=(240.0+239.0*y1);
      l->x2=(320.0+319.0*x2);
      l->y2=(240.0+239.0*y2);
      
      c++;
      if (d_akt!=d_anf)
      {
        dl[d_anf]=l;
      }
      d_anf++;
    }
    d_akt++;
  }
  count=d_anf;
  
  DrawFaceObjPtr f;
  double x3x1,y2y1,y3y1,x2x1,y4y3,x4x3;
  double q1,q2,q3;
  double b1,b2,b3,b0,a1,a2,a3;
  int ins1,ins2;
  int bo;
  int clipperfect=0;
  
  while (!clipperfect)
  {
    clipperfect=1;
    
    for (c=fl->count-1;c>=0;c--)
    {
      f=fl->dl[c];
      if (f->visible==TRUE)
      { 
        s=count;
        for (t=0;t<s;t++)
        {
          l=dl[t];       

          if ((l->visible==TRUE) && (l->maxZ > f->minZ))
          {   
            bo=TRUE;
		        if ((l->x1<f->minx) && (l->x2<f->minx)) bo=FALSE;
		        if ((l->x1>f->maxx) && (l->x2>f->maxx)) bo=FALSE;
		        if ((l->y1<f->miny) && (l->y2<f->miny)) bo=FALSE;
		        if ((l->y1>f->maxy) && (l->y2>f->maxy)) bo=FALSE;

            i=0;          
            while ((i<f->lcount) && (bo))
            {
              bo=(f->l[i++]!=l);
            }

            const double eps=1e-5; // ilon (i hate precision problems, especially of THAT scale)
            const double imeps=1.0-eps;

            if (bo)
            {
              b0=1.0/(((f->x2-f->x1)*(f->y3-f->y1))-((f->x3-f->x1)*(f->y2-f->y1)));
              b1= ((((f->x2-l->x1)*(f->y3-l->y1))-((f->x3-l->x1)*(f->y2-l->y1)))) * b0 ;
              b2= ((((f->x3-l->x1)*(f->y1-l->y1))-((f->x1-l->x1)*(f->y3-l->y1)))) * b0 ;
              b3= ((((f->x1-l->x1)*(f->y2-l->y1))-((f->x2-l->x1)*(f->y1-l->y1)))) * b0 ;
              ins1= ((b1>-eps) && (b2>-eps) && (b3>-eps));
            
              b1= ((((f->x2-l->x2)*(f->y3-l->y2))-((f->x3-l->x2)*(f->y2-l->y2)))) * b0 ;
              b2= ((((f->x3-l->x2)*(f->y1-l->y2))-((f->x1-l->x2)*(f->y3-l->y2)))) * b0 ;
              b3= ((((f->x1-l->x2)*(f->y2-l->y2))-((f->x2-l->x2)*(f->y1-l->y2)))) * b0 ;
              ins2= ((b1>-eps) && (b2>-eps) && (b3>-eps));
            
              y4y3=l->y2-l->y1;
              x2x1=f->x2-f->x1;
              y2y1=f->y2-f->y1;
              x4x3=l->x2-l->x1;
              q1=(y4y3*x2x1)-(x4x3*y2y1);
              if ((q1!=0.0f) && ((x2x1!=0.0f) || (y2y1!=0.0f))) {
                y3y1=l->y1-f->y1;
                x3x1=l->x1-f->x1;
                b1=((x3x1*y2y1)-(y3y1*x2x1))/q1;
              
                if (x2x1!=0)
                  a1=((x3x1+(b1*x4x3)))/x2x1;
                else
                  a1=((y3y1+(b1*y4y3)))/y2y1;

                if ((a1<eps) || (a1>imeps))
                  b1=-1;
              }
              else 
              {
                b1=-1;
              }
            
              y4y3=l->y2-l->y1;
              x2x1=f->x3-f->x2;
              y2y1=f->y3-f->y2;
              x4x3=l->x2-l->x1;
              q2=(y4y3*x2x1)-(x4x3*y2y1);
              if ((q2!=0) && ((x2x1!=0) || (y2y1!=0))) {
                y3y1=l->y1-f->y2;
                x3x1=l->x1-f->x2;
                b2=((x3x1*y2y1)-(y3y1*x2x1))/q2;
                if (x2x1!=0)
                  a2=((x3x1+(b2*x4x3)))/x2x1;
                else
                  a2=((y3y1+(b2*y4y3)))/y2y1;

                if ((a2<eps) || (a2>imeps))
                  b2=-1;
              }
              else 
              {
                b2=-1;
              }
            
              y4y3=l->y2-l->y1;
              x2x1=f->x1-f->x3;
              y2y1=f->y1-f->y3;
              x4x3=l->x2-l->x1;
              q3=(y4y3*x2x1)-(x4x3*y2y1);
              if ((q3!=0) && ((x2x1!=0) || (y2y1!=0))) {
                y3y1=l->y1-f->y3;
                x3x1=l->x1-f->x3;
                b3=((x3x1*y2y1)-(y3y1*x2x1))/q3;
                if (x2x1!=0)
                  a3=((x3x1+(b3*x4x3)))/x2x1;
                else
                  a3=((y3y1+(b3*y4y3)))/y2y1;

                if ((a3<eps) || (a3>imeps))
                  b3=-1;
              }
              else 
              {
                b3=-1;
              }          
            
              int bo1=1,bo2=1,bo3=1;
              if (b1<eps || b1>imeps) bo1=0;
              if (b2<eps || b2>imeps) bo2=0;
              if (b3<eps || b3>imeps) bo3=0;
            
              int bo=TRUE;
              if (ins1) 
              {
                if (ins2)
                {
                  //line is complete behind the face...
                  l->visible=FALSE;
                  bo=FALSE;
                } 
                else
                {
                  if (bo1 && !bo2 && !bo3)
                  {
                    l->x1=l->x1+b1*(l->x2-l->x1);
                    l->y1=l->y1+b1*(l->y2-l->y1);
                    bo=FALSE;
                  } 
                  else if (bo2 && !bo1 && !bo3)
                  {
                    l->x1=l->x1+b2*(l->x2-l->x1);
                    l->y1=l->y1+b2*(l->y2-l->y1);
                    bo=FALSE;
                  }
                  else if (bo3 && !bo1 && !bo2)
                  {
                    l->x1=l->x1+b3*(l->x2-l->x1);
                    l->y1=l->y1+b3*(l->y2-l->y1);
                    bo=FALSE;
                  }
                }
              }
              else
              {
                if (ins2)
                {
                  if (bo1 && !bo2 && !bo3)
                  {
                    l->x2=l->x1+b1*(l->x2-l->x1);
                    l->y2=l->y1+b1*(l->y2-l->y1);
                    bo=FALSE;
                  } 
                  else if (bo2 && !bo1 && !bo3)
                  {
                    l->x2=l->x1+b2*(l->x2-l->x1);
                    l->y2=l->y1+b2*(l->y2-l->y1);
                    bo=FALSE;
                  }
                  else if (bo3 && !bo1 && !bo2)
                  {
                    l->x2=l->x1+b3*(l->x2-l->x1);
                    l->y2=l->y1+b3*(l->y2-l->y1);
                    bo=FALSE;
                  }
                } 
                else
                {
                  if (bo1 && bo2 && !bo3)
                  {
                    //split line, between 1 and 2
                    l1=&(scratchLines[scratchCount++]);
                    if (b2<b1) 
                    {
                      mySwap(b1,b2,tmp);
                    }
                    l1->minZ=l->minZ;
                    l1->maxZ=l->maxZ;
                    l1->visible=TRUE;
                    l1->x2=l->x2;
                    l1->y2=l->y2;
                    l1->x1=l->x1+b2*(l->x2-l->x1);
                    l1->y1=l->y1+b2*(l->y2-l->y1);
                    l->x2 =l->x1+b1*(l->x2-l->x1);
                    l->y2 =l->y1+b1*(l->y2-l->y1);
                    dl[count++]=l1;
                    bo=FALSE;
                  }
                  else if (bo1 && bo3 && !bo2)
                  {
                    //split line, between 1 and 3
                    l1=&(scratchLines[scratchCount++]);
                    if (b3<b1) 
                    {
                      mySwap(b1,b3,tmp);
                    }
                    l1->minZ=l->minZ;
                    l1->maxZ=l->maxZ;
                    l1->visible=TRUE;
                    l1->x2=l->x2;
                    l1->y2=l->y2;
                    l1->x1=l->x1+b3*(l->x2-l->x1);
                    l1->y1=l->y1+b3*(l->y2-l->y1);
                    l->x2=l->x1+b1*(l->x2-l->x1);
                    l->y2=l->y1+b1*(l->y2-l->y1);
                    dl[count++]=l1;
                    bo=FALSE;
                  }
                  else if (bo2 && bo3 && !bo1)
                  {
                    //split line, between 2 and 3
                    l1=&(scratchLines[scratchCount++]);
                    if (b3<b2) 
                    {
                      mySwap(b2,b3,tmp);
                    }
                    l1->minZ=l->minZ;
                    l1->maxZ=l->maxZ;
                    l1->visible=TRUE;
                    l1->x2=l->x2;
                    l1->y2=l->y2;
                    l1->x1=l->x1+b3*(l->x2-l->x1);
                    l1->y1=l->y1+b3*(l->y2-l->y1);
                    l->x2=l->x1+b2*(l->x2-l->x1);
                    l->y2=l->y1+b2*(l->y2-l->y1);
                    dl[count++]=l1;
                    bo=FALSE;
                  } 
                }
              }                       
            }           
          }
        }
      }
    }
  }
}



void FaceList::sortmax(DrawFaceObjPtr *l,DrawFaceObjPtr *r,DrawFaceObjPtr *b,DrawFaceObjPtr *e)
{
  DrawFaceObjPtr x,tmp;
  DrawFaceObjPtr *i,*j;
  double xz;

  if (l<r)
  {
    x=*l;
    xz=x->maxZ;
    i=l;
    j=r+1;
    while (i<j)
    {
      i++;j--;
      while ( ((*i)->maxZ>xz) && (i<e)) i++;
      while ( ((*j)->maxZ<xz) && (j>b)) j--;
      if (i<j)
      {
        tmp=*j;
        (*j)=(*i);
        (*i)=tmp;
      }
    }
    (*l)=(*j);
    (*j)=x;
    sortmax(l,j-1,b,e);
    sortmax(j+1,r,b,e);
  }

}

void FaceList::sortmin(DrawFaceObjPtr *l,DrawFaceObjPtr *r,DrawFaceObjPtr *b,DrawFaceObjPtr *e)
{
  DrawFaceObjPtr x,tmp;
  DrawFaceObjPtr *i,*j;
  double xz;

  if (l<r)
  {
    x=*l;
    xz=x->minZ;
    i=l;
    j=r+1;
    while (i<j)
    {
      i++;j--;
      while ( ((*i)->minZ>xz) && (i<e)) i++;
      while ( ((*j)->minZ<xz) && (j>b)) j--;
      if (i<j)
      {
        tmp=*j;
        (*j)=(*i);
        (*i)=tmp;
      }
    }
    (*l)=(*j);
    (*j)=x;
    sortmin(l,j-1,b,e);
    sortmin(j+1,r,b,e);
  }

}

void FaceList::doClip(int mz)
{
//now do the z_clipping
  DrawFaceObjPtr f,f1;
  double x1,x2,x3,y1,y2,y3,z1,z2,z3;
  double fakt,neu,skal;
  int t,c,d_akt,d_anf,s;
  char visible;
  
  if (count<1) return;


  s=0;
  //clip Z
  d_anf=0;
  d_akt=d_anf;

  f=dl[d_akt];

  for (t=count;t>0;t--)
  {
    if (count>1)
      f=dl[d_akt];

    f->visible=1;
    
    if (f->visible==TRUE)
    {
      if (f->z1 < NEAR_Z)
      {
        if (f->z2 < NEAR_Z)
        {
          if (f->z3 < NEAR_Z)
          {
            //all points are outside!!
            f->visible=FALSE;
          }
          else
          {
            //points 0 & 1 are outside
            fakt=(NEAR_Z -f->z1)/(f->z1- f->z3);
            f->x1+=(f->x1- f->x3)*fakt;
            f->y1+=(f->y1- f->y3)*fakt;
            f->z1=NEAR_Z;
            f->u1+=(f->u1- f->u3)*fakt;
            f->v1+=(f->v1- f->v3)*fakt;
            fakt=(NEAR_Z - f->z2)/(f->z2- f->z3);
            f->x2+=(f->x2- f->x3)*fakt;
            f->y2+=(f->y2- f->y3)*fakt;
            f->z2=NEAR_Z;
            f->u2+=(f->u2- f->u3)*fakt;
            f->v2+=(f->v2- f->v3)*fakt;
          }
        }
        else
        {
          if (f->z3 < NEAR_Z)
          {
            // points 0 & 2 are outside
            fakt=(NEAR_Z - f->z1)/(f->z1- f->z2);
            f->x1+=(f->x1- f->x2)*fakt;
            f->y1+=(f->y1- f->y2)*fakt;
            f->z1=NEAR_Z;
            f->u1+=(f->u1- f->u2)*fakt;
            f->v1+=(f->v1- f->v2)*fakt;
            fakt=(NEAR_Z - f->z3)/(f->z3- f->z2);
            f->x3+=(f->x3- f->x2)*fakt;
            f->y3+=(f->y3- f->y2)*fakt;
            f->z3=NEAR_Z;
            f->u3+=(f->u3- f->u2)*fakt;
            f->v3+=(f->v3- f->v2)*fakt;
          }
          else
          {
            //point 0 is outside
            f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            fakt=(f1->z1-NEAR_Z)/(f1->z1- f1->z2);
            f1->x1+=(f1->x2- f1->x1)*fakt;
            f1->y1+=(f1->y2- f1->y1)*fakt;
            f1->z1=NEAR_Z;
            f1->u1+=(f1->u2- f1->u1)*fakt;
            f1->v1+=(f1->v2- f1->v1)*fakt;
            f1->x3=f->x1;
            f1->y3=f->y1;
            f1->z3=NEAR_Z;
            f1->u3=f->u1;
            f1->v3=f->v1;
            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            //f->visible=FALSE;
            fakt=(f->z1-NEAR_Z)/(f->z1- f->z3);
            f->x1+=(f->x3- f->x1)*fakt;
            f->y1+=(f->y3- f->y1)*fakt;
            f->z1=NEAR_Z;
            f->u1+=(f->u3- f->u1)*fakt;
            f->v1+=(f->v3- f->v1)*fakt;

          }
        }
      }
      else
      {
        if (f->z2 < NEAR_Z)
        {
          if (f->z3 < NEAR_Z)
          {
            //point 1 & 2 are outside
            fakt=(NEAR_Z - f->z2)/(f->z2- f->z1);
            f->x2+=(f->x2- f->x1)*fakt;
            f->y2+=(f->y2- f->y1)*fakt;
            f->z2=NEAR_Z;
            f->u2+=(f->u2- f->u1)*fakt;
            f->v2+=(f->v2- f->v1)*fakt;
            fakt=(NEAR_Z - f->z3)/(f->z3- f->z1);
            f->x3+=(f->x3- f->x1)*fakt;
            f->y3+=(f->y3- f->y1)*fakt;
            f->z3=NEAR_Z;
            f->u3+=(f->u3- f->u1)*fakt;
            f->v3+=(f->v3- f->v1)*fakt;
          }
          else
          {
            //point 1 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z2-NEAR_Z)/(f->z2- f->z3);
            f->x2+=(f->x3- f->x2)*fakt;
            f->y2+=(f->y3- f->y2)*fakt;
            f->z2=NEAR_Z;
            f->u2+=(f->u3- f->u2)*fakt;
            f->v2+=(f->v3- f->v2)*fakt;
            fakt=(f1->z2-NEAR_Z)/(f1->z2- f1->z1);
            f1->x2+=(f1->x1- f1->x2)*fakt;
            f1->y2+=(f1->y1- f1->y2)*fakt;
            f1->z2=NEAR_Z;
            f1->u2+=(f1->u1- f1->u2)*fakt;
            f1->v2+=(f1->v1- f1->v2)*fakt;
            f1->x3=f->x2;
            f1->y3=f->y2;
            f1->z3=NEAR_Z;
            f1->u3=f->u2;
            f1->v3=f->v2;
          }
        }
        else
        {
          if (f->z3 < NEAR_Z)
          {
            //point 2 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z3-NEAR_Z)/(f->z3- f->z2);
            f->x3+=(f->x2- f->x3)*fakt;
            f->y3+=(f->y2- f->y3)*fakt;
            f->z3=NEAR_Z;
            f->u3+=(f->u2- f->u3)*fakt;
            f->v3+=(f->v2- f->v3)*fakt;
            fakt=(f1->z3-NEAR_Z)/(f1->z3- f1->z1);
            f1->x3+=(f1->x1- f1->x3)*fakt;
            f1->y3+=(f1->y1- f1->y3)*fakt;
            f1->z3=NEAR_Z;
            f1->u3+=(f1->u1- f1->u3)*fakt;
            f1->v3+=(f1->v1- f1->v3)*fakt;
            f1->x2=f->x3;
            f1->y2=f->y3;
            f1->z2=NEAR_Z;
            f1->u2=f->u3;
            f1->v2=f->v3;
          }
          else
          {
            //all points are inside
            //nothing to do :)
          }
        }
      }
    }
    d_akt++;
  }
  d_akt=d_anf;

  for (t=count;t>0;t--)
  {
    if (count>1) f=dl[d_akt];
    if (f->visible==TRUE)
    {
      if (f->z1 > FAR_Z)
      {
        if (f->z2 > FAR_Z)
        {
          if (f->z3 > FAR_Z)
          {
            //all points are outside!!
            f->visible=FALSE;
          }
          else
          {
            //points 0 & 1 are outside
            fakt=(FAR_Z -f->z1)/(f->z1- f->z3);
            f->x1+=(f->x1- f->x3)*fakt;
            f->y1+=(f->y1- f->y3)*fakt;
            f->z1=FAR_Z;
            f->u1+=(f->u1- f->u3)*fakt;
            f->v1+=(f->v1- f->v3)*fakt;
            fakt=(FAR_Z - f->z2)/(f->z2- f->z3);
            f->x2+=(f->x2- f->x3)*fakt;
            f->y2+=(f->y2- f->y3)*fakt;
            f->z2=FAR_Z;
            f->u2+=(f->u2- f->u3)*fakt;
            f->v2+=(f->v2- f->v3)*fakt;
          }
        }
        else
        {
          if (f->z3 > FAR_Z)
          {
            // points 0 & 2 are outside
            fakt=(FAR_Z - f->z1)/(f->z1- f->z2);
            f->x1+=(f->x1- f->x2)*fakt;
            f->y1+=(f->y1- f->y2)*fakt;
            f->z1=FAR_Z;
            f->u1+=(f->u1- f->u2)*fakt;
            f->v1+=(f->v1- f->v2)*fakt;
            fakt=(FAR_Z - f->z3)/(f->z3- f->z2);
            f->x3+=(f->x3- f->x2)*fakt;
            f->y3+=(f->y3- f->y2)*fakt;
            f->z3=FAR_Z;
            f->u3+=(f->u3- f->u2)*fakt;
            f->v3+=(f->v3- f->v2)*fakt;
          }
          else
          {
            //point 0 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            //f->visible=FALSE;
            fakt=(f->z1-FAR_Z)/(f->z1- f->z3);
            f->x1+=(f->x3- f->x1)*fakt;
            f->y1+=(f->y3- f->y1)*fakt;
            f->z1=FAR_Z;
            f->u1+=(f->u3- f->u1)*fakt;
            f->v1+=(f->v3- f->v1)*fakt;
            fakt=(f1->z1-FAR_Z)/(f1->z1- f1->z2);
            f1->x1+=(f1->x2- f1->x1)*fakt;
            f1->y1+=(f1->y2- f1->y1)*fakt;
            f1->z1=FAR_Z;
            f1->u1+=(f1->u2- f1->u1)*fakt;
            f1->v1+=(f1->v2- f1->v1)*fakt;
            f1->x3=f->x1;
            f1->y3=f->y1;
            f1->z3=FAR_Z;
            f1->u3=f->u1;
            f1->v3=f->v1;
          }
        }
      }
      else
      {
        if (f->z2 > FAR_Z)
        {
          if (f->z3 > FAR_Z)
          {
            //point 1 & 2 are outside
            fakt=(FAR_Z - f->z2)/(f->z2- f->z1);
            f->x2+=(f->x2- f->x1)*fakt;
            f->y2+=(f->y2- f->y1)*fakt;
            f->z2=FAR_Z;
            f->u2+=(f->u2- f->u1)*fakt;
            f->v2+=(f->v2- f->v1)*fakt;
            fakt=(FAR_Z - f->z3)/(f->z3- f->z1);
            f->x3+=(f->x3- f->x1)*fakt;
            f->y3+=(f->y3- f->y1)*fakt;
            f->z3=FAR_Z;
            f->u3+=(f->u3- f->u1)*fakt;
            f->v3+=(f->v3- f->v1)*fakt;
          }
          else
          {
            //point 1 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z2-FAR_Z)/(f->z2- f->z3);
            f->x2+=(f->x3- f->x2)*fakt;
            f->y2+=(f->y3- f->y2)*fakt;
            f->z2=FAR_Z;
            f->u2+=(f->u3- f->u2)*fakt;
            f->v2+=(f->v3- f->v2)*fakt;
            fakt=(f1->z2-FAR_Z)/(f1->z2- f1->z1);
            f1->x2+=(f1->x1- f1->x2)*fakt;
            f1->y2+=(f1->y1- f1->y2)*fakt;
            f1->z2=FAR_Z;
            f1->u2+=(f1->u1- f1->u2)*fakt;
            f1->v2+=(f1->v1- f1->v2)*fakt;
            f1->x3=f->x2;
            f1->y3=f->y2;
            f1->z3=FAR_Z;
            f1->u3=f->u2;
            f1->v3=f->v2;
          }
        }
        else
        {
          if (f->z3 > FAR_Z)
          {
            //point 2 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);
          
            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z3-FAR_Z)/(f->z3- f->z2);
            f->x3+=(f->x2- f->x3)*fakt;
            f->y3+=(f->y2- f->y3)*fakt;
            f->z3=FAR_Z;
            f->u3+=(f->u2- f->u3)*fakt;
            f->v3+=(f->v2- f->v3)*fakt;
            fakt=(f1->z3-FAR_Z)/(f1->z3- f1->z1);
            f1->x3+=(f1->x1- f1->x3)*fakt;
            f1->y3+=(f1->y1- f1->y3)*fakt;
            f1->z3=FAR_Z;
            f1->u3+=(f1->u1- f1->u3)*fakt;
            f1->v3+=(f1->v1- f1->v3)*fakt;
            f1->x2=f->x3;
            f1->y2=f->y3;
            f1->z2=FAR_Z;
            f1->u2=f->u3;
            f1->v2=f->v3;
          }
          else
          {
            //all points are inside
            //nothing to do :)
          }
        }
      }
    }
    d_akt++;
   }

  //clip X
  d_akt=d_anf;
  for (t=count;t>0;t--)
  {
    if (count>1) f=dl[d_akt];
    if (f->visible==TRUE)
    {
      if (f->x1 < -f->z1)
      {
        if (f->x2 < -f->z2)
        {
          if (f->x3 < -f->z3)
          {
            //all points are outside!!
            f->visible=FALSE;
          }
          else
          {
            //points 0 & 1 are outside
            fakt=(f->z3 - f->z1);
            skal=(-f->z1-f->x1)/(f->x3-f->x1+fakt);
            neu=skal*fakt;
            f->y1+=(f->y3- f->y1)*skal;
            f->u1+=(f->u3- f->u1)*skal;
            f->v1+=(f->v3- f->v1)*skal;
            f->z1+=neu;
            f->x1=-f->z1;
            fakt=(f->z3 - f->z2);
            skal=(-f->z2-f->x2)/(f->x3-f->x2+fakt);
            neu=skal*fakt;
            f->y2+=(f->y3- f->y2)*skal;
            f->u2+=(f->u3- f->u2)*skal;
            f->v2+=(f->v3- f->v2)*skal;
            f->z2+=neu;
            f->x2=-f->z2;
          }
        }
        else
        {
          if (f->x3 < -f->z3)
          {
            // points 0 & 2 are outside
            fakt=(f->z2 - f->z1);
            skal=(-f->z1-f->x1)/(f->x2-f->x1+fakt);
            neu=skal*fakt;
            f->y1+=(f->y2- f->y1)*skal;
            f->u1+=(f->u2- f->u1)*skal;
            f->v1+=(f->v2- f->v1)*skal;
            f->z1+=neu;
            f->x1=-f->z1;
            fakt=(f->z2 - f->z3);
            skal=(-f->z3-f->x3)/(f->x2-f->x3+fakt);
            neu=skal*fakt;
            f->y3+=(f->y2- f->y3)*skal;
            f->u3+=(f->u2- f->u3)*skal;
            f->v3+=(f->v2- f->v3)*skal;
            f->z3+=neu;
            f->x3=-f->z3;
          }
          else
          {
            //point 0 is outside
            f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!

            fakt=(f->z2 - f->z1);
            skal=(-f->z1-f->x1)/(f->x2-f->x1+fakt);
            neu=skal*fakt;
            f->y1+=(f->y2- f->y1)*skal;
            f->u1+=(f->u2- f->u1)*skal;
            f->v1+=(f->v2- f->v1)*skal;
            f->z1+=neu;
            f->x1=-f->z1;
            fakt=(f1->z3 - f1->z1);
            skal=(-f1->z1-f1->x1)/(f1->x3-f1->x1+fakt);
            neu=skal*fakt;
            f1->y1+=(f1->y3- f1->y1)*skal;
            f1->u1+=(f1->u3- f1->u1)*skal;
            f1->v1+=(f1->v3- f1->v1)*skal;
            f1->z1+=neu;
            f1->x1=-f1->z1;
            f1->x2=f->x1;
            f1->y2=f->y1;
            f1->z2=f->z1;
            f1->u2=f->u1;
            f1->v2=f->v1;
          }
        }
      }
      else
      {
        if (f->x2 < -f->z2)
        {
          if (f->x3 < -f->z3)
          {
            //point 1 & 2 are outside
            fakt=(f->z1 - f->z2);
            skal=(-f->z2-f->x2)/(f->x1-f->x2+fakt);
            neu=skal*fakt;
            f->y2+=(f->y1- f->y2)*skal;
            f->u2+=(f->u1- f->u2)*skal;
            f->v2+=(f->v1- f->v2)*skal;
            f->z2+=neu;
            f->x2=-f->z2;
            fakt=(f->z1 - f->z3);
            skal=(-f->z3-f->x3)/(f->x1-f->x3+fakt);
            neu=skal*fakt;
            f->y3+=(f->y1- f->y3)*skal;
            f->u3+=(f->u1- f->u3)*skal;
            f->v3+=(f->v1- f->v3)*skal;
            f->z3+=neu;
            f->x3=-f->z3;
          }
          else
          {
            //point 1 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z3 - f->z2);
            skal=(-f->z2-f->x2)/(f->x3-f->x2+fakt);
            neu=skal*fakt;
            f->y2+=(f->y3- f->y2)*skal;
            f->u2+=(f->u3- f->u2)*skal;
            f->v2+=(f->v3- f->v2)*skal;
            f->z2+=neu;
            f->x2=-f->z2;
            fakt=(f1->z1 - f1->z2);
            skal=(-f1->z2-f1->x2)/(f1->x1-f1->x2+fakt);
            neu=skal*fakt;
            f1->y2+=(f1->y1- f1->y2)*skal;
            f1->u2+=(f1->u1- f1->u2)*skal;
            f1->v2+=(f1->v1- f1->v2)*skal;
            f1->z2+=neu;
            f1->x2=-f1->z2;
            f1->x3=f->x2;
            f1->y3=f->y2;
            f1->z3=f->z2;
            f1->u3=f->u2;
            f1->v3=f->v2;
          }
        }
        else
        {
          if (f->x3 < -f->z3)
          {
            //point 2 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z2 - f->z3);
            skal=(-f->z3-f->x3)/(f->x2-f->x3+fakt);
            neu=skal*fakt;
            f->y3+=(f->y2- f->y3)*skal;
            f->u3+=(f->u2- f->u3)*skal;
            f->v3+=(f->v2- f->v3)*skal;
            f->z3+=neu;
            f->x3=-f->z3;
            fakt=(f1->z1 - f1->z3);
            skal=(-f1->z3-f1->x3)/(f1->x1-f1->x3+fakt);
            neu=skal*fakt;
            f1->y3+=(f1->y1- f1->y3)*skal;
            f1->u3+=(f1->u1- f1->u3)*skal;
            f1->v3+=(f1->v1- f1->v3)*skal;
            f1->z3+=neu;
            f1->x3=-f1->z3;
            f1->x2=f->x3;
            f1->y2=f->y3;
            f1->z2=f->z3;
            f1->u2=f->u3;
            f1->v2=f->v3;
          }
          else
          {
            //all points are inside
            //nothing to do :)
          }
        }
      }
    }
    d_akt++;
  }
  d_akt=d_anf;
  for (t=count;t>0;t--)
  {
    if (count>1) f=dl[d_akt];
    if (f->visible==TRUE)
    {
      if (f->x1 > f->z1)
      {
        if (f->x2 > f->z2)
        {
          if (f->x3 > f->z3)
          {
            //all points are outside!!
            f->visible=FALSE;
          }
          else
          {
            //points 0 & 1 are outside
            fakt=(f->z3 - f->z1);
            skal=(f->z1-f->x1)/(f->x3-f->x1-fakt);
            neu=skal*fakt;
            f->y1+=(f->y3- f->y1)*skal;
            f->u1+=(f->u3- f->u1)*skal;
            f->v1+=(f->v3- f->v1)*skal;
            f->z1+=neu;
            f->x1=f->z1;
            fakt=(f->z3 - f->z2);
            skal=(f->z2-f->x2)/(f->x3-f->x2-fakt);
            neu=skal*fakt;
            f->y2+=(f->y3- f->y2)*skal;
            f->u2+=(f->u3- f->u2)*skal;
            f->v2+=(f->v3- f->v2)*skal;
            f->z2+=neu;
            f->x2=f->z2;
          }
        }
        else
        {
          if (f->x3 > f->z3)
          {
            // points 0 & 2 are outside
            fakt=(f->z2 - f->z1);
            skal=(f->z1-f->x1)/(f->x2-f->x1-fakt);
            neu=skal*fakt;
            f->y1+=(f->y2- f->y1)*skal;
            f->u1+=(f->u2- f->u1)*skal;
            f->v1+=(f->v2- f->v1)*skal;
            f->z1+=neu;
            f->x1=f->z1;
            fakt=(f->z2 - f->z3);
            skal=(f->z3-f->x3)/(f->x2-f->x3-fakt);
            neu=skal*fakt;
            f->y3+=(f->y2- f->y3)*skal;
            f->u3+=(f->u2- f->u3)*skal;
            f->v3+=(f->v2- f->v3)*skal;
            f->z3+=neu;
            f->x3=f->z3;
          }
          else
          {
            //point 0 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!

            fakt=(f->z2 - f->z1);
            skal=(f->z1-f->x1)/(f->x2-f->x1-fakt);
            neu=skal*fakt;
            f->y1+=(f->y2- f->y1)*skal;
            f->u1+=(f->u2- f->u1)*skal;
            f->v1+=(f->v2- f->v1)*skal;
            f->z1+=neu;
            f->x1=f->z1;
            fakt=(f1->z3 - f1->z1);
            skal=(f1->z1-f1->x1)/(f1->x3-f1->x1-fakt);
            neu=skal*fakt;
            f1->y1+=(f1->y3- f1->y1)*skal;
            f1->u1+=(f1->u3- f1->u1)*skal;
            f1->v1+=(f1->v3- f1->v1)*skal;
            f1->z1+=neu;
            f1->x1=f1->z1;
            f1->x2=f->x1;
            f1->y2=f->y1;
            f1->z2=f->z1;
            f1->u2=f->u1;
            f1->v2=f->v1;
          }
        }
      }
      else
      {
        if (f->x2 > f->z2)
        {
          if (f->x3 > f->z3)
          {
            //point 1 & 2 are outside
            fakt=(f->z1 - f->z2);
            skal=(f->z2-f->x2)/(f->x1-f->x2-fakt);
            neu=skal*fakt;
            f->y2+=(f->y1- f->y2)*skal;
            f->u2+=(f->u1- f->u2)*skal;
            f->v2+=(f->v1- f->v2)*skal;
            f->z2+=neu;
            f->x2=f->z2;
            fakt=(f->z1 - f->z3);
            skal=(f->z3-f->x3)/(f->x1-f->x3-fakt);
            neu=skal*fakt;
            f->y3+=(f->y1- f->y3)*skal;
            f->u3+=(f->u1- f->u3)*skal;
            f->v3+=(f->v1- f->v3)*skal;
            f->z3+=neu;
            f->x3=f->z3;
          }
          else
          {
            //point 1 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z3 - f->z2);
            skal=(f->z2-f->x2)/(f->x3-f->x2-fakt);
            neu=skal*fakt;
            f->y2+=(f->y3- f->y2)*skal;
            f->u2+=(f->u3- f->u2)*skal;
            f->v2+=(f->v3- f->v2)*skal;
            f->z2+=neu;
            f->x2=f->z2;
            fakt=(f1->z1 - f1->z2);
            skal=(f1->z2-f1->x2)/(f1->x1-f1->x2-fakt);
            neu=skal*fakt;
            f1->y2+=(f1->y1- f1->y2)*skal;
            f1->u2+=(f1->u1- f1->u2)*skal;
            f1->v2+=(f1->v1- f1->v2)*skal;
            f1->z2+=neu;
            f1->x2=f1->z2;
            f1->x3=f->x2;
            f1->y3=f->y2;
            f1->z3=f->z2;
            f1->u3=f->u2;
            f1->v3=f->v2;
          }
        }
        else
        {
          if (f->x3 > f->z3)
          {
            //point 2 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z2 - f->z3);
            skal=(f->z3-f->x3)/(f->x2-f->x3-fakt);
            neu=fakt*skal;
            f->y3+=(f->y2- f->y3)*skal;
            f->u3+=(f->u2- f->u3)*skal;
            f->v3+=(f->v2- f->v3)*skal;
            f->z3+=neu;
            f->x3=f->z3;
            fakt=(f1->z1 - f1->z3);
            skal=(f1->z3-f1->x3)/(f1->x1-f1->x3-fakt);
            neu=fakt*skal;
            f1->y3+=(f1->y1- f1->y3)*skal;
            f1->u3+=(f1->u1- f1->u3)*skal;
            f1->v3+=(f1->v1- f1->v3)*skal;
            f1->z3+=neu;
            f1->x3=f1->z3;
            f1->x2=f->x3;
            f1->y2=f->y3;
            f1->z2=f->z3;
            f1->u2=f->u3;
            f1->v2=f->v3;
          }
          else
          {
            //all points are inside
            //nothing to do :)
          }
        }
      }
    }
    d_akt++;
   }



  //clip Y
  d_akt=d_anf;
  for (t=count;t>0;t--)
  {
    if (count>1) f=dl[d_akt];
    if (f->visible==TRUE)
    {
      if (f->y1 < -f->z1)
      {
        if (f->y2 < -f->z2)
        {
          if (f->y3 < -f->z3)
          {
            //all points are outside!!
            f->visible=FALSE;
          }
          else
          {
            //points 0 & 1 are outside
            fakt=(f->z3 - f->z1);
            skal=(-f->z1-f->y1)/(f->y3-f->y1+fakt);
            neu=fakt*skal;
            f->x1+=(f->x3- f->x1)*skal;
            f->u1+=(f->u3- f->u1)*skal;
            f->v1+=(f->v3- f->v1)*skal;
            f->z1+=neu;
            f->y1=-f->z1;
            fakt=(f->z3 - f->z2);
            skal=(-f->z2-f->y2)/(f->y3-f->y2+fakt);
            neu=fakt*skal;
            f->x2+=(f->x3- f->x2)*skal;
            f->u2+=(f->u3- f->u2)*skal;
            f->v2+=(f->v3- f->v2)*skal;
            f->z2+=neu;
            f->y2=-f->z2;
          }
        }
        else
        {
          if (f->y3 < -f->z3)
          {
            // points 0 & 2 are outside
            fakt=(f->z2 - f->z1);
            skal=(-f->z1-f->y1)/(f->y2-f->y1+fakt);
            neu=fakt*skal;
            f->x1+=(f->x2- f->x1)*skal;
            f->u1+=(f->u2- f->u1)*skal;
            f->v1+=(f->v2- f->v1)*skal;
            f->z1+=neu;
            f->y1=-f->z1;
            fakt=(f->z2 - f->z3);
            skal=(-f->z3-f->y3)/(f->y2-f->y3+fakt);
            neu=fakt*skal;
            f->x3+=(f->x2- f->x3)*skal;
            f->u3+=(f->u2- f->u3)*skal;
            f->v3+=(f->v2- f->v3)*skal;
            f->z3+=neu;
            f->y3=-f->z3;
          }
          else
          {
            //point 0 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!

            fakt=(f->z2 - f->z1);
            skal=(-f->z1-f->y1)/(f->y2-f->y1+fakt);
            neu=fakt*skal;
            f->x1+=(f->x2- f->x1)*skal;
            f->u1+=(f->u2- f->u1)*skal;
            f->v1+=(f->v2- f->v1)*skal;
            f->z1+=neu;
            f->y1=-f->z1;
            fakt=(f1->z3 - f1->z1);
            skal=(-f1->z1-f1->y1)/(f1->y3-f1->y1+fakt);
            neu=fakt*skal;
            f1->x1+=(f1->x3- f1->x1)*skal;
            f1->u1+=(f1->u3- f1->u1)*skal;
            f1->v1+=(f1->v3- f1->v1)*skal;
            f1->z1+=neu;
            f1->y1=-f1->z1;
            f1->y2=f->y1;
            f1->x2=f->x1;
            f1->z2=f->z1;
            f1->v2=f->v1;
            f1->u2=f->u1;
          }
        }
      }
      else
      {
        if (f->y2 < -f->z2)
        {
          if (f->y3 < -f->z3)
          {
            //point 1 & 2 are outside
            fakt=(f->z1 - f->z2);
            skal=(-f->z2-f->y2)/(f->y1-f->y2+fakt);
            neu=fakt*skal;
            f->x2+=(f->x1- f->x2)*skal;
            f->u2+=(f->u1- f->u2)*skal;
            f->v2+=(f->v1- f->v2)*skal;
            f->z2+=neu;
            f->y2=-f->z2;
            fakt=(f->z1 - f->z3);
            skal=(-f->z3-f->y3)/(f->y1-f->y3+fakt);
            neu=fakt*skal;
            f->x3+=(f->x1- f->x3)*skal;
            f->u3+=(f->u1- f->u3)*skal;
            f->v3+=(f->v1- f->v3)*skal;
            f->z3+=neu;
            f->y3=-f->z3;
          }
          else
          {
            //point 1 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z3 - f->z2);
            skal=(-f->z2-f->y2)/(f->y3-f->y2+fakt);
            neu=fakt*skal;
            f->x2+=(f->x3- f->x2)*skal;
            f->u2+=(f->u3- f->u2)*skal;
            f->v2+=(f->v3- f->v2)*skal;
            f->z2+=neu;
            f->y2=-f->z2;
            fakt=(f1->z1 - f1->z2);
            skal=(-f1->z2-f1->y2)/(f1->y1-f1->y2+fakt);
            neu=fakt*skal;
            f1->x2+=(f1->x1- f1->x2)*skal;
            f1->u2+=(f1->u1- f1->u2)*skal;
            f1->v2+=(f1->v1- f1->v2)*skal;
            f1->z2+=neu;
            f1->y2=-f1->z2;
            f1->y3=f->y2;
            f1->x3=f->x2;
            f1->z3=f->z2;
            f1->v3=f->v2;
            f1->u3=f->u2;
          }
        }
        else
        {
          if (f->y3 < -f->z3)
          {
            //point 2 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z2 - f->z3);
            skal=(-f->z3-f->y3)/(f->y2-f->y3+fakt);
            neu=fakt*skal;
            f->x3+=(f->x2- f->x3)*skal;
            f->u3+=(f->u2- f->u3)*skal;
            f->v3+=(f->v2- f->v3)*skal;
            f->z3+=neu;
            f->y3=-f->z3;
            fakt=(f1->z1 - f1->z3);
            skal=(-f1->z3-f1->y3)/(f1->y1-f1->y3+fakt);
            neu=fakt*skal;
            f1->x3+=(f1->x1- f1->x3)*skal;
            f1->u3+=(f1->u1- f1->u3)*skal;
            f1->v3+=(f1->v1- f1->v3)*skal;
            f1->z3+=neu;
            f1->y3=-f1->z3;
            f1->y2=f->y3;
            f1->x2=f->x3;
            f1->z2=f->z3;
            f1->v2=f->v3;
            f1->u2=f->u3;
          }
          else
          {
            //all points are inside
            //nothing to do :)
          }
        }
      }
    }
    d_akt++;
  }
  d_akt=d_anf;
  for (t=count;t>0;t--)
  {
    if (count>1) f=dl[d_akt];
    if (f->visible==TRUE)
    {
      if (f->y1 > f->z1)
      {
        if (f->y2 > f->z2)
        {
          if (f->y3 > f->z3)
          {
            //all points are outside!!
            f->visible=FALSE;
          }
          else
          {
            //points 0 & 1 are outside
            fakt=(f->z3 - f->z1);
            skal=(f->z1-f->y1)/(f->y3-f->y1-fakt);
            neu=fakt*skal;
            f->x1+=(f->x3- f->x1)*skal;
            f->u1+=(f->u3- f->u1)*skal;
            f->v1+=(f->v3- f->v1)*skal;
            f->z1+=neu;
            f->y1=f->z1;
            fakt=(f->z3 - f->z2);
            skal=(f->z2-f->y2)/(f->y3-f->y2-fakt);
            neu=fakt*skal;
            f->x2+=(f->x3- f->x2)*skal;
            f->u2+=(f->u3- f->u2)*skal;
            f->v2+=(f->v3- f->v2)*skal;
            f->z2+=neu;
            f->y2=f->z2;
          }
        }
        else
        {
          if (f->y3 > f->z3)
          {
            // points 0 & 2 are outside
            fakt=(f->z2 - f->z1);
            skal=(f->z1-f->y1)/(f->y2-f->y1-fakt);
            neu=fakt*skal;
            f->x1+=(f->x2- f->x1)*skal;
            f->u1+=(f->u2- f->u1)*skal;
            f->v1+=(f->v2- f->v1)*skal;
            f->z1+=neu;
            f->y1=f->z1;
            fakt=(f->z2 - f->z3);
            skal=(f->z3-f->y3)/(f->y2-f->y3-fakt);
            neu=fakt*skal;
            f->x3+=(f->x2- f->x3)*skal;
            f->u3+=(f->u2- f->u3)*skal;
            f->v3+=(f->v2- f->v3)*skal;
            f->z3+=neu;
            f->y3=f->z3;
          }
          else
          {
            //point 0 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!

            fakt=(f->z2 - f->z1);
            skal=(f->z1-f->y1)/(f->y2-f->y1-fakt);
            neu=fakt*skal;
            f->x1+=(f->x2- f->x1)*skal;
            f->u1+=(f->u2- f->u1)*skal;
            f->v1+=(f->v2- f->v1)*skal;
            f->z1+=neu;
            f->y1=f->z1;
            fakt=(f1->z3 - f1->z1);
            skal=(f1->z1-f1->y1)/(f1->y3-f1->y1-fakt);
            neu=fakt*skal;
            f1->x1+=(f1->x3- f1->x1)*skal;
            f1->u1+=(f1->u3- f1->u1)*skal;
            f1->v1+=(f1->v3- f1->v1)*skal;
            f1->z1+=neu;
            f1->y1=f1->z1;
            f1->y2=f->y1;
            f1->x2=f->x1;
            f1->z2=f->z1;
            f1->v2=f->v1;
            f1->u2=f->u1;
          }
        }
      }
      else
      {
        if (f->y2 > f->z2)
        {
          if (f->y3 > f->z3)
          {
            //point 1 & 2 are outside
            fakt=(f->z1 - f->z2);
            skal=(f->z2-f->y2)/(f->y1-f->y2-fakt);
            neu=fakt*skal;
            f->x2+=(f->x1- f->x2)*skal;
            f->u2+=(f->u1- f->u2)*skal;
            f->v2+=(f->v1- f->v2)*skal;
            f->z2+=neu;
            f->y2=f->z2;
            fakt=(f->z1 - f->z3);
            skal=(f->z3-f->y3)/(f->y1-f->y3-fakt);
            neu=fakt*skal;
            f->x3+=(f->x1- f->x3)*skal;
            f->u3+=(f->u1- f->u3)*skal;
            f->v3+=(f->v1- f->v3)*skal;
            f->z3+=neu;
            f->y3=f->z3;
          }
          else
          {
            //point 1 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z3 - f->z2);
            skal=(f->z2-f->y2)/(f->y3-f->y2-fakt);
            neu=fakt*skal;
            f->x2+=(f->x3- f->x2)*skal;
            f->u2+=(f->u3- f->u2)*skal;
            f->v2+=(f->v3- f->v2)*skal;
            f->z2+=neu;
            f->y2=f->z2;
            fakt=(f1->z1 - f1->z2);
            skal=(f1->z2-f1->y2)/(f1->y1-f1->y2-fakt);
            neu=fakt*skal;
            f1->x2+=(f1->x1- f1->x2)*skal;
            f1->u2+=(f1->u1- f1->u2)*skal;
            f1->v2+=(f1->v1- f1->v2)*skal;
            f1->z2+=neu;
            f1->y2=f1->z2;
            f1->y3=f->y2;
            f1->x3=f->x2;
            f1->z3=f->z2;
            f1->v3=f->v2;
            f1->u3=f->u2;
          }
        }
        else
        {
          if (f->y3 > f->z3)
          {
            //point 2 is outside
			f1=&(scratchFaces[scratchCount++]);
			(*f1)=(*f);

            dl[count]=f1;count++; //insert new struct _DRAWFACE!
            fakt=(f->z2 - f->z3);
            skal=(f->z3-f->y3)/(f->y2-f->y3-fakt);
            neu=fakt*skal;
            f->x3+=(f->x2- f->x3)*skal;
            f->u3+=(f->u2- f->u3)*skal;
            f->v3+=(f->v2- f->v3)*skal;
            f->z3+=neu;
            f->y3=f->z3;
            fakt=(f1->z1 - f1->z3);
            skal=(f1->z3-f1->y3)/(f1->y1-f1->y3-fakt);
            neu=fakt*skal;
            f1->x3+=(f1->x1- f1->x3)*skal;
            f1->u3+=(f1->u1- f1->u3)*skal;
            f1->v3+=(f1->v1- f1->v3)*skal;
            f1->z3+=neu;
            f1->y3=f1->z3;
            f1->y2=f->y3;
            f1->x2=f->x3;
            f1->z2=f->z3;
            f1->v2=f->v3;
            f1->u2=f->u3;
          }
          else
          {
            //all points are inside
            //nothing to do :)
          }
        }
      }
    }
    d_akt++;
   }


  //last remove all not visible
  visible=TRUE;
  d_akt=d_anf;
  c=0;


  for (t=0; t<count; t++)
  {
    if (count>1)
      f=dl[d_akt];

    if (f->visible==TRUE)
    {
      if (f->z1<f->z2)
      {		
        f->minZ=f->z1;
        f->maxZ=f->z2;
      }
      else
      {
        f->minZ=f->z2;
        f->maxZ=f->z1;
      }
      
      if (f->z3<f->minZ)
        f->minZ=f->z3;
      
      if (f->z3>f->maxZ)
        f->maxZ=f->z3;

      z1 = 1.0 / f->z1;
      z2 = 1.0 / f->z2;
      z3 = 1.0 / f->z3;
      x1 = ((f->x1)*z1);
      y1 = ((f->y1)*z1);
      x2 = ((f->x2)*z2);
      y2 = ((f->y2)*z2);
      x3 = ((f->x3)*z3);
      y3 = ((f->y3)*z3);

      if (f->visible)
      {
        f->x1=(320.0+319.0*x1);
        f->y1=(240.0+239.0*y1);
        f->x2=(320.0+319.0*x2);
        f->y2=(240.0+239.0*y2);
        f->x3=(320.0+319.0*x3);
        f->y3=(240.0+239.0*y3);
        
        if (f->x1<f->x2)
	      {		
		      f->minx=f->x1;
		      f->maxx=f->x2;
	      }
        else
        {
		      f->minx=f->x2;
		      f->maxx=f->x1;
	      }

        if (f->x3<f->minx)
			    f->minx=f->x3;

		    if (f->x3>f->maxx)
			    f->maxx=f->x3;

        if (f->y1<f->y2)
		    {		
			    f->miny=f->y1;
			    f->maxy=f->y2;
		    }
        else
        {
			    f->miny=f->y2;
			    f->maxy=f->y1;
		    }

		    if (f->y3<f->miny)
			    f->miny=f->y3;

        if (f->y3>f->maxy)
			    f->maxy=f->y3;
		  
        c++;
        if (d_akt!=d_anf)
          dl[d_anf]=f;

        d_anf++;
      }
    }
    d_akt++;
  }
  count=d_anf;
 
  if (count>0)
  {
	  if(mz)
		  sortmin(&(dl[0]),&(dl[count-1]),&(dl[0]),&(dl[count-1]));
	  else
		  sortmax(&(dl[0]),&(dl[count-1]),&(dl[0]),&(dl[count-1]));
//    sortmin(dl, dl+count-1, dl, dl+count-1);
  }
}

