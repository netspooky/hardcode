#7z a -tGZip -mx=9 stream2.c.gz stream2.c
cp stream2.c perkele.c
gzip -9 --no-name perkele.c
cat unpack.header2 perkele.c.gz > stream2
chmod a+x stream2
rm perkele.c.gz
wc -c stream2
