//* File matching spec from https://pip-assets.raspberrypi.com/categories/1214-rp2350/documents/RP-008373-DS-2-rp2350-datasheet.pdf
//* Not everything is here, adding things as needed.

// ALIASES
pub const Alias = enum(u32) {
    rw = 0x0000,
    xor = 0x1000,
    set = 0x2000,
    clr = 0x3000,
};

pub fn alias(comptime op: Alias, ptr: anytype) @TypeOf(ptr) {
    return @ptrFromInt(@intFromPtr(ptr) + @intFromEnum(op));
}

// BASES
pub const resets_base: u32 = 0x40020000;
pub const io_bank0_base: u32 = 0x40028000;
pub const pads_bank0_base: u32 = 0x40038000;
pub const sio_base: u32 = 0xd0000000;
pub const ticks_base: u32 = 0x4010800;
pub const timer0_base: u32 = 0x400b0000;
pub const timer1_base: u32 = 0x400b8000;
pub const xosc_base: u32 = 0x40048000;
pub const clk_base: u32 = 0x40010000;

// CLOCKS
pub const clk_ref_ctrl: *volatile u32 = @ptrFromInt(clk_base + 0x30);
pub const clk_ref_div: *volatile u32 = @ptrFromInt(clk_base + 0x34);
pub const clk_ref_selected: *volatile u32 = @ptrFromInt(clk_base + 0x38);

// XOSC
pub const Xosc = extern struct {
    ctrl: Ctrl,
    status: Status,
    dormant: u32,
    startup: u32,
    count: u32,

    // NOTE(vasilis): all writes to a packed struct must be done in one go, not per field.
    // Make a local const with desired fields and then write. Use the alias function above
    // for actual bit writes. No issue for reading.
    pub const Ctrl = packed struct(u32) {
        freq_range: u12 = 0,
        enable: u12 = 0,
        __reserved: u8 = 0,
    };

    pub const Status = packed struct(u32) {
        freq_range: u2 = 0,
        __reserved2: u10 = 0,
        enabled: u1 = 0,
        __reserved13: u11 = 0,
        badwrite: u1 = 0,
        __reserved25: u6 = 0,
        stable: u1 = 0,
    };

    pub const ctrl_enable: u12 = 0xfab;
    pub const ctrl_disable: u12 = 0xd1e;
};
pub const xosc: *volatile Xosc = @ptrFromInt(xosc_base);

// TICKS
pub const TicksCtrl = packed struct(u32) {
    enable: u1 = 0,
    running: u1 = 0,
    __reserved: u30 = 0,
};
pub const ticks_timer0_ctrl: *volatile TicksCtrl = @ptrFromInt(ticks_base + 0x18);
pub const ticks_timer0_cycles: *volatile u32 = @ptrFromInt(ticks_base + 0x1c);

// TICKS Generator
const TickGenerator = extern struct {
    time_hw: u32,
    time_lw: u32,
    time_hr: u32,
    time_lr: u32,
    alarm: [4]u32,
    armed: u32,
    time_raw_h: u32,
    time_raw_l: u32,
    dbg_pause: u32,
    pause: u32,
    locked: u32,
    source: u32,
    int_r: u32,
    int_e: u32,
    int_f: u32,
    int_s: u32,
};
pub const timer0: *volatile TickGenerator = @ptrFromInt(timer0_base);
pub const timer1: *volatile TickGenerator = @ptrFromInt(timer1_base);

// GPIO
const num_gpio_slots = 48;
pub const gpio_in: *volatile u32 = @ptrFromInt(sio_base + 0x04);
pub const gpio_out_set: *volatile u32 = @ptrFromInt(sio_base + 0x18);
pub const gpio_out_clr: *volatile u32 = @ptrFromInt(sio_base + 0x20);
pub const gpio_oe_set: *volatile u32 = @ptrFromInt(sio_base + 0x38);

// RESETS
pub const resets_reset_clr: *volatile u32 = @ptrFromInt(resets_base + 0x3000);
pub const resets_reset_done: *volatile u32 = @ptrFromInt(resets_base + 0x8);
pub const rst_timer0: u32 = 1 << 23;
pub const rst_timer1: u32 = 1 << 24;
pub const rst_io_bank0: u32 = 1 << 6;
pub const rst_pads_bank0: u32 = 1 << 9;

// FUNCSEL
pub const funcsel_sio: u32 = 5;

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
