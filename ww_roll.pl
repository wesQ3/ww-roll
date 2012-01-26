use 5.12.0;
use Getopt::Long;
use Games::Dice::Advanced;

my $lowest_re_roll = 10;
my $lowest_success = 8;
my $verbose = undef;
GetOptions(
   'verbose' => \$verbose,
   'success|s=i' => \$lowest_success,
   're-roll|r=i' => \$lowest_re_roll,
);

my $d10 = Games::Dice::Advanced->new('d10');

my $count = $ARGV[0] || 1;
say "Rolling $count dice...";
my @result =  roll($count);

say join ' ', sort {$b <=> $a} @result if $verbose;

my $successes = scalar grep {$_ >= $lowest_success} @result;
say "$successes successes";

sub roll {
   my $count = shift;
   say "--rolling: $count dice" if $verbose;
   my @this_roll = map $d10->roll, 1..$count;
   my $next_count = scalar grep {$_ >= $lowest_re_roll} @this_roll;
   push @this_roll, roll($next_count) if $next_count;
   return @this_roll
}