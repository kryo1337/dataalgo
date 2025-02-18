const std = @import("std");

pub fn dfs(graph: [][]const usize, start: usize, visited: []bool, visit: fn (vertex: usize) void) void {
    if (visited[start]) return;
    visited[start] = true;
    visit(start);
    for (graph[start]) |children| {
        dfs(graph, children, visited, visit);
    }
}

fn visitVertex(vertex: usize) void {
    std.debug.print("visited vertex: {}\n", .{vertex});
}

pub fn main() void {
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

    std.debug.print("starting DFS from vertex 0:\n", .{});
    dfs(graph[0..], 0, &visited, visitVertex);
}
