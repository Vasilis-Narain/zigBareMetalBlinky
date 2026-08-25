const reg = @import("package");
const Xosc = reg.Xosc;
const Ctrl = Xosc.Ctrl;
const board = @import("board");
const resets = @import("resets.zig");

var initialized = false;

const startup_delay: u32 = (((board.xosc_hz / 1000) + 128) / 256) * board.xosc_startup_multiplier;

const freq_range: u12 = switch (board.xosc_hz) {
    1_000_000...15_000_000 => 0xaa0,
    15_000_001...30_000_000 => 0xaa1,
    30_000_001...60_000_000 => 0xaa2,
    else => 0xaa3,
};

const xosc_clksrc: u32 = 0x2;

const clk_ref_hz: u32 = board.xosc_hz / reg.clk_ref_div;
const ticks_cycles: u32 = clk_ref_hz / 1_000_000;

/// This function takes time in the order of milliseconds.
/// Define freq range -> set startup_delay -> set enable bit -> poll status.stable
fn initXosc() void {
    if (reg.xosc.status.stable == 1) return;

    const setup: Ctrl = .{ .freq_range = freq_range };
    reg.xosc.ctrl = setup;
    reg.xosc.startup = startup_delay;

    const enable_mask: Ctrl = .{ .enable = Xosc.ctrl_enable };
    reg.alias(.set, reg.xosc).ctrl = enable_mask;

    while (reg.xosc.status.stable == 0) {}
}

fn refToXosc() void {
    reg.clk_ref_ctrl.* = xosc_clksrc;

    while (reg.clk_ref_selected.* & (1 << xosc_clksrc) == 0) {}
}

pub fn init() void {
    if (initialized) return;
    initXosc();
    refToXosc();

    resets.unreset(reg.rst_timer0);
    reg.ticks_timer0_cycles.* = ticks_cycles;
    const setup: reg.TicksCtrl = .{ .enable = 1 };
    reg.ticks_timer0_ctrl.* = setup;
    while (reg.ticks_timer0_ctrl.running == 0) {}

    initialized = true;
}
