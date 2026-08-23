//* main.zig — RP2350 (Pico 2) bare-metal blink, no pico-sdk.
const std = @import("std");
const program_entry = @import("main.zig");

pub const panic = std.debug.no_panic;

// ---------------------------------------------------------------- linker syms
extern const __stack_top: anyopaque;
extern var __data_start: u8;
extern var __data_end: u8;
extern var __data_lma: u8;
extern var __bss_start: u8;
extern var __bss_end: u8;

export const vector_table linksection(".vector_table") = [2]*const anyopaque{
    &__stack_top,
    &resetHandler,
};

export const boot_block linksection(".boot_block") = [5]u32{
    0xFFFFDED3, // PICOBIN_BLOCK_MARKER_START
    0x10210142, // IMAGE_DEF: EXE, ARM, secure
    0x000001FF, // last-item terminator
    0x00000000, // next-block offset (0 = self-loop)
    0xAB123579, // PICOBIN_BLOCK_MARKER_END
};

// ---------------------------------------------------------------------- crt0
export fn resetHandler() callconv(.c) noreturn {
    const dlen = @intFromPtr(&__data_end) - @intFromPtr(&__data_start);
    const dst: [*]u8 = @ptrCast(&__data_start);
    const src: [*]const u8 = @ptrCast(&__data_lma);
    @memcpy(dst[0..dlen], src[0..dlen]);

    const blen = @intFromPtr(&__bss_end) - @intFromPtr(&__bss_start);
    const bss: [*]u8 = @ptrCast(&__bss_start);
    @memset(bss[0..blen], 0);

    program_entry.main();
}
