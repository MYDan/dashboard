use strict;
use warnings;
use FindBin qw( $Bin $RealBin );
use Tie::File;


exit if -f 'ok';

my $perl = $ENV{PERL_PATH} || $^X;
my $cpan = $perl;$cpan =~ s/perl$/cpan/;

$cpan = $ENV{cpan} unless -f $cpan;
die "no find cpan" unless -f $cpan;

sub mysystem
{
    my $cmd = shift;
    die "$cmd fail:$!" if system $cmd;
}

sub repl
{
    my $type = shift;
    for my $file ( `find $type -type f` )
    {
        chomp $file;
        tie my ( @file ), 'Tie::File', $file;
    
        next unless @file && $file[0] =~ /#![^#]*perl(.*$)/o;
        $file[0] = "#!$perl$1";
        warn "$file\n";
        untie @file;
    }
    
}

sub insl
{
   
    print '#' x 30, " check module ", '#' x 30, "\n";
   
    map{
        $_ =~ s/'//g;
        if( system "$perl -e \"use $_\" >/dev/null 2>&1" )
        {
            print "install $_\n";
            mysystem( "$cpan install $_" );
        }
        else { print "$_=> ok.\n"; }
        print '-' x 74, "\n";
    }@_;
    
}

mysystem "rsync -a cc/ cc.i/";
repl( 'cc.i' );
mysystem "rsync -a cc.i/ ./";

my %m;
tie my ( @file ), 'Tie::File', 'Makefile.PL';
map{ $m{$1} = 1 if $_ =~ /\s+'?([:\w]+)'? => [\d\.]+/ }@file;
untie @file;

insl( keys %m );   

system 'touch ok';
exit 0;
