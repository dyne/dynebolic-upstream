# why not autoconf/automake here?
# i love simplicity

CC = gcc
CPP = g++
CFLAGS = -g -DDEBUG -pipe -Wall -O2 -ffast-math
INSTALL = install -c
PREFIX = /usr
DATADIR = $(PREFIX)/share/dynebolic/taschino
INCLUDE = -I. `pkg-config --cflags gtk+-2.0 libglade-2.0`
LIBS = `pkg-config --libs gtk+-2.0 libglade-2.0`
OBJS = taschino.o nest.o parts.o results.o
all: taschino

taschino: $(OBJS)
	$(CPP) -o taschino $(CFLAGS) $(OBJS) $(LIBS)

translation:
	xgettext -a translatable.c
	msginit -i messages.po

%.o: %.cpp
	$(CPP) $(INCLUDE) $(CFLAGS) -c -o $@ $<

install: all
	$(INSTALL) -s taschino $(PREFIX)/bin
	$(INSTALL) nidifica $(DATADIR)
	$(INSTALL) taschino.glade $(DATADIR)
	$(INSTALL) pixmaps/* $(DATADIR)


clean:
	rm -f taschino *.o *.bak *~

