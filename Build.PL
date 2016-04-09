#!perl
use strict;
use warnings;
use Module::Build::Compat;
use Module::Build::Pluggable 'CPANfile';

my $builder = Module::Build::Pluggable->new(
    module_name    => 'App::dbi2graphviz',
    create_license => 1,
    license        => 'GPL_3',
    dist_author    => 'Mark Lawrence <nomad@null.net>',
    dist_version   => '0.0.1_1',
    no_index       => {
        package => [],
    },
    recursive_test_files => 1,
    add_to_cleanup       => [ 'db-*', '*.bak', 'blib', 'Makefile' ],
    meta_merge           => {
        resources => {
            bugtracker => 'https://github.com/mlawren/dbi2graphviz/issues',
            repository => 'git://github.com/mlawren/dbi2graphviz.git',
            homepage   => 'https://github.com/mlawren/dbi2graphviz',
        },
        keywords => [],
    },
);

$builder->create_build_script();

# I prefer to use make when developing so lets built the Makefile here
# as well
#Module::Build::Compat->create_makefile_pl( 'small', $builder );
Module::Build::Compat->write_makefile( build_class => 'Module::Build' );

use Pod::Text;
my $parser = Pod::Text->new( sentence => 0, width => 78 );
unlink 'README';
$parser->parse_from_file( 'bin/dbi2graphviz', 'README' );

