unit sound;

interface

procedure initSound;
procedure deInitSound;

implementation

uses  Windows, MMsystem, Classes, SysUtils;

var     wDeviceID : word;

procedure initSound;
var dwReturn : DWord;
    mciOpenParms : MCI_OPEN_PARMS;
    mciPlayParms : MCI_PLAY_PARMS;
    mciStatusParms : MCI_STATUS_PARMS;
    mciSeqSetParms : MCI_SEQ_SET_PARMS;

    ResourceStream : TResourceStream;
begin
  try
    ResourceStream :=TResourceStream.Create(hInstance, 'music', 'MIDI');
    ResourceStream.SaveToFile('music.mid');
  finally
    ResourceStream.Free;
  end;

  // Open the device by specifying the device and filename.
  // MCI will attempt to choose the MIDI mapper as the output port.
  mciOpenParms.lpstrDeviceType := 'sequencer';
  mciOpenParms.lpstrElementName := 'music.mid';
  dwReturn := mciSendCommand(0, MCI_OPEN, MCI_OPEN_TYPE OR MCI_OPEN_ELEMENT, Longint(@mciOpenParms));
  if dwReturn <> 0 then
      exit;

  // The device opened successfully; get the device ID.
  wDeviceID := mciOpenParms.wDeviceID;

  // Check if the output port is the MIDI mapper.
  mciStatusParms.dwItem := MCI_SEQ_STATUS_PORT;
  dwReturn := mciSendCommand(wDeviceID, MCI_STATUS, MCI_STATUS_ITEM, Longint(@mciStatusParms));
  if dwReturn <> 0 then
  begin
    mciSendCommand(wDeviceID, MCI_CLOSE, 0, NULL);
    exit;
  end;

  // The output port is not the MIDI mapper.
  // Ask if the user wants to continue.
  if LOWORD(mciStatusParms.dwReturn) <> Word(MIDI_MAPPER) then
  begin
    mciSendCommand(wDeviceID, MCI_CLOSE, 0, 0);
    exit;
  end;

  // Begin playback. The window procedure function for the parent
  // window will be notified with an MM_MCINOTIFY message when
  // playback is complete. At this time, the window procedure closes
  // the device.
  dwReturn := mciSendCommand(wDeviceID, MCI_PLAY, MCI_NOTIFY, Longint(@mciPlayParms));
  if dwReturn <> 0 then
  begin
    mciSendCommand(wDeviceID, MCI_CLOSE, 0, 0);
    exit;
  end;
end;


procedure deInitSound;
begin
  mciSendCommand(wDeviceID, MCI_CLOSE, 0, 0);
  DeleteFile('music.mid');
end;


end.
