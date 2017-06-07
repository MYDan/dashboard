package user;
use Dancer ':syntax';
use JSON;

use dashboard;
our $VERSION = '0.1';


our %code;
BEGIN{
    use FindBin qw( $RealBin );
    map{
        my $code = do "$RealBin/../code/$_";
        die "code/$_ no CODE" unless ref $code eq 'CODE';
        $code{$_} = $code;
    }qw( node sso );
};
sub get_username
{
    my $callback = sprintf "%s%s%s", config->{ssocallback}, config->{serveraddr},request->{path};
    my $username = &{$code{sso}}( config->{cookiekey} );
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
    my $username = get_username();
    my $tokenctrl = $param->{token} ||'';
    my $e;
    if( $tokenctrl eq 'add' )
    {
        $e = sprintf "replace into rel_user_token (`user`,`token`) values('$username','%s')", maketoken();
    }
    elsif( $tokenctrl eq 'del' )
    {
        $e = "delete from rel_user_token where user='$username'";
    }

    dashboard::execute( $e ) if $e;
    my $res = dashboard::query( "select token from rel_user_token where user='$username'");
    my $token = $res->[0][0] if $res && $res->[0] && $res->[0][0];
    template 'user/settings', +{ username => $username, token => $token };
};

any '/user/myhost/' => sub {
    my $param = params();
    my $username = get_username();
    my $data = &{$code{node}}( $username );
    my @myhost = map{ sprintf "%s:%s", $_, join ',', keys %{$data->{$_}} }keys %$data;
    template 'user/myhost', +{ username => $username, myhost => \@myhost, count => scalar @myhost };
};

true;
 
