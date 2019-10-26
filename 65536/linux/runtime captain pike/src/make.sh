#!/bin/sh

echo "Making pike..."

rm -f /tmp/q.gz
gcc -o /tmp/q play.c -lm 
strip /tmp/q
gzip /tmp/q
printf "#!/bin/sh\ndd bs=1 skip=82<%c0 2>/dev/null |gunzip>k;chmod +x k;./k %c@;rm -f k;exit\n" "$" "$" > pike 
cat /tmp/q.gz >> pike 
chmod +x pike 
rm -f /tmp/q.gz /tmp/q
