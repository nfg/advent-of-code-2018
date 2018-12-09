#!/usr/bin/env perl6

sub log(Any \msg) { say "[{DateTime.now()}] {msg.gist}"; }

class Point {
    has $.x;
    has $.y;
    has $.label;

    method distance($point) {
        return abs($.x - $point.x) + abs($.y - $point.y);
    }
}

class BoardPoint is Point {
    has $.label;
    has @.potentials;

    method mark($label) {
        die "Already marked!" if ?$!label;
        $!label = $label;
    }
    method add-potential-label($label) {
        return False if ?$.label;
        return False if $label ~~ any @.potentials;
        @.potentials.append($label);
        return True;
    }
    method resolve {
        return False if ?$.label;
        return False unless @.potentials;
        my $found_label = @.potentials.elems == 1;
        $!label = $found_label ?? @.potentials[0] !! 'bunk';
        return True;
    }
}

class Board {
    has %.board;
    has $.max_x;
    has $.max_y;
    has %!potentials;
    # List of next round of points to check.
    has @!next;

    submethod TWEAK() {
        for ^$!max_x -> $x {
            for ^$!max_y -> $y {
                %!board{idx($x, $y)}= BoardPoint.new(:$x, :$y);
            }
        }
    }

    multi sub idx ($x, $y) { return "$x.$y" }

    ################################################################################

    # Step zero: Record the points.
    method add-point(Point $point) {
        %!board{idx($point.x, $point.y)}.mark($point.label);
        @!next.append($point);
    }

    # Step one: Find potential new points.
    method find-potential-points() {
        return unless @!next;
        my @points = @!next;
        @!next = ();

        for @points -> $point {
            my ($x, $y) = ($point.x, $point.y);
            my $board_point = %!board{idx($x, $y)};
            my $label = $board_point.label;
            die "No label found :(" unless ?$label;

            self.add-potential-point($x - 1, $y, $label);
            self.add-potential-point($x + 1, $y, $label);
            self.add-potential-point($x, $y - 1, $label);
            self.add-potential-point($x, $y + 1, $label);
        }
    }

    # Step two: Add potential new points.
    method add-potential-point(Int $x, Int $y, Str $label) {
        my $idx = idx($x, $y);
        my $point = %!board{$idx};
        return unless $point && $point.add-potential-label($label);
        %!potentials{$idx} = $point; # Track changes to be resolved.
    }

    # Step three: Resolve potential points.
    method resolve() {
        @!next = %!potentials.values.grep: *.resolve();
        %!potentials = ();
        return @!next.Bool;
    }

    method dump() {
        for ^$!max_x -> $x {
            my @row;
            for ^$!max_y -> $y {
                my $point = %!board{idx($x, $y)};
                @row.append(sprintf("%5s", %!board{idx($x, $y)}.label || '+'));
            }
            say @row.join;
        }

        if %!potentials {
            say "Potential points to resolve";
            say "{$_.x}.{$_.y} - {$_.potentials}" for %!potentials.values;
        }
        if @!next {
            say "\nAlso, the next points to look at";
            say @!next.map({"{$_.x}.{$_.y}"}).join(", ");
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
        my @ok_points;
        for ^$!max_x -> $x {
            for ^$!max_y -> $y {
                my $label = %!board{idx($x, $y)}.label;
                my $point = Point.new(:$x, :$y, :$label);
                my $total_distance = @source_points.map({ $point.distance($_)}).sum;
                next unless $total_distance < $max_distance;
                @ok_points.append($point);
            }
        }
        return @ok_points.elems();
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
log "Loaded points";

my $max_x = @points.sort( *.x ).tail.x + 1;
my $max_y = @points.sort( *.y ).tail.y + 1;
log "Maximums: x: $max_x y: $max_y";

my $board = Board.new(:$max_x, :$max_y);
log "Initialized board";

$board.add-point($_) for @points;
log "Added points";

loop {
    #$board.dump();
    $board.find-potential-points();
    last unless $board.resolve();
}
log "Constructed board";
#$board.dump();

log "Solving part one";
my $answer = $board.solve_part_one();
log "Solution: $answer";

log "Solving part two";
$answer = $board.solve_part_two(@points);
log $answer;
