# The Secret of Mental Island - JS1K 2016 - "EleMental"

In previous JS1K contents people have entered great musical entries before like 
the [Game of Thrones soundtrack](http://js1k.com/2014-dragons/demo/1953) or the
[Synth Sphere](http://js1k.com/2013-spring/demo/1558). Those entries heavily 
relied on procedural generated note progression through code or through bytebeat
functions. This way, composing or recreating music is difficult. So, I am trying 
to find out, if it is possible to use a tool like Renoise to 
produce music that can still be used in a tiny program like a 1K JavaScript
demo without the necessity to couple code and music very tightly.

*UPDATE 2016-03-21:*

Awesome Mathieu 'p01' Henri made a much better looking version of the demo
that you can checkout here: (http://bl.ocks.org/p01/2bac941529aef959e8c9). 
He already incorporated some changes/optimizations I had already thought of, too,
but went much further with this than I had ever thought of. This is really impressive
and inspriring work!

*UPDATE 2016-03-30:*

Peter van der Zee (@kuvos) contributed some improvements to the code size via
pull request. And then Mathieu 'p01' Henri (@p01) completely reworked the code 
and shaved unbelievable 124 bytes off. I merged his changes and fixed the 
minor sound bugs that came with the amazing weight loss. Now, I can compress the
code to 904 bytes. Still, enough to fit some more stuff into it.

## Making the Music

As the first step, I select a fairly complex piece of music. My decision goes
towards the highly sophisticated title soundtrack of Monkey Island that was 
composed by talented Michael Land. So, I sit down and recreate the music with
Renoise using only two monophonic tracks while also enjoying sweet childhood 
memories. My aim is to keep the spirit of the original but also to
reduce the number of notes. Reducing the number of notes used  reduces entropy, 
which increases compressibility.

The result of this work is the Renoise tracker file [monkey.xrns](https://github.com/homecoded/demo/raw/master/HC04-secret-of-mental-island-by-homecoded/monkey.xrns).

## Converting the Music to Javascript Data
 
A Renoise module is basically just a ZIP-file. I extract the ```Song.xml```
from the module and put its contents into a textarea inside a html-file. After
analyzing the XML file, I find that it can be easily parsed via jQuery. The file
consists of a list of patterns, which in turn consist of a list of tracks, which
again consist of a list of lines and lines contain a note node. Each pattern
also defines how many lines are in the pattern.

    <RenoiseSong>
        <PatternPool>
            <Patterns>
                <Pattern>
                    <NumberOfLines>64</NumberOfLines>
                    <Tracks>
                        <PatternTrack>
                            <Lines>
                                <Line>
                                    <NoteColumns>
                                        <NoteColumn>
                                            <Note>C-1</Note>
                                        </NoteColumn>
                                    </NoteColumns>
                                </Line>
                                <Line>
                                    <NoteColumns>
                                        <NoteColumn>
                                            <Note>D-1</Note>
                                        </NoteColumn>
                                    </NoteColumns>
                                </Line>
                                ...
                            </Lines>
                        </PatternTrack>
                    </Tracks>
                </Pattern>
                <Pattern>
                    ...
                </Pattern>
                ...
            </Patterns>
        </PatternPool>
    </RenoiseSong>
    
The result of the first parse run is an array, that contains both tracks with all 
their notes. Together with a mapping table that assigns a frequency to each note
name, I create two arrays, one for each track, that contain lists of frequencies. 
While doing that, I create a list of used notes. The list of actually used notes
has a length of 30, an information that will be needed later.

After obtaining the song described as a list of frequencies, I convert the song
into a string where each character represents an index of the used-notes array.
The indexes are encoded as base35 encoded numbers. That means a number may 
be comprised of digits 0-9 and the letters a to y. This analogous to hexadecimal
numbers, which are based on the number 16 and thus contain numbers 0-9 and letters a-f. 
To encode the music base31 would have sufficed but I decide to use a number that is also used as
a frequency in the note table. This duplication of the number 35 helps compress
the code just a tiny little bit better.

    // FYI, this is how you convert a number to base35
    var iNumber = 20;
    iNumber.toString(35); // "k"

I store my data conversion script in the file [extract_music_data.html](http://htmlpreview.github.io/?https://github.com/homecoded/demo/blob/master/HC04-secret-of-mental-island-by-homecoded/extract_music_data.html?v=1).

## Building the Player

### A WebAudio API frame

For the player I decide to use the [WebAudio API](https://webaudio.github.io/web-audio-api/), 
which makes looping the music forever easy and provides a great quality of sound. 
So, for playing the music I use an ```AudioContext``` and a ```ScriptProcessorNode```.
The technical frame for music player looks like this:

    var oAudioContext = new AudioContext,
        oProcessor = oAudioContext.createScriptProcessor(4096, 1, 2),
        iLocalSampleIndex
        iSampleIndex = 0,
        aChannel1, aChannel2
    ;
        
    oProcessor.onaudioprocess = function (oData) {
        aChannel1 = oData.outputBuffer.getChannelData(0);
        aChannel2 = oData.outputBuffer.getChannelData(1);
        for (iLocalSampleIndex = 0; iLocalSampleIndex < 4096; iLocalSampleIndex++)
                // get the sample values for the tracks and store them in the audio buffer
                aChannel1[iLocalSampleIndex] = getSampleValueTrack1AtSampleIndex(iSampleIndex),
                aChannel2[iLocalSampleIndex] = getSampleValueTrack2AtSampleIndex(iSampleIndex),
                // loop after 264 notes
                iSampleIndex > 264 * iNoteLengthInSamples && (iSampleIndex = 0),
                // increase overall sample index
                iSampleIndex++
    };
    oProcessor.connect(oAudioContext.destination);

It's a very simple setup that writes each track to one of the stereo channels. This way 
I could spare any code for mixing. This will cause a 100% stereo separation, which probably
drives anyone insane using headphones. For the sake of saving some precious bytes, this has
to do, though. Note, that I also do not use any curly brackets in the for loop, instead I make one
large statement separated by commas. Again, this is another little byte saver.
 
### Converting the Data Back to Music

The demo code contains the note array  as a list of frequencies and two strings containing
indexes to that array as base35 encoded numbers. When I go through the characters of a string,
I can determine the frequency for the current track position:

    var 
        // this is the note array, each entry is the frequency for one note 
        aNotes = [35, 37, 41, 46, 49, 55, 58, 62, 65, 73, 82, 93, 98, 110, 117, 123, 131, 139, 147, 165, 185, 196, 220, 233, 247, 262, 277, 294, 330, 370],
        // this is a sample track
        sTrack = "7 fi7 f 5 d c",
        // this gives us the index of the character inside the track string
        iTrackNoteIndex  = Math.floor(iSampleIndex / iNoteLengthInSamples),
        // this gives us the character at the index, note: you can access characters of a string like an array
        sNoteIndexBase35 = sTrack[iTrackNoteIndex],
        // convert the base35 to base10
        iNoteFrequencyIndex = parseInt(sNoteIndexBase35, 35),
        // get the frequency at the position
        iFrequency = aNotes[iNoteFrequencyIndex]
    ;
    
This simple procedure determines the frequency to any given sample index. Together with an
oscillator I am able to produce sample data, which I can then feed into the audio buffer. 
I like the acoustic properties of square waves, so I decide to go with that instead of a simpler
oscillator like a sine-wave or a sawtooth wave. This costs me a few bytes but I really want
a square wave.

    iSampleValue = 0 < Math.sin(Math.PI * iSampleIndex / iSampleRate * 4 * fNoteFrequency) ? 1 : -1;
    
I decide to use a sine-wave as the basic oscillator. I turn its wave form into a square wave
by flooring its return values to -1 when they are negative and ceiling them to 1 in all other cases.
There are more elegant (and/or byte-economizing) ways to achieve a square wave, yet this version 
is easy to understand and probably the least complicated way to achieve a square wave of 
a frequency.

    ^
    |
    |####...####
    |##..   ..##
    |#.       .#
    |.         .
    |------------------------>
    |           .         .
    |           #.       .#
    |           ##..   ..##
    |           ####...####
    |

## Visualizations

Now, that I have the music in place, I still have a few hundred bytes left for some 
visualizations. It's not much but let's see what we can do. I would love to re-create
the Monkey Island title screen but with 200-300 bytes left there is only so much you 
can achieve. The original title screen shows Melee Island by night. 

![Monkey Island Title Screen](http://homecoded.com/prods/hc-04/monkey.jpg "Monkey Island Title Screen")

To make thinks easier I set a fixed canvas size so I can at least rely on this (virtual)
screen size. In each frame I fill the background with a gradient. Then, over that background
I draw lines, from the bottom of the screen to a calculated height. I define the
height via a sum of sine functions: One defines the overall shape of the island while
the other introduces some variation with a higher frequency.

For the water I simply plot the current content of the audio buffer. This actually 
make for some nice waves.

## Improvements

### Square Wave Generation

While the results so far are quite satisfactory, there is a lot of room for improvement.
An interesting path for exploration is using a sawtooth wave as base oscillator that gets
generated by using the sample index and applying a binary AND with 255. If I then AND the 
result with a power of two I'd receive a square wave again. The whole process can be 
the simplified to a single AND operation. The pitch can be increased or decreased by 
multiplying the sample index before applying any binary operations.

There is a problem with this approach. The base tone generated by this lies at around 
172.94 Hz if the sample frequency is set to 44100 Hz. The sample frequency of the WebAudio 
API is not fixed, though. It may be different from device to device. So, if the sample
frequency is higher than 44100 Hz the base tone is also higher. That means, we have
to make sure to compensate those possible differences, which make the whole process 
a little more complicated. At this point I don't even know if that will reduce the
size of the demo after all. It probably will, if I also use a sawtooth wave as 
another oscillator, which would lead to some duplicated cod. And code containing a lot
of duplication compresses better.

If an Audio element is used instead of WebAudio-API, we can specify the sample frequency 
and thus rely on the same base tone pitch on all computers. Downside here is that 
the Audio element only works on some Desktop browses such as Chrome and Firefox, 
while the WebAudio API also works flawlessly on Android and other mobile platforms. 
Also, it's easy to get 8bit audio working, but it's slightly more complicated to get 
16 bit or more and thus requires a few more precious bytes.

### Percussions and more Oscillators

One of the next steps I want to try out is to have more than one oscillator in the mix.
This will make the music much richer and more interesting. Sine and sawtooth will be
easy additions.

Of course, percussion would be handy as well. At least base drum, snare and high-hat  
are must-haves.

### Visualization

I hastily put the demo together on the night before I went on a family holiday. My 
laptop screen was quite bright, so I used colors that look way too dark on other 
screens. Too bad! I realized my mistake too late.

## License

License: MIT license.

The original Monkey Island soundtrack was composed my Michael Land. LucasArts
owns all rights to the music. The original soundtrack was altered and simplified
for the purpose of this code golfing project by Manuel Rülke.

This work is purely for educational purposes. The use of the copyrighted
music falls under the fair use.
