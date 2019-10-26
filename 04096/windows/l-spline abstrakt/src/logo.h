#pragma once

#include <windows.h>
#include <D3DX10math.h>
#include <gl\gl.h>
#include <gl\glu.h>


//#define MIDI_VERSION
#define USING_BLUR

#include "shader.gl.h"
#ifdef DEFAULT_SHADER
char const *svsh="\
varying vec4 Q;\
void main(){\
Q=gl_Color;\
gl_Position=gl_Vertex;\
}";

char const *sfsh="\
varying vec4 Q;\
void main(){\
gl_FragColor=Q;\
}";

char const *blur_svsh="\
varying vec2 R;\
void main(){\
gl_Position=gl_Vertex;\
R=gl_Position.xy;\
}";

char const *blur_sfsh="\
uniform sampler2D U;\
varying vec2 R;\
void main(){\
vec2 r=R*0.5+vec2(0.5,0.5);\
vec4 t=vec4(0,0,0,0),z=texture2D(U,r),f=t;\
float n=0,p=1.1+1.0/max(0.03,z.a),k=sin(R.x*50.0)+sin(R.x*137.0)+sin(R.y*61.0);\
while(++n<p)\
t+=texture2D(U,r+0.001*n*vec2(sin(n*n),cos(n*n)));\
t/=n;\
f=1.0*max(0.7*t.a-z.a,0.04)*vec4(10.0,10.0,10.0,1.0);\
n=0.4*t.a+0.6;\
gl_FragColor=f+0.4*(n*(t+z)+vec4(k,k,0.5,1.0)*max((1.0-n),0.0));\
}";
#else
#include "shader_code.h"
#endif

GLuint logo_shader;

#ifdef USING_BLUR
#ifdef USING_BLUR_SHADER
GLuint blurshader;
#endif
GLuint blur_texture[1];
#endif

typedef D3DXVECTOR3 vec;
typedef D3DXVECTOR3 unitvec;
typedef unsigned char const * PC;
typedef unsigned char OP;

const OP END = 0;
const OP TURTLE = 1;
const OP RUN = 2;
const OP FUNCTION = 3;

#ifdef MIDI_VERSION
	const OP MIDI_CMD = 4;
	const OP MIDI_R2 = 5;
	const OP MIDI_R3 = 6;

	DWORD midi_cmd = 0x257E00;
#endif

const OP WAIT = 6;
const OP CALL = 7;
const OP FORWARD = 8;
const OP TURN = 9;
const OP BEND = 10;
const OP ROLL = 11;
const OP COLOR = 12; // color vector starts here, C in shader
const OP MATERIAL = 13; // C.y
const OP RADIUS = 14;
const OP TIMER_ = 15;
//const OP ALPHA = 15; // C.z


struct Turtle
{
	vec pos;
	unitvec fwd_u;
	unitvec up_u;
	unitvec right_u;

	float op_reg[16];
	float age;
	float max_age;

	Turtle * next;
	Turtle * tail;
};

struct Process
{
	PC pc;
	Turtle * turtle;

	float time_left;

	float wait;
	OP repeat;

	//float trigger_t, interval_t;
	
	//float max_time; //normalise (

	//float phase_time;
	//float interval;
	//float start_time;

	Process * next;
};

Turtle * turtles;
Process * processes;
PC functions[8];
PC * func_pp = functions;

Turtle * MakeTurtle()
{
	return (Turtle *)LocalAlloc(GPTR, sizeof(Turtle));
}
Process* MakeProcess()
{
	return (Process *)LocalAlloc(GPTR, sizeof(Process));
}

Turtle * CopyTurtle(Turtle * ct)
{
	Turtle * t_new = MakeTurtle();
	memcpy(t_new, ct, sizeof(Turtle));
	//CopyMemory(t_new, ct, sizeof(Turtle));
	return t_new;
}

unsigned int RND = 0;
unsigned int random()
{
	RND = (1664525 * RND + 1013904223);
	return RND;
}

float rndf()
{
	return ((float)(random() & 0xFFFF)) / 65536.f;
	//return ((float)random()) / 4294967296.f;
}

void RotateNormal(vec * v, vec const* axis, float angle)
{
	D3DXMATRIX mat;
	D3DXVec3TransformNormal(v, v, D3DXMatrixRotationAxis(&mat, axis, angle));
}
/*
void RRN(vec * v1, vec * v2, vec * axis, float angle)
{
	RotateNormal(v1, axis, angle);
	RotateNormal(v2, axis, angle);
}*/


void TurtleVertex(Turtle * tu, float ang)
{
	unitvec v = tu->right_u;
	RotateNormal(&v, &tu->fwd_u, ang);
	//glTexCoord1f(t);
	glNormal3fv((float*)&v);
	tu->op_reg[TIMER_] = t;
	glColor4fv((float*)&tu->op_reg[COLOR]);
	glVertex3fv((float *)&(tu->pos));// + v*tu->op_reg[RADIUS]));
}

__forceinline void DrawTurtles()
{
	//Turtle * tprev = turtles;
	for(Turtle * tu = turtles; tu = tu->next; )
	{
		Turtle * tnext;
		for(Turtle * tnode = tu; tnext = tnode->tail; tnode = tnext)
		{
			//tnode->op_reg[ALPHA] = tnode->age / tnode->max_age;
			//tnext->op_reg[ALPHA] = tnext->age / tnext->max_age;////
			glBegin(GL_TRIANGLE_STRIP);
			{
				//const float thf16_2pi = 6.2832f;
				//const float thf16_da = 1.258f;
				for (float n=0; n<6.2832f; n+=1.256f * 0.5f)
				{
					TurtleVertex(tnode, n);
					TurtleVertex(tnext, n);
				}
			} glEnd();

			//tnode->age += DT;
			if (tnode->max_age < (tnode->age += DT))
			{
				tnode->tail = 0;
				//tnode->age = 0;
			}
			//break;
		}
		//tnode->age += DT;
		//tprev = tu;
	}

}



#define Skip(x) Eval(x, 0)

/*
PC Skip(PC pc)
{
	for (OP op; op = *(pc++);)
	{
		if ((op & 0xF) < 8)
			pc = Skip(pc);
	}
	return pc;
}*/

__forceinline float Byte2Float(OP b)
{
	//float f = (float)(((int)b) - 50);
	//f = f*f*f*0.00003f + f*0.005f;
	
		__int32 i = b;
		i = 0x3c280000 + (i << 19) + (i << 31);

		float* pf = (float*)&i;
		float f = *pf;
	

	return f;
}


PC Eval(PC pc, Turtle * turtle)
{
	for (OP codebyte; codebyte = *(pc++);)
	{
		const OP execmode = codebyte >> 4;
		const OP op = codebyte & 0xF;
					
		if (!turtle)
		{
			/*if (op == RUN) pc += execmode+1;
			else*/ if (execmode) ++pc;
			if (op < 4)
				pc = Skip(pc);
			continue;
		}

		OP byval = 0;

		float F;

		float by;
		
		if (execmode)
			by = Byte2Float(byval = *(pc++));

		float & OF = turtle->op_reg[op];
		float Fs[4] = {OF, by, OF*by, by * (rndf() - 0.5f)};

		F = Fs[execmode];
		OF = F;
	
		//if (! execmode) --pc;

		if (op == TURTLE)
		{
			Turtle * t_new = CopyTurtle(turtle);
			t_new->tail = 0;
			turtle->next = t_new;
			t_new->age = 0;
			t_new->max_age = F;
			pc = Eval(pc, t_new);
		}
		else if (op == RUN)
		{
			Process * proc = MakeProcess();
			proc->next = processes->next;
			processes->next = proc;
			proc->pc = pc;
			proc->turtle = turtle;
			float wait = turtle->op_reg[WAIT];
			proc->time_left = wait;
			proc->wait = wait;
			proc->repeat = byval;
			//proc->interval = F2;
			//proc->start_time = F3;
			pc = Skip(pc);
		}
		else if (op == FUNCTION)
		{
			*(func_pp++) = pc;
			pc = Skip(pc);
		}
		else if (op == CALL)
		{
			Eval(functions[byval], turtle);
		}
		else if (op == FORWARD)
		{
			Turtle * new_node = CopyTurtle(turtle);
			turtle->pos += turtle->fwd_u * F;
			turtle->age = 0;
			turtle->tail = new_node;
		}
		else if (op == TURN)
		{
			//float angle = 0.01f;
			//RRN(&turtle->fwd_u,&turtle->right_u, &turtle->up_u, F);
			RotateNormal(&turtle->fwd_u, &turtle->up_u, F);
			RotateNormal(&turtle->right_u, &turtle->up_u, F);
		}
		else if (op == BEND)
		{
			//float angle = 0.01f;
			//RRN(&turtle->fwd_u,&turtle->up_u, &turtle->right_u, F); FUR RFU URF
			RotateNormal(&turtle->fwd_u, &turtle->right_u, F);
			RotateNormal(&turtle->up_u, &turtle->right_u, F);
		}
		else if (op == ROLL)
		{
			//float angle = 0.01f;
			//RRN(&turtle->right_u,&turtle->up_u, &turtle->fwd_u, F);
			RotateNormal(&turtle->right_u, &turtle->fwd_u, F);
			RotateNormal(&turtle->up_u, &turtle->fwd_u, F);
		}

#ifdef MIDI_VERSION
		else if (op == MIDI_CMD)
		{
			midi_shortmsg(midi_cmd | byval);
		}
		else if (op == MIDI_R2)
		{
			midi_cmd ^= (midi_cmd & 0xFF00) ^ (byval << 8);
		}
		else if (op == MIDI_R3)
		{
			midi_cmd ^= (midi_cmd & 0xFF0000) ^ (byval << 16);
		}
#endif
		//else
		//{
		//}
	}
	return pc;
}


#ifdef DEFAULT_CODE

unsigned char const code[] =
{
	TURTLE,
	END,
END
};

#else

unsigned char const code[] =
{
#include "out.lh"
};

#endif

__forceinline void RunProcesses()
{
	Process * pprev = processes;
	for(Process * proc = processes; proc = proc->next;)
	{
		//float proc_t = (proc->time += DT);
		//if (proc->start_time < proc_t)
		//if (0 < (proc->time_left -= DT))
		//{
		//	proc->phase_time += DT;
		//	if (proc->interval < proc->phase_time)
		//	{
		//		proc->phase_time -= proc->interval;
		//		Eval(proc->pc, proc->turtle);
		//	}
		//}
		//if (proc->max_time < proc_t)
			//pprev->next = proc->next;

		float proc_t_left = (proc->time_left -= DT);

		Process * next_pprev = proc;

		if (proc_t_left < 0)
		{
			Eval(proc->pc, proc->turtle);
			proc->time_left = proc->wait;
			if (--proc->repeat == 0)
			{
				pprev->next = proc->next;
				next_pprev = pprev;
			}
		}

		pprev = next_pprev;
		//	if (--proc->repeat == 0)
		//		pprev->next = proc->next;
		////else //if (proc_t_left < proc->trigger_t)
		//	//proc->trigger_t -= proc->interval_t;
		//	else
		//		pprev = proc;
		//}

		//if (proc_t_left < 0)
		//	pprev->next = proc->next;
		//else //if (proc_t_left < proc->trigger_t)
		//{
		//	//proc->trigger_t -= proc->interval_t;
		//	Eval(proc->pc, proc->turtle);
		//	pprev = proc;
		//}
	}
}

float phase_time = 0.0f;

void RunLogo()
{
	while (phase_time < t)
	{

	phase_time += DT;

	//glClearColor(0.1f,0,0,0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	glEnable(GL_DEPTH_TEST);
	
	use_shader(logo_shader);

	RunProcesses();

	glRectf(-3.f,-3.f,3.f,3.f);
	DrawTurtles();
	
#ifdef USING_BLUR
	glReadBuffer(GL_BACK);
	glCopyTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 0, 0, XRES, YRES, 0);
	
	const int my_sampler_uniform_location = ((PFNGLGETUNIFORMLOCATIONPROC)wglGetProcAddress("glGetUniformLocation"))(logo_shader, "U");
	((PFNGLUNIFORM1IPROC) wglGetProcAddress("glUniform1i"))(my_sampler_uniform_location,0);

	//glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
 #ifndef USING_BLUR_SHADER


 #else
	use_shader(blurshader);
	glDisable(GL_DEPTH_TEST);

	//glBindTexture(GL_TEXTURE_2D, blur_texture[0]);
	int my_sampler_uniform_location = ((PFNGLGETUNIFORMLOCATIONPROC)wglGetProcAddress("glGetUniformLocation"))(blurshader, "U");
	((PFNGLUNIFORM1IPROC) wglGetProcAddress("glUniform1i"))(my_sampler_uniform_location,0);

	glTexCoord1f(t);
	glRectf(-1.f,-1.f,1.f,1.f);
 #endif
#endif
	//glEnable(GL_DEPTH_TEST);

	PeekMessage(NULL,0,0,0,PM_REMOVE);
	SwapBuffers(hDC);

	}
}

void InitLogo()
{
#ifdef USING_BLUR
	glGenTextures(1, blur_texture);
	glBindTexture(GL_TEXTURE_2D, blur_texture[0]);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, 4, XRES, YRES, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
	
#ifdef USING_BLUR_SHADER
	blurshader = make_shader(&logo_blur_vs_glsl, &logo_blur_fs_glsl);
#endif
#endif
	logo_shader = make_shader(&logo_vs_glsl, &logo_fs_glsl);

	turtles = MakeTurtle();
	processes = MakeProcess();

	turtles->fwd_u.z = 1.f;
	turtles->up_u.y = 1.f;
	turtles->right_u.x = 1.f;
	//turtles->op_reg[RADIUS] = 0.02f;

	Eval(code, turtles);
}

#ifdef RESTART_ENABLED

#define CCWORD(w1,w2,val) if (strcmp(w1,w2) == 0) return val;

OP CCWord(char const* word)
{
	CCWORD(word, "end", END)
	CCWORD(word, "turtle", TURTLE)
	CCWORD(word, "run", RUN)
	CCWORD(word, "function", FUNCTION)
	CCWORD(word, "wait", WAIT)
	CCWORD(word, "call", CALL)
	CCWORD(word, "forward", FORWARD)
	CCWORD(word, "turn", TURN)
	CCWORD(word, "bend", BEND)
	CCWORD(word, "roll", ROLL)
	CCWORD(word, "radius", RADIUS)
	CCWORD(word, "color", COLOR)
	CCWORD(word, "material", MATERIAL)
#ifdef MIDI_VERSION
	CCWORD(word, "midicmd", MIDI_CMD)
	CCWORD(word, "midi2", MIDI_R2)
	CCWORD(word, "midi3", MIDI_R3)
#endif

	OP byval = 0;
	bool use_raw = false;
	float sign = 1.f;
	if (*word == '-')
		sign = -1.f;
	float fval = 0;
	float fcmul = 1.f;
	bool past_comma = false;
	for (char const* ch = word; *ch; ++ch)
	{
		if (*ch >= '0' && *ch <= '9')
		{
			byval = byval*10 + (*ch - '0');
			fval = fval*10.f + (*ch - '0');
			if (past_comma)
				fcmul *= 0.1f;
		}
		else if (*ch == '.')
			past_comma = true;
		else if (*ch == '#')
			use_raw = true;
	}
	fval *= sign * fcmul;

	if (use_raw)
		return byval;

	OP val = 0;
	float dist = 9999999.9f;
	for (int n=0; n<256; ++n)
	{
		float nval = Byte2Float((OP)n);
		float ndist = fval-nval;
		if (ndist < 0) ndist *= -1.0f;

		if (ndist < dist)
		{
			dist = ndist;
			val = n;
		}
	}
	return val;
}

PC CompileLogo()
{
	char const * logo_vs = ReadFile("demo.logo");
	
	OP * new_code = new OP[32768];
	OP * writepos = new_code;
	char word[64];
	char * wordpos = word;
	for (char const * readpos = logo_vs; *readpos; ++readpos)
	{
		char c = *((char *)readpos);
		if (c == ' ' || c == '\n' || c == '\r' || c == '\t' || c == ':' || c == '*' || c == '?')
		{
			OP mask = 0;
			if (c == ':')
				mask = 16;
			else if (c == '*')
				mask = 32;
			else if (c == '?')
				mask = 48;
			
			if (wordpos > word)
			{
				*wordpos = 0;

				OP cc = CCWord(word) | mask;
				
				*(writepos++) = cc;
				wordpos = word;
			}
		}
		else if (c == '!')
			break;
		else
		{
			*(wordpos++) = c;
		}
	}

	*writepos = 0;

	HANDLE file = CreateFile("out.lh", GENERIC_WRITE, FILE_SHARE_WRITE, 0, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0);



	for (PC p = new_code; p <= writepos; ++p)
	{
		OP o = *p;
		char s[] = "     ";

		if (o / 100)
			s[0] = '0' + o/100;

		if ((o / 10) % 10 || o / 100)
			s[1] = '0' + ((o / 10) % 10);

		s[2] = '0' + (o % 10);

		if (p != writepos)
			s[3] = ',';

		DWORD dd;
		WriteFile(file, s, 5, &dd,0);
	}

	CloseHandle(file);

	return new_code;
}

void RestartLogo()
{
	//delete
	//turtles->next = 0;
	//processes->next = 0;

	phase_time = 0;

	turtles = MakeTurtle();
	processes = MakeProcess();

	turtles->fwd_u.z = 1.f;
	turtles->up_u.y = 1.f;
	turtles->right_u.x = 1.f;
	turtles->op_reg[RADIUS] = 0.02f;

	func_pp = functions;
	Eval(CompileLogo(), turtles);

#ifdef MIDI_VERSION
	//midiOutClose(midiout);
	//midiOutOpen(&midiout, 0, 0, 0, 0);
#endif
}

void ReloadLogo()
{
	use_shader(0);
	
	delete_shader(logo_shader);
	char const * logo_vs = ReadFile("logo_vs.glsl");
	char const * logo_fs = ReadFile("logo_fs.glsl");
	logo_shader = make_shader(&logo_vs, &logo_fs);

#ifdef USING_BLUR_SHADER
	delete_shader(blurshader);
	char const * logo_blur_vs = ReadFile("logo_blur_vs.glsl");
	char const * logo_blur_fs = ReadFile("logo_blur_fs.glsl");
	blurshader = make_shader(&logo_blur_vs, &logo_blur_fs);
#endif

	use_shader(logo_shader);
}
#endif



