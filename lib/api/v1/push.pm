package api::v1::push;
use Dancer ':syntax';
use JSON;

use dashboard;
our $VERSION = '0.1';

any '/api/v1/push/nodeinfo' => sub {
    my $param = params();
    map{ 
        return +{ stat =>  $JSON::false, info => "$_ undef" }
            unless $param->{$_} && $param->{$_} =~ /^[a-zA-Z0-9,\.\-]+$/
    }qw( hostname ips cdn );

    my( $hostname, $ips, $cdn ) =@$param{ qw( hostname ips cdn ) };
    my %ips; map { $_ =~ /^10\./ ? push @{$ips{in}}, $_ : push @{$ips{ex}}, $_  }sort split /,/, $ips;
    my @ips; 
    map{ push( @ips, shift @{$ips{$_}} ) if @{$ips{$_}} > 0 }qw( in ex );
    map{ push @ips, @{$ips{$_}} }qw( in ex );

    my $i = 1;
    my $error = dashboard::execute( 
        "delete from rel_host_ip_cdn where hostname='$hostname'",
        map{ sprintf "insert into rel_host_ip_cdn (`hostname`,`ip`,`cdn`,`if`) values('$hostname','$_','$cdn','%s')", $i++}
            grep{ $_ =~ /^[\d\.]+$/ }split /,/, $ips );

    return +{ stat =>  $JSON::false, info => "ERR:$error" } if $error;

    return +{ stat =>  $JSON::true, info => 'ok' };
};

true;
 
