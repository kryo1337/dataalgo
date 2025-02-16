const std = @import("std");

pub fn quickSort(comptime T: type, arr: []T, less: fn (a: T, b: T) bool) void {
    if (arr.len <= 1) return;
    quickSortInternal(T, arr, 0, arr.len - 1, less);
}

fn quickSortInternal(comptime T: type, arr: []T, low: usize, high: usize, less: fn (a: T, b: T) bool) void {
    if (low < high) {
        const p = partition(T, arr, low, high, less);
        if (p > 0) {
            quickSortInternal(T, arr, low, p - 1, less);
        }
        quickSortInternal(T, arr, p + 1, high, less);
    }
}

fn partition(comptime T: type, arr: []T, low: usize, high: usize, less: fn (a: T, b: T) bool) usize {
    const pivot = arr[high];
    var i: usize = low;
    var j: usize = low;
    while (j < high) : (j += 1) {
        if (less(arr[j], pivot)) {
            std.mem.swap(T, &arr[i], &arr[j]);
            i += 1;
        }
    }
    std.mem.swap(T, &arr[i], &arr[high]);
    return i;
}

fn intLess(a: i32, b: i32) bool {
    return a < b;
}

pub fn main() !void {
    var data = [_]i32{ 10, 5, 2, 7, 4, 9, 12, 1, 8, 6, 11, 3 };
    const slice = data[0..];
    std.debug.print("Before sort: {any}\n", .{slice});

    var timer = try std.time.Timer.start();
    quickSort(i32, slice, intLess);

    std.debug.print("After sort: {any}\n", .{slice});
    std.debug.print("Elapsed time: {} ms\n", .{timer.lap()});
}
