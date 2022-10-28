#!/usr/bin/perl

package QemuImgScrap;

use strict;

use autodie;
use warnings;
no warnings qw(experimental::vlb);
use feature qw(current_sub);

sub process_supported_format_block {
    chomp(
        my $supported_formats_block = ${ shift @_ // die 'No format block argument passed'}
    );
    my $result;
    if ($supported_formats_block =~ /\ASupported formats: (?<formats>.+)\z/) {
        @$result = split /\s+/, $+{formats};
    } 
    $result;
}

sub process_header_block {
    my $header_block = [ 
        split /\n/, ${shift @_ // die 'No header block argument passed'} 
    ];
    my $result;
    foreach(@$header_block) {
        chomp;
        if(/version (?<version>(?:\d\.){2}\d)/) {
            $$result{version} = $+{version};
        }
    }
    $result;
}

sub process_command_syntax_block {
    my $command_syntax_blocks = [ split /\n/, ${ 
        shift @_ // die 'No command syntax block argument passed' 
    } ];
    #my match_optional=qq((?(DEFINE)(?<match_optional>(?:\[)(?:r^\[\]]|(?&match_optional))*(?:\]))));

    my $parse_params = sub {
        my $result;

        my $argument_list = $_[0];
        $_ = $argument_list;



        #1. Check optional arguments
        #   Fall in deep recursion in [statement] optional block
        #
        # arguments_lsit left without optional arguments
        my $optional_args_ref; # list of recursive defined map (of optional vals [ --like this ])
        while ( $argument_list =~ /(?:\[)(?<optional_value>(?:[^\[\]]|(?R))*)(?:\])\B/g ) {
            # Be careful in deep (infinity) recursion
            # print "{$_[1]} Optional value: $+{optional_value}\n";
            $argument_list = $` . ' ' . $';
            push @$optional_args_ref, __SUB__->($+{optional_value}, $_[1] + 1);
        }

        #2. Check alteration
        #   It only match high level alteration (Here only high level block left)
        #   eg.
        #       It will NOT match in [ statement1 | statement2 | ... ] block
        #       It WILL match "statement1 | statement2 | ..." 
        #   Fall in deep recursion for each statement
        my $alteration_ref;
        if ( $argument_list =~ m/\|(?![^\[\(]*(?:\]|\)))/) { #string conatins top level alteration (not in [] or () scope)
            while( $argument_list =~ /(?:\|)?(?<alteration>[^\|]+)(?:\|)?/g) {
                # Be careful in deep (infinity) recursion
                next unless defined $+{alteration};
                push @$alteration_ref, __SUB__->($+{alteration}, $_[1] + 1);
                $argument_list = $';
            }
        }


        my $options_ref; # list of maps ref (of finalized options)
        #todo: rewrite this regex
        while( $argument_list =~ /(?<!\| |\[|\()(?<=\A|\s)(?<option_name>--?(?:[\w-])+?(?=\s|=|\Z))(?:\s|=|\Z)(?<option_value>\w+)?/g ) {
            push @$options_ref, {
                name => $+{option_name},
                value => defined $+{option_value} ? $+{option_value} : "none",
            };
            $argument_list = $` . ' ' . $';
        }

        # Here in $argument list lefts only params (not args and not optionsal blocks) like: 
        # filename in  "command [-arg val] filename"
        $argument_list =~ s/\A\s+//;
        my $splited_params_ref = [ split /\s+(?![^\[\(]*(?:\]|\)))/, $argument_list ];
        my $params_ref;
        foreach( @$splited_params_ref ) {
            m/(?(DEFINE)(?<match_top_square>\[(?>[^\[\]]|(?&match_top_square))*\]))(?(DEFINE)(?<match_top_round>\((?>[^\(\)]|(?&match_top_round))*\)))(?<prefix>(?&match_top_square)|(?&match_top_round))?(?<param_name>[^=\s]+)(?:=(?<param_value>.*))?/;
            
            my $param;
            $$param{name} = $+{param_name};
            $$param{value} = $+{param_value} if defined $+{param_value};
            $$param{prefix} = __SUB__->($+{prefix}, $_[1] + 1) if defined $+{prefix};
            push @$params_ref, $param; 
        }
        # todo: alteration
        $$result{options} = $options_ref if defined $options_ref;
        $$result{'optional-args'} = $optional_args_ref if defined $optional_args_ref;
        $$result{params} = $params_ref if defined $params_ref and scalar(@$params_ref) != 0;
        $$result{alteration} = $alteration_ref if defined $alteration_ref;

        $result;
    };

    my $result;
    foreach(@$command_syntax_blocks) {
        chomp;
        if (/\A\s*\b(?<command_name>\w+)\b\s+/) {
            push @$result, {
                $+{command_name} => $parse_params->($', 0),
            }
        }
    }
    die 'Could not parse command name' unless defined $result;
    $result;
}

# Return true value from module
1;
