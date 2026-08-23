pub const resets_base: u32 = 0x40020000;
pub const io_bank0_base: u32 = 0x40028000;
pub const pads_bank0_base: u32 = 0x40038000;
pub const sio_base: u32 = 0xd0000000;

// sio on rp2350 interleaves the _hi variants, so these offsets differ from rp2040.
pub const gpio_out_set: *volatile u32 = @ptrFromInt(sio_base + 0x18);
pub const gpio_out_clr: *volatile u32 = @ptrFromInt(sio_base + 0x20);
pub const gpio_oe_set: *volatile u32 = @ptrFromInt(sio_base + 0x38);

// atomic register aliases: +0x1000 xor, +0x2000 set, +0x3000 clr.
pub const resets_reset_clr: *volatile u32 = @ptrFromInt(resets_base + 0x3000);
pub const resets_reset_done: *volatile u32 = @ptrFromInt(resets_base + 0x8);
pub const rst_io_bank0: u32 = 1 << 6; // verify: rp2350 shifted these vs rp2040
pub const rst_pads_bank0: u32 = 1 << 9;

pub const led_pin: u32 = 25;
pub const led_mask: u32 = @as(u32, 1) << @intCast(led_pin);

pub const pad_led: *volatile u32 = @ptrFromInt(pads_bank0_base + 0x04 + 4 * led_pin);
pub const ctrl_led: *volatile u32 = @ptrFromInt(io_bank0_base + 8 * led_pin + 4);
pub const funcsel_sio: u32 = 5;
