const reg = @import("package");
const Xosc = reg.Xosc;
const Ctrl = Xosc.Ctrl;
const board = @import("board");
const resets = @import("resets.zig");

const Initialized = struct {
    timer0: bool = false,
    timer1: bool = false,
};
pub var initialized: Initialized = .{};

const startup_delay: u32 = (((board.xosc_hz / 1000) + 128) / 256) * board.xosc_startup_multiplier;

comptime {
    if (startup_delay >= 1 << 13)
        @compileError("xosc `startup delay` must be < 8192");
    if (board.xosc_hz % 1_000_000 != 0)
        @compileError("`xosc_hz` must be a whole number of MHz for an exact 1 MHz tick");
}

const freq_range: u12 = switch (board.xosc_hz) {
    1_000_000...15_000_000 => 0xaa0,
    15_000_001...30_000_000 => 0xaa1,
    30_000_001...60_000_000 => 0xaa2,
    else => @compileError("xosc_hz outside supported range"),
};

const xosc_clksrc: u32 = 0x2;

const ticks_cycles: u32 = board.xosc_hz / 1_000_000;

fn initXosc() void {
    if (reg.xosc.status.stable == 1) return;

    const setup: Ctrl = .{ .freq_range = freq_range };
    reg.xosc.ctrl = setup;
    reg.xosc.startup = startup_delay;

    const enable_mask: Ctrl = .{ .enable = Xosc.ctrl_enable };
    const xosc_set_alias = reg.alias(.set, reg.xosc);
    xosc_set_alias.ctrl = enable_mask;

    while (reg.xosc.status.stable == 0) {}
}

fn refToXosc() void {
    reg.clk_ref_ctrl.* = xosc_clksrc;
    reg.clk_ref_div.* = 1 << 16; // 16 is INT lsb from spec.

    while (reg.clk_ref_selected.* & (1 << xosc_clksrc) == 0) {}
}

pub const TimerEnum = enum {
    timer0,
    timer1,

    fn isInitialised(timer: @This()) bool {
        return switch (timer) {
            .timer0 => initialized.timer0,
            .timer1 => initialized.timer1,
        };
    }

    fn getPtr(timer: @This()) *volatile reg.TickGenerator {
        return switch (timer) {
            .timer0 => reg.timer0,
            .timer1 => reg.timer1,
        };
    }
};

pub const TimerHandle = struct {
    type: TimerEnum,
    ptr: *volatile reg.TickGenerator,
};

pub fn init(timer: TimerEnum) TimerHandle {
    const result: TimerHandle = .{
        .type = timer,
        .ptr = timer.getPtr(),
    };

    if (timer.isInitialised()) return result;

    initXosc();
    refToXosc();

    switch (timer) {
        .timer0 => {
            resets.unreset(reg.rst_timer0);

            reg.ticks_timer0_cycles.* = ticks_cycles;
            const setup: reg.TicksCtrl = .{ .enable = 1 };
            reg.ticks_timer0_ctrl.* = setup;
            while (reg.ticks_timer0_ctrl.running == 0) {}

            initialized.timer0 = true;
        },
        .timer1 => {
            resets.unreset(reg.rst_timer1);

            reg.ticks_timer1_cycles.* = ticks_cycles;
            const setup: reg.TicksCtrl = .{ .enable = 1 };
            reg.ticks_timer1_ctrl.* = setup;
            while (reg.ticks_timer1_ctrl.running == 0) {}

            initialized.timer1 = true;
        },
    }
    return result;
}
