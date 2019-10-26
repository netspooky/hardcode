#include "kaupunki.hpp"
#include "../linestrip.hpp"

const int xdim = 200;
const int zdim = 200;
const int ydim = 10;
CitySystem *city;

void CitySystem::draw(float aika, float alpha)
{
	int i;
	
	int count = (int)(this->pointcount*aika);
	const float frac = this->pointcount*aika - count;

	glPointSize(5);
	glLineWidth(2);
	glBegin(GL_POINTS);
	for (i=0;i<count;i++)
	{
		if (i==count-1)
			glColor4f(colors[i].x, colors[i].y, colors[i].z, alpha*alphas[i]*frac);
		else
			glColor4f(colors[i].x, colors[i].y, colors[i].z, alpha*alphas[i]);
		glVertex3fv((float *)&(this->points[i]));
		glVertex3fv((float *)&(this->points2[i]));
	}
	glEnd();

	alpha *= 2;
	glBegin(GL_LINES);
	for (i=0;i<count;i++)
	{
		if (i==count-1)
			glColor4f(colors[i].x, colors[i].y, colors[i].z, alpha*alphas[i]*frac);
		else
			glColor4f(colors[i].x, colors[i].y, colors[i].z, alpha*alphas[i]);
		glVertex3fv((float *)&(this->points[i]));
		glVertex3fv((float *)&(this->points2[i]));
	}
	glEnd();

}

CitySystem::CitySystem(int count)
{
	int i;
	int x, y, z;
	this->pointcount = count;
	this->points = new Vector[this->pointcount*2];
	this->points2 = new Vector[this->pointcount*2];
	this->colors = new Vector[this->pointcount];
	this->alphas = new float[this->pointcount];

	bool ***temp;
	temp = new bool**[zdim];
	for (y=0;y<zdim;y++)
	{
		temp[y] = new bool*[ydim];
		for (x=0;x<ydim;x++)
		{
			temp[y][x] = new bool[xdim];
		}
	}

	const float scale = 4;

	for (z=0;z<zdim;z++)
	{
		for (y=0;y<ydim;y++)
		{
			for (x=0;x<xdim;x++)
			{
				temp[z][y][x] = false;
			}
		}
	}

//	temp[dim/2][dim/2][dim/2] = true;
//	temp[zdim/2][ydim/2][xdim/2] = true;
//	temp[rand()%dim][rand()%dim][rand()%dim] = true;
//	temp[rand()%dim][rand()%dim][rand()%dim] = true;
//	temp[rand()%dim][rand()%dim][rand()%dim] = true;

	for (i=0;i<this->pointcount;i++)
	{
		int nx = rand()%xdim;
		int ny = rand()%ydim;
		int nz = rand()%zdim;

		int ox = nx;
		int oy = ny;
		int oz = nz;

		do
		{
			if (safeget(nx, ny, nz))
			{
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
					Vector point = Vector(nx-xdim/2.0f, ny-ydim/2.0f, nz-zdim/2.0f);
					Vector ppoint = Vector(ox-xdim/2.0f, oy-ydim/2.0f, oz-zdim/2.0f);
					points[i] = point;
					points2[i] = ppoint;
					const float maxlength = Vector(xdim/2.0f, ydim/2.0f, zdim/2.0f).length();
					alphas[i] = 2*(float)pow((maxlength-ppoint.length())/maxlength, 2);
					colors[i] = Vector(0.8f, 0.5f, 0.2f)*(alphas[i]) + Vector(0,0,0)*(1-alphas[i]);

					break;
				}
			}
			else 
			{
				//osuttiin reunaan, arvotaan uusi piste
//				nx = rand()%dim;
//				ny = rand()%dim;
//				nz = rand()%dim;
					temp[nx][ny][nz] = true;
					Vector point = Vector(nx-xdim/2.0f, ny-ydim/2.0f, nz-zdim/2.0f);
					Vector ppoint = Vector(ox-xdim/2.0f, oy-ydim/2.0f, oz-zdim/2.0f);
					points[i] = point;
					points2[i] = ppoint;
					const float maxlength = Vector(xdim/2.0f, ydim/2.0f, zdim/2.0f).length();
					alphas[i] = (float)pow((maxlength-ppoint.length())/maxlength, 2);
					colors[i] = Vector(0.8f, 0.5f, 0.2f)*(alphas[i]) + Vector(0,0,0)*(1-alphas[i]);

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

CitySystem::~CitySystem()
{
	delete [] this->points;
	delete [] this->colors;
	delete [] this->points2;
	delete [] this->alphas;
}

bool CitySystem::safeget(int xt, int yt, int zt)
{
	if (xt <= 0)
		return false;
	if (yt <= 0)
		return false;
	if (zt <= 0)
		return false;
	if (xt >= xdim-1)
		return false;
	if (yt >= ydim-1)
		return false;
	if (zt >= zdim-1)
		return false;

	return true;
}

void kaupunki(float aika)
{
	const float alpha = calcSaturate(aika, 0, 1, 3)*0.25f;

//	Vector campos = Vector(aika*30, 40-aika*60, -60.0f-20*(float)sin(aika*2*3.141592f));
//	Vector camtarget = Vector(0, 0, 0);

	float kohta = aika*130;
	Vector campos = Vector(aika, 7-(float)pow(aika+0.4f, 3)*3.5f, -90+kohta);
	Vector camtarget = Vector(0, 0, -50+kohta);

	glLoadIdentity();
	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(aika*20*(float)cos(aika*5), 0, 0, 1);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	city->draw(1, alpha);
	

}

void kaupunki_init()
{
	city = new CitySystem(40000);

}

void kaupunki_free()
{
	delete city;
} 
