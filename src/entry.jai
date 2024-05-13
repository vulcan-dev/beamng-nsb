#program_export
DllMain :: (hModule: HMODULE, dwReason: DWORD, lpReserved: LPVOID) -> BOOL #c_call {
    ctx: Context;
    push_context ctx {
        if (dwReason != DLL_PROCESS_ATTACH) {
            return .TRUE;
        }
        
        console_init();
        
        args := collect_arguments();
        defer free_arguments(*args);
        
        if array_find(args, "-c-allow-loadlib") then allow_loadlib();
    }

    return .TRUE;
}

#scope_file
signatures: JSON_Signatures;

#scope_file
allow_loadlib :: () -> bool {
    log("[BNG_NSB] Allowing Loadlib");

    if !parse_signatures() then return false;
    if !init_minhook() then return false;
    
    func_addr := find_pattern_v2(signatures.allow_loadlib.data, true);
    if func_addr == 0x0 {
        MessageBoxA(null, "Failed finding memory pattern", "allow_loadlib failed", MB_OK | MB_ICONERROR);
        return false;
    }

    // In my old research, I think this function was related to the tech license. So if you have it, maybe this returned 1?
    _game_is_unrestricted :: () -> s64 #c_call {
        ctx: Context;
        push_context ctx {
            log("[BNG_NSB] _game_is_unrestricted called!");
        }
        return 1;
    }
    
    log("[BNG_NSB] _game_is_unrestricted address: 0x%", formatInt(func_addr, 16));
    hook_create("_game_is_unrestricted", func_addr, _game_is_unrestricted, null);
    
    return true;
}

minhook_initialized := false;
init_minhook :: () -> bool {
    if minhook_initialized then return true;

    mh_status := MH_Initialize();
    if mh_status != .OK {
        log_error("[BNG_NSB] MH_Initialize failed: %\n", to_string(mh_status));
        return false;
    }
    
    minhook_initialized = true;
    return true;
}

parsed_signatures := false;
parse_signatures :: () -> bool {
    if parsed_signatures then return true;
    
    json_data, success := read_entire_file("signatures.json");
    if !success {
        log_error("[BNG_NSB] Failed reading \"signatures.json\"");
        return false;
    }
    
    success, signatures = json_parse_string(json_data, JSON_Signatures, ignore_unknown=false);
    if !success {
        log_error("[BNG_NSB] Failed parsing JSON data");
        return false;
    }
    
    parsed_signatures = true;
    return true;
}

#scope_file
collect_arguments :: () -> []string {
    commandLine := GetCommandLineW();
    argc: s32 = 0;

    wide_args := CommandLineToArgvW(commandLine, *argc);
    argv := cast(**u8)alloc(size_of(*u8) * argc);

    args_array := NewArray(argc, string);

    // Convert arguments to multibyte and update argv & args_array
    for 0..argc-1 {
        needed := WideCharToMultiByte(CP_UTF8, 0, wide_args[it], -1, null, 0, null, null);
        argv[it] = cast(*u8)alloc(needed);

        if WideCharToMultiByte(CP_UTF8, 0, wide_args[it], -1, argv[it], needed, null, null) <= 0 {
            log_error("[BNG_NSB] Failed collecting arguments, WideCharToMultiByte failed on argument [%]", it);
            continue;
        }

        args_array[it] = to_string(argv[it]);
    }

    __command_line_arguments.count = argc;
    __command_line_arguments.data  = argv;

    return args_array;
}

free_arguments :: (args_array: *[]string) {
    for 0..__command_line_arguments.count {
        free(__command_line_arguments.data[it]);
    }

    array_reset(args_array);
}

#scope_file
#import "Windows";
#import "System";
#import "String";
#import "File";

Utf8 :: #import "Windows_Utf8";

#import "MinHook";
#import "jaison";

#load "win32def.jai";
#load "console.jai";
#load "memory.jai";
#load "hook.jai";

JSON_Signatures :: struct {
    allow_loadlib: string;
}