const board = @import("board");
const sio = @import("sio.zig");
const gpio = @import("gpio.zig");
const time = @import("time.zig");

const wait_ms = 250;

pub fn main() noreturn {
    const timer = time.init(.timer0);

    const led = board.led;
    const gpio15 = board.Pin.gpio15;

    gpio.connectToSio(led, .{ .direction = .output });
    sio.enableOutput(led);

    gpio.connectToSio(gpio15, .{ .direction = .output });
    sio.enableOutput(gpio15);

    var next = timer.now32();
    while (true) {
        next = next.plus(time.fromMs(wait_ms));
        sio.setHigh(led);
        sio.setLow(gpio15);
        timer.sleepUntil32(next);

        next = next.plus(time.fromMs(wait_ms));
        sio.setLow(led);
        sio.setHigh(gpio15);
        timer.sleepUntil32(next);
    }
}
