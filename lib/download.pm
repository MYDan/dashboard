package download;
use Dancer ':syntax';
use JSON;

use FindBin qw( $RealBin );
use dashboard;
our $VERSION = '0.1';

any '/download/' => sub {
    my $param = params();
    my %download;
    map{ push @{$download{$1}}, $2 if $_ =~ /\/([^\/]+)\/([^\/]+)$/ }glob "$RealBin/../public/download/agent/*/*";

    template 'download', +{ download => \%download,  serveraddr => config->{serveraddr} };
};

true;
 
