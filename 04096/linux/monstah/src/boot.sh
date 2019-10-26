tail -n+4 $0|zcat>o
chmod +x o
./o>/dev/dsp
