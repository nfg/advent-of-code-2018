#!/usr/bin/env perl6

sub log(Any \msg) { say "[{DateTime.now()}] {msg.gist}"; }

sub they-match ($left, $right) {
    return $left ne $right && $left.fc eq $right.fc;
}

sub reduce-polymer(@polymer) {
    my $index = 1;
    loop {
        last if $index == @polymer.elems;
        if they-match(|@polymer[$index - 1, $index]) {
            @polymer.splice($index - 1, 2, ());
            --$index unless $index == 1;
            next;
        }
        ++$index;
    }
    return @polymer.elems;
}

log("Reading in data");
my @polymer = |$*IN.lines.head.split("").grep: * ne "";

{
    my @copy = @polymer;
    log("Solving part one");
    my $answer = reduce-polymer(@copy);
    log "Answer to part one: $answer";
}

{
    log("Getting uniques");
    my @uniques = @polymer.unique(:as(&lc)); # lc, uniques.
    log @uniques;
    my %result;
    for @uniques -> $char {
        log("Calculating for $char");
        my @copy = @polymer.grep({ $_.fc ne $char.fc });
        my $ret = reduce-polymer(@copy);
        %result{$char} = $ret;
    }

    log("Finding final answer");
    log %result;
    my $ret = %result.sort( *.value ).head;
    log("Answer to part two: {$ret.key} with length of {$ret.value}");
}
