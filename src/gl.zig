const std = @import("std");
const glcorearb = @cImport({
    @cInclude("include/glcorearb.h");
});

extern "opengl32" fn wglGetProcAddress(proc: [*:0]const u8) callconv(.C) ?*anyopaque;

const proc_type_entry = struct { k: []const u8, v: type };

const gl_proc_types = [1]proc_type_entry{
    .{ .k = "glBufferData", .v = (*const fn (u32, usize, *anyopaque, u32) callconv(.C) void) },
};

fn strcmp(a: [*:0]const u8, b: []const u8) bool {
    const len_a = std.mem.len(a);
    const len_b = b.len;

    if (len_a != len_b) {
        return false;
    }

    var i = 0;
    while (i < len_a) {
        const ca = a[i];
        const cb = b[i];
        std.debug.assert(ca != 0);

        if (ca != cb) {
            return false;
        }

        i += 1;
    }
    return true;
}

fn get_proc_type(comptime proc: [*:0]const u8) !type {
    // TODO: this is O(1) and could be
    // improved if compile times get long.
    // A static hashmap would be fairly
    // easy to implement.
    for (gl_proc_types) |entry| {
        if (strcmp(proc, entry.k)) {
            return entry.v;
        }
    }
    return error.typenotfound;
}

pub fn get_proc_address(comptime proc: [*:0]const u8) (get_proc_type(proc) catch @compileError("unable to lookup gl type")) {
    const T = try get_proc_type(proc);
    const fnptr = wglGetProcAddress(proc);
    return @as(T, @ptrCast(fnptr));
}
