#!/usr/bin/env perl6

sub log(Any \msg) { say "[{DateTime.now()}] {msg.gist}"; }

class FuelCell {
    has $.x is required;
    has $.y is required;
    has $.power-level;
    has $.answer is rw;

    submethod TWEAK() {
        $!answer = 0;
    }

    method calculate($serial-number) {
        my $rack-id = $.x + 10;
        my $power-level = ($rack-id * $!y + $serial-number) * $rack-id;
        my $hundreds = Int($power-level / 100) % 10;
        $!power-level = $hundreds - 5;
    }
}

class Grid {
    # indices start at 1.
    # x,y = 300, 300 means from 1,1 to 300,300
    has $.x;
    has $.y;
    has %.vals;
    has $.serial-number;

    sub _key($x, $y) {
        return "{$x},{$y}";
    }

    method calculate() {
        for 1 .. $!x -> $x {
            for 1 .. $!y -> $y {
                my $cell = FuelCell.new(:$x, :$y);
                $cell.calculate($.serial-number);
                my $key = _key($x, $y);
                #say "Setting $key to $cell";
                %.vals{_key($x, $y)} = $cell;
            }
        }
    }

    method propagate() {
        for 3 .. $!x -> $x {
            for 3 .. $!y -> $y {
                my $value = %.vals{_key($x, $y) }.power-level;
                for $x - 2 .. $x -> $other-x {
                    for $y - 2 .. $y -> $other-y {
                        %.vals{_key($other-x, $other-y)}.answer += $value;
                    }
                }
            }
        }
    }
    method solve-part-one() {
        my $cell = %.vals.values.sort({ $_.answer }).tail;
        say "{$cell.x},{$cell.y}";
    }
}

say "Part one";

my @serial-numbers = <18 42 1723>;
for @serial-numbers -> $serial-number {
    log "Creating grid for $serial-number";
    my $grid = Grid.new(:x(300), :y(300), :$serial-number);
    log "Calculating everything";
    $grid.calculate;
    log "Propagating values";
    $grid.propagate;
    log "Solve part one";
    $grid.solve-part-one;
}
