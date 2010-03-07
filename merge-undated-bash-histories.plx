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

use Date::Manip;

my $startDate = ParseDate($ARGV[0]);
my $endDate   = ParseDate($ARGV[1]);

if (not defined $startDate or not defined $endDate) {
  print STDERR "usage: $0 <START_DATE> <END_DATE>\n";
  exit 1;
}
$startDate = UnixDate($startDate, "%s");
$endDate = UnixDate($endDate, "%s");

my %history;
my $cnt = 0;
while (my $cmd = <STDIN>) {
  chomp $cmd;
  $history{$cmd} = $cnt++ if not defined $history{$cmd};
}

my $interval = int(($endDate - $startDate) / (scalar keys %history));

my $secs = $startDate;
foreach my $key (sort { $history{$a} cmp $history{$b} } keys %history) {
  print "#$secs\n$key\n";
  $secs += $interval;
}
