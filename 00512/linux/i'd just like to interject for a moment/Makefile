
BIN=bin
OBJ=obj
INC=inc
SRC=src

tcscz: romei

pxr/pixra.dtn: pxr/pixra-galfi.c
	$(MAKE) -C pxr

$(BIN)/fbq: $(SRC)/fbq.c
	$(CC) -O2 -o $@ $<

romei: $(OBJ)/fss-zei-zbasu.exe $(BIN)/fbq pxr/pixra.dtn \
        $(BIN)/proga $(SRC)/alsa-terzba.sh $(SRC)/oss-zei-terzba.sh $(SRC)/stdout-zei-terzba.sh
	mono $< $(SRC)/alsa-terzba.sh       $(OBJ)/proga.lzma $(BIN)/fss-alsa
	mono $< $(SRC)/oss-zei-terzba.sh    $(OBJ)/proga.lzma $(BIN)/fss-oss
	mono $< $(SRC)/stdout-zei-terzba.sh $(OBJ)/proga.lzma $(BIN)/fss-stdout
	chmod +x $(BIN)/fss-*
	@wc -c $(BIN)/fss-* | sort

$(OBJ)/fss-zei-zbasu.exe: $(SRC)/fss-zei-zbasu.cs
	mcs -out:$@ -checked- -debug- -optimize -t:exe $<

$(BIN)/proga: $(SRC)/samselpla.asm \
        $(INC)/tamselgau.asm $(INC)/elf.asm $(INC)/datni.asm \
        $(SRC)/zgike.asm $(SRC)/samxra.asm
	nasm -I "$(INC)/" -I "$(SRC)/" -I "pxr/" -f bin -o $@ $<
	chmod +x $@
	xz --format=lzma -9 --extreme --lzma1=preset=9,lc=1,lp=0,pb=0 --keep --stdout bin/proga > obj/proga.lzma
	@#gzip -ckn9 $@ > $(OBJ)/proga.gz
	@#7z a -tGZip -mx=9 $@ > $(OBJ)/proga.gz
	@wc -c $(BIN)/proga $(OBJ)/proga.lzma | sort

jisygau:
	$(MAKE) -C pxr jisygau
	rm -f $(BIN)/* $(OBJ)/* ./j

.PHONY: romei jisygau

