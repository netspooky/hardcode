PROD=yo03

release: $(PROD)

batch:
	PW=640 PH=480	make releaseWH
	PW=800 PH=600	make releaseWH
	PW=1024	PH=768	make releaseWH
	PW=1280 PH=720	make releaseWH
	PW=1280 PH=800	make releaseWH
	PW=1600 PH=1200	make releaseWH
	PW=1920 PH=1080	make releaseWH

releaseWH: $(PROD)_$(PW)x$(PH)

clean: $(PROD)
	rm $(PROD) 

$(PROD): $(PROD).asm
	nasm -f bin $(PROD).asm -o $(PROD)
	chmod +x $(PROD)
	wc -c $(PROD)

$(PROD)_$(PW)x$(PH): $(PROD).asm
	nasm -f bin $(PROD).asm -DW=$(PW) -DH=$(PH) -o $(PROD)_$(PW)x$(PH)
	chmod +x $(PROD)_$(PW)x$(PH)
	wc -c $(PROD)_$(PW)x$(PH)
