#include "object3d.h"

#include <stdio.h>


Object3D::Object3D(void)
{
	faces = verts = lines = 0;
	pFaces = NULL;
    pLines = NULL;
	pVert = NULL;

}

Object3D::~Object3D(void)
{
	DeAlloc();
}

void Object3D::BuildCube(float size)
{
  int i;

	DeAlloc();
	verts = 8;
	faces = 12;
  lines = 12;
	Alloc();

  for (i=0; i<8; i++)
    pVert[i]=Vertex(Vector(((i^(i>>1))&1)?size:-size, (i&2)?-size:size, (i&4)?size:-size));

	pFaces[0] = Face(0,1,2,Vector(0.3f,0.5f,0.0f),texCoord(255,0),texCoord(0,0),texCoord(0,255),0);
  pFaces[1] = Face(0,2,3,Vector(0.3f,0.5f,0.0f),texCoord(255,0),texCoord(0,255),texCoord(255,255),0);
	pFaces[2] = Face(5,4,7,Vector(0.7f,0.5f,0.0f),texCoord(255,0),texCoord(0,0),texCoord(0,255),1);
  pFaces[3] = Face(5,7,6,Vector(0.7f,0.5f,0.0f),texCoord(255,0),texCoord(0,255),texCoord(255,255),1);
	pFaces[4] = Face(1,5,6,Vector(0.0f,0.5f,0.3f),texCoord(255,0),texCoord(0,0),texCoord(0,255),2);
  pFaces[5] = Face(1,6,2,Vector(0.0f,0.5f,0.3f),texCoord(255,0),texCoord(0,255),texCoord(255,255),2);
	pFaces[6] = Face(4,0,3,Vector(0.2f,0.0f,0.0f),texCoord(255,0),texCoord(0,0),texCoord(0,255),3);
  pFaces[7] = Face(4,3,7,Vector(0.2f,0.0f,0.0f),texCoord(255,0),texCoord(0,255),texCoord(255,255),3);
	pFaces[8] = Face(4,5,1,Vector(0.2f,0.0f,0.2f),texCoord(255,0),texCoord(0,0),texCoord(0,255),4);
  pFaces[9] = Face(4,1,0,Vector(0.2f,0.0f,0.2f),texCoord(255,0),texCoord(0,255),texCoord(255,255),4);
	pFaces[10] = Face(3,2,6,Vector(0.2f,0.5f,0.0f),texCoord(255,0),texCoord(0,0),texCoord(0,255),5);
  pFaces[11] = Face(3,6,7,Vector(0.2f,0.5f,0.0f),texCoord(255,0),texCoord(0,255),texCoord(255,255),5);

  pLines[0] = Line(0,1,&pFaces[0],&pFaces[9]);
  pLines[1] = Line(1,2,&pFaces[0],&pFaces[5]);
  pLines[2] = Line(2,3,&pFaces[1],&pFaces[10]);
  pLines[3] = Line(3,0,&pFaces[1],&pFaces[6]);
  pLines[4] = Line(5,4,&pFaces[2],&pFaces[8]);
  pLines[5] = Line(4,7,&pFaces[2],&pFaces[7]);
  pLines[6] = Line(7,6,&pFaces[3],&pFaces[11]);
  pLines[7] = Line(6,5,&pFaces[3],&pFaces[4]);
  pLines[8] = Line(1,5,&pFaces[4],&pFaces[8]);
  pLines[9] = Line(6,2,&pFaces[5],&pFaces[10]);
  pLines[10] = Line(3,7,&pFaces[7],&pFaces[11]);
  pLines[11] = Line(0,4,&pFaces[6],&pFaces[9]);
  MakeNormals();
	m.Identity();
}

unsigned char* Object3D::BuildObj(unsigned char *mem, int texturnummer)
{
     unsigned char *m1,*m2;
    int a,b,c,u1,v1,u2,v2,u3,v3;
    char flag;
    FacePtr f1,f2;
    int bo;
    int la,lb;
    int i,j,k;
    float cr,cg,cb;
	DeAlloc();
	verts = *((short*)(mem));
    mem+=2;
	faces = *((short*)(mem));
    lines = 0;
    mem+=2;

    //hmm. now its getting a little bit complicated to determine the number of lines...
    m1=mem+verts*3*sizeof(float);
    for (i=0;i<faces;i++) 
    {
      flag=*(m1+3);
      if ((flag & 1)==1) 
      {
        la=*(m1+0);
        lb=*(m1+1);     
        m2=m1+4+6;
        bo=FALSE;
        for (j=i+1;j<faces;j++)
        {
           if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) bo=TRUE;           
           m2+=4+6;
        }
        if (bo==FALSE) lines++;
      }
      if ((flag & 2)==2) 
      {
        la=*(m1+1);
        lb=*(m1+2);     
        m2=m1+4+6;
        bo=FALSE;
        for (j=i+1;j<faces;j++)
        {
           if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) bo=TRUE;           
           m2+=4+6;
        }
        if (bo==FALSE) lines++;
      }
      if ((flag & 4)==4) 
      {
        la=*(m1+2);
        lb=*(m1+0);     
        m2=m1+4+6;
        bo=FALSE;
        for (j=i+1;j<faces;j++)
        {
           if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) bo=TRUE;           
           m2+=4+6;
        }
        if (bo==FALSE) lines++;
      }
      m1+=4+6;
    }
	Alloc();  

    for (i=0;i<verts;i++) 
    {
	  pVert[i] = Vertex(Vector((*((float*)(mem+0))),(*((float*)(mem+4))),(*((float*)(mem+8))) ));
      mem+=3*sizeof(float);
    }
    
    m1=mem;
    for (i=0;i<faces;i++) 
    {
      a=*(m1+0);
      b=*(m1+1);
      c=*(m1+2);
      u1=*(m1+4);
      v1=*(m1+5);
      u2=*(m1+6);
      v2=*(m1+7);
      u3=*(m1+8);
      v3=*(m1+9);

      pFaces[i] = Face(a,b,c,Vector(1.0f,1.0f,1.0f),texCoord(u1,v1),texCoord(u2,v2),texCoord(u3,v3),texturnummer);
      m1+=4+6;
    }
    
    m1=mem;
    k=0;
    for (i=0;i<faces;i++) 
    {
      flag=*(m1+3);
      if ((flag & 1)==1) 
      {
        la=*(m1);
        lb=*(m1+1);     
        m2=m1+4+6;
        bo=FALSE;
        for (j=i+1;j<faces;j++)
        {
           if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) bo=TRUE;           
           m2+=4+6;
        }
        if (bo==FALSE) 
        {
          m2=mem;
          f1=NULL;f2=NULL;
          for (j=0;j<=i;j++)
          {
            if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            m2+=4+6;
          }
          pLines[k++] = Line(la,lb,f1,f2);
        }        
      }
      if ((flag & 2)==2) 
      {
        la=*(m1+1);
        lb=*(m1+2);     
        m2=m1+4+6;
        bo=FALSE;
        for (j=i+1;j<faces;j++)
        {
           if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) bo=TRUE;           
           m2+=4+6;
        }
        if (bo==FALSE) 
        {
          m2=mem;
          f1=NULL;f2=NULL;
          for (j=0;j<=i;j++)
          {
            if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            m2+=4+6;
          }
          pLines[k++] = Line(la,lb,f1,f2);
        }        
      }

      if ((flag & 4)==4) 
      {
        la=*(m1+2);
        lb=*(m1+0);     
        m2=m1+4+6;
        bo=FALSE;
        for (j=i+1;j<faces;j++)
        {
           if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) bo=TRUE;
           if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) bo=TRUE;           
           m2+=4+6;
        }
        if (bo==FALSE) 
        {
          m2=mem;
          f1=NULL;f2=NULL;
          for (j=0;j<=i;j++)
          {
            if ( (((*(m2+3)) & 1)==1) && ( (((*(m2+0))==la) && ((*(m2+1))==lb)) || (((*(m2+0))==lb) && ((*(m2+1))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            if ( (((*(m2+3)) & 2)==2) && ( (((*(m2+1))==la) && ((*(m2+2))==lb)) || (((*(m2+1))==lb) && ((*(m2+2))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            if ( (((*(m2+3)) & 4)==4) && ( (((*(m2+2))==la) && ((*(m2+0))==lb)) || (((*(m2+2))==lb) && ((*(m2+0))==la)) ) ) { if (f1==NULL) f1=&pFaces[j]; else if (f2==NULL) f2=&pFaces[j]; }
            m2+=4+6;
          }
          pLines[k++] = Line(la,lb,f1,f2);
        }        
      }
      m1+=4+6;
    }

    m.Identity();

  cr=1.0f-(((float) (*m1))/255.0f);m1++;
  cg=1.0f-(((float) (*m1))/255.0f);m1++;
  cb=1.0f-(((float) (*m1))/255.0f);m1++;m1++;

  for (i=0;i<faces;i++) {
    pFaces[i].col = new PastelColor(Vector(cr,cg,cb)); 
  }

  return m1;
}


void Object3D::BuildText(LineFont* lf, char* string, float x, float y, float z,float size, float spacing, int lw)
{
    LineChar* lc;
    char *hstr=string;
    int v,i,pindex,j,vc ;

    vc=0;
    while(*hstr)
	{
		lc=&(lf->LC[(int)(*string)]);
		for(i=0; i<lc->curvecount; i++)
		{
			vc+=lc->ppcurve[i];
		}
		hstr++;
	}

	DeAlloc();
	verts = vc;
	faces = 0;
    lines = vc;
	Alloc();

	vc=0;
	while(*string)
	{
		lc=&(lf->LC[(int)(*string)]);
        v=0;
		for(i=0; i<lc->curvecount; i++)
		{
			pindex = vc;
            pVert[vc] = Vertex(lc->Curves[v]*size+Vector(x,y,z));
            vc++;
            v++;
			for(j=1; j<lc->ppcurve[i]; j++)
			{
	            pVert[vc] = Vertex(lc->Curves[v]*size+Vector(x,y,z));
                pLines[vc-1] = Line(vc-1,vc,NULL,NULL);
				v++;
                vc++;
			}
            pLines[vc-1] = Line(vc-1,pindex,NULL,NULL);
		}
		string++;
		x+=((lc->w+spacing)*size);
  }

  lines=vc;

	m.Identity();
}



void Object3D::DeAlloc()
{
	if(pFaces)
	{
		delete [] pFaces;
		pFaces = 0;
		faces = 0;       
	}

	if(pLines)
	{
		delete [] pLines;
		pLines = 0;
		lines = 0;       
	}

	if(pVert)
	{
		delete [] pVert;
		pVert = NULL;
		verts = 0;
	}
}

void Object3D::Alloc()
{
	if (faces!=0) pFaces = new Face[faces]; else (pFaces=NULL);
    if (lines!=0) pLines = new Line[lines]; else (pLines=NULL);
	pVert = new Vertex[verts];
}

void Object3D::Transform(Matrix mat)
{
	int i;
    Matrix n;
    n.Identity();
    n=mat;

    n*=m;

	for( i=0; i<verts; i++)
	{
		pVert[i].ws = pVert[i].os;
		pVert[i].ws *= n;
	}
}

void Object3D::Draw(LineList* ll,FaceList *fl)
{
  int i,visible;
  DrawLineObjPtr l;
  DrawFaceObjPtr f;
  
  for(i=0; i<faces; i++)
  {
      float x1,y1,z1,x2,y2,z2,x3,y3,z3;
      z1 = pVert[pFaces[i].pIndex[0]].ws.z;
      z2 = pVert[pFaces[i].pIndex[1]].ws.z;
      z3 = pVert[pFaces[i].pIndex[2]].ws.z;
      if (z1<NEAR_Z) z1=NEAR_Z;
      if (z2<NEAR_Z) z2=NEAR_Z;
      if (z3<NEAR_Z) z3=NEAR_Z;
      z1=1.0/z1;
      z2=1.0/z2;
      z3=1.0/z3;
      
      x1 = pVert[pFaces[i].pIndex[0]].ws.x*z1;
      y1 = pVert[pFaces[i].pIndex[0]].ws.y*z1;
      x2 = pVert[pFaces[i].pIndex[1]].ws.x*z2;
      y2 = pVert[pFaces[i].pIndex[1]].ws.y*z2;
      x3 = pVert[pFaces[i].pIndex[2]].ws.x*z3;
      y3 = pVert[pFaces[i].pIndex[2]].ws.y*z3;

      pFaces[i].visible=((x1 - x2)*(y1 - y3)) - ((x1 - x3)*(y1 - y2)) < 0;

		  if(pFaces[i].visible)
        fl->add(pVert,&(pFaces[i]));
      else
        pFaces[i].theDrawFace=0;
  }

  for(i=0; i<lines; i++)
  {
     visible=TRUE;
     if (pLines[i].fcount>0) visible=pLines[i].f[0]->visible;
     if (pLines[i].fcount>1) visible|=pLines[i].f[1]->visible;
     
     if (visible)
     {
       l=ll->add(&(pVert[pLines[i].pIndex[0]].ws), &(pVert[pLines[i].pIndex[1]].ws));
       if (pLines[i].fcount>0) 
       {
         f=pLines[i].f[0]->theDrawFace;
         if (f)
           f->l[f->lcount++]=l;
       }

       if (pLines[i].fcount>1) 
       {
         f=pLines[i].f[1]->theDrawFace;
         if (f)
           f->l[f->lcount++]=l;
       }
     }
  }

}
void Object3D::MakeNormals()
{
	for(int i=0; i<faces; i++)
	{
		pFaces[i].n = (pVert[pFaces[i].pIndex[1]].ws-pVert[pFaces[i].pIndex[0]].ws)%(pVert[pFaces[i].pIndex[2]].ws-pVert[pFaces[i].pIndex[0]].ws);
		pFaces[i].n.Normalise();
	}
}


#ifndef M_PI
#define M_PI 3.1415926535897932384626433832795f
#endif

Camera::Camera(void)
{

  perspX=1.0f;
  perspY=perspX *(640.0f/480.0f);

  eyepoint.x=0;
  eyepoint.y=0;
  eyepoint.z=-2.0f;
  roll=M_PI;
  target.x=0;
  target.y=0;
  target.z=1;

  m.Identity();  
  posKeys=NULL;
  targetKeys=NULL;
  rollKeys=NULL;
}

void Camera::Camera2Matrix()
{

  Vector cVec, pivot;
  float    focus;
  float    ax, ay, az;
  float    sinx, siny, sinz,cosx, cosy, cosz;

  m.Identity();

  pivot=eyepoint.Negated();
  cVec=target-eyepoint;
  focus = cVec.Magnitude();

  ax = (float)-atan2 (cVec.x, cVec.z);
  ay = (float)asin (cVec.y / focus);
  az = -roll;

  sinx = (float)sin (ax); cosx = (float)cos (ax); siny = (float)sin (ay);
  cosy = (float)cos (ay); sinz = (float)sin (az); cosz = (float)cos (az);

  m.xx =  (sinx * siny * sinz + cosx * cosz) * perspX;
  m.yx =  (cosy * sinz) * perspX;
  m.zx =  (sinx * cosz - cosx * siny * sinz) * perspX;

  m.xy =  (sinx * siny * cosz - cosx * sinz) * perspY;
  m.yy =  (cosy * cosz) * perspY;
  m.zy =  (-cosx * siny * cosz - sinx * sinz) * perspY;

  m.xz = (-sinx * cosy);
  m.yz = ( siny);
  m.zz = ( cosx * cosy);

  m.PreTranslation(pivot);
}


unsigned char* Camera::BuildCam(unsigned char *mem)
{
  eyepoint=Vector(*((float*)(mem+0)),*((float*)(mem+4)),*((float*)(mem+8)));
  mem+=3*sizeof(float);
  target=Vector(*((float*)(mem+0)),*((float*)(mem+4)),*((float*)(mem+8)));
  mem+=3*sizeof(float);
  roll=*((float*)(mem+0));
  mem+=4;
  return mem;
}

unsigned char* Camera::BuildCamKeys(unsigned char *mem)
{
  int l1,l2,l3;

  l1=*((unsigned short*)(mem));mem+=sizeof(unsigned short);
  l2=*((unsigned short*)(mem));mem+=sizeof(unsigned short);
  l3=*((unsigned short*)(mem));mem+=sizeof(unsigned short);

  posKeys=(float *) mem;mem+=l1*4*(sizeof(float));
  targetKeys=(float *) mem;mem+=l2*4*(sizeof(float));
  rollKeys=(float *) mem;mem+=l3*2*(sizeof(float));
  return mem;

}

void Scene3D::buildScene(unsigned char *mem)
{
  short t=0;
  Object3D *obj;
  while (t!=-1)
  {
    t=*((short*)mem);mem+=2;
    switch (t)
    {
      case 1:
        obj=new Object3D();
		mem=obj->BuildObj(mem,count%::texcount);
        o[count++]=obj;
      break;
      case 10:
        mem=cam.BuildCam(mem);
      break;
	  case 11:
		  mem=cam.BuildCamKeys(mem);
	break;
    }
  }
}

void Scene3D::buildfirstScene(LineFont* linefont)
{
  Object3D *obj;

  obj = new Object3D();
  obj->BuildText(linefont,"Farbrausch", 30, 10, 0, -0.008f, 1,1);
  o[count++]=obj;

  obj = new Object3D();
  obj->BuildText(linefont,"and", 0, -5, 0, -0.008f, 1,1);
  o[count++]=obj;

  obj = new Object3D();
  obj->BuildText(linefont,"ScoopeX", 20, -15, 0, -0.008f, 1,1);
  o[count++]=obj;
}


void Scene3D::buildsecondScene(LineFont* linefont)
{
  Object3D *obj;

  obj = new Object3D();
  obj->BuildText(linefont,"at", 30, 5, 0, -0.01f, 1,1);
  o[count++]=obj;

  obj = new Object3D();
  obj->BuildText(linefont,"ms2oo1", 20, -10, 0, -0.01f, 1,1);
  o[count++]=obj;

}


void Scene3D::buildthirdScene(LineFont* linefont)
{
  Object3D *obj;
 
  obj = new Object3D();
  obj->BuildText(linefont,"art", 20, 0, 0, -0.02f, 1,1);
  o[count++]=obj;

  obj=new Object3D();
  obj->BuildCube(8.0f);
  o[count++]=obj;
}

void Scene3D::buildgreetingScene(LineFont* linefont, char* text, float x, float y, float z, float size)
{
  for(int i=0; i<count; i++) delete o[i];
  count=0;
	
  Object3D *obj;

  obj = new Object3D();
  obj->BuildText(linefont,text, x, y, z, size, 1,1);
  o[count++]=obj;
}



void Scene3D::drawScene(float frame,LineList* ll,FaceList *fl)
{
  int i;

  if (cam.posKeys!=NULL)	  
	spline(cam.posKeys,frame,(float *) &(cam.eyepoint),3);
  if (cam.targetKeys!=NULL)	  
	spline(cam.targetKeys,frame,(float *) &(cam.target),3);

  cam.Camera2Matrix();
  for (i=0;i<count;i++)
  {
 	o[i]->Transform(cam.m);
	o[i]->Draw(ll,fl);
  }
}



void Scene3D::spline(float *keyArray,float curFrame,float *out,int numOfFloats)
{
  float sp_t,sp_t2,sp_t3;
  float k1,k2,k3,k4;
  float *keys;
  int i;


  keys=keyArray;
  while ( (keys[numOfFloats+1])<curFrame) keys+=numOfFloats+1;

  sp_t=(curFrame-keys[0])/(keys[numOfFloats+1]-keys[0]);
  sp_t2=sp_t*sp_t;
  sp_t3=sp_t2*sp_t;

  k1=(((-1.0f)/(6.0f)) * sp_t3 + (1.0f/2.0f) * sp_t2 - (1.0f/2.0f)*sp_t + (1.0f/6.0f));
  k2=(((1.0f)/(2.0f)) * sp_t3 - sp_t2 + (2.0f/3.0f));
  k3=(((-1.0f)/(2.0f)) * sp_t3 + (1.0f/2.0f) * sp_t2 + (1.0f/2.0f) * sp_t + (1.0f/6.0f));
  k4=(((1.0f)/(6.0f)) * sp_t3);



  for (i=0;i<numOfFloats;i++)
  {
    *(out++)=keys[i+1]*k1+keys[i+1+(1+numOfFloats)*1]*k2+keys[i+1+(1+numOfFloats)*2]*k3+keys[i+1+(1+numOfFloats)*3]*k4;
  }

} 
