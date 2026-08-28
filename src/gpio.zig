const reg = @import("package");
const resets = @import("resets.zig");
const Pin = reg.Pin;

var initialized: bool = false;

pub fn init() void {
    if (initialized) return;
    resets.unreset(reg.rst_io_bank0 | reg.rst_pads_bank0);
    initialized = true;
}

pub const Direction = enum { input, output };

pub const Drive = enum(u2) {
    @"2mA" = 0,
    @"4mA" = 1,
    @"8mA" = 2,
    @"12mA" = 3,
};

pub const Pull = enum { none, up, down };

pub const Config = struct {
    direction: Direction,
    drive: Drive = .@"2mA",
    schmitt: bool = true,
    pull: Pull = .none,
};

pub fn connectToSio(pin: Pin, config: Config) void {
    init();
    const pin_idx = pin.idx();

    var pad: reg.Pad = .{};
    pad.drive = @intFromEnum(config.drive);
    switch (config.pull) {
        .none => {},
        .down => pad.pde = 1,
        .up => pad.pue = 1,
    }

    switch (config.direction) {
        .output => {},
        .input => {
            pad.ie = 1;
            pad.schmitt = 1;
        },
    }

    reg.pads_bank0.gpio[pin_idx] = pad;
    reg.io_bank0.io[pin_idx].ctrl = reg.funcsel_sio;
}
