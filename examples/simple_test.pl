#!/usr/bin/perl -W
use strict;
use Carp;
use POE;
use Curses::Visterm;

my $vt = Curses::Visterm->new( Alias => "interface",
                                        Errlevel => 0 );

my $window_id = $vt->create_window(
       Window_Name => "window_one",

       Palette => { mycolor       => "magenta on black",
                    statcolor     => "green on black",
                    sockcolor     => "cyan on black",
                    ncolor        => "white on black",
                    st_frames     => "bright cyan on blue",
                    st_values     => "bright white on blue",
                    stderr_bullet => "bright white on red",
                    stderr_text   => "bright yellow on black",
                    err_input     => "bright white on red",
                    help          => "white on black",
                    help_cmd      => "bright white on black" },

       Status => { 0 =>
                   { format => "\0(st_frames)" .
                               " [" .
                               "\0(st_values)" .
                               "%8.8s" .
                               "\0(st_frames)" .
                               "] " .
                               "\0(st_values)" .
                               "%s",
                     fields => [qw( time name )] },
#                   1 =>
#                   { format => "template for status line 2",
#                     fields => [ qw( foo bar ) ] },
                 },

       Buffer_Size => 1000,
       History_Size => 50,

       Title => "Title of window_one"  );

POE::Session->create
  (inline_states =>
    { _start         => \&start_guts,
      got_term_input => \&handle_term_input,
      update_time    => \&update_time,
      update_name    => \&update_name,
      test_buffer    => \&test_buffer,
    }
  );

$vt->print($window_id, "My Window ID is $window_id");

## Initialize the back-end guts of the "client".

sub start_guts {
  my ($kernel, $heap) = @_[KERNEL, HEAP];

  # Tell the terminal to send me input as "got_term_input".
  $kernel->post( interface => send_me_input => "got_term_input" );

  # Start updating the time.
  $kernel->yield( "update_time" );
  $kernel->yield( "update_name" );
#  $kernel->yield( "test_buffer" );
}

### The main input handler for this program.  This would be supplied
### by the guts of the client program.

sub handle_term_input {
#  beep();
  my ($kernel, $heap, $input, $exception) = @_[KERNEL, HEAP, ARG0, ARG1];

  # Got an exception.  These are interrupt (^C) or quit (^\).
  if (defined $exception) {
    warn "got exception: $exception";
    exit;
  }
  $vt->print($window_id, $input);
}

### Update the time on the status bar.

sub update_time {
  my ($kernel, $heap) = @_[KERNEL, HEAP];

  # New time format.
  use POSIX qw(strftime);
  $vt->set_status_field( $window_id, time => strftime("%I:%M %p", localtime) );

  # Schedule another time update for the next minute.  This is more
  # accurate than using delay() because it schedules the update at the
  # beginning of the minute.
  $kernel->alarm( update_time => int(time() / 60) * 60 + 60 );
}

sub update_name {
  my ($kernel, $heap) = @_[KERNEL, HEAP];
  my $window_name = $vt->get_window_name($window_id);
  $vt->set_status_field( $window_id, name => $window_name );
}

my $i = 0;
sub test_buffer {
   my ($kernel, $heap) = @_[KERNEL, HEAP];
  $i++;
  $vt->print($window_id, $i);
  $kernel->alarm( test_buffer => int(time() / 60) * 60 + 20 ); 
}

$poe_kernel->run();
$vt->delete_window($window_id);
exit 0;
