package Node;
use strict;
use warnings;
use Carp;
use YAML::XS;

use File::Basename;
use POSIX qw( :sys_wait_h );
use Tie::File;

sub new
{
    my ( $class, %this ) = @_;
    die "path undef." unless $this{path};
    system( "mkdir -p '$this{path}'" ) unless -d $this{path};
    bless \%this, ref $class || $class;
}

sub add
{
    my ( $this, $user, $node ) = @_;

    my %node = map{ $_ => 1 }$this->nodes( $user );

    map{ $node{$_} ++ }@$node; 
    $this->nodes( $user, [ keys %node ] );
    return $this;
}

sub del
{
    my ( $this, $user, $node ) = @_;

    my %node = map{ $_ => 1 }$this->nodes( $user );

    map{ delete $node{$_} }@$node; 
    $this->nodes( $user, [ keys %node ] );
    return $this;
}

sub users
{
    my $this = shift;
    return map{ basename $_ }glob "$this->{path}/*";
}

sub nodes
{
    my ( $this, $user, $node ) = @_;
    die "user format error" unless $user =~ /^[a-zA-Z0-9\.\-\@_]+$/;
    die "tie fail: $!\n" unless tie my @nodes, 'Tie::File', "$this->{path}/$user";
    @nodes = grep{ /\w/ }@$node if $node;
    return @nodes;
}

1;
