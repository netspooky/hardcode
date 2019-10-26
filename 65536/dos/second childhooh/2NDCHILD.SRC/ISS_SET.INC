{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_SET .INC - System Directives Setup File                            ³}
{³                  Work started     : 1999.05.26.                          ³}
{³                  Last modification: 2001.06.29.                          ³}
{³             OS - Platform Independent (GO32V2,EMX tested)                ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

{ þ >>> L O A D E R  S E T T I N G S <<< þ }

{ DEFINE _ISS_LOAD_DEBUGMODE_}
{$DEFINE _ISS_LOAD_NOFILEMODE_}
{ DEFINE _ISS_LOAD_IDSMODE_}
{ DEFINE _ISS_LOAD_CREATELOGFILE_}

{$DEFINE _ISS_XM_INCLUDE_}
{ DEFINE _ISS_MOD_INCLUDE_}
{ DEFINE _ISS_S3M_INCLUDE_}


{ þ >>> D E V I C E  S E T T I N G S <<< þ }

{$IFDEF GO32V2}
 {$DEFINE _ISS_GUS_INCLUDE_}
 { DEFINE _ISS_GUS_DEBUGMODE_}

 {$DEFINE _ISS_SB_INCLUDE_}
 { DEFINE _ISS_SB_FORCEDSPVERSION_} { þ Dirty hack, will be removed! þ }
 { DEFINE _ISS_SB_DEBUGMODE_}

 {$DEFINE _ISS_NSND_INCLUDE_}
 { DEFINE _ISS_NSND_DEBUGMODE_}
 { DEFINE _ISS_NSND_SLOWMODE_}
{$ENDIF}

{$IFDEF OS2}
 {$DEFINE _ISS_GUSNATIVE_INCLUDE_}
 {$DEFINE _ISS_GUSNATIVE_DEBUGMODE_}

 {$DEFINE _ISS_DART_INCLUDE_}
 {$DEFINE _ISS_DART_DEBUGMODE_}
{$ENDIF}

{$IFDEF WIN32}
 {$FATAL WIN32 SUPPORT NOT IMPLEMENTED!}
 { DEFINE _ISS_DSOUND_INCLUDE_}
 {$DEFINE _ISS_DSOUND_DEBUGMODE_}
{$ENDIF}

{$IFDEF LINUX}
 {$FATAL LINUX SUPPORT NOT IMPLEMENTED!}
 { DEFINE _ISS_OSS_INCLUDE_}
 {$DEFINE _ISS_OSS_DEBUGMODE_}
{$ENDIF}


{ þ >>> S O U N D S Y S T E M  S E T T I N G S <<< þ }

{ DEFINE _ISS_MAIN_DEBUGMODE_}


{ þ >>> P L A Y E R  S E T T I N G S <<< þ }

{ DEFINE _ISS_PLAY_DEBUGMODE_}


{ þ >>> G L O B A L  D E F I N E S <<< þ }

{ þ This is REQUIRED. If the record fields not aligned to WORD, þ }
{ þ the mixer WILL crash. This may change in the future. þ }
{$PACKRECORDS 2}
