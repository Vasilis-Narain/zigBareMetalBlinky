const board = @import("board");
const gpio = @import("gpio.zig");
const sio = @import("sio.zig");

pub fn sosBlink(_: []const u8, _: ?usize) noreturn {
    const led = board.led;
    const fast: u32 = 1_500_000;
    var isFast = true;

    gpio.connectToSio(led, .{ .direction = .output });
    sio.enableOutput(led);

    while (true) {
        const local_period = if (isFast) fast else fast * 2;
        var i: u32 = 0;
        while (i < 3) : (i += 1) {
            sio.setHigh(led);
            delay(local_period);
            sio.setLow(led);
            delay(local_period);
        }
        i = 0;
        isFast = !isFast;
    }
}

/// delay function using cycles as we might panic without
/// having setup XOSC clock.
fn delay(cycles: u32) void {
    var i: u32 = 0;
    while (i < cycles) : (i += 1) {
        asm volatile ("" ::: .{ .memory = true });
    }
}
