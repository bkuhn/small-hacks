#!/usr/bin/perl -w
# mailman-archive-create-real-mbox.plx                                         -*- Perl -*-

# Copyright (C) 2013 Bradley M. Kuhn <bkuhn@ebb.org>
#
# This software's license gives you freedom; you can copy, convey,
# propogate, redistribute and/or modify this program under the terms of
# the GNU  General Public License (GPL) as published by the Free
# Software Foundation (FSF), either version 3 of the License, or (at your
# option) any later version of the GPL published by the FSF.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program in a file in the toplevel directory called
# "GPLv3".  If not, see <http://www.gnu.org/licenses/>.

use strict;
use warnings;

while (<>) {
  if (/^From\s+(\S+)\s+at\s+(\S+)\s+(.+)$/) {
    print "From ${1}\@${2} ${3}\n";
  } elsif (/^From\s+/) {
    die "invalid from line $_";
  } else {
    print $_;
  }
}

#
# Local variables:
# compile-command: "perl -c mailman-archive-create-real-mbox.plx"
# End:
