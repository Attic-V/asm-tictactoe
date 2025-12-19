# Tic-Tac-Toe

This is an assembly implementation of tic tac toe. It is written in for NASM in
intel syntax and targets x86_64 linux.

The implementation uses bitboards to track board states. This choice was made
both because bitboards are simple and because they play nicely with bit
manipulation.

## Building

```
make
```

## Usage

Upon building the project, an executable called `out` will be created. Assuming
that you are at the root of the project, you can run it with the following
command:

```
./out
```

