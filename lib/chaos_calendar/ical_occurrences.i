%module ical_occurrences

%inline {
  VALUE occurrences( char * dtstart, char * dtend, char * rrule );
}

