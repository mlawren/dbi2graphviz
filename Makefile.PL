#!/usr/bin/env perl
use strict;
use warnings;
use 5.010;
use ExtUtils::MakeMaker::CPANfile;

WriteMakefile(
    NAME         => 'dbi2graphviz',
    ABSTRACT     => 'database schema diagram generator',
    AUTHOR       => 'Mark Lawrence <nomad@null.net>',
    VERSION_FROM => 'lib/App/dbi2graphviz.pm',
    LICENSE      => 'gpl_3',
    EXE_FILES    => ['bin/dbi2graphviz'],
    test         => {
        RECURSIVE_TEST_FILES => 1,
    },
    META_MERGE => {
        'meta-spec' => { version => 2 },
        resources   => {
            bugtracker =>
              { web => 'https//github.com/mlawren/dbi2graphviz/issues', },
            homepage   => 'https//github.com/mlawren/dbi2graphviz',
            repository => {
                type => 'git',
                url  => 'ssh://git@github.com/mlawren/dbi2graphviz.git',
                web  => 'https//github.com/mlawren/dbi2graphviz',
            }
        },
    },
);
