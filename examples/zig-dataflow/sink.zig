const std = @import("std");
const fmt = std.fmt;

const dora = @cImport({
    @cInclude("apis/c/node/node_api.h");
});

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    try stdout.print("[zig sink] Hello World\n", .{});

    const dora_context = dora.init_dora_context_from_env();

    if (dora_context == null) {
        try stdout.print("Failed to create dora context\n", .{});
        return;
    }

    try stdout.print("[zig sink] dora context initialized\n", .{});

    while (true) {
        const event = dora.dora_next_event(dora_context);
        if (event == null) {
            try stdout.print("[zig sink] ERROR: unexpected end of event\n", .{});
            break;
        }

        const ty: dora.DoraEventType = dora.read_dora_event_type(event);

        if (ty == dora.DoraEventType_Input) {
            var id: [*]u8 = undefined;
            var id_len: usize = undefined;
            dora.read_dora_input_id(event, @ptrCast(&id), @ptrCast(&id_len));

            var data: [*]u8 = undefined;
            var data_len: usize = undefined;
            dora.read_dora_input_data(event, @ptrCast(&data), @ptrCast(&data_len));

            try stdout.print("[zig sink] received input \'{s}\'", .{id[0..id_len]});
            try stdout.print(" with data: {s}\n", .{data[0..data_len]});
        } else if (ty == dora.DoraEventType_InputClosed) {
            try stdout.print("[zig sink] received InputClosed event\n", .{});
        } else if (ty == dora.DoraEventType_Stop) {
            try stdout.print("[zig sink] received stop event\n", .{});
        } else {
            try stdout.print("[zig sink] received unexpected event: {d}\n", .{ty});
        }

        dora.free_dora_event(event);
    }

    dora.free_dora_context(dora_context);

    try stdout.print("[zig sink] finished successfully\n", .{});
}
