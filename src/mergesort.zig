const std = @import("std");

pub fn mergeSort(comptime T: type, arr: []T, less: fn (a: T, b: T) bool) !void {
    var allocator = std.heap.page_allocator;
    const temp = try allocator.alloc(T, arr.len);
    defer allocator.free(temp);

    mergeSortInternal(T, arr, temp, less);
}

fn mergeSortInternal(comptime T: type, arr: []T, temp: []T, less: fn (a: T, b: T) bool) void {
    if (arr.len <= 1) return;
    const mid = arr.len / 2;
    mergeSortInternal(T, arr[0..mid], temp[0..mid], less);
    mergeSortInternal(T, arr[mid..], temp[mid..], less);

    var i: usize = 0;
    var j: usize = mid;
    var k: usize = 0;

    while (i < mid and j < arr.len) {
        if (less(arr[i], arr[j])) {
            temp[k] = arr[i];
            i += 1;
        } else {
            temp[k] = arr[j];
            j += 1;
        }
        k += 1;
    }

    while (i < mid) {
        temp[k] = arr[i];
        i += 1;
        k += 1;
    }

    while (j < arr.len) {
        temp[k] = arr[j];
        j += 1;
        k += 1;
    }

    for (0..arr.len) |index| {
        arr[index] = temp[index];
    }
}

fn intLess(a: i32, b: i32) bool {
    return a < b;
}

pub fn main() !void {
    var data = [_]i32{ 10, 5, 2, 7, 4, 9, 12, 1, 8, 6, 11, 3 };
    const slice = data[0..];

    std.debug.print("Before sort: {any}\n", .{slice});

    var timer = try std.time.Timer.start();
    try mergeSort(i32, slice, intLess);

    std.debug.print("After sort: {any}\n", .{slice});
    std.debug.print("Elapsed time: {} ms\n", .{timer.lap()});
}
