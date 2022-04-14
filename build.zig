const std = @import("std");

const page_size = 65536; // in bytes

pub fn build(b: *std.build.Builder) void {
    // Adds the option -Drelease=[bool] to create a release build, which we set to be ReleaseSmall by default.
    b.setPreferredReleaseMode(.ReleaseSmall);
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const checkerboard_step = b.step("checkerboard", "Compiles checkerboard.zig");
    const checkerboard_lib = b.addSharedLibrary("checkerboard", "./checkerboard.zig", .unversioned);
    checkerboard_lib.setBuildMode(mode);
    checkerboard_lib.setTarget(.{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
        .abi = .musl,
    });
    checkerboard_lib.setOutputDir(".");

    // https://github.com/ziglang/zig/issues/8633
    checkerboard_lib.import_memory = true; // import linear memory from the environment
    checkerboard_lib.initial_memory = 2 * page_size; // initial size of the linear memory (1 page = 64kB)
    checkerboard_lib.max_memory = 2 * page_size; // maximum size of the linear memory
    checkerboard_lib.global_base = 6560; // offset in linear memory to place global data

    checkerboard_lib.install();
    checkerboard_step.dependOn(&checkerboard_lib.step);
}
