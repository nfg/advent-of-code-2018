#!/usr/bin/env perl6
use v6;

grammar Claim {
    token TOP { '#' <id> \s '@' \s <left> ',' <top> ':' \s <width> 'x' <height> }

    token id { \d+ }
    token left { \d+ }
    token top { \d+ }
    token width { \d+ }
    token height { \d+ }
}

class Rectangle {
    has Int $.id;
    has Int $.left;
    has Int $.top;
    has Int $.width;
    has Int $.height;

    method from_claim($claim) {
        fail "Bunk claim!" unless $claim;
        # Is there a better way of doing this?
        return Rectangle.new(
            id => $claim<id>.Int,
            left => $claim<left>.Int,
            top => $claim<top>.Int,
            width => $claim<width>.Int,
            height => $claim<height>.Int,
        );
    }

    method contains( $x, $y ) {
        return $.left ≤ $x && $x ≤ $.left + $.width && $.top ≤ $y && $y ≤ $.top + $.height;
    }

    method stamp(%map) {
        for $.left .. ($.left + $.width - 1) -> $x {
            for $.top .. ($.top + $.height - 1) -> $y {
                %map{"$x.$y"} //= 0;
                %map{"$x.$y"}++;
                #say "$x.$y = " ~ %map{"$x.$y"};
            }
        }
    }

    method unique(%map) {
        for $.left .. ($.left + $.width - 1) -> $x {
            for $.top .. ($.top + $.height - 1) -> $y {
                return False if %map{"$x.$y"} != 1;
            }
        }
        return True;
    }
}

sub log($msg) { say "[{DateTime.now()}] $msg"; }

log("Building rectangles");
my @rectangles = $*IN.lines().map: {
    my $claim = Claim.parse($_);
    Rectangle.from_claim($claim);
};

log("Building maps");
my %map;
$_.stamp(%map) for @rectangles;

log("Finding overlaps");
say "Num overlapping squares: " ~ %map.values.grep({ $_ > 1 }).elems();

log("Finding unique rectangles");
for @rectangles -> $rect {
    if $rect.unique(%map) {
        say "UNIQUE: " ~ $rect.id;
    }
}

log("DONE!");
