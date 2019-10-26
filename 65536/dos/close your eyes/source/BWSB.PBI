'                         file$   file off    OverSampling  Buffer Size  BaseI/O   IRQ     DMA
DECLARE FUNCTION LoadMSE%(string,byval long, byval integer,byval integer,integer,integer,integer)
DECLARE SUB FreeMSE()
DECLARE FUNCTION StartOutput&(byval integer, byval integer)
DECLARE SUB StopOutput()
DECLARE SUB StopBanner()

DECLARE SUB StartMusic()
DECLARE SUB StopMusic()
DECLARE FUNCTION MusicStatus%()

DECLARE FUNCTION MusicBPM%(byval integer)
DECLARE FUNCTION MusicTempo%(byval integer)
DECLARE FUNCTION MusicOrder%(byval integer)
DECLARE FUNCTION MusicPattern%(byval integer)
DECLARE FUNCTION MusicRow%()
DECLARE FUNCTION MusicLoop%(byval integer)
DECLARE FUNCTION MusicVolume%(byval integer)

DECLARE SUB AmigaHertz(byval long)

DECLARE FUNCTION MixStatus%()
DECLARE SUB MixForground()
DECLARE SUB SetAutoMix(byval integer)

DECLARE SUB GetChannelTable(byval integer, byval intger, byval integer)
DECLARE SUB GetSampleTable(byval integer, byval intger, byval integer)

DECLARE SUB GetMainScope(integer, integer)
DECLARE FUNCTION ChannelPan%(byval integer, byval integer)
DECLARE FUNCTION ChannelVU%(byval integer, byval integer)
DECLARE FUNCTION ChannelVol%(byval integer, byval integer)
DECLARE FUNCTION ChannelPos%(byval integer, byval integer)

DECLARE SUB PlaySample(byval integer, byval integer, byval long, byval integer, byval integer)

'                    handle        file off   flags   ModHead Seg  ModHead Off
DECLARE SUB LoadGDM(byval integer,byval long,integer,byval integer,byval integer)
DECLARE SUB UnloadModule()

DECLARE FUNCTION DeviceName$()

DECLARE FUNCTION EmsExist%()