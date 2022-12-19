#!/usr/bin/env perl

use strict;
use warnings;
use v5.30.0;

use List::Util qw(first);

if ( !( $#ARGV + 1 ) ) {
    say STDERR "Usage: ./main.pl <filepath>";
    exit 1;
}

chomp( my @lines = <> );
my @content   = unpack "W*", join( "", @lines );
my $start_idx = first { $content[$_] eq 83 } 0 .. $#content;
my $dest_idx  = first { $content[$_] eq 69 } 0 .. $#content;
my $width     = length $lines[0];

my @queue   = ($start_idx);
my %visited = ();
my %parents = ();

sub can_move {
    my $array_ref   = shift;
    my $source      = shift;
    my $destination = ${$array_ref}[shift];

    if ( $destination == 69 ) {
        $destination = 122;
    }

    return $destination <= ${$array_ref}[$source] + 1;
}

sub in_bounds {
    my $array_ref = shift;
    my $idx       = shift;

    return $idx > 0 && $idx < scalar @{$array_ref};
}

sub same_grid_line {
    my $width       = shift;
    my $source      = shift;
    my $destination = shift;

    return ( int $source / $width ) == ( int $destination / $width );
}

while ( scalar @queue > 0 ) {
    my $idx = shift @queue;

    if ( exists $visited{$idx} ) {
        next;
    }

    $visited{$idx} = 1;
    my $up_idx    = $idx - $width;
    my $down_idx  = $idx + $width;
    my $left_idx  = $idx - 1;
    my $right_idx = $idx + 1;

    foreach ( $up_idx, $down_idx, $left_idx, $right_idx ) {
        if ( in_bounds( \@content, $_ ) && !exists $visited{$_} ) {
            if ( ( $_ == $left_idx || $_ == $right_idx )
                && !same_grid_line( $width, $idx, $_ ) )
            {
                next;
            }

            $parents{$_} = $idx;

            if ( $_ == $dest_idx && can_move( \@content, $idx, $_) ) {
                $parents{$dest_idx} = $idx;
                last;
            }
            elsif ( scalar %visited == 1 || can_move( \@content, $idx, $_ ) ) {
                push @queue, $_;
            }
        }
    }
}

my $move_count = 0;
my $path_idx   = $dest_idx;

while ( exists ${ parents { $path_idx } } ) {
    ++$move_count;
    $path_idx = ${ parents { $path_idx } };
}

print "Reached destination after $move_count moves\n";
