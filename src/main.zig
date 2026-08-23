const board = @import("board_pico2.zig");
const sio = @import("sio.zig");
const gpio = @import("gpio.zig");
const utils = @import("utils.zig");

export var period: u32 = 1_500_000;
pub var blinks: u32 = 0;

pub fn main() noreturn {
    const led = board.led;

    gpio.init();
    gpio.connectToSio(led, .output);
    sio.enableOutput(led);

    while (true) {
        sio.setHigh(led);
        utils.delay(period);
        sio.setLow(led);
        utils.delay(period);
        blinks +%= 1;
    }
}
