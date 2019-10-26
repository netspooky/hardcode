#include "iterator.hpp"

const int iteratedpoints = 50000;

void iterator1(float aika);
void iterator2(float aika);
void iterator3(float aika);
void iterator4(float aika);

void iterator(float aika)
{
	const float itimes1[] = { 0.0f, 0.25f };
	const float itimes2[] = { 0.25f, 0.50f };
	const float itimes3[] = { 0.50f, 0.75f };
	const float itimes4[] = { 0.75f, 1.00f };

	const float i1 = calcPosFloat(aika, itimes1[0], itimes1[1]);
	const float i2 = calcPosFloat(aika, itimes2[0], itimes2[1]);
	const float i3 = calcPosFloat(aika, itimes3[0], itimes3[1]);
	const float i4 = calcPosFloat(aika, itimes4[0], itimes4[1]);


	glLoadIdentity();
	glTranslatef(0, 0, -8.0f);

	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glDisable(GL_DEPTH_TEST);

	glRotatef(aika*30, 1, 1, 0.3f);

	if (i1 > 0.001f && i1 < 0.999f)
	{
		glRotatef(aika*160, 0, 0, 1);
		iterator2(i1);
		return;
	}
	if (i2 > 0.001f && i2 < 0.999f)
	{
		glRotatef(aika*160-40, 0, 0, 1);
		iterator3(i2);
		return;
	}
	if (i3 > 0.001f && i3 < 0.999f)
	{
		glRotatef(aika*160+60, 0, 0, 1);
		iterator4(i3);
		return;
	}
	if (i4 > 0.001f && i4 < 1.00f)
	{
		glRotatef(aika*160+60, 0, 0, 1);
		iterator1(i4);
		return;
	}


}
void iterator2(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 3);

	double x = 0;
	double y = 0;
	double x1 = 0;
	double y1 = 0;
	double r = 0;
	
	srand((int)(aika*16100));

	glPointSize(2);
	glBegin(GL_POINTS);
	glColor4f(0, 0, 0, alpha);

	const float scale = 2+(float)sin(calcSaturate(aika, 0, 2, 1)*3.141592f*0.5f )*3;
	
	const float prob1 = 0.333333f;// aika*0.3f;//1.0f/3.0f;
	const float prob2 = prob1*(1.8f+0.4f*aika);// + 2.0f/3.0f;

	const float transf = 1.85f+aika*0.4f;
	const float prop = (float)sqrt(3)*(0.8f+aika*0.335f);

	for (i=0;i<iteratedpoints;i++)
	{
		r = randFloat();
		if (r < prob1) 
		{
			x1 = (x + y / prop) / transf;
			y1 = (x / prop - y) / transf;
		} 
		else if (r < prob2) 
		{
			x1 = (x - y / prop) / transf + 1 / 2.0;
			y1 = (-x / prop - y) / transf + 1 / (2 * prop);
		} 
		else 
		{
			x1 = (x + y / prop) / transf + 1;
			y1 = - (x / prop - y) / transf;
		}
		x = x1;
		y = y1;
		glVertex2d(x*scale-3.5f, y*scale-1.0f);
	}
	glEnd();
}
void iterator3(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 3);

	double x=0;//0.5f;
	double y=0;//0.75f;
	double xa,xb,xc,ya,yb,yc,xr,yr,x2,y2;
	srand((int)(aika*16100));

	glPointSize(2);
	glBegin(GL_POINTS);
	glColor4f(0, 0, 0, alpha);

	const float transf1 = (float)sqrt(3)-1.1f-0.15f*(float)cos(aika*1.4f*3.141592f);
	const float transf2 = (float)sqrt(3)+1.1f-0.15f*(float)sin(aika*1.4f*3.141592f);
	const float val3 = (float)sqrt(1.5f);//*(0.95f+0.2f*aika);
	const float scale = 8+aika*3;

	const float t1 = (float)cos(2*3.141592f/3);
	const float t2 = (float)sin(2*3.141592f/3);
	for (i=0;i<iteratedpoints;i++)
	{
		xr = t1*x - t2*y;
		yr = t1*y + t2*x;
		x2 = xr*xr - yr*yr;
		y2 = 2 * xr * yr;

		switch (rand() % 3) 
		{
			case 0:
			{
				xa = transf1*x+1;
				ya = transf1*y;
				xb = -x+transf2;
				yb = -y;
				xc = xb/(xb*xb+yb*yb);
				yc = -yb/(xb*xb+yb*yb);
				break;
			}
			case 1: 
			{
				xa = transf1*xr+1;
				ya = transf1*yr;
				xb = -xr+(transf2);
				yb = -yr;
				xc = xb/(xb*xb+yb*yb);
				yc = -yb/(xb*xb+yb*yb);
				break;
			}
			case 2:
			{
				xa = (transf1)*x2+1;
				ya = (transf1)*y2;
				xb = -x2+(transf2);
				yb = -y2;
				xc = xb/(xb*xb+yb*yb);
				yc = -yb/(xb*xb+yb*yb);
				break;
			}
		}
		x = (xa*xc - ya*yc) * val3;
		y = (xa*yc + xc*ya) * val3;
		glVertex2d(x*scale-4, y*scale);
	}
	glEnd();
}
void iterator4(float aika)
{
	int i;
	float a = -0.75f + 0.1f*(float)cos(aika*16);
	float b = 0.23f + 0.14f*(float)sin(aika*14);
	float prob = 0.87f + 0.10f*(float)cos(aika*14);

	float x = 0;
	float y = 0;
	float x1, y1;
	float s, r2, w2;
	const float alpha = calcSaturate(aika, 0, 1, 1);

	const float scale = 3.5f - 1*aika;//(float)sin(aika*12);

	glPointSize(3);
	glColor4f(0, 0, 0, alpha);
	glBegin(GL_POINTS);

	for (i=0;i<iteratedpoints;i++)
	{
		r2 = (float)sqrt((x-a)*(x-a) + (y-b)*(y-b));
		w2 = (float)atan2(y-b, x-a)*0.5f;

		s = -1;
		if ((rand()%10000 / 10000.0f) > prob)
			s = 1;

		x1 = (float)(s * sqrt(r2) * cos(w2));
		y1 = (float)(s * sqrt(r2) * sin(w2));

		x = x1;
		y = y1;

		glVertex2f(x*scale, y*scale);
	}
	glEnd();

}

void iterator1(float aika)
{
	int i;
	const float alpha = calcSaturate(aika, 0, 1, 3);

	double x = 0;
	double y = 0;
	double r = 2.3f-aika*0.4f;//2.5f+0.5f+0.5f*(float)sin(aika*27);
	double r0, w;

	srand((int)(aika*16100));

	glPointSize(2);
	glBegin(GL_POINTS);
	glColor4f(0, 0, 0, alpha);

	const float val = 0.4f + 0.4f*((1-aika)*(float)cos(aika*20)+aika);//(float)cos(aika*35);
	const double val2 = sqrt(3)*0.5*aika*3;
	const double val3 = 1;//sin(aika*30);
	for (i=0;i<iteratedpoints;i++)
	{
		r0 = sqrt(x*x+y*y);
		switch(rand()%4)
		{
			case 0: 
			{
				w = atan2(y, x-val3);
				y = -r0 * sin(w) / r + 1;
				x = -r0 * cos(w) / r;
				break;
			}
			case 1: 
			{
				w = atan2(y-val2, x+val);
				y = -r0 * cos(w) / r - val;
				x = -r0 * sin(w) / r + val2;
				break;
			}
	        case 2:
			{
				w = atan2(y+val2,x+val);
				y = -r0 * cos(w) / r - val;
				x = -r0 * sin(w) / r - val2;
				break;
			}
		    case 3:
			{
				w = atan2(y,x);
				y = -r0 * cos(w) / r;
				x = -r0 * sin(w) / r;
				break;
			}
		}
		glVertex2d(x+0.5, y+0.5);
	}
	glEnd();

}

void iterator_init()
{
}

void iterator_free()
{
} 
