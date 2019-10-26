#include "dla.hpp"

const int dim = 100;
DLASystem *dlasystem;

void DLASystem::draw(float aika, float alpha)
{
	int i;
	glBlendFunc(GL_SRC_ALPHA, GL_ONE);//_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);
	
	glPointSize(5);

	int count = (int)(this->pointcount*aika);
	const float frac = this->pointcount*aika - count;

	glDisable(GL_TEXTURE_2D);

	glBegin(GL_POINTS);
	for (i=0;i<count;i++)
	{
		const float hengitys = 0.9f+0.2f*(float)sin(aika*7.0f+i*0.03f);

		if (i==count-1)
			glColor4f(colors[i].x, colors[i].y, colors[i].z, alpha*alphas[i]*frac);
		else
			glColor4f(colors[i].x, colors[i].y, colors[i].z, alpha*alphas[i]);
		glVertex3fv((float *)&(this->points[i]*hengitys));
		glVertex3fv((float *)&(this->points2[i]*hengitys));
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

//	temp[dim/2][dim/2][dim/2] = true;
//	temp[rand()%dim][rand()%dim][rand()%dim] = true;
//	temp[rand()%dim][rand()%dim][rand()%dim] = true;
//	temp[rand()%dim][rand()%dim][rand()%dim] = true;

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
					const float randscale = 0.3f;

					Vector r = randomSphereVector(randscale);
					Vector point = Vector(nx-dim/2.0f, ny-dim/2.0f, nz-dim/2.0f) + r;
					Vector ppoint = Vector(ox-dim/2.0f, oy-dim/2.0f, oz-dim/2.0f);
					points[i] = point;
					points2[i] = ppoint;
					const float maxlength = Vector(dim/2.0f, dim/2.0f, dim/2.0f).length();
					alphas[i] = 2*(float)pow((maxlength-ppoint.length())/maxlength, 2);
					colors[i] = Vector(0.6f+randFloat()*0.2f, 0.3f+randFloat()*0.2f, 0.1f+randFloat()*0.2f)*alphas[i];//, alpha*0.46f
//					colors[i] = Vector(0.8f, 0.5f, 0.2f)*(alphas[i]) + Vector(0,0,0)*(1-alphas[i]);

					break;
				}
			}
			else 
			{
				//osuttiin reunaan, arvotaan uusi piste
//				nx = rand()%dim;
//				ny = rand()%dim;
//				nz = rand()%dim;
					const float randscale = 0.3f;

					temp[nx][ny][nz] = true;
					Vector r = randomSphereVector(randscale);
					Vector point = Vector(nx-dim/2.0f, ny-dim/2.0f, nz-dim/2.0f) + r;
					Vector ppoint = Vector(ox-dim/2.0f, oy-dim/2.0f, oz-dim/2.0f);
					points[i] = point;
					points2[i] = ppoint;
					const float maxlength = Vector(dim/2.0f, dim/2.0f, dim/2.0f).length();
					alphas[i] = (float)pow((maxlength-ppoint.length())/maxlength, 2);
//					colors[i] = Vector(0.8f, 0.5f, 0.2f)*(alphas[i]) + Vector(0,0,0)*(1-alphas[i]);
					colors[i] = Vector(0.6f+randFloat()*0.2f, 0.3f+randFloat()*0.2f, 0.1f+randFloat()*0.2f)*alphas[i];//, alpha*0.46f

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
	const float alpha = calcSaturate(aika, 0, 1, 3);

	Vector campos = Vector(aika*30, 40-aika*60, -60.0f-20*(float)sin(aika*2*3.141592f));
	Vector camtarget = Vector(0, 0, 0);

	glLoadIdentity();
	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(aika*30, 0, 0, 0.5f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	float fogcol[] = {0.7f,0.4f, 0.4f,1};
	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 90);
	glFogf(GL_FOG_END, 130);
	glEnable(GL_FOG);

	dlasystem->draw(0.5f+aika*0.5f, alpha);

	glDisable(GL_FOG);

	

}

void dla_init()
{
	dlasystem = new DLASystem(25000);

}

void dla_free()
{
	delete dlasystem;
} 
 
