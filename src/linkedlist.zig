const std = @import("std");
const Allocator = std.mem.Allocator;

pub const LinkedList = struct {
    head: ?*Node,
    tail: ?*Node,
    count: usize,
    allocator: Allocator,

    const Node = struct {
        next: ?*Node,
        data: i32,
    };

    pub fn new(allocator: Allocator) LinkedList {
        return LinkedList{
            .head = null,
            .tail = null,
            .count = 0,
            .allocator = allocator,
        };
    }

    pub fn free(self: *LinkedList) void {
        var current = self.head;
        while (current) |node| {
            current = node.next;
            self.allocator.destroy(node);
        }
        self.head = null;
        self.tail = null;
    }

    pub fn append(self: *LinkedList, value: i32) !void {
        const node = try self.allocator.create(Node);
        node.* = .{
            .next = null,
            .data = value,
        };

        if (self.tail) |tail| {
            tail.next = node;
        }
        self.tail = node;
        if (self.head == null) {
            self.head = node;
        }

        self.count += 1;
    }

    pub fn prepend(self: *LinkedList, value: i32) !void {
        const node = try self.allocator.create(Node);
        node.* = .{
            .next = null,
            .data = value,
        };

        if (self.head) |head| {
            node.next = head;
        }
        self.head = node;
        if (self.tail == null) {
            self.tail = node;
        }

        self.count += 1;
    }

    pub fn remove(self: *LinkedList, value: i32) bool {
        var prev_node: ?*Node = null;
        var find = self.head;
        while (find) |node| {
            if (node.data == value) break;
            prev_node = node;
            find = node.next;
        }

        if (find) |node| {
            if (prev_node) |prev| {
                prev.next = node.next;
                if (node == self.tail) {
                    self.tail = prev;
                }
            } else {
                self.head = node.next;
                if (self.head == null) {
                    self.tail = null;
                }
            }

            self.allocator.destroy(node);
            self.count -= 1;
            return true;
        }

        return false;
    }

    pub fn toOwnedSlice(self: *LinkedList) ![]i32 {
        const result = try self.allocator.alloc(i32, self.count);
        var current = self.head;
        var idx: usize = 0;
        while (current) |node| {
            result[idx] = node.data;
            idx += 1;
            current = node.next;
        }
        return result;
    }
};
