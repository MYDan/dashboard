package api::v1::agent;
use Dancer ':syntax';
use JSON;

use dashboard;
our $VERSION = '0.1';

any '/api/v1/agent/encryption' => sub {
    use Data::Dumper;
    use MYDan::Agent::Query;
    my ( $raw, $query ) = request->body;

    die "invalid $query\n" unless
        ( $yaml = Compress::Zlib::uncompress( $raw ) )
        && eval { $query = YAML::XS::Load $yaml }
        && ref $query eq 'HASH' && $query->{code};

    die "code format error:$query->{code}\n" unless $query->{code} =~ /^[A-Za-z0-9_\.]+$/;

    return $raw if $query->{code} =~ /^free\./;

    my $query = MYDan::Agent::Query->load( $r->body );
    print Dumper  $query->yaml();

};

true;
 
