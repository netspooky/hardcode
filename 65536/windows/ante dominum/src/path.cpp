#include "path.hpp"

Path::Path()
{
	count = 0;
	points = new Lista();
}


Path::~Path()
{
	points->destroy();
	delete points;
}

void Path::addpoint(Vector point)
{
	count++;
	points->add(new Vector(point.x, point.y, point.z));
}

void Path::draw()
{
	glPushAttrib(GL_ENABLE_BIT);	/* GL_TEXTURE_2D */
	glPushAttrib(GL_CURRENT_BIT); /* väri */
	glDisable(GL_TEXTURE_2D); /* ei kosketa wrapperiin ollenkaan */

	glColor4f(1,1,1,1);
	glBegin(GL_LINE_STRIP);
	for (float t=0;t<1.0f;t+=0.005f)
	{
		Vector v = getValue(t);
		glVertex3f(v.x, v.y, v.z);
	}
	glEnd();
	glPopAttrib();
	glPopAttrib();
}

Vector Path::getValue(float t)
{
	/* missä nodessa ollaan menossa */
	int nodepos = (int)floor((t*(count-1)));

	points->goToNode(nodepos);

	/* pyöristyksen takia ollaan ohitettu nodeposin osoittama node, eli 
	   käyrän Vectort ovat:

	   alkupiste = lista [nodepos]
	   alkutangentti = lista[nodepos+1] - lista[nodepos]
	   lopputangentti = lista[nodepos+2] - lista[nodepos+1]
	   loppupiste = lista[nodepos+1]
	*/

	Vector *startpoint = (Vector *)points->getCurrent();
	points->goForward();
	Vector *endpoint = (Vector *)points->getCurrent();
	Vector starttangent = *endpoint - *startpoint;		/* luodaan uusi Vector, tätä ei ole olemassa oikeasti */
	points->goForward();
	Vector endtangent = *(Vector *)points->getCurrent() - (*endpoint);	/* kuten myös */

	HermiteCurve c;
	c.set(*startpoint, starttangent, endtangent, *endpoint);

	float pos = (t*(count-1))-nodepos;
	return c.getValue(pos);
}

 
