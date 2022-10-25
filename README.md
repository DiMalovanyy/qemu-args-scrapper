# qemu-args-scrapper
Qemu binaries args scrapper for creating version compatible QEMU process integration API

## Motivation
This arguments scrapper was designed to make Qemu binaries argument version comaptiable. It generates file with any suitable format (YAML, JSON, etc.) 
with all arguments and options available in current qemu supported version. 

This files can be easy integrated with further qemu integration application, that would use Qemu binaries from different process.


## TODO list for MVP ( Developing in progress )
- [ ] add different output format and sources (now only Yaml in stdout)
- [ ] **qemu-img**
  - [X] header parsing (version etc.)
    - [X] test coverage
  - [X] supported format blocks
    - [X] test coverage
  - [ ] command test coverage
    - [X] amend command
    - [X] bench command
    - [X] commit command
    - [X] rebase command
    - [X] compare command
    - [ ] bitmap command
    - [ ] convert command
    - [ ] create command
    - [ ] dd command
    - [ ] info command
    - [ ] map command
    - [ ] snapshot command
    - [ ] resize command
    - [ ] all together
    - [ ] failed test cases
  - [X] optional recursion diving
    - [X] test coverage
  - [ ] smart alteration matching
    - [ ] test coverage
  - [ ] **command parameters matching** with another section
    - [ ] test coverage
  - [ ] smart multiple arguments matching
    - [ ] test coverage
- [ ] **qemu-storage-daemon** (should be much more easy)
  - [ ] test coverage
  