#!/usr/bin/env perl6

# To run: cat input.txt | perl6 answer.p6

say "PART ONE";

my @lines = $*IN.lines();

say "Resulting frequency: " ~ @lines.sum;

say "PART TWO";

my @inf_lines = lazy gather {
    while True { take $_ for @lines }
};

my $counter = 0;
my %seen;
for @inf_lines {
    $counter += $_;
    if %seen{$counter} {
        say "DUPLICATED FREQ: $counter";
        exit;
    }
    %seen{$counter} = 1
}
