#!/usr/bin/env perl
my $perl = $ENV{PERL_PATH} || $^X;

use FindBin qw( $RealBin );
my $p = $RealBin; $p =~ s#/dashboard$#/perl/bin/perl#;

exec "$p $RealBin/build @ARGV";
