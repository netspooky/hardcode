
    | Kuunsyke presents..
    |
    |   [ Spaceworm ]
    |   
    | 4k intro for Assembly 2003
    |
    |  Code and Music - by - BuG
    |
    +-----------------------

+-----------------------------------------------
| Requirements
+-----------------------------------------------
  - Windows XP or 2000
  - DirectX 9.0
  - "Good" 3D graphics accelerator
  - 800MHz processor
  - Sound card with MIDI synth

TEMP environment variable must point to a writable directory.

+-----------------------------------------------
| Music info
+-----------------------------------------------

The default MIDI device is used for music output.
Please make sure you set some *wavetable* device as default!

    In Windows XP, go to
        Control Panel ->
        Sounds and Audio Devices ->
        Audio ->
        MIDI music playback ->
        Default device

    Select your sound card MIDI synth:
        for SB Live, "SB Live! Synth A" or B.
        for SB Audigy, "SB Audigy Synth A" or B.

If the music is not functioning, go through the MIDI troubleshooting
section below until you can hear the music.

+-----------------------------------------------
| Intro troubleshooting
+-----------------------------------------------

If the intro doesn't start (no change in screen mode), an error
occured. Possible reasons include:
    - No DirectX 9.0 installed
    - Too old graphics card (check your drivers also!)
    - Invalid TEMP variable (shouldn't be..)

There is no room for error messages that would describe the actual
cause of crash, sorry.

+-----------------------------------------------
| MIDI troubleshooting
+-----------------------------------------------

    - Make sure your sound card and other audio equipment is
      functioning well. Test winamp, for example. If winamp is
      not functioning, fix that first.

    - Use the mixer (sndvol32.exe)
      to make sure your MIDI and MASTER volumes
      are turned up and from the right mixer device.

    - Turn off all hardware effects from your sound card.
      For SB Live and similar use the AudioHQ applet to
      start the EAX Control Panel. Select "no effects" from
      the dropdown list.



                                                +-------------------
                                                | kuunsyke@nic.fi
                                                |
