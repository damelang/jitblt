# TODO generalize this into a proper Makefile.am

# The order of these files matters
JITBLT_SOURCES = \
  super.k \
	uchar.k \
	map.k \
	expression.k \
  operator.k \
  pixel-format.k \
	pixman.k \
  jitblt-compile.k

all: pixman-jitblt.o

pixman-jitblt.o: jitblt-sources.h pixman-jitblt.h pixman-jitblt.c jitblt-params.h
	gcc -g -c -I.. -I../pixman pixman-jitblt.c

# This target bundles all the jitblt code into a C string named
# "jitblt_sources" and puts it in a file called jitblt-sources.h
jitblt-sources.h: $(JITBLT_SOURCES)
	cat $(JITBLT_SOURCES) | \
		grep -Ev '^(;|$$)' | \
		sed -e 's/";/"/g' -e 's/;.*$$//' -e 's/\\/\\\\/g' -e 's/"/\\"/g' | \
		awk '{print "\"", $$0, "\""}' | \
		awk 'BEGIN {RS = "\7"} \
			{print "static const char jitblt_sources[] = \n", $$0, ";"}' \
		> $@

clean:
	rm -rf jitblt-sources.h pixman-jitblt.o

distclean: clean

install:
