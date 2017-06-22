package api::v1::agent;
use Dancer ':syntax';
use JSON;

use dashboard;
use user;

use MYDan::Util::OptConf;
use MYDan::Agent::Query;
use YAML::XS;

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

    return 'no auth' unless my $auth = delete $query->{auth};
    map{ return "no $_" unless $query->{$_} }qw( logname peri node );

    eval{
        return 'auth fail' unless MYDan::Agent::Auth->new(
            pub => $dashboard{'auth'}, user => $query->{logname}
        )->verify( $auth, YAML::XS::Dump $query );
    };

    return "verify fail:$@" if $@;

    my @peri = split '#', $query->{peri};
    return 'peri fail' unless $peri[0] < time && time < $peri[1];

    my ( $logname, $user, $node ) = @$query{qw( logname user node )};

    my $data = &{$user::code{access}}( $logname );
    $query->{node} = +{ map{ $_ =>  1 }  $user ? grep{ $data->{$_}{$user} }@$node : grep{ $data->{$_} }@$node };

    $query->{auth} = eval{ MYDan::Agent::Auth->new( key => $agent{'auth'} )->sign( YAML::XS::Dump $query ) };
    return  "sign error: $@" if $@;
    my $r =  Compress::Zlib::compress( YAML::XS::Dump $query );
    send_file( \$r, content_type => 'image/png' );
};

true;
