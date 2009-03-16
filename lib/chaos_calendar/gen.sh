#!/bin/sh

rm -f Makefile *.o *wrap.c*
swig -ruby ical_occurrences.i
ruby extconf.rb
make
