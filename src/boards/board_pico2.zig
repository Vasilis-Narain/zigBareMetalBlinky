const reg = @import("package");

pub const Pin = reg.Pin;

pub const xosc_hz: u32 = 12_000_000;
pub const xosc_startup_multiplier: u32 = 1;

pub const adc0 = reg.adc0;
pub const adc1 = reg.adc1;
pub const adc2 = reg.adc2;

pub const smps_mode: Pin = .gpio23;
pub const vbus_detect: Pin = .gpio24;
pub const led: Pin = .gpio25;
pub const vsys_sense: Pin = .gpio29;

pub fn pinFromInt(n: u32) !Pin {
    return switch (n) {
        0...22 => @enumFromInt(n),
        26...28 => error.PinHasCanonicalName,
        23...25, 29 => error.PinReservedByBoard,
        else => error.PinNotBonded,
    };
}
