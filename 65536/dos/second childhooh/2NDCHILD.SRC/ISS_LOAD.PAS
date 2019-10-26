{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ ş ISS_LOAD.PAS - High level loading routines                             ³}
{³                  Work started     : 1999.05.24.                          ³}
{³                  Last modification: 2001.01.18.                          ³}
{³             OS - Platform Independent                                    ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$MODE FPC}
{$IOCHECKS OFF}
Unit ISS_Load;

Interface

Uses ISS_Var { ş Uses the system variables and types ş }
     {$IFDEF _ISS_XM_INCLUDE_}
      ,ISS_XM  { ş Includes the XM loader ş }
     {$ENDIF}
     {$IFDEF _ISS_MOD_INCLUDE_}
      ,ISS_MOD { ş Includes the MOD loader ş }
     {$ENDIF}
     {$IFDEF _ISS_S3M_INCLUDE_}
      ,ISS_S3M { ş Includes the S3M loader ş }
     {$ENDIF}
     {$IFDEF _ISS_LOAD_IDSMODE_}
      ,IDS_LOAD
     {$ENDIF}
     ;

{$IFNDEF _ISS_LOAD_NOFILEMODE_}
Function ISS_LoadModule(FileName : String; Var Module : ISS_PModule) : Boolean;
{$ENDIF}
{$IFDEF _ISS_LOAD_IDSMODE_}
Function ISS_IDSLoadModule(DFHandle : IDS_PDataFile; FileName : String;
                           Var Module : ISS_PModule) : Boolean;
{$ENDIF}
Function ISS_LoadInternalModule(ModMem : Pointer;
                            Var Module : ISS_PModule) : Boolean;
Function ISS_FreeModule(Var Module : ISS_PModule) : Boolean;

Function ISS_InitLoaders : Boolean;

Implementation

Var ISS_LoaderOK  : Boolean; { ş True if there is an usable loader ş }
    ISS_LoaderNum : DWord;   { ş Number of loaders ş }

    { ş Loaders ş }
    ISS_Loader    : Array[1..ISS_MaxLoaders] Of ISS_PModuleLoader;


{$IFDEF _ISS_LOAD_IDSMODE_}
Function ISS_IDSLoadModule(DFHandle : IDS_PDataFile; FileName : String;
                           Var Module : ISS_PModule) : Boolean;
Var ModuleFile : IDS_PFile;
Begin
 ISS_IDSLoadModule:=False;
 If DFHandle=Nil Then Exit;
 If Not ISS_LoaderOk Then Exit;

 ModuleFile:=IDS_OpenFile(DFHandle,FileName);
 If ModuleFile=Nil Then Exit;

 With ModuleFile^ Do Begin
   ISS_IDSLoadModule:=ISS_LoadInternalModule(FData,Module);
  End;
 IDS_CloseFile(ModuleFile);
End;
{$ENDIF}

{$IFNDEF _ISS_LOAD_NOFILEMODE_}
{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_LoadModule                                                          ³}
{³                                                                          ³}
{³. Description : Opens a module file, reads it to the memory, and calls    ³}
{³                ISS_LoadInternalModule procedure to load the module to    ³}
{³                the player. Returns a pointer to the loaded module        ³}
{³                structure, and the error code.                            ³}
{³                                                                          ³}
{³. Parameters  : FileName - [I] The file name of the module to be loaded.  ³}
{³                Module   - [O] Pointer to the loaded module structure.    ³}
{³                                                                          ³}
{³. Returns     : A Boolean value, true if successful, false if not         ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Function ISS_LoadModule(FileName : String; Var Module : ISS_PModule) : Boolean;
Var ModuleFile : File;
    ModuleSize : DWord;
    ModuleMem  : Pointer;
Begin
 ISS_LoadModule:=False;
 If ISS_LoaderOK Then Begin
   { ş Opening the file ş }
   Assign(ModuleFile, FileName);
   FileMode:=0;
   Reset(ModuleFile,1);
   If IOResult<>0 Then Begin
     { ş ERROR CODE! ş }
     Close(ModuleFile);
     Exit;
    End;

   { ş Loading the file into memory ş }
   ModuleSize:=FileSize(ModuleFile);
   GetMem(ModuleMem,ModuleSize);     { ş Allocating memory ş }
   BlockRead(ModuleFile,ModuleMem^,ModuleSize); { ş Loading file ş }
   If IOResult<>0 Then Begin
     { ş ERROR CODE! ş }
     FreeMem(ModuleMem,ModuleSize); { ş Freeing up memory ş }
     Close(ModuleFile);
     Exit;
    End;

   { ş Loading Module ş }
   ISS_LoadModule:=ISS_LoadInternalModule(ModuleMem,Module);

   FreeMem(ModuleMem,ModuleSize); { ş Freeing up memory ş }
   Close(ModuleFile); { ş Closing the file ş }

  End;
End;
{$ENDIF}

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_LoadInternalModule                                                  ³}
{³                                                                          ³}
{³. Description : Loads a module from the specified memory area using the   ³}
{³                low level module loading routines, and returns a pointer  ³}
{³                to the module structure, and the error code.              ³}
{³                                                                          ³}
{³. Parameters  : ModMem - [I] A pointer to the "raw" module to be loaded.  ³}
{³                Module - [O] Pointer to the loaded module structure.      ³}
{³                                                                          ³}
{³. Returns     : A Boolean value, true if successful, false if not         ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Function ISS_LoadInternalModule(ModMem : Pointer;
                            Var Module : ISS_PModule) : Boolean;
Var Counter : DWord;
Begin
 ISS_LoadInternalModule:=False;

 { ş Is the pointer specified free? ş }
 If (Module<>Nil) And (Module^.MID=ISS_ModuleID) Then Begin
   { ş ERROR CODE! ş }
   Exit;
  End;

 Module:=Nil;
 If ISS_LoaderOK Then Begin

   { ş Selecting Loader ş }
   Counter:=0;
   Repeat
    Inc(Counter);
    If Counter>ISS_LoaderNum Then Begin
      { ş ERROR CODE! ş }
      Exit;
     End;
    ISS_Loader[Counter]^.ModuleMem:=ModMem;
   Until ISS_Loader[Counter]^.CheckModule();

   { ş Loading Module ş }
   With ISS_Loader[Counter]^ Do Begin

     {$IFDEF _ISS_LOAD_DEBUGMODE_}
      DebugInit;
     {$ENDIF}

     New(ModulePtr); { ş Allocating memory for the header ş }
     If Not LoadHeader() Then Begin { ş Loading Header ş }
       { ş ERROR CODE! ş }
       Dispose(ModulePtr);
       Exit;
      End;
     ModulePtr^.MStatus:=0; { ş Clearing status ş }

     { ş Allocating pattern header memory ş }
     For Counter:=0 To ModulePtr^.MPatternNum Do Begin
       New(ModulePtr^.MPatterns[Counter]);
      End;
     If Not LoadPatterns() Then Begin { ş Loading Patterns ş }
       { ş Deallocating pattern header memory if loading failed ş }
       For Counter:=0 To ModulePtr^.MPatternNum Do Begin
         Dispose(ModulePtr^.MPatterns[Counter]);
        End;
       { ş ERROR CODE! ş }
       Dispose(ModulePtr);
       Exit;
      End;

     { ş Allocating instrument header memory ş }
     For Counter:=1 To ModulePtr^.MInstrNum Do Begin
       New(ModulePtr^.MInstruments[Counter]);
      End;
     If Not LoadInstruments() Then Begin { ş Loading Instruments ş }
       { ş Allocating instrument header memory ş }
       For Counter:=1 To ModulePtr^.MInstrNum Do Begin
         Dispose(ModulePtr^.MInstruments[Counter]);
        End;
       { ş Dellocating pattern header memory if loading failed ş }
       For Counter:=0 To ModulePtr^.MPatternNum Do Begin
         Dispose(ModulePtr^.MPatterns[Counter]);
        End;
       { ş ERROR CODE! ş }
       Dispose(ModulePtr);
       Exit;
      End;

     {$IFDEF _ISS_LOAD_DEBUGMODE_}
      DebugDone;
     {$ENDIF}

     ModulePtr^.MID:=ISS_ModuleID;
     Module:=ModulePtr;
     ISS_LoadInternalModule:=True;

    End;
  End;
End;

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_FreeModule                                                          ³}
{³                                                                          ³}
{³. Description : Frees up the memory area allocated by the ISS_LoadModule  ³}
{³                function. Returns the error code.                         ³}
{³                                                                          ³}
{³. Parameters  : Module - [I] Pointer to the loaded module structure.      ³}
{³                                                                          ³}
{³. Returns     : A Boolean value, true if successful, false if not         ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Function ISS_FreeModule(Var Module : ISS_PModule) : Boolean;
Var Counter  : DWord;
    Counter2 : DWord;
Begin
 ISS_FreeModule:=False;
 If ISS_LoaderOK Then Begin

   { ş Specified pointer not points to a loaded module? ş }
   If (Module=Nil) Or (Module^.MID<>ISS_ModuleID) Then Begin
     { ş ERROR CODE! ş }
     Exit;
    End;

   {$IFDEF _ISS_LOAD_DEBUGMODE_}
    Write('LDR_INIT: Deallocating module memory... ');
   {$ENDIF}

   With Module^ Do Begin

     { ş Module is loaded to the player device? ş }
     If MStatus>0 Then Begin
       { ş ERROR CODE! ş }
       Exit;
      End;

     { ş Freeing up instrument memory ş }
     For Counter:=1 To MInstrNum Do Begin
       With MInstruments[Counter]^ Do Begin

         { ş Free up samples memory ş }
         If ISampleNum>0 Then Begin
           For Counter2:=0 To ISampleNum-1 Do Begin
             With ISamples[Counter2]^ Do Begin
               If SLength>0 Then FreeMem(SData,SLength);
              End;
             Dispose(ISamples[Counter2]);
            End;
          End;

        End;
       Dispose(MInstruments[Counter]);
      End;

     { ş Freeing up pattern memory ş }
     For Counter:=0 To MPatternNum Do Begin
       { ş Free up pattern data memory ş }
       With MPatterns[Counter]^ Do Begin
         FreeMem(PatRows,PatSize);
        End;
       Dispose(MPatterns[Counter]);
      End;
    End;

   Module^.MID:='!?!?'; { ş Destroying module ID ş }
   Dispose(Module);     { ş Freeing up module header ş }

   {$IFDEF _ISS_LOAD_DEBUGMODE_}
    WriteLn('DONE.');
   {$ENDIF}

   ISS_FreeModule:=True;
  End;
End;

{ ş Initializes the low-level loader routines. ş }
Function ISS_InitLoaders : Boolean;
Begin
 ISS_LoaderNum:=0;

 {$IFDEF _ISS_XM_INCLUDE_}
  Inc(ISS_LoaderNum);
  ISS_XMLoaderInit;
  ISS_Loader[ISS_LoaderNum]:=@ISS_XMLoader;
 {$ENDIF}

 If ISS_LoaderNum<>0 Then ISS_LoaderOK:=True Else ISS_LoaderOk:=False;

 {$IFDEF _ISS_LOAD_DEBUGMODE_}
  If ISS_LoaderOK Then
    WriteLn('LDR_INIT: ',ISS_LoaderNum,' Module Loader(s) Initialized')
   Else
    WriteLn('LDR_INIT: WARNING! No Module Loaders Included!');
 {$ENDIF}

 ISS_InitLoaders:=ISS_LoaderOK;
End;

Begin
End.
{ ş ISS_LOAD.PAS - (C) 1999-2001 Charlie/Inquisition ş }
