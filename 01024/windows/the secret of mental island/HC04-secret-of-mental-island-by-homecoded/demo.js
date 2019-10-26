/**
 * "The Secret of Mental Island"
 * JS1K 2916 entry by Manuel Rülke / homecoded /DESiRE
 *
 * This is the actual source code used for the entry. The only change
 * I did was increasing the brightness of the background color. You can
 * find an annotated version in the file ```demo_full_variables.js```,
 * which is also part of this repository.
 *
 * The file can be compressed using closure compiler ('whitespace only')
 * and then RackPack'ed (v 4.0.1) using the following settings:
 *
 * score:       6
 * gain:        3
 * copies:      0
 * tiebreaker:  most copies first
 *
 * The file compresses down to 1024 bytes.
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

var b = [35, 37, 41, 46, 49, 55, 58, 62, 65, 73, 82, 93, 98, 110, 117, 123, 131, 139, 147, 165, 185, 196, 220, 233, 247, 262, 277, 294, 330, 370],
    d = new AudioContext,
    e = d.sampleRate,
    f = .16 * e,
    g = 0,
    h = d.createScriptProcessor(4096, 1, 2),
    k, l, m, n, p, r,
    t;

h.onaudioprocess = function(v) {
    n = v.outputBuffer.getChannelData(0);
    p = v.outputBuffer.getChannelData(1);
    for (m = 0; m < 4096; m++)
        k = b[parseInt("    o  rqom o     m  lkml   k     o    rqom o      qr   s   q  rqomqr   q   o  rqomqr   q   o  rqom o           mlkml   k                         m o i     lkjlm i     k i l m    smsrsr q o k     h i p               t r     q r qror  l             j h     f h fhd" [~~(g / f)], 35)] ? b[parseInt("    o  rqom o     m  lkml   k     o    rqom o      qr   s   q  rqomqr   q   o  rqomqr   q   o  rqom o           mlkml   k                         m o i     lkjlm i     k i l m    smsrsr q o k     h i p               t r     q r qror  l             j h     f h fhd" [~~(g / f)], 35)] : k,
        l = b[parseInt("7 fi7 f 5 d c lo9 i 9 d a   jf o7 f 7 f 5 d c lo9 i 9 i a a d m d   9 i 6 en7 f 5 d 9 b 3 b 7 fi5 dg4 cf4 c 4 cf9 i a j f   7 fi9 f d d 7 fk9 f 5 dhc             9 b d     4 dk0 2 5   7   3 1       7 8 a c         g f b 9          79 b d         i h d a         d" [~~(g / f)], 35)] ? b[parseInt("7 fi7 f 5 d c lo9 i 9 d a   jf o7 f 7 f 5 d c lo9 i 9 i a a d m d   9 i 6 en7 f 5 d 9 b 3 b 7 fi5 dg4 cf4 c 4 cf9 i a j f   7 fi9 f d d 7 fk9 f 5 dhc             9 b d     4 dk0 2 5   7   3 1       7 8 a c         g f b 9          79 b d         i h d a         d" [~~(g / f)], 35)] : l,
        n[m] = 0 < Math.sin(Math.PI * g / e * 4 * k) ? 1 : -1,
        p[m] = 0 < Math.sin(Math.PI * g / e * 4 * l) ? 1 : -1,
        g > 264 * f && (g = 0),
        g++
};
h.connect(d.destination);
a.width = 800;
a.height = 370;
setInterval(function(v) {
    v = c.createLinearGradient(0, 0, 0, 370);
    c.fillStyle = v;
    v.addColorStop(0, "#214");
    v.addColorStop(1, "#44F");
    c.fillRect(0, 0, 800, 370);
    v = c.createLinearGradient(0, 0, 0, 370);
    c.fillStyle = "#002";
    r = 370 / 6;
    for (t = 0; 800 > t; t++)
        c.fillRect(t,  4 * r * Math.sin(t / 100) + r / 5 * Math.sin(t / 10) + 370 - r, 2, r * 6);
    r = 370 / 16;
    for (t = 0; 800 > t; t++)
        c.fillRect(t, 330 + p[t<<2] + n[t<<2], 2, r * 6)
});