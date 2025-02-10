const std = @import("std");
const heap = std.heap;
const print = std.debug.print;

const Stack = @import("stack.zig").Stack;
// const LinkedList = @import("linkedlist.zig").LinkedList;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var stack = Stack(i32){ .allocator = allocator };
    defer stack.deinit();

    for (0..5) |i| {
        try stack.push(@intCast(i));
        print("{}\n", .{stack});
    }

    while (stack.pop()) |item| {
        print("{}\n", .{item});
        print("{}\n", .{stack});
    }

    stack.deinit();

    for (0..10) |i| {
        try stack.push(@intCast(i));
        print("{}\n", .{stack});
    }
}
