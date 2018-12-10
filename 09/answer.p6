#!/usr/bin/env perl6

class Game {
    has @.circle;
    has $!current = 0;

    method add-marble($value) {
        if ! @.circle {
            @.circle[0] = $value;
            $!current = 0;
            return 0;
        }

        my $location = ($!current + 2) % @.circle.elems;
        if $location == 0 { $location = @.circle.elems };
        splice @.circle, $location, 0, ($value);
        $!current = $location;
        return 0;
    }

    method rm-marble() {
        my $to-kill = ($!current - 7) % @.circle.elems;
        my $val = @.circle[$to-kill] or die "WTF??";

        splice @.circle, $to-kill, 1, ();
        $!current = $to-kill % @.circle.elems;
        return $val;
    }

    method process($value) {
        if $value %% 23 && $value > 0 {
            return $value + self.rm-marble();
        }
        return self.add-marble($value);
    }

    method dump($count) {
        my @vals = @.circle.keys.map({
            my $val = @.circle[$_];
            $_ == $!current ?? "($val)" !! $val;
        });
        say "[$count] {@vals}";
    }
}

class Player {
    has $.score is rw = 0;
}

multi sub MAIN(Int $num-players, Int :$count) {
    my @players;
    @players.append(Player.new) for ^$num-players;
    my $player-idx = -1;

    my $game = Game.new;
    for ^$count -> $value {
        if $value %% 10_000 { say "AT $value"; }
        $player-idx = ($player-idx + 1) % $num-players;
        my $score = $game.process($value);
        @players[$player-idx].score += $score;
        #$game.dump($value);
    }

    say "[$_]: {@players[$_].score}" for @players.keys;
    say "Winner: " ~ @players.sort(*.score).tail.score;
}

#multi sub MAIN(Int $num-players, Int :$score) {
#    my @players;
#    @players.append(Player.new) for ^$num-players;
#    my $player-idx = -1;
#
#    my $game = Game.new;
#    my $value = -1;
#    loop {
#        $player-idx = ($player-idx + 1) % $num-players;
#        ++$value;
#
#        my $turn-score = $game.process($value);
#        if $turn-score {
#            say "Turn score: $turn-score";
#        }
#        @players[$player-idx].score += $turn-score;
#        last if $turn-score == $score;
#
#        die ":( -- value = $value" if $value/2 >= $score;
#    }
#
#    say "[$_]: {@players[$_].score}" for @players.keys;
#    say "Winner: " ~ @players.sort(*.score).tail.score;
#}


