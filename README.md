## Bare-metal Blinky on Raspberry Pico 2 in Zig (RP2350)

Timed using the crystal oscillator present on the board.

Way more code than necessary for blinky... I'm experimenting different sw architectures and practicing reading spec.

Requires `picotool` installed on the system for full build. Minimum installation is fine as it is only used for the final `uf2` conversion.

Can use any other method of doing this conversion, altering/removing the final few lines of `build.zig` with appropriate arguments as necessary.

Entry point of the program is `entry.zig`.
