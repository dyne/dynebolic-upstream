# why not autoconf/automake here?
# i love simplicity

CC = gcc
CPP = g++
CFLAGS = -ggdb -DDEBUG -pipe -Wall -O2 -ffast-math `pkg-config --cflags gtk+-2.0`

INSTALL = install -c
PREFIX = /usr
LIBS = `pkg-config --libs gtk+-2.0`
OBJS = main.o support.o	interface.o callbacks.o

all: netconf

netconf: $(OBJS)
	$(CPP) -o netconf $(CFLAGS) $(OBJS) $(LIBS)

clean:
	rm -f *.o *~ netconf

%.o: %.c
	$(CPP) $(INCLUDE) $(CFLAGS) -c -o $@ $<
