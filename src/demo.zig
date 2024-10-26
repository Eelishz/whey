const std = @import("std");
const builtin = @import("builtin");

extern fn test_print() void;
extern fn initialize() void;

pub fn main() void {
    std.debug.print("Hello from demo\n", .{});
    test_print();

    initialize();
}
