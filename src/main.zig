const std = @import("std");
const fmt = std.fmt;
const heap = std.heap;
const mem = std.mem;
const print = std.debug.print;
const time = std.time;

const Stack = @import("stack.zig").Stack;
const Trie = @import("trie.zig");
// const LinkedList = @import("linkedlist.zig").LinkedList;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Stack
    print("\n\nStack: \n", .{});

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

    //Trie
    print("\n\nTrie: \n", .{});

    const corpus = @embedFile("alice.txt");

    var iter = mem.tokenizeScalar(u8, corpus, ' ');

    var trie = Trie.init(allocator);
    defer trie.deinit();

    try trie.insert("caterpillar");
    try trie.insert("category");
    print("caterpillar: {} | ", .{trie.lookup("caterpillar")});
    print("category: {} | ", .{trie.lookup("category")});
    print("cat: {}\n\n", .{trie.lookup("cat")});

    var words: usize = 0;
    var found: usize = 0;

    var timer = try std.time.Timer.start();

    while (iter.next()) |word| {
        try trie.insert(word);
        words += 1;
    }

    iter.index = 0;

    while (iter.next()) |word| {
        if (trie.lookup(word)) found += 1;
    }

    print(
        \\words:    {}
        \\found:    {}
        \\took:     {}
        \\
    , .{
        words,
        found,
        fmt.fmtDuration(timer.lap()),
    });
}
