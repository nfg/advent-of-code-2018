#!/usr/bin/env perl6

use v6;

# Calculate some bullshit checksum based on the input.

my $with_two = 0;
my $with_three = 0;

for $*IN.lines() -> $line {
    my %matches;

    for $line.comb(/\w/) -> $char {
        %matches{$char}++;
    }
    $with_two += 1 if %matches.values().grep({ $_ == 2 }).Bool;
    $with_three += 1 if %matches.values().grep({ $_ == 3 }).Bool;
}

say $with_two * $with_three;
