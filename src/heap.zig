const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Heap(comptime T: type) type {
    return struct {
        allocator: Allocator,
        items: []T,
        capacity: usize,
        len: usize,
        comparator: *const fn (a: T, b: T) bool,

        const Self = @This();

        pub const Error = error{
            EmptyHeap,
        };

        pub fn init(allocator: Allocator, capacity: usize, comparator: *const fn (T, T) bool) !Self {
            return Self{
                .allocator = allocator,
                .items = try allocator.alloc(T, capacity),
                .capacity = capacity,
                .len = 0,
                .comparator = comparator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.items);
        }

        pub fn push(self: *Self, value: T) !void {
            if (self.len >= self.capacity) {
                const new_cap = if (self.capacity == 0) 1 else self.capacity * 2;
                self.items = try self.allocator.realloc(self.items, new_cap);
                self.capacity = new_cap;
            }
            self.items[self.len] = value;
            var i = self.len;
            self.len += 1;

            while (i != 0) {
                const parentIndex = (i - 1) / 2;
                if (self.comparator(self.items[i], self.items[parentIndex])) {
                    const tmp = self.items[i];
                    self.items[i] = self.items[parentIndex];
                    self.items[parentIndex] = tmp;
                    i = parentIndex;
                } else {
                    break;
                }
            }
        }

        pub fn pop(self: *Self) !T {
            if (self.len == 0) return Error.EmptyHeap;

            const result = self.items[0];
            self.len -= 1;
            self.items[0] = self.items[self.len];
            var i: usize = 0;

            while (true) {
                const left = 2 * i + 1;
                const right = 2 * i + 2;
                var smallest = i;

                if (left < self.len and self.comparator(self.items[left], self.items[smallest])) {
                    smallest = left;
                }
                if (right < self.len and self.comparator(self.items[right], self.items[smallest])) {
                    smallest = right;
                }
                if (smallest == i) break;

                const tmp = self.items[i];
                self.items[i] = self.items[smallest];
                self.items[smallest] = tmp;
                i = smallest;
            }

            return result;
        }

        pub fn peek(self: *Self) !T {
            if (self.len == 0) return Error.EmptyHeap;
            return self.items[0];
        }
    };
}
