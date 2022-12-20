#!/usr/bin/env perl

use strict;
use warnings;
use v5.30.0;

sub sub_special_values {
    my $value             = shift;
    my $start             = 83;
    my $end               = 69;
    my $start_replacement = 96;
    my $end_replacement   = 123;

    if ( $value == $end ) {
        $value = $end_replacement;
    }
    elsif ( $value == $start ) {
        $value = $start_replacement;
    }

    return $value;
}

sub can_move {
    my ( $source, $destination ) = @_;

    if ( $source eq "\n" || $destination eq "\n" ) {
        return 0;
    }

    my $source_ord      = sub_special_values( ord $source );
    my $destination_ord = sub_special_values( ord $destination );

    return $destination_ord <= $source_ord + 1;
}

sub filesize {
    my $handle = shift;

    my $start = tell $handle;
    seek $handle, 0, 2;
    my $total = tell $handle;
    seek $handle, $start, 0;

    return $total;
}

sub first_char_offset {
    my $handle  = shift;
    my $desired = shift;
    my $offset  = -1;
    my $char    = "";

    my $start = tell $handle;

    while ( $offset == -1 && !eof $handle ) {
        read $handle, $char, 1;

        if ( $char eq $desired ) {
            $offset = ( tell $handle ) - 1;
        }
    }

    seek $handle, $start, 0;
    return $offset;
}

if ( !( $#ARGV + 1 ) ) {
    say STDERR "Usage: ./main.pl <filepath>";
    exit 1;
}

open my $fh, "<", $ARGV[0] or die "Could not open file at provided path";

my $grid_size       = filesize($fh);
my $grid_width      = first_char_offset( $fh, "\n" );
my $starting_offset = first_char_offset( $fh, "S" );
my $ending_offset   = first_char_offset( $fh, "E" );

my @queue   = ($starting_offset);
my %visited = ();
my %parents = ();

while ( scalar @queue > 0 ) {
    my $offset = shift @queue;

    if ( exists $visited{$offset} ) {
        next;
    }

    $visited{$offset} = 1;
    seek $fh, $offset, 0;
    read $fh, my $char, 1;

    my $up_idx    = $offset - $grid_width - 1;
    my $down_idx  = $offset + $grid_width + 1;
    my $left_idx  = $offset - 1;
    my $right_idx = $offset + 1;

    foreach ( $up_idx, $down_idx, $left_idx, $right_idx ) {
        if (   $_ >= 0
            && $_ <= $grid_size
            && ( ( $_ + 1 ) % ( $grid_width + 1 ) ) != 0 )
        {
            seek $fh, $_, 0;
            read $fh, my $check_char, 1;

            if ( can_move( $char, $check_char ) && !exists $visited{$_} ) {
                $parents{$_} = $offset;

                if ( $_ == $ending_offset ) {
                    last;
                }

                push @queue, $_;
            }
        }
    }
}

my $move_count = 0;
my $idx        = $ending_offset;

while ( exists $parents{$idx} ) {
    $idx = $parents{$idx};
    ++$move_count;
}

say "Shortest path count: $move_count steps";

close $fh;
