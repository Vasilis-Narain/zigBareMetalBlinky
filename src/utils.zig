pub fn delay(cycles: u32) void {
    var i: u32 = 0;
    while (i < cycles) : (i += 1) {
        asm volatile ("" ::: .{ .memory = true });
    }
}
