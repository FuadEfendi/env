#!/usr/bin/env PERL5OPT=-T perl
#
# Copyright (c) 2001, 2015, Oracle and/or its affiliates. All rights reserved.
#
#    NAME
#    opatch.pl
#
#    SYNOPSIS
#    perl opatch [ -n ] [ -x ] [ -h ] < command > < command_options >
#
#    DESCRIPTION
#    Front end to the opatch, the one-off patch tool for installing
#    patches to the Oracle RDBMS.
#
#    NOTES
#    1.    This is meant to be invoked with a perl interpreter.
#    2.    Version 5.6.0 or later should be used.
#    3.    This front-end module checks the environment, parses the 
#          commands and then calls the module to do the real work.
#    4.    All commands must be idempotent.
#    5.    Data structures are detailed in the package that relates to 
#          their class. So the Command data structure is in Command.pm.
#    6.    Yes, this is just a byzantine dispatch table that doesn't
#          exec its own environment.
#    7.    For notes on speed please see the footnote on pg 340 of
#          Programming Perl by L. Wall, T. Christiansen and J. Orwent 
#          [ O'Reilly & Associates ], Ed 3, 2000.
#    8.    If, at some later stage, the environment needs to be manipulated
#          to ensure this works:
#          a. this script should be moved into the  directory
#             (say to opatch_real), and
#          b. a wrapper script should be created that manipulates the 
#             environment and finishes with invoking this script.
#
#    BUGS
#    * <if you know of any bugs, put them here!>
#
#    MODIFIED   (MM/DD/YY)
#    opatch  09/03/15 - To update the year of copyright
#    opatch  04/15/02 - daevans_patch_programs
#    opatch  11/28/01 - Updated code and comments.
#    opatch  11/01/01 - Initial coding.
#
##########################################################################

###############################################################################
###############################################################################
#
#  ------------------------ INITIALIZATION ------------------------
#
###############################################################################
###############################################################################

use lib Opatch_Modules;

######
#
# Standard modules:
#
use English;         # Let us say "$CHILD_ERROR" instead of "$?", etc.
use strict;          # Enforce strict variables, refs, subs, etc.


# Check perl >= 5.6.0 to minimize version differences.
require 5.6.0;

# Command.pm initializes the command set and associated attributes.
use Command();

my $current_perl = $EXECUTABLE_NAME;
my $current_name = $PROGRAM_NAME;

# Get the current command set.
my $rh_command_list = &Command::build_command_list();

# Count the number of commands. It's in the design spec, that's why.
#my $count = Command->number_of_commands({ rh_command_list=>$rh_commands });

# Now check the command line to see if there is anything there or if
# they asked for help. If calling usage the program exits!.
if ( ( ! defined($ARGV[0]) ) || 
     ( ( $ARGV[0] =~ /^-h(elp)?$/ ) && ( ! defined($ARGV[1]) ) ) ) {
    &main::usage({ rh_commands => $rh_command_list });
    exit 0;
}

my $rh_command_line = &main::parse_arguments( {
                                      ra_arguments    => \@ARGV,
                                      rh_command_list => $rh_command_list } );

if ( ! defined $rh_command_line ) {
    print "\nProblem with parsing the opatch command.\n";
    &main::usage({ rh_commands => $rh_command_list });
    exit 0;
}

my $class = ref ( $rh_command_line );
$class -> validate_command_line_input({ rh_command_line => $rh_command_line,
                                        rh_command_list => $rh_command_list } );

# Now, did they ask for help on the command? If so exit after showing the
# help message.
if ( grep ( /^-h(elp)?$/, @ARGV ) ) {
    $class -> display_help( { command         => $$rh_command_line{command},
                              rh_command_list => $rh_command_list } );
    exit 0;
}

if ( exists $$rh_command_line{invalid} ) {
    print "$current_name error:\n $$rh_command_line{invalid}\n";
    exit 0;
}


# If things got to here we're OK. Lets do some real processing now.
$class -> abdomen ( { arguments       => $$rh_command_line{arguments},
                      command         => $$rh_command_line{command},
                      rh_command_list => $rh_command_list } );


# End of opatch().

###############################################################################
#
# NAME   : parse_arguments
#
# PURPOSE: A method that checks the command line arguments and prepares
#          to execute one of the opatch subcommands if needed.
#
# INPUTS : $$ARG[ra_arguments]   - A reference to the @ARGV array from the
#                                      command line.
#          $$ARG[rh_command_list]    - A hash containing the valid commands
#                                      and associated attributes.
#
# OUTPUTS: \%executable_command      - A reference to a hash that contains
#                                      the details of what to do.
#
# NOTES  : 1. The options accept a single letter or the full string. This 
#             means "-x" or "-xhtml" is valid but not "-xh". This may be
#             useful if the number of options grows in the future and a
#             greater degree of control is needed.
#
###############################################################################
sub parse_arguments {

    my $rh_arguments    = $ARG[0];

    my $ra_arguments    = $$rh_arguments{ra_arguments};
    my $rh_command_list = $$rh_arguments{rh_command_list};

    # OK, we need someplace to store the results. I guess another blessed
    # hash will be needed as this will be used to invoke the real module.
    my $rh_real_command = undef; 

    # Some flag variables. Yes, it can be done much more efficiently but
    # this is meant to be readable. Using one byte for all the flags is
    # great for optimization but hard on the reader.
    my $error_flag = 0;
    my $command_is = 0;
    my $help_flag  = 0;
    my $no_op_flag = 0;
    my $xhtml_flag = 0;

    my $argv_array_size = scalar ( @$ra_arguments );
    for ( my $i = 0; $i < $argv_array_size; $i++ ) {

        # It's less typing.
        my $arg = $$ra_arguments[$i];

        # List global options first, then commands. I like it that way.
        if ( $arg =~ /^-h(elp)?$/ ) {
            $help_flag = 1;

        } elsif ( $arg =~ /^-n(o_op)?$/ ) {
            $no_op_flag = 1;

        } elsif ( $arg =~ /^-x(html)?$/ ) {
            $xhtml_flag = 1;

        } elsif ( ( ! $command_is ) && ( $arg =~ /^apply$/ ) ) {
            $command_is = $arg;
            my $class = ucfirst ( lc $arg );
            $rh_real_command = $class -> bless_hash();
            $$rh_real_command{command} = $arg;

        } elsif ( ( ! $command_is ) && ( $arg =~ /^lsinventory$/ ) ) {
            $command_is = $arg;
            my $class = "LsInventory";
            $rh_real_command = $class -> bless_hash();
            $$rh_real_command{command} = $arg;

        } elsif ( ( ! $command_is ) && ( $arg =~ /^rollback$/ ) ) {
            $command_is = $arg;
            my $class = "RollBack";
            $rh_real_command = $class -> bless_hash();
            $$rh_real_command{command} = $arg;

        } elsif ( ( ! $command_is ) && ( $arg =~ /^version$/ ) ) {
            $command_is = $arg;
            my $class = ucfirst ( lc $arg );
            $rh_real_command = $class -> bless_hash();
            $$rh_real_command{command} = $arg;

        } elsif ( $command_is ) {
            # There is a valid command with extra arguments. Append the
            # details into a string for validation later.
            $$rh_real_command{arguments} .= $arg . " ";

        } else {
            $error_flag = 1;
        }
    }

    # Since these may have appeared before the command was detected add them
    # back into place with the other arguments but only if there was a command
    # given.
    if ( $rh_real_command ) {
        if ( $help_flag ) { 
            $$rh_real_command{arguments} = 
                                     "-help " . $$rh_real_command{arguments};
        }
        if ( $no_op_flag ) { 
            $$rh_real_command{arguments} = 
                                     "-no_op " . $$rh_real_command{arguments};
        }
        if ( $xhtml_flag ) { 
            $$rh_real_command{arguments} = 
                                     "-xhtml " . $$rh_real_command{arguments};
        }
    }

    if ( ! $rh_real_command ) {
        print "\n No command given.\n";
    }
    
    if ( $error_flag ) {
        $rh_real_command = undef; 
    }
        
    return $rh_real_command;

}   # End of parse_arguments().

##############################################################################
#
# NAME   : usage
#
# PURPOSE: Display usage
#
# INPUTS : $$ARG[rh_commands] - A reference to a hash structure that is an
#                               instantiation of the class Command.
#
# OUTPUTS: To STDOUT.
#
# NOTES  : 1. It's much easier to do this as hardwired strings than to do 
#             by building a string from the hash keys and then cleaning up
#             the output.
#          2. This is a "here doc" so any variables need to be setup before
#             it starts. Also note the formatting change being absolute
#             on the screen instead of relative ( as in print() ).
#
##############################################################################
sub usage {

    my $rh_arguments = $ARG[0];

    my $rh_commands  = $$rh_arguments{rh_commands};

    # On string could be used but they do have different tasks.
    my $command_list = "";
    my $global_args  = "";
    foreach my $command ( sort (keys %$rh_commands) ) {

        # Allow for "lsinventory" and one space.
        my $long_string = 12;
        my $pad = $long_string - (length ( $command ));
        

        if ( $command !~ m#^-# ) {
            # Do the commands.
            $command_list = $command_list . $command . "\n" . " "x23;
        } else {
            # Handle the global arguments. Longest string is 6 bytes
            # so pad to make the display nice.
            $global_args = $global_args . $command . " "x$pad . "(" .
                           $$rh_commands{$command}{_helpText} . ")\n" .
                           " "x23;
        }
    }
    # Strip off last new line and 23 spaces.
    ( $command_list ) = ( $command_list =~ m#(.+)\n {23}$#s );

    # Start of "here doc".
    print STDOUT <<END_OF_USAGE

 Usage: opatch { [ -h[elp] ] [ -n[o_op] ] [ -x[html] ] [ command ] }

            command := $command_list

 <global_arguments> := $global_args

END_OF_USAGE
;
}   # End of usage().

##############################################################################
#
# End of opatch file.
#
##############################################################################
