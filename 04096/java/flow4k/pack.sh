#!/bin/sh
rm -rf release
mkdir release

pushd bin
../tools/kzip.exe /r ../release/tmp.jar *
popd

java -jar tools/proguard/lib/proguard.jar @script.pro

mkdir tmp
pushd tmp
unzip ../release/tmp2.jar
../tools/kzip.exe /r ../release/Flow4k.jar *.class
popd
rm -rf tmp

rm release/tmp.jar release/tmp2.jar

echo '<applet archive="Flow4k.jar" code="Main" width="256" height="288">Flow 4k Java applet (please enable Java applets for your browser)</applet>' > release/game.html
