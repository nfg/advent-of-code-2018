#!/usr/bin/env perl6

sub log($msg) { say "[{DateTime.now()}] $msg"; }

class Record {
    has $.time;
    has $.action;
    has $.orig;

    method build-from-log($line) {
        my $m = $line ~~ /^ '[' (\d\d\d\d) '-' (\d\d) '-' (\d\d) ' ' (\d\d) ':' (\d\d) '] ' (.*) $/;
        return Record.new(
            time => DateTime.new(:year($m[0].Int), :month($m[1].Int), :day($m[2].Int), :hour($m[3].Int), :minute($m[4].Int)),
            action => $m[5].Str,
            orig => $m.orig,
        );
    }
    method guard-id() {
        if $.orig ~~ / 'Guard #' (\d+) ' begins shift' / -> $m {
            return $m[0].Int;
        }
        return False
    }
    method falls-asleep() {
        my $m = $.orig ~~ /'falls asleep'/;
        return $m.Bool;
    }
    method wakes-up() {
        my $m = $.orig ~~ /'wakes up'/;
        return $m.Bool;
    }
}

class Guard {
    has $.id;
    has Int $.sleep-minutes is rw;
    has %.minutes;

    has $!start-sleep;
    method build-guard($id) {
        return Guard.new(:id($id), :sleep-minutes(0));
    }

    method falls-asleep($time) { $!start-sleep = $time.minute; }
    method wakes-up($time) {
        my $wake-up = $time.minute;
        $.sleep-minutes += $wake-up - $!start-sleep;

        say "$.id fell asleep from $!start-sleep to $wake-up!";

        for $!start-sleep .. $wake-up - 1 {
            %.minutes{$_} //= 0;
            ++%.minutes{$_};
        }
    }

    method sleepiest-minute() {
        return %.minutes.sort({ $_.value }).tail.key;
    }
}

log("Parse records");
my @records = $*IN.lines().map({ Record.build-from-log($_) }).sort: *.time;

log('Construct guards');
my %guards;

say @records;

for @records.grep({$_.guard-id}) {
    my $id = .guard-id;
    my $guard = Guard.new(:$id);
    %guards{$id} = $guard;
}

log('Record sleeping history');
my $id;
for @records {
    if .guard-id() {
        $id = .guard-id;
    }
    elsif .falls-asleep {
        %guards{$id}.falls-asleep( .time );
    }
    elsif .wakes-up {
        %guards{$id}.wakes-up( .time );
    }
    else {
        fail "Unexpected input!";
    }
}

my $sleepiest = %guards.values.grep({ ?$_.sleep-minutes }).sort({ $_.sleep-minutes }).tail;
say "Guard with the most minutes asleep:";
say $sleepiest;
my $minute = $sleepiest.sleepiest-minute();
say "Sleepiest minute: $minute";

say "Answer to part one: " ~ ($sleepiest.id * $minute)

