#!/usr/bin/env perl6

# Reimplemented solution using grammars. It was hard to work out,
# but it works!

#use Grammar::Tracer; # See https://github.com/jnthn/grammar-debugger

sub log(Any \msg) { say "[{DateTime.now()}] {msg.gist}"; }

class Node {
    has @.children;
    has @.metadata;

    method part1() {
        my $child-metadata = [+] @.children.map: *.part1();
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

grammar InputData {
    token TOP { <node> }
    token num-children { \d+ }
    token num-metadata { \d+ }
    token metadata { \d+ }

    rule node {
        # I couldn't figure out how to pass in the matched values
        # without temporary variables. :(

        # Prefixing with ":" lets us declare variables.
        :my ($num-children, $num-metadata);

        # The curly-braces let us include normal code.
        <num-children> { $num-children = $<num-children>.Int }
        <num-metadata> { $num-metadata = $<num-metadata>.Int }
        <children($num-children)>
        <metadata-list($num-metadata)>
    }

    rule children($num) { <node> ** {$num} }
    rule metadata-list($num) { <metadata> ** {$num} }
}

# Yeah, so the methods here take the match object from before and convert
# to useful data. "make" sets the result for "made" for the match object, I think.
#
# The method names correspond to the rules in the grammar.
class InputDataActions {
    method TOP($/) {
        make $<node>.made;
    }
    method node($/) {
        make Node.new(:children($<children>.made), :metadata($<metadata-list>.made));
    }
    method children($/) {
        make $<node>.map: *.made;
    }
    method metadata-list($/) {
        make $<metadata>.map: *.Int;
    }
}

my $data = $*IN.lines.first;
log "Parsing the data";
my $root_node = InputData.parse($data, actions => InputDataActions.new).made;
log "Complete!";
log "Answer for part one: {$root_node.part1}";
log "Answer for part two: {$root_node.part2}";
log "DONE!";


