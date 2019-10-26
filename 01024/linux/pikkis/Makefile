# Pikkis by zipola
TARGET = pikkis

all: $(TARGET)

pikkis:
	7z a -tgzip -mx=9 $(TARGET).gz $(TARGET).py
	cat unpack.header $(TARGET).gz > $(TARGET)
	chmod a+x $(TARGET)
	rm $(TARGET).gz

run:
	./$(TARGET)

clean: 
	rm $(TARGET)

