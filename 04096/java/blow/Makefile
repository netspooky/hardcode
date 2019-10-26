
M4:=m4
JAR:=jar
JAVAC:=javac -O

GENERATED_SOURCE:=main.java
CLASSES:=main.class
JARFILE:=blow.jar

all: $(JARFILE)


$(JARFILE): $(CLASSES)
	$(JAR) -cf $@ $+
	@echo jarfile is: `ls -l $@ | awk '{print $$5}'` bytes
	@echo classes are: `ls -l $< | awk '{print $$5}'` bytes

main.java: Bloobs.java.m4 Blur.java.m4 Fade.java.m4 blow.m4 main.java.m4 Lookup.java.m4 Logo.java.m4 Text.java.m4 Julia.java.m4 Colorize.java.m4


%.class:%.java
	$(JAVAC) $<

%.java:%.java.m4
	$(M4) $< >$@

clean:
	rm -f $(JARFILE) $(CLASSES) $(GENERATED_SOURCE) *~

