const board = @import("board");
const sio = @import("sio.zig");
const gpio = @import("gpio.zig");
const time = @import("time.zig");

export var wait_ms: u32 = 500;
pub var blinks: u32 = 0;

pub fn main() noreturn {
    const led = board.led;

    gpio.connectToSio(led, .output);
    sio.enableOutput(led);

    const timer = time.init(.timer0);
    var next = timer.now32();

    while (true) {
        next = next.plus(time.fromMs(wait_ms));
        sio.setHigh(led);
        timer.sleepUntil32(next);

        next = next.plus(time.fromMs(wait_ms));
        sio.setLow(led);
        timer.sleepUntil32(next);
        blinks +%= 1;
    }
}
