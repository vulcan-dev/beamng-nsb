#program_export
DllMain :: (hModule: HMODULE, dwReason: DWORD, lpReserved: LPVOID) -> BOOL #c_call {
    if (dwReason != DLL_PROCESS_ATTACH) {
        return .TRUE;
    }
    
    DisableThreadLibraryCalls(hModule);
    
    if !entry_func() {
        return .FALSE;
    }
    
    return .TRUE;
}

#scope_file
signatures: JSON_Signatures;

#scope_file
entry_func :: () -> s32 #c_call {
    ctx: Context;
    push_context ctx {
        console_init();
        
        args := collect_arguments();
        defer free_arguments(*args);
        
        root := path_decomp(args[0]);
        
        if !read_signatures(root) {
            return 0;
        }
        
        if array_find(args, "-c-allow-loadlib") then allow_loadlib();
        if array_find(args, "-c-unrestrict-openwebbrowser") then unrestrict_open_web_browser();
    }
    
    return 1;
}

allow_loadlib :: () -> bool {
    log("[BNG_NSB] Allowing Loadlib");

    if !init_minhook() then return false;
    
    func_addr := memory_find_pattern(signatures.allow_loadlib.data, true);
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

unrestrict_open_web_browser :: () -> bool {
    log("[BNG_NSB] Unrestricting openWebBrowser");

    /*
    sub_7FF6274652F0+CA   0F8                 call    sub_7FF6274D43D0
    sub_7FF6274652F0+CF   0F8                 test    al, al
    sub_7FF6274652F0+D1   0F8                 jnz     short loc_7FF627465437 <-- We just want to change this JNZ (jump not zero) to a JMP
    sub_7FF6274652F0+D3   0F8                 lea     rax, aUnableToOpenWe_0 ; "unable to open webpage due to domain fi"...
    */

    jnz_addr := memory_find_pattern(signatures.openWebBrowser_jnz.data);

    if jnz_addr == 0x0 {
        MessageBoxA(null, "Failed finding memory pattern", "unrestrict_open_web_browser failed", MB_OK | MB_ICONERROR);
        return false;
    }
    
    if !memory_protect(xx jnz_addr, 2, #code {
        jnz_inst: *u8 = xx jnz_addr;
        if jnz_inst.* != 0x75 {
            message_box(MB_OK | MB_ICONERROR, EXE_NAME, "Invalid instruction, game may have updated and we have the wrong address");
            return false;
        }

        memory_print_as_string(xx jnz_addr, 16, "openWebBrowser_jnz before: ");
        jnz_inst.* = 0xEB; // Change the first byte from JNZ (0x75) to JMP (0xEB) instruction
        memory_print_as_string(xx jnz_addr, 16, "openWebBrowser_jnz after: ");
    }) {
        message_box(MB_OK | MB_ICONERROR, EXE_NAME, "Something went wrong!");
        return false;
    }

    return true;
}

minhook_initialized := false;
init_minhook :: () -> bool {
    if minhook_initialized then return true;

    mh_status := MH_Initialize();
    if mh_status != .OK {
        log("[BNG_NSB] MH_Initialize failed: %\n", to_string(mh_status));
        return false;
    }
    
    minhook_initialized = true;
    return true;
}

parsed_signatures := false;
read_signatures :: (game_root: string) -> bool {
    if parsed_signatures then return true;
    parsed_signatures = true;
    
    log("Reading signatures");
    
    log("%", tprint("%/signatures.json", game_root));
    json_data, success := read_entire_file(tprint("%/signatures.json", game_root));
    if !success {
        MessageBoxA(null, "AAA", "unrestrict_open_web_browser failed", MB_OK | MB_ICONERROR);
        log("[BNG_NSB] Failed reading \"signatures.json\"");
        return false;
    }
    
    success, signatures = json_parse_string(json_data, JSON_Signatures, ignore_unknown=false);
    if !success {
        MessageBoxA(null, "AA", "unrestrict_open_web_browser failed", MB_OK | MB_ICONERROR);
        log("[BNG_NSB] Failed parsing JSON data");
        return false;
    }

    // Check for any missing signatures
    sb: String_Builder;
    defer free_buffers(*sb);
    
    is_missing_signatures := false;
    
    tis := cast(*Type_Info_Struct)JSON_Signatures;
    for tis.members {
        ptr := (cast(*void)*signatures) + it.offset_in_bytes;
        value := (cast(*string)ptr).*;
        log("%", value);
        if value == "" {
            if !is_missing_signatures {
                append(*sb, "Missing signatures:\n");
                is_missing_signatures = true;
            }
        
            append_value := tprint("  %\n", it.name);
            append(*sb, append_value);
            log("Missing signature: %", it.name);
        }
    }
    
    if is_missing_signatures {
        sb_string := builder_to_string(*sb);
        MessageBoxA(null, sb_string.data, "Failed reading signatures", MB_OK | MB_ICONERROR);
        return false;
    }
    
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
            log("[BNG_NSB] Failed collecting arguments, WideCharToMultiByte failed on argument [%]", it);
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
#load "helpers.jai";

JSON_Signatures :: struct {
    allow_loadlib: string;
    openWebBrowser_jnz: string;
}

EXE_NAME :: "BeamNG.drive.x64.exe";