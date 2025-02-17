const std = @import("std");

pub fn binarySearch(comptime T: type, arr: []T, target: T, cmp: fn (a: T, b: T) i32) ?usize {
    if (arr.len == 0) return null;
    return binarySearchInternal(T, arr, target, cmp, 0, arr.len - 1);
}

fn binarySearchInternal(comptime T: type, arr: []T, target: T, cmp: fn (a: T, b: T) i32, low: usize, high: usize) ?usize {
    if (low > high) return null;

    const mid = low + ((high - low) / 2);
    const rst = cmp(arr[mid], target);

    if (rst == 0) {
        return mid;
    } else if (rst > 0) {
        if (mid == 0) return null;
        return binarySearchInternal(T, arr, target, cmp, low, mid - 1);
    } else {
        return binarySearchInternal(T, arr, target, cmp, mid + 1, high);
    }
}

fn intCmp(a: i32, b: i32) i32 {
    if (a < b) return -1;
    if (a > b) return 1;
    return 0;
}

pub fn main() void {
    var data = [_]i32{ 1, 3, 5, 7, 9, 11, 13, 15 };
    const slice = data[0..];

    const target = 7;
    const idx = binarySearch(i32, slice, target, intCmp);
    if (idx) |found| {
        std.debug.print("found {} at index {}\n", .{ target, found });
    } else {
        std.debug.print("{} not found\n", .{target});
    }
}
