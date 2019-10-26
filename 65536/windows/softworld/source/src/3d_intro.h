#ifndef _3D_INTRO_H
#define _3D_INTRO_H
#include <windows.h>
#include <gl\gl.h>			// Header File For The OpenGL32 Library
#include <gl\glu.h>			// Header File For The GLu32 Library
#include "normal.h"

#define		PI 3.1415926535898

struct precalc_normal
{
	unsigned char		nb_faces;
	int					face[4];
};


class Plan
{
protected:
	int				nb_faces;			// Nombre de faces du Plan
	int				nb_points;			// Nombre de points du Plan
	int				nb_points_largeur;	// Nombre de points de largeur du Plan
	int				nb_points_longueur;	// Nombre de points de hauteur du Plan
	float			largeur;			// largeur du Plan
	float			longueur;			// longeur du Plan
	int				*faces;				// Les faces du Plan
	float			*points;			// Les Points du Plan
	float			*faces_normals;		// Les vecteurs normaux des faces du Plan
	float			*points_normals;	// Les vecteurs normaux des points du Plan
	float			*UV;				// Les coordonnées du mapping du Plan
	precalc_normal  *faces_points;		// Tels point est entoure de n faces avec leur index! (max 4 dans un Plan avec des faces carré)


public:

	Plan(int nbplr,int nbpln,float lr,float ln)
	{
		nb_points_largeur=nbplr;
		nb_points_longueur=nbpln;
		largeur=lr;
		longueur=ln;

		nb_points=nb_points_largeur*nb_points_longueur;
		nb_faces=(nb_points_largeur-1)*(nb_points_longueur-1);

		// Allocation mémoire
		points=(float *) malloc(3*nb_points*sizeof(float));
		faces=(int *) malloc(4*nb_faces*sizeof(int));
		faces_normals=(float *) malloc(3*nb_faces*sizeof(float));
		points_normals=(float *) malloc(3*nb_points*sizeof(float));
		faces_points=(precalc_normal *) malloc(nb_points*sizeof(precalc_normal));
		UV=(float *) malloc(2*nb_points*sizeof(float));

		// Genere les points du Plan
		this->Plan_Genere_Points();
		
		// centre l'object
		//this->Plan_Centre();

		// genere les faces!
		this->Plan_Genere_Faces();

		// Precalculation pour les normales des points
		this->Plan_Precalc();

		// calcule les normales des faces!
		this->Plan_Genere_Normale_Faces();

		// calcule les normales des points!
		this->Plan_Genere_Normale_Points();

		// calcules les U et les V pour les textures!!!
		this->Plan_Genere_UV();
		
	}

	~Plan()
	{
		free(faces);
		free(points);

		free(points_normals);
		free(faces_normals);

		free(faces_points);

		free(UV);
	}

	// Genere les points du Plan
	virtual void Plan_Genere_Points()
	{
		int		i,j,p;
		float	x,y,z,x_dep,y_dep,coef_x,coef_y;

		z=0.0f;
		x_dep=-(largeur/2);
		y_dep=-(longueur/2);
		coef_x=largeur/nb_points_largeur;
		coef_y=longueur/nb_points_longueur;
		p=0;

		for (i=0;i<nb_points_longueur;i++)
		{
			y=y_dep+i*coef_y;
			for (j=0;j<nb_points_largeur;j++)
			{
				x=x_dep+j*coef_x;
				points[p*3+0]=x;
				points[p*3+1]=y;
				points[p*3+2]=z;
				p++;
			}
		}
	};

	virtual void Plan_Genere_Faces()
	{
		int		i,j,point1,point2,point3,point4,p;

		p=0;

		for (i=0;i<nb_points_longueur-1;i++)
		{
			for (j=0;j<nb_points_largeur-1;j++)
			{
				point1=j+(i*nb_points_longueur);
				point2=point1+1;
				point3=j+((i+1)*nb_points_longueur);
				point4=point3+1;

				faces[p*4+0]=point1;
				faces[p*4+1]=point2;
				faces[p*4+2]=point4;
				faces[p*4+3]=point3;

				p++;
			}
		}
	}

	// Precalculations des faces autour d'un point
	virtual void Plan_Precalc()
	{
		int			i,j;

		for (i=0;i<nb_points;i++)
		{
			faces_points[i].nb_faces=0;
			for (j=0;j<nb_faces;j++)
			{
				if ((i==faces[4*j+0]) || (i==faces[4*j+1]) || (i==faces[4*j+2]) || (i==faces[4*j+3])) // si le point i fait partie de la face j, on le rajoute au veteur normal de ce point
				{
					faces_points[i].face[faces_points[i].nb_faces]=j;
					faces_points[i].nb_faces++;
				}
			}
		}

	}

	// Genere les normales de Faces!
	virtual void Plan_Genere_Normale_Faces()
	{

		Lib3dsVector	a,b,c,n;
		int				i,point1,point2,point3;
		float			x,y,z;

		// les faces:
		for (i=0;i<nb_faces;i++)
		{	
			point1=faces[4*i+0];
			point2=faces[4*i+1];
			point3=faces[4*i+2];
			
			// POINT 1
			x=points[point1*3+0];
			y=points[point1*3+1];
			z=points[point1*3+2];
			a[0]=x;
			a[1]=y;
			a[2]=z;

			// POINT 2
			x=points[point2*3+0];
			y=points[point2*3+1];
			z=points[point2*3+2];
			b[0]=x;
			b[1]=y;
			b[2]=z;

			// POINT 3
			x=points[point3*3+0];
			y=points[point3*3+1];
			z=points[point3*3+2];
			c[0]=x;
			c[1]=y;
			c[2]=z;

			vector_normal(n,a,b,c);

			faces_normals[i*3+0]=n[0];
			faces_normals[i*3+1]=n[1];
			faces_normals[i*3+2]=n[2];
		}
	}

	// Genere les Normales des Points a partir ce celles des faces et de la precalc!
	virtual void Plan_Genere_Normale_Points()
	{
		int				i,j;
		Lib3dsVector	a,b,n;

		for (i=0;i<nb_points;i++)
		{
			// on met le premier vecteur dans le point!
			points_normals[i*3+0]=faces_normals[faces_points[i].face[0]*3+0];
			points_normals[i*3+1]=faces_normals[faces_points[i].face[0]*3+1];
			points_normals[i*3+2]=faces_normals[faces_points[i].face[0]*3+2];

			// puis on additione le vecteur du point a ceux des autres faces qui restent autour!
			for (j=1;j<faces_points[i].nb_faces;j++)
			{
				a[0]=points_normals[i*3+0];
				a[1]=points_normals[i*3+1];
				a[2]=points_normals[i*3+2];

				b[0]=faces_normals[faces_points[i].face[j]*3+0];
				b[1]=faces_normals[faces_points[i].face[j]*3+1];
				b[2]=faces_normals[faces_points[i].face[j]*3+2];
						
				vector_add(n,a,b);
				vector_normalize(n);

				points_normals[3*i+0]=n[0];
				points_normals[3*i+1]=n[1];
				points_normals[3*i+2]=n[2];
			}
		}
	}

	// Genere les U & V pour le mapping!
	virtual void Plan_Genere_UV()
	{
		float	uv_val,uv_u,uv_u_add,uv_v,uv_v_add;
		int		i,j,p;

		uv_val=8.0f/nb_points_largeur;
		uv_u=0.0f;
		uv_v=0.0f;
		uv_u_add=uv_val;
		uv_v_add=uv_val;

		p=0;

		for (i=0;i<nb_points_longueur;i++)
		{
			for (j=0;j<nb_points_largeur;j++)
			{
				UV[p*2+0]=uv_u;
				UV[p*2+1]=uv_v;
				uv_u+=uv_u_add;
				p++;
			}
			uv_v+=uv_v_add;
			uv_u=0;
		}

	}

	// Affiche le plan en 3d
	virtual void Plan_Affiche()
	{
		int		i,point1,point2,point3,point4;
		float	x,y,z,u,v;
		
		for (i=0;i<nb_faces;i++)
		{
			glBegin(GL_QUADS);

			point1=faces[4*i+0];
			point2=faces[4*i+1];
			point3=faces[4*i+2];
			point4=faces[4*i+3];

			// POINT 1
			x=(float) (points[point1*3+0]);
			y=(float) (points[point1*3+1]);
			z=(float) (points[point1*3+2]);

			u=UV[point1*2+0];
			v=UV[point1*2+1];

			glNormal3f(points_normals[3*point1+0],points_normals[3*point1+1],points_normals[3*point1+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 2
			x=(float) (points[point2*3+0]);
			y=(float) (points[point2*3+1]);
			z=(float) (points[point2*3+2]);

			u=UV[point2*2+0];
			v=UV[point2*2+1];

			glNormal3f(points_normals[3*point2+0],points_normals[3*point2+1],points_normals[3*point2+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 3
			x=(float) (points[point3*3+0]);
			y=(float) (points[point3*3+1]);
			z=(float) (points[point3*3+2]);

			u=UV[point3*2+0];
			v=UV[point3*2+1];

			glNormal3f(points_normals[3*point3+0],points_normals[3*point3+1],points_normals[3*point3+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 4
			x=(float) (points[point4*3+0]);
			y=(float) (points[point4*3+1]);
			z=(float) (points[point4*3+2]);

			u=UV[point4*2+0];
			v=UV[point4*2+1];

			glNormal3f(points_normals[3*point4+0],points_normals[3*point4+1],points_normals[3*point4+2]);	
			glTexCoord2f(u,v); 
			glVertex3f(x,y,z);

			glEnd();
		}
	}


	// Affiche2 le plan en 3d a l'envers
	virtual void Plan_Affiche2()
	{
		int		i,point1,point2,point3,point4;
		float	x,y,z,u,v;
		
		for (i=0;i<nb_faces;i++)
		{
			glBegin(GL_QUADS);

			point1=faces[4*i+3];
			point2=faces[4*i+2];
			point3=faces[4*i+1];
			point4=faces[4*i+0];

			// POINT 1
			x=(float) (points[point1*3+0]);
			y=(float) (points[point1*3+1]);
			z=(float) (points[point1*3+2]);

			u=UV[point1*2+0];
			v=UV[point1*2+1];

			glNormal3f(points_normals[3*point1+0],points_normals[3*point1+1],points_normals[3*point1+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 2
			x=(float) (points[point2*3+0]);
			y=(float) (points[point2*3+1]);
			z=(float) (points[point2*3+2]);

			u=UV[point2*2+0];
			v=UV[point2*2+1];

			glNormal3f(points_normals[3*point2+0],points_normals[3*point2+1],points_normals[3*point2+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 3
			x=(float) (points[point3*3+0]);
			y=(float) (points[point3*3+1]);
			z=(float) (points[point3*3+2]);

			u=UV[point3*2+0];
			v=UV[point3*2+1];

			glNormal3f(points_normals[3*point3+0],points_normals[3*point3+1],points_normals[3*point3+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 4
			x=(float) (points[point4*3+0]);
			y=(float) (points[point4*3+1]);
			z=(float) (points[point4*3+2]);

			u=UV[point4*2+0];
			v=UV[point4*2+1];

			glNormal3f(points_normals[3*point4+0],points_normals[3*point4+1],points_normals[3*point4+2]);	
			glTexCoord2f(u,v); 
			glVertex3f(x,y,z);

			glEnd();
		}
	}

	// Genere les points du Plan
	virtual void Plan_Deforme(float param1,float param2,float param3)
	{
		int		i,j,p;
		float	z;

		z=0.0f;
		p=0;
		for (i=0;i<nb_points_longueur;i++)
		{
			for (j=0;j<nb_points_largeur;j++)
			{
				z=(float)(5*cos(param2)+2*sin(param3));
				points[p*3+2]=z;
				p++;
				param3+=(float)(sin(param1)/4);
				param1+=0.2f;
			}
			param2+=0.1f;
		}
		// calcule les normales des faces!
		this->Plan_Genere_Normale_Faces();

		// calcule les normales des points!
		this->Plan_Genere_Normale_Points();
	};

};



// LE CYLINDRE
class Cylindre
{
protected:
	int				nb_faces;			// Nombre de faces du Cylindre
	int				nb_points;			// Nombre de points du Cylindre
	int				nb_points_rayon;	// Nombre de points du rayon
	int				nb_points_hauteur;	// Nombre de points en hauteur
	float			rayon;				// Rayon du Cylindre
	float			hauteur;			// Hauteur du Cylindre
	int				*faces;				// Les faces du Cylindre
	float			*points;			// Les Points du Cylindre
	float			*faces_normals;		// Les vecteurs normaux des faces du Cylindre
	float			*points_normals;	// Les vecteurs normaux des points du Cylindre
	float			*UV;				// Les coordonnées du mapping du Cylindre
	precalc_normal  *faces_points;		// Tels point est entoure de n faces avec leur index! (max 4 dans un Cylindre avec des faces carré)

//	GLuint			object;				// Display list Opengl du Cylindre

public:

	Cylindre(int nbpr,int nbph,float h,float r)
	{
		nb_points_rayon=nbpr;
		nb_points_hauteur=nbph;
		hauteur=h;
		rayon=r;
		nb_faces=(nb_points_rayon)*(nb_points_hauteur-1);
		nb_points=(nb_points_rayon+1)*nb_points_hauteur;

		// Allocation memoire!
		faces=(int *) malloc(4*nb_faces*sizeof(int));
		points=(float *) malloc(3*nb_points*sizeof(float));
		faces_normals=(float *) malloc(3*nb_faces*sizeof(float));
		points_normals=(float *) malloc(3*nb_points*sizeof(float));
		faces_points=(precalc_normal *) malloc(nb_points*sizeof(precalc_normal));
		UV=(float *) malloc(2*nb_points*sizeof(float));

		// genere les points!
		this->Cylindre_Genere_Points();

		// centre l'object
		this->Cylindre_Centre();

		// genere les faces!
		this->Cylindre_Genere_Faces();

		// Precalculation pour les normales des points
		this->Cylindre_Precalc();

		// calcule les normales des faces!
		this->Cylindre_Genere_Normale_Faces();

		// calcule les normales des points!
		this->Cylindre_Genere_Normale_Points();

		// calcules les U et les V pour les textures!!!
		this->Cylindre_Genere_UV();

	};


	~Cylindre()
	{
		free(faces);
		free(points);

		free(points_normals);
		free(faces_normals);

		free(faces_points);

		free(UV);
	};

	// Genere les points du Cylindre
	virtual void Cylindre_Genere_Points()
	{
		int		i,j,p;
		float	angle,x,y,z;
		p=0;
		for (i=0;i<nb_points_hauteur;i++)
		{
			z=hauteur*i/nb_points_hauteur;

			for (j=0;j<nb_points_rayon+1;j++)
			{
				angle = (float) (2*PI*j/nb_points_rayon); 

				x=(float) (rayon*cos(angle));
				y=(float) (rayon*sin(angle));

				points[p*3+0]=x;
				points[p*3+1]=y;
				points[p*3+2]=z;

				p++;
			}
		}
	}

	// Genere les faces du Cylindre
	virtual void Cylindre_Genere_Faces()
	{
		int		i,j,p,p1,p2,p3,p4;
		p=0;
		for (i=0;i<nb_points_hauteur-1;i++)
		{
			for (j=0;j<nb_points_rayon;j++)
			{
				p1=j+i*(nb_points_rayon+1);
				p3=j+(i+1)*(nb_points_rayon+1);
/*				if (j==nb_points_rayon)
				{
					p2=i*(nb_points_rayon+1);
					p4=(i+1)*(nb_points_rayon+1);
				}
				else
*/				{
					p2=p1+1;
					p4=p3+1;
				}

				faces[p*4+0]=p1;
				faces[p*4+1]=p2;
				faces[p*4+2]=p4;
				faces[p*4+3]=p3;
				p++;
			}
		}


		for (i=0;i<nb_faces;i++)
		{
				p1=faces[i*4+0];
				p2=faces[i*4+1];
				p4=faces[i*4+2];
				p3=faces[i*4+3];
				j=0;
				j=1;
		}

	}

	// Genere les points du Cylindre avec deformation
	virtual void Cylindre_Deforme(float param1,float param2,float param3)
	{
		int		i,j,p;
		float	angle,x,y,z;
		float	temp,temp2;
		p=0;
		for (i=0;i<nb_points_hauteur;i++)
		{
			z=hauteur*i/nb_points_hauteur;

			for (j=0;j<nb_points_rayon+1;j++)
			{
				angle = (float) ((2*PI*j/nb_points_rayon)+4*cos(param2)+sin(param3)); 

				temp=(float) (2*cos(2*PI*param3))+(rayon);
				temp2=(float) (sin(2*PI*param2)+(rayon)+(2*cos(2*PI*param2)));
				x=(float) ((temp*cos(angle))+0.5*cos(2*PI*param2));
				y=(float) ((temp2*sin(angle))+0.5*sin(2*PI*param2));

				points[p*3+0]=x;
				points[p*3+1]=y;
				points[p*3+2]=z;

				p++;
				
			}
			param2+=0.02f; //0.008
			param1+=0.05f;
			param3+=0.005f;			
		}

		// calcule les normales des faces!
		this->Cylindre_Genere_Normale_Faces();

		// calcule les normales des points!
		this->Cylindre_Genere_Normale_Points();
		
		// Centre le Cylindre
		this->Cylindre_Centre();

	}	

	// Genere les U & V pour le mapping!
	virtual void Cylindre_Genere_UV()
	{
		float	uv_val,uv_u,uv_u_add,uv_v,uv_v_add;
		int		i,j,p;

		uv_val=4.0f/nb_points_rayon;
		uv_u=0.0f;
		uv_v=0.0f;
		uv_u_add=uv_val;
		uv_v_add=uv_val;

		p=0;

		for (i=0;i<nb_points_hauteur;i++)
		{
			for (j=0;j<nb_points_rayon+1;j++)
			{
				UV[p*2+0]=uv_u;
				UV[p*2+1]=uv_v;
				uv_u+=uv_u_add;
				p++;
			}
			uv_v+=uv_v_add;
			uv_u=0;
		}

	}

	// Genere les normales de Faces!
	virtual void Cylindre_Genere_Normale_Faces()
	{
		//Lib3dsVector	a,b,c,n;
		float			a[3],b[3],c[3],n[3];
		int				i,point1,point2,point3;
		float			x,y,z;

		// les faces:
		for (i=0;i<nb_faces;i++)
		{	
			point1=faces[4*i+0];
			point2=faces[4*i+1];
			point3=faces[4*i+2];
			
			// POINT 1
			x=points[point1*3+0];
			y=points[point1*3+1];
			z=points[point1*3+2];
			a[0]=x;
			a[1]=y;
			a[2]=z;

			// POINT 2
			x=points[point2*3+0];
			y=points[point2*3+1];
			z=points[point2*3+2];
			b[0]=x;
			b[1]=y;
			b[2]=z;

			// POINT 3
			x=points[point3*3+0];
			y=points[point3*3+1];
			z=points[point3*3+2];
			c[0]=x;
			c[1]=y;
			c[2]=z;

			//lib3ds_vector_normal(n,a,b,c);
			vector_normal(n,a,b,c);

			faces_normals[i*3+0]=n[0];
			faces_normals[i*3+1]=n[1];
			faces_normals[i*3+2]=n[2];
		}
	}

	// Genere les Normales des Points a partir ce celles des faces et de la precalc!
	virtual void Cylindre_Genere_Normale_Points()
	{
		int				i,j;
		//Lib3dsVector	a,b,n;
		float			a[3],b[3],n[3];

		for (i=0;i<nb_points;i++)
		{
			// on met le premier vecteur dans le point!
			points_normals[i*3+0]=faces_normals[faces_points[i].face[0]*3+0];
			points_normals[i*3+1]=faces_normals[faces_points[i].face[0]*3+1];
			points_normals[i*3+2]=faces_normals[faces_points[i].face[0]*3+2];

			// puis on additione le vecteur du point a ceux des autres faces qui restent autour!
			for (j=1;j<faces_points[i].nb_faces;j++)
			{
				a[0]=points_normals[i*3+0];
				a[1]=points_normals[i*3+1];
				a[2]=points_normals[i*3+2];

				b[0]=faces_normals[faces_points[i].face[j]*3+0];
				b[1]=faces_normals[faces_points[i].face[j]*3+1];
				b[2]=faces_normals[faces_points[i].face[j]*3+2];
						
				//lib3ds_vector_add(n,a,b);
				//lib3ds_vector_normalize(n);
				vector_add(n,a,b);
				vector_normalize(n);

				points_normals[3*i+0]=n[0];
				points_normals[3*i+1]=n[1];
				points_normals[3*i+2]=n[2];
			}
		}
	}

	// Precalculations des faces autour d'un point
	virtual void Cylindre_Precalc()
	{
		int			i,j,nb,nb2,k,l,nbt;

		for (i=0;i<nb_points;i++)
		{
			faces_points[i].nb_faces=0;
			faces_points[i].face[0]=0;
			faces_points[i].face[1]=0;
			faces_points[i].face[2]=0;
			faces_points[i].face[3]=0;
			for (j=0;j<nb_faces;j++)
			{
				if ((i==faces[4*j+0]) || (i==faces[4*j+1]) || (i==faces[4*j+2]) || (i==faces[4*j+3])) // si le point i fait partie de la face j, on le rajoute au veteur normal de ce point
				{
					faces_points[i].face[faces_points[i].nb_faces]=j;
					faces_points[i].nb_faces++;
				}
			}
		}
		// Fais les modifs du au faces 
		faces_points[0].face[faces_points[0].nb_faces]=nb_points_rayon;
		faces_points[0].nb_faces++;

		faces_points[nb_points_rayon].face[faces_points[nb_points_rayon].nb_faces]=0;
		faces_points[nb_points_rayon].nb_faces++;

		for (i=0;i<nb_points;i++)
		{
			nbt=faces_points[i].nb_faces;
			if (nbt==2)
			{
				nbt=0;
			}
		}


		for (i=1;i<nb_points_hauteur-1;i++)
		{
			k=(i*(nb_points_rayon+1));
			nb=((i-1)*(nb_points_rayon))+nb_points_rayon-1;
			nb2=(i*(nb_points_rayon))+nb_points_rayon-1;

			nbt=faces_points[k].nb_faces;

			if (nbt==2)
			{
				faces_points[k].face[faces_points[k].nb_faces]=nb;
				faces_points[k].nb_faces++;
				faces_points[k].face[faces_points[k].nb_faces]=nb2;
				faces_points[k].nb_faces++;
			}

			l=((i+1)*(nb_points_rayon+1))-1;
			nb2=nb+1;
			nb=(i-1)*nb_points_rayon;

			nbt=faces_points[l].nb_faces;
			if (nbt==2)
			{			
				faces_points[l].face[faces_points[l].nb_faces]=nb;
				faces_points[l].nb_faces++;
				faces_points[l].face[faces_points[l].nb_faces]=nb2;
				faces_points[l].nb_faces++;
			}

			// reste face du fond mais comme on les voit pas....
		}



	}

	// Centre le Cylindre
	virtual void Cylindre_Centre()
	{
		int		i;
		float	x,y,z,val_x,val_y,val_z;
		float	min_x=50000.0f,max_x=-50000.0f,min_y=50000.0f,max_y=-50000.0f,min_z=50000.0f,max_z=-50000.0f;

		for (i=0;i<nb_points;i++)
		{
			x=points[i*3+0];
			if (x<min_x)
			{
				min_x=x;
			}
			if (x>max_x)
			{
				max_x=x;
			}

			y=points[i*3+1];
			if (y<min_y)
			{
				min_y=y;
			}
			if (y>max_y)
			{
				max_y=y;
			}
		
		
			z=points[i*3+2];
			if (z<min_z)
			{
				min_z=z;
			}
			if (z>max_z)
			{
				max_z=z;
			}
		}
	
		val_x=-(((max_x-min_x)/2)+min_x);
		val_y=-(((max_y-min_y)/2)+min_y);
		val_z=-(((max_z-min_z)/2)+min_z);

		for (i=0;i<nb_points;i++)
		{
			points[i*3+0]+=val_x;
			points[i*3+1]+=val_y;
			points[i*3+2]+=val_z;
		}
	}

	// Affiche le Cylindre
	virtual void Cylindre_affiche()
	{
		int		i,point1,point2,point3,point4;
		float	x,y,z,u,v;


		glBegin(GL_QUADS);
		for (i=0;i<nb_faces;i++)
		{
			point1=faces[4*i+0];
			point2=faces[4*i+1];
			point3=faces[4*i+2];
			point4=faces[4*i+3];

			// POINT 1
			x=(float) (points[point1*3+0]);
			y=(float) (points[point1*3+1]);
			z=(float) (points[point1*3+2]);

			u=UV[point1*2+0];
			v=UV[point1*2+1];

			glNormal3f(points_normals[3*point1+0],points_normals[3*point1+1],points_normals[3*point1+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 2
			x=(float) (points[point2*3+0]);
			y=(float) (points[point2*3+1]);
			z=(float) (points[point2*3+2]);

			u=UV[point2*2+0];
			v=UV[point2*2+1];

			glNormal3f(points_normals[3*point2+0],points_normals[3*point2+1],points_normals[3*point2+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 3
			x=(float) (points[point3*3+0]);
			y=(float) (points[point3*3+1]);
			z=(float) (points[point3*3+2]);

			u=UV[point3*2+0];
			v=UV[point3*2+1];

			glNormal3f(points_normals[3*point3+0],points_normals[3*point3+1],points_normals[3*point3+2]);	
			glTexCoord2f(u, v); 
			glVertex3f(x,y,z);

			// POINT 4
			x=(float) (points[point4*3+0]);
			y=(float) (points[point4*3+1]);
			z=(float) (points[point4*3+2]);

			u=UV[point4*2+0];
			v=UV[point4*2+1];

			glNormal3f(points_normals[3*point4+0],points_normals[3*point4+1],points_normals[3*point4+2]);	
			glTexCoord2f(u,v); 
			glVertex3f(x,y,z);
		}
		glEnd();
	}

	// Affiche le Cylindre vu de l'interieur
	virtual void Cylindre_affiche2()
	{
		int		i,point1,point2,point3,point4;
		float	x,y,z,u,v;
		float	min_x=50000.0f,max_x=-50000.0f,min_y=50000.0f,max_y=-50000.0f,min_z=50000.0f,max_z=-50000.0f;


		glBegin(GL_QUADS);
		for (i=0;i<nb_faces;i++)
		{
			point1=faces[4*i+0];
			point2=faces[4*i+1];
			point3=faces[4*i+2];
			point4=faces[4*i+3];

			// POINT 1
			x=(float) (points[point1*3+0]);
			y=(float) (points[point1*3+1]);
			z=(float) (points[point1*3+2]);

			u=UV[point1*2+0];
			v=UV[point1*2+1];

			glTexCoord2f(u, v); 
			glNormal3f(points_normals[3*point1+0],points_normals[3*point1+1],points_normals[3*point1+2]);
			glVertex3f(x,y,z);

			// POINT 4
			x=(float) (points[point4*3+0]);
			y=(float) (points[point4*3+1]);
			z=(float) (points[point4*3+2]);

			u=UV[point4*2+0];
			v=UV[point4*2+1];

			glTexCoord2f(u,v); 
			glNormal3f(points_normals[3*point4+0],points_normals[3*point4+1],points_normals[3*point4+2]);
			glVertex3f(x,y,z);


			// POINT 3
			x=(float) (points[point3*3+0]);
			y=(float) (points[point3*3+1]);
			z=(float) (points[point3*3+2]);

			u=UV[point3*2+0];
			v=UV[point3*2+1];

			glTexCoord2f(u, v); 
			glNormal3f(points_normals[3*point3+0],points_normals[3*point3+1],points_normals[3*point3+2]);		
			glVertex3f(x,y,z);

			// POINT 2
			x=(float) (points[point2*3+0]);
			y=(float) (points[point2*3+1]);
			z=(float) (points[point2*3+2]);

			u=UV[point2*2+0];
			v=UV[point2*2+1];

			glTexCoord2f(u, v); 
			glNormal3f(points_normals[3*point2+0],points_normals[3*point2+1],points_normals[3*point2+2]);	
			glVertex3f(x,y,z);
		}
		glEnd();
	}

};

#endif
