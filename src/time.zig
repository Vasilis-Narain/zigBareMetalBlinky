//! User facing time API. Usage for simple blinky program:
//!
//! ```{zig}
//! const board = @import("board");
//! const sio = @import("sio.zig");
//! const gpio = @import("gpio.zig");
//! const time = @import("time.zig");
//!
//! const wait_ms: u32 = 500;
//!
//! pub fn main() noreturn {
//!     const led = board.led;
//!
//!     gpio.connectToSio(led, .output);
//!     sio.enableOutput(led);
//!
//!     const timer = time.init(.timer0);
//!     var next = timer.now32();
//!
//!     while (true) {
//!         next = next.plus(time.fromMs(wait_ms));
//!         sio.setHigh(led);
//!         timer.sleepUntil32(next);
//!
//!         next = next.plus(time.fromMs(wait_ms));
//!         sio.setLow(led);
//!         timer.sleepUntil32(next);
//!     }
//! }
//! ```
const clocks = @import("clocks.zig");
const TickGeneratorHandle = clocks.TickGeneratorHandle;
pub const TimerEnum = clocks.TimerEnum;

/// Call this before using other timer functions.
pub fn init(timer: TimerEnum) Timer {
    return .{
        .handle = clocks.init(timer),
    };
}

pub const Duration32 = struct {
    us: u32,
};

const std = @import("std");
const builtin = std.builtin;

/// Input must be `f32`,`u32`, `comptime_int`, `comptime_float`
///
/// Does saturating multiplication. This means if
/// `ms` is too large the returned `Duration32` struct
/// will have `us = 1 << 31`.
pub fn fromMs(ms: anytype) Duration32 {
    const T = @TypeOf(ms);

    const isFloat = switch (T) {
        f32, comptime_float => true,
        u32, comptime_int => false,
        else => @compileError("ANYTYPE_CHECK: `fromMs(ms: anytype)` only accepts types that can coerce `f32` or `u32`"),
    };

    const result: u32 = blk: {
        if (T == comptime_int and !(ms > 0)) break :blk 0;
        const max_us = 1 << 31;
        if (isFloat) {
            if (!(ms > 0)) break :blk 0;
            const us_float = ms * 1000;

            if (us_float >= @as(comptime_float, max_us)) {
                break :blk max_us;
            } else {
                break :blk @intFromFloat(@trunc(us_float));
            }
        } else {
            break :blk @min(ms *| 1000, max_us);
        }
    };

    return .{
        .us = result,
    };
}

pub const Instant32 = struct {
    us: u32,

    pub fn plus(self: @This(), duration: Duration32) @This() {
        return .{
            .us = self.us +% duration.us,
        };
    }

    pub fn reached(self: @This(), deadline: @This()) bool {
        return @as(i32, @bitCast(self.us -% deadline.us)) >= 0;
    }
};

pub const Timer = struct {
    handle: TickGeneratorHandle,

    pub fn now32(self: @This()) Instant32 {
        return .{
            .us = self.handle.ptr.time_raw_l,
        };
    }

    pub fn sleepUntil32(self: @This(), deadline: Instant32) void {
        while (!now32(self).reached(deadline)) {}
    }

    pub fn sleepFor32(self: @This(), delay: Duration32) void {
        self.sleepUntil32(now32(self).plus(delay));
    }
};
