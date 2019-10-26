ASCFLIERS=pwpflier0-small.txt pwpflier0-big.txt
PSFLIERS=pwpflier0.ps pwpflier0b.ps pwpflier0c.ps

all: ascfliers psfliers

ascfliers: $(ASCFLIERS)

psfliers: $(PSFLIERS)

pwpflier: pwpflier.c
	cc pwpflier.c -o pwpflier

pwpflier0-small.txt: pwpflier
	./pwpflier 3 3 > pwpflier0-small.txt

pwpflier0-big.txt: pwpflier
	./pwpflier 7 5 > pwpflier0-big.txt

pwpflier0b-big.txt: pwpflier
	./pwpflier 4 3 > pwpflier0b-big.txt

pwpflier0c-big.txt: pwpflier
	./pwpflier 7 5 plasma > pwpflier0c-big.txt

pwpflier0-big2.txt: pwpflier0-big.txt
	cat pwpflier0-big.txt pwpflier0-big.txt > pwpflier0-big2.txt

pwpflier0b-big2.txt: pwpflier0b-big.txt
	cat pwpflier0b-big.txt pwpflier0b-big.txt > pwpflier0b-big2.txt

pwpflier0c-big2.txt: pwpflier0c-big.txt
	cat pwpflier0c-big.txt pwpflier0c-big.txt > pwpflier0c-big2.txt

pwpflier0.ps: pwpflier pwpflier0-big2.txt
	a2ps --prologue=bold --no-header --chars-per-line=230 \
	     --copies=4 pwpflier0-big2.txt > pwpflier0.ps

pwpflier0b.ps: pwpflier pwpflier0b-big2.txt
	a2ps --prologue=bold --no-header --chars-per-line=140 \
	     pwpflier0b-big2.txt > pwpflier0b.ps

pwpflier0c.ps: pwpflier pwpflier0c-big2.txt
	a2ps --prologue=bold --no-header --chars-per-line=230 \
	     --copies=4 pwpflier0c-big2.txt > pwpflier0c.ps

clean:
	rm -f *~ pwpflier $(ASCFLIERS) $(PSFLIERS)
