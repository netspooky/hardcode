{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_VAR .PAS - System Variables and Types                              ³}
{³                  Work started     : 2000.10.19.                          ³}
{³                  Last modification: 2001.06.18.                          ³}
{³             OS - Platform Independent                                    ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$MODE FPC}
Unit ISS_Var;

Interface

Const { þ Main system constants þ }
      ISS_Version    : DWord = $021;    { þ Version Number þ }
      ISS_VersionStr : PChar = '0.2.1'; { þ Version Number String þ }

      {$IFDEF GO32V2}
       ISS_PlatformID  = $0001;
       ISS_PlatformStr = 'DOS-GO32V2';
      {$ENDIF}
      {$IFDEF OS2}
       ISS_PlatformID  = $0002;
       ISS_PlatformStr = 'OS/2-EMX';
      {$ENDIF}
      {$IFDEF LINUX}
       ISS_PlatformID  = $0004;
       ISS_PlatformStr = 'Linux/i386';
      {$ENDIF}
      {$IFDEF WIN32}
       ISS_PlatformID  = $0008;
       ISS_PlatformStr = 'Win32';
      {$ENDIF}

      ISS_MaxDevices = 4;  { þ Maximum Number of Devices þ }
      ISS_MaxLoaders = 1;  { þ Maximum Number of Loaders þ }

      ISS_MaxSSChannels = 32; { þ Sound System Channel Number þ }
      ISS_MaxPlChannels = 32; { þ Player Channel Number þ }

      { þ Tracker IDs (used for playing incompatible effects correctly) þ }
      ISS_TrackerID_PRO = 1; { þ Protracker þ }
      ISS_TrackerID_ST3 = 2; { þ ScreamTracker 3.x þ }
      ISS_TrackerID_FT2 = 3; { þ Fasttracker 2 þ }

      { þ Device Type Flags þ }
      ISS_Dev8Bit      =   1; { þ Device supports 8bit output/samples þ }
      ISS_Dev16Bit     =   2; { þ Device supports 16bit output/samples þ }
      ISS_DevMono      =   4; { þ Device supports mono output þ }
      ISS_DevStereo    =   8; { þ Device supports stereo output þ }
      ISS_DevSigned    =  16; { þ Device supports signed samples þ }
      ISS_DevUnsigned  =  32; { þ Device supports unsigned samples þ }
      ISS_DevMixed     =  64; { þ Device supports mixing þ }
      ISS_DevWaveTable = 128; { þ Device supports wavetable mode þ }
      ISS_DevDRAM      = 256; { þ Device has on-board DRAM þ }

      { þ Sample Type Consts þ } { þ GUS Values þ }
      ISS_Smp16BitData    = %00000100; { þ 16bit SampleData þ }
      ISS_SmpNoLoop       = %00000000; { þ No Looping þ }
      ISS_SmpForwardLoop  = %00001000; { þ Forward Looping þ }
      ISS_SmpPingPongLoop = %00011000; { þ Bidirectional Looping þ }

      { þ Virtual Channel Control Flags þ }
      ISS_CCActive       =   1; { þ Channel Activity Flag             (0) þ }
      ISS_CCStop         =   2; { þ Stop Channel                      (1) þ }
      ISS_CCSample       =   4; { þ Change Channel Sample             (2) þ }
      ISS_CCVolume       =   8; { þ Change Channel Volume             (3) þ }
      ISS_CCPeriod       =  16; { þ Change Channel Period             (4) þ }
      ISS_CCPanning      =  32; { þ Change Channel Panning            (5) þ }
      ISS_CCVolFadeOut   =  64; { þ Volume Fadeout in progress        (6) þ }

      { þ Frequency Mode Flags þ }
      ISS_AmigaFreq      =  0; { þ Amiga Frequency Mode (MOD,XM) þ }
      ISS_LinearFreq     =  1; { þ Linear Frequency Mode (XM) þ }

      { þ Envelope Type Flags þ }
      ISS_EnvEnabled     = 1; { þ Envelope Enabled þ }
      ISS_EnvSustain     = 2; { þ Envelope Sustain þ }
      ISS_EnvLoop        = 4; { þ Envelope Looped þ }

      { þ Internal Module ID þ }
      ISS_ModuleID = 'INQM';

      { þ Internal Module Status Flags þ }
      ISS_StLoaded       = 1; { þ Module loaded to device þ }
      ISS_StPlaying      = 2; { þ Module currently playing þ }

      { þ Amiga Period Table (The one from the XM documentation.) þ }
      ISS_AmigaPeriodTable : Array[0..12*8-1] Of Word = (
          907,900,894,887,881,875,868,862,856,850,844,838,832,826,820,814,
          808,802,796,791,785,779,774,768,762,757,752,746,741,736,730,725,
          720,715,709,704,699,694,689,684,678,675,670,665,660,655,651,646,
          640,636,632,628,623,619,614,610,604,601,597,592,588,584,580,575,
          570,567,563,559,555,551,547,543,538,535,532,528,524,520,516,513,
          508,505,502,498,494,491,487,484,480,477,474,470,467,463,460,457);

      { þ Sinus Table used by vibrato and tremolo þ }
      ISS_SineTable : Array[0..127] Of Integer = (
             0,  6, 12, 18, 24, 31, 37, 43, 49, 55, 61, 68, 74, 79, 85, 91,
            97,103,109,114,120,125,131,136,141,146,151,156,161,166,171,175,
           180,184,188,193,197,201,204,208,212,215,218,221,224,227,230,233,
           235,237,240,242,244,245,247,248,250,251,252,253,253,254,254,254,
           255,254,245,254,253,253,252,251,250,248,247,245,244,242,240,237,
           235,233,230,227,224,221,218,215,212,208,204,201,197,193,188,184,
           180,175,171,166,161,156,151,146,141,136,131,125,120,114,109,103,
            97, 91, 85, 79 ,74, 68, 61, 55, 49, 43, 37, 31, 24, 18, 12,  6);


Type  { þ >>> D A T A  T Y P E S <<< þ }

      { þ Internal Pattern Row Format (Same as used by FT2) þ }
      ISS_TPatternRow = Record
        RNote   : Byte; { þ Note (0-71) 0 = C-0 þ }
        RInstr  : Byte; { þ Instrument Number (0-128) þ }
        RVolCol : Byte; { þ Volume Column Byte þ }
        RFXType : Byte; { þ Effect Type þ }
        RFXParm : Byte; { þ Effect Parameter þ }
       End;
      ISS_PPatternRow = ^ISS_TPatternRow;

      { þ Internal Pattern Format þ }
      ISS_TPattern = Record
        PatRowsNum : Word;    { þ Number of Rows in the Pattern þ }
        PatSize    : DWord;   { þ Pattern Data Size þ }
        PatRows    : Pointer; { þ Pointer to XM-Packed Pattern Data þ }
       End;
      ISS_PPattern = ^ISS_TPattern;

      { þ Internal Sample Format þ }
      ISS_TSample = Record
        SName      : Array[0..21] Of Char; { þ Sample Name þ }
        SLength    : DWord; { þ Sample Length þ }
        SLoopStart : DWord; { þ Sample Loop Start þ }
        SLoopEnd   : DWord; { þ Sample Loop End þ }
        SVolume    : Byte;  { þ Sample Volume þ }
        SFineTune  : ShortInt; { þ Sample FineTune (signed byte -16..+15) þ }
        SType      : Byte;  { þ Sample Type þ }
        SPanning   : Byte;  { þ Sample Panning þ }
        SRelNote   : ShortInt;  { þ Sample Relative Note (signed byte) þ }
        SData      : Pointer; { þ Pointer to the sample data þ }
        SDRAMOffs  : DWord; { þ Sample Offset in Wavetable DRAM þ }
       End;
      ISS_PSample = ^ISS_TSample;

      { þ An Envelope Point þ }
      ISS_TEnvPoint = Record
        EPPosition  : Word; { þ Position of This Envelope Point þ }
        EPValue     : Word; { þ Envelope Value at this Point þ }
       End;

      { þ Internal Envelope Format þ }
      ISS_TEnvelope = Record
        EnvType      : Byte; { þ Envelope Type þ }
        EnvPointsNum : Byte; { þ Number Of Envelope Points þ }
        EnvSustain   : Byte; { þ Envelope Sustain Point þ }
        EnvLoopStart : Byte; { þ Envelope Loop Start Point þ }
        EnvLoopEnd   : Byte; { þ Envelope Loop End Point þ }
        EnvPoints    : Array[0..11] Of ISS_TEnvPoint; { þ Envelope Points þ }
       End;

      { þ Internal Instrument Format þ }
      ISS_TInstrument = Record
        IName : Array[0..31] Of Char; { þ Instrument Name þ }

        INoteTable : Array[1..96] Of Byte; { þ Sample Number for all notes þ }

        IVolumeEnv  : ISS_TEnvelope; { þ Volume Envelope Data þ }
        IPanningEnv : ISS_TEnvelope; { þ Panning Envelope Data þ }

        IVibType    : Byte; { þ Vibrato Type þ }
        IVibSweep   : Byte; { þ Vibrato Sweep þ }
        IVibDepth   : Byte; { þ Vibrato Depth þ }
        IVibRate    : Byte; { þ Vibrato Rate þ }

        IVolFadeOut : Word; { þ Volume FadeOut þ }

        ISampleNum : Word; { þ Number Of Samples in the Instrument þ }
        ISamples   : Array[0..15] Of ISS_PSample; { þ Pointer to Sample þ }
       End;
      ISS_PInstrument = ^ISS_TInstrument;

      { þ Internal Module Format Header þ }
      ISS_TModule = Record
        MID      : Array[0..3] Of Char; { þ Module ID. See the const above þ }
        MTitle   : String[32]; { þ Title of the Module þ }
        MStatus  : Word; { þ Status bits of the module þ }

        MFlags   : Word; { þ Module Flags þ }
        MTracker : Word; { þ Original Tracker (File Format) þ }

        MChannels   : Word; { þ Number of Channels in the Module þ }
        MPatternNum : Word; { þ Number of Patterns in the Module þ }
        MSampleNum  : Word; { þ Number of Samples in the Module þ }
        MInstrNum   : Word; { þ Number of Instruments in the Module þ }

        MSongLength : Word; { þ Song Length (Orders Num) þ }
        MRestart    : Word; { þ Song Restart Position (Order Num) þ }
        MOrders     : Array[0..255] Of Byte; { þ Pattern Order Table þ }
        MPatterns   : Array[0..255] Of ISS_PPattern; { þ Ptrs to patterns þ }

        MTempo   : Byte; { þ Default Speed þ }
        MBPM     : Byte; { þ Default Tempo (BPM) þ }

        { þ Pointers to instruments þ }
        MInstruments : Array[1..128] Of ISS_PInstrument;

       End;
      ISS_PModule = ^ISS_TModule;


      { þ >>> V I R T U A L  S O U N D  D E V I C E <<< þ }

      { þ A Virtual Device Channel þ }
      ISS_TVirtualChannel = Record
        VChControl : DWord;  { þ Device Controller Bits (See flags above) þ }

        VChFreq    : DWord; { þ Frequency for this device channel þ }
        VChPeriod  : DWord; { þ Note Period þ }

        VChSmpAddr : ISS_PSample; { þ Sample Structure Address þ }
        VChInsAddr : ISS_PInstrument; { þ Instrument Structure Address þ }
        VChSmpOffs : DWord; { þ Sample Start Offset (FX:SetSampOffs) þ }

        VChVolume      : Byte;  { þ Virtual Channel Volume (0-64) þ }
        VChFinalVolume : Byte;  { þ Final Volume (after instr+etc) (0-64) þ }
        VChMute        : Boolean; { þ Force Volume 0 on the channel þ }

        VChPanning      : Byte; { þ Virtual Channel Panning þ }
        VChFinalPanning : Byte; { þ Final Panning (after instr+etc) þ }
        VChForceMono    : Boolean; { þ Disable Panning þ }

        VChFadeOutVolume : Word; { þ Envelope : Volume Fadeout þ }
        VChEnvVolume     : Byte; { þ Envelope : Volume (0-64) þ }
        VChEnvVolPoint   : Byte; { þ Envelope : Current Vol Env Point þ }
        VChEnvVolPos     : Word; { þ Envelope : Current Vol Env Position þ }

        VChEnvPanning    : Byte; { þ Envelope : Panning (0-32) þ }
        VChEnvPanPoint   : Byte; { þ Envelope : Current Pan Env Point þ }
        VChEnvPanPos     : Word; { þ Envelope : Current Pan Env Position þ }

        VChAVibPos       : Byte;  { þ Autovibrato : Position þ }
        VChAVibSwpPos    : Byte; { þ Autovibrato : Sweep Position þ }
        VChAVibPitch     : Integer; { þ Autovibrato : Final pitch þ }

        { þ Debug Variables. Will be removed soon. þ }
        VChDebug1  : DWord;
        VChDebug2  : DWord;
        VChDebug3  : DWord;

       End;

      { þ Virtual Channels For Devices þ }
      ISS_TVirtualChannels = Array[0..ISS_MaxSSChannels-1]
                             Of ISS_TVirtualChannel;
      ISS_PVirtualChannels = ^ISS_TVirtualChannels;

      { þ >>> S Y S T E M  S T R U C T U R E S <<< þ }

      { þ Low-Level Loader Routines þ }
      ISS_TModuleLoader = Record
        { þ Variables þ }
        ModuleMem  : Pointer; { þ Pointer to the current 'raw' module þ }
        ModulePtr  : ISS_PModule; { þ Pointer to the loaded module þ }
        ErrorCode  : DWord;  { þ The last error code þ }
        { þ Procedures þ }
        DebugInit  : Procedure; { þ Inits the loader debug routinesþ }
        DebugDone  : Procedure; { þ Shuts down the loader debug routines þ }
        { þ Returns true if the module is possible to load with the loader þ }
        CheckModule     : Function : Boolean;
        LoadHeader      : Function : Boolean; { þ Loads the header þ }
        LoadPatterns    : Function : Boolean; { þ Loads the patterns þ }
        LoadInstruments : Function : Boolean; { þ Loads the instruments þ }
       End;
      ISS_PModuleLoader = ^ISS_TModuleLoader;

      { þ Low-Level Device Routines þ }
      ISS_TSoundDriver = Record { þ Pointers for the player þ }
        Detect     : Function : Boolean; { þ True if device is available þ }
        Init       : Function : Boolean; { þ True if device init success þ }
        Done       : Function : Boolean; { þ True if device close success þ }
        LoadSample : Function(SStruc : ISS_PSample) : Boolean;
        FreeSample : Function(SStruc : ISS_PSample) : Boolean;
        SetVolume  : Function(Volume : DWord) : Boolean;
        StartOut   : Function(PeriodicCall  : Pointer) : Boolean;
        StopOut    : Function(PeriodicCall : Pointer) : Boolean;
        UpdateOut  : Procedure; { þ Updates the sound output þ }
       End;
      ISS_PSoundDriver = ^ISS_TSoundDriver;

      { þ Device Parameter Record þ }
      ISS_TSoundDevice = Record { þ Contains standard device-handling þ }
        DevDriver   : ISS_PSoundDriver; { þ Device handler procedures þ }
        DevAvail    : Boolean; { þ True if device is available þ }
        DevName     : String; { þ Name of the device þ }
        DevHWVer    : String; { þ Hardware version string (eg. SB DSP ver) þ }
        DevSWVer    : String; { þ Software version string (eg. OS/2 driver version) þ }
        DevType     : Word;   { þ Type of the device (see device flags) þ }
        DevBaseport : Word;   { þ Baseport þ }
        DevIRQ      : Byte;   { þ IRQ number þ }
        DevDMA1     : Byte;   { þ DMA channel 1 þ }
        DevDMA2     : Byte;   { þ DMA channel 2 þ }
        DevDRAMSize : DWord;  { þ Size of On-board memory in bytes þ }
        DevFreq     : Word;   { þ Maximum available playing frequency þ }
        DevMaxChan  : Word;   { þ Maximum number of channels available þ }
        DevMixRate  : Word;   { þ The mixrate the device currently using þ }
        DevMode     : Word;   { þ Mode the device using (devtype flags!) þ }
       End;
      ISS_PSoundDevice = ^ISS_TSoundDevice;

Var ISS_ErrorCode : DWord;  { þ Contains Latest Error Number þ }

    { þ Difference between the timer ticks, can be used for player sync þ }
    ISS_TimerDiff : DWord;

    ISS_TimerFreq : DWord;

    { þ Virtual Sound Device þ }
    ISS_VirtualChannels : ISS_PVirtualChannels;

    { þ The module currently playing þ }
    ISS_CurrentModule : ISS_PModule;

    { þ Active channel numbers þ }
    ISS_ActiveSSChannels : Word;
    ISS_ActivePlChannels : Word;

    { þ Global Volumes þ }
    ISS_GlobalSSVolume : Byte; { þ System Volume þ }
    ISS_GlobalPlVolume : Byte; { þ Player Volume þ }

Implementation

Begin
 { þ Setting variable defaults þ }
 ISS_ActiveSSChannels:=0;
 ISS_ActivePlChannels:=0;
End.
{ þ ISS_VAR.PAS - (C) 1999-2001 Charlie/Inquisition þ }
