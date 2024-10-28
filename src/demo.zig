const std = @import("std");
const builtin = @import("builtin");
const whey = @import("whey.zig");
const macros = @import("macros.zig");

pub const wWinMain = macros.create_winmain(update);
pub const main = macros.create_main(update);

fn update(delta_time: f32, event: whey.Event) callconv(.C) void {
    _ = delta_time;
    _ = event;
    std.debug.print("new frame\n", .{});
}
