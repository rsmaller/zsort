const std = @import("std");
const mergesort = @import("mergesort.zig");
const cs210thing = @import("cs210thing");

pub fn main() !void {
    var stdout_buf : [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    var stdout = &stdout_writer.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const random_buf = try allocator.alloc(usize, 21);

    random_buf[0] = 1;
    for (0..random_buf.len) |i| {
        random_buf[i] = random_buf.len - i;
        try stdout.print("{d} ", .{random_buf[i]});
    }
    try stdout.print("\n", .{});
    try mergesort.sort(allocator, random_buf);
    for (0..random_buf.len) |i| {
        try stdout.print("{d} ", .{random_buf[i]});
    }
    try stdout.print("\n", .{});
    try stdout.flush();
}