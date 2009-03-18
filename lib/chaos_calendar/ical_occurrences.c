#include <ruby.h>
#include <libical/ical.h>
#include <time.h>

//#define RRULE   "FREQ=MONTHLY;BYMONTH=1,2,3,4,5,6,7,8,9,10,11;BYDAY=-1WE;UNTIL=20091105T220000"
//#define RRULE   "FREQ=DAILY;UNTIL=20991111T220000;VFOO"

VALUE occurrences( VALUE dtstart, VALUE dtend, char *rrule ) {
  struct icaltimetype start, end;
  time_t tt;
  VALUE  tv_sec, occurr = rb_ary_new(); 

  /* Get method ID for Time.tv_sec */
  ID time_tv_sec  = rb_intern( "tv_sec" );
  ID time_to_time = rb_intern( "to_time" );

  if( !rb_respond_to( dtstart, time_tv_sec ) ) {
    if( rb_respond_to( dtstart, time_to_time ) )
      dtstart = rb_funcall( dtstart, time_to_time, 0 );
    else
     rb_raise( rb_eTypeError, "Can't convert dtstart into a Time-like object." );
  }

  if( !rb_respond_to( dtend, time_tv_sec ) ) {
    if( rb_respond_to( dtend, time_to_time ) ) 
      dtend = rb_funcall( dtend, time_to_time, 0 );
    else
     rb_raise( rb_eTypeError, "Can't convert dtend into a Time-like object." );
  }

  /* Apply .tv_sec to our Time objects (if they are Times ...) */
  tv_sec = rb_funcall( dtstart, time_tv_sec, 0 ); 
  tt     = NUM2INT( tv_sec );
  start  = icaltime_from_timet( tt, 0 );

  tv_sec = rb_funcall( dtend, time_tv_sec, 0 );
  tt     = NUM2INT( tv_sec );
  end    = icaltime_from_timet( tt, 0 );

  icalerror_clear_errno();
  icalerror_set_error_state( ICAL_MALFORMEDDATA_ERROR, ICAL_ERROR_NONFATAL);

  struct icalrecurrencetype recur = icalrecurrencetype_from_string( rrule );
  if( icalerrno != ICAL_NO_ERROR ) {
    rb_raise(rb_eArgError, "Malformed RRule");
    return Qnil;
  }

  icalrecur_iterator* ritr = icalrecur_iterator_new( recur, start );

  while(1) {
    struct icaltimetype next = icalrecur_iterator_next(ritr);

    if( icaltime_is_null_time(next) || ( icaltime_compare( next, end ) > 0 ) ) {
      icalrecur_iterator_free(ritr);
      return occurr; 
    }

    rb_ary_push( occurr, rb_time_new( icaltime_as_timet( next ), 0 ) );
  };

  icalrecur_iterator_free(ritr);
  return occurr;
}

VALUE duration_to_fixnum( char * duration ) {
  icalerror_clear_errno();
  icalerror_set_error_state( ICAL_MALFORMEDDATA_ERROR, ICAL_ERROR_NONFATAL);

  struct icaldurationtype dur_struct = icaldurationtype_from_string( duration );

  if( icaldurationtype_is_bad_duration( dur_struct ) )
    rb_raise(rb_eArgError, "Malformed Duration");

  return LONG2FIX(icaldurationtype_as_int( dur_struct ));
}
