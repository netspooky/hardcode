
tcscz: pixra.dtn

pxr-glf: pixra-galfi.c
	$(CC) -I.. -O2 -o $@ $< -lm

pixra.dtn: pxr-glf
	./$<
	gzip -cnk9 $@ > $@.gz
	@wc -c $@ $@.gz

jisygau:
	-rm *.dtn *.gz pxr-glf

.PHONY: pixra.dtn tcscz jisygau

