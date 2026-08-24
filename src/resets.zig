const reg = @import("package");

pub fn unreset(mask: u32) void {
    reg.resets_reset_clr.* = mask;
    while (reg.resets_reset_done.* & mask != mask) {}
}
