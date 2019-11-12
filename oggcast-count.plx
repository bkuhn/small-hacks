#!/usr/bin/perl
# Copyright (C) 2011, 2019 Bradley M. Kuhn
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

my %data;

my $overallTotal = 0;

while (<>) {
  chomp;
  next unless /^(\S+)\s+[^"]+"\s*(GET)\s+(\S+)[\s"]/;
#  die "invalid line: $_"
#    unless /^(\S+)\s+[^"]+"\s*(LOCK|HEAD|GET|POST|OPTIONS|PUT|CONNECT|PROPFIND)\s+(\S+)[\s"]/;
  my($ip, $method, $url) = ($1, $2, $3);
  next unless $method =~ /^\s*GET\s*$/i;

  next unless $url =~ s/\s*\.(ogg|mp3)\s*$/.audio/i;   # Treat ogg and mp3 downloads same, and only count those.
  $url =~ s/\s*\/$$//;   # Always remove trailing slash 
  if (not defined $data{$url}{$ip} ) {
     $data{$url}{$ip} = 0;
     $data{$url}{__TOTAL_UNIQUE_IP__} = 0 unless
        defined $data{$url}{__TOTAL_UNIQUE_IP__};
     $data{$url}{__TOTAL_UNIQUE_IP__}++;
  }
  $data{$url}{__TOTAL__} = 0 unless defined $data{$url}{__TOTAL__};
  $data{$url}{$ip}++;
  $data{$url}{__TOTAL__}++;
}

foreach my $url (sort { $data{$b}{__TOTAL_UNIQUE_IP__} <=> $data{$a}{__TOTAL_UNIQUE_IP__}}
                 keys %data) {
  print "$url: Unique: $data{$url}{__TOTAL_UNIQUE_IP__} With Dups: $data{$url}{__TOTAL__}\n";
   print "    Top Few IPs: ";
   my(@ll) = map { $_->[0] }
       sort { $b->[1] <=> $a->[1]  or $b->[0] cmp $a->[0] }
       map { [ $_, $data{$url}{$_} ] } keys %{$data{$url}};
   my $cnt = 0;
   foreach my $ip (@ll) {
     next if $ip =~ /^__/;
     last if $cnt++ > 5;
     print ", " if $cnt > 1;
     print "$ip"
   }
   print "\n";
  $overallTotal +=  $data{$url}{__TOTAL_UNIQUE_IP__} if $url =~ /\.audio/;
}
print "TOTAL AUDIO DOWNLOADS OVERALL: $overallTotal\n";
###############################################################################
# Local variables:
# compile-command: "perl -c oggcast-count.plx"
# End:
