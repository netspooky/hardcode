#include "newton.hpp"

const int ngridx = 100;
const int ngridy = 100;
float *ngrid;

inline Complex evaluate1(Complex value, float aika)
{
	return value - (value*value*value*value*-2+value*value*value+value*value+value*-2-Complex(aika*15,0)) / (value*value*value*-8 + value*value*3 + value*2 - Complex(2, 0));
}
inline Complex evaluate2(Complex value, float aika)
{
	return value - (value*value*value*(1+aika*3)-Complex(1, 0))/(value*value*3);
}
inline Complex evaluate3(Complex value, float aika)
{
	return value - (value*value*value*value+value*value*value-Complex(1, 0)) / (value*value*value*4*(aika-0.5f)*2+value*value*3);
}
inline Complex evaluate4(Complex value, float aika)
{
	return value - (value*value*value+value*value*2+value+Complex(3, aika*25)) / (value*value*3+value*4+Complex(1+aika*6-0.75f, 0));
}

void newton(float aika)
{
	int x, y;
	const float alpha = calcSaturate(aika, 0, 1, 6);

	glLoadIdentity();

	Vector campos = Vector(0, 0, -160.0f);//+70*(float)cos(aika*18));
	Vector camtarget = Vector(0, 0, 0);

	gluLookAt(campos.x, campos.y, campos.z, camtarget.x, camtarget.y, camtarget.z, 0, 1, 0);
	glRotatef(aika*30, 0.2f, 0.1f, 0.54f);

	glDisable(GL_TEXTURE_2D);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glEnable(GL_BLEND);
	glDisable(GL_DEPTH_TEST);

	int offs = 0;
	float a = 0.0f;

	const float limit1 = 0.25f;
	const float limit2 = 0.50f;
	const float limit3 = 0.75f;
	const float limit4 = 1.00f;

	const float sharpness = 8;
	if (aika <= limit1)
	{
		a = calcSaturate(aika, 0, limit1, sharpness);
	}
	else if (aika <= limit2)
	{
		a = calcSaturate(aika, limit1, limit2, sharpness);
	}
	else if (aika <= limit3)
	{
		a = calcSaturate(aika, limit2, limit3, sharpness);
	}
	else if (aika <= limit4)
	{
		a = calcSaturate(aika, limit3, limit4, sharpness);
	}

	for (y=0;y<ngridy;y++)
	{
		const float ykohta = y / (float)ngridy;
		for (x=0;x<ngridx;x++)
		{
			const float xkohta = x / (float)ngridx;

			const float realval = xkohta*2;
			const float imagval = ykohta*2;

			//f(z) = z^3 - 1
			//f'(z) = 3z^2

			const int maxiter = 7;
			Complex value = Complex(realval, imagval);
			int i;
			for (i=0;i<maxiter;i++)
			{
				//zn+1 = zn - f(zn)/f'(zn)
//				Complex nvalue = value - (value*value*value*value*-2+value*value*value+value*value+value*-2-Complex(aika*15,0)) / (value*value*value*-8 + value*value*3 + value*2 - Complex(2, 0));
//				Complex nvalue = value - (value*value*value*(1+aika*3)-Complex(1, 0))/(value*value*3);
//				Complex nvalue = value - (value*value*value*value+value*value*value-Complex(1, 0)) / (value*value*value*4*(aika-0.5f)*2+value*value*3);

				if (aika <= limit1)
				{
					value = evaluate1(value, aika*4);
				}
				else if (aika <= limit2)
				{
					value = evaluate2(value, 1+(aika-limit2)*7);
				}
				else if (aika <= limit3)
				{
					value = evaluate3(value, 0.5f+(aika-limit3)*3);
				}
				else if (aika <= limit4)
				{
					value = evaluate4(value, aika);
				}
			}
			ngrid[offs++] = (float)value.angle()*0.2f*i/(float)maxiter;
		}
	}

	glBegin(GL_QUADS);
	glColor4f(0, 0, 0, alpha*a);
	for (y=0;y<ngridx;y++)
	{
		for (x=0;x<ngridy;x++)
		{
			const float size = 130.0f;
			Vector kohta = Vector((float)x/ngridx-0.5f, (float)y/ngridy-0.5f, 0)*size;

			const float maxpolysize = 2.5f;
			const float polysize = 0.2f- maxpolysize * ngrid[x+y*ngridx];
			Vector v1 = kohta + Vector(-polysize, -polysize, 0);
			Vector v2 = kohta + Vector( polysize, -polysize, 0);
			Vector v3 = kohta + Vector( polysize,  polysize, 0);
			Vector v4 = kohta + Vector(-polysize,  polysize, 0);

			glVertex3fv((float *)&v1);
			glVertex3fv((float *)&v2);
			glVertex3fv((float *)&v3);
			glVertex3fv((float *)&v4);
		}
	}
	glEnd();
}

void newton_init()
{
	int i;
	ngrid = new float[ngridx*ngridy];
	for (i=0;i<ngridx*ngridy;i++)
	{
		ngrid[i] = 0;

	}

}

void newton_free()
{
	delete [] ngrid;
} 
