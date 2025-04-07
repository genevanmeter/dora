const std = @import("std");
const fmt = std.fmt;

const dora = @cImport({
    @cInclude("apis/c/node/node_api.h");
});

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const assert = std.debug.assert;

    try stdout.print("[zig node] Hello World\n", .{});

    const dora_context = dora.init_dora_context_from_env();

    if (dora_context == null) {
        try stdout.print("Failed to create dora context\n", .{});
        return;
    }

    for (0..100) |i| {
        const event = dora.dora_next_event(dora_context);
        if (event == null) {
            try stdout.print("[zig node] ERROR: unexpected end of event\n", .{});
            break;
        }

        const ty: dora.DoraEventType = dora.read_dora_event_type(event);

        if (ty == dora.DoraEventType_Input) {
            var data: [*]u8 = undefined;
            var data_len: usize = undefined;
            dora.read_dora_input_data(event, @ptrCast(&data), @ptrCast(&data_len));

            assert(data_len == 0);

            const out_id: []const u8 = "message";
            var out_data: [50]u8 = undefined;

            const out = try fmt.bufPrint(out_data[0..], "loop iteration {d}", .{i});

            _ = dora.dora_send_output(dora_context, @constCast(@ptrCast(out_id)), out_id.len, @ptrCast(out), out.len);
        } else if (ty == dora.DoraEventType_Stop) {
            try stdout.print("[zig node] received stop event\n", .{});
        } else {
            try stdout.print("[zig node] received unexpected event: {d}\n", .{ty});
        }

        dora.free_dora_event(event);
    }

    dora.free_dora_context(dora_context);

    try stdout.print("[zig node] finished successfully\n", .{});
}
