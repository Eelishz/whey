const std = @import("std");
const builtin = @import("builtin");
const windows = @import("windows.zig");
const linux = @import("linux.zig");

pub const update_fn = *const fn (delta_time: f32, event: Event) callconv(.C) void;

pub const Vec2f = struct {
    x: f32,
    y: f32,
};

pub const Texture = struct {};

pub const Sprite = struct {
    texture: *Texture,
    altas_width: i32,
    altas_hight: i32,
    world_position: Vec2f,
    z_index: i32,
};

pub const Camera = struct {
    world_position: Vec2f,
    fov: f32,
};

pub const Event = enum { None };

pub fn test_print() void {
    std.debug.print("Hello from lib\n", .{});
}
