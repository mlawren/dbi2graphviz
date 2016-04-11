package App::dbi2graphviz;
use strict;
use warnings;
use DBI;
use DBIx::Model;
use GraphViz2;
use Time::Piece;
use XML::API;

our $VERSION = '0.0.1_2';

sub run {
    my $class = shift;
    my $opts  = shift;
    $opts->{dsn} = 'dbi:SQLite:dbname=' . $opts->{dsn} if -f $opts->{dsn};
    $opts->{format} = $opts->{output} =~ s/.*\.(.*)/$1/r;

    my $dbh = DBI->connect( $opts->{dsn} );
    my $db  = $dbh->model(
        name => $opts->{name} // $opts->{dsn},
        exclude => $opts->{exclude},
    );

    sub exclude {
        my $name    = shift;
        my $exclude = shift;
        my $include = shift;

        foreach my $try (@$exclude) {
            return 1 if $name =~ m/$try/;
        }

        return 0 unless $include;

        foreach my $try (@$include) {
            return 0 if $name =~ m/$try/;
        }

        return 1;
    }

    my $x = XML::API->new;
    $x->table_open(
        {
            align  => 'left',
            border => 0,
        }
    );

    $x->tr_open;
    $x->td( { align => 'left' }, '.' );
    $x->td('');
    $x->tr_close;

    $x->tr_open;
    $x->td_open( { align => 'left', } );
    $x->b('Database:');
    $x->td_close;
    $x->td( { align => 'left', }, $db->name );
    $x->tr_close;

    $x->tr_open;
    $x->td_open( { align => 'left', } );
    $x->b('Generated:');
    $x->td_close;
    my $t  = localtime;
    my $tz = sprintf( "%+.2d%.2d",
        int( $t->tzoffset / 3600 ),
        ( abs( $t->tzoffset ) - int( abs( $t->tzoffset ) / 3600 ) * 3600 ) /
          60 );

    $x->td( { align => 'left' },
        $t->strftime('%F %T') . ' ' . $tz . ' by dbi2graphviz v' . $VERSION );
    $x->tr_close;

    $x->table_close;

    ( $x = $x->_fast_string ) =~ s/.*?>//m;

    my $graph = GraphViz2->new(
        graph => {
            label     => '<' . $x . '>',
            rankdir   => uc( $opts->{rankdir} ),
            labeljust => 'l',
            overlap   => 'false',
        },
        edge   => { color => 'grey' },
        global => {
            directed => 1,
            driver   => $opts->{driver},
            name => ( $opts->{name} // $opts->{dsn} ) =~ s/[^a-zA-z]+/_/gr =~
              s/((^_)|(_$))//gr,
        },
        node => {
            color => 'grey',
            shape => 'oval',
        },
    );

    foreach
      my $table ( sort { $b->target_count <=> $a->target_count } $db->tables )
    {
        next if exclude( $table->name, $opts->{exclude}, $opts->{include} );

        my $x = XML::API->new;
        $x->table_open(
            {
                align  => 'left',
                border => 1,
                color  => 'grey',
            }
        );
        $x->tr_open;
        $x->td_open( { align => 'left', border => 0, port => $table->name } );
        $x->b( $table->name );
        $x->td_close;
        $x->tr_close;

        foreach my $col ( $table->columns ) {
            $x->tr_open;
            $x->td_open(
                {
                    align  => 'left',
                    border => 0,
                    port   => $col->name,
                    width  => 5,
                    $col->chain
                    ? ( bgcolor => $opts->{color}->[ $col->chain ] || 'grey' )
                    : (),
                },
                $col->name . ' '
            );
            $x->i(
                lc(
                      $col->size
                    ? $col->type . '(' . $col->size . ')'
                    : $col->type
                  )
                  . ( $col->nullable ? ' (null)' : '' )
            );
            $x->td_close;
            $x->tr_close;
        }

        $x->table_close;

        ( $x = $x->_fast_string ) =~ s/.*?>//m;

        $graph->add_node(
            name   => $table->name,
            label  => '<' . $x . '>',
            shape  => 'none',
            width  => 0,
            height => 0,
            margin => 0,
        );
    }

    my %seen;

    foreach my $fk ( map { $_->foreign_keys } $db->tables ) {
        next if exclude( $fk->table->name, $opts->{exclude}, $opts->{include} );
        next
          if exclude( $fk->to_table->name, $opts->{exclude}, $opts->{include} );

        my @fcols = $fk->columns;
        my @tcols = $fk->to_columns;
        foreach my $i ( 0 .. $#fcols ) {
            my $fcol = $fcols[$i];
            my $tcol = $tcols[$i];

            next if $seen{ $fcol->full_name . $tcol->full_name }++;

            $graph->add_edge(
                from  => $fk->table->name . ':' . $fcol->name,
                to    => $fk->to_table->name . ':' . $tcol->name,
                color => $opts->{color}->[ $tcol->chain ] || 'grey',
            );
        }
    }

    unlink $opts->{output};

    $graph->run(
        format      => $opts->{format},
        output_file => $opts->{output},
    );

    foreach my $chain ( 1 .. $db->chains ) {
        print "FK Chain $chain: "
          . ( $opts->{color}->[$chain] || 'grey' ) . "\n";
    }

    #print $db->as_string;
    #print $graph->dot_input;
}

1;
__END__

=head1 NAME

App::dbi2graphviz - database schema diagram generator


