//----------------------------------------------------------------------------
//
//                            E L I T E G R O U P
//                             we are very good.
//
// MXMPlay/Win32 v0.9 (based on MXMPlay 1.6)
// done and (C) The Artist Formerly Known As Doctor Roole in 1999
//
// -> Example source for use with Watcom C/C++
//
//----------------------------------------------------------------------------

#define WIN32_LEAN_AND_MEAN

#include <math.h>
#include <stdio.h>
#include <conio.h>
#include <windows.h>
#include "mxmplay.h"
#include "dsio.h"
#include "savexi.h"

extern char mxmfile[];

extern DWORD ficken, ficken2;

extern "C" extern int __stdcall syRender(int n, signed short *buf, int size);

// it's just simple:

signed short sb[1000000];

typedef struct { char *name; int len; } insinfo;

insinfo smpls[] = { {"SynLead 1", 135000},
									  {"SynPad 1", 135000},
									  {"dark synbass", 150000},
                    {"808 HH closed", 10000},
                    {"tbseq 1", 60000},
                    {"tbseq 2", 60000},
                    {"tbseq 3", 60000},
                    {"tbseq 4", 60000},
                    {"tbseq 5", 60000},
                    {"tbseq 6", 60000},
                    {"909 Basedrum 1", 20000},
                    {"909 Snare 1", 10000},
                    {"808 HH open", 30000},
                    {"rumms      ", 80000},
                    {"ms2kspeech", 100000},
                    {"virseq 1 F", 80000},
                    {"moogbass", 40000},
                    {"fake bell", 100000},
                    {"virseq 1 C#", 80000},
                    {"virseq 1 A#", 80000},
										{"SynLead 2", 200000},
									};


void main(int argc, char *argv[])
{

  setbuf(stdout,0);

  printf("\n--- MakeSamples 1.0 (C) 1999 The Artist Formerly Known As Doctor Roole '99\n");

	char buf[100];

	int fi=0;
	int li=sizeof(smpls)/sizeof(insinfo);

	if (argc>1)
	{
		int x;
  	sscanf(argv[1],"%x",&x);
		x--;
		if (x>0 && x<li) fi=x;
	}
	if (argc>2)
	{
		int x;
  	sscanf(argv[2],"%x",&x);
		if (x>0 && x<li) li=x;
	}

	for (int n=fi; n<li; n++)
	{
    printf ("rendering sample %02x (%s) ... ",n+1,smpls[n].name);
		syRender(n,sb,smpls[n].len);
		printf ("saving ... ");
		sprintf(buf,"%02x",n+1);
		savexi(buf, smpls[n].name, sb, smpls[n].len);
		printf("ok\n");
	}

  printf("\nwe are very good.\n");
}