#!/usr/bin/env perl6

grammar LineEntry {
    rule TOP { 'position=' <point> 'velocity=' <point> }
    rule point { '<' (\-? \d+) ',' (\-? \d+) '>' }
}

class ListOfPoints {
    has @.points;
    method move() { @.points.map: *.move; }
    method range-x() {
        my @sorted = @.points.map({$_.x}).sort;
        return @sorted.head, @sorted.tail;
    }
    method range-y() {
        my @sorted = @.points.map({$_.y}).sort;
        return @sorted.head, @sorted.tail;
    }
}

class Point {
    has $.x;
    has $.y;
    has $.v-x;
    has $.v-y;

    method move() {
        $!x += $.v-x;
        $!y += $.v-y;
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

sub print-stars($list) {
    my ($min-x, $max-x) = $list.range-x;
    my ($min-y, $max-y) = $list.range-y;

    my %map;
    for $list.points {
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
}

sub MAIN (Str $filename) {
    my $fh = open $filename, :r;
    my @points = $fh.lines.map({ LineEntry.parse( $_, actions => LineEntryAction.new).made });
    my $list = ListOfPoints.new(:@points);
    $fh.close;

    my $count = 0;
    my $range = 100;

    $list.move for ^10000;

    loop {
        my ($min-x, $max-x) = $list.range-x;
        my $x = $max-x - $min-x;
        my ($min-y, $max-y) = $list.range-y;
        my $y = $max-y - $min-y;
        if $count %% 100 {
            say "AT $count [$x $y]";
        }
        last if $x < 100 && $y < 50;

        NEXT { ++$count; $list.move }
    }

    my $quit;
    loop {
        say "At step $count:";
        print-stars($list);
        loop {
            my $answer = prompt("Step forward? ");
            last if $answer ~~ /^ y | yes $/;
            if $answer ~~ /^ n | no $/ {
                $quit = True;
                last;
            }
        }
        last if $quit;
        ++$count;
        $list.move;
    }
    say "Last step: $count";
}
