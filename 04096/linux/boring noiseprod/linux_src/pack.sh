./sstrip $1
cp gz-cargador intro
gzip -c9 $1 >> intro
chmod +x intro
ls -l intro
