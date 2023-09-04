const std = @import("std");

// Number of pages reserved for heap memory.
// This must match the number of pages used in script.js.
const number_of_pages = 2;

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
    lib.stack_size = std.wasm.page_size;

    lib.initial_memory = std.wasm.page_size * number_of_pages;
    lib.max_memory = std.wasm.page_size * number_of_pages;

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.installArtifact(lib);
}
