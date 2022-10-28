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
    - [X] convert command
    - [X] create command
    - [X] dd command
    - [X] info command
    - [X] map command
    - [X] snapshot command
    - [X] resize command
    - [ ] all together
    - [ ] failed test cases
  - [X] optional recursion diving
    - [X] test coverage
  - [X] smart alteration matching (Now not full: works only with optional)
    - [X] test coverage
  - [ ] **command parameters matching** with another section
    - [ ] test coverage
  - [X] smart multiple arguments matching
    - [X] test coverage
  - [X] params with values parsing
    - [X] test coverage (covered in dd)
- [ ] **qemu-storage-daemon** (should be much more easy)
  - [ ] test coverage
  
