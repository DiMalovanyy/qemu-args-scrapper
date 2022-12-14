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
use Data::Dumper;

sub test_process_command_syntax_block {
    plan tests => 1;

    my $test_basic = sub {
        plan tests => 12;
       
        {
            # 1. Basic input with optional different args types and one param
            # amend in my qemu-img version looks like
            my $input_basic_amend = <<"HEREDOC";
        amend [--object objectdef] [--image-opts] [-p] [-q] [-f fmt] [-t cache] [--force] -o options filename
HEREDOC
            my $expect_output = [{
                amend=>{
                    options=>[{name =>'-o',value=>'options'}],
                    params=>[{'name'=>"filename"}],
                    'optional-args' => [ 
                        {options=>[{name=>'--object',value=>'objectdef'}]},
                        {options=>[{name=>'--image-opts',value=>'none'}]},
                        {options=>[{name=>'-p',value=>'none'}]},
                        {options=>[{name=>'-q',value=>'none'}]},
                        {options=>[{name=>'-f',value=>'fmt'}]},
                        {options=>[{name=>'-t',value=>'cache'}]},
                        {options=>[{name=>'--force',value =>'none'}]},
                    ],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_amend);
            cmp_deeply($output, $expect_output, "qemu-img basic [amend]");
        }

        {
            # 2. Simple bench command (prety same as amend)
            my $input_basic_bench = <<"HEREDOC";
        bench [-c count] [-d depth] [-f fmt] [--flush-interval=flush_interval] [-i aio] [-n] [--no-drain] [-o offset] [--pattern=pattern] [-q] [-s buffer_size] [-S step_size] [-t cache] [-w] [-U] filename
HEREDOC
            my $expect_output = [{
                'bench'=>{ 
                    'optional-args'=>[
                        {'options'=>[{'name'=>'-c','value'=>'count'}]},
                        {'options'=>[{'name'=>'-d','value'=>'depth'}]},
                        {'options'=>[{'value'=>'fmt','name'=>'-f'}]},
                        {'options'=>[{'value'=>'flush_interval','name'=>'--flush-interval'}]},
                        {'options'=>[{'name'=>'-i','value'=>'aio'}]},
                        {'options'=>[{'name'=>'-n','value'=>'none'}]},
                        {'options'=>[{'value'=>'none','name'=>'--no-drain'}]},
                        {'options'=>[{'name'=>'-o','value'=>'offset'}]},
                        {'options'=>[{'value'=>'pattern','name'=>'--pattern'}]},
                        {'options'=>[{'name'=>'-q','value'=>'none'}]},
                        {'options'=>[{'name'=>'-s','value'=>'buffer_size'}]},
                        {'options'=>[{'name'=>'-S','value'=>'step_size'}]},
                        {'options'=>[{'value'=>'cache','name'=>'-t'}]},
                        {'options'=>[{'value'=>'none','name'=>'-w'}]},
                        {'options'=>[{'name'=>'-U','value'=>'none'}]},
                    ],
                    'params'=>[{'name'=>'filename'}],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_bench);
            cmp_deeply($output, $expect_output, "qemu-img basic [bench]");
        }

        {
            # 3. Simple commit command (logic same as above)
            my $input_basic_commit = <<"HEREDOC";
        commit [--object objectdef] [--image-opts] [-q] [-f fmt] [-t cache] [-b base] [-r rate_limit] [-d] [-p] filename
HEREDOC
            my $expect_output = [{
                'commit'=>{
                    'optional-args'=>[
                        {'options'=>[{'value'=>'objectdef','name'=>'--object'}]},
                        {'options'=>[{'value'=>'none','name'=>'--image-opts'}]},
                        {'options'=>[{'value'=>'none','name'=>'-q'}]},
                        {'options'=>[{'name'=>'-f','value'=>'fmt'}]},
                        {'options'=>[{'name'=>'-t','value'=>'cache'}]},
                        {'options'=>[{'name'=>'-b','value'=>'base'}]},
                        {'options'=>[{'value'=>'rate_limit','name'=>'-r'}]},
                        {'options'=>[{'name'=>'-d','value'=>'none'}]},
                        {'options'=>[{'name'=>'-p','value'=>'none'}]},
                    ],
                    'params'=>[{'name'=>'filename'}],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_commit);
            cmp_deeply($output, $expect_output, "qemu-img basic [commit]");
        }

        {
            # 4. Simple  rebase logic
            my $input_basic_rebase = <<"HEREDOC";
    rebase [--object objectdef] [--image-opts] [-U] [-q] [-f fmt] [-t cache] [-T src_cache] [-p] [-u] -b backing_file [-F backing_fmt] filename
HEREDOC
            my $expect_output = [{
                'rebase'=>{
                    'optional-args'=>[
                        {'options'=>[{'name'=>'--object','value'=>'objectdef'}]},
                        {'options'=>[{'name'=>'--image-opts','value'=>'none'}]},
                        {'options'=>[{'name'=>'-U','value'=>'none'}]},
                        {'options'=>[{'value'=>'none','name'=>'-q'}]},
                        {'options'=>[{'value'=>'fmt','name'=>'-f'}]},
                        {'options'=>[{'name'=>'-t','value'=>'cache'}]},
                        {'options'=>[{'name'=>'-T','value'=>'src_cache'}]},
                        {'options'=>[{'value'=>'none','name'=>'-p'}]},
                        {'options'=>[{'value'=>'none','name'=>'-u'}]},
                        {'options'=>[{'value'=>'backing_fmt','name'=>'-F'}]},
                    ],
                    'options'=>[{'name'=>'-b', 'value'=>'backing_file'}],
                    'params'=>[{'name'=>'filename'}],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_rebase);
            cmp_deeply($output, $expect_output, "qemu-img basic [rebase]");
        }

        {
            # 5. qemu-img compare (two params)
            my $input_basic_compare = <<"HEREDOC";
    compare [--object objectdef] [--image-opts] [-f fmt] [-F fmt] [-T src_cache] [-p] [-q] [-s] [-U] filename1 filename2
HEREDOC
            my $expect_output = [{
                'compare'=>{
                    'params'=>[{'name'=>'filename1'},{'name'=>'filename2'}],
                    'optional-args'=>[
                        {'options'=>[{'value'=>'objectdef','name'=>'--object'}]},
                        {'options'=>[{'value'=>'none','name'=>'--image-opts'}]},
                        {'options'=>[{'name'=>'-f','value'=>'fmt'}]},
                        {'options'=>[{'name'=>'-F','value'=>'fmt'}]},
                        {'options'=>[{'name'=>'-T','value'=>'src_cache'}]},
                        {'options'=>[{'value'=>'none','name'=>'-p'}]},
                        {'options'=>[{'value'=>'none','name'=>'-q'}]},
                        {'options'=>[{'name'=>'-s','value'=>'none'}]},
                        {'options'=>[{'value'=>'none','name'=>'-U'}]},
                    ],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_compare);
            cmp_deeply($output, $expect_output, "qemu-img basic [compare]");
        }

        {
            # 6.qemu-img dd (no params only options & params with =)
            my $input_basic_dd = <<"HEREDOC";
    dd [--image-opts] [-U] [-f fmt] [-O output_fmt] [bs=block_size] [count=blocks] [skip=blocks] if=input of=output
HEREDOC
            my $expect_output = [{
                'dd'=>{
                    'params'=>[
                        {'name'=>'if','value'=>'input'},
                        {'name'=>'of','value'=>'output'},
                    ],
                    'optional-args'=>[
                        {'options'=>[{'value'=>'none','name'=>'--image-opts'}]},
                        {'options'=>[{'value'=>'none','name'=>'-U'}]},
                        {'options'=>[{'value'=>'fmt','name'=>'-f'}]},
                        {'options'=>[{'name'=>'-O','value'=>'output_fmt'}]},
                        {'params'=>[{'name'=>'bs','value'=>'block_size'}]},
                        {'params'=>[{'name'=>'count','value'=>'blocks'}]},
                        {'params'=>[{'name'=>'skip','value'=>'blocks'}]},
                    ],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_dd);
            cmp_deeply($output, $expect_output, "qemu-img basic [dd]");
        }

        {
            # 7. qemu-img info (very common)
            my $input_basic_info = <<"HEREDOC";
    info [--object objectdef] [--image-opts] [-f fmt] [--output=ofmt] [--backing-chain] [-U] filename
HEREDOC
            my $expect_output = [{
                'info'=>{
                    'optional-args'=>[
                        {'options'=>[{'name'=>'--object','value'=>'objectdef'}]},
                        {'options'=>[{'name'=>'--image-opts','value'=>'none'}]},
                        {'options'=>[{'name'=>'-f','value'=>'fmt'}]},
                        {'options'=>[{'name'=>'--output','value'=>'ofmt'}]},
                        {'options'=>[{'name'=>'--backing-chain','value'=>'none'}]},
                        {'options'=>[{'name'=>'-U','value'=>'none'}]},
                    ],
                    'params'=>[{'name'=>'filename'}],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_info);
            cmp_deeply($output, $expect_output, "qemu-img basic [info]");
        } 
        {
            # 8. qemu-img map (very common)
            my $input_basic_map = <<"HEREDOC";
    map [--object objectdef] [--image-opts] [-f fmt] [--start-offset=offset] [--max-length=len] [--output=ofmt] [-U] filename
HEREDOC
            my $expect_output = [{
                'map'=>{
                    'optional-args'=>[
                        {'options'=>[{'name'=>'--object','value'=>'objectdef'}]},
                        {'options'=>[{'name'=>'--image-opts','value'=>'none'}]},
                        {'options'=>[{'value'=>'fmt','name'=>'-f'}]},
                        {'options'=>[{'value'=>'offset','name'=>'--start-offset'}]},
                        {'options'=>[{'name'=>'--max-length','value'=>'len'}]},
                        {'options'=>[{'name'=>'--output','value'=>'ofmt'}]},
                        {'options'=>[{'name'=>'-U','value'=>'none'}]},
                    ],
                    'params'=>[{'name'=>'filename'}],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_map);
            cmp_deeply($output, $expect_output, "qemu-img basic [map]");
        }
        {
            # 9. qemu-img snapshot (alteration)
            my $input_basic_snapshot = <<"HEREDOC";
    snapshot [--object objectdef] [--image-opts] [-U] [-q] [-l | -a snapshot | -c snapshot | -d snapshot] filename
HEREDOC
            my $expect_output = [{
                'snapshot'=>{
                    'optional-args'=>[
                        {'options'=>[{'name'=>'--object','value'=>'objectdef'}]},
                        {'options'=>[{'name'=>'--image-opts','value'=>'none'}]},
                        {'options'=>[{'name'=>'-U','value'=>'none'}]},
                        {'options'=>[{'value'=>'none','name'=>'-q'}]},
                        {'alteration'=>[
                            {'options'=>[{'name'=>'-l','value'=>'none'}]},
                            {'options'=>[{'name'=>'-a','value'=>'snapshot'}]},
                            {'options'=>[{'name'=>'-c','value'=>'snapshot'}]},
                            {'options'=>[{'name'=>'-d','value'=>'snapshot'}]},
                        ]},
                    ],
                    'params'=>[{'name'=>'filename'}],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_snapshot);
            cmp_deeply($output, $expect_output, "qemu-img basic [snapshot]");
        }

        {
            # 10.  qemu-img resize (param additional prefix)
            my $input_basic_resize = <<"HEREDOC";
    resize [--object objectdef] [--image-opts] [-f fmt] [--preallocation=prealloc] [-q] [--shrink] filename [+ | -]size
HEREDOC
            my $expect_output = [{
                'resize'=>{
                    'optional-args'=>[
                        {'options'=>[{'value'=>'objectdef','name'=>'--object'}]},
                        {'options'=>[{'value'=>'none','name'=>'--image-opts'}]},
                        {'options'=>[{'name'=>'-f','value'=>'fmt'}]},
                        {'options'=>[{'name'=>'--preallocation','value'=>'prealloc'}]},
                        {'options'=>[{'value'=>'none','name'=>'-q'}]},
                        {'options'=>[{'name'=>'--shrink','value'=>'none'}]},
                    ],
                    'params'=>[
                        {'name'=>'filename'},
                        {
                            'name'=>'size',
                            'prefix'=>{
                                'optional-args'=>[
                                    {'alteration'=>[
                                        {'params'=>[{'name'=>'+'}]},
                                        {'params'=>[{'name'=>'-'}]},
                                    ]},
                                ],
                            },
                        },
                    ],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_resize);
            cmp_deeply($output, $expect_output, "qemu-img basic [resize]");
        }

        {
            # 11. qemu-img create (optional param after required param + nested optional)
            my $input_basic_create = <<"HEREDOC";
    create [--object objectdef] [-q] [-f fmt] [-b backing_file [-F backing_fmt]] [-u] [-o options] filename [size]
HEREDOC
            my $expect_output = [{
                'create'=>{
                    'optional-args'=>[
                        {'options'=>[{'value'=>'objectdef','name'=>'--object'}]},
                        {'options'=>[{'value'=>'none','name'=>'-q'}]},
                        {'options'=>[{'name'=>'-f','value'=>'fmt'}]},
                        {
                            'options'=>[{'value'=>'backing_file','name'=>'-b'}],
                            'optional-args'=>[
                                {'options'=>[{'value'=>'backing_fmt','name'=>'-F'}]},
                            ],
                        },
                        {'options'=>[{'value'=>'none','name'=>'-u'}]},
                        {'options'=>[{'value'=>'options','name'=>'-o'}]},
                        {'params'=>[{'name'=>'size'}]},
                    ],
                    'params'=>[{'name'=>'filename'}],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_create);
            cmp_deeply($output, $expect_output, "qemu-img basic [create]");
        }

        {
            # 12. convert (multiple params)
            my $input_basic_convert = << "HEREDOC";
    convert [--object objectdef] [--image-opts] [--target-image-opts] [--target-is-zero] [--bitmaps] [-U] [-C] [-c] [-p] [-q] [-n] [-f fmt] [-t cache] [-T src_cache] [-O output_fmt] [-B backing_file [-F backing_fmt]] [-o options] [-l snapshot_param] [-S sparse_size] [-r rate_limit] [-m num_coroutines] [-W] [--salvage] filename [filename2 [...]] output_filename
HEREDOC
            my $expect_output = [{
                'convert'=>{
                    'optional-args'=>[
                        {'options'=>[{'name'=>'--object','value'=>'objectdef'}]},
                        {'options'=>[{'value'=>'none','name'=>'--image-opts'}]},
                        {'options'=>[{'name'=>'--target-image-opts','value'=>'none'}]},
                        {'options'=>[{'name'=>'--target-is-zero','value'=>'none'}]},
                        {'options'=>[{'name'=>'--bitmaps','value'=>'none'}]},
                        {'options'=>[{'name'=>'-U','value'=>'none'}]},
                        {'options'=>[{'name'=>'-C','value'=>'none'}]},
                        {'options'=>[{'name'=>'-c','value'=>'none'}]},
                        {'options'=>[{'value'=>'none','name'=>'-p'}]},
                        {'options'=>[{'value'=>'none','name'=>'-q'}]},
                        {'options'=>[{'name'=>'-n','value'=>'none'}]},
                        {'options'=>[{'name'=>'-f','value'=>'fmt'}]},
                        {'options'=>[{'value'=>'cache','name'=>'-t'}]},
                        {'options'=>[{'name'=>'-T','value'=>'src_cache'}]},
                        {'options'=>[{'value'=>'output_fmt','name'=>'-O'}]},
                        {
                            'options'=>[{'value'=>'backing_file','name'=>'-B'}],
                            'optional-args'=>[
                                {'options'=>[{'name'=>'-F','value'=>'backing_fmt'}]},
                            ],
                        },
                        {'options'=>[{'value'=>'options','name'=>'-o'}]},
                        {'options'=>[{'name'=>'-l','value'=>'snapshot_param'}]},
                        {'options'=>[{'value'=>'sparse_size','name'=>'-S'}]},
                        {'options'=>[{'name'=>'-r','value'=>'rate_limit'}]},
                        {'options'=>[{'value'=>'num_coroutines','name'=>'-m'}]},
                        {'options'=>[{'name'=>'-W','value'=>'none'}]},
                        {'options'=>[{'value'=>'none','name'=>'--salvage'}]},
                        {'params'=>[{'name'=>'filename2'}],'optional-args'=>[{'params'=>[{'name'=>'...'}]}]},
                    ],
                    'params'=>[
                        {'name'=>'filename'},
                        {'name'=>'output_filename'},
                    ],
                },
            }];
            my $output = &QemuImgScrap::process_command_syntax_block(\$input_basic_convert);
            cmp_deeply($output, $expect_output, "qemu-img basic [convert]");
        }
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
