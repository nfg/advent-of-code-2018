#!/usr/bin/env perl6

my $counter = 0;
my %seen = ( $counter => 1 );

my @lines = $*IN.lines();
my @inf_lines = lazy gather {
    while True { take $_ for @lines }
};

for @inf_lines {
    $counter += $_;
    if %seen{$counter} {
        say "DUPLICATED FREQ: $counter";
        exit;
    }
    %seen{$counter} = 1
}
