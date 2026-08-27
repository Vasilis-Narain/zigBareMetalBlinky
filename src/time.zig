const clocks = @import("clocks.zig");
const TimerHandle = clocks.TimerHandle;
pub const TimerEnum = clocks.TimerEnum;

pub const Duration32 = struct {
    us: u32,
};

pub fn fromMs(ms: u32) Duration32 {
    return .{
        .us = ms * 1000,
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

pub fn init(timer: TimerEnum) Timer {
    return .{
        .handle = clocks.init(timer),
    };
}

pub const Timer = struct {
    handle: TimerHandle = undefined,

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
