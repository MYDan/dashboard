package dashboard;
use Dancer ':syntax';

set serializer => 'JSON';
set show_errors => 1;

our $VERSION = '0.1';
our $MYSQL;

use Dancer::Plugin::Database;

sub query
{
    my $sth = database->prepare( shift );
    $sth->execute();
    $sth->fetchall_arrayref;
}
sub execute
{
    eval{
        map{ database->do( $_ ); }@_;
        database->commit();
    };
    my $error = $@;
    if( $error )
    {
        eval{ database->rollback; };
        return $error;
    }
    return undef;
}

get '/' => sub {
    template 'index';
};

any '/mon' => sub {
     eval{ query( sprintf "select count(*) from rel_host_ip_cdn" )};
     return $@ ? "ERR:$@" : "ok";
};

any '/test' => sub {
    my $r = request;
    use Data::Dumper;
    #print Dumper $r->body;# params();;
    #print Dumper $r->{_http_body}->body->filename;# params();;
    use MYDan::Agent::Query;
    my $query = MYDan::Agent::Query->load( $r->body );
    print Dumper  $query->yaml();
};



true;
