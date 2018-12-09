#!/usr/bin/env perl6

sub log(Any \msg) { say "[{DateTime.now()}] {msg.gist}"; }

class Point {
    has $.x;
    has $.y;
    has $.label;
    has $.total-distance;

    method distance($point) {
        return abs($.x - $point.x) + abs($.y - $point.y);
    }

    method mark($label, $total-distance) {
        die "Already marked!" if ?$.label;
        $!label = $label;
        $!total-distance = $total-distance;
    }
}

class Board {
    has %.board;
    has @.points;
    has $!max_x;
    has $!max_y;

    submethod TWEAK() {
        $!max_x = @!points.sort( *.x ).tail.x + 1;
        $!max_y = @!points.sort( *.y ).tail.y + 1;

        for ^$!max_x -> $x {
            say "AT $x.0 out of $!max_x.$!max_y";
            for ^$!max_y -> $y {
                my $point = Point.new(:$x, :$y);
                my %distances = @!points.map({
                    $_.label => $point.distance($_)
                });
                my $total = %distances.values.sum;
                my @sorted = %distances.sort( *.value );

                my $label = @sorted[0].key;
                if ?@sorted[1] && @sorted[0].value == @sorted[1].value {
                    $label = 'bunk';
                }
                $point.mark($label, $total);
                %!board{idx($x, $y)} = $point;
            }
        }
    }

    multi sub idx ($x, $y) { return "$x.$y" }

    ################################################################################

    method dump() {
        for ^$!max_x -> $x {
            my @row;
            for ^$!max_y -> $y {
                my $point = %!board{idx($x, $y)};
                @row.append(sprintf("%5s", %!board{idx($x, $y)}.label || '+'));
            }
            say @row.join;
        }
        say "\n";
    }

    method solve_part_one() {
        my @infinites;
        for ^$!max_x -> $x {
            @infinites.append(%!board{idx($x, 0)}.label);
            @infinites.append(%!board{idx($x, $!max_y - 1)}.label);
        }
        for ^$!max_y -> $y {
            @infinites.append(%!board{idx(0, $y)}.label);
            @infinites.append(%!board{idx($!max_x - 1, $y)}.label);
        }
        @infinites = @infinites.unique;
        @infinites.append('bunk');

        my %counts;
        for %!board.values.map({ $_.label }) -> $label {
            %counts{$label} //= 0;
            ++%counts{$label};
        }

        for %counts.pairs.sort(*.value).reverse -> $pair {
            next if $pair.key ~~ any @infinites;
            return $pair.value;
        }
        die "FAIL!!";
    }

    method solve_part_two(@source_points) {
        my $max_distance = 10_000;
        return %!board.values.grep( *.total-distance < 10_000 ).elems;
    }
}

################################################################################

log "Starting";
my $index = 'a';
my @points = $*IN.lines.map({
    my $m = $_ ~~ m/^ (\d+) ',' \s* (\d+) $/
        or die "Bunk line. :( {$_.gist}";
    my $label = $index++;
    Point.new(:x($m[0].Int), :y($m[1].Int), :$label)
});
log "Build source points";
#say $_ for @points;

log "Making board...";
my $board = Board.new(:@points);
log "Initialized board";

#$board.dump();

log "Solving part one";
my $answer = $board.solve_part_one();
log "Solution: $answer";

log "Solving part two";
$answer = $board.solve_part_two(@points);
log $answer;
