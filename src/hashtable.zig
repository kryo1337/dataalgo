const std = @import("std");
const Allocator = std.mem.Allocator;

pub const HashTable = struct {
    allocator: Allocator,
    entries: []Entry,
    capacity: usize,

    const Self = @This();

    const Entry = struct {
        key: []const u8,
        value: []const u8,
        used: bool,
        deleted: bool,
    };

    pub const Error = error{
        HashTableFull,
    };

    fn hash(key: []const u8) usize {
        var h: usize = 1469598103934665603;
        for (key) |b| {
            h = (h ^ @as(usize, b)) *% @as(usize, 1099511628211);
        }
        return h;
    }

    pub fn init(allocator: Allocator, capacity: usize) !Self {
        const entries = try allocator.alloc(Entry, capacity);
        for (entries) |*entry| {
            entry.* = Entry{
                .key = "",
                .value = "",
                .used = false,
                .deleted = false,
            };
        }
        return Self{
            .allocator = allocator,
            .entries = entries,
            .capacity = capacity,
        };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.free(self.entries);
    }

    pub fn insert(self: *Self, key: []const u8, value: []const u8) !void {
        const index = hash(key) % self.capacity;
        var tombstone: ?usize = null;
        var i: usize = 0;
        while (i < self.capacity) : (i += 1) {
            const idx = (index + i) % self.capacity;
            var entry = &self.entries[idx];
            if (entry.used) {
                if (!entry.deleted and std.mem.eql(u8, entry.key, key)) {
                    entry.value = value;
                    return;
                } else if (entry.deleted and tombstone == null) {
                    tombstone = idx;
                }
            } else {
                if (tombstone) |ts| {
                    self.entries[ts] = Entry{
                        .key = key,
                        .value = value,
                        .used = true,
                        .deleted = false,
                    };
                } else {
                    entry.* = Entry{
                        .key = key,
                        .value = value,
                        .used = true,
                        .deleted = false,
                    };
                }
                return;
            }
        }
        if (tombstone) |ts| {
            self.entries[ts] = Entry{
                .key = key,
                .value = value,
                .used = true,
                .deleted = false,
            };
            return;
        }
        return Error.HashTableFull;
    }

    pub fn get(self: *Self, key: []const u8) ?[]const u8 {
        const index = hash(key) % self.capacity;
        var i: usize = 0;
        while (i < self.capacity) : (i += 1) {
            const idx = (index + i) % self.capacity;
            const entry = self.entries[idx];
            if (!entry.used) {
                return null;
            }
            if (!entry.deleted and std.mem.eql(u8, entry.key, key)) {
                return entry.value;
            }
        }
        return null;
    }

    pub fn delete(self: *Self, key: []const u8) bool {
        const index = hash(key) % self.capacity;
        var i: usize = 0;
        while (i < self.capacity) : (i += 1) {
            const idx = (index + i) % self.capacity;
            var entry = &self.entries[idx];
            if (!entry.used) {
                return false;
            }
            if (!entry.deleted and std.mem.eql(u8, entry.key, key)) {
                entry.deleted = true;
                return true;
            }
        }
        return false;
    }
};
