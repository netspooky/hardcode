#include "fibotree.hpp"

int maxfibo = 100;
int *fibonaccinumbers;
const int maxfibogeneration = 6;

const int fibotreecount = 100;
FiboTree **trees;

void FiboTree::draw(float aika, float alpha)
{
	int i;

	if (aika > endtime || aika < starttime)
		return;
	const float pos = calcPosFloat(aika, starttime, endtime);
	float treealpha = alpha*calcSaturate(pos, 0, 1, 3);

	tree->goToStart();
	
	int drawcount = tree->getNodeCount();

	const int leveltodraw = (int)(treealpha*(maxfibogeneration+1));
	const float frac = treealpha*(maxfibogeneration+1) - leveltodraw;

	treealpha *= 0.7f;

	glBegin(GL_LINES);

	for (i=0;i<drawcount;i++)
	{
		FiboTreeItem *item = (FiboTreeItem *)tree->getCurrent();
		if (item->generation < leveltodraw)
		{
			glColor4f(0, 0, 0, treealpha*(maxfibogeneration+1-item->generation)/maxfibogeneration);
			glVertex3fv((float *)&item->v1);
			glVertex3fv((float *)&item->v2);
		}
		if (item->generation == leveltodraw)
		{
			glColor4f(0, 0, 1, frac*treealpha*(maxfibogeneration+1-item->generation)/maxfibogeneration);
			glVertex3fv((float *)&item->v1);
			glVertex3fv((float *)&item->v2);
		}
		tree->goForward();
	}
	glEnd();

}
void fibotree(float aika) 
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

//	Vector campos = Vector(0, 8+5*cos(aika*17), -21.0f);
	Vector campos = Vector(0, 0, -20.0f-25*aika*aika);
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);

	glRotatef(aika*150, 0.5f, 0.9f, 0.4f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glEnable(GL_DEPTH_TEST);

	float fogcol[] = {1,1,1,1};

	glFogi(GL_FOG_MODE, GL_LINEAR); //EXP, EXP2, LINEAR
	glFogfv(GL_FOG_COLOR, fogcol);
	glFogf(GL_FOG_DENSITY, 0.4f+0.4f*(float)cos(aika*10));
	glHint(GL_FOG_HINT, GL_DONT_CARE);
	glFogf(GL_FOG_START, 20);
	glFogf(GL_FOG_END, 45);
	glEnable(GL_FOG);

	glLineWidth(3);
	for (i=0;i<fibotreecount;i++)
	{
		trees[i]->draw(aika, alpha);
	}
	glDisable(GL_FOG);
}

void fibotree_recurse(Lista *list, Vector &sourcepoint, int depth, int maxdepth)
{
	int i;
	if (depth > maxdepth)
		return;

	int count = fibonaccinumbers[depth];

	for (i=0;i<count;i++)
	{
		FiboTreeItem *item = new FiboTreeItem();
		item->v1 = sourcepoint;

		const float maxlength = (maxdepth+1-depth)*0.8f;
		const float minlength = (maxdepth+1-depth)*0.6f;
		const float length = minlength + (maxlength - minlength);

	
		Vector randvec = randomSphereVector(length);
		item->v2 = item->v1 + randvec;
		item->generation = depth;
		list->add(item);

		fibotree_recurse(list, item->v2, depth+1, maxdepth);
	}
}

void fibotree_init()
{
	int i;
	fibonaccinumbers = new int[maxfibo];

	fibonaccinumbers[0] = 1;
	fibonaccinumbers[1] = 1;

	for (i=2;i<maxfibo;i++)
	{
		fibonaccinumbers[i] = fibonaccinumbers[i-1]+fibonaccinumbers[i-2];
	}

	Vector point1 = Vector(0, 0, 0);

	trees = new FiboTree*[fibotreecount];
	for (i=0;i<fibotreecount;i++)
	{
		trees[i] = new FiboTree();
		trees[i]->tree = new Lista();
		srand(560*i);
		fibotree_recurse(trees[i]->tree, point1, 0, maxfibogeneration);

		trees[i]->starttime = randFloat();
		trees[i]->endtime = trees[i]->starttime + 0.1f + randFloat()*0.1f;
	}
}

void fibotree_free()
{
	int i;
	for (i=0;i<fibotreecount;i++)
	{
		trees[i]->tree->destroy();
		delete trees[i]->tree;
		delete trees[i];
	}
	delete [] trees;
} 
