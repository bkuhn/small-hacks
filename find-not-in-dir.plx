# find-not-in-dir.plx                                            -*- Perl -*-
#   Possible bug: only -type f and -type d are checked
# Copyright (C) 2001, 2002, 2003, 2004, 2008, 2011 Bradley M. Kuhn <bkuhn@ebb.org>
# Copyright (C) 2011 Denver Gingerich <denver@ossguy.com>
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
#

######################################################################
sub FindAndSortOutput {
  use File::Find;

  my($type, $dir, $output, $ignoreRegex, $includeRegex, $filterRewrite) = @_;
  my @files;

  my $buildList = sub {
    my $val = $_;
    chomp $val;
    $val =~ s/$filterRewrite// if defined $filterRewrite;
    if ($type eq "NON-REGULAR") {
      push(@files, $val) unless -f $_;
    } elsif ($type eq "FILES") {
      push(@files, $val) if -f $_;
    } elsif ($type eq "DIRECTORY") {
      push(@files, $val) if -d $_;
    } else {
      die "Unknown type requested: $type";
    }
  };

  find({ wanted => $buildList, no_chdir => 1},  $dir);

  open(FILE_OUTPUT, ">$output") or
    die "$0: unable to open temporary output file, $output: $!";

  my @sortedChompedFiles;
  foreach my $file (sort {$a cmp $b } @files) {
    chomp $file;
    next if defined $ignoreRegex and $file =~ /$ignoreRegex/;
    next if defined $includeRegex and $file !~ /$includeRegex/;
    push(@sortedChompedFiles, $file);
    print FILE_OUTPUT "$file\n";
  }
  close FILE_OUTPUT;

  return @sortedChompedFiles;
}
######################################################################

my(@orgNonRegular) = FindAndSortOutput("FILES", $origDir, $origTempFile,
                                 $ignoreRegex, "^/?($origDir|$comparedDir)/?");
