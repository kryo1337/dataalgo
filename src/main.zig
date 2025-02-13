const std = @import("std");
const fmt = std.fmt;
const heap = std.heap;
const mem = std.mem;
const print = std.debug.print;
const time = std.time;

const LinkedList = @import("linkedlist.zig").LinkedList;
const Stack = @import("stack.zig").Stack;
const Trie = @import("trie.zig");
const Tree = @import("tree.zig").Tree;
const Heap = @import("heap.zig").Heap;
const HashTable = @import("hashtable.zig").HashTable;

fn comparator(a: i32, b: i32) bool {
    return a < b;
}

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // LinkedList
    print("\n\nLinkedList: \n", .{});
    var list = LinkedList.init(allocator);
    defer list.deinit();

    try list.append(10);
    try list.append(5);
    try list.append(7);
    try list.append(1);
    try list.append(8);

    _ = list.remove(10);
    _ = list.remove(7);
    _ = list.remove(8);

    var items = try list.toOwnedSlice();
    _ = &items;
    defer allocator.free(items);
    print("{any}\n", .{items});

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

    //Tree
    print("\n\nTree:\n", .{});
    const stdout = std.io.getStdOut().writer();
    var tree = try Tree(i32).init(allocator, 10);
    defer tree.deinit();

    _ = try tree.insert(5);
    _ = try tree.insert(15);
    _ = try tree.insert(3);
    _ = try tree.insert(7);
    _ = try tree.insert(12);
    _ = try tree.insert(17);

    try tree.format("", std.fmt.FormatOptions{}, stdout);

    if (tree.find(7)) |node| {
        try stdout.print("Found node with value: {d}\n", .{node.value});
    } else {
        try stdout.print("Value 7 not found.\n", .{});
    }

    try tree.remove(10);
    try stdout.print("\nAfter removing 10:\n", .{});
    try tree.format("", std.fmt.FormatOptions{}, stdout);

    //Heap
    print("\n\nHeap:\n", .{});
    const int_heap = Heap(i32);

    var heaps = try int_heap.init(allocator, 10, &comparator);
    defer heaps.deinit();

    try heaps.push(5);
    try heaps.push(3);
    try heaps.push(8);
    try heaps.push(1);
    try heaps.push(4);

    const min_val = try heaps.peek();
    print("min_val: {}\n", .{min_val});

    print("poppin:\n", .{});
    while (heaps.len > 0) {
        const value = try heaps.pop();
        print("{}\n", .{value});
    }

    //Hash Table
    print("\n\nHash Table:\n", .{});

    var ht = try HashTable.init(allocator, 16);
    defer ht.deinit();

    try ht.insert("siema", "hello");
    try ht.insert("spier", "nara");

    if (ht.get("siema")) |val| {
        print("found key: siema, value: {s}\n", .{val});
    } else {
        print("not found key: siema\n", .{});
    }

    try ht.insert("siema", "elo");
    if (ht.get("siema")) |val| {
        print("updated key: siema: {s}\n", .{val});
    }

    if (ht.delete("spier")) {
        print("deleted key: spier\n", .{});
    } else {
        print("key: spier, not found\n", .{});
    }

    if (ht.get("spier") == null) {
        print("key: spier, isnt in table\n", .{});
    } else {
        print("key: spier, is in table\n", .{});
    }
}
