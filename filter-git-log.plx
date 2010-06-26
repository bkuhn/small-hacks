#!/usr/bin/perl
# filter-git-log.plx

#  I wrote this script to filter the output of git log -p to find patches
#   that occured on certain dates.  It could probably be adapted to filter
#   other git log output.

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

if (@ARGV < 2 or @ARGV > 3) {
  print STDERR "usage: $0 <GIT_COMMAND_STRING> <DATE_RANGE_CODE_FILE> [<SKIP_AUTHOR_REGEX>]\n";
  exit 1;
}
my($GIT_CMD, $DATE_RANGE_CODE_FILE, $SKIP_AUTHOR_REGEX) = @ARGV;

# DATE_RANGE_CODE_FILE must define a one-arg function called DateIsInRange()
require "$DATE_RANGE_CODE_FILE";

$GIT_CMD .= " --no-color";

open(GIT_OUTPUT, "-|", $GIT_CMD) or die "unable to run \"$GIT_CMD\": $!";

my $currentCommit = "";
my $skipThisOne = 1;
while (my $line = <GIT_OUTPUT>) {
  if ($line =~ /^\s*commit\s+([\dA-F]+)\s*$/i) {
    print $currentCommit unless $skipThisOne;
    $skipThisOne = 0;
    $currentCommit = "";
  } elsif ($line =~ /^\s*Date\s*:\s*(.+)$/i) {
    $skipThisOne = not DateIsInRange($1) if not $skipThisOne;
  } elsif ($line =~ /^\s*Author\s*:\s*(.+)$/i) {
    my $author = $1;
    $skipThisOne = 1 if $author =~ /$SKIP_AUTHOR_REGEX/;
  }
  $currentCommit .= $line;
}
print $currentCommit unless $skipThisOne;
close GIT_OUTPUT;
die "non-zero exit code on \"$GIT_CMD\": $!" unless $? == 0;
###############################################################################
# Local variables:
# compile-command: "perl -c filter-git-log.plx"
# End:
