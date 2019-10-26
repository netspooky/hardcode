#include "ScnBlobs.h"
#include "meta_tables.h"

void ScnBlobs::iniGrids(void)
{
	int x, y, z;
	float xmin, ymin, zmin;
	float incr;
	float px, py, pz;

	xmin = -1.0f;
	ymin = -1.0f;
	zmin = 1.0f;
	incr = 2.0f/((float)MB_RES);

	PUNTOS = new pCube[MB_RES+1][MB_RES+1][MB_RES+1];
	CELDAS = new Cube[MB_RES][MB_RES][MB_RES];

	for(x=0;x<=MB_RES;x++) {
		px = xmin + incr*x;
		for(y=0;y<=MB_RES;y++) {
			py = ymin + incr*y;
			for(z=0;z<=MB_RES;z++) {
				pz = zmin - incr*z;

				PUNTOS[x][y][z].pos.x = px;
				PUNTOS[x][y][z].pos.y = py;
				PUNTOS[x][y][z].pos.z = pz;
			}
		}
	}

	for(x=0;x<MB_RES;x++)
		for(y=0;y<MB_RES;y++)
			for(z=0;z<MB_RES;z++) {
					CELDAS[x][y][z].P[0]=&PUNTOS[x]  [y]  [z];
					CELDAS[x][y][z].P[1]=&PUNTOS[x+1][y]  [z];
					CELDAS[x][y][z].P[2]=&PUNTOS[x+1][y]  [z+1];
					CELDAS[x][y][z].P[3]=&PUNTOS[x]  [y]  [z+1];
					CELDAS[x][y][z].P[4]=&PUNTOS[x]  [y+1][z];
					CELDAS[x][y][z].P[5]=&PUNTOS[x+1][y+1][z];
					CELDAS[x][y][z].P[6]=&PUNTOS[x+1][y+1][z+1];
					CELDAS[x][y][z].P[7]=&PUNTOS[x]  [y+1][z+1];
			}
}

void ScnBlobs::iniMetaballs(void)
{
	metaCock[0].mass = (float)0.20;
	metaCock[0].pos.x = 0.0;
	metaCock[0].pos.y = 0.0;
	metaCock[0].pos.z = 0.0;

	metaCock[1].mass = (float)0.25;
	metaCock[1].pos.x = 0.0;
	metaCock[1].pos.y = 0.0;
	metaCock[1].pos.z = 0.0;

	metaCock[2].mass = (float)0.20;
	metaCock[2].pos.x = 0.0;
	metaCock[2].pos.y = 0.0;
	metaCock[2].pos.z = 0.0;

	metaCock[3].mass = (float)0.20;
	metaCock[3].pos.x = 0.0;
	metaCock[3].pos.y = 0.0;
	metaCock[3].pos.z = 0.0;

	metaCock[4].mass = (float)0.20;
	metaCock[4].pos.x = 0.0;
	metaCock[4].pos.y = 0.0;
	metaCock[4].pos.z = 0.0;
}

void ScnBlobs::pintaCelda(Cube *grid)
{
	int i;
	int cubeid;
	vertex  verts[12];
	vertex	normal[12];

	cubeid = 0;
	if(grid->P[0]->value < ISO_Level ) cubeid |= 1;
	if(grid->P[1]->value < ISO_Level ) cubeid |= 2;
	if(grid->P[2]->value < ISO_Level ) cubeid |= 4;
	if(grid->P[3]->value < ISO_Level ) cubeid |= 8;
	if(grid->P[4]->value < ISO_Level ) cubeid |= 16;
	if(grid->P[5]->value < ISO_Level ) cubeid |= 32;
	if(grid->P[6]->value < ISO_Level ) cubeid |= 64;
	if(grid->P[7]->value < ISO_Level ) cubeid |= 128;

	if(edgeTable[cubeid]==0)
		return;

	if(edgeTable[cubeid] & 1)
		verts[0]=interpolate(grid->P[0],grid->P[1],&normal[0]);
	if(edgeTable[cubeid] & 2)
		verts[1]=interpolate(grid->P[1],grid->P[2],&normal[1]);
	if(edgeTable[cubeid] & 4)
		verts[2]=interpolate(grid->P[2],grid->P[3],&normal[2]);
	if(edgeTable[cubeid] & 8)
		verts[3]=interpolate(grid->P[3],grid->P[0],&normal[3]);
	if(edgeTable[cubeid] & 16)
		verts[4]=interpolate(grid->P[4],grid->P[5],&normal[4]);
	if(edgeTable[cubeid] & 32)
		verts[5]=interpolate(grid->P[5],grid->P[6],&normal[5]);
	if(edgeTable[cubeid] & 64)
		verts[6]=interpolate(grid->P[6],grid->P[7],&normal[6]);
	if(edgeTable[cubeid] & 128)
		verts[7]=interpolate(grid->P[7],grid->P[4],&normal[7]);
	if(edgeTable[cubeid] & 256)
		verts[8]=interpolate(grid->P[0],grid->P[4],&normal[8]);
	if(edgeTable[cubeid] & 512)
		verts[9]=interpolate(grid->P[1],grid->P[5],&normal[9]);
	if(edgeTable[cubeid] & 1024)
		verts[10]=interpolate(grid->P[2],grid->P[6],&normal[10]);
	if(edgeTable[cubeid] & 2048)
		verts[11]=interpolate(grid->P[3],grid->P[7],&normal[11]);

	i = 0;
	glDisable(GL_TEXTURE_2D);
	glDisable(GL_LIGHTING);
	glColor3f(0.5f,0.5f,0.0f);
	glBegin(GL_TRIANGLES);
		while(triTable[cubeid][i] != -1){

			glNormal3f(normal[triTable[cubeid][i]].x,normal[triTable[cubeid][i]].x,normal[triTable[cubeid][i]].x);
			glVertex3f(verts[triTable[cubeid][i]].x,verts[triTable[cubeid][i]].y,verts[triTable[cubeid][i]].z);

			glNormal3f(normal[triTable[cubeid][i+1]].x,normal[triTable[cubeid][i+1]].x,normal[triTable[cubeid][i+1]].x);
			glVertex3f(verts[triTable[cubeid][i+1]].x,verts[triTable[cubeid][i+1]].y,verts[triTable[cubeid][i+1]].z);

			glNormal3f(normal[triTable[cubeid][i+2]].x,normal[triTable[cubeid][i+2]].x,normal[triTable[cubeid][i+2]].x);
			glVertex3f(verts[triTable[cubeid][i+2]].x,verts[triTable[cubeid][i+2]].y,verts[triTable[cubeid][i+2]].z);

			i = i + 3;
		}
	glEnd();
}

vertex ScnBlobs::interpolate(pCube *p1,pCube *p2,vertex *normal)
{
	float	mu;
	vertex	aux;

	if(fabs(p1->value) == ISO_Level){
		normal = &p1->normal;
		return p1->pos;

	}
	else{
		if(fabs(p2->value) == ISO_Level){
			normal = &p2->normal;
			return p2->pos;
		}
		else{
			if(p1->value == p2->value){
				normal = &p1->normal;
				return p1->pos;
			}
			else{
				mu = (ISO_Level - p1->value) / (p2->value - p1->value);

				aux.x = p1->pos.x + mu * (p2->pos.x - p1->pos.x);
				aux.y = p1->pos.y + mu * (p2->pos.y - p1->pos.y);
				aux.z = p1->pos.z + mu * (p2->pos.z - p1->pos.z);

				normal->x = p1->normal.x + (p2->normal.x - p1->normal.x) * mu;
				normal->y = p1->normal.y + (p2->normal.y - p1->normal.y) * mu;
				normal->z = p1->normal.z + (p2->normal.z - p1->normal.z) * mu;

				return aux;
			}
		}
	}
}

vertex ScnBlobs::normalizarVector(vertex p)
{
	float len;

	len = sqrt(sqr(p.x) + sqr(p.y) + sqr(p.z));

	if(len != 0) {
		p.x = p.x / len;
		p.y = p.y / len;
		p.z = p.z / len;
	}

	return p;
}

float ScnBlobs::evaluate(float mass,vertex a,vertex b)
{
	return sqr(mass) / ((sqr(a.x - b.x) + sqr(a.y - b.y) + sqr(a.z - b.z)));
}

int ScnBlobs::setup(int reason)
{
	

	glViewport(0,0,640,480);
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	gluPerspective(45.0f,(GLfloat)640/(GLfloat)480,0.1f,100.0f);
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();

	glShadeModel(GL_SMOOTH);

	glEnable(GL_DEPTH_TEST);
	glDepthFunc(GL_LESS);	//GL_LEQUAL

	GLfloat lightAmbient[]={0.5,0.0,0.0,1.0};
	GLfloat lightDiffuse_0[]={1.0,0.0,0.0,1.0};
	GLfloat lightDiffuse_1[]={0.75,0.2,0.0,1.0};
	GLfloat lightPosition_0[]={0.0,0.0,10.0};
	GLfloat lightPosition_1[]={0.0,0.0,-10.0};
	GLfloat lightPosition_2[]={10.0,0.0,1.0};
	GLfloat lightPosition_3[]={-10.0,0.0,1.0};
	
	glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse_0);
	glLightfv(GL_LIGHT0, GL_POSITION, lightPosition_0);
	glLightfv(GL_LIGHT1, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT1, GL_DIFFUSE, lightDiffuse_1);
	glLightfv(GL_LIGHT1, GL_POSITION, lightPosition_1);
	glLightfv(GL_LIGHT2, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT2, GL_DIFFUSE, lightDiffuse_0);
	glLightfv(GL_LIGHT2, GL_POSITION, lightPosition_2);
	glLightfv(GL_LIGHT3, GL_AMBIENT, lightAmbient);
	glLightfv(GL_LIGHT3, GL_DIFFUSE, lightDiffuse_1);
	glLightfv(GL_LIGHT3, GL_POSITION, lightPosition_3);
	
	glEnable(GL_LIGHT0);
	glEnable(GL_LIGHT1);
	glEnable(GL_LIGHT2);
	glEnable(GL_LIGHT3);
	
	glClearColor(0.25,0.25,0.25,1.0);
	iniMetaballs();
	iniGrids();

	glBlendFunc(GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);

	glClearColor(0.25f, 0.25f, 0.25f, 1.0f);
	
	return 0;
}

int ScnBlobs::run(long time)
{
	if(_setup == false)
	{
		this->setup(0);
		_setup = true;
	}
	
	int cx, cy, cz,i;
	float value;

	glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
	glLoadIdentity();

	metaCock[0].pos.x = 0.5*sin(time/400.0);
	metaCock[0].pos.y = 0.1*cos(time/650.0);
	metaCock[0].pos.z = 0.1*sin(time/150.0);

	metaCock[1].pos.x = 0.25*cos(time/750.0);
	metaCock[1].pos.y = 0.3*sin(time/250.0);
	metaCock[1].pos.z = 0.1*sin(time/350.0);

	metaCock[2].pos.z = 0.25*sin(time/250.0);
	metaCock[2].pos.y = 0.05*sin(time/250.0);
	metaCock[2].pos.z = 0.75*sin(time/350.0);

	metaCock[3].pos.z = 0.5*sin(time/250.0);
	metaCock[3].pos.y = 0.5*sin(time/250.0);
	metaCock[3].pos.z = 0.07*sin(time/350.0);

	metaCock[4].pos.x = 0.5*sin(time/400.0);
	metaCock[4].pos.y = 0.1*cos(time/650.0);

	for(cx=0;cx<MB_RES+1;cx++){
		for(cy=0;cy<MB_RES+1;cy++){
			for(cz=0;cz<MB_RES+1;cz++){
				value = 0;
				for(i=0;i<5;i++){
					value = value + evaluate(metaCock[i].mass,PUNTOS[cx][cy][cz].pos,metaCock[i].pos);
				}

				PUNTOS[cx][cy][cz].value = value;
			}
		}
	}

	for(cx=1;cx<MB_RES-1;cx++){
		for(cy=1;cy<MB_RES-1;cy++){
			for(cz=1;cz<MB_RES-1;cz++){
				PUNTOS[cx][cy][cz].normal.x = PUNTOS[cx-1][cy][cz].value - PUNTOS[cx+1][cy][cz].value;
				PUNTOS[cx][cy][cz].normal.y = PUNTOS[cx][cy-1][cz].value - PUNTOS[cx][cy+1][cz].value;
				PUNTOS[cx][cy][cz].normal.z = PUNTOS[cx][cy][cz-1].value - PUNTOS[cx][cy][cz+1].value;

				PUNTOS[cx][cy][cz].normal = normalizarVector(PUNTOS[cx][cy][cz].normal);
			}
		}
	}

	glEnable(GL_TEXTURE_2D);
	glPolygonMode(GL_FRONT_AND_BACK,GL_LINE);
	glLoadIdentity();
		glTranslatef(1.0,0.5,-5.0f);

		glTranslatef((float)(sin(time/20.0f))/8.0f,0.0f,0.0f);
		glTranslatef(0.0f,(float)(cos(time/20.0f))/8.0f,0.0f);
		glTranslatef(0.0f,0.0f,(float)(sin(time/20.0f))/8.0f);

		glScalef(1.5f,1.5f,1.5f);
		
		//glColor4f(0.0f,0.0f,0.0f,0.2f);
		glBegin(GL_QUADS);
			glTexCoord2f(0.0f,0.0f);
			glVertex3f(-1.0f,1.0f,0.0f);
			glTexCoord2f(1.0f,0.0f);
			glVertex3f(-1.0f,-1.0f,0.0f);
			glTexCoord2f(1.0f,1.0f);
			glVertex3f(1.0f,-1.0f,0.0f);
			glTexCoord2f(0.0f,1.0f);
			glVertex3f(1.0f,1.0f,0.0f);
		glEnd();

	glLoadIdentity();
		glTranslatef(1.0,0.5,-5.0f);

		glTranslatef((float)(sin(time/20.0f))/8.0f,0.0f,0.0f);
		glTranslatef(0.0f,(float)(cos(time/20.0f))/8.0f,0.0f);
		glTranslatef(0.0f,0.0f,(float)(sin(time/20.0f))/8.0f);

		glScalef(3.5f,3.5f,1.5f);
		
		//glColor4f(0.0f,0.0f,0.0f,0.1f);
		glBegin(GL_QUADS);
			glTexCoord2f(0.0f,0.0f);
			glVertex3f(-1.0f,1.0f,0.0f);
			glTexCoord2f(1.0f,0.0f);
			glVertex3f(-1.0f,-1.0f,0.0f);
			glTexCoord2f(1.0f,1.0f);
			glVertex3f(1.0f,-1.0f,0.0f);
			glTexCoord2f(0.0f,1.0f);
			glVertex3f(1.0f,1.0f,0.0f);
		glEnd();

	glLoadIdentity();
		glTranslatef(1.0,0.5,-5.0f);

		glTranslatef((float)(sin(time/20.0f))/8.0f,0.0f,0.0f);
		glTranslatef(0.0f,(float)(cos(time/20.0f))/8.0f,0.0f);
		glTranslatef(0.0f,0.0f,(float)(sin(time/20.0f))/8.0f);

		glScalef(6.5f,6.5f,1.5f);
		
		//glColor4f(0.0f,0.0f,0.0f,0.05f);
		glBegin(GL_QUADS);
			glTexCoord2f(0.0f,0.0f);
			glVertex3f(-1.0f,1.0f,0.0f);
			glTexCoord2f(1.0f,0.0f);
			glVertex3f(-1.0f,-1.0f,0.0f);
			glTexCoord2f(1.0f,1.0f);
			glVertex3f(1.0f,-1.0f,0.0f);
			glTexCoord2f(0.0f,1.0f);
			glVertex3f(1.0f,1.0f,0.0f);
		glEnd();

	glClear(GL_DEPTH_BUFFER_BIT);

	glDisable(GL_TEXTURE_2D);

	glLoadIdentity();
	glEnable(GL_LIGHTING);

	glTranslatef(0.5,0.25,-2.5f);

	//glScalef(1.,1.2,1.2);

	glRotatef(time/100.0,0.0,1.0,0.0);
	glRotatef(time/200.0,1.0,0.0,0.0);
	glRotatef(time/150.0,0.0,0.0,1.0);

	//glColor4f(1.0f,1.0f,0.0f,1.0f);
	glTranslatef(-1.0f,-0.5f,0.0f);		
	for(cx=0;cx<MB_RES;cx++){
		for(cy=0;cy<MB_RES;cy++){
			
			for(cz=0;cz<MB_RES;cz++){
				
				pintaCelda(&CELDAS[cx][cy][cz]);
			}
		}
	}

	glDisable(GL_LIGHTING);

	glClear(GL_DEPTH_BUFFER_BIT);

	return 0;
}

void ScnBlobs::free()
{
}
