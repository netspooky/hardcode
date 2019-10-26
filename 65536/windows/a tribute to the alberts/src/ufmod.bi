'  uFMOD header file
'  Target OS: Windows
'  Compiler:  FreeBASIC
'  Driver:    WINMM

'  function uFMOD_PlaySong(
'     byval lpXM    as any ptr,
'     byval param   as uinteger,
'     byval fdwSong as uinteger
'  ) as HWAVEOUT ptr
'  ---
'  Description:
'  ---
'     Loads the given XM song and starts playing it immediately,
'     unless XM_SUSPENDED is specified. It will stop any currently
'     playing song before loading the new one.
'  ---
'  Parameters:
'  ---
'    lpXM
'       Specifies the song to play. If this parameter is 0, any
'       currently playing song is stopped. In such a case, function
'       does not return a meaningful value. fdwSong parameter
'       determines whether this value is interpreted as a filename,
'       as a resource identifier or a pointer to an image of the song
'       in memory.
'    param
'       If XM_RESOURCE is specified, this parameter should be the
'       handle to the executable file that contains the resource to
'       be loaded. A 0 value refers to the executable module itself.
'       If XM_MEMORY is specified, this parameter should be the size
'       of the image of the song in memory.
'       If XM_FILE is specified, this parameter is ignored.
'    fdwSong
'       Flags for playing the song. The following values are defined:
'       XM_FILE      lpXM points to filename. param is ignored.
'       XM_MEMORY    lpXM points to an image of a song in memory.
'                    param is the image size. Once, uFMOD_PlaySong
'                    returns, it's safe to free/discard the memory
'                    buffer.
'       XM_RESOURCE  lpXM specifies the name of the resource.
'                    param identifies the module whose executable file
'                    contains the resource.
'                    The resource type must be RT_RCDATA.
'       XM_NOLOOP    An XM track plays repeatedly by default. Specify
'                    this flag to play it only once.
'       XM_SUSPENDED The XM track is loaded in a suspended state,
'                    and will not play until the uFMOD_Resume function
'                    is called. This is useful for preloading a song
'                    or testing an XM track for validity.
'  ---
'  Return Values:
'  ---
'     On success, returns a pointer to an open WINMM output device handle.
'     Returns 0 on failure. If you are familiar with WINMM, you'll know
'     what this handle might be useful for :)
'  ---
'  Remarks:
'  ---
'     If no valid song is specified and there is one currently being
'     played, uFMOD_PlaySong just stops playback.
declare function uFMOD_PlaySong stdcall alias "uFMOD_PlaySong" (byval as any ptr, byval as uinteger, byval as uinteger) as any ptr
#define uFMOD_StopSong() uFMOD_PlaySong(0, 0, 0)

'  sub uFMOD_Jump2Pattern(
'     byval pat as uinteger
'  )
'  ---
'  Description:
'  ---
'     Jumps to the specified pattern index.
'  ---
'  Parameters:
'  ---
'     pat
'        Next zero based pattern index.
'  ---
'  Remarks:
'  ---
'     uFMOD doesn't automatically perform Note Off effects before jumping
'     to the target pattern. In other words, the original pattern will
'     remain in the mixer until it fades out. You can use this feature to
'     your advantage. If you don't like it, just insert leading Note Off
'     commands in all patterns intended to be used as uFMOD_Jump2Pattern
'     targets.
'     if the pattern index lays outside of the bounds of the pattern order
'     table, calling this function jumps to pattern 0, effectively
'     rewinding playback.
declare sub uFMOD_Jump2Pattern stdcall alias "uFMOD_Jump2Pattern" (byval as uinteger)
#define uFMOD_Rewind() uFMOD_Jump2Pattern(0)

'  sub uFMOD_Pause
'  ---
'  Description:
'  ---
'     Pauses the currently playing song, if any.
'  ---
'  Remarks:
'  ---
'     While paused you can still control the volume (uFMOD_SetVolume) and
'     the pattern order (uFMOD_Jump2Pattern). The RMS volume coefficients
'     (uFMOD_GetStats) will go down to 0 and the progress tracker
'     (uFMOD_GetTime) will "freeze" while the song is paused.
'     uFMOD_Pause doesn't perform the request immediately. Instead, it
'     signals to pause when playback reaches next chunk of data, which may
'     take up to about 40ms. This way, uFMOD_Pause performs asynchronously
'     and returns very fast. It is not cumulative. So, calling
'     uFMOD_Pause many times in a row has the same effect as calling it
'     once.
'     If you need synchronous pause/resuming, you can use WINMM
'     waveOutPause/waveOutRestart functions.
declare sub uFMOD_Pause alias "uFMOD_Pause"

'  sub uFMOD_Resume
'  ---
'  Description:
'  ---
'     Resumes the currently paused song, if any.
'  ---
'  Remarks:
'  ---
'     uFMOD_Resume doesn't perform the request immediately. Instead, it
'     signals to resume when an internal thread gets a time slice, which
'     may take some milliseconds to happen. Usually, calling Sleep(0)
'     immediately after uFMOD_Resume causes it to resume faster.
'     uFMOD_Resume is not cumulative. So, calling it many times in a row
'     has the same effect as calling it once.
'     If you need synchronous pause/resuming, you can use WINMM
'     waveOutPause/waveOutRestart functions.
declare sub uFMOD_Resume alias "uFMOD_Resume"

'  function uFMOD_GetStats as uinteger
'  ---
'  Description:
'  ---
'     Returns the current RMS volume coefficients in (L)eft and (R)ight
'     channels.
'        low-order word: RMS volume in R channel
'        hi-order word:  RMS volume in L channel
'     Range from 0 (silence) to $7FFF (maximum) on each channel.
'  ---
'  Remarks:
'  ---
'     This function is useful for updating a VU meter. It's recommended
'     to rescale the output to log10 (decibels or dB for short), because
'     human ears track volume changes in a dB scale. You may call
'     uFMOD_GetStats() as often as you like, but take in mind that uFMOD
'     updates both channel RMS volumes every 20-40ms, depending on the
'     output sampling rate. So, calling uFMOD_GetStats about 16 times a
'     second whould be quite enough to track volume changes very closely.
declare function uFMOD_GetStats alias "uFMOD_GetStats" as uinteger

'  function uFMOD_GetRowOrder as uinteger
'  ---
'  Description:
'  ---
'     Returns the currently playing row and order.
'        low-order word: row
'        hi-order word:  order
'  ---
'  Remarks:
'  ---
'     This function is useful for synchronization. uFMOD updates both
'     row and order values every 20-40ms, depending on the output sampling
'     rate. So, calling uFMOD_GetRowOrder about 16 times a second whould be
'     quite enough to track row and order progress very closely.
declare function uFMOD_GetRowOrder alias "uFMOD_GetRowOrder" as uinteger

'  function uFMOD_GetTime as uinteger
'  ---
'  Description:
'  ---
'     Returns the time in milliseconds since the song was started.
'  ---
'  Remarks:
'  ---
'     This function is useful for synchronizing purposes. In fact, it is
'     more precise than a regular timer in Win32. Multimedia applications
'     can use uFMOD_GetTime to synchronize GFX to sound, for example. An
'     XM player can use this function to update a progress meter.
declare function uFMOD_GetTime alias "uFMOD_GetTime" as uinteger

'  function uFMOD_GetTitle as zstring ptr
'  ---
'  Description:
'  ---
'     Returns the current song's title.
'  ---
'  Remarks:
'  ---
'     Not every song has a title, so be prepared to get an empty string.
'     The string format may be ANSI or Unicode debending on the UF_UFS
'     settings used while recompiling the library.
declare function uFMOD_GetTitle alias "uFMOD_GetTitle" as zstring ptr

'  sub uFMOD_SetVolume(
'     byval vol as uinteger
'  )
'  ---
'  Description:
'  ---
'     Sets the global volume. The volume scale is linear.
'  ---
'  Parameters:
'  ---
'     vol
'        New volume. Range: from uFMOD_MIN_VOL (muting) to uFMOD_MAX_VOL
'        (maximum volume). Any value above uFMOD_MAX_VOL maps to maximum
'        volume.
'  ---
'  Remarks:
'  ---
'     uFMOD internally converts the given values to a logarithmic scale (dB).
'     Maximum volume is set by default. The volume value is preserved across
'     uFMOD_PlaySong calls. You can set the desired volume level before
'     actually starting to play a song.
'     You can use WINMM waveOutSetVolume function to control the L and R
'     channels volumes separately. It also has a wider range than
'     uFMOD_SetVolume, sometimes allowing to amplify the sound volume as well,
'     as opposed to uFMOD_SetVolume only being able to attenuate it. The bad
'     things about waveOutSetVolume is that it may produce clicks and it's
'     hardware dependent.
declare sub uFMOD_SetVolume stdcall alias "uFMOD_SetVolume" (byval as uinteger)

#define XM_RESOURCE       0
#define XM_MEMORY         1
#define XM_FILE           2
#define XM_NOLOOP         8
#define XM_SUSPENDED      16
#define uFMOD_MIN_VOL     0
#define uFMOD_MAX_VOL     25
#define uFMOD_DEFAULT_VOL 25