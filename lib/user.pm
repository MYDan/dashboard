package user;
use Dancer ':syntax';
use JSON;

use Tie::File;
use dashboard;
our $VERSION = '0.1';


our %code;
BEGIN{
    use FindBin qw( $RealBin );
    map{
        my $code = do "$RealBin/../code/$_";
        die "code/$_ no CODE" unless ref $code eq 'CODE';
        $code{$_} = $code;
    }qw( access sso );
};
sub get_username
{
    my $callback = sprintf "%s%s%s", config->{ssocallback}, "http://".request->{host},request->{path};
    my $username = &{$code{sso}}( cookie( config->{cookiekey} ) );
    redirect $callback unless $username;
    return $username;
}

sub maketoken
{
    my @dataSource = (0..9,'a'..'z','A'..'Z');  
    return join '', map { $dataSource[int rand @dataSource] } 0..31;  
}

any '/user/settings/' => sub {
    my $param = params();
    return unless my $username = get_username();

    my ( $t, $p ) = map{ "$RealBin/../../etc/dashboard/$_" }qw( auth pass );
    map{ system "mkdir -p '$_'" unless -e $_; }( $t, $p );

    die "tie auth $username fail" unless tie my @token, 'Tie::File', "$t/$username.pub";
    die "tie pass $username fail" unless tie my @pass, 'Tie::File', "$p/$username";

    @token = ( $param->{token} ) if $param->{token};
    @pass  = ( $param->{pass} )  if $param->{pass};

    template 'user/settings', +{ 
        username => $username,
        token => join( "\n", @token), 
        pass => join( "\n",@pass )
    };
};

any '/user/myhost/' => sub {
    my $param = params();
    return unless my $username = get_username();
    my $data = &{$code{access}}( $username );
    my @myhost = map{ sprintf "%s:%s", $_, join ',', keys %{$data->{$_}} }keys %$data;
    template 'user/myhost', +{ username => $username, myhost => \@myhost, count => scalar @myhost };
};

true;
 
