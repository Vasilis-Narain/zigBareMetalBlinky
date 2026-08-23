pub const resets_base: u32 = 0x40020000;
pub const io_bank0_base: u32 = 0x40028000;
pub const pads_bank0_base: u32 = 0x40038000;
pub const sio_base: u32 = 0xd0000000;

// sio on rp2350 interleaves the _hi variants, so these offsets differ from rp2040.
pub const gpio_in: *volatile u32 = @ptrFromInt(sio_base + 0x04);
pub const gpio_out_set: *volatile u32 = @ptrFromInt(sio_base + 0x18);
pub const gpio_out_clr: *volatile u32 = @ptrFromInt(sio_base + 0x20);
pub const gpio_oe_set: *volatile u32 = @ptrFromInt(sio_base + 0x38);

// atomic register aliases: +0x1000 xor, +0x2000 set, +0x3000 clr.
pub const resets_reset_clr: *volatile u32 = @ptrFromInt(resets_base + 0x3000);
pub const resets_reset_done: *volatile u32 = @ptrFromInt(resets_base + 0x8);
pub const rst_io_bank0: u32 = 1 << 6; // verify: rp2350 shifted these vs rp2040
pub const rst_pads_bank0: u32 = 1 << 9;

pub const funcsel_sio: u32 = 5;

const num_gpio_slots = 48;

const Gpio = extern struct {
    status: u32,
    ctrl: u32,
};

const IoBank0 = extern struct {
    io: [num_gpio_slots]Gpio,
};

const PadsBank0 = extern struct {
    voltage_select: u32,
    gpio: [num_gpio_slots]u32,
    swclk: u32,
    swd: u32,
};

pub const io_bank0: *volatile IoBank0 = @ptrFromInt(io_bank0_base);
pub const pads_bank0: *volatile PadsBank0 = @ptrFromInt(pads_bank0_base);

pub const Pin = enum(u5) {
    gpio0 = 0,
    gpio1 = 1,
    gpio2 = 2,
    gpio3 = 3,
    gpio4 = 4,
    gpio5 = 5,
    gpio6 = 6,
    gpio7 = 7,
    gpio8 = 8,
    gpio9 = 9,
    gpio10 = 10,
    gpio11 = 11,
    gpio12 = 12,
    gpio13 = 13,
    gpio14 = 14,
    gpio15 = 15,
    gpio16 = 16,
    gpio17 = 17,
    gpio18 = 18,
    gpio19 = 19,
    gpio20 = 20,
    gpio21 = 21,
    gpio22 = 22,
    gpio23 = 23,
    gpio24 = 24,
    gpio25 = 25,
    gpio26 = 26,
    gpio27 = 27,
    gpio28 = 28,
    gpio29 = 29,

    pub fn idx(pin: @This()) u5 {
        return @intFromEnum(pin);
    }
};

pub const adc0: Pin = .gpio26;
pub const adc1: Pin = .gpio27;
pub const adc2: Pin = .gpio28;
