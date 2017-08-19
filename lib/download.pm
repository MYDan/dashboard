package download;
use Dancer ':syntax';
use JSON;

use FindBin qw( $RealBin );
use dashboard;
our $VERSION = '0.1';

any '/download/' => sub {
    my $param = params();
    my ( %download, %dl );
    map{ $download{$1}{$2}{$3} = 1 if $_ =~ /\/([^\/]+)\/([^\/]+)\.(client|agent|tar\.gz)$/ }glob "$RealBin/../public/download/agent/*/*";

    while( my ( $arch, $data ) = each %download )
    {
        for my $ver ( sort keys %$data )
        {
            push  @{$dl{$arch}}, [ $ver, map{ $data->{$ver}{$_}||= 0 }qw( tar.gz client agent ) ];
        }
        
    }
    template 'download', +{ download => \%dl };
};

true;
 
