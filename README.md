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

## Building (native)

To build the project directly on your machine:

```
make
```

This will produce an executable called `out` in the `bin` directory.

## Building with Docker

A Dockerfile is provided so that you can build and run the project inside a
container if you so choose. You would likely do this if either A) you don't want
to install dependencies locally or B) don't have an x86-64 Linux box available.

Build and run the project in Docker:

```
make docker
```

> If your Docker setup requires root privileges, prefix the command with `sudo`.

## Cleaning

To remove build artifacts:

```
make clean
```
