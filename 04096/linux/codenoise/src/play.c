/* 
  *      Copyright (C) 2004 Jorge Gorbe Moya <slack@frikis.org>
  *                         Alejandro Domingo Monge <adomingo@dsic.upv.es>
  *
  *
  *      This program is free software; you can redistribute it and/or modify
  *      it under the terms of the GNU General Public License version 2, as 
  *      published by the Free Software Foundation.
  *
  *      This program is distributed in the hope that it will be useful,
  *      but WITHOUT ANY WARRANTY; without even the implied warranty of
  *      MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  *      GNU General Public License for more details.
  *
  *      You should have received a copy of the GNU General Public License
  *      along with this program; if not, write to the
  *      Free Software Foundation, Inc.,
  *      59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */



#include "dl_init.h"
#include "synth.h"
#include "play.h"

#define NUM_VOICES 24
#define MAX_PARTICLES 3000



Channel channels[NUM_CHANNELS];
Voice voices[NUM_VOICES];


#include "song.h"

int px, py;
float mix_buf[BUFFER_SIZE];

#ifdef OUTFILE
FILE *fout;
#endif

#define cos(x) __builtin_cosf(x)
#define sin(x) __builtin_sinf(x)
#define sqrt(x) __builtin_sqrtf(x)
int cur_pos=0, cur_row=-1;

float osc=0.0f;
float bombo=0.0f;
float rotacion=0.0f;
float fadeout=1.0f;

Uint8 fin=0;

float ruido;
int last=0;

static void play(void *userdata, Uint8 *stream, int len)
{
	static int rows_played=0;

	static float current_time=0.0f;
	
	unsigned int num_samples=len>>1;
	float row_duration;
	float tmp;
	int i,j;

	Pattern *cur_ptn;
	Track *cur_trk;

	Song *s=(Song *)userdata;
	Sint16 *buf=(Sint16 *)stream;

	row_duration = 0.1515151f;
	current_time += num_samples/SAMPLE_RATE;

	__builtin_memset(mix_buf, 0, BUFFER_SIZE*sizeof(float));

	if ((current_time - rows_played*row_duration) > row_duration)
	{
		++rows_played;
		++cur_row;

		if (cur_row == TRACK_LENGTH) // fin de pista
		{
			cur_row=0;
			if (++cur_pos==14) {fin=1; ruido=0.0f;}
		}
		

		cur_ptn=&s->ptns[s->ptn_list[cur_pos]];
		
		for (i=0; i<NUM_CHANNELS; ++i)
		{
			int transp = cur_ptn->transpose[i];
			int note;
			Uint8 vol;

			cur_trk = &s->tracks[cur_ptn->tracks[i]];

			note = cur_trk->note[cur_row];
			vol = cur_trk->vol[cur_row];
			if (vol)
			{
				channels[i].vol = vol/127.0f;
			}
			
			if (note != 0)
			{
				if (!cur_row)
				{
					osc=1.0f;
					rotacion+=90.0f;
				}
				if (i==1)
				{
					if (!fin) ruido=0.38f;			
				}
				if (i==0)
				{
					bombo=0.0f;
				}


				note+=transp;
				/*
				for (j=0; j<NUM_VOICES; ++j)
				{
					if (!voices[j].active)
						break;
					
				}
				*/
				last=(last+1)%NUM_VOICES;
				voices[last].ins = &song.insts[i];
				voices[last].chn = &channels[i];
				voices[last].pitch = 440.0f*fn.powf(2.0f,(note-45.0f)/12.0f);
				voices[last].pos = 0;
				voices[last].active = 1;
			}

		}
	}

	// Ahora vamos sintetizando las voces
	for (i=0; i<NUM_VOICES; ++i)
	{
		if (voices[i].active)
		{
			voices[i].active=synth(&voices[i], num_samples, mix_buf);
		}
	}

	// convertimos a Sint16
	for (i=0; i<num_samples; ++i)
	{
		tmp = mix_buf[i]*fadeout;
//		if (tmp>1.0f) tmp=1.0f;
//		else if(tmp<-1.0f) tmp=-1.0f;
//		mix_buf[i]=tmp;
		buf[i]=(Sint16)(tmp*32767.0f);
	}

	if (!fin) ruido -= num_samples/SAMPLE_RATE;
	else ruido += 0.006;
#ifdef OUTFILE
	fwrite(buf, sizeof(Sint16), num_samples, fout);
#endif
}


SDL_AudioSpec desired={44100,AUDIO_S16SYS, 1,0,BUFFER_SIZE,0,0,play,&song};

/*
void dibuja_cubo(float x, float y, float z, float tam)
{       // Dibujamos un pseudo-cubo de 3 caras
        fn.glBegin(GL_TRIANGLE_FAN);
        fn.glVertex3f(x,y,z);
        fn.glVertex3f(x,y-tam,z);
        fn.glVertex3f(x+tam,y-tam,z);
        fn.glVertex3f(x+tam,y,z);          // Cara frontal
        fn.glVertex3f(x+tam,y,z+tam);
        fn.glVertex3f(x,y,z+tam);          // Cara superior
        fn.glVertex3f(x,y-tam,z+tam);
        fn.glVertex3f(x,y-tam,z);          // Cara izquierda
        fn.glEnd();

        fn.glBegin(GL_TRIANGLE_FAN);
        fn.glVertex3f(x+tam,y-tam,z+tam);
        fn.glVertex3f(x+tam,y,z+tam);
        fn.glVertex3f(x,y,z+tam);
        fn.glVertex3f(x,y-tam,z+tam);      // Cara trasera
        fn.glVertex3f(x+tam,y-tam, z);
        fn.glVertex3f(x+tam,y-tam,z);      // Cara inferior
        fn.glVertex3f(x+tam,y,z);
        fn.glVertex3f(x+tam,y,z+tam);      // Cara derecha
        fn.glEnd();
}
*/

int buf_scanline[128*128];
Uint8 buf_tex[128*128];
Uint8 tex_particle[128*128];

//GLfloat LightPos[]={0.0f,1.0f,10.0f,1.0f};
//GLfloat LightAmbient[]={0.3f,0.3f,0.3f};
//GLfloat LightDiffuse[]={0.7f,0.7f,0.7f};


void fullscreenquad()
{
	fn.glBegin(GL_QUADS);
	fn.glTexCoord2f(0,0);
	fn.glVertex2f(-1,-1);
	fn.glTexCoord2f(1,0);
	fn.glVertex2f(1,-1);
	fn.glTexCoord2f(1,1);
	fn.glVertex2f(1,1);
	fn.glTexCoord2f(0,1);
	fn.glVertex2f(-1,1);
	fn.glEnd();

}

float blah=70.0f;

int num_particles = 0;
float pos[MAX_PARTICLES*2];

void draw_particles(float posx)
{
	int i;
	fn.glBegin(GL_QUADS);
	float PARTICLE_SCALE=1.0f+2.0f/(bombo*bombo);
	for(i = 0; i < num_particles; i++)
	{
		float x = pos[i*2] + posx + 0.05f*sin(i+(float)blah * 0.1f);
		float y = pos[i*2+1];

//#define PARTICLE_SCALE 1
		fn.glTexCoord2f(0, 0);
		fn.glVertex2f(x, y);
		fn.glTexCoord2f(1, 0);
		fn.glVertex2f(x + PARTICLE_SCALE*0.075f, 0 + y);
		fn.glTexCoord2f(1, 1);
		fn.glVertex2f(x + PARTICLE_SCALE*0.075f, PARTICLE_SCALE*0.1f + y);
		fn.glTexCoord2f(0, 1);
		fn.glVertex2f(x, PARTICLE_SCALE*0.1f + y);

		pos[i*2+1]+=0.01f+(i%3)*0.0015f;
	}
	fn.glEnd();
}

#define NUMTEXTURES 10
#define SQR(x) ((x)*(x))

void oscilloscope()
{
	int i;
	fn.glDisable(GL_TEXTURE_2D);

	fn.glBegin(GL_POINTS);
	for (i=0; i<BUFFER_SIZE; ++i)
	{
		float amp=__builtin_fabsf(mix_buf[i]*2.0f);
		float x,y;
		int ix=i-HALF_BS;
		y=0.8f*mix_buf[i];
		if (cur_pos<6)
		{
			if (cur_pos<2)
			{
				x=ix/(float)HALF_BS;
			}
			
			else
			{
				y -= 1.0f;
				x = (ix/30*30)/(float)HALF_BS; 
			}
			
			fn.glColor4f(amp, 0.3f, 1.0f-amp,1.0f); 
			fn.glVertex2f(x, y);	
			fn.glVertex2f(x, y+2.0f);	
		}
	}
	fn.glEnd();
	fn.glEnable(GL_TEXTURE_2D);
}


//int main(int argc, char **argv)
void __attribute__((noreturn)) _start()
{
	SDL_Event ev;
	SDL_Surface *video;
	GLuint texturas[NUMTEXTURES];
	float phi, theta; // para la esfera
	float cosphi, costheta, sinphi, sintheta;
	float cosphi2, sinphi2;
	float rad1,rad2,rad3,rad4;
	float x1,y1,z1;
	float y;
	int i,j;
	float osc_inicial;
	//int np=0;

	dl_init();
	
	__builtin_memset(voices, 0, NUM_VOICES*sizeof(struct Voice_STRUCT));
	
	/*
	for (i=0; i<NUM_CHANNELS; ++i)
	{
		channels[i].vol=1.0f;
		channels[i].cutoff=22000.0f;
	}
	*/

	fn.SDL_Init(SDL_INIT_VIDEO|SDL_INIT_AUDIO);

        fn.SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);

	video=fn.SDL_SetVideoMode(1024, 768, 32, SDL_HWSURFACE | SDL_OPENGL | SDL_FULLSCREEN);
	fn.SDL_ShowCursor(0);
	fn.SDL_OpenAudio(&desired, NULL);
	fn.SDL_PauseAudio(0);

	fn.glGenTextures(NUMTEXTURES, texturas);
	
	
	//fn.glClearColor(0.1,0.1,0.3,1.0);

	for (i=0; i<128; ++i)
	{
		for (j=0;j<128;++j)
		{
			int d = SQR(i - 64) + SQR(j - 64);
			unsigned char c = 0;
			Uint8 valor;			
			float coef;
			/*
			buf_tex[128*j+i]=128*( sin((float)j*0.3) *0.5 + 0.5)*(cos(sin((float)i*0.1))*0.5+0.5)+
				128*( sin((float)i*0.3) *0.5 + 0.5)*(cos(sin((float)j*0.1))*0.5+0.5);
			*/
			//buf_tex[128*j+i]=(Uint8)( 64 + 63 * ( sin( (float) sqrt( (5168-j)*(1238-j)+(128-i)*(541-i)) ) ) );
			if(d < 64*64)
				c = 255 * (1 - sqrt(d)/64.0f);
			tex_particle[128*j+i] = c;

			if (abs(i-64)>48)
			{
				coef=(abs(i-64)-48)/16.0;

			}

			valor=(Uint8)( 128 + 127 * sin( (float)i/(74+90*cos((float)j)) )
                                                * cos( 3*(float)j/(62+35*sin((float)i))) ) *c >>7;
			buf_tex[128*j+i]=255-valor;
			/*
			buf_tex[4*(128*j+i)]=buf_tex[4*(128*j+i)+1]=valor;
			buf_tex[4*(128*j+i)+2]=valor+i/2+(128-i)/2-sin(PI*j/128);
			buf_tex[4*(128*j+i)+3]=255;
			*/
		}
	}

        //fn.glEnable(GL_LIGHTING);
        //fn.glLightfv(GL_LIGHT0, GL_AMBIENT, LightAmbient);
        //fn.glLightfv(GL_LIGHT0, GL_DIFFUSE, LightDiffuse);
        //fn.glLightfv(GL_LIGHT0, GL_POSITION, LightPos);

        //fn.glEnable(GL_LIGHT0);
	
	fn.glEnable(GL_BLEND); // Todos los colores tienen alpha adecuado, asi que no hace falta desactivar el blend
	fn.glEnable(GL_TEXTURE_2D);

   	fn.glTexGeni(GL_S, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);
	fn.glTexGeni(GL_T, GL_TEXTURE_GEN_MODE, GL_SPHERE_MAP);

	fn.glBindTexture(GL_TEXTURE_2D, texturas[1]);

	fn.glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE8, 128, 128, 0, GL_LUMINANCE,
		GL_UNSIGNED_BYTE, buf_tex);

	fn.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	fn.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

	fn.glBindTexture(GL_TEXTURE_2D, texturas[2]);
	fn.glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE8, 128, 128, 0, GL_LUMINANCE,
		GL_UNSIGNED_BYTE, tex_particle);

	fn.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	fn.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);


	fn.glPointSize(10);
	while(1)
	{
		while (fn.SDL_PollEvent(&ev))
		{
			if (ev.type==SDL_KEYDOWN)
				goto fin;
		}
		
		fn.glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);


		//fn.glDisable(GL_BLEND);
		fn.glBindTexture(GL_TEXTURE_2D, texturas[1]);
		
		oscilloscope();
		
		if (cur_pos<2) goto nextframe;



		fn.glColor4f(0.4f,0.4f,0.4f,1.0f);
		//fn.glDepthMask(GL_FALSE);
		
		fullscreenquad();

		oscilloscope();

		//fn.glDepthMask(GL_TRUE);
		fn.glEnable(GL_DEPTH_TEST);
		//fn.glEnable(GL_LIGHTING);
		fn.glEnable(GL_COLOR_MATERIAL);

		
		fn.glMatrixMode(GL_PROJECTION);
		//fn.glLoadIdentity();
		fn.gluPerspective(70,1.33f,0.1f,100);

		fn.glMatrixMode(GL_MODELVIEW);
		//fn.glLoadIdentity();
		fn.gluLookAt(0,0,7.5f,0,0,0,0,1,0);

		blah += 1.0f;

		fn.glColor4f(0.8f,0.9f,1.0f,1.0f);

		
		fn.glEnable(GL_TEXTURE_GEN_S);
		fn.glEnable(GL_TEXTURE_GEN_T);

		osc+=0.45f;
		if (cur_pos < 6)
		{
			bombo+=0.5f;
			goto no_bola;
		}
		else
		{
			bombo=1.0f;
		}

		sinphi=0;
		cosphi=1;

		osc_inicial=(cur_pos==6? 0.5f : 1.0f);
		fn.glRotatef(5.0f*blah, 1.0f, 1.0f, 1.0f);
		fn.glTranslatef((1/osc_inicial)*2.5f*sin(osc*osc_inicial)/(0.5f*osc), 0.0f, 0.3f);

		//np=0;
		#define RESOLUCION 0.1f
		for (phi=0; phi<DOSPI; phi+=RESOLUCION)
		{
			costheta=0;
			sintheta=-1;
			sinphi2=sin(phi+RESOLUCION);
			cosphi2=cos(phi+RESOLUCION);
			fn.glBegin(GL_QUAD_STRIP);
			for (theta=-PI/2.0f; theta <= PI/2.0f+RESOLUCION; theta+=RESOLUCION)
			{

				costheta=cos(theta);
				sintheta=sin(theta);
				
				rad1=2.5f+0.3f*sin(3.0f*sin(0.1f*blah)*(cur_pos%4+0.6f)*theta+blah);//*cos(0.001*phi+blah);
				rad2=2.5f+0.3f*sin(3.0f*sin(0.1f*blah)*(cur_pos%4+0.4f)*(theta+RESOLUCION)+blah);//*cos((0.001*phi)+blah);
				//rad3=2.0f+0.1*sin(10.0f*(theta+0.1f)+blah)*cos((0.001*phi+0.1f)+blah);
				//rad4=2.0f+0.1*sin(10.0f*(theta)+blah)*cos((0.001*phi+0.1f)+blah);
				rad3=rad2;
				rad4=rad1;
				

				x1=costheta*cosphi;
				y1=costheta*sinphi;
				z1=sintheta;
				fn.glNormal3f(x1, y1, z1); 
				x1*=rad1;
				y1*=rad1;
				z1*=rad1;
				fn.glVertex3f(x1, y1, z1); 
				/*
				x1=costheta2*cosphi;
				y1=costheta2*sinphi;
				z1=sintheta2;
				fn.glNormal3f(x1, y1, z1); 
				x1*=rad2;
				y1*=rad2;
				z1*=rad2;
				fn.glVertex3f(x1, y1, z1); 
				
				x1=costheta2*cosphi2;
				y1=costheta2*sinphi2;
				z1=sintheta2; 
				fn.glNormal3f(x1, y1, z1); 
				x1*=rad3;
				y1*=rad3;
				z1*=rad3;
				fn.glVertex3f(x1, y1, z1); 
				*/

				x1=costheta*cosphi2;
				y1=costheta*sinphi2;
				z1=sintheta; 
				fn.glNormal3f(x1, y1, z1); 
				x1*=rad4;
				y1*=rad4;
				z1*=rad4;
				fn.glVertex3f(x1, y1, z1); 
				//++np;
			}
			fn.glEnd();
			cosphi=cosphi2;
			sinphi=sinphi2;
		}
no_bola:

		fn.glDisable(GL_TEXTURE_GEN_S);
		fn.glDisable(GL_TEXTURE_GEN_T);

		//__builtin_printf("%d\n", np);

		//fn.glDisable(GL_LIGHTING);		
		fn.glLoadIdentity();
		fn.glMatrixMode(GL_PROJECTION);
		fn.glLoadIdentity();




		fn.glDisable(GL_DEPTH_TEST);
		
		for (i=0; i<128; ++i)
		{
			//buf_scanline[i]=fn.rand();
						
			for (j=0; j<128; ++j)
			{
					buf_scanline[128*i+j]=((i&1) && (!fin)?0x00FFFFFF:0xFF000000)+fn.rand()%30-15;
					
			}
		}



		// partículas
		fn.glBindTexture(GL_TEXTURE_2D, texturas[2]);

		//fn.glEnable(GL_BLEND);
		//fn.glDisable(GL_DEPTH_TEST);
		fn.glBlendFunc(GL_SRC_COLOR, GL_ONE);//GL_ONE_MINUS_SRC_COLOR);

		fn.glColor4f(0.7f, 0.7f, 1.0f, 1.0f);
		draw_particles(0.75f);
		fn.glRotatef(180.0f+rotacion,0.0f,0.0f,1.0f);
		draw_particles(0.75f);
		fn.glRotatef(180.0f-rotacion,0.0f,0.0f,1.0f);
		//__builtin_printf("%d\n", num_particles);
		if(num_particles < MAX_PARTICLES)
		{
			pos[num_particles*2] = (float)(fn.rand()%100)*0.001f;
			pos[num_particles*2+1] = -1.2f;
			num_particles++;
		}


		fn.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

		fn.glBindTexture(GL_TEXTURE_2D, texturas[0]);
	
		fn.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, 128, 128, 0, GL_RGBA,
			GL_UNSIGNED_BYTE, buf_scanline);
		fn.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		fn.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                
		fn.glColor4f(fadeout, fadeout, fadeout,1.5f*ruido);
		if (cur_pos>14) 
		{
			fadeout	/= 1.1f;
			if (fadeout<0.00001f) goto fin;
		}
		fullscreenquad();

nextframe:
		fn.SDL_Delay(30);
		fn.SDL_GL_SwapBuffers();
	}

fin:

//	fn.SDL_PauseAudio(1);
//	fn.SDL_CloseAudio();
	fn.SDL_Quit();
#ifdef X86_ASM
	asm("xorl %eax, %eax\n\t"
	    "incl %eax\n\t"
	    "int $0x80\n\t");
#else
	exit(0);
#endif
}


