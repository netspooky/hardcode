#include <stdio.h>
#include <conio.h>
#include <dos.h>
#include <io.h>
#include <stdlib.h>
char *fname[20];
FILE *crc;
unsigned int top,top2;
long s1,s2,s3;
unsigned int byt;
void main(int argc, char *arg[])
{
if (arg[1]==NULL)
        {
        printf("\nexe adi:");fscanf(stdin,"%s",fname);
        }
else
        strcpy(fname,arg[1]);
top=0;top2=0;
if ((crc=fopen(fname,"r+b"))==NULL)
        {
        printf("\n%s bulunamadi",fname);
        exit(0);
        }
printf("\nDosyanin uzunlugu : %u",filelength(fileno(crc)));
for(s1=0;s1<=filelength(fileno(crc));s1++)
        {
	fread(&byt,1,1,crc);
        top2+=byt;
        }
fwrite(&top2,2,1,crc);
fclose(crc);
printf("\ncrc degeri %u ve exe'ye eklendi",top2);

}
