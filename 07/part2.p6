#!/usr/bin/env perl6

my $num-workers = 5;
my $base-time = 60;
class GraphNode {
    has @.prereqs;
    has $.name;
    has $.active is rw;

    method add-prereq($name) { @.prereqs.append($name) }
    method rm-prereq($name) {
        @.prereqs = @.prereqs.grep(* ne $name);
    }
    method satisfied() { ! $.active && ! @.prereqs }
    method time-needed () {
        return ord($.name) - ord('A') + 1 + $base-time;
    }
}

class Worker {
    has $.current-job;
    has $.finish-time;
    method check-state ($time, %nodes, @result) {
        my $free = $time >= $.finish-time;
        if ?$.current-job && $free {
            @result.append($.current-job);
            %nodes{$.current-job}:delete;
            $_.rm-prereq($.current-job) for %nodes.values;
            $!current-job = False;
        }
        return $free;
    }
    method start (GraphNode $node, $time) {
        $node.active = True;
        $!current-job = $node.name;
        $!finish-time = $time + $node.time-needed;
    }
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
my @workers;
for ^$num-workers { @workers.append(Worker.new(:finish-time(-1))) };
my $time = -1;
loop {
    ++$time;
    my @free-workers = @workers.grep: *.check-state($time, %nodes, @result);
    last if ! %nodes && @free-workers.elems == @workers.elems;

    for @free-workers -> $worker {
        my $next = %nodes.values.grep(*.satisfied).sort(*.name).first
            or next;

        $worker.start($next, $time);
    }
    say sprintf("%4s", $time) ~ ": " ~ @workers.map({ sprintf("%4s", $_.current-job || 'free')}).join(" ");

}
say "Finished @ $time: {@result.join}";
