// SPDX-License-Identifier: AGPL-3.0-or-later
//! Zig FFI bindings for Nickel configuration language
//! Direct access to nickel-lang evaluation engine via Rust shim

const std = @import("std");
const c = @cImport({
    @cInclude("nickel_ffi.h");
});

pub const Error = error{
    ContextInitFailed,
    EvalFailed,
    TypeCheckFailed,
    AllocationFailed,
};

/// Nickel evaluation context
pub const Context = struct {
    ctx: *c.NickelContext,
    allocator: std.mem.Allocator,

    /// Initialize a new Nickel context
    pub fn init(allocator: std.mem.Allocator) Error!Context {
        const ctx = c.nickel_context_new();
        if (ctx == null) {
            return Error.ContextInitFailed;
        }
        return Context{
            .ctx = ctx.?,
            .allocator = allocator,
        };
    }

    /// Free the context
    pub fn deinit(self: *Context) void {
        c.nickel_context_free(self.ctx);
    }

    /// Evaluate Nickel source code and return the result as JSON
    pub fn eval(self: *Context, allocator: std.mem.Allocator, source: []const u8) Error![]const u8 {
        const source_z = allocator.dupeZ(u8, source) catch return Error.AllocationFailed;
        defer allocator.free(source_z);

        const result = c.nickel_eval(self.ctx, source_z.ptr);
        if (result == null) {
            return Error.EvalFailed;
        }
        defer c.nickel_string_free(result);

        const result_slice = std.mem.span(result);
        return allocator.dupe(u8, result_slice) catch return Error.AllocationFailed;
    }

    /// Type-check Nickel source code
    pub fn typecheck(self: *Context, allocator: std.mem.Allocator, source: []const u8) Error!bool {
        const source_z = allocator.dupeZ(u8, source) catch return Error.AllocationFailed;
        defer allocator.free(source_z);

        return c.nickel_typecheck(self.ctx, source_z.ptr) == 1;
    }
};

/// Get the Nickel version string
pub fn version() []const u8 {
    return std.mem.span(c.nickel_version());
}

// =============================================================================
// C FFI re-exports (for other languages to use Zig wrapper)
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
    // Convert to C string - caller must free
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
    // Free up to null terminator
    const slice = std.mem.span(s);
    global_allocator.free(slice[0 .. slice.len + 1]);
}

export fn zig_nickel_version() [*:0]const u8 {
    return c.nickel_version();
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
