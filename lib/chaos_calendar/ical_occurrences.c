#include <ruby.h>
#include <ical.h>

//#define RRULE   "FREQ=MONTHLY;BYMONTH=1,2,3,4,5,6,7,8,9,10,11;BYDAY=-1WE;UNTIL=20091105T220000"
//#define RRULE   "FREQ=DAILY;UNTIL=20991111T220000;VFOO"
//#define DTSTART "20000101T010000"

VALUE occurrences( char *dtstart, char *dtend, char *rrule ) {
  VALUE occurr = rb_ary_new();  

  icalerror_clear_errno();
  icalerror_set_error_state( ICAL_MALFORMEDDATA_ERROR, ICAL_ERROR_NONFATAL);

  struct icalrecurrencetype recur = icalrecurrencetype_from_string( rrule );
  if( icalerrno != ICAL_NO_ERROR ) {
    printf( "libical error: %i. -- 1\n", icalerrno );
    return occurr;
  }
  struct icaltimetype start = icaltime_from_string( dtstart );
  if( icalerrno != ICAL_NO_ERROR ) {
    printf( "libical error: %i. -- 2\n", icalerrno );
    return occurr;
  }
  struct icaltimetype end   = icaltime_from_string( dtend );
  if( icalerrno != ICAL_NO_ERROR ) {
    printf( "libical error: %i. -- 3\n", icalerrno );
    return occurr;
  }

  icalrecur_iterator* ritr = icalrecur_iterator_new( recur, start );

  while(1) {
//    char outbuf[1024] = {0};
    struct icaltimetype next = icalrecur_iterator_next(ritr);

    if( icaltime_is_null_time(next) || ( icaltime_compare( next, end ) > 0 ) ) {
      icalrecur_iterator_free(ritr);
      return occurr; 
    }

    rb_ary_push( occurr, rb_time_new( icaltime_as_timet( next ), 0 ) );
//    print_datetime_to_string( outbuf, &next );
//    rb_ary_push( occurr, rb_str_new2( outbuf ) );
  };

  icalrecur_iterator_free(ritr);
  return occurr;
}
