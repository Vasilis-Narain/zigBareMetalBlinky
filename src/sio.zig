const reg = @import("registers.zig");
const Pin = reg.Pin;

pub fn setHigh(pin: Pin) void {
    reg.gpio_out_set.* = bit(pin);
}

pub fn setLow(pin: Pin) void {
    reg.gpio_out_clr.* = bit(pin);
}

pub fn enableOutput(pin: Pin) void {
    reg.gpio_oe_set.* = bit(pin);
}

pub fn read(pin: Pin) bool {
    return reg.gpio_in.* & bit(pin) != 0;
}

fn bit(pin: Pin) u32 {
    return @as(u32, 1) << pin.idx();
}
