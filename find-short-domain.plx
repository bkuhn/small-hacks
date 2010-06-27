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

use Net::WhoisNG;

if (@ARGV != 2) {
  print STDERR "usage: $0 <TLD> <CACHE_FILE>\n";
}
my($TLD, $CACHE_FILE) = @ARGV;

my %cache;

open(CACHE, "<", $CACHE_FILE) or die "Unable to open $CACHE_FILE for reading: $!";

while (my $line = <CACHE>) {
  chomp $line;
  die "maleformed line, \"$line\" in $CACHE_FILE"
    unless $line =~ /^\s*(\S+)\s*\:\s*((?:available|expires:\s*\S+))/;
  $cache{$1} = $2;
}

foreach my $let1 ('a' .. 'z', '0' .. '9') {
  foreach my $let2 ('a' .. 'z', '0' .. '9', '-') {
    foreach my $let3 ('a' .. 'z', '0' .. '9') {
      my $domain = "$let1$let2$let3" . "." . $TLD;
      next if defined $cache{$domain};

      my $w = new Net::WhoisNG($domain);
      if(!$w->lookUp()){
        print "$domain is not in use\n";
      } else {
        my $exp_date=$w->getExpirationDate();
        if (not defined $exp_date) {
          print "$domain: available\n";
        }
        else {
          print "$domain: expires: $exp_date\n";
        }
      }
    }
  }
}
