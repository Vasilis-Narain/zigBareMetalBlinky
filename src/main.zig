const std = @import("std");
const reg = @import("registers.zig");

// These exist to prove crt0 ran. `period` lives in .data (flash LMA -> RAM VMA),
// `blinks` in .bss. Skip the copy/zero below and the blink rate goes obviously
// wrong instead of failing silently.
export var period: u32 = 1_500_000;
var blinks: u32 = 0;

fn unreset(mask: u32) void {
    reg.resets_reset_clr.* = mask;
    while (reg.resets_reset_done.* & mask != mask) {}
}

fn delay(cycles: u32) void {
    var i: u32 = 0;
    while (i < cycles) : (i += 1) {
        asm volatile ("" ::: .{ .memory = true });
    }
}

pub fn main() noreturn {
    unreset(reg.rst_io_bank0 | reg.rst_pads_bank0);

    // writinreg.0 clears iso (bit 8) — mandatory on rp2350, no rp2040 equivalent.
    // also clears od/pde/pue and leaves ie off, which is what we want for output.
    reg.pad_led.* = 0;
    reg.ctrl_led.* = reg.funcsel_sio;
    reg.gpio_oe_set.* = reg.led_mask;

    while (true) {
        reg.gpio_out_set.* = reg.led_mask;
        delay(period);
        reg.gpio_out_clr.* = reg.led_mask;
        delay(period);
        blinks +%= 1;
    }
}
