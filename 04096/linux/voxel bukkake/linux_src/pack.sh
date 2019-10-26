./sstrip $1
cp gz-cargador gzplay
gzip -c9 $1 >> gzplay
chmod +x gzplay
ls -l gzplay
