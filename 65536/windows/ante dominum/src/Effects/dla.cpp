#include "dla.hpp"

Lista *DLAList;

const int dlacount = 1;
const int dlapointcount = 25000;
const int dim = 100;

void DLASystem::draw(float aika, float alpha)
{
	int i;
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	
	glPointSize(5);

	int count = (int)(this->pointcount*aika);
	glBegin(GL_POINTS);
	for (i=0;i<count;i++)
	{
		glColor4f(colors[i].x, colors[i].y, colors[i].z, alpha*alphas[i]);
		glVertex3fv((float *)&this->points[i]);
		glVertex3fv((float *)&this->points2[i]);
	}
	glEnd();
}

DLASystem::DLASystem(int count)
{
	int i;
	int x, y, z;
	this->pointcount = count;
	this->points = new Vector[this->pointcount];
	this->points2 = new Vector[this->pointcount];
	this->colors = new Vector[this->pointcount];
	this->alphas = new float[this->pointcount];

//	bool temp[dim][dim][dim];// = new bool[dim*dim*dim];

	bool ***temp;
	temp = new bool**[dim];
	for (y=0;y<dim;y++)
	{
		temp[y] = new bool*[dim];
		for (x=0;x<dim;x++)
		{
			temp[y][x] = new bool[dim];
		}
	}

	const float scale = 4;

	for (z=0;z<dim;z++)
	{
		for (y=0;y<dim;y++)
		{
			for (x=0;x<dim;x++)
			{
				temp[z][y][x] = false;
			}
		}
	}

	temp[dim/2][dim/2][dim/2] = true;

	for (i=0;i<this->pointcount;i++)
	{
		int nx = rand()%dim;
		int ny = rand()%dim;
		int nz = rand()%dim;

		int ox = nx;
		int oy = ny;
		int oz = nz;

		do
		{
			if (safeget(nx, ny, nz))
			{
				//ollaan jossain kohtaa ruudukon keskiosissa
/*				if (temp[nx][ny-1][nz] ||
					temp[nx][ny+1][nz] ||
					temp[nx-1][ny][nz] ||
					temp[nx+1][ny][nz] ||
					temp[nx][ny][nz+1] ||
					temp[nx][ny][nz-1])
*/
				if (temp[nx-1][ny-1][nz-1] ||
					temp[nx][ny-1][nz-1]||
					temp[nx+1][ny-1][nz-1] ||				
					temp[nx-1][ny-1][nz] ||
					temp[nx][ny-1][nz]||
					temp[nx+1][ny-1][nz] ||				
					temp[nx-1][ny-1][nz+1] ||
					temp[nx][ny-1][nz+1]||
					temp[nx+1][ny-1][nz+1] ||
					temp[nx-1][ny][nz-1] ||
					temp[nx][ny][nz-1]||
					temp[nx+1][ny][nz-1] ||				
					temp[nx-1][ny][nz] ||
					temp[nx+1][ny][nz] ||				
					temp[nx-1][ny][nz+1] ||
					temp[nx][ny][nz+1]||
					temp[nx+1][ny][nz+1] ||
					temp[nx-1][ny+1][nz-1] ||
					temp[nx][ny+1][nz-1]||
					temp[nx+1][ny+1][nz-1] ||				
					temp[nx-1][ny+1][nz] ||
					temp[nx][ny+1][nz]||
					temp[nx+1][ny+1][nz] ||				
					temp[nx-1][ny+1][nz+1] ||
					temp[nx][ny+1][nz+1]||
					temp[nx+1][ny+1][nz+1])
				{
					temp[nx][ny][nz] = true;

					//lisätään piste piirtolistaan
					const float randscale = 0.0f;

					Vector r = randomSphereVector(randscale);
					Vector point = Vector(nx-dim/2.0f, ny-dim/2.0f, nz-dim/2.0f) + r;
					Vector ppoint = Vector(ox-dim/2.0f, oy-dim/2.0f, oz-dim/2.0f);
					points[i] = point;
					points2[i] = ppoint;
					const float maxlength = Vector(dim/2.0f, dim/2.0f, dim/2.0f).length();
					alphas[i] = (float)pow((maxlength-ppoint.length())/maxlength, 2);
					colors[i] = Vector(1, 0, 0)*(alphas[i]) + Vector(0,0,0)*(1-alphas[i]);

					break;
				}
			}
			else 
			{
				//osuttiin reunaan, arvotaan uusi piste
//				nx = rand()%dim;
//				ny = rand()%dim;
//				nz = rand()%dim;
					const float randscale = 0.0f;

					temp[nx][ny][nz] = true;
					Vector r = randomSphereVector(randscale);
					Vector point = Vector(nx-dim/2.0f, ny-dim/2.0f, nz-dim/2.0f) + r;
					Vector ppoint = Vector(ox-dim/2.0f, oy-dim/2.0f, oz-dim/2.0f);
					points[i] = point;
					points2[i] = ppoint;
					const float maxlength = Vector(dim/2.0f, dim/2.0f, dim/2.0f).length();
					alphas[i] = (float)pow((maxlength-ppoint.length())/maxlength, 2);
					colors[i] = Vector(1, 0, 0)*(alphas[i]) + Vector(0,0,0)*(1-alphas[i]);

					break;
			}

			//ei osuttu mihinkään, liikutaan

			ox = nx;
			oy = ny;
			oz = nz;
			switch(rand()%6)
			{
				case 0: nx++; break;
				case 1: nx--; break;
				case 2: ny++; break;
				case 3: ny--; break;
				case 4: nz++; break;
				case 5: nz--; break;
			}

		} while(true);
	}
}

DLASystem::~DLASystem()
{
	delete [] this->points;
	delete [] this->colors;
	delete [] this->points2;
	delete [] this->alphas;
}

bool DLASystem::safeget(int xt, int yt, int zt)
{
	if (xt <= 0)
		return false;
	if (yt <= 0)
		return false;
	if (zt <= 0)
		return false;
	if (xt >= dim-1)
		return false;
	if (yt >= dim-1)
		return false;
	if (zt >= dim-1)
		return false;

	return true;
}

void dla(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector campos = Vector(0, 40, -100.0f-20*(float)sin(aika*2*3.141592f));
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(aika*130, 0, 1, 0.2f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	DLAList->goToStart();
	DLASystem *s = (DLASystem *)DLAList->getCurrent();

	float fogcol[] = {1,1,1,1};

	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 90);
	glFogf(GL_FOG_END, 100);
	glEnable(GL_FOG);

	s->draw(aika, alpha);

	glDisable(GL_FOG);

}

void dla_init()
{
	int i;
	DLAList = new Lista();

	srand(6501);
	setSeed(16981);
	
	for (i=0;i<dlacount;i++)
	{
		DLASystem *s = new DLASystem(dlapointcount);
		DLAList->add(s);

	}
}

void dla_free()
{
	delete DLAList;
} 
