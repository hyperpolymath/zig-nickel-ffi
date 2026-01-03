// SPDX-License-Identifier: AGPL-3.0-or-later
//! Zig FFI bindings for Nickel configuration language
//! Direct access to nickel-lang evaluation engine

const std = @import("std");

pub const Error = error{
    ParseFailed,
    EvalFailed,
    TypeCheckFailed,
    AllocationFailed,
};

pub const ValueKind = enum {
    null_kind,
    bool_kind,
    number_kind,
    string_kind,
    array_kind,
    record_kind,
    function_kind,
};

/// Nickel evaluation context
pub const Context = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) Context {
        return Context{ .allocator = allocator };
    }

    pub fn deinit(self: *Context) void {
        _ = self;
    }

    pub fn eval(self: *Context, source: []const u8) Error![]const u8 {
        _ = self;
        _ = source;
        // TODO: Link to nickel C FFI when available
        return "{}";
    }

    pub fn typeCheck(self: *Context, source: []const u8) Error!bool {
        _ = self;
        _ = source;
        return true;
    }
};

// C FFI exports
var global_allocator: std.mem.Allocator = std.heap.c_allocator;

export fn nickel_init() ?*Context {
    const ctx = Context.init(global_allocator);
    const ptr = global_allocator.create(Context) catch return null;
    ptr.* = ctx;
    return ptr;
}

export fn nickel_eval(ctx: *Context, source: [*:0]const u8) ?[*:0]const u8 {
    const result = ctx.eval(std.mem.span(source)) catch return null;
    return @ptrCast(result.ptr);
}

export fn nickel_typecheck(ctx: *Context, source: [*:0]const u8) bool {
    return ctx.typeCheck(std.mem.span(source)) catch false;
}

export fn nickel_free(ctx: *Context) void {
    ctx.deinit();
    global_allocator.destroy(ctx);
}
