#!perl
on configure => sub {
    requires 'Module::Build'                      => '0.4004';
    requires 'Module::Build::Pluggable'           => 0;
    requires 'Module::Build::Pluggable::CPANfile' => '0.05';
};

on runtime => sub {
    requires 'DBIx::Model' => 0;
    requires 'GraphViz2'   => 0;
    requires 'OptArgs2'    => 0;
    requires 'Time::Piece' => 0;
    requires 'XML::API'    => '0.30';
};

on test => sub {
    requires 'Test2::Bundle::Extended' => 0;
};
