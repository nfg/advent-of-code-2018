#!/usr/bin/env perl6

sub log(Any \msg) { say "[{DateTime.now()}] {msg.gist}"; }

class Point {
    has $.x;
    has $.y;
}

class BoardPoint is Point {
    has $.label;
    has @.potentials;
    has $.resolved;

    method mark($label) {
        die "Already marked!" if $.resolved;
        $!label = $label;
        $!resolved = True;
    }
    method add-potential-label($label) {
        return False if $.resolved;
        return False if $label ~~ any @.potentials;
        @.potentials.append($label);
        return True;
    }
    method resolve {
        return False if $.resolved;
        return False unless @.potentials;
        $!resolved = True;
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
                %!board{idx($x, $y)}= BoardPoint.new(:resolved(False), :$x, :$y);
            }
        }
    }

    multi sub idx ($x, $y) { return "$x.$y" }

    ################################################################################

    # Step zero: Record the points.
    method add-point(Point $point, $label) {
        %!board{idx($point.x, $point.y)}.mark($label);
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
}

log "Starting";
my $index = 'a';
my %points = $*IN.lines.map({
    my $m = $_ ~~ m/^ (\d+) ',' \s* (\d+) $/
        or die "Bunk line. :( {$_.gist}";
    $index++ => Point.new(:x($m[0].Int), :y($m[1].Int))
});
log "Loaded points";

my $max_x = %points.values.sort( *.x ).tail.x + 1;
my $max_y = %points.values.sort( *.y ).tail.y + 1;
log "Maximums: x: $max_x y: $max_y";

my $board = Board.new(:$max_x, :$max_y);
log "Initialized board";

$board.add-point($_.value, $_.key) for %points.pairs;
log "Added points";

loop {
    $board.dump();
    $board.find-potential-points();
    last unless $board.resolve();
}
$board.dump();
