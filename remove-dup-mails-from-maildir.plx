#!/usr/bin/perl

use strict;
use warnings;

use Mail::Header;
use File::Copy;

if (@ARGV < 2) {
  print STDERR "usage: $0 <TYPE> <SOURCE_MAILDIR_FOLDER_PATH> [<MALDIRS_LOOK_FOR_DUPS_IN> ...]\n";
  exit 1;
}

my($TYPE, $MAILDIR_FOLDER) = ($ARGV[0], $ARGV[1]);

my (@dupFolders) = @ARGV[2..$#ARGV];

my %msgs;  # indexed by Message-Id

foreach my $folder (@dupFolders) {
  my @msgDirs = ("$folder/cur", "$folder/new");
  foreach my $dir (@msgDirs) {
    die "$MAILDIR_FOLDER must not be a maildir folder (or is unreadable by you), since $dir isn't a readable directory: $!"
      unless  (-d $dir);
  }
  foreach my $dir (@msgDirs) {
    opendir(MAILDIR, $dir) or die "Unable to open directory $dir for reading: $!";
    while (my $file = readdir MAILDIR) {
      next if -d $file;    # skip directories
      my $existing_file = "$dir/$file";
      open(MAIL_MESSAGE, "<", $existing_file) or
        die "unable to open $existing_file for reading: $!";

      my $header = new Mail::Header(\*MAIL_MESSAGE);
      my $fields = $header->header_hashref;

      my $id = $fields->{'Message-ID'}[0];
      chomp $id;
      die "weirdly formatted message ID, $id in $dir/$file"
        unless $id =~ s/^\s*\<?\s*(\S+)\s*\>?.*$/$1/;

      die "$dir/$file has no message ID" if not defined $id;

#      die "Duplicate message ID's $id\n" if defined $msgs{$id};

      $msgs{$id} = $fields;
    }
    close MAIL_MESSAGE;
  }
  close MAILDIR;
}

# This code shouldn't be all cut-and-pasty from the above, but I was in a hurry.

my @msgDirs = ("$MAILDIR_FOLDER/cur", "$MAILDIR_FOLDER/new");
foreach my $dir (@msgDirs) {
  die "$MAILDIR_FOLDER must not be a maildir folder (or is unreadable by you), since $dir isn't a readable directory: $!"
    unless  (-d $dir);
}
foreach my $dir (@msgDirs) {
  opendir(MAILDIR, $dir) or die "Unable to open directory $dir for reading: $!";
  while (my $file = readdir MAILDIR) {
    next if -d $file;    # skip directories
    my $existing_file = "$dir/$file";
    open(MAIL_MESSAGE, "<", $existing_file) or
      die "unable to open $existing_file for reading: $!";

    my $header = new Mail::Header(\*MAIL_MESSAGE);
    my $fields = $header->header_hashref;

    my $id = $fields->{'Message-ID'}[0];
    chomp $id;
    die "weirdly formatted message ID, $id in $dir/$file"
      unless $id =~ s/^\s*\<?\s*([\S\n\s]+)\s*\>?.*$/$1/m;

    die "$dir/$file has no message ID" if not defined $id;

    # If we already have this message elsehwere, then we simply remove it
    # from this folder here.  Otherwise, we note that we have it by adding
    # it to %msgs.

    if (defined $msgs{$id}) {
      if ($TYPE eq "print") {
        print "$id\n";
      } elsif ($TYPE eq "svn") {
        system("svn rm \"$existing_file\"");
        die "Unable to unlink file $existing_file: $!"
          unless $? == 0;
      } else {
        print STDERR "Removing $existing_file\n";
        die "Unable to unlink $existing_file: $!"
          unless unlink($existing_file) == 1;
      }
    } else {
      $msgs{$id} = $fields;
    }
    close MAIL_MESSAGE;
  }
  close MAILDIR;
}

###############################################################################
#
# Local variables:
# compile-command: "perl -c remove-dup-mails-from-maildir.plx"
# End:
