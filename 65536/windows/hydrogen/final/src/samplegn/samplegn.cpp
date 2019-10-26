// samplegn.cpp : Defines the entry point for the console application.
//

#include <stdio.h>
#include <conio.h>
#include <string.h>
#include "generate.h"

#define MF_RESUME -1

int   freadnm(char *buf,int bites,FILE *f);
bool fseek_section(char *section,int start,bool after,FILE *sf);

int  freadnm(char *buf,int bites,FILE *f) {
  int ch;
  int prevp= ftell(f);
  for(int k=0;k<bites;k++) {
    ch = fgetc(f);
    if(ch==EOF) {
      buf[k] = 0;
      break;
    }
    else {
      buf[k] = (char)ch;
    }
  }
  buf[k+1] = 0;
  fseek(f,prevp,SEEK_SET);
  //printf("freadnm = %s\r\n",buf);
  return k;
}

bool fseek_section(char *section,int start,bool after,FILE *sf) {
  char  bufc;
  char  *buf;
  char  *lsection;
  unsigned int seeklen=0;
//  unsigned int seekprev;

  seeklen = strlen(section);
  if(seeklen==0)
    return false;
  lsection = section+1;
  buf = new char[seeklen+1];
  memset((void *)buf, 0, seeklen+1);
  if(start != MF_RESUME) {
    fseek(sf,start,SEEK_SET);
  }

  do {
    bufc = (char) fgetc(sf);
    if(bufc == *section) {
      //fseek(sf,ftell(sf)-1,SEEK_SET);
      freadnm(buf,seeklen-1,sf);
      if((strcmp(lsection,buf))==0) {
        if(after) {
          fseek(sf,seeklen-1,SEEK_CUR);
        }
        else {
          fseek(sf,ftell(sf)-1,SEEK_SET);
        }
        return true;
      }
    }
  } while(!feof(sf));

  return false;
}

void create_s(char *fname) {
  FILE  *fin;
  FILE  *fout;
  unsigned short int samples=0;
  unsigned short int sample_num=0;
  SampleInfo  si;
  char  str[256];
  short int *buf=NULL;
  int len=0;


  fin = fopen(fname,"r");
  fseek_section("[SAMPLES_COUNT]",MF_RESUME,true,fin);
  fscanf(fin,"%d",&samples);
  printf("%d samples to be generated\n",samples);

  for(int k=0;k<samples; k++) {
    fseek_section("[SAMPLE]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&sample_num);
    printf("Found sample #%d\n",sample_num);

    fseek_section("[FREQUENCY]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.frequency);
    printf("  frequency = %f\n",si.frequency);

    fseek_section("[PITCH_ENV]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.pitch_env);
    printf("  pitch_env = %f\n",si.pitch_env);

    fseek_section("[PHY]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.phy);
    printf("  phy = %f\n",si.phy);

    fseek_section("[AMPLITUDE]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.amplitude);
    printf("  amplitude = %f\n",si.amplitude);

    fseek_section("[RATE]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.rate);
    printf("  sample rate = %d\n",si.rate);

    fseek_section("[GENERATOR]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.gen_type);
    printf("  generator :");
    switch(si.gen_type) {
      case G_TRI:  printf("tri()\n");break;
      case G_SQU:  printf("squ()\n");break;
      case G_SAW:  printf("saw()\n");break;
      case G_NOISE:printf("noise()\n");break;
      case G_SIN:  printf("sin()\n");break;
    }



    fseek_section("[ATTACK]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.attack);
    printf("  attack = %d\n",si.attack);

    fseek_section("[SUSTAIN]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.sustain);
    printf("  sustain = %d\n",si.sustain);

    fseek_section("[RELEASE]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.release);
    printf("  release = %d\n",si.release);

    fseek_section("[FILTER]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.filter);
    printf("  filter = %d\n",si.filter);

    fseek_section("[CUTOFF]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.cutoff);
    printf("  cutoff = %f\n",si.cutoff);

    fseek_section("[RESONANCE]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.resonance);
    printf("  resonance = %f\n",si.resonance);

    fseek_section("[CUT_ENV]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.cut_env);
    printf("  cut_env = %f\n",si.cut_env);

    fseek_section("[RES_ENV]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.res_env);
    printf("  res_env = %f\n",si.res_env);


    len = si.attack+si.sustain+si.release;
    printf("  total length = %d\n",len);

    if(buf!=NULL)
      delete []buf;
    buf = new short int [len];
    GenerateSample16((void*)buf,&si);
    sprintf(str,"smp%02d.raw",sample_num);
    fout = fopen(str,"wb");
    fwrite((const void*)buf,2,len,fout);
    fclose(fout);
    /*if(feof(fin)) {
      printf("\nend of file found...\n");
      fclose(fin);
      return 0;
    }*/
  }
  fclose(fin);
  if(buf!=NULL)
    delete []buf;
}

void compile_s(char *fname) {
  FILE  *fin;
  FILE  *fout;
  unsigned short int samples=0;
  int sample_num=0;
  SampleInfo  si;
  char  str[512];
  short int *buf=NULL;
  int len=0;

  strcpy(str,fname);
  for(int i=0;i<512;i++) {
    if(str[i] == 0)
      break;
    if(str[i] == '.') {
      str[i] = 0;
      break;
    }
  }

  strcat(str,".csm\0");


  fin = fopen(fname,"r");
  fout = fopen(str,"wb");
  fseek_section("[SAMPLES_COUNT]",MF_RESUME,true,fin);

  fscanf(fin,"%d",&samples);
  printf("%d sample presets to be compiled\n",samples);

  fwrite((const void *)&samples, sizeof(samples), 1, fout);

  for(int k=0;k<samples; k++) {
    fseek_section("[SAMPLE]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&sample_num);
    printf("Found sample #%d\n",sample_num);

    fseek_section("[FREQUENCY]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.frequency);
    printf("  frequency = %f\n",si.frequency);

    fseek_section("[PITCH_ENV]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.pitch_env);
    printf("  pitch_env = %f\n",si.pitch_env);

    fseek_section("[PHY]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.phy);
    printf("  phy = %f\n",si.phy);

    fseek_section("[AMPLITUDE]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.amplitude);
    printf("  amplitude = %f\n",si.amplitude);

    fseek_section("[RATE]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.rate);
    printf("  sample rate = %d\n",si.rate);

    fseek_section("[GENERATOR]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.gen_type);
    printf("  generator :");
    switch(si.gen_type) {
      case G_TRI:  printf("tri()\n");break;
      case G_SQU:  printf("squ()\n");break;
      case G_SAW:  printf("saw()\n");break;
      case G_NOISE:printf("noise()\n");break;
      case G_SIN:  printf("sin()\n");break;
    }

    fseek_section("[ATTACK]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.attack);
    printf("  attack = %d\n",si.attack);

    fseek_section("[SUSTAIN]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.sustain);
    printf("  sustain = %d\n",si.sustain);

    fseek_section("[RELEASE]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.release);
    printf("  release = %d\n",si.release);

    fseek_section("[FILTER]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si.filter);
    printf("  filter = %d\n",si.filter);

    fseek_section("[CUTOFF]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.cutoff);
    printf("  cutoff = %f\n",si.cutoff);

    fseek_section("[RESONANCE]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.resonance);
    printf("  resonance = %f\n",si.resonance);

    fseek_section("[CUT_ENV]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.cut_env);
    printf("  cut_env = %f\n",si.cut_env);

    fseek_section("[RES_ENV]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si.res_env);
    printf("  res_env = %f\n",si.res_env);

    fseek_section("[HIGH_FREQ]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si[k].high_freq);
    printf("  high_freq = %d\n",si[k].high_freq);

    fseek_section("[LOW_FREQ]",MF_RESUME,true,fin);
    fscanf(fin,"%d",&si[k].low_freq);
    printf("  low_freq = %d\n",si[k].low_freq);

    fseek_section("[HIGH_ENV]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si[k].high_env);
    printf("  high_env = %f\n",si[k].high_env);

    fseek_section("[LOW_ENV]",MF_RESUME,true,fin);
    fscanf(fin,"%f",&si[k].low_env);
    printf("  low_env = %f\n",si[k].low_env);
    fwrite((const void *)&si, sizeof(si), 1, fout);
  }
  fclose(fout);
  fclose(fin);
}

void build_s(char *fname) {
  FILE  *fin;
  FILE  *fout;
  unsigned short int samples=0;
  unsigned short int sample_num=0;
  SampleInfo  si;
  char  str[256];
  short int *buf=NULL;
  int len=0;


  fin = fopen(fname,"rb");
  fread(&samples,sizeof(samples),1,fin);
  printf("%d samples to be built\n",samples);

  for(int k=0;k<samples; k++) {
    fread(&si,sizeof(si),1,fin);

    printf("  frequency = %f\n",si.frequency);
    printf("  pitch_env = %f\n",si.pitch_env);
    printf("  phy = %f\n",si.phy);
    printf("  amplitude = %f\n",si.amplitude);
    printf("  sample rate = %d\n",si.rate);
    printf("  generator :");
    switch(si.gen_type) {
      case G_TRI:  printf("tri()\n");break;
      case G_SQU:  printf("squ()\n");break;
      case G_SAW:  printf("saw()\n");break;
      case G_NOISE:printf("noise()\n");break;
      case G_SIN:  printf("sin()\n");break;
    }
    printf("  attack = %d\n",si.attack);
    printf("  sustain = %d\n",si.sustain);
    printf("  release = %d\n",si.release);
    printf("  filter = %d\n",si.filter);
    printf("  cutoff = %f\n",si.cutoff);
    printf("  resonance = %f\n",si.resonance);
    printf("  cut_env = %f\n",si.cut_env);
    printf("  res_env = %f\n",si.res_env);

    len = si.attack+si.sustain+si.release;
    printf("  total length = %d\n\n",len);
    //while(!kbhit());
    //getch();

    if(buf!=NULL)
      delete []buf;
    buf = new short int [len];
    GenerateSample16((void*)buf,&si);
    sprintf(str,"smp%02d.raw",k);
    fout = fopen(str,"wb");
    fwrite((const void*)buf,2,len,fout);
    fclose(fout);
  }
  fclose(fin);
  if(buf!=NULL)
    delete []buf;
}

int main(int argc, char* argv[]) {
  printf("Sample generator by Elmm/[KCN]\n\n");
  if(argc<=2) {
    printf("Usage: samplegn gcl file.txt\n");
          printf(" g - generate\n c - compile\n l - build\n");
    return 0;
  }
  else {
    switch(*argv[1]) {
    case 'g': create_s(argv[2]); break;
    case 'c': compile_s(argv[2]); break;
    case 'l': build_s(argv[2]); break;
    }
  }
        return 0;
}
