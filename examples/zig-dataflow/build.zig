const std = @import("std");

pub fn link_dora(obj: *std.Build.Step.Compile) void {
    obj.addIncludePath(.{ .cwd_relative = "../.." });
    obj.addLibraryPath(.{ .cwd_relative = "../../target/release" });
    obj.linkSystemLibrary("dora_node_api_c");
    obj.linkSystemLibrary("dora_operator_api_c");
    obj.linkSystemLibrary("unwind");
}

pub fn build(b: *std.Build) void {
    const node = b.addExecutable(.{
        .name = "node",
        .root_source_file = b.path("node.zig"),
        .target = b.graph.host,
    });

    const sink = b.addExecutable(.{
        .name = "sink",
        .root_source_file = b.path("sink.zig"),
        .target = b.graph.host,
    });

    link_dora(node);
    link_dora(sink);

    b.installArtifact(node);
    b.installArtifact(sink);
}
