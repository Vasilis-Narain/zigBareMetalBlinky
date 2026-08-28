## Bare-metal Blinky on Raspberry Pico 2 in Zig (RP2350)

Timed using the crystal oscillator present on the board.

Way more code than necessary for blinky... I'm experimenting different sw architectures and practicing reading spec.

Specifically this project aims to teach me:

- microcontrollers
- reading spec
- linker scripts
- clocks (i've written a simple profiler that uses rdtsc(), this takes it lower albeit with no os in the way)
- interrupts

Requires `picotool` installed on the system for full build. Minimum installation is fine as it is only used for the final `uf2` conversion.

Can use any other method of doing this conversion, altering/removing the final few lines of `build.zig` with appropriate arguments as necessary.

Entry point of the program is `entry.zig`.

Future project:

- rewrite it in C (to brush up on C skills, only things required by the application) and also write an I2C driver for a temp/humidity monitor.
- write a barebones Blinky (using just system clock, not the crystal oscillator) in ASM
