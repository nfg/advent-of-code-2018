#!/usr/bin/env perl6

class Point {
    has Int $.x;
    has Int $.y;
    has Int $.v-x;
    has Int $.v-y;

    method displace($count) {
        my $x = $!x + ($count * $.v-x);
        my $y = $!y + ($count * $.v-y);
        return Point.new(:$x, :$y, :$.v-x, :$.v-y);
    }
}

class StarMap {
    has @.points;
    has Int $!min-x;
    has Int $!max-x;
    has Int $!min-y;
    has Int $!max-y;
    has Int $.count;

    my %memo;

    submethod TWEAK() {
        my @sorted = @!points.map({$_.x}).sort;
        $!min-x = @sorted.head;
        $!max-x = @sorted.tail;
        @sorted = @!points.map({$_.y}).sort;
        $!min-y = @sorted.head;
        $!max-y = @sorted.tail;
        return;
    }

    method displace($count) {
        my @new-list = @.points.map: *.displace($count);
        return StarMap.new(:points(@new-list), :$count);
    }
    method area() {
        return abs($!max-x - $!min-x) * abs($!max-y - $!min-y);
    }

    method print-stars() {
        return if self.area() > 10_000;

        my %map;
        %map{ $_.y }{ $_.x } = '*' for @.points;
        for $!min-y .. $!max-y -> $y {
            if ! %map{$y} {
                say "{sprintf('%4d', $y)}:";
                next;
            }
            my @row = ($!min-x..$!max-x).map({ %map{$y}{$_} ?? '*' !! ' ' });
            say "{sprintf('%4d', $y)}: " ~ join "", @row;
        }
    }
    # -1 = shrinking
    # 0  = found
    # +1 = growing
    method check() {
        if ?%memo{$!count} {
            return %memo{$!count}
        }

        my $previous = self.displace(-1);
        my $next = self.displace(1);
        my $answer = 1;
        if self.area < $previous.area {
            # FOUND!
            $answer = self.area < $next.area ?? 0 !! -1;
        }
        return %memo{$!count} = $answer;
    }
}

grammar LineEntry {
    rule TOP { 'position=' <point> 'velocity=' <point> }
    rule point { '<' (\-? \d+) ',' (\-? \d+) '>' }
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

sub MAIN (Str $filename, Int $step = 10000, Bool $interactive = False) {
    die "Invalid step!" if $step <= 0;
    my $fh = open $filename, :r;
    my @points = $fh.lines.map({ LineEntry.parse( $_, actions => LineEntryAction.new).made });
    my $map = StarMap.new(:@points, :count(0));
    $fh.close;

    my $next-step = $step;
    my $count = 0;
    my $moving-forward = True;
    my $new-map;
    my $quit;

    # Fake binary search.
    loop {
        $new-map = $map.displace($count);

        my $result = $new-map.check;
        if $result == -1 {
            # It's shrinking
            if ! $moving-forward {
                $next-step = Int($next-step / 2);
                say "Moving forward (numbers shrinking) [$next-step]" if $interactive;
                die "BUNK STEP!" if $next-step < 1;
            }
            $moving-forward = True;
        }
        elsif $result == 1 {
            if $moving-forward {
                $next-step = Int($next-step / 2);
                say "Moving backward (numbers increasing) [$next-step]" if $interactive;
                die "BUNK STEP!" if $next-step < 1;
            }
            $moving-forward = False;
        }
        else {
            last;
        }

        $new-map.print-stars if $interactive;
        $quit = False;
        my $next = $moving-forward ?? $count + $next-step !! $count - $next-step;
        if ! $interactive {
            $count = $next;
            next;
        }

        loop {
            say "AT COUNT $count [next $next]";
            my $answer = prompt("Continue? ");
            last if $answer ~~ /^ y | yes $/;
            if $answer ~~ /^ n | no | q | quit $/ {
                $quit = True;
                last;
            }
        }
        last if $quit;
        $count = $next;
    }
    if ! $quit {
        say "SOLVED (?) AT $count";
        $new-map.print-stars;
    }
    exit;
}
