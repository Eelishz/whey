const std = @import("std");
const builtin = @import("builtin");
const windows = @import("windows.zig");
const linux = @import("linux.zig");

const Vec2f = extern struct {
    x: f32,
    y: f32,
};

const Texture = extern struct {};

const Sprite = extern struct {
    texture: *Texture,
    altas_width: i32,
    altas_hight: i32,
    world_position: Vec2f,
    z_index: i32,
};

const Camera = extern struct {
    world_position: Vec2f,
    fov: f32,
};

export fn test_print() void {
    std.debug.print("Hello from lib\n", .{});
}

fn _update() callconv(.C) void {}

pub fn wWinMain(
    h_instace: std.os.windows.HINSTANCE,
    h_prev_instance: ?std.os.windows.HINSTANCE,
    p_cmd_line: std.os.windows.PWSTR,
    n_cmd_show: std.os.windows.INT,
) std.os.windows.INT {
    _ = h_prev_instance;
    _ = p_cmd_line;
    windows.initialize(_update, h_instace, n_cmd_show) catch @panic("window init failed");
    return 0;
}

export fn initialize(update: *const fn () callconv(.C) void) void {
    switch (builtin.os.tag) {
        .windows => {
            _ = std.start.call_wWinMain();
        },
        .linux => {
            linux.initialize(update) catch @panic("window init failed");
        },
        else => {
            @panic("unsupported target");
        },
    }
}
