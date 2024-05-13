#scope_export
Signature :: struct {
    pattern:    *u8;
    mask:       *u8;
    relative: bool;
}

get_module_info :: () {
    if base_address != 0 then return;

    mi: MODULEINFO;
    if !GetModuleInformation(GetCurrentProcess(), GetModuleHandleA(null), *mi, size_of(MODULEINFO)) {
        MessageBoxA(null, "GetModuleInformation Failed", "JAIMP", MB_OK | MB_ICONERROR);
        return;
    }

    base_address = cast(u64)mi.lpBaseOfDll;
    module_size = mi.SizeOfImage;   
}

get_game_base :: () -> u64 {
    return base_address;
}

pattern_compare :: (data: *u8, pattern: *u8, mask: *u8) -> bool {
    while mask.* {
        if mask.* == #char "x" && data.* != pattern.* then return false;
        data += 1;
        pattern += 1;
        mask += 1;
    }
    return true;
}

read_ptr :: (addr: u64, offset: u32) -> s64 #no_abc  {
    rel_offset := (cast(*s32)(addr + offset)).*;
    return (cast(s64)(addr) + rel_offset + size_of(s32)) + cast(s64)offset;
}

find_pattern_v2 :: (pattern_u8: *u8, relative: bool = false) -> u64 #no_abc {
    get_module_info();

    pattern := to_string(pattern_u8);
    code_to_ida_style(*pattern);

    mask_len: u16 = cast(u16)pattern.count / 4;
    mask := create_mask_for_ida_pattern(pattern);

    escaped := escape_ida_code_pattern(pattern);

    // logformatInt("pattern: %, mask: %, escaped: %\n", pattern, cast(string)mask, cast(string)escaped);
    return find_pattern(.{ escaped.data, mask.data, ((pattern[0] == #char "E" && pattern[1] == #char "8") || relative) });
}

find_pattern :: (sig: Signature) -> u64 #no_abc {
    for 0..module_size - 1 {
        if pattern_compare(cast(*u8)(base_address + it), sig.pattern, sig.mask) {
            if sig.relative then return xx read_ptr(xx(base_address + it), 1);
            return base_address + it;
        }
    }

    return 0;
}

get_signature_and_mask :: (sig: *u8) -> [..]u8, [..]u8 {
    pattern := to_string(sig);
    code_to_ida_style(*pattern);

    mask_len: u16 = cast(u16)pattern.count / 4;
    mask := create_mask_for_ida_pattern(pattern);

    escaped := escape_ida_code_pattern(pattern);
    return escaped, mask;
}

// Unused right now
get_function_from_ida :: (sig: $S, mask: $M, fn: *$T, relative: bool = false) #modify {
    return (cast(*Type_Info_Struct)T).type == .PROCEDURE;
} {
    result := find_pattern(.{sig.data, mask.data, relative});
    assert(result, tprint("Invalid Signature: %", to_string(sig.data)));

    fn.* = cast(T)result;
}

get_function_from_ida :: (sig: *u8, fn: *$T, relative: bool = false, off: u32 = 0) #modify {
    ti: Type_Info_Struct = cast(*Type_Info_Struct)T;
    return ti.type == .PROCEDURE;
} {
    result := find_pattern_v2(sig, relative);
    assert(result != 0, tprint("Invalid Signature: %", to_string(sig)));
    
    fn.* = cast(T)(result - off);
    print("Got function: 0x%\n", formatInt(result, 16));
}

#scope_file
escape_ida_code_pattern :: (pattern: string) -> [..]u8 #no_abc {
    escaped: [..]u8;
    array_reserve(*escaped, pattern.count / 4); // speedy (this is always the amount we end up with)

    for i: 0..pattern.count - 1 {
        if pattern.data[i] == #char "\\" && pattern.data[i+1] == #char "x" { // If it's \x
            if i + 3 < pattern.count { // Could be xE8 for example
                hex: string = slice(pattern, i + 2, 2); // E8
                escaped_char: u8 = xx string_to_int(hex, 16); // Escape E8
                array_add(*escaped, escaped_char);
                i += 3; // Skip to the next part: \xE8\x00\x33
                        //                             ^ We are now here.
            } else {
                // Add \x
                array_add(*escaped, #char "\\");
                array_add(*escaped, #char "x");
            }
        } else {
            array_add(*escaped, pattern.data[i]);
        }
    }

    // This has been commented more just to help me visualise it better in the future.
    return escaped;
}

code_to_ida_style :: (pattern: *string) {
    pattern.* = replace(pattern.*, "??", "?"); // If we use the other IDA plugin, we will get ?? instead of just ?, you know what I mean??
    pattern.* = replace(pattern.*, "?", "CC");
    pattern.* = replace(pattern.*, " ", "\\x");
    pattern.* = join("\\x", pattern.*);
}

create_mask_for_ida_pattern :: (pattern: string) -> [..]u8 #no_abc {
    mask_len: u16 = cast(u16)pattern.count / 4;

    mask: [..]u8;
    array_reserve(*mask, mask_len - 1);

    for 1..mask_len {
        idx := it * 4 - 1;
        print("%, ", idx);
        if pattern.data[idx] == #char "C" && pattern.data[idx - 1] == #char "C" {
            array_add(*mask, #char "?");
        } else {
            array_add(*mask, #char "x");
        }
    }

    print("\n");
    return mask;
}

base_address: u64 = 0;
module_size: u32 = 0;