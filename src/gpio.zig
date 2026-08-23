const reg = @import("registers.zig");
const resets = @import("resets.zig");
const Pin = reg.Pin;

var initialized: bool = false;

pub fn init() void {
    if (initialized) return;
    resets.unreset(reg.rst_io_bank0 | reg.rst_pads_bank0);
    initialized = true;
}

pub const Direction = enum { input, output };

pub fn connectToSio(pin: Pin, direction: Direction) void {
    init();
    const pin_idx = pin.idx();
    reg.pads_bank0.gpio[pin_idx] = if (direction == .input) 1 << 6 else 0;
    reg.io_bank0.io[pin_idx].ctrl = reg.funcsel_sio;
}
