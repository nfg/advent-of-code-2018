#!/usr/bin/env perl6

my $total = 0;
for $*IN.lines() {
    say "LINE: $_";
    $total += $_;
}

say "TOTAL: $total";
