package api::v1::query;
use Dancer ':syntax';
use JSON;

use dashboard;
our $VERSION = '0.1';

any '/api/v1/query/cdn' => sub {
    my $param = params();
    my %query = ( sql => 'select * from rel_host_ip_cdn' );
    map{ 
        return +{ stat =>  $JSON::false, info => "$_ format error" }
           if $param->{$_} && $param->{$_} !~ /^[a-zA-Z0-9,\.\-]+$/;
           if( $param->{$_} )
           {

               $query{$_} = [ split /,/, $param->{$_} ];
               push @{$query{where}}, sprintf "$_ in (%s)", join',',map{ "'$_'"}@{$query{$_}}
           }
    }qw( hostname ip );

    $query{sql} = sprintf( "$query{sql} where %s", join ' or ', @{$query{where}} )if $query{where};
    my $re = dashboard::query( $query{sql} );


    return +{ stat =>  $JSON::true, data => $re } unless $query{where};
    my %data;
    map{ 

        $data{$_->[1]} = $_->[3];
        $data{$_->[2]} = $_->[3];
    }@$re;

    return +{ stat =>  $JSON::true, data => +{ map{ $_ => $data{$_} }@{$query{hostname}},@{$query{ip}}} };
};

any '/api/v1/query/net' => sub {
    my $re = dashboard::query( 'select * from rel_net_subnet_cdn' );
    my @data; map{push @data, +{ net => $_->[1], subnet => $_->[2], cdn => $_->[3], remark => $_->[4] } }@$re;
    return +{ stat =>  $JSON::true, data => \@data };
};

true;
 
