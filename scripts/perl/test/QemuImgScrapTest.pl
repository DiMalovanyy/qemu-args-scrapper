#!/usr/bin/perl

package QemuImgScrapTest;

use Cwd qw(getcwd);
use Path::Class;

use strict;
use warnings;
use autodie;

BEGIN {
    my $current_dir = Path::Class::File->new(getcwd());
    unshift @INC, $current_dir->parent->stringify;
}

use QemuImgScrap qw(
    process_command_syntax_block 
    process_header_block 
    process_supported_format_block
);

use Test::More tests => 3;
use Test::Deep;

sub test_process_command_syntax_block {
    plan tests => 1;

    my $test_basic = sub {
        plan tests => 1;
        
        # 1. Basic input with optional different args types and one param
        # ammend in my qemu-img version looks like
        my $input_basic_1 = <<"HEREDOC";
    amend [--object objectdef] [--image-opts] [-p] [-q] [-f fmt] [-t cache] [--force] -o options filename
HEREDOC


    };
    subtest 'Basic parse' => $test_basic;
}

sub test_header_block {
    plan tests => 1;
 
   my $test_basic = sub {
        plan tests => 1;
        my $input = <<"HEREDOC";
qemu-img version 7.1.0
Copyright (c) 2003-2022 Fabrice Bellard and the QEMU Project developers
usage: qemu-img [standard options] command [command options]
QEMU disk image utility
HEREDOC
        my $exepect_output = { version => '7.1.0' };
        my $output = &QemuImgScrap::process_header_block(\$input);
        cmp_deeply($output, $exepect_output);
   };
   subtest 'Basic parse' => $test_basic;
}

sub test_supported_format_block {
    plan tests => 1;

    # todo (dmalovan): need to verify input on specific characters, because
    #   supported_formats just match any format after "Supported formats:" string unless \n, splited by ' '
    my $test_basic = sub {
        plan tests => 1;
        my $input = <<"HEREDOC";
Supported formats: cow gcow2 
HEREDOC
        my $expect_output = [ "cow", "gcow2" ]; 
        my $output = &QemuImgScrap::process_supported_format_block(\$input);
        cmp_deeply($output, $expect_output);
    };
    subtest 'Basic parse' => $test_basic;
}


subtest 'Header block' => \&test_header_block;
subtest 'Process command syntax block' => \&test_process_command_syntax_block;
subtest 'Suppotrted format block' => \&test_supported_format_block;

__END__
