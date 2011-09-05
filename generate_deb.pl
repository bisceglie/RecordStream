#!/usr/bin/perl -w

use strict;
use BuildTools qw(run_command);
use File::Glob qw(glob);

my $DIST_DIR = 'deb-dist';

my $CLEAN_COMMANDS = {
   debian    => 'rm -rf debian',
   Makefile  => 'make clean',
   $DIST_DIR => "rm -rf $DIST_DIR",
};

cleanup($CLEAN_COMMANDS);

if ( $ARGV[0] eq '--clean' ) {
   print "Clean only, bailing!\n";
   exit 0;
}

run_command('perl Makefile.PL');
run_command('make dist');

my @found_tars = glob('App-RecordStream-*.tar.gz');

if ( scalar @found_tars > 1 ) {
   die "Found more than one tar file: " . join(' ', @found_tars);
}

my $tar = $found_tars[0];

mkdir $DIST_DIR;
run_command("cp $tar $DIST_DIR");
chdir $DIST_DIR;
run_command("tar -xzvf $tar");

my $dir = $tar;
$dir =~ s/\.tar\.gz$//;

chdir $dir;

run_command('dh-make-perl --depends gnuplot --build .');
run_command('sed -e \'s/perl\///g\' -i debian/control');
run_command('debuild -i -us -uc -b');

chdir '..';
run_command('cp *.deb ..');

sub cleanup {
   my $commands = shift;

   foreach my $file (keys %$commands) {
      my $command = $commands->{$file};
      if ( -e $file ) {
         run_command($command);
      }
   }
}
