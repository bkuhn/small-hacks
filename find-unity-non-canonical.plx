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

my @NON_CANONICAL =  ('apinheiro@igalia.com',
                      'mike@mterry.name', 'kamstrup@delight', 'kamstrup@hardback',
                      'mikkel.kamstrup@gmail.com', 'macslow@bangang.de', 'mirco.mueller@ubuntu.com',
                      'seb128@ubuntu.com');

system("bzr branch lp:unity");
chdir("unity");

my $COMMITTER_REGEX;

foreach my $email (@NON_CANONICAL) {
  (not defined $COMMITTER_REGEX) ? ($COMMITTER_REGEX = '^\s*committer\s*:.*(')
    : ($COMMITTER_REGEX .= "|");
  $COMMITTER_REGEX .= $email;
}
$COMMITTER_REGEX .= ')';
print $COMMITTER_REGEX, "\n";
open(BZR_LOG, "-|", "bzr log -p") or die "unable to run bzr: $!";

while (my $line = <BZR_LOG>) {
  chomp $line;
  if ($line =~ /$COMMITTER_REGEX/) {
    my $capture = 0;
    print "=" x 48;
    print "\nFOUND: $line\n";
    my $subLine;
    while (my $subLine = <BZR_LOG>) {
      last if ($subLine =~ /^revno/);
      if ($subLine =~ /^diff:/) {
        $capture = 1;
      }
      print $subLine if $capture;
    }
    last if not defined $subLine;
  }

}


