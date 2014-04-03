#!/usr/bin/perl
# Copyright (C) 2010, Bradley M. Kuhn
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


use strict;
use warnings;

use Mail::Header;
use Date::Manip;

#use File::Copy;

my $VERBOSE = 1;

if (@ARGV < 4 or @ARGV > 5) {
  print STDERR "usage: $0 <MAILDIR_DIRECTORY> <DSPAM_PROBABILITY_MIN> <DSPAM_CONFIDENCE_LEVEL_MIN> <DAYS> [<COUNT_ONLY_DONT_DELETE>]\n";
  exit 1;
}

my($MAILDIR_FOLDER, $DSPAM_PROB_MIN, $DSPAM_CONF_MIN, $DAYS, $COUNT_ONLY) = @ARGV;

my($total, $countDeleted, $totalInDate) = (0, 0, 0);

my $nDaysAgo = ParseDate("$DAYS days ago");

my @msgDirs = ("$MAILDIR_FOLDER/cur", "$MAILDIR_FOLDER/new");

foreach my $dir (@msgDirs) {
  die "$MAILDIR_FOLDER must not be a maildir folder (or is unreadable by you), since $dir isn't a readable directory: $!"
    unless  (-d $dir);
}
foreach my $dir (@msgDirs) {
  opendir(MAILDIR, $dir) or die "Unable to open directory $dir for reading: $!";
MAIL:  while (my $file = readdir MAILDIR) {
    next if -d $file;    # skip directories
    my $fullFileName = "$dir/$file";

    unless (open(MAIL_MESSAGE, "<", $fullFileName)) {
      print STDERR "File, $fullFileName, appears to have disappeared during processing ($!).\n    (Ignoring that fact, but counts may be off.)\n";
      next MAIL;
    }

    my $header = new Mail::Header(\*MAIL_MESSAGE);
    my $fields = $header->header_hashref;

    my $mailDate;
    foreach my $dt (@{$fields->{"Date"}}) {
      if (not defined $mailDate) {
        $mailDate = $dt;
      } else {
        $mailDate = $dt if $dt lt $mailDate;
      }
    }
    if (not defined $mailDate) {
      print STDERR "File $file has no Date: header. Skipping.\n";
      next MAIL;
    }
    my $parsedDate = ParseDate($mailDate);
    unless (defined $parsedDate) {
      print STDERR "File $file has Unparsable Date header $mailDate";
      next MAIL;
    }
    $total++;

    print "\nDate: $parsedDate" if ($VERBOSE > 2);

    next MAIL if ($parsedDate gt $nDaysAgo);
    $totalInDate++;

    print "    Not skipping over date, $nDaysAgo\n" if ($VERBOSE > 2);
    my %dspamVal;
    foreach my $val ('Confidence', 'Probability') {
      foreach my $dv (@{$fields->{"X-Dspam-$val"}}) {
        chomp $dv;
        if (not defined $dspamVal{$val}) {
          $dspamVal{$val} = $dv;
        } else {
          $dspamVal{$val} = $dv if $dv < $dspamVal{$val};
        }
      }
      if (not defined $dspamVal{$val}) {
        print STDERR "File $file has no X-Dspam-$val header. Skipping.\n";
        next MAIL;
      }
    }

    print " Confidence: $dspamVal{Confidence}, Probability: $dspamVal{Probability}\n"
      if ($VERBOSE > 2);

    if ($dspamVal{Confidence}  >= $DSPAM_CONF_MIN and
        $dspamVal{Probability} >= $DSPAM_PROB_MIN) {
      $countDeleted++;
      print "    counting this one\n" if ($VERBOSE > 2);
      unless (defined $COUNT_ONLY and $COUNT_ONLY) {
        warn "unable to unlink $fullFileName: $!"
          unless unlink("$fullFileName") == 1;
      }
    }
    close MAIL_MESSAGE;
  }
  close MAILDIR;
}

my $percent = ($countDeleted / $total) * 100.00;

print sprintf("%.2f", $percent), "% ($countDeleted/$total) ",
  ((defined $COUNT_ONLY and $COUNT_ONLY) ?
   " would be deleted.\n" :
   sprintf("were deleted.\nThis leaves %d in the folder.\n",
          $total - $countDeleted));

my $percentInDate = ($totalInDate / $total) * 100.00;

print sprintf("Of those matching the date range, %.2f", $percentInDate), "% ($countDeleted/$totalInDate) ",
  ((defined $COUNT_ONLY and $COUNT_ONLY) ?
   " would be deleted.\n" :
   sprintf("were deleted.\n"));
print sprintf("%d in the folder don't match that date range.\n",
          $total - $totalInDate);
###############################################################################
#
# Local variables:
# compile-command: "perl -c remove-spam-high-confidence-maildir.plx"
# End:
