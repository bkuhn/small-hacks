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
open(THREE_DAYS, "-|", "/usr/bin/emacs -batch -l ~/.emacs -eval '(org-batch-agenda \"a\" org-agenda-files (mapcar (lambda (arg) (replace-regexp-in-string \"~/Crypt/Orgs/\" \"~/Crypt/.org-backup/\" arg)) org-agenda-files) org-agenda-span (quote 3)  org-agenda-overriding-header \"\" org-agenda-repeating-timestamp-show-all t org-agenda-time-grid nil org-agenda-repeating-timestamp-show-all t org-agenda-entry-types (quote (:sexp :scheduled)) org-agenda-skip-function (quote bkuhn/skip-unless-appt-or-diary))' 2>/dev/null") or
die "Unable to run emacs: $!";

my $firstDay = 1;
my $firstTime = 1;
my $dayLine = "";
my $prettyDayLine;
while (my $line = <THREE_DAYS>) {
  chomp $line;
  if ($line =~ /^\S/) {
    $firstDay = $firstTime;
    $firstTime = 0;
    $dayLine = $line;
    $dayLine =~ s/\s*W\d+\s*$//;
    $prettyDayLine = "\${color3}$dayLine\${color}\n";
  }
  elsif ($line =~ /^\s+(?:[^:]+)\s*:\s+(\d+)\s*:\s*(\d+)\s*[\-\.]+(.*)$/) {
    my $date =  ParseDate("$dayLine $1:$2");
    if ($firstDay) {
      my $time = "$1:$2";
      my $val = $3;
      if (DateCalc("$date", "+ 15 minutes") ge $now and
          DateCalc("$now", "+ 15 minutes") gt $date) {
        my  $fh = File::Temp->new();
        $fh->unlink_on_destroy( 1 );
        my  $fname = $fh->filename;
        print $fh "You have an appointment at $time: $val\n";
        $fh->close();
        system('/home/bkuhn/bin/myosd', $fname);
        system("/usr/bin/espeak",  '-p', '45', '-s', '130', '-f', $fname)
          unless -f "$ENV{HOME}/.silent-running";
        system('/usr/bin/notify-send', '-u', 'critical', '-t', '300000',
               'Appointment', "You have an appointment at $time: $val");
      }
    }
    next if DateCalc("$date", "+ 1 hour") lt $now;
    if (defined $prettyDayLine) {
      print $prettyDayLine;
      undef $prettyDayLine;
    }
    print "$line\n";
  }
}
###############################################################################
#
# Local variables:
# compile-command: "perl -c org-mode-appt-check.plx"
# End:

