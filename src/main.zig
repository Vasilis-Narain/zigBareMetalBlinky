//* main.zig — RP2350 (Pico 2) bare-metal blink, no pico-sdk.
const std = @import("std");

/// Freestanding: no std panic machinery. Safety checks become @trap().
pub const panic = std.debug.no_panic;

// ---------------------------------------------------------------- linker syms
extern const __stack_top: anyopaque;
extern var __data_start: u8;
extern var __data_end: u8;
extern var __data_lma: u8;
extern var __bss_start: u8;
extern var __bss_end: u8;

// ------------------------------------------------------------- image metadata
export const vector_table linksection(".vector_table") = [2]*const anyopaque{
    &__stack_top,
    &resetHandler, // LLD sets the Thumb bit on this reloc; do NOT | 1
};

/// RP2350 bootrom scans the first 4 KiB for this block. Absent/malformed
/// => silent drop to BOOTSEL, no error. Verify with `picotool info -a`.
export const boot_block linksection(".boot_block") = [5]u32{
    0xFFFFDED3, // PICOBIN_BLOCK_MARKER_START
    0x10210142, // IMAGE_DEF: EXE, ARM, secure
    0x000001FF, // last-item terminator
    0x00000000, // next-block offset (0 = self-loop)
    0xAB123579, // PICOBIN_BLOCK_MARKER_END
};

// ------------------------------------------------------------------ registers
const RESETS_BASE: u32 = 0x40020000;
const IO_BANK0_BASE: u32 = 0x40028000;
const PADS_BANK0_BASE: u32 = 0x40038000;
const SIO_BASE: u32 = 0xD0000000;

// SIO on RP2350 interleaves the _HI variants, so these offsets differ from RP2040.
const GPIO_OUT_SET: *volatile u32 = @ptrFromInt(SIO_BASE + 0x18);
const GPIO_OUT_CLR: *volatile u32 = @ptrFromInt(SIO_BASE + 0x20);
const GPIO_OE_SET: *volatile u32 = @ptrFromInt(SIO_BASE + 0x38);

// Atomic register aliases: +0x1000 XOR, +0x2000 SET, +0x3000 CLR.
const RESETS_RESET_CLR: *volatile u32 = @ptrFromInt(RESETS_BASE + 0x3000);
const RESETS_RESET_DONE: *volatile u32 = @ptrFromInt(RESETS_BASE + 0x8);
const RST_IO_BANK0: u32 = 1 << 6; // verify: RP2350 shifted these vs RP2040
const RST_PADS_BANK0: u32 = 1 << 9;

const LED_PIN: u32 = 25;
const LED_MASK: u32 = @as(u32, 1) << @intCast(LED_PIN);

const PAD_LED: *volatile u32 = @ptrFromInt(PADS_BANK0_BASE + 0x04 + 4 * LED_PIN);
const CTRL_LED: *volatile u32 = @ptrFromInt(IO_BANK0_BASE + 8 * LED_PIN + 4);
const FUNCSEL_SIO: u32 = 5;

// -------------------------------------------------------------------- globals
// These exist to prove crt0 ran. `period` lives in .data (flash LMA -> RAM VMA),
// `blinks` in .bss. Skip the copy/zero below and the blink rate goes obviously
// wrong instead of failing silently.
export var period: u32 = 1_500_000;
var blinks: u32 = 0;

// ---------------------------------------------------------------------- crt0
export fn resetHandler() callconv(.c) noreturn {
    const dlen = @intFromPtr(&__data_end) - @intFromPtr(&__data_start);
    const dst: [*]u8 = @ptrCast(&__data_start);
    const src: [*]const u8 = @ptrCast(&__data_lma);
    @memcpy(dst[0..dlen], src[0..dlen]);

    const blen = @intFromPtr(&__bss_end) - @intFromPtr(&__bss_start);
    const bss: [*]u8 = @ptrCast(&__bss_start);
    @memset(bss[0..blen], 0);

    main();
}

// ---------------------------------------------------------------------- main
fn unreset(mask: u32) void {
    RESETS_RESET_CLR.* = mask;
    while (RESETS_RESET_DONE.* & mask != mask) {}
}

fn delay(cycles: u32) void {
    var i: u32 = 0;
    while (i < cycles) : (i += 1) {
        asm volatile ("" ::: .{ .memory = true });
    }
}

fn main() noreturn {
    unreset(RST_IO_BANK0 | RST_PADS_BANK0);

    // Writing 0 clears ISO (bit 8) — mandatory on RP2350, no RP2040 equivalent.
    // Also clears OD/PDE/PUE and leaves IE off, which is what we want for output.
    PAD_LED.* = 0;
    CTRL_LED.* = FUNCSEL_SIO;
    GPIO_OE_SET.* = LED_MASK;

    while (true) {
        GPIO_OUT_SET.* = LED_MASK;
        delay(period);
        GPIO_OUT_CLR.* = LED_MASK;
        delay(period);
        blinks +%= 1;
    }
}
