#!/usr/bin/env perl6

class Node {
    has $.left is rw;
    has $.right is rw;
    has $.value;

    method place($left, $right) {
        $.left = $left;
        $.right = $right;
        $left.right = self;
        $right.left = self;
    }

    method rm() {
        $.left.right = $.right;
        $.right.left = $.left;
    }
}

class Game {
    has $.current;
    multi method add-marble(0) {
        $!current = Node.new(:value(0));
        $!current.left = $!current;
        $!current.right = $!current;
    }

    multi method add-marble($value) {
        my $node = Node.new(:$value);
        $!current = $!current.right;
        my $right = $!current.right;
        $node.place($right.left, $right);
        $!current = $node;
    }

    method rm-marble() {
        for ^6 {
            $!current = $!current.left;
        }
        my $val = $!current.left.value;
        $!current.left.rm();
        return $val;
    }
}

multi sub MAIN(Int $num-players, Int :$count) {
    my @players;
    @players.append(0) for ^$num-players;

    my $game = Game.new;
    $game.add-marble(0);

    for 1..^$count -> $value {
        if $value %% 10_000 { say "AT $value"; }

        if $value %% 23 {
            my $player-idx = $value % $num-players;
            my $score = $game.rm-marble();
            @players[$player-idx] += $score + $value;
            next;
        }
        $game.add-marble($value);
    }

    #say "[$_]: {@players[$_].score}" for @players.keys;
    say "Winner: " ~ @players.values.sort.tail;
}


