#!/usr/bin/env perl6

class GraphNode {
    has @.prereqs;
    has $.name;
    method add-prereq($name) { @.prereqs.append($name) }
    method rm-prereq($name) {
        @.prereqs = @.prereqs.grep(* ne $name);
    }
    method satisfied() { ! @.prereqs }
}

my %nodes;
for $*IN.lines -> $line {
    my $m = $line ~~ m/'Step ' (\w+) ' must be finished before step ' (\w+) ' can begin.'/;
    die "Bunk line: $_" unless $m;
    for $m[0].Str, $m[1].Str -> $name {
        %nodes{$name} //= GraphNode.new(:$name);
    }
    %nodes{$m[1].Str}.add-prereq($m[0].Str);
}

my @result;
while (%nodes) {
    my $next = %nodes.values.grep(*.satisfied).sort(*.name).first
        or die "Nothing is possible. :(";
    @result.append($next.name);
    %nodes{$next.name}:delete;
    $_.rm-prereq($next.name) for %nodes.values;
    #say @result;
}
say @result.join;
