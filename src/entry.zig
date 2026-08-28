//! platform-specific entry point of the program
const std = @import("std");
const program_entry = @import("main.zig");

// panic override
const panic_override = @import("panic_override.zig");
const sosBlink = panic_override.sosBlink;
pub const panic = std.debug.FullPanic(sosBlink);

// linker syms
extern const __stack_top: anyopaque;
extern var __data_start: u8;
extern var __data_end: u8;
extern var __data_lma: u8;
extern var __bss_start: u8;
extern var __bss_end: u8;

const num_vtable_entries = 16 + 58; //16 pre irq, 58 irq

export const vector_table linksection(".vector_table") = blk: {
    var vector: [num_vtable_entries]*const anyopaque = @splat(&defaultHandler);
    vector[0] = &__stack_top;
    vector[1] = &resetHandler;
    vector[16] = &timer0IrqHandler;
    break :blk vector;
};

export const boot_block linksection(".boot_block") = [5]u32{
    0xFFFFDED3, // PICOBIN_BLOCK_MARKER_START
    0x10210142, // IMAGE_DEF: EXE, ARM, secure
    0x000001FF, // last-item terminator
    0x00000000, // next-block offset (0 = self-loop)
    0xAB123579, // PICOBIN_BLOCK_MARKER_END
};

/// Check for debug probe if not just sosBlink.
export fn defaultHandler() callconv(.c) noreturn {
    const dhcsr: *volatile u32 = @ptrFromInt(0xe000edf0);
    if (dhcsr.* & 1 != 0) asm volatile ("bkpt #0");
    sosBlink("", null);
}

/// crt0
export fn resetHandler() callconv(.c) noreturn {
    const vtor: *volatile u32 = @ptrFromInt(0xe000ed08);
    vtor.* = @intFromPtr(&vector_table);

    const data_len = @intFromPtr(&__data_end) - @intFromPtr(&__data_start);
    const dest: [*]u8 = @ptrCast(&__data_start);
    const src: [*]const u8 = @ptrCast(&__data_lma);
    @memcpy(dest[0..data_len], src[0..data_len]);

    const bss_len = @intFromPtr(&__bss_end) - @intFromPtr(&__bss_start);
    const bss: [*]u8 = @ptrCast(&__bss_start);
    @memset(bss[0..bss_len], 0);

    program_entry.main();
}

/// timer0 irq handler. For future use :D
export fn timer0IrqHandler() callconv(.c) void {}
