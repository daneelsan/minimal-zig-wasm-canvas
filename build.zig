const std = @import("std");

const page_size = 1024 * 64;

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    const lib = b.addSharedLibrary(.{
        .name = "checkerboard",

        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = .{ .path = "src/checkerboard.zig" },

        .target = .{
            .cpu_arch = .wasm32,
            .os_tag = .freestanding,
            .abi = .musl,
        },

        .optimize = .ReleaseSmall,
    });

    // <https://github.com/ziglang/zig/issues/8633>
    lib.global_base = 6560;
    lib.rdynamic = true;
    lib.import_memory = true;

    // TODO: Find out why required memory is so high
    // Attempting to build with `page_size * 2` fails with:
    // `error: wasm-ld: initial memory too small, 1095136 bytes needed`
    lib.initial_memory = page_size * 17;
    lib.max_memory = page_size * 17;

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
