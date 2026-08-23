const board = @import("board_pico2.zig");
const sio = @import("sio.zig");
const gpio = @import("gpio.zig");

// These exist to prove crt0 ran. `period` lives in .data (flash LMA -> RAM VMA),
// `blinks` in .bss. Skip the copy/zero below and the blink rate goes obviously
// wrong instead of failing silently.
export var period: u32 = 1_500_000;
var blinks: u32 = 0;

fn delay(cycles: u32) void {
    var i: u32 = 0;
    while (i < cycles) : (i += 1) {
        asm volatile ("" ::: .{ .memory = true });
    }
}

pub fn main() noreturn {
    const led = board.led;

    gpio.init();
    gpio.connectToSio(led, .output);
    sio.enableOutput(led);

    while (true) {
        sio.setHigh(led);
        delay(period);
        sio.setLow(led);
        delay(period);
        blinks +%= 1;
    }
}
