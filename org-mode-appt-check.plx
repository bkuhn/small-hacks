#!/usr/bin/perl
# org-mode-appt-check.plx
#
# Copyright (C) 2013, Bradley M. Kuhn
#
# This program gives you software freedom; you can copy, modify, convey,
# and/or redistribute it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program in a file called 'GPLv3'.  If not, write to the:
#    Free Software Foundation, Inc., 51 Franklin St, Fifth Floor
#                                    Boston, MA 02110-1301, USA.
#
# I needed a quick script to parse the output of emacs script.


use strict;
use warnings;
use Date::Manip;
use File::Temp ();

if (not -d "$ENV{HOME}/Crypt/Orgs") {
  print "\${color5}Crypt Directory Not Mounted!\n";
  exit 0;
}
system("/usr/bin/rsync -q -Havz $ENV{HOME}/Crypt/Orgs/*.org $ENV{HOME}/Crypt/.org-backup/");
if ($? != 0) {
  print "\${color5}rsync failed for Org Backup!\n";
  exit 0;
}
my $now =  ParseDate("now");
open(ORG_MODE_AGENDA, "-|", "/usr/bin/emacs -batch -l ~/.emacs -eval '(org-batch-agenda \"a\" org-agenda-files (mapcar (lambda (arg) (replace-regexp-in-string \"~/Crypt/Orgs/\" \"~/Crypt/.org-backup/\" arg)) org-agenda-files) org-agenda-span (quote 10)  org-agenda-overriding-header \"\" org-agenda-repeating-timestamp-show-all t org-agenda-time-grid nil org-agenda-repeating-timestamp-show-all t org-agenda-entry-types (quote (:sexp :scheduled)))' 2>/dev/null") or
die "Unable to run emacs: $!";

my $firstDay;
my $dayLine = "";
my $prettyDayLine;

while (my $line = <ORG_MODE_AGENDA>) {
  next if ($line =~ /^\a/);   # Skip line of bells
  my $thisLinePrintable;
  chomp $line;
  if ($line =~ /^\S+/) {
    $firstDay =  (not defined $firstDay) ? 1 : 0;
    $dayLine = $line;
    $dayLine =~ s/\s*W\d+\s*$//;
    $prettyDayLine = "\${color3}$dayLine\${color}\n";
  }
  elsif ($line =~ /^\s+([^:]+)\s*:\s*(\d+)\s*:\s*(\d+)\s*[\-\.]+(?:\s*(\d+)\s*:\s*(\d+))?(.*)$/) {
    my($source, $startHour, $startMin, $endHour, $endMin, $rest) =
      ($1, $2, $3, $4, $5, $6);
    next if $rest =~ /Sched.*\d+x\s*:/;  # Skip overdue TODOs, because I have lot.
    $rest =~ s/\[\s*\#\s*\S+\s*\]//g;   # Remove priority tags
    my $type;
    if ($rest =~ s/^\s*Scheduled?\s*:\s*(WAITING|TODO|APPT|DELEGATED|DONE|DEFFERRED|CANCELLED|STARTED)\s*//i) {
      $type = $1;
    } else {
      $type = $source;
    }
    next if $type =~ /(DELEGATED|DONE|DEFFERRED|CANCELLED)/i;

    $startHour = "0$startHour" if length($startHour) == 1;
    my $start = "$startHour:$startMin";
    my $date =  ParseDate("$dayLine $start");
    my($endDate, $end);
    if (not defined $endHour) {
      $endDate = DateCalc($date, "+ 8 hour");
      $end = "";
    } else {
      $endMin = "00" if (not defined $endMin);
      $end = "$endHour:$endMin";
      $endDate = ParseDate("$dayLine $end");
      $end = "-$end";
    }
    # Diaries and appointments are always printed, and have notifier.
    if ($source =~ /(Diary|APPT)/i or $type =~ /(Diary|APPT)/i) {
      $thisLinePrintable = "    $start$end  $rest\${alignr 10} ($source)"
        if ($endDate gt $now);
      # At this point, we'd hope we'd hit a "\S+" line, which would indicate
      # that there's a date in this output, as they start at column 0 on the
      # output.  However, if we happen to find something odd in the output,
      # just treat it like an Appointment without a known date.
      if (not defined $firstDay) {
        print "Appointment, on an Unknown Date:\n"
          if $thisLinePrintable;
      } elsif ($firstDay) {
        my $val = $3;
        if (DateCalc("$now", "+ 15 minutes") ge $date and $now le $date) {
          my  $fh = File::Temp->new();
          $fh->unlink_on_destroy( 1 );
          my  $fname = $fh->filename;
          print $fh "You have an appointment at $start: $rest\n";
          $fh->close();
          system('/home/bkuhn/bin/myosd', $fname);
          system("/home/bkuhn/bin/myspeakbyfile", $fname)
            unless -f "$ENV{HOME}/.silent-running";
          system('/usr/bin/notify-send', '-u', 'critical', '-t', '300000',
                 'Appointment', "You have an appointment at $start: $rest");
        }
      }
    } else {  # Source isn't a diary or appointment
      $thisLinePrintable = "    $start$end  $rest\${alignr 10}($type, $source)"
        if (($endDate gt $now) and
            ($firstDay or $type   =~ /(birthday|anniversary)/i
                       or $source =~ /(birthday|anniversary)/i));
    }
  }
  if (defined $thisLinePrintable) {
    if (defined $prettyDayLine) {
      print $prettyDayLine;
      undef $prettyDayLine;
    }
    print $thisLinePrintable, "\n";
  }
}
close ORG_MODE_AGENDA;
die "Error($?) reading org mode output: $!" unless $? == 0;
exit 0;
###############################################################################
#
# Local variables:
# compile-command: "perl -c org-mode-appt-check.plx"
# End:

