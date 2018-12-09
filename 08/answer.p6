#!/usr/bin/env perl6

sub log(Any \msg) { say "[{DateTime.now()}] {msg.gist}"; }

class Node {
    has @.children;
    has @.metadata;
    method add-metadata() {
        my $child-metadata = [+] @.children.map: *.add-metadata();
        return @.metadata.sum + $child-metadata;
    }
    method part2() {
        return @.metadata.sum unless @.children;
        return @.metadata.map({
            my $node = @.children[$_ - 1];
            ?$node ?? $node.part2 !! 0;
        }).sum;
    }
}

class ParseState {
    has $.data;
    has $.root-node;

    method parse() {
        $!root-node = self.parse-node();
    }

    method parse-node() {
        my $m = $!data ~~ s/^ $<num-children>=(\d+) \s+ $<num-metadata>=(\d+) \s+ //;
        my (@children, @metadata);
        @children.append(self.parse-node) for ^$m<num-children>.Int;
        @metadata.append(self.parse-metadata) for ^$m<num-metadata>.Int;
        return Node.new(:@children, :@metadata);
    }

    method parse-metadata() {
        my $m = $!data ~~ s/^ (\d+) \s+ //;
        return $m[0].Int;
    }

    method add-metadata() {
        return $!root-node.add-metadata();
    }

    method part2() {
        return $!root-node.part2();
    }
}

my $data = $*IN.lines.first ~ ' ';
my $state = ParseState.new(:$data);
log "Parsing input data!";
$state.parse();
log "And done!";
log "Part one: " ~ $state.add-metadata();
log "Part two: " ~ $state.part2;
