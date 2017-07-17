package install;
use Dancer ':syntax';
use JSON;

use FindBin qw( $RealBin );
use dashboard;
use MYDan;
our $VERSION = '0.1';

any '/install/' => sub {
    my $param = params();
    template 'install', +{ serveraddr => "http://".request->{host} };
};

my $install_script_agent;
any '/install/script/agent.sh' => sub {

    unless( $install_script_agent )
    {
        $install_script_agent = 
'#!/bin/bash
test -e MYDanROOT/etc/mydan.lock && exit 1;
TMP=/tmp/mydan.install.tar.gz;
ARCH=$(uname).$(uname -m);
wget -O $TMP http://ServerAddr/download/agent/$ARCH/mydan.latest.tar.gz || exit 1;
tar -zxvf $TMP -C / || exit 1
rsync -av MYDanROOT/etc/agent/auth.tmp/ MYDanROOT/etc/agent/auth/ || exit
rsync -av MYDanROOT/dan/bootstrap/exec.tmp/agent MYDanROOT//dan/bootstrap/exec/agent || exit
MYDanROOT/dan/bootstrap/bin/bootstrap --install || exit 1
sed -i "s/.*#myrole/  role: agent #myrole/" MYDanROOT/dan/.config || exit 1

sed -i "s/.*#dashboard_addr/  addr: http:\/\/ServerAddr #dashboard_addr/" MYDanROOT/dan/.config || exit 1
#ServerAddr
#MYDanROOT
#AgentPort
#PROC_IPTABLES_NAMES=/proc/net/ip_tables_names
#NF_TABLES=$(cat "$PROC_IPTABLES_NAMES" 2>/dev/null)
#
#if [ -z "$NF_TABLES" ]; then
#    echo "Firewall is not running."
#else
#    INPUTC=$(iptables -L  INPUT|wc -l)
#    IPTABLE=$(iptables -L INPUT|grep AgentPort|wc -l)
#    test $INPUTC -gt 2 && test $IPTABLE -lt 1 && iptables -I  INPUT -p tcp --dport AgentPort -j ACCEPT
#fi
#
echo OK
';
        my %reg = ( MYDanROOT => $MYDan::PATH );
        while( my( $k, $v ) = each %reg )
        {
            $install_script_agent  =~ s/$k/$v/g;
        }
    }

    my $ServerAddr = request->{host};
    my $tmp = $install_script_agent; $tmp =~ s/ServerAddr/$ServerAddr/g;
    
    return $tmp;
};

my $install_script_client;
any '/install/script/client.sh' => sub {

    unless( $install_script_client )
    {
        $install_script_client = 
'#!/bin/bash
test -e MYDanROOT/etc/mydan.lock && exit 1;
TMP=/tmp/mydan.install.tar.gz;
ARCH=$(uname).$(uname -m);
wget -O $TMP http://ServerAddr/download/agent/$ARCH/mydan.latest.tar.gz || exit 1;
tar -zxvf $TMP -C / || exit 1
sed -i "s/.*#myrole/  role: client #myrole/" MYDanROOT/dan/.config || exit 1
sed -i "s/.*#dashboard_addr/  addr: http:\/\/ServerAddr #dashboard_addr/" MYDanROOT/dan/.config || exit 1
echo OK
';
        my %reg = ( MYDanROOT => $MYDan::PATH );
        while( my( $k, $v ) = each %reg )
        {
            $install_script_client =~ s/$k/$v/g;
        }
    }

    my $ServerAddr = request->{host};
    my $tmp = $install_script_client; $tmp =~ s/ServerAddr/$ServerAddr/g;
    
    return $tmp;
};

true;
 
