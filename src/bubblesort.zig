const std = @import("std");

pub fn bubbleSort(comptime T: type, arr: []T, less: fn (a: T, b: T) bool) void {
    if (arr.len <= 1) return;
    var l: usize = 0;

    var swapped = true;
    var n = arr.len;

    while (swapped) : (l += 1) {
        swapped = false;
        var i: usize = 0;
        while (i < n - 1) : (i += 1) {
            if (less(arr[i + 1], arr[i])) {
                std.mem.swap(T, &arr[i], &arr[i + 1]);
                swapped = true;
            }
        }
        n -= 1;
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
    bubbleSort(i32, slice, intLess);

    std.debug.print("After sort: {any}\n", .{slice});
    std.debug.print("Elapsed time: {} ms\n", .{timer.lap()});
}
