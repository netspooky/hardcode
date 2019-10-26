# The top-level input Makefile for SDL

# require automake 1.4
AUTOMAKE_OPTIONS = 1.4

## Any directories that you want built and installed should go here.
SUBDIRS = src

## Any directories you want a part of the distribution should be listed
## here, as well as have a Makefile generated at the end of configure.in
##
## This only works for subdirectories one level deep.
DIST_SUBDIRS = $(SUBDIRS)


# All the rest of the distributed files
EXTRA_DIST =		\
	autogen.sh	\
	dist.sh

# Rule to build tar-gzipped distribution package
$(PACKAGE)-$(VERSION).tar.gz: dist

# Rule to build RPM distribution package
rpm: $(PACKAGE)-$(VERSION).tar.gz
	rpm -ta $(PACKAGE)-$(VERSION).tar.gz
	
zip: $(PACKAGE)-$(VERSION).tar.gz
	zip -9 $(PACKAGE)-$(VERSION).zip *
	
