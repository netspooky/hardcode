Handle:
                Laos

Name:
                Tu Lam

Email Address:
                uflaos@hotmail.com

Comments:
                Hairy "nut" as in the circular thing that fits around a bolt.

Requirements:
                You need a VRML browser to view this.  (If you didn't know,
                VRML is an ISO standard to represent 3D and was designed to
                work on the web.)  Download one here:

                        http://www.blaxxun.com/download/

                For those who want to see a screen shot first, look at
                screenshot.jpg.

Testing Machine:
                IE6 with blaxxun Contact 5.1; 1.0 GHz Pentium III; 
                256 MB RAM; GeForce2; Windows 2000

Source Code:
                The final file is a gzipped ASCII file.  You can use WinZip
                to look at the source.  Or here it is as well:

                #
                Script{url"vrmlscript:function initialize(){s='Viewpoint{
                orientation 0 1 0 .5}';for(i=0;i<5;i+=.8)for(j=0;j<6.2;
                j+=.1)s+='Transform{translation '+(10*Math.cos(j)-20)+' '+
                10*Math.sin(j)+' '+(2*i-32)+' scale 1 5 1 rotation 0 0 1 '+
                (j-1.57)+' children Cone{}}';b=Browser;b.replaceWorld(
                b.createVrmlFromString(s));}"}
