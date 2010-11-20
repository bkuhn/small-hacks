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
#use File::Copy;

if (@ARGV < 3) {
  print STDERR "usage: $0 <MAILDIR_DIRECTORY> <DSPAM_PROBABILITY_MIN> <DSPAM_CONFIDENCE_LEVEL_MIN>\n";
  exit 1;
}

my($MAILDIR_FOLDER, $DSPAM_PROB_MIN, $DSPAM_CONF_MIN) = @ARGV;

my($total, $countDeleted) = (0, 0);

my @msgDirs = ("$MAILDIR_FOLDER/cur", "$MAILDIR_FOLDER/new");

foreach my $dir (@msgDirs) {
  die "$MAILDIR_FOLDER must not be a maildir folder (or is unreadable by you), since $dir isn't a readable directory: $!"
    unless  (-d $dir);
}
MAIL: foreach my $dir (@msgDirs) {
  opendir(MAILDIR, $dir) or die "Unable to open directory $dir for reading: $!";
  while (my $file = readdir MAILDIR) {
    next if -d $file;    # skip directories
    my $existing_file = "$dir/$file";
    open(MAIL_MESSAGE, "<", $existing_file) or
      die "unable to open $existing_file for reading: $!";

    my $header = new Mail::Header(\*MAIL_MESSAGE);
    my $fields = $header->header_hashref;

    my %dspamVal;
    foreach my $val ('Confidence', 'Probability') {
      foreach my $dv (@{$fields->{"X-Dspam-$val"}}) {
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
    $total++;

    if ($dspamVal{Confidence}  >= $DSPAM_PROB_MIN and
        $dspamVal{Probability} >= $DSPAM_CONF_MIN) {
      $countDeleted++;
    }
    close MAIL_MESSAGE;
  }
  close MAILDIR;
}

print "$countDeleted of $total would be deleted\n";

###############################################################################
#
# Local variables:
# compile-command: "perl -c remove-spam-high-confidence-maildir.plx"
# End:
