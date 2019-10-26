Handle:
                Laos

Name:
                Tu Lam

Email Address:
                uflaos@hotmail.com

Comments:
                This scene reminds me of what a flea would see jumping on top
                of a dog.  8)

Requirements:
                You need a VRML browser to view this.  (If you didn't know,
                VRML is an ISO standard to represent 3D and was designed to
                work on the web.)  Download one here:

                        http://www.blaxxun.com/download/

                For those who want to see a screen shot first, look at
                screenshot.jpg.  If you see all white, you may need to unzip
                Laos-Flea's_Perspective.zip to a directory first.

Testing Machine:
                IE6 with blaxxun Contact 5.1; 1.0 GHz Pentium III; 
                256 MB RAM; GeForce2; Windows 2000

Source Code:
                The final file is a gzipped ASCII file.  You can use WinZip
                to look at the source.  Or here it is as well:

                #
                Script{url"vrmlscript:function initialize() {s='';for(i=0;
                i<40;i++)for(j=1;j<30;j++)s+='Transform{translation '+2*i
                +' '+2*j+' 0 rotation 0 '+i/j+' 1 '+(3*(i/20+j/47))+
                ' children Cone{height 16}}';s+=
                'Viewpoint{position 32 16 31 orientation 1 -.2 .1 .4}';
                Browser.replaceWorld(Browser.createVrmlFromString(s));}"}
