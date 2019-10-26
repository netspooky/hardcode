/**
 * "The Secret of Mental Island"
 * JS1K 2916 entry by Manuel Rülke / homecoded /DESiRE
 *
 * This is the annotated source code. You can find the original in the
 * file ```demo..js```, which is also part of this repository.
 *
 * License: MIT license.
 *
 * The original Monkey Island soundtrack was composed my Michael Land. LucasArts
 * owns all rights to the music. The original soundtrack was altered and simplified
 * for the purpose of this code golfing project.
 *
 * This work is purely for educational purposes. The use of the copyrighted
 * music falls under the fair use.
 */

var aNotes = [35, 37, 41, 46, 49, 55, 58, 62, 65, 73, 82, 93, 98, 110, 117, 123, 131, 139, 147, 165, 185, 196, 220, 233, 247, 262, 277, 294, 330, 370],
    sTrack1 = "    o  rqom o     m  lkml   k     o    rqom o      qr   s   q  rqomqr   q   o  rqomqr   q   o  rqom o           mlkml   k                         m o i     lkjlm i     k i l m    smsrsr q o k     h i p               t r     q r qror  l             j h     f h fhd ",
    sTrack2 = "7 fi7 f 5 d c lo9 i 9 d a   jf o7 f 7 f 5 d c lo9 i 9 i a a d m d   9 i 6 en7 f 5 d 9 b 3 b 7 fi5 dg4 cf4 c 4 cf9 i a j f   7 fi9 f d d 7 fk9 f 5 dhc             9 b d     4 dk0 2 5   7   3 1       7 8 a c         g f b 9          79 b d         i h d a         d ",
    oAudioContext = new AudioContext,
    iSampleRate = oAudioContext.sampleRate,
    iNoteLengthInSamples = .16 * iSampleRate,
    iSampleIndex = 0,
    oProcessor = oAudioContext.createScriptProcessor(4096, 1, 2),
    fFrequencyTrack1,fFrequencyTrack2, iLocalSampleIndex, aChannel1, aChannel2, iWaveHeight,
    x;

oProcessor.onaudioprocess = function (oData) {
    aChannel1 = oData.outputBuffer.getChannelData(0);
    aChannel2 = oData.outputBuffer.getChannelData(1);
    for (iLocalSampleIndex = 0; iLocalSampleIndex < 4096; iLocalSampleIndex++)
            fFrequencyTrack1 = aNotes[parseInt(sTrack1[~~(iSampleIndex / iNoteLengthInSamples)], 35)] ? aNotes[parseInt(sTrack1[~~(iSampleIndex / iNoteLengthInSamples)], 35)] : fFrequencyTrack1,
            fFrequencyTrack2 = aNotes[parseInt(sTrack2 [~~(iSampleIndex / iNoteLengthInSamples)], 35)] ? aNotes[parseInt(sTrack2[~~(iSampleIndex / iNoteLengthInSamples)], 35)] : fFrequencyTrack2,
            aChannel1[iLocalSampleIndex] = 0 < Math.sin(Math.PI * iSampleIndex / iSampleRate * 4 * fFrequencyTrack1) ? 1 : -1,
            aChannel2[iLocalSampleIndex] = 0 < Math.sin(Math.PI * iSampleIndex / iSampleRate * 4 * fFrequencyTrack2) ? 1 : -1,
        iSampleIndex > 264 * iNoteLengthInSamples && (iSampleIndex = 0),
            iSampleIndex++
};
oProcessor.connect(oAudioContext.destination);
a.width = 800;
a.height = 370;

// drawing routine for Melee Island
setInterval(function (oGradient) {
    oGradient = c.createLinearGradient(0, 0, 0, 370);
    c.fillStyle = oGradient;
    oGradient.addColorStop(0, "#214");
    oGradient.addColorStop(1, "#44F");
    c.fillRect(0, 0, 800, 370);
    c.fillStyle = "#002";
    iWaveHeight = 370 / 6;
    for (x = 0; 800 > x; x++)
        c.fillRect(x, 4 * iWaveHeight * Math.sin(x / 100) + iWaveHeight / 5 * Math.sin(x / 10) + 370 - iWaveHeight, 2, 370);
    iWaveHeight = 370 / 16;
    for (x = 0; 800 > x; x++)
        c.fillRect(x, 330 + aChannel2[x << 2] + aChannel1[x << 2], 2, 370)
});
