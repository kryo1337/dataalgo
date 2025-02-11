const std = @import("std");
const mem = std.mem;

const NodeMap = std.AutoHashMap(u8, Node);

const Node = struct {
    terminal: bool = false,
    children: NodeMap,

    fn init(allocator: mem.Allocator) Node {
        return .{ .children = NodeMap.init(allocator) };
    }

    fn deinit(self: *Node) void {
        var iter = self.children.valueIterator();
        while (iter.next()) |node| node.deinit();
        self.children.deinit();
    }
};

allocator: mem.Allocator,
root: Node,

const Trie = @This();

pub fn init(allocator: mem.Allocator) Trie {
    return .{
        .allocator = allocator,
        .root = Node.init(allocator),
    };
}

pub fn deinit(self: *Trie) void {
    self.root.deinit();
}

pub fn insert(self: *Trie, str: []const u8) !void {
    var node = &self.root;

    for (str, 0..) |b, i| {
        var gop = try node.children.getOrPut(b);

        if (!gop.found_existing) {
            gop.value_ptr.* = Node.init(self.allocator);
        }

        if (i == str.len - 1) gop.value_ptr.terminal = true;

        node = gop.value_ptr;
    }
}

pub fn lookup(self: Trie, str: []const u8) bool {
    var node = self.root;

    for (str, 0..) |b, i| {
        if (node.children.get(b)) |n| {
            if (i == str.len - 1 and n.terminal) return true;

            node = n;
        } else break;
    }

    return false;
}
