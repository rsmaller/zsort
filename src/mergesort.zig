const std = @import("std");

pub fn sort(allocator: anytype, buf: anytype) !void {
    try mergeSort(allocator, buf, 0, buf.len-1);
}

fn mergeSort(allocator: anytype, buf: anytype, min: usize, max: usize) !void {
    if (min < max) {
        const middle = min + ((max - min) / 2);
        try mergeSort(allocator, buf, min, middle);
        try mergeSort(allocator, buf, middle+1, max);
        try merge(allocator, buf, min, middle, max);
    }
    return;
}

pub fn printArr(arr: anytype) void {
    for (arr) |item| {
        std.debug.print("{d} ", .{item});
    }
}

fn merge(allocator: anytype, buf : anytype, min: usize, mid: usize, max: usize) !void {
    const elementType = @TypeOf(buf[0]);
    var left: []elementType = try allocator.alloc(elementType, mid - min + 1);
    var right: []elementType = try allocator.alloc(elementType, max - mid);
    defer allocator.free(left);
    defer allocator.free(right);
    for (min..mid+1) |i| {
        left[i-min] = buf[i];
    }
    for (mid+1..max+1) |i| {
        right[i-mid-1] = buf[i];
    }
    var i: usize = 0;
    var j: usize = 0;
    var bufIndex: usize = min;
    while (i < left.len and j < right.len) : (bufIndex += 1) {
        if (left[i] <= right[i]) {
            buf[bufIndex] = left[i];
            i += 1;
        } else {
            buf[bufIndex] = right[j];
            j += 1;
        }
    }
    while (i < left.len) : (bufIndex += 1) {
        buf[bufIndex] = left[i];
        i += 1;
    }
    while (j < right.len) : (bufIndex += 1) {
        buf[bufIndex] = right[j];
        j += 1;
    }
}