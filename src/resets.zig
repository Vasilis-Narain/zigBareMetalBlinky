const reg = @import("registers");

pub fn unreset(mask: u32) void {
    reg.resets_reset_clr.* = mask;
    while (reg.resets_reset_done.* & mask != mask) {}
}
