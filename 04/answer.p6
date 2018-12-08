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
        my $m = $.orig ~~ / 'Guard #' (\d+) ' begins shift' /;
        return $m ?? $m[0].Int !! False
    }
    method falls-asleep() { return $.orig ~~ /'falls asleep'/; }
    method wakes-up() { return $.orig ~~ /'wakes up'/; }
}

class Guard {
    has $.id;
    has Int $.sleep-minutes is rw;
    has %.minutes;

    has $!start-sleep;
    has $.sleepiest-minute is rw;

    method build-guard($id) {
        return Guard.new(:id($id), :sleep-minutes(0));
    }

    method falls-asleep($time) { $!start-sleep = $time.minute; }
    method wakes-up($time) {
        my $wake-up = $time.minute;
        $.sleep-minutes += $wake-up - $!start-sleep;
        #say "$.id fell asleep from $!start-sleep to $wake-up!";
        for $!start-sleep .. $wake-up -1 {
            %.minutes{$_} //= 0;
            ++%.minutes{$_};
        }
    }

    method calculate-sleepiest-minute() {
        return unless %.minutes;
        $.sleepiest-minute = %.minutes.sort({ $_.value }).tail;
    }
}

log("Parse records");
my @records = $*IN.lines().map({ Record.build-from-log($_) }).sort: *.time;

log('Construct guards');
my %guards;
for @records.grep({$_.guard-id}).map: *.guard-id -> $id {
    %guards{$id} = Guard.new(:$id);
}

log('Record sleeping history');
my $id;
for @records {
    when so .guard-id() { $id = .guard-id; } # so = "force to bool"
    when .falls-asleep { %guards{$id}.falls-asleep( .time ); }
    when .wakes-up { %guards{$id}.wakes-up( .time ); }
}

log('Determining sleepiest minutes');
.calculate-sleepiest-minute() for %guards.values;

log('Solve part one');
my $sleepiest = %guards.values.grep({ ?$_.sleep-minutes }).sort({ $_.sleep-minutes }).tail;
say "Guard with the most minutes asleep:";
my $minute = $sleepiest.sleepiest-minute;
say "Sleepiest minute: {$minute.key}";

say "Answer to part one: " ~ ($sleepiest.id * $minute.key);

log('Solve part two');
$sleepiest = %guards.values.grep({ ?$_.sleep-minutes }).sort({ $_.sleepiest-minute.value }).tail;
$minute = $sleepiest.sleepiest-minute;
say $minute;
say "Answer to part two: " ~ ($sleepiest.id * $minute.key);
