./sstrip $1
cp bz2-cargador bzplay
bzip2 -c9 $1 >> bzplay
chmod +x bzplay
ls -l bzplay
