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
    system( "touch '$this{path}/current'" ) unless -e "$this{path}/current";
    bless \%this, ref $class || $class;
}

sub add
{
    my ( $this, $user, $node, $name ) = @_;

    my $data = $this->_data();

    map{ $data->{$user}{$_}{$name} = 1 }@$node;
    my $file = sprintf "data.%s", POSIX::strftime( "%F_%T", localtime );
    eval{ YAML::XS::DumpFile "$this->{path}/$file", $data; };
    system "ln -fsn '$file' '$this->{path}/current'";

    return $this;
}

sub del
{
    my ( $this, $user, $node, $name ) = @_;

    my $data = $this->_data();
    map{ 
        delete $data->{$user}{$_}{$name};
        delete $data->{$user}{$_} unless keys %{$data->{$user}{$_}};

    }@$node;

    my $file = sprintf "data.%s", POSIX::strftime( "%F_%T", localtime );
    eval{ YAML::XS::DumpFile "$this->{path}/$file", $data; };
    system "ln -fsn '$file' '$this->{path}/current'";

    return $this;
}

sub users
{
    my $data = shift->_data();
    return [ keys %$data ];
}

sub nodes
{
    my ( $this, $user ) = @_;
    my $data = $this->_data();
    return $data->{$user};
}


sub _data
{
    my $this = shift;
    my $data = eval{  YAML::XS::LoadFile "$this->{path}/current" };
    die "load $this->{path}/current fail:$@" if $@;
    return $data;
}


1;
