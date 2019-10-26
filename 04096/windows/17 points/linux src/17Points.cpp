////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                                //
//                                                                                                                //
//                                       4k particle engine by BoyC                                               //
//                                                                                                                //
//                                                                                                                //
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Na itten a forras, hatha valaki hasznat veszi. Tudom hogy gany a kod, dehat ez van :) legalabb kommentezem nektek

// Linux/GCC/GLUT port by Charlie/iNQ <charlie@scenergy.dfmk.hu> (2003.07.25-26)
// Ported on a PowerMac 8500/AV, with 604e/200Mhz and ATi Radeon 7000 32MB DDR PCI
// Awfully slow on this old baby, hope will be faster on someone else's machine. :) 
// x86 still suxx anyway! :) Enjoy!

// This is the second version. Bugfixed particle display, now should look the same as
// the original version. Additionally you can now also exit by pressing escape, and 
// switch fullscreen on/off by pressing enter.

#include <GL/gl.h>
#include <GL/glu.h>
#include <GL/glut.h>
#include <math.h>
#include <float.h>
#include <stdlib.h>
#include <stdio.h>

#define oldposnum 8
#define numspheres 8
double radtheta=3.1415/180.0;

int time;                 //globalis timer
bool done;

float r=0.3,g=0.58,b=2; // a particle szine



float min(float a, float b)
{
 if (a<b) { return a; } else { return b; }
}

float max(float a, float b)
{
 if (a>b) { return a; } else { return b; }
}


// Itten kezdodik a lenyeg

unsigned char particle[64][64],map[64][64]; //particle textura, gomb envmap textura
unsigned char Floor[8][8]; // sakktabla

GLuint phandle,fhandle,mhandle;
GLUquadricObj *a=gluNewQuadric();

struct vector3
{
	float x,y,z;
};

struct sphere
{
	vector3 pos;
	float rad;
};

sphere spheres[8]; // a gombok

struct ptcle // egy particle
{
	vector3 pos,speed;
	vector3 oldpos[oldposnum]; // a csovahoz
	int life,lifestart;
};

ptcle particles[6000]; // particlek

vector3 campos; // kamera: pozicio, target
vector3 pi,pj; // a particle-k sikjanak ket egysegvektorat szamoljuk ide

float lensqr(vector3 v)
{
	return (v.x*v.x+v.y*v.y+v.z*v.z);
}

void createparticle(ptcle *p, int x) // ez a rutin letrehoz egy uj particle-t
{
	p->pos.y=((float)rand()/(float)RAND_MAX)*2-13;
	p->pos.x=1;//((float)rand()/(float)RAND_MAX-0.5)*10;
	p->pos.z=1;//((float)rand()/(float)RAND_MAX-0.5)*10;

	while (p->pos.x*p->pos.x+p->pos.z*p->pos.z>0.25) //kor alakba hulljanak a particlek
	{
		p->pos.x=((float)rand()/(float)RAND_MAX-0.5)*10;
		p->pos.z=((float)rand()/(float)RAND_MAX-0.5)*10;
	}

	if (x<2000)	// kek emitter
	{
		p->pos.x-=2;
		p->pos.z+=1;
	}
	else
	if (x<4000) // piros emitter
	{
		p->pos.x+=1;
		p->pos.z-=2;
	}
	else // zold emitter
	{
		p->pos.x+=2.7;
		p->pos.z+=2.7;
	}

	for (int a=0; a<oldposnum; a++) p->oldpos[a]=p->pos; //csova a kezdopontban
	p->speed.x=p->speed.y=p->speed.z=0; //kezdosebesseg 0
	p->life=p->lifestart=((float)rand()/(float)RAND_MAX)*30.0+350+(x<2000)*70-(x>=4000)*40; // ez a sor okozza hogy valtakozva hullanak az effekt elejen az emitterekbol a particlek
}

void initeffect() // init
{
	// a gombok adatai

	sphere *s=spheres;

	spheres[0].pos.x=-0.2;
	spheres[0].rad=2;

	spheres[1].pos.x=4;
	spheres[1].pos.y=-0.3;
	spheres[1].pos.z=-5.2;
	spheres[1].rad=2;
	
	spheres[2].pos.x=-2.2; 
	spheres[2].pos.z=1.4;
	spheres[2].rad=1.1;

	spheres[3].pos.x=1; 
	spheres[3].pos.y=-3;
	spheres[3].pos.z=-2;
	spheres[3].rad=1.2;

	spheres[4].pos.x=-4;
	spheres[4].pos.y=-0.75;
	spheres[4].pos.z=-3;
	spheres[4].rad=1.5;

	spheres[5].pos.x=4;
	spheres[5].pos.y=-0.5;
	spheres[5].rad=1;

	spheres[6].pos.x=3;
	spheres[6].pos.z=3.4;
	spheres[6].rad=1.6;

	spheres[7].pos.x=-1;
	spheres[7].pos.z=3.4;
	spheres[7].rad=1;

	// textura generalas
	for (int x=0; x<64; x++) 
		for (int y=0; y<64; y++)
		{
			particle[x][y]=max(0.0,255.0-(sqrt( (x-32)*(x-32) + (y-32)*(y-32) )*8.0))/3;
			map[x][y]=255-particle[x][y]*3;
		}

	for (int x=0; x<32; x++)
		for (int y=0; y<32; y++)
			particle[x+16][y+16]=min(255,particle[x+16][y+16]+(particle[x*2][y*2])*2);

	glGenTextures(1,&phandle);
	glBindTexture(GL_TEXTURE_2D,phandle);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D,0,1,64,64,0,GL_RED,GL_UNSIGNED_BYTE,particle);

	glGenTextures(1,&mhandle);
	glBindTexture(GL_TEXTURE_2D,mhandle);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D,0,1,64,64,0,GL_RED,GL_UNSIGNED_BYTE,map);

	// sakktabla generalas
	bool a;
	for (int x=0; x<8; x++)	{
		for (int y=0; y<8; y++)		{
			a=!a;
			Floor[x][y]=a*64+64;		}
		a=!a;
	}

	glGenTextures(1,&fhandle);
	glBindTexture(GL_TEXTURE_2D,fhandle);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_NEAREST);
	glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_NEAREST);
	glTexImage2D(GL_TEXTURE_2D,0,1,8,8,0,GL_RED,GL_UNSIGNED_BYTE,Floor);
}

vector3 cross(vector3 b, vector3 c)
{
	vector3 buf;
	buf.x=(b.y * c.z) - (b.z * c.y);
	buf.y=(b.z * c.x) - (b.x * c.z);
	buf.z=(b.x * c.y) - (b.y * c.x);
	return buf;
}

vector3 egyseg( vector3 a)
{
	vector3 buf;
	float s=sqrt(lensqr(a));
	buf.x=a.x/s;
	buf.y=a.y/s;
	buf.z=a.z/s;
	return buf;
}

void countparticleplane() //ez a rutin szamolja ki a particle-k sikjanak ket egysegvektorat
{
	vector3 camdir; //ide szamoljuk a target-eye vektort, erre meroleges sikon kell ket egysegvektor
	camdir.x=-campos.x;
	camdir.y=-1-campos.y;
	camdir.z=-campos.z;
	vector3 up;
	up.x=up.z=0;
	up.y=-1;
	pi=egyseg(cross(camdir,up)); // ez a vektor rajta lesz a keresett sikon, meroleges lesz a camdir-up vektorok sikjara
	pj=egyseg(cross(camdir,pi)); // ez a vektor lesz a masik keresett egysegvektor
	pi.x*=0.2; // igen, tul nagyok voltak a particlek ;)
	pi.y*=0.2;
	pi.z*=0.2;
	pj.x*=0.2;
	pj.y*=0.2;
	pj.z*=0.2;
}

void drawparticle(vector3 pos) //kirajzol egy particle-t
{
	glTexCoord2f(0,0);
	glVertex3f(pos.x-pi.x-pj.x,pos.y-pi.y-pj.y,pos.z-pi.z-pj.z);
	glTexCoord2f(1,0);
	glVertex3f(pos.x+pi.x-pj.x,pos.y+pi.y-pj.y,pos.z+pi.z-pj.z);
	glTexCoord2f(1,1);
	glVertex3f(pos.x+pi.x+pj.x,pos.y+pi.y+pj.y,pos.z+pi.z+pj.z);
	glTexCoord2f(0,1);
	glVertex3f(pos.x-pi.x+pj.x,pos.y-pi.y+pj.y,pos.z-pi.z+pj.z);
}

void drawfloor() //a talajt rajzolja ki
{
	glBegin(GL_QUADS);

	glTexCoord2f(0,0);
	glVertex3i(-5,0,-5);
	glTexCoord2f(1,0);
	glVertex3i(5,0,-5);
	glTexCoord2f(1,1);
	glVertex3i(5,0,5);
	glTexCoord2f(0,1);
	glVertex3i(-5,0,5);

	glEnd();
}

void drawsphere(float x, float y, float z, float r) // kirajzol egy gombot
{
	glTranslatef(x,y,z);
	gluSphere(a,r,48,48);
	glTranslatef(-x,-y,-z);
}

void calcsphere(ptcle *pt, float x, float y, float z, float k) //kiszamolja egy particle utkozeset egy gombbel
{
	float r=k*k;

	vector3 v0; // a particle pozicioja a gomb kozeppontjahoz kepest
	v0.x=x-pt->pos.x;
	v0.y=y-pt->pos.y;
	v0.z=z-pt->pos.z;
	
	float cc=lensqr(v0); // tavolsag a kozepponttol
	
	vector3 a; // a particle kovetkezo allapotanak pozicioja a gomb kozeppontjahoz kepest
	a.x=v0.x-pt->speed.x;
	a.y=v0.y-pt->speed.y;
	a.z=v0.z-pt->speed.z;

	float d2=lensqr(a); // tavolsag a kozepponttol

	if (cc>r && d2<=r) 	// ha a particle a gombon kivul van, de a kovetkezo idopillanatban mar a gombon belul lenne,
				// akkor utkozik
	{
    	    // az utkozes szamitasa: kiszamolja a pontot ahol talalkozna a particle a gombbel, veszi az abba mutato
	    // sugarat, es tukrozi ra a sebessegvektort
		
		float a,b,c;
		a=lensqr(pt->speed);
		
		b=2*(v0.x+v0.y+v0.z);
		c=cc-r;

		float b4ac=sqrt(b*b-4*a*c); //sqrt(b^2-4*a*c) ismeros? :)
		float t;

		t=(-b+b4ac)/(2*a);
		if (t>=1) t=(-b-b4ac)/(2*a); //az 1nel kisebb t kell (t=1 a particle kovetkezo allapota)

		vector3 p,d;
		p.x=pt->pos.x+pt->speed.x*t; // az utkozesi pont
		p.y=pt->pos.y+pt->speed.y*t;
		p.z=pt->pos.z+pt->speed.z*t;
		
		d.x=x-p.x; // a sugar
		d.y=y-p.y;
		d.z=z-p.z;
		d=egyseg(d);

		float len=sqrt(a); // a particle sebessegenek nagysaga
		
		pt->pos.x=p.x+(1.0-t)*pt->speed.x; //jo helyen legyen a particle az utkozes utan
		pt->pos.y=p.y+(1.0-t)*pt->speed.y;
		pt->pos.z=p.z+(1.0-t)*pt->speed.z;

		vector3 i=cross(egyseg(pt->speed),d); // az utkozesi pontban a sugarbol es a sebessegbol szamitott sik
		vector3 j=cross(i,d); 

		a=(pt->speed.y*j.x-pt->speed.x)/(i.y*j.x-i.x);
		b=(pt->speed.x-a*i.x)/j.x;

		vector3 s;

		s.x=a*i.x-b*j.x; // tukrozes a sikon
		s.y=a*i.y-b*j.y;
		s.z=a*i.z-b*j.z;
		s=egyseg(s);

		len*=0.5; //az eredeti sebessegbol veszit

		pt->speed.x=s.x*len;
		pt->speed.y=s.y*len;
		pt->speed.z=s.z*len;

	}
}

void mainloop()
{
    time++; //mulik az ido
    
    glLoadIdentity();
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    campos.x=8.0*sin(time/10.0*radtheta); //kameramozgas
    campos.y=-4+cos(time/2.0*radtheta);
    campos.z=7.0*cos(time/5.0*radtheta);

    spheres[2].pos.y=-4+(3*cos(time/6.0*radtheta)); // a kek emitter alatti gomb animalasa

    gluLookAt(campos.x,campos.y,campos.z,0,-1,0,0,-1,0); //kamera
    countparticleplane(); // particle sik szamitasa

    glDisable(GL_BLEND);
    glColor4f(0.3,0.3,0.3,1);

    glBindTexture(GL_TEXTURE_2D,mhandle); //envmap textura

    glEnable(GL_TEXTURE_GEN_S); // envmap bekapcsolasa
    glEnable(GL_TEXTURE_GEN_T);
    glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
    glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

    // gombok rajzolasa
    for (int x=0; x<numspheres; x++) drawsphere(spheres[x].pos.x,spheres[x].pos.y,spheres[x].pos.z,spheres[x].rad);

    glDisable(GL_TEXTURE_GEN_S); //envmap kikapcsolasa
    glDisable(GL_TEXTURE_GEN_T);

    glBindTexture(GL_TEXTURE_2D,fhandle); //sakktabla
    glColor4f(1,1,1,1);
    drawfloor(); //fold rajzolas

    glEnable(GL_BLEND);
    glDepthMask(false); // nem irunk a zbufferbe
    glBindTexture(GL_TEXTURE_2D,phandle); // particle textura
    glBegin(GL_QUADS);
			
    for (int x=0; x<6000; x++) // a particlek szamitasa
    {
	float a;

	ptcle *p=&particles[x];
				
	a=p->life/(float)p->lifestart;
				
	if (x<2000) 
	    glColor4f(r,g,b,a); // kek emitter
	else
        if (x<4000)         // piros emitter
	    glColor4f(b,g,r,a);
	else
	    glColor4f(r,b,g,a); // zold emitter

	if (!isnan(p->speed.x) && !isnan(p->speed.y) && !isnan(p->speed.z)) // ... a sebesseg miatt...
	{
	    drawparticle(p->pos); // kirajzolja a particle-t

	    glEnd(); 
	    glBegin(GL_LINE_STRIP); //jon a csova
	    for (int a=0; a<oldposnum; a++)
	    {
		float b=a/(float)oldposnum*0.3+0.2;
		glTexCoord2f(b,b);
		glVertex3f(p->oldpos[a].x,p->oldpos[a].y,p->oldpos[a].z);
	    }
	    glEnd();
	    glBegin(GL_QUADS);
	    for (int a=0; a<oldposnum-1; a++) p->oldpos[a]=p->oldpos[a+1];
	    p->oldpos[oldposnum-1]=p->pos;

	    //fold utkozes szamitasa: ha a kovetkezo pillanatig atlepne az y=0 sikot a [-5..5][-5..5] intervallumon
	    //akkor megpattan
	    if (p->pos.y<0 && p->pos.y+p->speed.y>=0 && fabs(p->pos.x)<5 && fabs(p->pos.z)<5) p->speed.y*=-0.4;

	    //gombok szamitasa
	    for (int y=0; y<numspheres; y++) calcsphere(p,spheres[y].pos.x,spheres[y].pos.y,spheres[y].pos.z,spheres[y].rad);

	    p->pos.x+=p->speed.x; //particle mozgatasa
	    p->pos.y+=p->speed.y;
	    p->pos.z+=p->speed.z;

	    p->speed.y+=0.0015; // gravitacio
	}

	p->life--; // particle eletenek csokkentese
	if (p->life<0) createparticle(p,x); //ha a particle "meghalt" akkor ujat csinal helyette
    }
			
    glEnd();
    glDepthMask(true);		
    glutSwapBuffers();
}

void ontimer(int value)
{
 glutPostRedisplay();
 glutTimerFunc(20,ontimer,0);
}

int fullscreen = 0;

void keyboard(unsigned char key, int x, int y)
{
    switch( key ) {
	case 27:
	    exit(0);
    	    break;
	case 13:
	    fullscreen=1-fullscreen;
	    if (fullscreen==1) { glutFullScreen(); } else { glutReshapeWindow(640,480); }
	    break;
	default:
	    break;
    }
}

void main()
{
	glutInitWindowPosition(0,0);
	glutInitWindowSize(640,480);

        glutInitDisplayMode(GLUT_RGB + GLUT_DOUBLE + GLUT_DEPTH);
	glutCreateWindow("17 points");
	
//	Remove the comment from the lines below if you want it fullscreen by default!	
//	glutFullScreen();
//	fullscreen = 1;

	glutDisplayFunc(mainloop);
	glutTimerFunc(20,ontimer,0);
	glutKeyboardFunc(keyboard);
	
	glEnable(GL_DEPTH_TEST); // opengl init
	glEnable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA,GL_ONE);
	glMatrixMode(GL_PROJECTION);
	gluPerspective(90,4/3.0,1,100.0);
	glMatrixMode(GL_MODELVIEW);
	
	initeffect(); // inicializalas

	glutMainLoop();	
	return 0;
}
