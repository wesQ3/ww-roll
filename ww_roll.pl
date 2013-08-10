#!/usr/bin/env perl

use 5.14.1;
use warnings;

use Getopt::Long::Descriptive;
use Games::Dice::Advanced;

my ($opt, $usage) = describe_options(
  'ww_roll %o <some-arg>',
  [ 'reroll|r=i',  'Minimum to reroll',         { default => 10 }],
  [ 'dice|x=i',    'Amount of dice to roll',    { default => 1 } ],
  [ 'success|s=i', 'Minimum value for success', { default => 8 } ],
  [ 'accumulate|a=i', 'Count attempts to reach required successes', { default => 0 } ],
  [ 'total|t=i', 'Total successes in limited attempts', { default => 0 } ],
  [],
  [ 'verbose|v',   'verbose'                                     ],
  [ 'help|h',     'view help'                                    ],
);

print($usage->text), exit if $opt->help;
say("Can't do that."), exit if $opt->accumulate && $opt->total;

if ($opt->accumulate) {
   say sprintf 'Accumulating %d successes',$opt->accumulate;
   my ( $super_total, $attempt_count ) = 0;
   while ($super_total < $opt->accumulate) {
      $super_total += attempt();
      $attempt_count++;
   }
   say "Succeeded in $attempt_count attempts";
} elsif ($opt->total) {
   say sprintf 'Totalling %d attempts',$opt->total;
   my $super_total = 0;
   $super_total += attempt() for 1..$opt->total;
   say "$super_total total successes";
} else {
   printf "Expected successes: %.2f\n", $opt->dice*(11 - $opt->success)/($opt->reroll - 1);
   attempt()
}

sub attempt {
   say 'Rolling ' . $opt->dice . ' dice...';
   my @result =  roll($opt->dice);
   say join ' ', sort {$b <=> $a} @result if $opt->verbose;
   my $successes = scalar grep {$_ >= $opt->success} @result;
   say "$successes successes";
   return $successes
}

sub roll {
   state $d10 = Games::Dice::Advanced->new('d10');
   my $count = shift;
   say "--rolling: $count dice" if $opt->verbose;
   my @this_roll = map $d10->roll, 1..$opt->dice;
   my $next_count = scalar grep {$_ >= $opt->reroll} @this_roll;
   push @this_roll, roll($next_count) if $next_count;
   return @this_roll
}
