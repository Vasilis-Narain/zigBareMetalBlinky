const board = @import("board");
const sio = @import("sio.zig");
const gpio = @import("gpio.zig");
const clocks = @import("clocks.zig");

// To be replaced with better delay method once timer0 wired up.
const delay = @import("panic_override.zig").delay;

export var period: u32 = 1_500_000;
pub var blinks: u32 = 0;

pub fn main() noreturn {
    const led = board.led;

    gpio.connectToSio(led, .output);
    sio.enableOutput(led);

    clocks.init();

    while (true) {
        sio.setHigh(led);
        delay(period);
        sio.setLow(led);
        delay(period);
        blinks +%= 1;
    }
}
