const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Tree(comptime T: type) type {
    return struct {
        allocator: Allocator,
        root: ?*Node,

        const Self = @This();

        pub const Error = error{
            NotFound,
        };

        pub const Node = struct {
            value: T,
            parent: ?*Node,
            left: ?*Node,
            right: ?*Node,

            pub fn init(value: T) Node {
                return Node{
                    .value = value,
                    .parent = null,
                    .left = null,
                    .right = null,
                };
            }
        };

        pub fn init(allocator: Allocator, value: T) !*Self {
            var tree = try allocator.create(Self);
            tree.allocator = allocator;
            tree.root = try allocator.create(Node);
            tree.root.?.* = Node.init(value);
            return tree;
        }

        pub fn deinit(self: *Self) void {
            if (self.root) |root| {
                self.deinitNode(root);
            }
            self.allocator.destroy(self);
        }

        fn deinitNode(self: *Self, node: *Node) void {
            if (node.left) |left| {
                self.deinitNode(left);
            }
            if (node.right) |right| {
                self.deinitNode(right);
            }
            self.allocator.destroy(node);
        }

        pub fn insert(self: *Self, value: T) !*Node {
            if (self.root == null) {
                self.root = try self.allocator.create(Node);
                self.root.?.* = Node.init(value);
                return self.root.?;
            }
            var current = self.root.?;
            var new_node = try self.allocator.create(Node);
            new_node.* = Node.init(value);

            while (true) {
                if (value < current.value) {
                    if (current.left) |child| {
                        current = child;
                    } else {
                        current.left = new_node;
                        new_node.parent = current;
                        break;
                    }
                } else {
                    if (current.right) |child| {
                        current = child;
                    } else {
                        current.right = new_node;
                        new_node.parent = current;
                        break;
                    }
                }
            }
            return new_node;
        }

        pub fn find(self: *Self, value: T) ?*Node {
            var current = self.root;
            while (current) |node| {
                if (value == node.value) {
                    return node;
                } else if (value < node.value) {
                    current = node.left;
                } else {
                    current = node.right;
                }
            }

            return null;
        }

        fn removeNode(self: *Self, node: *Node) !void {
            // two children
            if (node.left != null and node.right != null) {
                var successor = node.right.?;
                while (successor.left) |child| {
                    successor = child;
                }

                node.value = successor.value;
                try self.removeNode(successor);
                return;
            }

            // one child at most
            const child: ?*Node = if (node.left != null) node.left else node.right;

            if (node.parent == null) {
                self.root = child;
                if (child) |c| {
                    c.parent = null;
                }
            } else {
                if (node.parent.?.left == node) {
                    node.parent.?.left = child;
                } else {
                    node.parent.?.right = child;
                }
                if (child) |c| {
                    c.parent = node.parent;
                }
            }
            self.allocator.destroy(node);
        }

        pub fn remove(self: *Self, value: T) !void {
            const node = self.find(value);
            if (node == null) {
                return Error.NotFound;
            }
            try self.removeNode(node.?);
        }

        pub fn format(
            self: *Self,
            comptime _: []const u8,
            _: std.fmt.FormatOptions,
            writer: anytype,
        ) !void {
            try self.formatNode(self.root, writer, 0);
        }

        fn formatNode(self: *Self, node: ?*Node, writer: anytype, indent: usize) !void {
            if (node) |n| {
                try self.formatNode(n.left, writer, indent + 1);
                {
                    var i: usize = 0;
                    while (i < indent) : (i += 1) {
                        try writer.print(" ", .{});
                    }
                }
                try writer.print("{any}\n", .{n.value});
                try self.formatNode(n.right, writer, indent + 1);
            }
        }
    };
}
