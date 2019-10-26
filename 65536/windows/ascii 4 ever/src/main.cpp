#include <windows.h>
#include <conio.h>
#include <mmsystem.h>
#include <stdio.h>
#include <math.h>
#include "minifmod.h"


const int ascii_w = 88;
const int ascii_h = 33;
const int pouet_w = 82;
const int pouet_h = 20;
const int exp_w = 117;
const int exp_h = 23;
int Width = 117;
int Height= 23;
const int MaxWidth=80;
const int MaxHeight=25;
int Time=0, StartTime=0, LastTime=0, BeginTime=0;
float speed = 2;
HANDLE STDOut;

char*	FileName = "experience";
FILE*	File;
char*	buffer;
char*	pouet;
char*	ascii;
char*	experience;

char*	Scroller = "                                                                                     Feel the joy of oldschool effects in TEXT mode !! Enjoy ! Plus odlschool tu meurs                                                                    ASCII 4 EVER :: Code : Antoche  /  Zik : Kenet (Funk)  /  Gfx ASCII : Antoche (enfin, bgascii plutot)                                                                       First released at Synthesis Party 2001                                                                                             Special greets from Antoche to : Kenet, Chewbacca, Sanx, CaptainFR, #codefr (plus de fasts !), #demofr (plus de jus d'orange !), #pixelfr (plus d'einstein !), #traxfr (plus de voix !) et tous les autres !                                                                                                          Et vive les scrollers a la con";

const int OutWidth = 80;
const int OutHeight = 49;
float*	precalc;
char*	bufecran;
WORD*	bufcolorecran;
float	Raster1,Raster2,Raster3;


unsigned int fileopen(char *name)
{
	return (unsigned int)fopen(name, "rb");
}

void fileclose(unsigned int handle)
{
	fclose((FILE *)handle);
}

int fileread(void *buffer, int size, unsigned int handle)
{
	return fread(buffer, 1, size, (FILE *)handle);
}

void fileseek(unsigned int handle, int pos, signed char mode)
{
	fseek((FILE *)handle, pos, mode);
}

int filetell(unsigned int handle)
{
	return ftell((FILE *)handle);
}



void	Init()
{
	int i,j;

	pouet = new char[pouet_h*pouet_w];
	ascii = new char[ascii_h*ascii_w];
	experience = new char[exp_w*exp_h];
	precalc = new float[OutWidth*OutHeight];
	bufecran = new char [OutWidth*OutHeight];
	bufcolorecran = new WORD [OutWidth*OutHeight];

	for (j=0 ; j<OutHeight ; j++)
		for (i=0 ; i<OutWidth ; i++)
			precalc[j*OutWidth + i] = sqrt(i*i+j*j);

	File = fopen(FileName , "r");
	fread(experience,exp_w*exp_h,1,File);
	fclose(File);
	
	File = fopen("pouet" , "r");
	fread(pouet,pouet_h*pouet_w,1,File);
	fclose(File);

	File = fopen("ascii" , "r");
	fread(ascii,ascii_h*ascii_w,1,File);
	fclose(File);
	
	buffer = experience;
	Width = exp_w;
	Height = exp_h;


}

void turn()
{
	for (int i=0 ; i<Width*Height ; i++)
		switch(buffer[i])
		{
			case '+':
				buffer[i]='\\';
				break;
			case '\\':
				buffer[i]='|';
				break;
			case '-':
				buffer[i]='\\';
				break;
			case '/':
				buffer[i]='-';
				break;
			case '|':
				buffer[i]='/';
				break;
			default:
				break;
		}
}

void clearscreen()
{
	system("cls");
}


void wait(DWORD t)
{
	DWORD Begin = timeGetTime();
	while (timeGetTime()-Begin<t);
}

void printtitle(int offset, int offset2, float offset3, float offset4=0)
{
	int i;
	char FormatString[100];

	if (kbhit()) exit(0);
	clearscreen();
	for (i=0 ; i<offset2 ; i++) printf("\n");
	for (i=0 ; i<Height ; i++)
	{
		int offs = int(offset3*(1+sin(i/2. + offset4)));
		sprintf(FormatString,"%s%d%s","%.",MaxWidth-offs,"s");
		for (int j=0 ; j<offs ; j++) printf(" ");
		printf(FormatString,buffer+i*Width+int(offset)+1);
	}
	//for (i=offset2  ; i<; i++) printf("\n");
	
	wait(50);
}



inline int modulo(int a, int b)
{
	return (a%b>=0 ? a%b : (a%b)+b);
}

void	blit(char* dest, int wd, const char* source, int ws, int hs)
{
	for (int i=0 ; i<ws ; i++)
		for (int j=0 ; j<hs ; j++)
			dest[j*wd+i] = source[j*ws+i];
}



void rotozoom(int cx, int cy, float angle, float zoom2, float coef=.1, float coefloupe=0, bool dorasters=false)
{
	int i,j;
	float zoom;
	float zoom3;
	if (kbhit()) return;

	Raster1 = - sin((Time-BeginTime)/300.)*OutHeight/4.
			  + cos((Time-BeginTime)/100.)*OutHeight/4.
			  + sin((Time-BeginTime)/200.)*OutHeight/4.
			  + OutHeight/2.;
	Raster2 = + sin((Time-BeginTime)/400.)*OutHeight/3.
			  - cos((Time-BeginTime)/200.)*OutHeight/4.
			  - sin((Time-BeginTime)/300.)*OutHeight/5.
			  + OutHeight/2.;
	Raster3 = - sin((Time-BeginTime)/600.)*OutHeight/4.
			  - cos((Time-BeginTime)/400.)*OutHeight/5.
			  + sin((Time-BeginTime)/500.)*OutHeight/3.
			  + OutHeight/2.;


	for (j=0 ; j<OutHeight ; j++)
	{
		zoom3= zoom2 + sin(float(j)/OutHeight*2*3.14)*coef;
		for (i=0 ; i<OutWidth ; i++)
		{
			int n = abs(j-cy)*OutWidth + abs(i-cx);
			zoom = zoom3 + 4*precalc[n]*precalc[n]*coefloupe/OutHeight/OutHeight;
			int x = zoom*precalc[n]*cos(angle+atan2(double(j-cy),double(i-cx)));
			int y = zoom*precalc[n]*sin(angle+atan2(double(j-cy),double(i-cx)));
			bufecran[j*OutWidth + i] = buffer[modulo(y, Height)*Width + modulo(x, Width)];
			bufcolorecran[j*OutWidth + i] = 0;
			switch (abs(y/Height)%3) {
			case 0: bufcolorecran[j*OutWidth + i] |= FOREGROUND_GREEN;	break;
			case 1:	bufcolorecran[j*OutWidth + i] |= FOREGROUND_BLUE;	break;
			case 2: bufcolorecran[j*OutWidth + i] |= FOREGROUND_RED;	break;
			}
			switch ((y/Height)+2) {
			case 2: bufcolorecran[j*OutWidth + i] |= FOREGROUND_GREEN;	break;
			case 1:	bufcolorecran[j*OutWidth + i] |= FOREGROUND_BLUE;	break;
			case 0: bufcolorecran[j*OutWidth + i] |= FOREGROUND_RED;	break;
			}
		}
		if (dorasters && j==int(Raster1)) for (i=0 ; i<OutWidth ; i++) bufcolorecran[j*OutWidth + i] |= BACKGROUND_RED;
		if (dorasters && j==int(Raster2)) for (i=0 ; i<OutWidth ; i++) bufcolorecran[j*OutWidth + i] |= BACKGROUND_BLUE;
		if (dorasters && j==int(Raster3)) for (i=0 ; i<OutWidth ; i++) bufcolorecran[j*OutWidth + i] |= BACKGROUND_GREEN;
		//printf("%.80s",bufecran+j*OutWidth);
	}
	COORD startcoords = {0,0};
	DWORD N;

	WriteConsoleOutputCharacter(STDOut,
		bufecran,
		OutHeight*OutWidth,
		startcoords,
		&N);
	WriteConsoleOutputAttribute(STDOut,
		bufcolorecran,
		OutHeight*OutWidth,
		startcoords,
		&N);

	int scrolleroffset=((Time-BeginTime)/80)%strlen(Scroller);
	COORD ScrollerCoords = {0,49};
	WriteConsoleOutputCharacter(STDOut,
		Scroller+scrolleroffset,
		80,
		ScrollerCoords,
		&N);

	//wait(20);

}


int main()
{
	int i;
	float offset=0,offset2=0, offset3=0 , offset4=0;

	
	FMUSIC_MODULE *mod;

	FSOUND_File_SetCallbacks(fileopen, fileclose, fileread, fileseek, filetell);

	if (!FSOUND_Init(44100, 0))
	{
		printf("Error upon initialization\n");
		exit(0);
	}

	// ==========================================================================================
	// LOAD SONG
	// ==========================================================================================
	mod = FMUSIC_LoadSong("kenet_funky.xm", NULL); //sampleloadcallback);
	if (!mod)
	{
		printf("Error loading song\n");
		exit(0);
	}
	
	STDOut = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleTitle("Pouet !");
	COORD size = {80,50};
	SMALL_RECT rect={1,1,80,50};
	CONSOLE_CURSOR_INFO cursorinfos = {10,FALSE};
	SetConsoleWindowInfo(STDOut, TRUE, &rect);
	SetConsoleScreenBufferSize(STDOut, size);
	SetConsoleCursorInfo(STDOut, &cursorinfos);

	printf("This intro runs properly on windows NT/2K !\n");
	printf("Please switch to full screen (Alt+Enter) if you are not in ths mode then press any key to start\n");
	getch();


	Init();
	FMUSIC_PlaySong(mod);
	StartTime =timeGetTime();
	Time = StartTime;
	LastTime=Time;
	BeginTime = StartTime;


	while (true)
	{
		offset=0;
		StartTime = Time;
		while(Time-StartTime<9800)
		{
			if (kbhit()) break;
			rotozoom(0,0,0,1.5*sin((Time-StartTime)*3.14/2000.),0);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;

		offset=0;
		StartTime = Time;
		while(Time-StartTime<10100)
		{
			offset+=(Time-LastTime)/2000.;
			if (kbhit()) break;
			rotozoom(0,0,offset,1.5*sin((Time-StartTime)*3.14/2000.),0);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;

		StartTime = Time;
		while(Time-StartTime<4700)
		{
			if (kbhit()) break;
			if ((Time%300)<50) 
			{
				if (buffer==pouet)
				{
					buffer = experience;
					Width = exp_w;
					Height = exp_h;
				}
				else
				{
					buffer = pouet;
					Width = pouet_w;
					Height = pouet_h;
				}

			}
			rotozoom(0,0,(Time-StartTime)/5000.,1.0,0);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;


		StartTime = Time;
		while(Time-StartTime<19600)
		{
			if (kbhit()) break;
			if ((Time%300)<50) 
			{
				if (buffer==pouet)
				{
					buffer = experience;
					Width = exp_w;
					Height = exp_h;
				}
				else
				{
					buffer = pouet;
					Width = pouet_w;
					Height = pouet_h;
				}

			}
			rotozoom(0,0,-(Time/310*310-StartTime/310*310)/2000.,1.3,0);
			LastTime = Time;
			Time = timeGetTime();
		}
		
		//if (kbhit()) if (getch()==27) break;
		
		buffer = pouet;
		Width = pouet_w;
		Height = pouet_h;

		StartTime = Time;
		while(Time-StartTime<9700)
		{
			if (kbhit()) break;
			offset=2*3.14*(Time-StartTime)/10000.;
			rotozoom(15+15*sin(offset*3),30+10*sin(offset*2),offset,1.5,0);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;

		buffer = ascii;
		Width = ascii_w;
		Height = ascii_h;

		StartTime = Time;
		while(Time-StartTime<10000)
		{
			if (kbhit()) break;
			offset=2*3.14*(Time-StartTime)/10000.;
			rotozoom(15+15*sin(offset*3),30+10*sin(offset*2),-offset,1.5+sin(offset)/2.,0);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;
		
		StartTime = Time;
		while(Time-StartTime<9700)
		{
			if (kbhit()) break;
			offset=2*3.14*(Time-StartTime)/10000.;
			rotozoom(15+15*sin(offset*3),30+10*sin(offset*2),offset,1.5+sin(offset)/2.,.2,0);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;

		
		StartTime = Time;
		while(Time-StartTime<20000)
		{
			if (kbhit()) break;
			offset=2*3.14*(Time-StartTime)/10000.;
			rotozoom(25+15*(-20000+Time-StartTime)/20000.*sin(offset*3) , 30-10*(-20000+Time-StartTime)/20000.*sin(offset*2) , -offset,1.+sin(offset)/2. , sin(offset*2)*.2,sin(offset*5)*.2);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;

		StartTime = Time;
		while(Time-StartTime<38800)
		{
			if (kbhit()) break;
			if ((Time%500)<40) 
			{
				if (buffer==pouet)
				{
					buffer = ascii;
					Width = ascii_w;
					Height = ascii_h;
				}
				else
				{
					buffer = pouet;
					Width = pouet_w;
					Height = pouet_h;
				}
			}

			offset+=sin((Time-StartTime)/1000.+offset/100.)/50.;
			rotozoom(40 , 20 , offset, 1.2+sin(offset)*1.5 , sin(offset*2)*.3,sin(offset*5)*.1,true);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;

		StartTime = Time;
		while(Time-StartTime<20000)
		{
			if (kbhit()) break;
			if ((Time%500)<40) 
			{
				if (buffer==pouet)
				{
					buffer = ascii;
					Width = ascii_w;
					Height = ascii_h;
				}
				else
				{
					buffer = pouet;
					Width = pouet_w;
					Height = pouet_h;
				}
			}

			offset=2*3.14*(Time-StartTime)/10000.;
			rotozoom(40 , 20 , -offset,1.5+sin(offset)/2. , sin(offset*2)*.3,sin(offset*5)*.1,true);
			LastTime = Time;
			Time = timeGetTime();
		}
		//if (kbhit()) if (getch()==27) break;

		Scroller = "                                                                                       It's finished. You may press a key to exit or stay to enjoy this intro !";
		StartTime = Time;
		while(true)
		{
			if (kbhit()) break;
			if ((Time%500)<40) 
			{
				if (buffer==pouet)
				{
					buffer = ascii;
					Width = ascii_w;
					Height = ascii_h;
				}
				else
				{
					buffer = pouet;
					Width = pouet_w;
					Height = pouet_h;
				}
			}

			offset=2*3.14*(Time-StartTime)/10000.;
			rotozoom(40 , 20 , offset,1.5+sin(offset)/2. , sin(offset*2)*.3,sin(offset*5)*.1,true);
			LastTime = Time;
			Time = timeGetTime();
		}
		
		break;
	}

	FMUSIC_FreeSong(mod);
	FSOUND_Close();

	delete[] pouet;
	delete[] ascii;
	delete[] experience;
	delete[] precalc;
	delete[] bufecran;
	delete[] bufcolorecran;

	return 0;
}