// SPDX-License-Identifier: AGPL-3.0-or-later
//! Build configuration for zig-nickel-ffi (Zig 0.15+)
//!
//! This requires the Rust shim to be built first:
//!   cd shim && cargo build --release

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create root module
    const root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    // Add include path for C header
    root_module.addIncludePath(b.path("include"));

    // Link to Rust shim
    root_module.addLibraryPath(b.path("shim/target/release"));
    root_module.linkSystemLibrary("nickel_ffi_shim", .{});

    // Static library
    const lib = b.addLibrary(.{
        .linkage = .static,
        .name = "zig-nickel-ffi",
        .root_module = root_module,
    });
    b.installArtifact(lib);

    // Shared library for FFI consumers
    const shared_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    shared_module.addIncludePath(b.path("include"));
    shared_module.addLibraryPath(b.path("shim/target/release"));
    shared_module.linkSystemLibrary("nickel_ffi_shim", .{});

    const shared_lib = b.addLibrary(.{
        .linkage = .dynamic,
        .name = "nickel_ffi",
        .root_module = shared_module,
    });
    b.installArtifact(shared_lib);

    // Tests
    const test_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    test_module.addIncludePath(b.path("include"));
    test_module.addLibraryPath(b.path("shim/target/release"));
    test_module.linkSystemLibrary("nickel_ffi_shim", .{});

    const unit_tests = b.addTest(.{
        .root_module = test_module,
    });

    const run_tests = b.addRunArtifact(unit_tests);
    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);

    // Build shim step
    const build_shim = b.addSystemCommand(&.{ "cargo", "build", "--release", "--manifest-path", "shim/Cargo.toml" });
    const shim_step = b.step("shim", "Build the Rust shim library");
    shim_step.dependOn(&build_shim.step);
}
