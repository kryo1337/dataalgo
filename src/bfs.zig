const std = @import("std");

pub fn bfs(graph: [][]const usize, start: usize, visited: []bool, visit: fn (vertex: usize) void) !void {
    const allocator = std.heap.page_allocator;
    var queue = std.ArrayList(usize).init(allocator);
    defer queue.deinit();

    var count: usize = 0;

    visited[start] = true;
    try queue.append(start);
    count += 1;

    var head: usize = 0;
    while (head < count) {
        const current = queue.items[head];
        head += 1;
        visit(current);

        for (graph[current]) |child| {
            if (!visited[child]) {
                visited[child] = true;
                try queue.append(child);
                count += 1;
            }
        }
    }
}

fn visitVertex(vertex: usize) void {
    std.debug.print("visited vertex: {}\n", .{vertex});
}

pub fn main() !void {
    const adj0 = [_]usize{ 1, 2 };
    const adj1 = [_]usize{ 0, 3, 4 };
    const adj2 = [_]usize{ 0, 4 };
    const adj3 = [_]usize{1};
    const adj4 = [_]usize{ 1, 2 };

    var graph: [5][]const usize = .{
        adj0[0..],
        adj1[0..],
        adj2[0..],
        adj3[0..],
        adj4[0..],
    };

    var visited: [5]bool = .{ false, false, false, false, false };

    std.debug.print("Starting BFS from vertex 0:\n", .{});
    try bfs(graph[0..], 0, &visited, visitVertex);
}
