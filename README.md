# Tic-Tac-Toe

This is an assembly implementation of Tic-Tac-Toe. The source code is written in
x86-64 assembly and assembled with NASM targeting Linux.

The implementation uses bitboards to track board states. This choice was made
both because bitboards are simple and because they play nicely with bit
manipulation.

## Dependencies

- **NASM**
- **GNU Make**
- **binutils** (for `ld`)
- A **Linux** environment targeting **x86-64**

## Building

To build the project:

```
make
```

This will produce an executable called `out` in the `bin` directory.

## Cleaning

To remove build artifacts:

```
make clean
```
