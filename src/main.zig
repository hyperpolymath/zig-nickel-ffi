// SPDX-License-Identifier: AGPL-3.0-or-later
//! Zig FFI bindings for Nickel configuration language
//! Direct access to nickel-lang evaluation engine via Rust shim
//!
//! No C code involved - just Zig declaring extern functions that
//! link to Rust's C-ABI exports.

const std = @import("std");

// =============================================================================
// External declarations (linking to Rust shim via C ABI)
// =============================================================================

const RustContext = opaque {};

extern "C" fn nickel_context_new() ?*RustContext;
extern "C" fn nickel_context_free(ctx: *RustContext) void;
extern "C" fn nickel_eval(ctx: *RustContext, source: [*:0]const u8) ?[*:0]u8;
extern "C" fn nickel_typecheck(ctx: *RustContext, source: [*:0]const u8) c_int;
extern "C" fn nickel_string_free(s: [*:0]u8) void;
extern "C" fn nickel_version() [*:0]const u8;

// =============================================================================
// Zig API
// =============================================================================

pub const Error = error{
    ContextInitFailed,
    EvalFailed,
    TypeCheckFailed,
    AllocationFailed,
};

/// Nickel evaluation context
pub const Context = struct {
    ctx: *RustContext,
    allocator: std.mem.Allocator,

    /// Initialize a new Nickel context
    pub fn init(allocator: std.mem.Allocator) Error!Context {
        const ctx = nickel_context_new() orelse return Error.ContextInitFailed;
        return Context{
            .ctx = ctx,
            .allocator = allocator,
        };
    }

    /// Free the context
    pub fn deinit(self: *Context) void {
        nickel_context_free(self.ctx);
    }

    /// Evaluate Nickel source code and return the result as a string
    pub fn eval(self: *Context, allocator: std.mem.Allocator, source: []const u8) Error![]const u8 {
        const source_z = allocator.dupeZ(u8, source) catch return Error.AllocationFailed;
        defer allocator.free(source_z);

        const result = nickel_eval(self.ctx, source_z.ptr) orelse return Error.EvalFailed;
        defer nickel_string_free(result);

        const result_slice = std.mem.span(result);
        return allocator.dupe(u8, result_slice) catch return Error.AllocationFailed;
    }

    /// Type-check Nickel source code
    pub fn typecheck(self: *Context, allocator: std.mem.Allocator, source: []const u8) Error!bool {
        const source_z = allocator.dupeZ(u8, source) catch return Error.AllocationFailed;
        defer allocator.free(source_z);

        return nickel_typecheck(self.ctx, source_z.ptr) == 1;
    }
};

/// Get the Nickel version string
pub fn version() []const u8 {
    return std.mem.span(nickel_version());
}

// =============================================================================
// C ABI exports (for other languages to use this Zig library)
// =============================================================================

var global_allocator: std.mem.Allocator = std.heap.c_allocator;

export fn zig_nickel_init() ?*Context {
    const ctx = Context.init(global_allocator) catch return null;
    const ptr = global_allocator.create(Context) catch return null;
    ptr.* = ctx;
    return ptr;
}

export fn zig_nickel_eval(ctx: *Context, source: [*:0]const u8) ?[*:0]const u8 {
    const result = ctx.eval(global_allocator, std.mem.span(source)) catch return null;
    const result_z = global_allocator.dupeZ(u8, result) catch return null;
    global_allocator.free(result);
    return result_z.ptr;
}

export fn zig_nickel_typecheck(ctx: *Context, source: [*:0]const u8) bool {
    return ctx.typecheck(global_allocator, std.mem.span(source)) catch false;
}

export fn zig_nickel_free(ctx: *Context) void {
    ctx.deinit();
    global_allocator.destroy(ctx);
}

export fn zig_nickel_string_free(s: [*:0]u8) void {
    const slice = std.mem.span(s);
    global_allocator.free(slice[0 .. slice.len + 1]);
}

export fn zig_nickel_version() [*:0]const u8 {
    return nickel_version();
}

// =============================================================================
// Tests
// =============================================================================

test "version" {
    const v = version();
    try std.testing.expect(v.len > 0);
}

test "Context.init and deinit" {
    var ctx = try Context.init(std.testing.allocator);
    ctx.deinit();
}

test "Context.eval simple" {
    var ctx = try Context.init(std.testing.allocator);
    defer ctx.deinit();

    const result = try ctx.eval(std.testing.allocator, "1 + 2");
    defer std.testing.allocator.free(result);

    try std.testing.expectEqualStrings("3", result);
}

test "Context.typecheck valid" {
    var ctx = try Context.init(std.testing.allocator);
    defer ctx.deinit();

    const valid = try ctx.typecheck(std.testing.allocator, "{ x = 1, y = 2 }");
    try std.testing.expect(valid);
}
