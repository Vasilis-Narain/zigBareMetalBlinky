## Bare-metal Blinky on Raspberry Pico 2 (RP2350)

Way more code than necessary for blinky... I'm experimenting different sw architectures and practicing reading spec.

Specifically this project aims to teach me:

- microcontrollers
- reading spec
- linker scripts
- clocks (i've written a simple profiler that uses rdtsc(), this takes it lower albeit with no os in the way)

Requires `picotool` installed on the system for full build. Minimum installation is fine as it is only used for the final `uf2` conversion.

Can use any other method of doing this conversion, altering/removing the final few lines of `build.zig` with appropriate arguments as necessary.

Entry point of the program is `entry.zig`.
