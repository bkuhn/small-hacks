#!/usr/bin/perl
# dc-download-videos.plx
# Copyright (C) 2014, Bradley M. Kuhn
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

use strict;
use warnings;

use WWW::Mechanize;
use HTTP::Cookies;

use Encode qw(encode decode);

my $mech = WWW::Mechanize->new(autocheck => 1);

foreach my $dir ("html", "videos", "log") {
  unless (-d $dir) {
    mkdir $dir or die "unable to create subdir for $dir: $!";
  }
}

die "usage: $0 PASSWORD STAKES GAME_TYPE" unless @ARGV == 3;

my $passfile = $ARGV[0];

#   <select name="stakes" id="stakes_sort" class="col1">
#    <option value="any" selected="selected">Stakes</option>
#    <option value="3">Mid Stakes</option>
#<option value="4">High Stakes</option>
# <option value="5" selected="selected">Micro/Small Stakes</option>  </select>

my $stakes = $ARGV[1];

# <option value="2" selected="selected">No Limit Hold&#x27;Em</option>
# <option value="3">Omaha/Omaha 8</option>
# <option value="4">Pot-Limit Omaha</option>
#<option value="5">Stud/Stud 8</option>
# <option value="6">Razz</option>
# <option value="7">MTT</option>
# <option value="8">Misc/Other</option>
# <option value="11">SNG</option>

my $gameType = $ARGV[2];

open(PASSWORDS, "<", $passfile) or die "unable to read $passfile $!";

my($login, $password);
while (my $line = <PASSWORDS>) {
  if ($line =~ /^\s*login\s*:\s*(\S+)\s*$/) {
    $login = $1;
  } elsif ($line =~ /^\s*password\s*:\s*(\S+)\s*$/) {
    $password = $1;
  } else {
    print STDERR "Bad lin in $passfile";
    exit 1;
  }
}
close PASSWORDS;
die "error reading $passfile: $!" unless $? == 0;

$mech->get("http://www.deucescracked.com/dashboard");
my $x = $mech->submit_form(form_number => 1,
                   fields => { login => $login, password => $password});
use Data::Dumper;
print $x->decoded_content();

###############################################################################
#
# Local variables:
# compile-command: "perl -c dc-download-videos.plx"
# End:

