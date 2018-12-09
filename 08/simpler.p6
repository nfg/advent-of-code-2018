#!/usr/bin/env perl6

# Me trying to figure out grammars.

use Grammar::Tracer;

grammar Simple {
    rule TOP {
        :my $num;
        \d+ { $num = $/.Int }
        \d ** { $num }
    }
}

my $data = "4 1 2 3 4";
say "Trying out $data";
say Simple.parse($data);

$data = "3 1 2 3 4";
say "Trying out $data";
say Simple.parse($data);
