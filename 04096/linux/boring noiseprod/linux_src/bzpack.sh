./sstrip $1
cp bz2-cargador bzintro
bzip2 -c9 $1 >> bzintro
chmod +x bzintro
ls -l bzintro
