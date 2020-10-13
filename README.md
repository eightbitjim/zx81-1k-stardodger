# zx81-1k-stardodger

A minimal game for the 1K ZX81, written in assembler.

## build

> These instructions are based on Ubuntu Linux.

To build, you need to have installed the `z80asm` assembler:

```
sudo apt install z80asm
```

Then build using:

```
make
```

This should build `stardodger.p`, which is a tape file that will load 
into most ZX81 emulators.

The file `template.p` is a template BASIC program that contains a `REM`
statement, into which the assembled machine code program is inserted by
the assembler. You can load it into an emulator to have a look, but it
won't do anything useful on its own.

## play

Run by typing `RUN` (just press the "R" key) and hitting NEWLINE (or
pressing return on an emulator).

Ok, it's not a very excisting game. Scrolls a starfield from right to
left, and you need to avoid hitting the stars for as long as possible.
Use `Q` to go up, `Z` to go down. When you hit a star, your score is
shown.

Run again by typing `RUN`.
