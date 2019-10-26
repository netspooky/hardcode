TEMPLATE = app

CONFIG -= exceptions \
stl \
qt \
CONFIG += warn_off
DESTDIR = /home/gilesc/svn/mapprox/bin

INCLUDEPATH += ../libmapprox

LIBS += ../lib/libmapprox.a \
  -lSDL

TARGETDEPS += ../lib/libmapprox.a

HEADERS += Main.h

SOURCES += Main.cpp

TARGET = demo

CONFIG+= warn_off
QMAKE_CXXFLAGS_RELEASE += -Os \
  -Wall \
  -Werror \
  -Wno-unused-parameter \
  -pedantic \
-Wl,--print-gc-sections -ffast-math -DBLKSIZE=1024 -s -Os -g0 -nostdlib -fno-access-control -fconserve-space -fno-rtti -fno-threadsafe-statics -fno-nonansi-builtins -fno-enforce-eh-specs -fmerge-all-constants -fsingle-precision-constant

QMAKE_CXXFLAGS_DEBUG += -Os \
  -Wall \
  -Werror \
  -Wno-unused-parameter \
  -pedantic \
-Wl,--print-gc-sections -ffast-math -DBLKSIZE=1024 -s -Os -g0 -nostdlib -fno-access-control -fconserve-space -fno-rtti -fno-threadsafe-statics -fno-nonansi-builtins -fno-enforce-eh-specs -fmerge-all-constants -fsingle-precision-constant

