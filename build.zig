const std = @import("std");

const Board = enum {
    pico_2,
};

const Package = enum {
    rp2350a,
};

fn fatal(comptime format: []const u8, args: anytype) noreturn {
    std.debug.print(format, args);
    std.process.exit(1);
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .thumb,
        .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m33 },
        .os_tag = .freestanding,
        .abi = .eabi,
    });

    const board = b.option(Board, "board", "target board") orelse .pico_2;
    const board_src = switch (board) {
        .pico_2 => "src/boards/board_pico2.zig",
    };

    const package: Package = switch (board) {
        .pico_2 => .rp2350a,
    };

    const package_src = switch (package) {
        .rp2350a => "src/chip_packages/package_rp2350a.zig",
    };

    const opts = b.addOptions();
    opts.addOption(Board, "board", board);
    opts.addOption(Package, "package", package);

    const package_mod = b.createModule(.{
        .root_source_file = b.path(package_src),
        .target = target,
        .optimize = optimize,
    });

    const board_mod = b.createModule(.{
        .root_source_file = b.path(board_src),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "package", .module = package_mod },
        },
    });

    const root_mod = b.createModule(.{
        .root_source_file = b.path("src/entry.zig"),
        .target = target,
        .optimize = optimize,
        .strip = false,
        .imports = &.{
            .{ .name = "package", .module = package_mod },
            .{ .name = "board", .module = board_mod },
            .{ .name = "build_options", .module = opts.createModule() },
        },
    });

    const exe = b.addExecutable(.{
        .name = "blinky",
        .root_module = root_mod,
    });

    exe.setLinkerScript(b.path("link.ld"));
    exe.entry = .{ .symbol_name = "resetHandler" };
    b.installArtifact(exe);

    const uf2 = b.addSystemCommand(&.{ "picotool", "uf2", "convert" });
    uf2.addFileArg(exe.getEmittedBin());
    uf2.addArgs(&.{ "-t", "elf" });
    const uf2_out = uf2.addOutputFileArg("blinky.uf2");
    uf2.addArgs(&.{ "--family", "rp2350-arm-s" });
    b.getInstallStep().dependOn(&b.addInstallBinFile(uf2_out, "blinky.uf2").step);
}
