#include "stdio.h"
#include "string.h"


char *abc=" -0123456789:;?ABCDEFGHIJKLMNOPQRSTUVWXYZ.,abcdefghijklmnopqrstuvwxyz";

void main(void){

  int i,j;

  int tot_out=0;

  FILE *f1=fopen("1.fnt","rb");
  FILE *f2=fopen("fontdata.cpp","wt");
  FILE *f3=fopen("fontdata.h","wt");

  fprintf (f3,"extern char font_abc[];\n");
  fprintf (f3,"extern unsigned char font_data[];\n");
  fprintf (f3,"extern unsigned short font_index[];\n");

  fprintf(f2,"char  font_abc[]=\"%s\";\n",abc);

  tot_out+=strlen(abc)+1;

  int font_index[256];
  int index=0;

  fprintf(f2,"//sh,sw,ox,oy\n");
  fprintf(f2,"unsigned char font_data[]={\n");

  for (i=0;i<strlen(abc);i++){
    char ox=0;
    char oy=0;
    char sh=16;
    char sw=8;

    char c=abc[i];

    font_index[i]=index;

    char temp[16];

    fseek(f1,c*16,SEEK_SET);
    fread(temp,1,16,f1);

    int k;


    while (!temp[0]&&sh>0){
      for (k=0;k<sh-1;k++){
        temp[k]=temp[k+1];
      }
      sh--;
      oy++;
    }

    if (sh)
      while (!temp[sh-1]) sh--;

    if (!sh) oy=0;

    int maxw=0;
    for (k=0;k<sh;k++){
      int wx=8;
      for (int bt=0;bt<8;bt++,wx--){
        if (temp[k]&1<<bt) break;
      }
      if (wx>maxw) maxw=wx;
    }
    sw=maxw;

    fprintf(f2,"%d,%d,%d,%d,",sh,sw,ox,oy);
    index+=4;
    tot_out+=4;

    if (sh) {
      for (j=0;j<sh;j++){
        fprintf(f2,"%u",(unsigned char)temp[j]);
        if (j!=sh-1||i<strlen(abc)-1) fprintf(f2,",");
        else fprintf(f2,"};\n");
        if (j==sh-1) fprintf(f2,"\n");

        index++;
        tot_out++;
      }
    }
    else fprintf(f2,"\n");
  }
  fprintf(f2,"unsigned short font_index[]={\n");
  for (i=0;i<strlen(abc);i++){
    fprintf(f2,"%u",font_index[i]);
    if (i<strlen(abc)-1) fprintf(f2,",\n");
    else fprintf(f2,"};\n");

    tot_out+=2;
  }
  printf("Total output size=%d\n",tot_out);
}


