#include <stdio.h>
#include <stdlib.h>

/*
 *	WE BE ELEET ENOUGH NOT TO HASSLE WITH PHUKKEN
 *	BOURNE SHELL SCRIPTAHS
 */

const char*pwplogo=
"\033[2J\033[H\n"
"   \033[36;46mMMmmmmmmMM\033[0m\n"
"       \033[36;46mMM\033[0m\n"
"    \033[31;41mxxxxxxxxxxxx\033[0m\n"
"    \033[31;41mxxxxxxxxxxxxxxxxxxx\033[0m\n"
"   \033[31;41mxxxxxxxxx\033[0m\n"
"   \033[33;43mZZZZZ\033[34;44m....\033[0m        %%%%%%%%%  %%%        %%%  %%%%%%%%%\n"
"  \033[37;47m@@@@\033[34;44m......\033[0m        %%%%%%%%%. %%%....... %%%. %%%%%%%%%....\n"
"  \033[37;47m@@@@\033[34;44m....\033[37mo\033[34m.\033[0m   .....%%%   %%%  %%%   %%%  %%%  %%%   %%%\n"
" \033[37;47m@@@@@@@\033[34;44m....\033[0m        %%%   %%%  %%%   %%%  %%%  %%%   %%%\n"
" \033[37;47m@@@@@@@@@@@\033[0m        %%%%  %%%  %%%   %%%  %%%  %%%%  %%%\n"
" \033[37;47m@@@@@@@@@@@@@\033[0m      %%%%  %%%  %%%   %%%  %%%  %%%%  %%%\n"
" \033[37;47m@@@@@@@@@@@@@@@\033[0m    %%%%%%%%%  %%%   %%%  %%%  %%%%%%%%%\n"
"  \033[37;47m@@@@\033[0m              %%%%%%%%%  %%%   %%%  %%%  %%%%%%%%%\n"
"  \033[37;47m@@@@@@\033[0m            %%%        %%%%% %%%  %%%  %%%\n"
"  \033[37;47m@@@@@@@@@@\033[0m  \033[31;41mxx\033[0m    %%%        %%%%% %%%  %%%  %%%\n"
"  \033[37;47m@@@@@@@@@@@@@@\033[0m    %%%        %%%%% %%%% %%%  %%%\n"
"   \033[37;47m@@@@@@@@@@@\033[0m      %%%        %%%%% %%%% %%%  %%%\n"
"   \033[37;47m@@@@@@@@@\033[0m   .....%%%....... %%%%%%%%%%%%%%. %%%..........\n"
"     \033[37;47m@@@@@\033[0m          %%%        %%%%%%%%%%%%%%  %%%\n"
"     \033[37;47m@@@@\033[0m\n\n";


char*prods[] = { "pwplib","oldchsool", NULL };

void printconfig_win32native(f,name,mingwdir,mingwgcclib)
     FILE*f; char*name,*mingwdir,*mingwgcclib;
{
    if(strcmp(name,"pwplib")) {

    fprintf(f,"\n\n"
             "%s: $(OBJS)\n"
             "\tld -Bdynamic -o %s.exe %s/lib/crt2.o "
                  "-L%s/lib -L%s $(OBJS) ../pwplib.a "
                  "-lgcc -lmoldname -lmsvcrt -lkernel32 "
                  "-lwinmm -lmingw32\n"
             "\tstrip %s.exe\n"
             "\tupx %s.exe\n\n",

             name,
             name,mingwdir,
             mingwdir,mingwgcclib,
             name,name);
   }

   fprintf(f,"%%.o: %%.c\n"
             "\tgcc -O2 -mno-cygwin -I../pwplib -c -o $@ -DDRIVE_WIN32 $(@:.o=.c)\n\n");
}

char*systype;

int cpu_is_little_endian()
{
   int numeric=1;
   char*s=(char*)&numeric;
   return (int)(*s);
}

void printconfig_unix(f,name,ccinvo,ldflags)
     FILE*f; char*name,*ccinvo,*ldflags;
{
   if(strcmp(name,"pwplib")) {

   fprintf(f,"\n\n"
             "%s: $(OBJS)\n"
             "\t%s $(OBJS) ../pwplib.a -s -o %s -lm %s\n\n",
             name,ccinvo,name,ldflags);
   }

   fprintf(f,"%%.o: %%.c\n"
             "\t%s -I../pwplib -c -o $@ $(@:.o=.c)\n\n",
             ccinvo);
}

void print_valid_systypes()
{
   puts("* Valid systypes are:\n"
        "  linux  - linux with oss & vcsa console (host endian check)\n"
        "  unix   - generic unix without sound support (host endian check)\n"
        "  hpux   - hp-ux (big-endian unix with native sound support)\n"
        "  cygwin - windows pc system with cygwin\n"
        "  win32  - native win32 binary (cygwin + mingw32 libraries)\n\n");
}

void makeconfig(prodname,systype)
     char*prodname,*systype;
{
    char makefile_in[32],makefile[32];
    FILE *f_in,*f;

    printf("* Writing makefile for %s\n",prodname);

    sprintf(makefile_in,"%s/Makefile.in",prodname);
    sprintf(makefile,   "%s/Makefile",   prodname);

    f_in = fopen(makefile_in,"r");
    f    = fopen(makefile,   "w");

    if(f==NULL) { puts("* Error writing Makefile\n"); exit(1); }
    if(f_in==NULL) { puts("* Error reading Makefile.in\n"); exit(1); }

    {int c;
     while((c=fgetc(f_in))!=EOF) { fputc(c,f); }}

    if(!strcmp(systype,"unix"))
    {
       if(!cpu_is_little_endian())
       printconfig_unix(f,prodname,"gcc -O2 -DUNIX -DBIG_ENDIAN","-lm"); else
       printconfig_unix(f,prodname,"gcc -O2 -DUNIX","-lm");
    }
    else
    if(!strcmp(systype,"hpux"))
       printconfig_unix(f,prodname,"gcc -O2 -DUNIX -DBIG_ENDIAN -DDRIVE_HPUX","-lm");
    else
    if(!strcmp(systype,"linux"))
    {
       if(!cpu_is_little_endian())
       printconfig_unix(f,prodname,"gcc -O2 -DUNIX -DDRIVE_OSS -DDRIVE_LINUXCON -DBIG_ENDIAN","-lm");else
       printconfig_unix(f,prodname,"gcc -O2 -DUNIX -DDRIVE_OSS -DDRIVE_LINUXCON","-lm");
    }
    else
    if(!strcmp(systype,"cygwin")) 
       printconfig_unix(f,prodname,"gcc -O2 -DDRIVE_WIN32","-lm -lwinmm");   
    else
    if(!strcmp(systype,"win32"))
      printconfig_win32native
      (f,prodname,"/usr/local/mingw",
       "/usr/local/mingw/lib/gcc-lib/mingw32/2.95.3-4");
    else
    {
       puts("* Invalid systype!"); print_valid_systypes();
       exit(1);
    }

    fclose(f_in);
    fclose(f);
}

int main(argc,argv)
    int argc; char**argv;
{
    puts(pwplogo);

    if(argc<=1)
    {
       printf("* Usage: %s systype\n",argv[0]);
       print_valid_systypes();
       exit(0);
    }
     else systype=argv[1];

    {char**p=prods;
     while(*p!=NULL)
     {
        makeconfig(*p,systype);
        p++;
     }
    }

    puts("* Finished writing makefiles! Now 'make'\n");

    return 0;
}




