#!/usr/bin/env perl6

use v6;

# Find the two strings differing by only one letter.

my @strings = $*IN.lines().map: { S:g/\W// }; # S = non-destructive substitution

while @strings.shift -> $string {
    if ! @strings.Bool { last }

    my @chars = $string.comb;
    my $last = @chars.end;

    for @chars.keys -> $index {
        my $prefix = $index > 0 ?? @chars[0..$index-1].join !! "";
        my $suffix = $index == $last ?? "" !! @chars[$index+1..$last].join;

        # "any" makes this about 2x faster.
        if any @strings ~~ /^ $prefix . $suffix $/ {
            say "MATCH: $prefix$suffix";
        }
    }
}
