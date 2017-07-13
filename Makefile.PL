use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

our %PREREQ_PM =
(
    DBI => 1.625,
    JSON => 2.90,
    Dancer => 1.31,
    Expect => 1.21,
    threads => 1.80,
    DateTime => 1.03,
    'YAML::XS' => 0.65,
    'DBD::SQLite' => 1.37,
    'Getopt::Long' => 2.38,
    'Thread::Queue' => 2.12,
    'Test::More' => 0,
    'AnyEvent' => 0,#
    'Crypt::PK::RSA' => 0,
    'Template' => 0,
    'Dancer::Plugin::Database' => 0,
    'Twiggy' => 0,
);

WriteMakefile
(
    AUTHOR        => 'Lijinfeng <lijinfeng2011@gmail.com>',
    NAME          => 'dashboard',
    VERSION_FROM  => 'lib/dashboard.pm',
    ABSTRACT            => 'MYDan dashboard',
    PREREQ_PM     => \%PREREQ_PM, 
    dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => [ 'dashboard-*', 'cc.i', 'ok', 'bin', 'tools' ]},
    ( $ExtUtils::MakeMaker::VERSION >= 6.3002 ? ( LICENSE => 'perl' ) : () ),
);
