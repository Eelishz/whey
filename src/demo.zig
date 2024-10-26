const std = @import("std");
const builtin = @import("builtin");
const whey = @import("whey.zig");

pub fn main() void {
    std.debug.print("Hello from demo\n", .{});
    whey.test_print();

    whey.initialize(update);
}

fn update(delta_time: f32, event: whey.Event) callconv(.C) void {
    _ = delta_time;
    _ = event;
    std.debug.print("new frame\n", .{});
}
