#ifndef SAVEXI__H
#define SAVEXI__H

// der Filename des Template XI instrumentes.
// Hier kann der User seine Default Einstellungen einspeichern
#define dummyXI "dummy.xi"

// Diese Routine schreibt ein neues XI File, ausgehend vom Template XI.
// den *filename ohne Endung bitte
int savexi(const char *filename,
					 const char *insname,
           const signed short *buf,
           const int len=65536);

////////////////////////////////////////////////////////////////////////////

#pragma pack(1)
typedef struct
{
  char id[0x15];
  char name[0x16];
  unsigned char nil;
  char trackername[0x14];
  unsigned short version;
} XIheader;


typedef struct
{
  unsigned char sample2note[0x60];
  unsigned short volumePoint[0x30/sizeof(unsigned short)];
  unsigned short panningPoint[0x30/sizeof(unsigned short)];
  unsigned char volumePointNum;
  unsigned char panningPointNum;
  unsigned char volumeSustainPoint;
  unsigned char volumeLoopStart;
  unsigned char volumeLoopEnd;
  unsigned char panningSustainPoint;
  unsigned char panningLoopStart;
  unsigned char panningLoopEnd;
  unsigned char volumeType;
  unsigned char panningType;
  unsigned char vibratoType;
  unsigned char vibratoSweep;
  unsigned char vibratoDepth;
  unsigned char vibratoRate;
  unsigned short volumeFadeout;
  unsigned char nil[0x16];
  unsigned short sampleNum;

} XIinstrument;


typedef struct
{
  unsigned long length;
  unsigned long loopStart;
  unsigned long loopLength;
  unsigned char volume;
  signed char finetune;
  unsigned char type;
  unsigned char panning;
  signed char note;
  unsigned char nameLen;
  char name[0x16];
} XIsample;

typedef struct
{
  XIheader header;
  XIinstrument instrument;
  XIsample sample;
} XI;

typedef struct
{
  char name[4];
  unsigned long length;
  unsigned short type;
  unsigned short channels;
  unsigned long rate;
  unsigned long bytesPerSecond;
  unsigned short bytesPerSample;
  unsigned short bitsPerSample;
} WAVfmt;

#define WAVfmtMono 1
#define WAVfmtStereo 1

typedef struct
{
  char name[4];
  unsigned long length;
} WAVdata;

typedef struct
{
  char name[4];
  unsigned long length;
  char type[4];
  WAVfmt fmt;
  WAVdata data;
} WAV;

#define WAVheaderLen (sizeof(WAV)-8)

#endif