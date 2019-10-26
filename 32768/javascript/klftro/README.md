KLFtro by TPOLM

Demobit 2017 64k compo entry

code by ps
music by syphus/BDSE
ahx player routines by Abyss

to convert AHX file into url-encoded string you use Gasman's binhexjs.rb script to create a .js file and then copy paste it into the source code of the intro
you'll need to install ruby first,
on windows use ruby installer for ruby 2.3.3
http://railsinstaller.org/en

then you'll be able to run 
`ruby binhexjs.rb original_assets\3ameternal.ahx >> AHXdump.js`
or simply call `binhexjs.bat`

test stuff launching index.html

to compile the javascript with closure compiler you should write this on the console
`java -jar compiler.jar --compilation_level ADVANCED_OPTIMIZATIONS --js jetski.js --externs closure_audiocontext.js --externs closure_ctxhash.js --js_output_file=jetski_closure.js`
or simply call `compile.bat`

to convert it to .png self extractable you should write this on the console
`ruby pnginator.rb jetski_closure.js jetski.png.html`
or simply call `pngify.bat`

to launch the png.html you need local webserver running or it'll complain of cross address bullshit (`python -m SimpleHTTPServer` or http-serve from npm will do) 