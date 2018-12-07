#!/usr/bin/env perl6
use v6;

# To run: cat input.txt | perl6 answer.p6

my @lines = $*IN.lines();

say "Find the two strings differing by only one letter.";

my @strings = @lines.map: { S:g/\W// }; # S = non-destructive substitution

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

say "Calculate some bullshit checksum based on the input.";

my $with_two = 0;
my $with_three = 0;

for @lines -> $line {
    my %matches;

    for $line.comb(/\w/) -> $char {
        %matches{$char}++;
    }
    $with_two += 1 if %matches.values().grep({ $_ == 2 }).Bool;
    $with_three += 1 if %matches.values().grep({ $_ == 3 }).Bool;
}

say $with_two * $with_three;
