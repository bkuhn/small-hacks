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

foreach my $patchFile (@ARGV) {
  if (not -r $patchFile) {
    print STDERR "$patchFile is not readable\n";
    exit 1;
  }
  if (not -r "${patchFile}.sig") {
    print STDERR "${patchFile}.sig is not readable\n";
    exit 1;
  }
  system("/usr/bin/gpg ${patchFile}.sig");
  if ($? != 0) {
    print STDERR "GPG signature check problem on $patchFile\n";
    exit 1;
  }
}
