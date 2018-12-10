#!/usr/bin/env perl

no crap;
use experimentals;

package Node;
use Moo;
use experimental 'signatures';
has [qw<left right value>] => ( is => 'rw' );
sub place($self, $left, $right) {
    $self->left($left);
    $self->right($right);
    $left->right($self);
    $right->left($self);
}

sub rm ($self) {
    $self->left->right( $self->right );
    $self->right->left( $self->left );
    undef $self;
}

package Game;
use Moo;
use experimental 'signatures';
has 'current' => ( is => 'rw' );
sub add_marble ($self, $value) {
    if (! $self->current && $value == 0) {
        my $node = Node->new();
        $node->left($node);
        $node->right($node);
        $node->value($value);
        $self->current($node);
        return;
    }

    my $node = Node->new(value => $value);
    my $current = $self->current;
    $current = $current->right;
    my $right = $current->right;
    $node->place($current, $right);
    $self->current($node);
}

sub rm_marble($self) {
    my $current = $self->current;
    for (0..5) {
        $current = $current->left;
    }
    my $val = $current->left->value;
    $current->left->rm();
    $self->current($current);
    return $val;
}

package main;
use Data::Printer;

my $num_players = 477;
my $count = 7085100;

my @players = map { 0 } (0 .. $num_players - 1);
my $game = Game->new();
$game->add_marble(0);

for (my $value = 1; $value < $count ; ++$value) {
    if ($value % 10_000 == 0) {
       say "AT $value";
   }

    if ($value % 23 == 0) {
        my $player_idx = $value % $num_players;
        my $score = $game->rm_marble();
        $players[$player_idx] += $score + $value;
        next;
    }
    $game->add_marble($value);
}
@players = reverse sort @players;
say "Winner: " . $players[0];
