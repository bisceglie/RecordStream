package Recs::Operation::eval;

use strict;
use warnings;

use base qw(Recs::Operation Recs::ScreenPrinter);

use Recs::Executor;

sub init {
   my $this = shift;
   my $args = shift;

   my $no_newline = 0;
   my $spec = {
      "--no-newline"  => \$no_newline,
   };

   $this->parse_options($args, $spec);
   if(!@{$this->_get_extra_args()}) {
      die "Missing expression\n";
   }
   my $expression = shift @{$this->_get_extra_args()};
   my $executor = Recs::Executor->new($expression);

   $this->{'EXECUTOR'}   = $executor;
   $this->{'NO_NEWLINE'} = $no_newline;
}

sub accept_record {
   my $this   = shift;
   my $record = shift;

   my $executor = $this->{'EXECUTOR'};
   my $value = $executor->execute_code($record);

   my $output = $value . "\n";
   if ( $this->{'NO_NEWLINE'} ) {
      $output = $value;
   }
   $this->print_value($output);
}

sub add_help_types {
   my $this = shift;
   $this->use_help_type('snippet');
   $this->use_help_type('keyspecs');
}

sub usage {
   my $usage =  <<USAGE;
Usage: recs-eval <args> <expr> [<files>]
   <expr> is evaluated as perl on each record of input (or records from
   <files>) with \$r set to a Recs::Record object and \$line set to the current
   line number (starting at 1).  The result of each evaluation is printed on a
   line by itself (this is not a recs stream).  See Recs::Record for help on
   what the \$r object can do.  See --help-snippets for more information on
   code snippets

   --no-newline - Do not put a newline after each record's output

Examples:
   Print the host field from each record.
      recs-eval '\$r->{host}'
   Prepare to gnuplot field y against field x.
      recs-eval '\$r->{x} . " " . \$r->{y}'
   Set up a script (this would be presumably piped to sh)
      recs-eval '"./myscript --value \$r->{foo}"'
USAGE
}

1;
