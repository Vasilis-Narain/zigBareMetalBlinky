## Bare-metal Blinky on Raspberry Pico 2 (RP2350)

Much more code than necessary for blinky as I'm experimenting.

Requires `picotool` installed on the system for full build. Minimum installation is fine as it is only used for the final `uf2` conversion.

Can use any other method of doing this conversion, altering/removing the final few lines of `build.zig` with appropriate arguments as necessary.

Entry point of the program is `entry.zig`.
