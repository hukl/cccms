#!/bin/sh

rm -f Makefile *.o *wrap.c*
swig -ruby chaos_calendar.i
ruby extconf.rb
make
