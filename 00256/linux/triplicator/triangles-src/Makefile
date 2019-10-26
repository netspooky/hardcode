triangles-127col: triangles-127col.asm

# Alternate 80-column option
triangles-80col: triangles-80col.asm


%: %.asm
	nasm -f bin -o $@ $<
	chmod a+x $@

clean:
	-$(RM) main-80col
	-$(RM) main-127col

.PHONY: clean

