
CONFIG -= qt
CONFIG += c++11


DEFINES += eRELEASE ePLAYER
#LIBS += -lsfml-audio -lsfml-graphics -lsfml-window -lsfml-system
#LIBS += -L.. -lrtaudio_static -lpulse -lpulse-simple -lpthread -lsfml-graphics -lsfml-window -lsfml-system -lGL -lGLU -lX11
LIBS += -L.. -lrtaudio_static -lpulse -lpulse-simple -lpthread -lGL -lGLU -lX11
SOURCES +=  \
    array.cpp \
    cameras.cpp \
    datastream.cpp \
    frameworks.cpp \
    music.cpp \
    random.cpp \
    runtime.cpp \
    scenes.cpp \
    sequences.cpp \
    simd.cpp \
    tf4.cpp \
    tf4fx.cpp \
    main.cpp \
    window.cpp \
    vec3.cpp \
    fbo.cpp \
    texture.cpp

HEADERS += \
    array.hpp \
    cameras.hpp \
    datastream.hpp \
    frameworks.hpp \
    music.hpp \
    random.hpp \
    runtime.hpp \
    scenes.hpp \
    sequences.hpp \
    simd.hpp \
    system.hpp \
    tf4.hpp \
    tf4fx.hpp \
    types.hpp \
    RtAudio.h \
    window.hpp \
    vec3.hpp \
    fbo.hpp \
    texture.hpp

