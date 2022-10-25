#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use Cwd qw(getcwd);
use YAML;

BEGIN {
    unshift @INC, getcwd();
}

use QemuImgScrap;

my $supported_binaries = qw(
    qemu_img
);

my $qemu_binary = $ARGV[0] // die "binary not provided $!";
die "Binary file not match qemu binary file format. $!" unless -e -r -x $qemu_binary;

#TODO: Validation for binary file format


# Parse arguments
my ( $qemu_img ) = @ARGV; 
die "Qemu-img binary does not provided" unless defined $qemu_img;

# Make some additional file checking
die "qemu-img file doe's not sutable file format" unless -e -r -x $qemu_img;

my $qemu_img_help = undef;
$$qemu_img_help = qx($qemu_img --help);
my $qemu_img_blocks_ref = [ split /\n\n/, $$qemu_img_help ];

my (
    $header_block_ref,
    $command_syntax_block_ref,
    $command_params_block_ref,
) = \@$qemu_img_blocks_ref[0, 2, 3];


#my @subcommands_blocks = @$qemu_img_blocks_ref[3 .. $#$qemu_img_blocks_ref - 2 ];
my $supported_formats_block = \@$qemu_img_blocks_ref[-2];

print $$supported_formats_block, "\n";
#print Dump(&QemuImgScrap::process_supported_format_block($supported_formats_block));
#print Dump(&QemuImgScrap::process_header_block($header_block_ref));
print Dump(&QemuImgScrap::process_command_syntax_block($command_syntax_block_ref)), "\n";



