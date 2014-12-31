#!/usr/bin/perl
# Copyright (C) 2011, Bradley M. Kuhn
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

while (<>) {
  chomp;
  next unless /^(\S+)\s+[^"]+"\s*(GET)\s+(\S+)[\s"]/;
#  die "invalid line: $_"
#    unless /^(\S+)\s+[^"]+"\s*(LOCK|HEAD|GET|POST|OPTIONS|PUT|CONNECT|PROPFIND)\s+(\S+)[\s"]/;
  my($ip, $method, $url) = ($1, $2, $3);
  next unless $method =~ /^\s*GET\s*$/i;

  $url =~ s/\s*\.(ogg|mp3)\s*$/.audio/i;   # Treat ogg and mp3 downloads same.
  $url =~ s/\s*\/$$//;   # Always remove trailing slash 

  $data{$url}{$ip} = 0 unless defined $data{$url}{$ip};
  $data{$url}{__TOTAL__} = 0 unless defined $data{$url}{__TOTAL__};
  $data{$url}{$ip}++;
  $data{$url}{__TOTAL__}++;
}

foreach my $url (sort { $data{$b}{__TOTAL__} <=> $data{$a}{__TOTAL__}}
                 keys %data) {
  print "$url: $data{$url}{__TOTAL__}\n";
}
###############################################################################
# Local variables:
# compile-command: "perl -c oggcast-count.plx"
# End:
