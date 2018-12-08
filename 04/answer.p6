#!/usr/bin/env perl6

sub log($msg) { say "[{DateTime.now()}] $msg"; }

class Record {
    has $.time;
    has $.action;
    has $.orig;
    has $.minute;

    method build-from-log($line) {
        my $m = $line ~~ /^ '[' (\d\d\d\d) '-' (\d\d) '-' (\d\d) ' ' (\d\d) ':' (\d\d) '] ' (.*) $/;
        return Record.new(
            time => $m[0].Str ~ $m[1].Str ~ $m[2].Str ~ $m[3].Str ~ $m[4].Str,
            minute => $m[4].Int,
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

    method falls-asleep($minute) { $!start-sleep = $minute; }
    method wakes-up($wake-up) {
        $.sleep-minutes += $wake-up - $!start-sleep;
        #say "$.id fell asleep from $!start-sleep to $wake-up!";
        for $!start-sleep ..^ $wake-up {
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
    when .falls-asleep { %guards{$id}.falls-asleep( .minute ); }
    when .wakes-up { %guards{$id}.wakes-up( .minute ); }
}

log('Determining sleepiest minutes');
.calculate-sleepiest-minute() for %guards.values;

# ? = "prefix ?^" = "convert the following value to a boolean"
my $dude = %guards.values.grep({ ?$_.sleep-minutes }).sort({ $_.sleep-minutes }).tail;
my $minute = $dude.sleepiest-minute;
say "Answer to part one is guard {$dude.id} @ {$minute.fmt("%s/%s")}: {$dude.id * $minute.key}";

$dude = %guards.values.grep({ ?$_.sleep-minutes }).sort({ $_.sleepiest-minute.value }).tail;
$minute = $dude.sleepiest-minute;
say "Answer to part two is guard {$dude.id} @ {$minute.fmt("%s/%s")}: {$dude.id * $minute.key}";
