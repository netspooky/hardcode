./sstrip $1
cp gz-cargador $2
gzip -c9 $1 >> $2
chmod +x $2
ls -l $2
