const std = @import("std");

const StackError = error{
    EmptyStack
};

const MergeSortFrame = struct {
    left: usize,
    right: usize,
    state: enum {
        NO_RECURSE,
        AFTER_LEFT,
        AFTER_RIGHT,
    },
};

fn SortStack(comptime T: type) type {
    return struct {
        const Self = @This();
        current_index: usize = 0,
        capacity: usize = 4,
        allocation: []T = undefined,

        pub fn push(self: *Self, allocator: anytype, item: T) !void {
            if (self.current_index == self.capacity) {
                self.capacity = self.capacity * 2;
                if (!allocator.resize(self.allocation, self.capacity)) {
                    self.allocation = try allocator.realloc(self.allocation, self.capacity);
                }
            }
            self.allocation[self.current_index] = item;
            self.current_index += 1;
        }

        pub fn pop(self: *Self) !T {
            if (self.current_index == 0) return StackError.EmptyStack;
            self.current_index -= 1;
            const ret = self.allocation[self.current_index];
            return ret;
        }

        pub fn deinit(self: *Self, allocator: anytype) void {
            allocator.free(self.allocation);
        }
    };
}

pub fn create_sort_stack(allocator: anytype, comptime T: type) !SortStack(T) {
    var stack = SortStack(T){};
    stack.allocation = try allocator.alloc(T, stack.capacity);
    return stack;
}

pub fn merge_sort(allocator: anytype, buf: anytype) !void {
    var stack = try create_sort_stack(allocator, MergeSortFrame);
    defer stack.deinit(allocator);
    const tempbuf = try allocator.alloc(@TypeOf(buf[0]), buf.len);
    defer allocator.free(tempbuf);
    try stack.push(allocator, .{.left = 0, .right = buf.len-1, .state = .NO_RECURSE});
    while (stack.current_index > 0) {
        var current_frame = &stack.allocation[stack.current_index - 1];
        const left: usize = current_frame.left;
        const right: usize = current_frame.right;
        const middle = left + ((right - left) / 2);
        switch (current_frame.state) {
            .NO_RECURSE => {
                if (left >= right) {
                    _ = try stack.pop();
                    continue;
                }
                current_frame.state = .AFTER_LEFT;
                try stack.push(allocator, .{.left = left, .right = middle, .state = .NO_RECURSE});
            },
            .AFTER_LEFT => {
                current_frame.state = .AFTER_RIGHT;
                try stack.push(allocator, .{.left = middle+1, .right = right, .state = .NO_RECURSE});
            },
            .AFTER_RIGHT => {
                try merge(buf, tempbuf, left, middle, right);
                _ = try stack.pop();
            }
        }
    }
    return;
}

fn merge(buf: anytype, tempbuf: anytype, min: usize, mid: usize, max: usize) !void {
    var left = tempbuf[min..mid+1];
    var right = tempbuf[mid+1..max+1];
    @memcpy(left[0..], buf[min..mid+1]);
    @memcpy(right[0..], buf[mid+1..max+1]);
    var i: usize = 0;
    var j: usize = 0;
    var buf__index: usize = min;
    while (i < left.len and j < right.len) : (buf__index += 1) {
        if (left[i] <= right[j]) {
            buf[buf__index] = left[i];
            i += 1;
        } else {
            buf[buf__index] = right[j];
            j += 1;
        }
    }
    if (i<left.len) {
        @memcpy(buf[buf__index..buf__index+left.len-i], left[i..]);
    } else if (j < right.len) {
        @memcpy(buf[buf__index..buf__index+right.len-j], right[j..]);
    }
}

pub fn printArr(arr: anytype) void {
    for (arr) |item| {
        std.debug.print("{d} ", .{item});
    }
}