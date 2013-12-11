package File::Logging;

##############################################################################
# Package   : Logging
# Methods   : See methods under _usage() or call new as Logging::new( "help" );
##############################################################################

use 5.006;
use strict;
use warnings;

=head1 NAME

File::Logging - OO File::Logging Perl library. Use this library to easily integrate file logging in your Perl scripts.

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';


=head1 SYNOPSIS

    use File::Logging;

    my $foo = File::Logging->new( 'help' );

=cut

use constant BLU => "\033[34;1m";
use constant GRE => "\033[32;1m";
use constant RED => "\033[31;1m";
use constant RST => "\033[0m";
use constant YEL => "\033[33;1m";

use Data::Dumper;
use Fcntl qw(:flock O_RDWR O_CREAT SEEK_END);
use Tie::File;

sub new( @ ) {
    my $class = shift;
    $_[0] =~ /^help$/i && do { _usage(); return; };
    my $self = { @_ }; 
    bless( $self, $class );
    $$self{"DBGLVL"} = 0 if ( ! defined $$self{"DBGLVL"} );
    $$self{"DEBUG"} = 0 if ( ! defined $$self{"DEBUG"} );
    if ( ! $$self{"DEFAULT"}{"PATH"} ) {
        $0 =~ /.*[\\\/](.+)/;
        $$self{"DEFAULT"}{"PATH"} = "$1.log";
        print STDERR qq(DEFAULT log not set, using '$$self{"DEFAULT"}{"PATH"}'.\n)
                   . qq(Run    'my \$l = File::Logging->new( "help" );'   for options.\n);

    }
    return( $self );
}

sub alert( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print RED . "[ALERT] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[ALERT] $_[0]", $l_log );
}

sub crit( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print RED . "[CRIT] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[CRIT] $_[0]", $l_log );
}

sub debug( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    return if ( ! $$self{"DEBUG"} );
    my( $l_print_TF, $l_debug_level );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    $l_debug_level = ( $_[0] =~ /^\d+$/ && defined $_[1] ) ? shift : 0;
    return if ( $l_debug_level > $$self{"DBGLVL"} );
    print BLU . "[DEBUG] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[DEBUG-LEVEL:$l_debug_level] $_[0]", $l_log );
}

sub emerg( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print RED . "[EMERGENCY] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[EMERGENCY] $_[0]", $l_log );
}

sub error( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print RED . "[ERROR] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[ERROR] $_[0]", $l_log );
}

sub fatal( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print RED . "[FATAL] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[FATAL] $_[0]", $l_log );
}

sub info( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print "[INFO] $_[0]\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[INFO] $_[0]", $l_log );
}

sub log( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );

    my( $l_log, $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    print "$_[0]\n" if ( $l_print_TF );

    my @la_tied_file;
    tie( @la_tied_file, 'Tie::File', $$self{"$l_log"}{"PATH"}, mode => O_RDWR | O_CREAT ) or do {
        warn( qq($!$@ - Can't tie to log file $$self{"$l_log"}{"PATH"} for writing!\n) );
        return;
    };

    if ( $$self{"$l_log"}{"MAXLINES"} && $#la_tied_file + 1 >= $$self{"$l_log"}{"MAXLINES"} ) {
        splice( @la_tied_file, 0, ($#la_tied_file + 2) - $$self{"$l_log"}{"MAXLINES"} );
    }

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
    $year += 1900;
    $mon  = ( $mon  =~ /^\d$/ ) ? "0$mon"  : $mon;
    $mday = ( $mday =~ /^\d$/ ) ? "0$mday" : $mday;
    $hour = ( $hour =~ /^\d$/ ) ? "0$hour" : $hour;
    $min  = ( $min  =~ /^\d$/ ) ? "0$min"  : $min;
    $sec  = ( $sec  =~ /^\d$/ ) ? "0$sec"  : $sec;

    push @la_tied_file, "$year$mon$mday$hour$min$sec $_[0]";
    untie( @la_tied_file );
}

sub normal( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print "[NORMAL] $_[0]\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[NORMAL] $_[0]", $l_log );
}

sub notice( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print YEL . "[NOTICE] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[NOTICE] $_[0]", $l_log );
}

sub success( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print GRE . "[SUCCESS] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[SUCCESS] $_[0]", $l_log );
}

sub warn( @ ) {
    my $self = shift;
    croak( "$self is not an object" ) if ( ! ref($self) );
    my( $l_print_TF );
    $l_print_TF = ( $_[0] =~ /^\-print/i ) ? shift : 0;
    print YEL . "[WARN] $_[0]" . RST . "\n" if ( $l_print_TF );
    return if ( $l_print_TF =~ /^\-print_only/i );
    my $l_log = ( scalar @_ gt 1 ) ? pop : "DEFAULT";
    my $l_pid = ( exists $$self{"PID"} && $$self{"PID"} || exists $$self{"$l_log"}{"PID"} && $$self{"$l_log"}{"PID"} ) ? "[PID:$$] " : "";
    $self->log( "${l_pid}[WARN] $_[0]", $l_log );
}

sub _usage() {
    print q(
    USAGE (File::Logging Package):
    ------------------------------------------------------------------------------
    my $l = File::Logging->new( "help" |
                          DEFAULT => {
                              PATH     => "<log path>",
                             [MAXLINES =>  <# lines>, ]
                             [PID      => {0|1}, ]  #write PID to this log file
                          },
                         #extra logs, i.e. log key named DEBUG would be your debug log
                         [<LOGKEY> => {
                              PATH     => "<log path>",
                             [MAXLINES =>  <# lines>, ]
                             [PID      => {0|1}, ]
                          },]
                         [DEBUG => {0|1}, [DBGLVL => <level#>, ]]
                         [PID   => {0|1}, ]     #writes the PID to all log files
                        );
    $l->alert(   ["-print|-print_only", ] <alert   msg>[, <LOG>] );
    $l->crit(    ["-print|-print_only", ] <crit    msg>[, <LOG>] );
    $l->debug(   ["-print|-print_only", [<dbglvl>, ]] <debug msg>[, <LOG>] );
    $l->emerg(   ["-print|-print_only", ] <emerg   msg>[, <LOG>] );
    $l->error(   ["-print|-print_only", ] <error   msg>[, <LOG>] );
    $l->fatal(   ["-print|-print_only", ] <fatal   msg>[, <LOG>] );
    $l->info(    ["-print|-print_only", ] <info    msg>[, <LOG>] );
    $l->log(     ["-print|-print_only", ] <log     msg>[, <LOG>] );
    $l->normal(  ["-print|-print_only", ] <normal  msg>[, <LOG>] );
    $l->notice(  ["-print|-print_only", ] <notice  msg>[, <LOG>] );
    $l->success( ["-print|-print_only", ] <success msg>[, <LOG>] );
    $l->warn(    ["-print|-print_only", ] <warn    msg>[, <LOG>] );

    Example:
    ------------------------------------------------------------------------------
    my $l = File::Logging->new(
                          "DEFAULT" => { "PATH" => "/tmp/default.log", "MAXLINES" => 5000 },
                          "SERVER"  => { "PATH" => "/tmp/server.log" },
                          "DEBUG"   => ( "@ARGV" =~ /-debug/i ) ? 1 : 0,
                          "DBGLVL"  => ( "@ARGV" =~ /-dbglvl:(\d+)/i ) ? $1 : 0,
                          "PID"     => 1,
                        );
    $l->info( "-print_only", "Started" );      #prints to screen only
    $l->info( "-print", "print to screen and default.log" );
    $l->debug( "-print", 3, "ARGS: @ARGV" );   #prints to screen and default.log, if -debug given
    $l->info( "-print", "Started", "SERVER" ); #prints to screen and server.log
    $l->info( "Started", "SERVER" );           #prints to server.log only

);
}

=head1 AUTHOR

Justin Francis, C<< <jfrancis at inbox.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-file-logging at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Logging>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc File::Logging


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-Logging>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/File-Logging>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/File-Logging>

=item * Search CPAN

L<http://search.cpan.org/dist/File-Logging/>

=back
=cut


#=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2013 Justin Francis.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1; # End of File::Logging
