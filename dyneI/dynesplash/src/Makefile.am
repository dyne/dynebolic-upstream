## Process this file with automake to produce Makefile.in

INCLUDES = \
	-I$(top_srcdir)/intl \
	@GTK_CFLAGS@

bin_PROGRAMS = splash

splash_SOURCES = \
	main.c \
	support.c support.h \
	interface.c interface.h \
	callbacks.c callbacks.h \
	jutils.c jutils.h

splash_LDADD = @GTK_LIBS@ 

# DEACTIVATED internationalization with gettext:
# removed $(INTLLIBS) from splash_LDADD

