#!/usr/bin/env perl6

my $test = 'position=< 9,  1> velocity=< 0,  2>';
grammar LineEntry {
    rule TOP { 'position=' <point> 'velocity=' <point> }
    rule point { '<' (\-? \d+) ',' (\-? \d+) '>' }
}

class Point {
    has $.x;
    has $.y;
    has $.v-x;
    has $.v-y;

    method min() {
        my $min-x = 0;
        my $min-y = 0;
        if $.x < 0 {
            $min-x = abs($.x / $.v-x).ceiling;
        }
        if $.y < 0 {
            $min-y = abs($.y / $.v-y).ceiling;
        }
        return max($min-x, $min-y);
    }

    method move($count = 1) {
        $!x += ($.v-x * $count);
        $!y += ($.v-y * $count);
    }
}

class LineEntryAction {
    method TOP($/) {
        make Point.new(
            :x($/<point>[0].made[0]),
            :y($/<point>[0].made[1]),
            :v-x($/<point>[1].made[0]),
            :v-y($/<point>[1].made[1])
        );
    }
    method point($/) {
        make ($/[0].Int, $/[1].Int);
    }
}

sub print-stars(@points, $skip) {
    my $min-x = @points.map({ $_.x }).sort.head;
    my $max-x = @points.map({ $_.x }).sort.tail;
    my $min-y = @points.map({ $_.y }).sort.head;
    my $max-y = @points.map({ $_.y }).sort.tail;

    if $skip && ($min-x < 0 || $min-y < 0) {
        return False;
    }

    my %map;
    for @points {
        %map{ $_.y }{ $_.x } = '*';
    }
    for $min-y .. $max-y -> $y {
        if ! %map{$y} {
            say "{sprintf('%4d', $y)}:";
            next;
        }
        my @row = ($min-x..$max-x).map({ %map{$y}{$_} ?? '*' !! ' ' });
        say "{sprintf('%4d', $y)}: " ~ join "", @row;
    }
    return True;
}

sub MAIN (Str $filename, Bool $skip=False) {
    my $fh = open $filename, :r;
    my @points = $fh.lines.map({ LineEntry.parse( $_, actions => LineEntryAction.new).made });
    $fh.close;

    my @yarr = @points.map: *.min;
    say @yarr;

    my $min = @points.map(*.min).sort.tail;
    say "MIN: $min";
    @points.map: *.move($min);

    my $count = 0;
    loop {
        say "At step $count:";
        print-stars(@points, $skip) or do {
            ++$count;
            @points.map: *.move;
            next;
        };
        my $answer = prompt("Step forward? ");
        if $answer ~~ /^ y | yes $/ {
            ++$count;
            @points.map: *.move;
            next;
        }
        say "Last step: $count";
        last;
    }
}
