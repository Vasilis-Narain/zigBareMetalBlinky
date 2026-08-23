const reg = @import("registers.zig");

pub fn unreset(mask: u32) void {
    reg.resets_reset_clr.* = mask;
    while (reg.resets_reset_done.* & mask != mask) {}
}
