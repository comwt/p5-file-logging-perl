#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'File::Logging' ) || print "Bail out!\n";
}

diag( "Testing File::Logging $File::Logging::VERSION, Perl $], $^X" );
