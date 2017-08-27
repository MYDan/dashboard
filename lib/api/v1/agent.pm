package api::v1::agent;
use Dancer ':syntax';
use JSON;

use dashboard;
use user;

use MYDan::Util::OptConf;
use MYDan::Agent::Query;
use YAML::XS;
use Data::UUID;

our $VERSION = '0.1';

our ( %agent, %dashboard ); 
BEGIN{ 
    %agent     = MYDan::Util::OptConf->load()->dump( 'agent' );
    %dashboard = MYDan::Util::OptConf->load()->dump( 'dashboard' );
};

any '/api/v1/agent/encryption' => sub {
    my ( $raw, $query, $yaml ) = request->body;

    return 'invalid query' unless
        ( $yaml = Compress::Zlib::uncompress( $raw ) )
        && eval { $query = YAML::XS::Load $yaml }
        && ref $query eq 'HASH';

    my $uuid = Data::UUID->new->create_str();
    print YAML::XS::Dump +{ uuid => $uuid, query => $query };
    my $auth = delete $query->{auth};
    return 'no auth' unless $auth && %$auth;

    map{ return "no $_" unless $query->{$_} }qw( user peri node );
    return 'user format error' unless $query->{user} =~ /^[a-zA-Z0-9\._-]+$/;

    eval{
        return 'auth fail' unless MYDan::Agent::Auth->new(
            pub => $dashboard{'auth'}, user => $query->{user}
        )->verify( $auth, YAML::XS::Dump $query );
    };

    return "verify fail:$@" if $@;

    my @peri = split '#', $query->{peri};
    return 'peri fail' unless $peri[0] < time && time < $peri[1];

    my ( $user, $sudo, $node ) = @$query{qw( user sudo node )};

    my $data = &{$user::code{access}}( $user );
    print YAML::XS::Dump +{ uuid => $uuid, access => $data };

    if( $data->{'*'} &&  $data->{'*'}{'*'} )
    {
        delete $query->{node};
    }
    else
    {
        $query->{node} = +{ map{ $_ =>  1 }  $sudo 
            ? grep{ $data->{$_}{$sudo} }@$node : grep{ $data->{$_} }@$node };
    }

    $query->{sudo} = $query->{user} unless $sudo;


    $query->{auth} = eval{ 
        MYDan::Agent::Auth->new( key => $agent{'auth'} )
            ->sign( YAML::XS::Dump $query );
    };
    print YAML::XS::Dump  +{ uuid => $uuid, 'return' => $query };
    return  "sign error: $@" if $@;
    my $r =  Compress::Zlib::compress( YAML::XS::Dump $query );
    send_file( \$r, content_type => 'image/png' );
};

true;
