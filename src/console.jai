#scope_export
console_init :: () {
    g_console = GetStdHandle(STD_OUTPUT_HANDLE);
    mode: DWORD = 0;
    GetConsoleMode(g_console, cast(LPDWORD)*mode);
    mode |= ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(g_console, mode);
}

console_write :: (text: string) #expand {
    if !g_console then return;

    WriteConsoleA(g_console, text.data, cast(u32)text.count, null, null);
}

console_write :: (fmt: string, args: ..Any) {
    if !g_console then return;

    builder: String_Builder;
    builder.allocator = __temporary_allocator;

    print_to_builder(*builder, fmt, ..args);
    console_write(builder_to_string(*builder,, __temporary_allocator));
} @PrintLike

g_console: HANDLE = null;

#scope_file
#import "Basic";
#import "Windows";