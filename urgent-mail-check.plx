#!/usr/bin/perl
# urgent-mail-check.plx
#
# Copyright (C) 2013, Bradley M. Kuhn
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
# I needed a quick script to parse the output of emacs script.

use strict;
use warnings;
use Date::Manip;
use Net::IMAP::Client;
use File::Spec;


my $DIR = File::Spec->catdir("$ENV{HOME}", 'tmp', '.urgent-email-displayed');

chdir($DIR) or die "unable to go to $DIR";

######################################################################
sub ReadRecentUrgentEmailAnnouncements ($) {
  my($dir) = @_;

  my %info;
  my $file = File::Spec->catfile($dir, 'urgent-email-announce-recent');
  open(RECENT_ALERTS, "<", $file) or die "unable to open $file for reading: $!";
  my $key;
  my $data = "";
  foreach my $line (<RECENT_ALERTS>) {
    chomp $line;
    next if $line =~ /^\s*$/;
    if ($line =~ /^\s*([\d\:\-]+)/) {
      my $newKey = $1;
      $info{$key} = $data if defined $key;
      $key = $newKey;
      $data = "";
    } else {
      $data .= $line;
    }
  }
  close RECENT_ALERTS; die "error($?) reading $file: $!" unless $? == 0;

  $info{$key} = $data if (defined $key);  # Grab last one.

  return \%info;
}
######################################################################
sub WriteRecentUrgentEmailAnnouncements ($$) {
  my($dir, $info) = @_;

  my $file = File::Spec->catfile($dir, 'urgent-email-announce-recent');
  open(RECENT_ALERTS, ">", $file) or die "unable to open $file for reading: $!";

  foreach my $key (sort keys %$info) {
    print RECENT_ALERTS "$key\n$info->{$key}\n";
  }
  close RECENT_ALERTS; die "error($?) writing $file: $!" unless $? == 0;
}
######################################################################
# Test if network is up
system('/bin/ping -q -w 20 -c 5 pine.sfconservancy.org > /dev/null 2>&1');

exit 1 if ($? != 0);

my $output = "";
my $record = "";
my $info = ReadRecentUrgentEmailAnnouncements($DIR);

# open a connection to the IMAP server
use Net::IMAP::Client;
open(PW, "<", $ARGV[1]) or die "unable to open $ARGV[0] to find password!";

my %passwords;
while (my $line = <PW>) {
  $passwords{$1} = $2;
}
close PW;

my $imap = Net::IMAP::Client->new(
        server => 'pine.sfconservancy.org',
        user   => $ARGV[0],
        pass   => $passwords{$ARGV[0]},
        ssl    => 1,                              # (use SSL? default no)
        ssl_verify_peer => 1,                     # (use ca to verify server, default yes)
#        ssl_ca_file => '/etc/ssl/certs/certa.pm', # (CA file used for verify server) or
        ssl_ca_path => '/etc/ssl/certs/',         # (CA path used for SSL)
        port   => 993                             # (but defaults are sane)
                                 );

$imap->login or
  die('Login failed: ' . $imap->last_error);

$imap->select('URGENT');
my $messages = $imap->search('ALL');

print Data::Dumper->Dump([$messages]);



if ($output eq "") {
    print "\$hr\n\${font :size=17}Urgent Emails:\n";
}
###############################################################################
#
# Local variables:
# compile-command: "perl -c urgent-mail-check.plx"
# End:

