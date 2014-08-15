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
close PASSWORDS;  die "error reading $passfile: $!" unless $? == 0;

open(OLD_TITLE_LOG, "<", "log/title.log") or die "unable to open title.log for writing: $!";

my %haveFull;
my %haveTitle;
my $startCount = 0;
while (my $line = <OLD_TITLE_LOG>) {
  if ($line =~ /^\s*(\d+)\s*\-(\S+)\s*:\s*(.+)$/) {
    my($num, $type, $val) = ($1, $2, $3);
    $val =~ s/^\s+//; $val =~ s/\s+$//;
    my $curCount = $num;
    $curCount =~ s/^0*//g;  $curCount = 0 if $curCount =~ /^\s*$/;
    $startCount = $curCount + 1 if ($curCount >= $startCount);
    $haveFull{$num}{$type} = $val;
    $haveTitle{$val} = 1 if ($type eq "Title");
  }
}
print STDERR "Begining donwload at video $startCount\n";
close OLD_TITLE_LOG;  die "error reading old title log: $!" unless $? == 0;

my $mech;
sub redo_login {
  $mech = undef;

  $mech = WWW::Mechanize->new(autocheck => 1);
  $mech->get("http://www.deucescracked.com/dashboard");
  $mech->submit_form(form_number => 1,
                     fields => { login => $login, password => $password});
}
&redo_login();

$mech->get("http://www.deucescracked.com/videos");
my $page= $mech->submit_form(form_number => 1,
                          fields => { stakes => $stakes, game_type => $gameType });

open(TITLE_LOG, ">>", "log/title.log") or die "unable to open title.log for writing: $!";
select(TITLE_LOG); $| = 1; select(STDERR); $| = 1; select(STDOUT);

my $count = 0;
my @allVideoLinks;
my $nextLink;
do {
  $mech->get($nextLink) if defined $nextLink;

  open(OUTPUT, ">", sprintf("html/%.4d.html", $count)) or die "unable to open ${count}.html for writing: $!";
  print OUTPUT encode('UTF-8', $page->decoded_content());
  close OUTPUT;

  my @videoLinks = $mech->find_all_links( class => 'video_title' );
  push(@allVideoLinks, @videoLinks);
  $count++;
} while ($nextLink = $mech->find_link(class => 'next_page'));

$count = $startCount;
foreach my $videoURL (@allVideoLinks) {
  my $v = sprintf("%.4d", $count);
  my $title = encode('UTF-8', $videoURL->text());
  print STDERR "Downloading $v: ",  $title, " .... ";
  if (defined $haveTitle{$title}) {
    print STDERR ".... already have.\n";
    next;
  }
  if ( ($startCount % 10) == 0) {
    print STDERR " ... redoing login ...";
    &redo_login;
  }
  $mech->get($videoURL->url_abs());
  
  my $videoResponse = $mech->follow_link(text_regex => qr/Download full/i);
  my $filename = $videoResponse->filename();
  $filename =~ s/-/_/g;
  $filename =~ s/ /-/g;
  $filename =~ s/-_-/_/g;
  $mech->save_content("videos/$filename");
  print TITLE_LOG "${v}-Title:    ",  $title,
                  "\n${v}-URL:      ", encode('UTF-8', $videoURL->url_abs()),
                  "\n${v}-Filename: ", encode('UTF-8', $filename), "\n";
  print STDERR " .... done.\n";
  $count++;
}
###############################################################################
#
# Local variables:
# compile-command: "perl -c dc-download-videos.plx"
# End:

