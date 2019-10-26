// ===========================================================================
//  fsound.c
// ---------------------------------------------------------------------------
//  MiniFMOD public source code release.
//  This source is provided as-is.  Firelight Multimedia will not support
//  or answer questions about the source provided.
//  MiniFMOD Sourcecode is copyright (c) 2000, Firelight Multimedia.
//  MiniFMOD Sourcecode is in no way representative of FMOD 3 source.
//  Firelight Multimedia is a registered business name.
//  This source must not be redistributed without this notice.
// ---------------------------------------------------------------------------
//  Some parts of this source is copyright (c) 2002, Luks <luks@host.sk>
// ===========================================================================

#include "minifmod.h"
#include "mixer.h"
#include "mixer_clipcopy.h"
#include "mixer_fpu_ramp.h"
#include "music.h"
#include "sound.h"
#include "system_file.h"
#include "system_memory.h"

#ifdef __LINUX__
#include <unistd.h>
#include <fcntl.h>
#include <linux/soundcard.h>
#include <sys/ioctl.h>
#include <pthread.h>
#include <time.h>
#include <string.h>
#endif

#ifdef __WIN32__
#include <windows.h>
#include <mmsystem.h>
#endif

//= GLOBALS ==================================================================

FSOUND_CHANNEL FSOUND_Channel[256];     // channel pool
int FSOUND_MixRate;                     // mixing rate in hz.
int FSOUND_BufferSizeMs = 1000;
#ifdef __LINUX__
int FSOUND_FileDSP = -1;
char FSOUND_SoundBuffer[(1<<FSOUND_FRAGSIZE)*FSOUND_NUMFRAGS];
#endif
#ifdef __WIN32__
HWAVEOUT FSOUND_WaveOutHandle;
FSOUND_SoundBlock FSOUND_MixBlock;
#endif

// mixing info
signed char * FSOUND_MixBufferMem;      // mix buffer memory block
signed char * FSOUND_MixBuffer;         // mix output buffer (16bit or 32bit)
float FSOUND_OOMixRate;                 // mixing rate in hz.
int FSOUND_BufferSize;                  // size of 1 'latency' ms buffer in bytes
int FSOUND_BlockSize;                   // LATENCY ms worth of samples

// thread control variables
volatile signed char FSOUND_Software_Exit = FALSE;      // mixing thread termination flag
volatile signed char FSOUND_Software_UpdateMutex = FALSE;
volatile signed char FSOUND_Software_ThreadFinished  = TRUE;
#ifdef __LINUX__
volatile int FSOUND_Software_hThread = 0;
#endif
#ifdef __WIN32__
volatile HANDLE FSOUND_Software_hThread = NULL;
#endif
volatile int FSOUND_Software_FillBlock = 0;
volatile int FSOUND_Software_RealBlock = 0;

int FSOUND_Init(int mixrate, int vcmmode)
{
  int count;

  if (!FSOUND_File_OpenCallback || !FSOUND_File_CloseCallback || !FSOUND_File_ReadCallback || !FSOUND_File_SeekCallback || !FSOUND_File_TellCallback)
    return FALSE;

  // =========================================================================
  //  CLOSE IT DOWN FIRST IF IT IS ALREADY OPEN
  // =========================================================================
  FSOUND_Close();

  // =========================================================================
  //  SET SOME DEFAULTS
  // =========================================================================
  FSOUND_MixRate = mixrate;
  {
#ifdef __LINUX__
    int temp;
    // =======================================================================
    // INITIALIZE OSS
    // =======================================================================
    if ((FSOUND_FileDSP = open("/dev/dsp", O_WRONLY)) == -1)
      return(FALSE);
    temp = 16;
    ioctl(FSOUND_FileDSP, SNDCTL_DSP_SAMPLESIZE, &temp);
    if (temp != 16)
    {
      FSOUND_Close();
      return(FALSE);
    }
    temp = 1;
    ioctl(FSOUND_FileDSP, SNDCTL_DSP_STEREO, &temp);
    if (temp != 1)
    {
      FSOUND_Close();
      return(FALSE);
    }
    temp = mixrate;
    ioctl(FSOUND_FileDSP, SNDCTL_DSP_SPEED, &temp);
    if (temp != mixrate)
    {
      FSOUND_Close();
      return(FALSE);
    }
    temp = (FSOUND_NUMFRAGS<<16)+FSOUND_FRAGSIZE;
    ioctl(FSOUND_FileDSP, SNDCTL_DSP_SETFRAGMENT, &temp);
    if ((temp & 0xFFFF)  != FSOUND_FRAGSIZE)
    {
      FSOUND_Close();
      return(FALSE);
    }

#endif
#ifdef __WIN32__
    WAVEFORMATEX pcmwf;
    UINT hr;
    // =======================================================================
    // INITIALIZE WAVEOUT
    // =======================================================================
    pcmwf.wFormatTag        = WAVE_FORMAT_PCM;
    pcmwf.nChannels         = 2;
    pcmwf.wBitsPerSample    = 16;
    pcmwf.nBlockAlign       = pcmwf.nChannels * pcmwf.wBitsPerSample / 8;
    pcmwf.nSamplesPerSec    = mixrate;
    pcmwf.nAvgBytesPerSec   = pcmwf.nSamplesPerSec * pcmwf.nBlockAlign;
    pcmwf.cbSize            = 0;
    hr = waveOutOpen(&FSOUND_WaveOutHandle, WAVE_MAPPER, &pcmwf, 0, 0, 0);
    if (hr)
      return(FALSE);
#endif
  }

  // =========================================================================
  // INITIALIZE SOFTWARE MIXER
  // =========================================================================
  FSOUND_OOMixRate = 1.0f / (float)mixrate;
#ifdef __LINUX__
  FSOUND_BlockSize = 1 << FSOUND_FRAGSIZE;    // Number of *samples*
  FSOUND_BufferSize = FSOUND_BlockSize;        // in linux oss do double-buffering
#endif
#ifdef __WIN32__
  FSOUND_BlockSize = ((FSOUND_MixRate * FSOUND_LATENCY / 1000) + 3) & 0xFFFFFFFC; // Number of *samples*
  FSOUND_BufferSize = FSOUND_BlockSize * (FSOUND_BufferSizeMs / FSOUND_LATENCY);  // make it perfectly divisible by granularity
  FSOUND_BufferSize <<= 1;        // double buffer
#endif

  mix_volumerampsteps = FSOUND_MixRate * FSOUND_VOLUMERAMP_STEPS / 44100;
  mix_1overvolumerampsteps = 1.0f / mix_volumerampsteps;

  // =========================================================================
  // ALLOC GLOBAL CHANNEL POOL
  // =========================================================================
  memset(FSOUND_Channel, 0, sizeof(FSOUND_CHANNEL) * 256);

  // =========================================================================
  // SET UP CHANNELS
  // =========================================================================
  for (count = 0; count < 256; count++)
  {
    FSOUND_Channel[count].index = count;
    FSOUND_Channel[count].speedhi = 1;
  }

  return(TRUE);
}

void FSOUND_Close()
{
  // ========================================================================================================
  // SHUT DOWN OUTPUT DRIVER
  // ========================================================================================================
#ifdef __LINUX__
  if (FSOUND_FileDSP != -1)
    close(FSOUND_FileDSP);
#endif
#ifdef __WIN32__
  waveOutReset(FSOUND_WaveOutHandle);
  waveOutClose(FSOUND_WaveOutHandle);
#endif
}

void FSOUND_Software_Fill()
{
#ifdef __LINUX__

  // =========================================================================
  // MIXBUFFER CLEAR
  // =========================================================================
  memset(FSOUND_MixBuffer, 0, FSOUND_BlockSize << 3);

  // =========================================================================
  // UPDATE MUSIC
  // =========================================================================
  {
    int MixedSoFar = 0;
    int MixedLeft = FMUSIC_PlayingSong->mixer_samplesleft;
    int SamplesToMix;

    // keep resetting the mix pointer to the beginning of this portion of the ring buffer
    signed char * MixPtr = FSOUND_MixBuffer;

    while (MixedSoFar < FSOUND_BlockSize)
    {
      if (!MixedLeft)
      {
        FMUSIC_PlayingSong->Update(FMUSIC_PlayingSong); // update new mod tick
        SamplesToMix = FMUSIC_PlayingSong->mixer_samplespertick;
        MixedLeft = SamplesToMix;
      }
      else
        SamplesToMix = MixedLeft;

      if (MixedSoFar + SamplesToMix > FSOUND_BlockSize)
        SamplesToMix = FSOUND_BlockSize - MixedSoFar;

      FSOUND_Mixer_FPU_Ramp(MixPtr, SamplesToMix, FALSE);

      MixedSoFar += SamplesToMix;
      MixPtr += (SamplesToMix << 3);
      MixedLeft -= SamplesToMix;

      FMUSIC_PlayingSong->time_ms += (int)(((float)SamplesToMix * FSOUND_OOMixRate) * 1000);
    }

    FMUSIC_TimeInfo.ms = FMUSIC_PlayingSong->time_ms;
    FMUSIC_TimeInfo.row = FMUSIC_PlayingSong->row;
    FMUSIC_TimeInfo.order = FMUSIC_PlayingSong->order;

    FMUSIC_PlayingSong->mixer_samplesleft = MixedLeft;
  }

  // =========================================================================
  // CLIP AND COPY BLOCK TO OUTPUT BUFFER
  // =========================================================================
  FSOUND_MixerClipCopy_Float32(FSOUND_SoundBuffer, FSOUND_MixBuffer, FSOUND_BlockSize);

#endif

#ifdef __WIN32__
  void * mixbuffer;
  int mixpos = FSOUND_Software_FillBlock * FSOUND_BlockSize;
  int totalblocks = FSOUND_BufferSize / FSOUND_BlockSize;

  mixbuffer = (char *)FSOUND_MixBuffer + (mixpos << 3);

  // =========================================================================
  // MIXBUFFER CLEAR
  // =========================================================================
  memset(mixbuffer, 0, FSOUND_BlockSize << 3);

  // =========================================================================
  // UPDATE MUSIC
  // =========================================================================
  {
    int MixedSoFar = 0;
    int MixedLeft = FMUSIC_PlayingSong->mixer_samplesleft;
    int SamplesToMix;
    signed char *MixPtr;

    // keep resetting the mix pointer to the beginning of this portion of the ring buffer
    MixPtr = mixbuffer;

    while (MixedSoFar < FSOUND_BlockSize)
    {
      if (!MixedLeft)
      {
        FMUSIC_PlayingSong->Update(FMUSIC_PlayingSong); // update new mod tick
        SamplesToMix = FMUSIC_PlayingSong->mixer_samplespertick;
        MixedLeft = SamplesToMix;
      }
      else
        SamplesToMix = MixedLeft;

      if (MixedSoFar + SamplesToMix > FSOUND_BlockSize)
        SamplesToMix = FSOUND_BlockSize - MixedSoFar;

      FSOUND_Mixer_FPU_Ramp(MixPtr, SamplesToMix, FALSE);

      MixedSoFar += SamplesToMix;
      MixPtr += (SamplesToMix << 3);
      MixedLeft -= SamplesToMix;

      FMUSIC_PlayingSong->time_ms += (int)(((float)SamplesToMix * FSOUND_OOMixRate) * 1000);
    }

    FMUSIC_TimeInfo[FSOUND_Software_FillBlock].ms = FMUSIC_PlayingSong->time_ms;
    FMUSIC_TimeInfo[FSOUND_Software_FillBlock].row = FMUSIC_PlayingSong->row;
    FMUSIC_TimeInfo[FSOUND_Software_FillBlock].order = FMUSIC_PlayingSong->order;

    FMUSIC_PlayingSong->mixer_samplesleft = MixedLeft;
  }

  // =========================================================================
  // CLIP AND COPY BLOCK TO OUTPUT BUFFER
  // =========================================================================
  {
    void *ptr1;
    unsigned int len1;
    ptr1 = FSOUND_MixBlock.data + (mixpos << 2);
    len1 = FSOUND_BlockSize << 2;
    FSOUND_MixerClipCopy_Float32(ptr1, mixbuffer, len1>>2);
  }

  FSOUND_Software_FillBlock++;
  if (FSOUND_Software_FillBlock >= totalblocks)
    FSOUND_Software_FillBlock = 0;

#endif
}

#ifdef __LINUX__
void * FSOUND_Software_OutputThread(void * arg)
{
  FSOUND_Software_ThreadFinished = FALSE;
  while (!FSOUND_Software_Exit)
  {
    usleep(10000);

    FSOUND_Software_UpdateMutex = TRUE;

    FSOUND_Software_Fill();

    write(FSOUND_FileDSP, FSOUND_SoundBuffer, FSOUND_BlockSize << 2);

    FSOUND_Software_UpdateMutex = FALSE;
  }
  FSOUND_Software_ThreadFinished = TRUE;
  pthread_exit(NULL);
}
#endif

#ifdef __WIN32__
DWORD FSOUND_Software_DoubleBufferThread(LPDWORD lpdwParam)
{
  int totalblocks;

  FSOUND_Software_ThreadFinished = FALSE;

  totalblocks = FSOUND_BufferSize / FSOUND_BlockSize;

  while (!FSOUND_Software_Exit)
  {
    int    cursorpos,cursorblock,prevblock;
    MMTIME mmt;

    mmt.wType = TIME_BYTES;
    waveOutGetPosition(FSOUND_WaveOutHandle, &mmt, sizeof(MMTIME));
    mmt.u.cb >>= 2;
    cursorpos = mmt.u.cb;

    cursorpos %= FSOUND_BufferSize;
    cursorblock = cursorpos / FSOUND_BlockSize;

    prevblock = cursorblock - 1;
    if (prevblock < 0)
      prevblock = totalblocks - 1;

    while (FSOUND_Software_FillBlock != cursorblock)
    {
      FSOUND_Software_UpdateMutex = TRUE;

      FSOUND_Software_Fill();

      FSOUND_Software_RealBlock++;
      if (FSOUND_Software_RealBlock >= totalblocks)
        FSOUND_Software_RealBlock = 0;

      FSOUND_Software_UpdateMutex = FALSE;
    }
    Sleep(5);
  };

  FSOUND_Software_ThreadFinished = TRUE;

  return 0;
}
#endif

