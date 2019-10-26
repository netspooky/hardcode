#!/usr/bin/perl

use bytes;
use strict;
use warnings;

chdir 'data';


# music instruments and data

my @files = ('drum', 'hihat', 'snare'); # order is important
open(my $TO, '>../data.h') || die $!;
my @sizes;

foreach my $w (@files) {
  my @bytes;
  open(my $FR, '<:raw', "$w.wav") || die $!;
  @bytes = split(//, join('', ( <$FR> )));
  close($FR);
  push @sizes, ($#bytes-43)/2;
  printf $TO "const short musicdata_%s[] = {", $w;
  for(my$i=0;$i<$#bytes;$i++) {
    next if $i < 44; # data starts at the 45th byte
    printf $TO '%d', unpack('s', sprintf('%s%s', $bytes[$i], $bytes[++$i]));
    print $TO ',' if $i != $#bytes;
    print $TO "\n  " if $i % 50 == 1 || $i % 50 == 0;
  }
  printf $TO "};\n\n";
}
print $TO "extern const short *musicdata[] = {";
  print $TO "musicdata_$_".($files[$#files]eq$_?'':',') foreach (@files);
printf $TO "};\nextern const int musicsizes[%d] = {%s};\n", $#files+1, join(',',@sizes);

print $TO "extern char sounddat[] = {\n  ";
open(my $FR, '<musicdata') || die $1;
  my $done = 0;
  while(<$FR>) {
    s/\r?\n$//g;
    s/^\s*[0-9]+\s*://;
    foreach my $l (split(//)) {
      if($l =~ /^[0-3]$/) {
        printf $TO '%d,', $l;
        $done++;
        print $TO "\n  " if $done % 50 == 0;
      }
    }
  }
close($FR);
print $TO "};\n\n";

open($FR, "<tunnel.c") || die $!;
  print $TO $_ while(<$FR>);
close($FR);


# ascii text

my @lines;
open($FR, 'text') || die $!;
  @lines = <$FR>;
close($FR);
die "ASCII should be 6 lines!" if $#lines != 5;
my $l;
foreach (0..5) {
  $lines[$_] =~ s/[\r\n]+$//;
  die "Not all lines have the same length!" if $l && length($lines[$_]) != $l;
  $l = length($lines[$_]);
}
printf $TO 'unsigned char text[%d] = {', $l+1;
foreach (0..$l) {
  my $bits = 0;
  $bits += 32 if substr($lines[0], $_, 1) eq 'x';
  $bits += 16 if substr($lines[1], $_, 1) eq 'x';
  $bits += 8 if substr($lines[2], $_, 1) eq 'x';
  $bits += 4 if substr($lines[3], $_, 1) eq 'x';
  $bits += 2 if substr($lines[4], $_, 1) eq 'x';
  $bits += 1 if substr($lines[5], $_, 1) eq 'x';
  printf $TO '%d', $bits;
  print $TO ',' if $_ != $l;
  print $TO "\n  " if $_ && $_ % 50 == 0;
}
print $TO "};\n";

close($TO);
