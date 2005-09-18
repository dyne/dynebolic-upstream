# why not autoconf/automake here?
# i love simplicity

CC = gcc
CPP = g++
CFLAGS = -g -DDEBUG -pipe -Wall -O2 -ffast-math
INSTALL = install -c
PREFIX = /usr
DATADIR = $(PREFIX)/share/dynebolic/splash
INCLUDE = -I. `pkg-config --cflags gtk+-2.0 libglade-2.0`
LIBS = `pkg-config --libs gtk+-2.0 libglade-2.0`
OBJS = dynesplash.o
all: dynesplash

dynesplash: $(OBJS)
	$(CPP) -o dynesplash $(CFLAGS) $(OBJS) $(LIBS)

translation:
	xgettext -a trans.c
	msginit -i messages.po

%.o: %.cpp
	$(CPP) $(INCLUDE) $(CFLAGS) -c -o $@ $<

install: all
	$(INSTALL) -s dynesplash $(PREFIX)/bin
	$(INSTALL) dynesplash.glade $(DATADIR)
	$(INSTALL) pixmaps/* $(DATADIR)


clean:
	rm -f dynesplash *.o *.bak *~

