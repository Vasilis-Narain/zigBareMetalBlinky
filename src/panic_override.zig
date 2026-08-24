const gpio = @import("gpio.zig");
const sio = @import("sio.zig");
const board = @import("board");
const utils = @import("utils.zig");

pub fn sosBlink(_: []const u8, _: ?usize) noreturn {
    const led = board.led;
    const fast: u32 = 1_500_000;
    var isSlow = true;

    gpio.connectToSio(led, .output);
    sio.enableOutput(led);

    var i: u32 = 0;
    while (true) {
        const local_period = fast << (@as(u2, @intFromBool(isSlow)) + 1);
        while (i < 3) : (i += 1) {
            sio.setHigh(led);
            utils.delay(local_period);
            sio.setLow(led);
            utils.delay(local_period);
        }
        i = 0;
        isSlow = !isSlow;
    }
}
