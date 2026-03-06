const std = @import("std");
const sort = @import("sort.zig");

pub fn main() !void {
    var stdout_buf : [1024]u8 = undefined;
    var stdout_writer = std.fs.File.stdout().writer(&stdout_buf);
    var stdout = &stdout_writer.interface;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);
    if (args.len < 2) {
        try stdout.print("Please provide an argument.\n", .{});
        try stdout.flush();
        return;
    }
    const n = try std.fmt.parseInt(u16, args[1], 10);
    const random_buf = try allocator.alloc(u16, n);

    random_buf[0] = 1;
    for (0..random_buf.len) |i| {
        random_buf[i] = std.crypto.random.intRangeAtMost(u16, 0, 100);
        try stdout.print("{d} ", .{random_buf[i]});
    }
    try stdout.print("\n", .{});
    try sort.merge_sort(allocator, random_buf);
    for (0..random_buf.len) |i| {
        try stdout.print("{d} ", .{random_buf[i]});
    }
    try stdout.print("\n", .{});
    try stdout.flush();
}