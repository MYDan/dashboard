package install;
use Dancer ':syntax';
use JSON;

use FindBin qw( $RealBin );
use dashboard;
use MYDan;
our $VERSION = '0.1';

any '/install/' => sub {
    my $param = params();

    template 'install', +{ serveraddr => config->{serveraddr} };
};


my $install_script;
any '/install/script.sh' => sub {

    unless( $install_script )
    {
        $install_script = 
'#!/bin/bash
test -e /etc/mydan.lock && exit 1;
TMP=/tmp/mydan.install.tar.gz;
ARCH=$(uname).$(uname -m);
wget -O $TMP ServerAddr/download/agent/$ARCH/mydan.latest.tar.gz || exit 1;
tar -zxvf $TMP -C / || exit 1
MYDanROOT/dan/bootstrap/bin/bootstrap --install || exit 1
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

        my %reg = ( ServerAddr => config->{serveraddr}, MYDanROOT => $MYDan::PATH );
        while( my( $k, $v ) = each %reg )
        {
            $install_script =~ s/$k/$v/g;
        }
    }
    
    return $install_script;
};


true;
 
